import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/permissions_controller.dart';

class PermissionsFlowScreen extends StatelessWidget {
  const PermissionsFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.put(PermissionsController());

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.steps.length,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  final step = controller.steps[index];

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.45),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 34,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 6),
                            Image.asset(
                              step.assetPath,
                              width: 170,
                              height: 170,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              step.title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF353B4A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              step.description,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF9AA0AF),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: 240,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: controller.onPrimaryPressed,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    step.primaryButtonText,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: controller.onSkipPressed,
                              child: Text('Skip for now'.tr,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFFB6BAC5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
