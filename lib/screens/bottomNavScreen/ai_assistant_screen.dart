import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:superapp/controllers/ai_assistant_controller.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/modal/ai_chat_message.dart';
import 'package:superapp/services/listing_service.dart';
import 'package:superapp/screens/hotel_detail_screen.dart';
import 'package:superapp/screens/property_detail_screen.dart';

class AiAssistantScreen extends StatelessWidget {
  AiAssistantScreen({super.key});

  final AiAssistantController controller = Get.put(AiAssistantController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount:
                    controller.messages.length +
                    (controller.isLoading.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.messages.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final message = controller.messages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildMessageItem(context, message),
                  );
                },
              ),
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, AiChatMessage message) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          child: _UserMessage(message: message.text ?? ''),
        ),
      );
    } else {
      Widget content;
      switch (message.type) {
        case AiMessageType.text:
          content = _AiMessage(message: message.text ?? '');
          break;
        case AiMessageType.hotelList:
          content = _HotelList(hotels: message.hotels ?? []);
          break;
        case AiMessageType.chart:
          content = _PricePredictionCard(data: message.chartData);
          break;
      }

      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          child: content,
        ),
      );
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1CB5B3),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Assistant'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text('Powered by machine learning'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.dark
                ? Colors.white10
                : const Color(0xFFF3F4F6),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: controller.messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask about hotels, prices, rooms...'.tr,
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 14,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white70
                          : const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
              const SizedBox(width: 10),
              Obx(
                () => GestureDetector(
                  onTap: controller.toggleRecording,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: controller.isRecording.value
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF2FC1BE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.isRecording.value
                          ? Icons.stop_rounded
                          : Icons.mic_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: controller.sendMessage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2FC1BE), // Teal color
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      'assets/send.svg',
                      // ignore: deprecated_member_use
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                _SuggestionChip(label: 'Recommend Hotels'),
                SizedBox(width: 8),
                _SuggestionChip(label: 'Available jobs'),
                SizedBox(width: 8),
                _SuggestionChip(label: 'List all staff'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;

  const _SuggestionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        final controller = Get.find<AiAssistantController>();
        controller.messageController.text = label;
        controller.sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? Colors.white54
                : const Color(0xFF6B7280),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}

class _AiMessage extends StatelessWidget {
  final String message;
  const _AiMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/Ai.svg',
                width: 24,
                height: 24,
                // ignore: deprecated_member_use
                color: const Color(0xFF1CB5B3),
              ),
              const SizedBox(width: 8),
              Text('AI Assistant'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1CB5B3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.outfit(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMessage extends StatelessWidget {
  final String message;
  const _UserMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileController = Get.find<ProfileController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Obx(() {
                final photo = profileController.photoUrl.value;
                return ClipOval(
                  child: photo.isNotEmpty
                      ? Image.network(
                          photo,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => SvgPicture.asset(
                            'assets/Ai.svg',
                            width: 24,
                            height: 24,
                            // ignore: deprecated_member_use
                            color: const Color(0xFF1CB5B3),
                          ),
                        )
                      : SvgPicture.asset(
                          'assets/Ai.svg',
                          width: 24,
                          height: 24,
                          // ignore: deprecated_member_use
                          color: const Color(0xFF1CB5B3),
                        ),
                );
              }),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  profileController.displayName,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1CB5B3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.outfit(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotelList extends StatelessWidget {
  final List<AiHotel> hotels;
  const _HotelList({required this.hotels});

  @override
  Widget build(BuildContext context) {
    if (hotels.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: hotels
            .map(
              (hotel) => Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _HotelRecommendationCard(hotel: hotel),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _HotelRecommendationCard extends StatelessWidget {
  final AiHotel hotel;
  const _HotelRecommendationCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProperty = hotel.type == 'Property';

    return GestureDetector(
      onTap: () {
        // Debug: Print what data we have
        print('AI Item ID: ${hotel.id}');
        print('AI Item Name: ${hotel.name}');
        print('AI Item Type: ${hotel.type}');
        print('AI Item Data: ${hotel.hotelData}');

        // Navigate with hotelData if available, otherwise create minimal data with ID
        final data =
            hotel.hotelData ??
            {
              'id': hotel.id,
              'title': hotel.name,
              'address': hotel.location,
              'images': ['placeholder'],
            };

        print('Navigating with data: $data');

        // Navigate to appropriate detail screen based on type
        if (isProperty) {
          Get.to(() => PropertyDetailScreen(propertyData: data));
        } else {
          Get.to(() => HotelDetailScreen(hotelData: data));
        }
      },
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1CB5B3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
              child: Image.network(
                hotel.id > 0
                    ? (isProperty
                          ? ListingService.propertyImageUrl(hotel.id, 0)
                          : ListingService.hotelImageUrl(hotel.id, 0))
                    : hotel.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: const Color(0xFFF3F4F6),
                  child: Icon(
                    isProperty ? Icons.home_outlined : Icons.hotel_outlined,
                    color: const Color(0xFF9CA3AF),
                    size: 40,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hotel.name,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ADE80),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            hotel.match,
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hotel.location,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF9CA3AF),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '\$${hotel.price.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1CB5B3),
                            ),
                          ),
                          if (!isProperty)
                            TextSpan(
                              text: '/night',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricePredictionCard extends StatelessWidget {
  final AiChartData? data;
  const _PricePredictionCard({this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Price'.tr,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    '\$${data!.currentPrice.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1CB5B3),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.trending_down_rounded,
                color: Color(0xFF4ADE80),
                size: 32,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Best Price'.tr,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    '\$${data!.bestPrice.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4ADE80),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF059669).withOpacity(0.2)
                  : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFFFCD34D),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book on Feb 5 to save \$39', // Could also be dynamic
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF059669),
                        ),
                      ),
                      Text(
                        '${data!.confidence}% confidence based on AI analysis',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFE5E7EB),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data!.xLabels.length) {
                          return Text(
                            data!.xLabels[index],
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data!.points.asMap().entries.map((e) {
                      return FlSpot(
                        e.key.toDouble(),
                        (e.value['y'] as num).toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF60A5FA),
                    barWidth: 2.5,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
