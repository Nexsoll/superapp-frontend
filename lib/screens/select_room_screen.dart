import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/room_selection_card.dart';
import '../widgets/main_bottom_bar.dart';
import 'booking_summary_screen.dart';

class SelectRoomScreen extends StatefulWidget {
  const SelectRoomScreen({super.key});

  @override
  State<SelectRoomScreen> createState() => _SelectRoomScreenState();
}

class _SelectRoomScreenState extends State<SelectRoomScreen> {
  // Mock data to match the design
  final List<Map<String, dynamic>> rooms = [
    {
      'id': 1,
      'image': 'assets/room1.png',
      'title': 'Standard Room',
      'desc': 'Comfortable room with modern amenities and city views.',
      'size': '25 m²',
      'bed': '1 King Bed',
      'guests': '2 Guests',
      'price': '180',
      'amenities': ['Free Wifi', 'TV', 'Coffee Maker'],
      'match': 99,
      'quantity': 1,
    },
    {
      'id': 2,
      'image': 'assets/room2.png',
      'title': 'Deluxe Suite',
      'desc': 'Spacious suite with separate living area and premium amenities.',
      'size': '25 m²',
      'bed': '1 King Bed+Sofa',
      'guests': '3 Guests',
      'price': '350',
      'amenities': ['Free Wifi', 'TV', 'Coffee Maker', 'Mini Bar'],
      'match': null,
      'quantity': 1,
    },
    {
      'id': 3,
      'image': 'assets/room3.png',
      'title': 'Family Room',
      'desc': 'Perfect for families with ample space and comfort.',
      'size': '25 m²',
      'bed': '2 Queen Beds',
      'guests': '4 Guests',
      'price': '300',
      'amenities': ['Free Wifi', 'TV', 'Coffee Maker'],
      'match': null,
      'quantity': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: MainBottomBar(
        currentIndex: 0, // Home tab
        onTap: (index) {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Color(0xFF2FC1BE),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('Select Room'.tr,
                                style: TextStyle(
                                  color: Color(0xFF2FC1BE), // Primary
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Outfit',
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Dec 13 - Dec 16 (3 Nights) ',
                                    style: TextStyle(
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.white70
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'Edit',
                                    style: TextStyle(
                                      color: Color(0xFF2FC1BE),
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xFF2FC1BE),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Subheader
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('3 Rooms Found'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF1D2330),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF2FC1BE).withOpacity(0.1)
                          : const Color(0xFFDFF9F8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF2FC1BE).withOpacity(0.3)
                            : const Color(0xFFBFEFED),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text('sort by : Best Value'.tr,
                          style: TextStyle(
                            color: Color(0xFF2FC1BE),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 14,
                          color: Color(0xFF2FC1BE),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];

                  return RoomSelectionCard(
                    imagePath: room['image'],
                    title: room['title'],
                    description: room['desc'],
                    size: room['size'],
                    bedType: room['bed'],
                    guests: room['guests'],
                    price: room['price'],
                    amenities: room['amenities'],
                    matchPercentage: room['match'],
                    quantity: room['quantity'],
                    onAdd: () {
                      setState(() {
                        rooms[index]['quantity'] =
                            (rooms[index]['quantity'] as int) + 1;
                      });
                    },
                    onRemove: () {
                      setState(() {
                        if (rooms[index]['quantity'] > 0) {
                          rooms[index]['quantity'] =
                              (rooms[index]['quantity'] as int) - 1;
                        }
                      });
                    },
                    onTap: () {
                      Get.to(() => const BookingSummaryScreen());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
