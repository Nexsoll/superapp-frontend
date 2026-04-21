import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BookingCard extends StatelessWidget {
  final String hotelName;
  final String location;
  final String imagePath;
  final String dateRange;
  final String status;
  final String? buttonLabel;
  final Widget? buttonIcon;
  final VoidCallback? onButtonTap;
  final VoidCallback? onBookingDetailsTap;
  final bool showActionButton;

  const BookingCard({
    super.key,
    required this.hotelName,
    required this.location,
    required this.imagePath,
    required this.dateRange,
    required this.status,
    this.buttonLabel,
    this.buttonIcon,
    this.onButtonTap,
    this.onBookingDetailsTap,
    this.showActionButton = true,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFFC107);
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9AA0AF);
    }
  }

  Widget _buildImage() {
    // Check if imagePath is a URL or local asset
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: 135,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 135,
          color: Colors.grey[300],
          child: const Icon(Icons.hotel, size: 40, color: Colors.grey),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 135,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        width: 135,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 135,
          color: Colors.grey[300],
          child: const Icon(Icons.hotel, size: 40, color: Colors.grey),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 135,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hotel Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: _buildImage(),
          ),
          // Hotel Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel Name and Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          hotelName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        'assets/hotel.svg',
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF9AA0AF),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Location
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/location.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF9AA0AF),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF747477),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Date Range
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Color(0xFF9AA0AF),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          dateRange,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF747477),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                   if (showActionButton)
                    GestureDetector(
                      onTap: onButtonTap ?? onBookingDetailsTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white10
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white24
                                : const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            buttonIcon ??
                                SvgPicture.asset(
                                  'assets/booking-detail.svg',
                                  width: 13,
                                  height: 13,
                                  colorFilter: ColorFilter.mode(
                                    theme.brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF1D2330),
                                    BlendMode.srcIn,
                                  ),
                                ),
                            const SizedBox(width: 4),
                            Text(
                              buttonLabel ?? 'Booking Details',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF1D2330),
                              ),
                            ),
                          ],
                        ),
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
