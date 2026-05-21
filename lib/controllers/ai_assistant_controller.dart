import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'
    show TextEditingController, ScrollController, Curves;
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';
import 'package:superapp/modal/ai_chat_message.dart';

class AiAssistantController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final AudioRecorder _recorder = AudioRecorder();

  final RxList<AiChatMessage> messages = <AiChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRecording = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Add initial welcome message
    messages.add(
      AiChatMessage(
        type: AiMessageType.text,
        text:
            "Hello! I'm your AI travel assistant powered by advanced machine learning. I can help you with hotel recommendations, price prediction, room suggestions, and more.\nWhat can I help you with today?",
        isUser: false,
      ),
    );

    // Check for initial message from navigation arguments
    final args = Get.arguments;
    if (args != null && args['message'] != null) {
      messageController.text = args['message'];
      sendMessage();
    }
  }

  Future<void> toggleRecording() async {
    if (isRecording.value) {
      await _stopAndTranscribe();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      Get.snackbar('Permission', 'Microphone permission is required');
      return;
    }

    final hasPerm = await _recorder.hasPermission();
    if (!hasPerm) {
      Get.snackbar('Permission', 'Microphone permission is required');
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/ai_voice_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );
    isRecording.value = true;
  }

  Future<void> _stopAndTranscribe() async {
    // Enforce minimum recording time (1 second)
    await Future.delayed(const Duration(seconds: 1));

    String? path;
    try {
      path = await _recorder.stop();
    } catch (e) {
      isRecording.value = false;
      Get.snackbar('Error', 'Failed to stop recording: $e');
      return;
    }

    isRecording.value = false;

    if (path == null || path.isEmpty) {
      Get.snackbar('Error', 'No audio recorded');
      return;
    }

    // Check file size - warn if too small (likely silence)
    final file = File(path);
    final fileSize = await file.length();
    print('DEBUG: Recorded audio file size: $fileSize bytes');

    if (fileSize < 1000) {
      Get.snackbar(
        'Speech',
        'Recording too short or no audio detected. Try speaking louder or check microphone permissions.',
      );
      return;
    }

    isLoading.value = true;
    _scrollToBottom();

    try {
      final transcript = await _uploadAndTranscribe(File(path));
      if (transcript.trim().isEmpty) {
        Get.snackbar('Speech', 'Could not recognize any speech');
        return;
      }

      messageController.text = transcript;
      await sendMessage();
    } catch (e) {
      Get.snackbar('Error', 'Speech-to-text failed: $e');
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  Future<String> _uploadAndTranscribe(File audioFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    final isGuest = token == null || token.isEmpty;

    final baseUrl = ApiService.baseUrl;

    final uri = Uri.parse(
      isGuest
          ? '$baseUrl/ai-assistant/transcribe-guest'
          : '$baseUrl/ai-assistant/transcribe',
    );
    final request = http.MultipartRequest('POST', uri);

    if (!isGuest) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final bytes = await audioFile.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'audio',
      bytes,
      filename: audioFile.uri.pathSegments.last,
    );
    request.files.add(multipartFile);

    final streamed = await request.send();
    final bodyBytes = await streamed.stream.toBytes();
    final body = utf8.decode(bodyBytes);

    if (streamed.statusCode != 200 && streamed.statusCode != 201) {
      throw 'Transcribe failed: ${streamed.statusCode} $body';
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    return (data['text'] ?? '').toString();
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    messages.add(
      AiChatMessage(type: AiMessageType.text, text: text, isUser: true),
    );

    messageController.clear();
    isLoading.value = true;
    _scrollToBottom();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      final isGuest = token == null || token.isEmpty;

      final baseUrl = ApiService.baseUrl;
      final uri = Uri.parse(
        isGuest
            ? '$baseUrl/ai-assistant/chat-guest'
            : '$baseUrl/ai-assistant/chat',
      );

      final headers = {
        'Content-Type': 'application/json',
      };
      if (!isGuest) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({'message': text}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final backendMessages = data['messages'] as List;

        for (final msg in backendMessages) {
          if (msg['type'] == 'text') {
            messages.add(
              AiChatMessage(
                type: AiMessageType.text,
                text: msg['content'],
                isUser: false,
              ),
            );
          } else if (msg['type'] == 'hotel_list') {
            print('DEBUG: Received hotel_list data: ${msg['data']}');
            final hotels = (msg['data'] as List).map((h) {
              print('DEBUG: Individual hotel JSON: $h');
              return AiHotel.fromJson(h);
            }).toList();
            messages.add(
              AiChatMessage(
                type: AiMessageType.hotelList,
                hotels: hotels,
                isUser: false,
              ),
            );
          } else if (msg['type'] == 'chart') {
            final chartData = AiChartData.fromJson(msg['data']);
            messages.add(
              AiChatMessage(
                type: AiMessageType.chart,
                chartData: chartData,
                isUser: false,
              ),
            );
          }
        }
      } else {
        Get.snackbar('Error', 'Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    _recorder.dispose();
    super.onClose();
  }
}
