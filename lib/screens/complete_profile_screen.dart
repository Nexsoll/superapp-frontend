import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/app_routes.dart';
import 'package:superapp/controllers/auth/complete_profile_controller.dart';
import 'package:superapp/widgets/auth_desktop_shell.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  void _goBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
      return;
    }

    Get.offAllNamed(AppRoutes.signIn);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompleteProfileController());
    final theme = Theme.of(context);
    final isDesktopWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 900;

    if (isDesktopWeb) {
      return AuthDesktopShell(
        logoAsset: 'assets/wellcome.png',
        title: 'Complete your profile'.tr,
        subtitle:
            'Add the essentials so bookings, payments, and owner tools use the right details.'
                .tr,
        heroTitle: 'Personalize your IDS Europe workspace',
        heroSubtitle:
            'Your profile keeps bookings, currency preferences, language, and account recovery aligned.',
        leading: Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text('Back'.tr),
          ),
        ),
        children: [
          Center(child: _ProfileAvatar(controller: controller, radius: 58)),
          const SizedBox(height: 26),
          TextFormField(
            controller: controller.fullNameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Full Name'.tr,
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Email'.tr,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.gender.value,
                    decoration: InputDecoration(hintText: 'Gender'.tr),
                    items: [
                      DropdownMenuItem(value: 'Male', child: Text('Male'.tr)),
                      DropdownMenuItem(
                        value: 'Female',
                        child: Text('Female'.tr),
                      ),
                      DropdownMenuItem(value: 'Other', child: Text('Other'.tr)),
                    ],
                    onChanged: controller.setGender,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.currency.value,
                    decoration: InputDecoration(hintText: 'Currency'.tr),
                    items: [
                      DropdownMenuItem(value: 'USD', child: Text('USD'.tr)),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR'.tr)),
                      DropdownMenuItem(value: 'PKR', child: Text('PKR'.tr)),
                    ],
                    onChanged: controller.setCurrency,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.language.value,
              decoration: InputDecoration(hintText: 'Language'.tr),
              items: [
                DropdownMenuItem(value: 'English', child: Text('English'.tr)),
                DropdownMenuItem(value: 'Urdu', child: Text('Urdu'.tr)),
                DropdownMenuItem(value: 'Arabic', child: Text('Arabic'.tr)),
              ],
              onChanged: controller.setLanguage,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.saveProfile,
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Continue'.tr),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: _goBack,
                  child: Text(
                    'Back'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 56),
              Text(
                'Complete your Profile'.tr,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              _ProfileAvatar(controller: controller, radius: 62),
              const SizedBox(height: 34),
              TextFormField(
                controller: controller.fullNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(hintText: 'Full Name'.tr),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(hintText: 'Email'.tr),
                readOnly:
                    true, // Email usually read-only if it came from registration
              ),
              const SizedBox(height: 14),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.gender.value,
                  decoration: const InputDecoration(),
                  hint: Text(
                    'Gender'.tr,
                    style: theme.inputDecorationTheme.hintStyle,
                  ),
                  style: theme.textTheme.bodyLarge,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFFB6BAC5),
                  ),
                  items: [
                    DropdownMenuItem(value: 'Male', child: Text('Male'.tr)),
                    DropdownMenuItem(value: 'Female', child: Text('Female'.tr)),
                    DropdownMenuItem(value: 'Other', child: Text('Other'.tr)),
                  ],
                  onChanged: controller.setGender,
                ),
              ),
              const SizedBox(height: 14),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.currency.value,
                  decoration: const InputDecoration(),
                  hint: Text(
                    'Currency'.tr,
                    style: theme.inputDecorationTheme.hintStyle,
                  ),
                  style: theme.textTheme.bodyLarge,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFFB6BAC5),
                  ),
                  items: [
                    DropdownMenuItem(value: 'USD', child: Text('USD'.tr)),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR'.tr)),
                    DropdownMenuItem(value: 'PKR', child: Text('PKR'.tr)),
                  ],
                  onChanged: controller.setCurrency,
                ),
              ),
              const SizedBox(height: 14),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.language.value,
                  decoration: const InputDecoration(),
                  hint: Text(
                    'Language'.tr,
                    style: theme.inputDecorationTheme.hintStyle,
                  ),
                  style: theme.textTheme.bodyLarge,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFFB6BAC5),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'English',
                      child: Text('English'.tr),
                    ),
                    DropdownMenuItem(value: 'Urdu', child: Text('Urdu'.tr)),
                    DropdownMenuItem(value: 'Arabic', child: Text('Arabic'.tr)),
                  ],
                  onChanged: controller.setLanguage,
                ),
              ),
              const SizedBox(height: 34),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.saveProfile,
                  child: Text('Continue'.tr),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.controller, required this.radius});

  final CompleteProfileController controller;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Obx(() {
          final url = controller.photoUrl.value;
          final localPath = controller.localPhotoPath.value;
          ImageProvider imageProvider;
          if (localPath.isNotEmpty) {
            imageProvider = kIsWeb
                ? NetworkImage(localPath)
                : FileImage(File(localPath)) as ImageProvider;
          } else if (url.isNotEmpty) {
            imageProvider = NetworkImage(url);
          } else {
            imageProvider = const AssetImage('assets/avatar.png');
          }
          return CircleAvatar(
            radius: radius,
            backgroundColor: const Color(0xFFD3D3D3),
            backgroundImage: imageProvider,
          );
        }),
        Positioned(
          right: 6,
          bottom: 6,
          child: Material(
            color: theme.colorScheme.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: controller.changePicture,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
