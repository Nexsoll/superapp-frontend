import 'package:get/get.dart';
import 'package:superapp/app_routes.dart';
import 'package:superapp/controllers/auth/signin_controller.dart';

class NewPasswordSuccessController extends GetxController {
  void continueToLogin() {
    // Delete old SignInController if it exists, so a fresh one is created
    if (Get.isRegistered<SignInController>()) {
      Get.delete<SignInController>(force: true);
    }
    Get.offAllNamed(AppRoutes.signIn);
  }
}
