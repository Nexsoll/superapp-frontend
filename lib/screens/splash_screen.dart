import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SplashController>()) {
      Get.put(SplashController(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Image.asset('assets/logo.gif', fit: BoxFit.contain),
        ),
      ),
    );
  }
}
