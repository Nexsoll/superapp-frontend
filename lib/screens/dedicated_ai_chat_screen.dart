import 'package:flutter/foundation.dart';
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

class DedicatedAiChatScreen extends StatelessWidget {
  const DedicatedAiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate or find the controller
    final AiAssistantController controller = Get.put(AiAssistantController());
    final theme = Theme.of(context);
    final isDesktopWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 900;

    if (isDesktopWeb) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.primary),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Back to Stays'.tr,
            style: GoogleFonts.outfit(
              color: theme.colorScheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.13,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Assistant'.tr,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Ask about hotels, prices, rooms, staff, and operations.'.tr,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.66),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.35),
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Obx(
                            () => ListView.builder(
                              controller: controller.scrollController,
                              padding: const EdgeInsets.all(24),
                              itemCount: controller.messages.length +
                                  (controller.isLoading.value ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == controller.messages.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final message = controller.messages[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: _buildMessageItem(context, message),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildInputArea(context, controller),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1CB5B3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'AI Assistant'.tr,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: controller.messages.length +
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
          _buildInputArea(context, controller),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, AiChatMessage message) {
    if (message.isUser) {
      final maxWidth = kIsWeb && MediaQuery.sizeOf(context).width >= 900
          ? 560.0
          : MediaQuery.of(context).size.width * 0.85;
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
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

      final maxWidth = kIsWeb && MediaQuery.sizeOf(context).width >= 900
          ? 640.0
          : MediaQuery.of(context).size.width * 0.85;
      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      );
    }
  }

  Widget _buildInputArea(BuildContext context, AiAssistantController controller) {
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
                _SuggestionChip(label: 'Predict Price Trends'),
                SizedBox(width: 8),
                _SuggestionChip(label: 'Find Properties'),
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
              Text(
                'AI Assistant'.tr,
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
    ProfileController? profileController;
    try {
      profileController = Get.find<ProfileController>();
    } catch (_) {}

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
              ClipOval(
                child: profileController != null && profileController.photoUrl.value.isNotEmpty
                    ? Image.network(
                        profileController.photoUrl.value,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                      )
                    : _buildDefaultAvatar(),
              ),
              const SizedBox(width: 8),
              Text(
                profileController != null ? profileController.displayName : 'Guest Traveler',
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

  Widget _buildDefaultAvatar() {
    return Container(
      width: 24,
      height: 24,
      color: const Color(0x201CB5B3),
      child: const Icon(
        Icons.person_rounded,
        size: 16,
        color: Color(0xFF1CB5B3),
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
        final data = hotel.hotelData ??
            {
              'id': hotel.id,
              'title': hotel.name,
              'address': hotel.location,
              'images': ['placeholder'],
            };

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
                  Text(
                    'Current Price'.tr,
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
                  Text(
                    'Best Price'.tr,
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
            height: 180,
            padding: const EdgeInsets.only(top: 10, right: 10),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: TextStyle(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < data!.xLabels.length) {
                          return Text(
                            data!.xLabels[idx],
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 9,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data!.points.length - 1).toDouble(),
                minY: (data!.bestPrice - 20).clamp(0.0, double.infinity),
                maxY: data!.currentPrice + 20,
                lineBarsData: [
                  LineChartBarData(
                    spots: data!.points
                        .asMap()
                        .entries
                        .map((e) => FlSpot(
                              e.key.toDouble(),
                              (e.value['y'] as num).toDouble(),
                            ))
                        .toList(),
                    isCurved: true,
                    color: const Color(0xFF1CB5B3),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF1CB5B3).withValues(alpha: 0.15),
                    ),
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
