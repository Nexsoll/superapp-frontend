import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/edit_profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 150,
              color: theme.colorScheme.primary,
              child: Row(
                children: [
                  IconButton(
                    onPressed: controller.back,
                    icon: const Icon(Icons.chevron_left, size: 30),
                    color: Colors.white,
                  ),
                  Text('Edit Profile'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 35,
                        vertical: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 18),

                          Center(
                            child: TextButton(
                              onPressed: controller.changePicture,
                              child: Text('Change Picture'.tr,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF9AA0AF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          _label(theme, 'Full Name'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: controller.usernameCtrl,
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 20),

                          _label(theme, 'Email'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: controller.emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 20),

                          _label(theme, 'Phone Number'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: controller.phoneCtrl,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                          ),

                          const SizedBox(height: 35),

                          SizedBox(
                            height: 44,
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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
                                    : Text('Update'.tr,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Avatar overlap
                    Positioned(
                      top: -46,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: controller.changePicture,
                          child: Obx(() {
                            final localPath = controller.localPhotoPath.value;
                            final url = controller.photoUrl.value;

                            ImageProvider imageProvider;
                            if (localPath.isNotEmpty) {
                              imageProvider = FileImage(File(localPath));
                            } else if (url.isNotEmpty) {
                              imageProvider = NetworkImage(url);
                            } else {
                              imageProvider = const AssetImage(
                                'assets/avatar.png',
                              );
                            }

                            return Stack(
                              children: [
                                Container(
                                  width: 92,
                                  height: 92,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: imageProvider,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 14,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF1D2330),
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
