import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BookingReferenceCard extends StatelessWidget {
  final String referenceNumber;

  const BookingReferenceCard({super.key, required this.referenceNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2FC1BE)),
      ),

      child: Column(
        children: [
          Text('Booking Reference'.tr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5A606A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            referenceNumber,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2FC1BE),
            ),
          ),
        ],
      ),
    );
  }
}
