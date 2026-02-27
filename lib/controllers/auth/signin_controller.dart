import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/screens/complete_profile_screen.dart';
import 'package:superapp/screens/main_screen.dart';
import 'package:superapp/screens/auth/otp_screen.dart';
import 'package:superapp/screens/auth/signup_screen.dart';
import 'package:superapp/services/auth_service.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  final _authService = AuthService();
  final _firebaseAuth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn.instance;

  void showPassword() => obscurePassword.value = !obscurePassword.value;

  void goToSignup() => Get.to(() => const SignupScreen());

  Future<void> signIn() async {
    isLoading.value = true;
    try {
      final result = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = (result['user'] as Map?) ?? {};
      final token = (result['access_token'] as String?) ?? '';

      final profile = Get.find<ProfileController>();
      await profile.saveUserData(
        id: user['id'] as int?,
        userToken: token,
        name: (user['fullName'] as String?) ?? '',
        userEmail: (user['email'] as String?) ?? '',
        userPhone: (user['phoneNumber'] as String?) ?? '',
        userPhotoUrl: (user['avatar'] as String?) ?? '',
        userFirstName: (user['firstName'] as String?) ?? '',
        userRole: (user['role'] as String?) ?? 'USER',
      );

      final isProfileComplete = (user['isProfileComplete'] as bool?) ?? false;
      if (!isProfileComplete) {
        Get.offAll(() => const CompleteProfileScreen(), arguments: result);
      } else {
        Get.offAll(() => const MainScreen());
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar('Error', 'Please enter your email first');
      return;
    }

    Get.to(
      () => const OtpScreen(),
      arguments: {'email': email, 'flow': 'forgot_password'},
    );
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      // Initialize GoogleSignIn with web client ID (required for server-side auth)
      await _googleSignIn.initialize(
        clientId:
            '634639795131-0uth2jlnhp540gn8ksvl6rfvtoblpofg.apps.googleusercontent.com',
      );
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = await googleUser.authentication;
      final googleIdToken = googleAuth.idToken;
      if (googleIdToken == null || googleIdToken.isEmpty) {
        throw Exception('Google sign-in failed (missing id token)');
      }
      final credential = GoogleAuthProvider.credential(idToken: googleIdToken);

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Google sign-in failed');
      }

      final idToken = await firebaseUser.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google sign-in failed (missing firebase id token)');
      }
      final result = await _authService.socialLogin(
        idToken: idToken,
        provider: 'google',
      );

      await _handleAuthResult(result);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    isLoading.value = true;
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      if (appleCredential.identityToken == null ||
          appleCredential.identityToken!.isEmpty) {
        throw Exception('Apple sign-in failed (missing identity token)');
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken!,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        oauthCredential,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Apple sign-in failed');
      }

      // Apple may not always return name/email on subsequent logins.
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty) {
          await firebaseUser.updateDisplayName(displayName);
        }
      }

      final idToken = await firebaseUser.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Apple sign-in failed (missing firebase id token)');
      }
      final result = await _authService.socialLogin(
        idToken: idToken,
        provider: 'apple',
      );

      await _handleAuthResult(result);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleAuthResult(Map<String, dynamic> result) async {
    final user = (result['user'] as Map?) ?? {};
    final token = (result['access_token'] as String?) ?? '';

    final profile = Get.find<ProfileController>();
    await profile.saveUserData(
      id: user['id'] as int?,
      userToken: token,
      name: (user['fullName'] as String?) ?? '',
      userEmail: (user['email'] as String?) ?? '',
      userPhone: (user['phoneNumber'] as String?) ?? '',
      userPhotoUrl: (user['avatar'] as String?) ?? '',
      userFirstName: (user['firstName'] as String?) ?? '',
      userRole: (user['role'] as String?) ?? 'USER',
    );

    final isProfileComplete = (user['isProfileComplete'] as bool?) ?? false;
    if (!isProfileComplete) {
      Get.offAll(() => const CompleteProfileScreen(), arguments: result);
    } else {
      Get.offAll(() => const MainScreen());
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
