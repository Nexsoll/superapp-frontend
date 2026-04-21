import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/security_setting_controller.dart';

import '../../main.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SecuritySettingsController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          color: kPrimaryColor,
          onPressed: () => Get.back(),
        ),
        title: Text('Security Settings'.tr,
          style: theme.textTheme.titleMedium?.copyWith(
            color: kPrimaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            color: theme.cardColor,
            child: Column(
              children: [
                Obx(
                  () => _settingRow(
                    enabled: true,
                    context: context,
                    title: 'Remember me',
                    value: controller.rememberMe.value,
                    onChanged: controller.rememberMeButton,
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.brightness == Brightness.dark ? Colors.white24 : const Color(0xFFE5E7EB),
                ),

                Obx(
                  () => _settingRow(
                    context: context,
                    enabled: true,
                    title: 'Face ID',
                    value: controller.faceId.value,
                    onChanged: controller.faceIdButton,
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.brightness == Brightness.dark ? Colors.white24 : const Color(0xFFE5E7EB),
                ),

                Obx(
                  () => _settingRow(
                    context: context,

                    title: 'Fingerprint',
                    value: controller.fingerprint.value,
                    onChanged: controller.fingerprintButton,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingRow({
    required BuildContext context,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 46,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: const Color(0xFF34C759),
            ),
          ],
        ),
      ),
    );
  }
}
