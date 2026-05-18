import 'package:get/get.dart';
import 'package:superapp/screens/auth/forgot_password_screen.dart';
import 'package:superapp/screens/auth/new_password_success_screen.dart';
import 'package:superapp/screens/auth/otp_screen.dart';
import 'package:superapp/screens/auth/set_new_password_screen.dart';
import 'package:superapp/screens/auth/signin_screen.dart';
import 'package:superapp/screens/auth/signup_screen.dart';
import 'package:superapp/screens/auth/wellcome_screen.dart';
import 'package:superapp/screens/main_screen.dart';
import 'package:superapp/screens/on_boarding_screen.dart';
import 'package:superapp/screens/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const welcome = '/welcome';
  static const signIn = '/signin';
  static const signUp = '/signup';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';
  static const setNewPassword = '/set-new-password';
  static const passwordResetSuccess = '/password-reset-success';
  static const main = '/home';

  static final pages = <GetPage<dynamic>>[
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: welcome, page: () => const WellcomeScreen()),
    GetPage(name: signIn, page: () => const SignInScreen()),
    GetPage(name: signUp, page: () => const SignupScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: otp, page: () => const OtpScreen()),
    GetPage(name: setNewPassword, page: () => const SetNewPasswordScreen()),
    GetPage(
      name: passwordResetSuccess,
      page: () => const NewPasswordSuccessScreen(),
    ),
    GetPage(name: main, page: () => const MainScreen()),
  ];
}
