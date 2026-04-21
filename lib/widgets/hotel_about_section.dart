import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HotelAboutSection extends StatelessWidget {
  final String description;

  const HotelAboutSection({super.key, this.description = ''});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayText = description.isNotEmpty
        ? description
        : 'Experience luxury at its finest in the heart of London. Our hotel offers world-class service, elegant rooms, and breathtaking views of the city. Perfect for both business and leisure travelers.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About'.tr,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1D2330),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          displayText,
          style: TextStyle(
            color: theme.brightness == Brightness.dark
                ? Colors.white70
                : const Color(0xFF9AA0AF),
            fontSize: 15,
            height: 1.6,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
