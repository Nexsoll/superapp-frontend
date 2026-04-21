import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: IconButton(
                      onPressed: () => controller.back(),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 28,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),

                  Text('Notification'.tr,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/notification_empty.png',
                      height: 220,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 18),

                    Text('Empty'.tr,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text("You don't have any notifications at this time".tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 130),
          ],
        ),
      ),
    );
  }
}
