import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/services/auth_service.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Assuming ProfileController is already initialized in memory.
    final ProfileController profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 100,
              color: theme.colorScheme.primary,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.chevron_left, size: 30),
                    color: Colors.white,
                  ),
                  Text(
                    'Preferences'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Currency'.tr,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your preferred currency for the app.'.tr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white24
                              : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Column(
                        children: ['USD', 'EUR', 'PKR'].map((currency) {
                          return Obx(
                            () => RadioListTile<String>(
                              title: Text(currency.tr),
                              value: currency,
                              groupValue: profileController.userCurrency.value,
                              activeColor: theme.colorScheme.primary,
                              onChanged: (value) async {
                                if (value != null) {
                                  profileController.userCurrency.value = value;
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('user_currency', value);

                                  try {
                                    if (profileController.userId != 0 &&
                                        profileController.token.isNotEmpty) {
                                      await AuthService().updateProfile(
                                        userId: profileController.userId,
                                        token: profileController.token,
                                        currency: value,
                                      );
                                    }
                                  } catch (e) {
                                    debugPrint('Error saving currency: $e');
                                  }

                                  Get.snackbar(
                                      'Success'.tr, 'Currency updated to '.tr + value);
                                  Get.forceAppUpdate();
                                }
                              },
                            ),
                          );
                        }).toList(),
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
