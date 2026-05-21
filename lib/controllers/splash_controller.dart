import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superapp/app_routes.dart';

class SplashController extends GetxController {
  static const _onboardingDoneKey = 'onboarding_done';
  static const _userIdKey = 'user_id';

  @override
  void onInit() {
    super.onInit();
    _nextScreen();
  }

  Future<void> _nextScreen() async {
    await Future.delayed(const Duration(seconds: 4));

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(_onboardingDoneKey) ?? false;
    final userId = prefs.getInt(_userIdKey) ?? 0;

    if (kIsWeb) {
      if (userId > 0) {
        Get.offAllNamed(AppRoutes.main);
      } else {
        Get.offAllNamed(AppRoutes.landing);
      }
      return;
    }

    if (!onboardingDone) {
      // First launch — show onboarding, then mark as done
      await prefs.setBool(_onboardingDoneKey, true);
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (userId > 0) {
      // User is signed in
      Get.offAllNamed(AppRoutes.main);
    } else {
      // User is logged out
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
}
