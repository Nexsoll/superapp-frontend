import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/auth/complete_profile_controller.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompleteProfileController());
    final theme = Theme.of(context);

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
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Text('Back'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 56),
              Text('Complete your Profile'.tr,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              Stack(
                children: [
                  Obx(() {
                    final url = controller.photoUrl.value;
                    final localPath = controller.localPhotoPath.value;
                    ImageProvider imageProvider;
                    if (localPath.isNotEmpty) {
                      imageProvider = FileImage(File(localPath));
                    } else if (url.isNotEmpty) {
                      imageProvider = NetworkImage(url);
                    } else {
                      imageProvider = const AssetImage('assets/avatar.png');
                    }
                    return CircleAvatar(
                      radius: 62,
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
              ),
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
                  hint: Text('Gender'.tr,
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
                  hint: Text('Currency'.tr,
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
                  hint: Text('Language'.tr,
                    style: theme.inputDecorationTheme.hintStyle,
                  ),
                  style: theme.textTheme.bodyLarge,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFFB6BAC5),
                  ),
                  items: [
                    DropdownMenuItem(value: 'English', child: Text('English'.tr)),
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
