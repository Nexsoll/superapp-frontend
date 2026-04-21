import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_service.dart';

class AuthService {
  static String get baseUrl => '${ApiService.baseUrl}/auth';

  // Helper to get headers with token
  Map<String, String> _headers({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final t = (token ?? '').trim();
    if (t.isNotEmpty) {
      headers['Authorization'] = 'Bearer $t';
    }
    return headers;
  }

  Future<List<Map<String, dynamic>>> getUsers({String? query}) async {
    final base = _usersBaseUrl;
    final q = (query ?? '').trim();
    final url = Uri.parse(q.isEmpty ? base : '$base?q=${Uri.encodeComponent(q)}');

    try {
      final response = await http.get(url, headers: _headers());
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        throw Exception('Invalid response');
      }

      throw Exception('Failed to load users: ${response.body}');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> socialLogin({
    required String idToken,
    required String provider,
  }) async {
    final url = Uri.parse('$baseUrl/social-login');
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({
          'idToken': idToken,
          'provider': provider,
        }),
      );

      return _handleResponse(response, 'social login');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        }),
      );

      return _handleResponse(response, 'register');
    } catch (e) {
      // Re-throw to be handled by controller
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/verify-otp');
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      return _handleResponse(response, 'verify OTP');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      return _handleResponse(response, 'login');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final url = Uri.parse('$baseUrl/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({'email': email}),
      );

      return _handleResponse(response, 'forgot password');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/reset-password');
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      return _handleResponse(response, 'reset password');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/verify-reset-otp');
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      return _handleResponse(response, 'verify reset OTP');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  // New method for updating profile
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String token,
    String? fullName,
    String? gender,
    String? currency,
    String? language,
    bool? isProfileComplete,
  }) async {
    final url = Uri.parse('$baseUrl/../users/$userId');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token', // Uncomment when backend protects this route
        },
        body: jsonEncode({
          if (fullName != null) 'fullName': fullName,
          if (gender != null)
            'gender':
                gender, // Ensure backend expects UPPERCASE if using enum, or handle mapping
          if (currency != null) 'currency': currency,
          if (language != null)
            'language': language
                .toUpperCase(), // Map 'English' -> 'ENGLISH' in controller or here
          if (isProfileComplete != null) 'isProfileComplete': isProfileComplete,
        }),
      );

      return _handleResponse(response, 'update profile');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Base URL for /users endpoints
  static String get _usersBaseUrl => '${ApiService.baseUrl}/users';

  /// Edit user profile (name, email, phone, avatar)
  Future<Map<String, dynamic>> editUserProfile({
    required int userId,
    String? fullName,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? avatar,
  }) async {
    final url = Uri.parse('$_usersBaseUrl/$userId');

    final body = <String, dynamic>{};
    if (fullName != null && fullName.isNotEmpty) body['fullName'] = fullName;
    if (firstName != null && firstName.isNotEmpty)
      body['firstName'] = firstName;
    if (lastName != null && lastName.isNotEmpty) body['lastName'] = lastName;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phoneNumber != null && phoneNumber.isNotEmpty)
      body['phoneNumber'] = phoneNumber;
    if (avatar != null && avatar.isNotEmpty) body['avatar'] = avatar;

    try {
      final response = await http.patch(
        url,
        headers: _headers(),
        body: jsonEncode(body),
      );

      return _handleResponse(response, 'edit profile');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  /// Upload avatar image for user
  Future<Map<String, dynamic>> uploadAvatar({
    required int userId,
    required File imageFile,
  }) async {
    final url = Uri.parse('$_usersBaseUrl/$userId/avatar');

    try {
      final request = http.MultipartRequest('PATCH', url);

      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();

      final multipartFile = http.MultipartFile(
        'avatar',
        stream,
        length,
        filename: 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(responseBody);
      } else {
        throw Exception('Failed to upload avatar: $responseBody');
      }
    } catch (e) {
      throw Exception('Error uploading avatar: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response, String action) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      // Try to parse error message from body
      try {
        final body = jsonDecode(response.body);
        final message = body['message'] ?? body['error'] ?? 'Unknown error';
        throw Exception('Failed to $action: $message');
      } catch (_) {
        throw Exception('Failed to $action: ${response.body}');
      }
    }
  }

  Future<Map<String, dynamic>> markAsRead({
    required String token,
    required int senderId,
    int? propertyId,
  }) async {
    final queryParams = propertyId != null ? '?propertyId=$propertyId' : '';
    final url = Uri.parse('$_messagesBaseUrl/mark-read/$senderId$queryParams');

    try {
      final response = await http.post(url, headers: _headers(token: token));
      return _handleResponse(response, 'mark as read');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  static String get _messagesBaseUrl => '${ApiService.baseUrl}/messages';

  Future<List<Map<String, dynamic>>> getThreads({required String token}) async {
    final url = Uri.parse('$_messagesBaseUrl/threads');

    try {
      final response = await http.get(url, headers: _headers(token: token));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        throw Exception('Invalid response');
      }
      throw Exception('Failed to load threads: ${response.body}');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMessagesWithUser({
    required String token,
    required int otherUserId,
    int? propertyId,
  }) async {
    final queryParams = propertyId != null ? '?propertyId=$propertyId' : '';
    final url = Uri.parse('$_messagesBaseUrl/with/$otherUserId$queryParams');

    try {
      final response = await http.get(url, headers: _headers(token: token));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        throw Exception('Invalid response');
      }
      throw Exception('Failed to load messages: ${response.body}');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> sendDirectMessage({
    required String token,
    required int receiverId,
    required String content,
    int? propertyId,
  }) async {
    final url = Uri.parse('$_messagesBaseUrl/send');

    try {
      final response = await http.post(
        url,
        headers: _headers(token: token),
        body: jsonEncode({
          'receiverId': receiverId,
          'content': content,
          if (propertyId != null) 'propertyId': propertyId,
        }),
      );
      return _handleResponse(response, 'send message');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> updateMyFcmToken({
    required String token,
    required String fcmToken,
  }) async {
    final url = Uri.parse('$_usersBaseUrl/me/fcm-token');

    try {
      final response = await http.patch(
        url,
        headers: _headers(token: token),
        body: jsonEncode({'fcmToken': fcmToken}),
      );
      return _handleResponse(response, 'update fcm token');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> getMe({required String token}) async {
    final url = Uri.parse('$_usersBaseUrl/me');

    try {
      final response = await http.get(url, headers: _headers(token: token));
      return _handleResponse(response, 'get profile');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}
