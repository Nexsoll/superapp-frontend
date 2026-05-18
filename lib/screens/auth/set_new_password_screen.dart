import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/auth/set_new_password_controller.dart';
import 'package:superapp/widgets/auth_desktop_shell.dart';
import 'package:superapp/widgets/auth_text_form_field.dart';

class SetNewPasswordScreen extends StatelessWidget {
  const SetNewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SetNewPasswordController());
    final theme = Theme.of(context);
    final isDesktopWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 900;

    if (isDesktopWeb) {
      return AuthDesktopShell(
        logoAsset: 'assets/signin_logo.png',
        title: 'Set a new password'.tr,
        subtitle:
            'Create a password that is at least 6 characters and different from previous ones.'
                .tr,
        heroTitle: 'Secure your IDS Europe account',
        heroSubtitle:
            'Finish account recovery by choosing a strong password before returning to sign in.',
        leading: TextButton.icon(
          onPressed: controller.back,
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: Text('Back'.tr),
        ),
        children: [
          Obx(() {
            return AuthTextFormField(
              controller: controller.newPasswordController,
              hint: 'Enter your new password',
              prefixIcon: Icons.lock_outline,
              obscureText: controller.obscureNew.value,
              suffixIcon: controller.obscureNew.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixTap: controller.showNewPassword,
              textInputAction: TextInputAction.next,
            );
          }),
          const SizedBox(height: 14),
          Obx(() {
            return AuthTextFormField(
              controller: controller.confirmPasswordController,
              hint: 'Re-enter password',
              prefixIcon: Icons.lock_outline,
              obscureText: controller.obscureConfirm.value,
              suffixIcon: controller.obscureConfirm.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixTap: controller.showConfirmPassword,
              textInputAction: TextInputAction.done,
            );
          }),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.updatePassword,
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Update Password'.tr),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: TextButton(
                  onPressed: controller.back,
                  child: Text(
                    'Back'.tr,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Set a new password'.tr,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Create a new password. Ensure it differs from\nprevious ones for security'
                    .tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 20),

              Obx(() {
                return AuthTextFormField(
                  controller: controller.newPasswordController,
                  hint: 'Enter your new password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: controller.obscureNew.value,
                  suffixIcon: controller.obscureNew.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixTap: controller.showNewPassword,
                  textInputAction: TextInputAction.next,
                );
              }),

              const SizedBox(height: 15),

              Obx(() {
                return AuthTextFormField(
                  controller: controller.confirmPasswordController,
                  hint: 'Re-enter password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: controller.obscureConfirm.value,
                  suffixIcon: controller.obscureConfirm.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixTap: controller.showConfirmPassword,
                  textInputAction: TextInputAction.done,
                );
              }),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Update Password'.tr,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
