import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArRoomTourScreen extends StatelessWidget {
  const ArRoomTourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/room1.png', // Using room1 as the background
              fit: BoxFit.cover,
            ),
          ),

          // Top Buttons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _translucentCircleButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Get.back(),
                      ),
                    ),
                    _arTourChip(),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Info Card
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: _infoCard(),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF9AA0AF).withOpacity(0.55),
            borderRadius: BorderRadius.circular(30),
          ),
          child: SizedBox(
            height: 180,
            child: Stack(
              children: [
                Positioned(
                  left: 8,
                  top: 6,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: const AssetImage('assets/room1.png'),
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 6,
                  child: _circleGlassButton(icon: Icons.refresh, onTap: () {}),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text('Standard Room'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 6,
                  child: _infoBubble('25m²'),
                ),
                Positioned(
                  right: 8,
                  bottom: 6,
                  child: _infoBubble('\$180'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoBubble(String text) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _circleGlassButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _arTourChip() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0x542FC1BE),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/ai.png',
                width: 18,
                height: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text('AR Room Tour'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _translucentCircleButton(
      {required IconData icon, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
