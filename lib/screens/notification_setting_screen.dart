import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/notification_setting_controller.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsSettingsController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: controller.back,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('Notifications'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [
                  _SectionTitle('MESSAGE NOTIFICATIONS'),
                  SizedBox(height: 10),
                  _Card(
                    child: Column(
                      children: [
                        Obx(
                          () => _SwitchRow(
                            title: 'Show Notifications',
                            value: controller.messageShow.value,
                            onChanged: (v) => controller.messageShow.value = v,
                          ),
                        ),
                        const _Divider(),
                        Obx(
                          () => _NavRow(
                            title: 'Sound',
                            trailingText: controller.messageSound.value,
                            onTap: controller.openMessageSoundPicker,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  _SectionTitle('GROUP NOTIFICATIONS'),
                  SizedBox(height: 10),
                  _Card(
                    child: Column(
                      children: [
                        Obx(
                          () => _SwitchRow(
                            title: 'Show Notifications',
                            value: controller.groupShow.value,
                            onChanged: (v) => controller.groupShow.value = v,
                          ),
                        ),
                        const _Divider(),
                        Obx(
                          () => _NavRow(
                            title: 'Sound',
                            trailingText: controller.groupSound.value,
                            onTap: controller.openGroupSoundPicker,
                          ),
                        ),
                        const _Divider(),
                        Obx(
                          () => _SwitchRow(
                            title: 'Reaction Notifications',
                            value: controller.reaction.value,
                            onChanged: (v) => controller.reaction.value = v,
                          ),
                        ),
                        const _Divider(),
                        Obx(
                          () => _SwitchRow(
                            title: 'Special Offers',
                            value: controller.specialOffers.value,
                            onChanged: (v) =>
                                controller.specialOffers.value = v,
                          ),
                        ),
                        const _Divider(),
                        Obx(
                          () => _SwitchRow(
                            title: 'Payments',
                            value: controller.payments.value,
                            onChanged: (v) => controller.payments.value = v,
                          ),
                        ),
                        const _Divider(),

                        Obx(
                          () => _SwitchRow(
                            title: 'Cashback',
                            value: controller.cashback.value,
                            onChanged: null,
                            enabled: false,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(height: 10),
                  _Card(
                    child: _NavRow(
                      title: 'In-App Notifications',
                      subTitle: 'Banners, Sounds, Vibrate',

                      onTap: controller.openInAppNotifications,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _SectionTitle(''),
                  _Card(
                    child: Column(
                      children: [
                        Obx(
                          () => _SwitchRow(
                            title: 'Show Preview',

                            value: controller.showPreview.value,
                            onChanged: (v) => controller.showPreview.value = v,
                            dense: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                    child: Text('Preview message text inside new message notifications.'.tr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          // horizontal: 20,
                          vertical: 10,
                        ),
                        child: Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: TextButton(
                            onPressed: () {},
                            child: Text('Reset Notification Settings'.tr,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFFEF4444),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return SizedBox(height: 0);

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: const Color(0xFF9AA0AF),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      height: 1,
      thickness: 1,
      color: Get.isDarkMode ? Colors.white24 : const Color(0xFFF2F2F2),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
    this.dense = true,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? subtitle;
  final bool enabled;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(12, dense ? 6 : 10, 12, dense ? 6 : 10),
      child: Row(
        children: [
          Expanded(
            child: subtitle == null
                ? Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: enabled
                          ? (Get.isDarkMode ? Colors.white : const Color(0xFF1D2330))
                          : const Color(0xFF9AA0AF),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: enabled
                              ? (Get.isDarkMode ? Colors.white : const Color(0xFF1D2330))
                              : const Color(0xFF9AA0AF),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF9AA0AF),
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: Color(0xFF34C759),
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.title,
    required this.onTap,
    this.trailingText,
    this.subTitle,
  });

  final String title;
  final String? subTitle;
  final String? trailingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Get.isDarkMode ? Colors.white : const Color(0xFF1D2330),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),

                  if (subTitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subTitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF9AA0AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF9AA0AF),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
            ],

            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA0AF)),
          ],
        ),
      ),
    );
  }
}
