import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/app_routes.dart';
import 'package:superapp/screens/auth/new_password_success_screen.dart';
import 'package:superapp/services/auth_service.dart';

class SetNewPasswordController extends GetxController {
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;
  final isLoading = false.obs;

  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String email = '';
  String otp = '';
  final _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map? ?? {};
    email = args['email'] ?? '';
    otp = args['otp'] ?? '';
  }

  void back() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
      return;
    }

    Get.offAllNamed(AppRoutes.forgotPassword);
  }

  void showNewPassword() => obscureNew.value = !obscureNew.value;
  void showConfirmPassword() => obscureConfirm.value = !obscureConfirm.value;

  Future<void> updatePassword() async {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Error', 'Please fill in both fields');
      return;
    }

    if (newPassword.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      await _authService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      Get.off(() => const NewPasswordSuccessScreen());
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
