import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/main_screen_controller.dart';
import '../widgets/main_bottom_bar.dart';
import 'bottomNavScreen/home_screen.dart';
import 'bottomNavScreen/explore_screen.dart';
import 'bottomNavScreen/booking_screen.dart';
import 'bottomNavScreen/profile_screen.dart';
import 'bottomNavScreen/chat_screen.dart';
import 'bottomNavScreen/ai_assistant_screen.dart';
import 'bottomNavScreen/dashboard_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.put(MainScreenController(), permanent: true);
    final isDesktopWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 900;

    Widget currentPage(bool isProperty) {
      switch (controller.bottomIndex.value) {
        case 0:
          return const HomeScreen();
        case 1:
          return const ExploreScreen();
        case 2:
          return isProperty ? const DashboardScreen() : const BookingScreen();
        case 3:
          return isProperty ? const ChatScreen() : AiAssistantScreen();
        case 4:
          return const ProfileScreen();
        default:
          return const HomeScreen();
      }
    }

    if (isDesktopWeb) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Row(
            children: [
              Obx(() {
                final isProperty = controller.categoryIndex.value == 1;
                return _DesktopSidebar(
                  currentIndex: controller.bottomIndex.value,
                  isPropertySelected: isProperty,
                  onTap: controller.onBottomNavTap,
                );
              }),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: Border(
                      left: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                  child: Obx(() {
                    final isProperty = controller.categoryIndex.value == 1;
                    return currentPage(isProperty);
                  }),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() {
        final isProperty = controller.categoryIndex.value == 1;
        return currentPage(isProperty);
      }),
      bottomNavigationBar: Obx(
        () => MainBottomBar(
          currentIndex: controller.bottomIndex.value,
          onTap: controller.onBottomNavTap,
          isPropertySelected: controller.categoryIndex.value == 1,
        ),
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.currentIndex,
    required this.isPropertySelected,
    required this.onTap,
  });

  final int currentIndex;
  final bool isPropertySelected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <({String label, IconData icon})>[
      (label: 'Home', icon: Icons.home_rounded),
      (label: 'Explore', icon: Icons.explore_rounded),
      if (isPropertySelected) ...[
        (label: 'Dashboard', icon: Icons.dashboard_rounded),
        (label: 'Messages', icon: Icons.chat_bubble_rounded),
      ] else ...[
        (label: 'Bookings', icon: Icons.calendar_month_rounded),
        (label: 'AI', icon: Icons.auto_awesome_rounded),
      ],
      (label: 'Profile', icon: Icons.person_rounded),
    ];

    return SizedBox(
      width: 260,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.apartment_rounded,
                  color: theme.colorScheme.primary,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  'IDS EUROPE',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            ...List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == currentIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primary.withValues(alpha: 0.13)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.iconTheme.color?.withValues(alpha: 0.68),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item.label.tr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodyMedium?.color?.withValues(
                                    alpha: 0.78,
                                  ),
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Balkan stays and properties'.tr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
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
