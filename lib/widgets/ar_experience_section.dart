import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/screens/ar_room_tour_screen.dart';

class ARExperienceSection extends StatelessWidget {
  const ARExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // 16% opacity teal background
        color: theme.brightness == Brightness.dark ? const Color(0xFF2FC1BE).withOpacity(0.1) : const Color(0x292FC1BE),
        borderRadius: BorderRadius.circular(30),
        // full-opacity teal border
        border: Border.all(
            color: const Color(0xFF2FC1BE), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF2FC1BE),
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Image.asset(
                    'assets/ai.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Experience in AR'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Take a virtual 360º tour of rooms'.tr,
                    style: TextStyle(
                      color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF1D2330),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Get.to(() => const ArRoomTourScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2FC1BE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text('Start Tour'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
