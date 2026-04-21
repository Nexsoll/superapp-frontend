import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HotelAmenitiesSection extends StatelessWidget {
  final List<String> amenities;

  const HotelAmenitiesSection({super.key, this.amenities = const []});

  static const Map<String, IconData> _amenityIcons = {
    'free wifi': Icons.wifi_rounded,
    'wifi': Icons.wifi_rounded,
    'breakfast': Icons.local_cafe_rounded,
    'restaurant': Icons.restaurant_rounded,
    'parking': Icons.local_parking_rounded,
    'pool': Icons.pool_rounded,
    'swimming pool': Icons.pool_rounded,
    'gym': Icons.fitness_center_rounded,
    'fitness': Icons.fitness_center_rounded,
    'spa': Icons.spa_rounded,
    'bar': Icons.local_bar_rounded,
    'room service': Icons.room_service_rounded,
    'laundry': Icons.local_laundry_service_rounded,
    'ac': Icons.ac_unit_rounded,
    'air conditioning': Icons.ac_unit_rounded,
    'tv': Icons.tv_rounded,
    'pets': Icons.pets_rounded,
    'pet friendly': Icons.pets_rounded,
    'elevator': Icons.elevator_rounded,
    'concierge': Icons.support_agent_rounded,
  };

  static final List<Map<String, dynamic>> _defaultAmenities = [
    {'label': 'Free Wifi', 'icon': Icons.wifi_rounded},
    {'label': 'Breakfast', 'icon': Icons.local_cafe_rounded},
    {'label': 'Restaurant', 'icon': Icons.restaurant_rounded},
    {'label': 'Parking', 'icon': Icons.local_parking_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> displayAmenities;
    if (amenities.isNotEmpty) {
      displayAmenities = amenities.map((a) {
        final key = a.toLowerCase().trim();
        return {
          'label': a,
          'icon': _amenityIcons[key] ?? Icons.check_circle_outline_rounded,
        };
      }).toList();
    } else {
      displayAmenities = _defaultAmenities;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amenities'.tr,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1D2330),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: displayAmenities.map((item) {
            return Column(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF2FC1BE).withOpacity(0.1)
                        : const Color(0x292FC1BE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF2FC1BE),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    item['icon'],
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF2FC1BE)
                        : const Color(0xFF1B8785),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 70,
                  child: Text(
                    item['label'],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white70
                          : const Color(0xFF9AA0AF),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
