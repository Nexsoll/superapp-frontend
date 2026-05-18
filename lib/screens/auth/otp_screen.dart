import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:superapp/controllers/auth/otp_controller.dart';
import 'package:superapp/widgets/auth_desktop_shell.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OtpController());
    final theme = Theme.of(context);
    final isDesktopWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 900;
    const pinTextStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Color(0xFF101820),
    );
    final pinTheme = PinTheme(
      width: 54,
      height: 56,
      textStyle: pinTextStyle,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDE3EA)),
      ),
    );

    if (isDesktopWeb) {
      return AuthDesktopShell(
        logoAsset: 'assets/signup_logo.png',
        title: 'Enter OTP'.tr,
        subtitle: 'Please enter OTP sent to your registered email'.tr,
        heroTitle: 'Verify your IDS Europe account',
        heroSubtitle:
            'Use the six digit code from your email to continue securely.',
        leading: TextButton.icon(
          onPressed: controller.back,
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: Text('Back'.tr),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Pinput(
              length: 6,
              keyboardType: TextInputType.number,
              onChanged: controller.setOtp,
              onCompleted: controller.setOtp,
              mainAxisAlignment: MainAxisAlignment.start,
              defaultPinTheme: pinTheme,
              focusedPinTheme: pinTheme.copyWith(
                textStyle: pinTextStyle,
                decoration: pinTheme.decoration?.copyWith(
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              submittedPinTheme: pinTheme.copyWith(
                textStyle: pinTextStyle,
                decoration: pinTheme.decoration?.copyWith(
                  border: Border.all(color: theme.colorScheme.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.verify,
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Verify'.tr),
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
          padding: EdgeInsetsGeometry.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: TextButton(
                  onPressed: () => controller.back(),
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
                'Enter OTP'.tr,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Please enter OTP sent to your registered email'.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Pinput(
                    length: 6,
                    keyboardType: TextInputType.number,
                    onChanged: controller.setOtp,
                    onCompleted: controller.setOtp,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Add this

                    defaultPinTheme: PinTheme(
                      width: 50, // Increased width
                      height: 50,
                      textStyle: const TextStyle(
                        fontSize: 20, // Increased font size
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                    ),

                    focusedPinTheme: PinTheme(
                      width: 50, // Keep consistent
                      height: 50,
                      textStyle: pinTextStyle,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),

                    submittedPinTheme: PinTheme(
                      width: 50, // Keep consistent
                      height: 50,
                      textStyle: pinTextStyle,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.verify,
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
                            'Verify'.tr,
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
