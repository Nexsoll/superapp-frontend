import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superapp/screens/admin/admin_dashboard_screen.dart';
import 'package:superapp/screens/staff/staff_dashboard_screen.dart';
import 'package:superapp/screens/bottomNavScreen/edit_profile_screen.dart';
import 'package:superapp/screens/my_wallet_screen.dart';
import 'package:superapp/screens/notification_setting_screen.dart';
import 'package:superapp/screens/photo_detail_screen.dart';
import 'package:superapp/screens/security_setting_screen.dart';
import 'package:superapp/screens/auth/wellcome_screen.dart';
import 'package:superapp/services/auth_service.dart';
import 'package:superapp/services/listing_service.dart';
import 'package:superapp/screens/bottomNavScreen/preferences_screen.dart';

class ProfileController extends GetxController {
  final bookings = 12.obs;
  final reviews = 8.obs;
  final points = 100.obs;

  final username = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final photoUrl = ''.obs;
  final firstName = ''.obs;
  final userCurrency = 'USD'.obs;
  final role = 'USER'.obs;
  final balance = 0.0.obs;

  // Auth data
  int userId = 0;
  String token = '';

  static const _themeKey = 'is_dark_mode';
  static const _usernameKey = 'user_username';
  static const _emailKey = 'user_email';
  static const _phoneKey = 'user_phone';
  static const _photoUrlKey = 'user_photo_url';
  static const _firstNameKey = 'user_first_name';
  static const _userIdKey = 'user_id';
  static const _tokenKey = 'user_token';
  static const _currencyKey = 'user_currency';
  static const _roleKey = 'user_role';
  static const _balanceKey = 'user_balance';
  static const _locationKey = 'user_location';

  final isDark = true.obs;
  final selectedLocation = 'Montenegro'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
    _loadUserData().then((_) => getProfile());
  }

  String _normalizeAvatarUrl(String rawUrl) {
    if (rawUrl.trim().isEmpty) return '';
    if (rawUrl.startsWith('https://storage.googleapis.com/')) {
      return ListingService.avatarImageUrl(rawUrl);
    }
    return rawUrl;
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    username.value = prefs.getString(_usernameKey) ?? '';
    email.value = prefs.getString(_emailKey) ?? '';
    phone.value = prefs.getString(_phoneKey) ?? '';
    firstName.value = prefs.getString(_firstNameKey) ?? '';
    userCurrency.value = prefs.getString(_currencyKey) ?? 'USD';
    role.value = prefs.getString(_roleKey) ?? 'USER';
    balance.value = prefs.getDouble(_balanceKey) ?? 0.0;
    userId = prefs.getInt(_userIdKey) ?? 0;
    token = prefs.getString(_tokenKey) ?? '';
    selectedLocation.value = prefs.getString(_locationKey) ?? 'Montenegro';

    final savedPhoto = prefs.getString(_photoUrlKey) ?? '';
    photoUrl.value = _normalizeAvatarUrl(savedPhoto);

    await _syncFcmToken();
  }

  Future<void> getProfile() async {
    if (token.isEmpty) return;
    try {
      final data = await AuthService().getMe(token: token);
      
      // Update observables
      firstName.value = data['firstName'] ?? '';
      username.value = data['fullName'] ?? (data['username'] ?? '');
      email.value = data['email'] ?? '';
      photoUrl.value = _normalizeAvatarUrl(data['avatar'] ?? '');
      balance.value = double.tryParse(data['balance']?.toString() ?? '') ?? 0.0;
      role.value = data['role'] ?? 'USER';
      userCurrency.value = data['currency'] ?? 'USD';

      // Save to prefs
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_firstNameKey, firstName.value);
      await prefs.setString(_usernameKey, username.value);
      await prefs.setString(_emailKey, email.value);
      await prefs.setString(_photoUrlKey, data['avatar'] ?? '');
      await prefs.setDouble(_balanceKey, balance.value);
      await prefs.setString(_roleKey, role.value);
      await prefs.setString(_currencyKey, userCurrency.value);
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> _syncFcmToken() async {
    if (token.trim().isEmpty) return;

    try {
      await FirebaseMessaging.instance.requestPermission();
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.trim().isEmpty) return;

      final service = AuthService();
      await service.updateMyFcmToken(token: token, fcmToken: fcmToken);
    } catch (_) {
    }
  }

  Future<void> saveUserData({
    String? name,
    String? userEmail,
    String? userPhone,
    String? userPhotoUrl,
    String? userFirstName,
    String? currency,
    String? userRole,
    int? id,
    String? userToken,
    double? userBalance,
    String? location,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (location != null) {
      selectedLocation.value = location;
      await prefs.setString(_locationKey, location);
    }
    if (name != null) {
      username.value = name;
      await prefs.setString(_usernameKey, name);
    }
    if (userEmail != null) {
      email.value = userEmail;
      await prefs.setString(_emailKey, userEmail);
    }
    if (userPhone != null) {
      phone.value = userPhone;
      await prefs.setString(_phoneKey, userPhone);
    }
    if (userPhotoUrl != null) {
      final normalized = _normalizeAvatarUrl(userPhotoUrl);
      photoUrl.value = normalized;
      await prefs.setString(_photoUrlKey, userPhotoUrl);
    }
    if (userFirstName != null) {
      firstName.value = userFirstName;
      await prefs.setString(_firstNameKey, userFirstName);
    }
    if (currency != null) {
      userCurrency.value = currency;
      await prefs.setString(_currencyKey, currency);
    }
    if (userRole != null) {
      role.value = userRole;
      await prefs.setString(_roleKey, userRole);
    }
    if (userBalance != null) {
      balance.value = userBalance;
      await prefs.setDouble(_balanceKey, userBalance);
    }
    if (id != null) {
      userId = id;
      await prefs.setInt(_userIdKey, id);
    }
    if (userToken != null) {
      token = userToken;
      await prefs.setString(_tokenKey, userToken);
    }
  }

  String get displayName {
    if (firstName.value.isNotEmpty) return firstName.value;
    if (username.value.isNotEmpty) return username.value;
    return 'User';
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_themeKey);

    isDark.value = saved ?? true;
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);

    if (saved == null) {
      await prefs.setBool(_themeKey, isDark.value);
    }
  }

  Future<void> toggleTheme(bool value) async {
    isDark.value = value;
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark.value);
  }

  void back() => Get.back();

  Future<void> onEditProfile() async {
    await Get.to(() => const EditProfileScreen());
  }

  void onIdentity() => Get.snackbar('Support', 'Community');
  Future<void> onPreferences() async {
    Get.to(() => const PreferencesScreen());
  }

  void onMyWallet() => Get.to(() => MyWalletScreen());
  void onPaymentMethods() => Get.to(PhotoDetailsScreen());

  void onNotifications() => Get.to(() => const NotificationsSettingsScreen());
  void onSecurity() => Get.to(() => const SecuritySettingsScreen());

  void onTermPolicy() => Get.snackbar('Support', 'Term & Policy');
  void onHelpCenter() => Get.snackbar('Support', 'Help Center');

  Future<void> onLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    username.value = '';
    email.value = '';
    phone.value = '';
    photoUrl.value = '';
    firstName.value = '';
    userCurrency.value = 'USD';
    role.value = 'USER';
    balance.value = 0.0;
    userId = 0;
    token = '';

    Get.offAll(() => const WellcomeScreen());
  }

  void onAdminDashboard() => Get.to(() => const AdminDashboardScreen());
  void onStaffDashboard() => Get.to(() => const StaffDashboardScreen());
}
