import 'package:get/get.dart';
import 'package:superapp/app_routes.dart';

class WelcomeController extends GetxController {
  void goToSignup() => Get.toNamed(AppRoutes.signUp);

  void goToLogin() => Get.toNamed(AppRoutes.signIn);
}
