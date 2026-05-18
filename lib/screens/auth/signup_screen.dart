import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/auth/signup_controller.dart';
import 'package:superapp/widgets/auth_desktop_shell.dart';
import 'package:superapp/widgets/auth_social_button.dart';
import 'package:superapp/widgets/auth_text_form_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktopWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 900;

    if (isDesktopWeb) {
      return AuthDesktopShell(
        logoAsset: 'assets/signup_logo.png',
        title: 'Create your account'.tr,
        subtitle:
            'Start booking stays and managing properties from the web.'.tr,
        heroTitle: 'Build your travel and property workspace',
        heroSubtitle:
            'Create one account for hotel bookings, property listings, wallets, and owner tools.',
        children: [
          Row(
            children: [
              Expanded(
                child: AuthTextFormField(
                  controller: controller.firstNameController,
                  hint: 'First Name',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AuthTextFormField(
                  controller: controller.lastNameController,
                  hint: 'Last Name',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AuthTextFormField(
            controller: controller.emailController,
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          Obx(() {
            return AuthTextFormField(
              controller: controller.passwordController,
              hint: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              obscureText: controller.obscurePassword.value,
              suffixIcon: controller.obscurePassword.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixTap: controller.showPassword,
              textInputAction: TextInputAction.done,
            );
          }),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                return Checkbox(
                  value: controller.agreeTerms.value,
                  onChanged: controller.termsEvent,
                  activeColor: theme.colorScheme.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'I agree to the Terms of service and Privacy policy'.tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B7280),
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: controller.signUp,
              child: Text('Sign Up'.tr),
            ),
          ),
          const SizedBox(height: 18),
          AuthDivider(label: 'or'.tr),
          const SizedBox(height: 18),
          SocialButton(
            text: 'Sign up with Google',
            icon: 'assets/google.png',
            onTap: controller.signUpWithGoogle,
          ),
          const SizedBox(height: 12),
          SocialButton(
            text: 'Sign up with Apple',
            icon: 'assets/apple.png',
            onTap: controller.signUpWithApple,
          ),
        ],
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account?'.tr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton(
              onPressed: controller.goTosignIn,
              child: Text('Sign in'.tr),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 80),

              SizedBox(
                height: 150,
                child: Center(
                  child: Image.asset(
                    'assets/signup_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Create Your Account'.tr,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: AuthTextFormField(
                      controller: controller.firstNameController,
                      hint: 'First Name',
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AuthTextFormField(
                      controller: controller.lastNameController,
                      hint: 'Last Name',
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              AuthTextFormField(
                controller: controller.emailController,
                hint: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 10),

              Obx(() {
                return AuthTextFormField(
                  controller: controller.passwordController,
                  hint: 'Enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: controller.obscurePassword.value,
                  suffixIcon: controller.obscurePassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixTap: controller.showPassword,
                  textInputAction: TextInputAction.done,
                );
              }),

              const SizedBox(height: 6),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    return Checkbox(
                      //  alignment: Alignment.topLeft,
                      value: controller.agreeTerms.value,
                      onChanged: controller.termsEvent,
                      activeColor: theme.colorScheme.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: const VisualDensity(
                        horizontal: -3,
                        vertical: -3,
                      ),
                    );
                  }),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                            height: 1.3,
                            fontSize: 11.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'By signing up, you agree to the ',
                            ),
                            TextSpan(
                              text: 'Terms of service',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy policy',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Sign Up'.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFF6B7280))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'or'.tr,
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFF6B7280))),
                ],
              ),

              const SizedBox(height: 12),

              SocialButton(
                text: 'Sign up with Google',
                icon: 'assets/google.png',
                onTap: controller.signUpWithGoogle,
              ),
              const SizedBox(height: 10),
              SocialButton(
                text: 'Sign up with Apple',
                icon: 'assets/apple.png',
                onTap: controller.signUpWithApple,
              ),

              const SizedBox(height: 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?'.tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: controller.goTosignIn,
                    child: Text(
                      'Sign in'.tr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
