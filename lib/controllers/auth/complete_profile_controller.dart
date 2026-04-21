import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/screens/choose_location_screen.dart';
import 'package:superapp/services/auth_service.dart';

class CompleteProfileController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();

  final gender = 'Male'.obs;
  final currency = 'USD'.obs;
  final language = 'English'.obs;

  final photoUrl = ''.obs;
  final localPhotoPath = ''.obs;
  final isLoading = false.obs;

  final _authService = AuthService();
  final _picker = ImagePicker();

  int _userId = 0;
  String _token = '';

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map) {
      // Handle both 'user' and 'result' keys (backend returns 'result' after OTP verification)
      final user = (args['user'] as Map?) ?? (args['result'] as Map?) ?? {};
      _token = (args['access_token'] as String?) ?? '';
      _userId = (user['id'] as int?) ?? 0;

      // Build full name from firstName and lastName if fullName is not available
      final firstName = (user['firstName'] as String?) ?? '';
      final lastName = (user['lastName'] as String?) ?? '';
      final fullName = (user['fullName'] as String?) ?? '';

      if (fullName.isNotEmpty) {
        fullNameController.text = fullName;
      } else if (firstName.isNotEmpty || lastName.isNotEmpty) {
        fullNameController.text = '$firstName $lastName'.trim();
      }

      emailController.text = (user['email'] as String?) ?? '';
      photoUrl.value = (user['avatar'] as String?) ?? '';

      final g = user['gender'];
      if (g is String && g.isNotEmpty) {
        if (g.toLowerCase() == 'female') gender.value = 'Female';
        if (g.toLowerCase() == 'other') gender.value = 'Other';
      }

      final c = user['currency'];
      if (c is String && c.isNotEmpty) currency.value = c;

      final l = user['lang'];
      if (l is String && l.isNotEmpty) {
        if (l.toUpperCase() == 'URDU') language.value = 'Urdu';
        if (l.toUpperCase() == 'ARABIC') language.value = 'Arabic';
      }
    }

    if (_userId == 0) {
      final profile = Get.find<ProfileController>();
      _userId = profile.userId;
      _token = profile.token;
      if (fullNameController.text.isEmpty) {
        fullNameController.text = profile.username.value;
      }
      if (emailController.text.isEmpty) {
        emailController.text = profile.email.value;
      }
      if (photoUrl.value.isEmpty) {
        photoUrl.value = profile.photoUrl.value;
      }
    }
  }

  void setGender(String? v) {
    if (v != null && v.isNotEmpty) gender.value = v;
  }

  void setCurrency(String? v) {
    if (v != null && v.isNotEmpty) currency.value = v;
  }

  void setLanguage(String? v) {
    if (v != null && v.isNotEmpty) language.value = v;
  }

  void changePicture() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Change Profile Picture'.tr,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.camera_alt_rounded,
                color: Get.theme.colorScheme.primary,
              ),
              title: Text('Take a Photo'.tr),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_rounded,
                color: Get.theme.colorScheme.primary,
              ),
              title: Text('Choose from Gallery'.tr),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
            if (photoUrl.value.isNotEmpty || localPhotoPath.value.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Colors.red),
                title: Text('Remove Photo'.tr,
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.back();
                  photoUrl.value = '';
                  localPhotoPath.value = '';
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked != null) {
        localPhotoPath.value = picked.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<String?> _uploadAvatarIfNeeded() async {
    if (localPhotoPath.value.isEmpty) {
      return photoUrl.value.isNotEmpty ? photoUrl.value : null;
    }

    try {
      final file = File(localPhotoPath.value);
      final result = await _authService.uploadAvatar(
        userId: _userId,
        imageFile: file,
      );
      print('Upload avatar result: $result');
      // The backend returns the user object directly with avatar field
      final avatarUrl = result['avatar'] as String?;
      print('Extracted avatar URL: $avatarUrl');
      return avatarUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      Get.snackbar('Error', 'Failed to upload avatar: $e');
      return null;
    }
  }

  Future<void> saveProfile() async {
    if (_userId == 0) {
      Get.snackbar('Error', 'Missing user session. Please sign in again.');
      return;
    }

    isLoading.value = true;
    try {
      // Upload avatar if a new image was selected
      final avatarUrl = await _uploadAvatarIfNeeded();

      final nameParts = fullNameController.text.trim().split(' ');
      final fName = nameParts.isNotEmpty ? nameParts.first : '';
      final lName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final updatedUser = await _authService.editUserProfile(
        userId: _userId,
        fullName: fullNameController.text.trim(),
        firstName: fName,
        lastName: lName,
        email: emailController.text.trim(),
        avatar: avatarUrl,
      );

      await _authService.updateProfile(
        userId: _userId,
        token: _token,
        fullName: fullNameController.text.trim(),
        gender: gender.value.toUpperCase(),
        currency: currency.value.toUpperCase(),
        language: language.value.toUpperCase(),
        isProfileComplete: true,
      );

      final profile = Get.find<ProfileController>();
      await profile.saveUserData(
        id: updatedUser['id'] as int?,
        userToken: _token,
        name: (updatedUser['fullName'] as String?) ?? fullNameController.text.trim(),
        userEmail: (updatedUser['email'] as String?) ?? emailController.text.trim(),
        userPhone: (updatedUser['phoneNumber'] as String?) ?? '',
        userPhotoUrl: (updatedUser['avatar'] as String?) ?? avatarUrl ?? '',
        userFirstName: (updatedUser['firstName'] as String?) ?? fName,
        currency: currency.value.toUpperCase(),
      );

      Get.offAll(() => const ChooseLocationScreen());
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
