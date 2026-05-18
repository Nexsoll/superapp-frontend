import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/auth/wellcome_controller.dart';

class WellcomeScreen extends StatelessWidget {
  const WellcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WelcomeController());
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
                  horizontal: 52,
                  vertical: 42,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          'assets/wellcome.png',
                          height: 500,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 70),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 470),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                'Welcome'.tr,
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Have a better sharing experience'.tr,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.brightness == Brightness.dark
                                      ? const Color(0xFFDDE7EA)
                                      : const Color(0xFF3F4B55),
                                  fontWeight: FontWeight.w500,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 36),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: controller.goToSignup,
                                        child: Text('Create an account'.tr),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: SizedBox(
                                      height: 52,
                                      child: OutlinedButton(
                                        onPressed: controller.goToLogin,
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        child: Text('Log In'.tr),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: const [
                                  _WelcomePill(
                                    icon: Icons.hotel_outlined,
                                    label: 'Hotels',
                                  ),
                                  _WelcomePill(
                                    icon: Icons.home_work_outlined,
                                    label: 'Properties',
                                  ),
                                  _WelcomePill(
                                    icon: Icons.auto_awesome_outlined,
                                    label: 'AI + AR',
                                  ),
                                ],
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(vertical: 20),
          child: Column(
            children: [
              Spacer(flex: 1),

              SizedBox(
                height: 230,
                child: Center(
                  child: Image.asset(
                    'assets/wellcome.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      'Welcome'.tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Have a better sharing experience'.tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF353B4A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.goToSignup();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Create an account'.tr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          controller.goToLogin();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Log In'.tr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
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
      ),
    );
  }
}

class _WelcomePill extends StatelessWidget {
  const _WelcomePill({required this.icon, required this.label});

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
