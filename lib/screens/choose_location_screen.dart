import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/screens/main_screen.dart';

class ChooseLocationScreen extends StatelessWidget {
  const ChooseLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    final theme = Theme.of(context);
    final isDesktopWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 900;

    final locations = [
      {'name': 'Montenegro', 'image': 'assets/locations/montenegro.png'},
      {'name': 'Serbia', 'image': 'assets/locations/serbia.png'},
      {'name': 'Bosnia', 'image': 'assets/locations/bosnia.png'},
      {'name': 'Croatia', 'image': 'assets/locations/croatia.png'},
      {'name': 'Albania', 'image': 'assets/locations/albania.png'},
      {'name': 'Slovenia', 'image': 'assets/locations/slovenia.png'},
    ];

    if (isDesktopWeb) {
      return Scaffold(
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFF0B1014)
            : const Color(0xFFF5FAFA),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 42,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 54),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.apartment_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 34,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'IDS EUROPE',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              width: 64,
                              height: 4,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'Choose your location'.tr,
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF101820),
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Select a location to see the most relevant recommendations for you.'
                                  .tr,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFFB7C1CC)
                                    : const Color(0xFF617080),
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 34),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: const [
                                _LocationPill(
                                  icon: Icons.hotel_outlined,
                                  label: 'Hotels',
                                ),
                                _LocationPill(
                                  icon: Icons.home_work_outlined,
                                  label: 'Properties',
                                ),
                                _LocationPill(
                                  icon: Icons.explore_outlined,
                                  label: 'Recommendations',
                                ),
                              ],
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                      childAspectRatio: 1.28,
                                    ),
                                itemCount: locations.length,
                                itemBuilder: (context, index) {
                                  final loc = locations[index];
                                  return Obx(() {
                                    final isSelected =
                                        profileController
                                            .selectedLocation
                                            .value ==
                                        loc['name'];
                                    return InkWell(
                                      onTap: () {
                                        profileController.saveUserData(
                                          location: loc['name'],
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                                    .withValues(alpha: 0.14)
                                              : theme.colorScheme.surface
                                                    .withValues(alpha: 0.54),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.primary
                                                      .withValues(alpha: 0.18),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CircleAvatar(
                                              radius: 19,
                                              backgroundColor: theme
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.14),
                                              child: Text(
                                                loc['name']![0],
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    loc['name']!,
                                                    style: theme
                                                        .textTheme
                                                        .titleSmall
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: isSelected
                                                              ? theme
                                                                    .colorScheme
                                                                    .primary
                                                              : null,
                                                        ),
                                                  ),
                                                ),
                                                if (isSelected)
                                                  Icon(
                                                    Icons.check_circle_rounded,
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                    size: 20,
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                                },
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.offAll(() => const MainScreen());
                                  },
                                  child: Text('Continue'.tr),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Choose your location'.tr,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Select a location to see the most relevant recommendations for you.'
                    .tr,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final loc = locations[index];
                  return Obx(() {
                    final isSelected =
                        profileController.selectedLocation.value == loc['name'];
                    return InkWell(
                      onTap: () {
                        profileController.saveUserData(location: loc['name']);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  loc['name']![0],
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              loc['name']!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => const MainScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text('Continue'.tr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPill extends StatelessWidget {
  const _LocationPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              label.tr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
