import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/on_boarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    final theme = Theme.of(context);
    final isDesktopWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 900;

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
                  vertical: 36,
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.skip,
                        child: Text('Skip'.tr),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: controller.pageController,
                              onPageChanged: controller.onPageChanged,
                              itemCount: controller.item.length,
                              itemBuilder: (_, i) {
                                final item = controller.item[i];

                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Image.asset(
                                    item.image,
                                    height: 460,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 72),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 460,
                                ),
                                child: Obx(() {
                                  final item = controller
                                      .item[controller.currentIndex.value];

                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      Text(
                                        item.title.tr,
                                        style: theme.textTheme.displaySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w900,
                                              height: 1.05,
                                            ),
                                      ),
                                      const SizedBox(height: 18),
                                      Text(
                                        item.subtitle.tr,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color:
                                                  theme.brightness ==
                                                      Brightness.dark
                                                  ? const Color(0xFFDDE7EA)
                                                  : const Color(0xFF3F4B55),
                                              height: 1.45,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 38),
                                      Row(
                                        children: List.generate(
                                          controller.item.length,
                                          (i) {
                                            final active =
                                                controller.currentIndex.value ==
                                                i;
                                            return AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 220,
                                              ),
                                              margin: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              width: active ? 36 : 9,
                                              height: 9,
                                              decoration: BoxDecoration(
                                                color: active
                                                    ? theme.colorScheme.primary
                                                    : theme.colorScheme.primary
                                                          .withValues(
                                                            alpha: 0.24,
                                                          ),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 38),
                                      SizedBox(
                                        width: 220,
                                        height: 52,
                                        child: ElevatedButton(
                                          onPressed: controller.next,
                                          child: Text(
                                            controller.currentIndex.value ==
                                                    controller.item.length - 1
                                                ? 'Get Started'.tr
                                                : 'Next'.tr,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: controller.skip,
                  child: Text(
                    'Skip'.tr,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 100),

            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.item.length,
                itemBuilder: (_, i) {
                  final item = controller.item[i];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Image.asset(item.image, height: 250),
                        ),
                      ),

                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 25,
                        ),
                      ),

                      const SizedBox(height: 4),

                      SizedBox(
                        width: 270,
                        child: Text(
                          item.subtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : const Color(0xFF353B4A),
                            fontWeight: FontWeight.w500,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(controller.item.length, (i) {
                  final active = controller.currentIndex.value == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              );
            }),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.all(40),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Obx(() {
                    final isLast =
                        controller.currentIndex.value ==
                        controller.item.length - 1;
                    return Text(
                      isLast ? 'Get Started' : 'Next',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
