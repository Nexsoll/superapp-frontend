import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/services/api_service.dart';

class StaffMember {
  final int staffId;
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatar;
  final String? propertyTitle;
  final String? hotelTitle;

  const StaffMember({
    required this.staffId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
    this.propertyTitle,
    this.hotelTitle,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final property = json['property'] as Map<String, dynamic>?;
    final hotel = json['hotel'] as Map<String, dynamic>?;
    return StaffMember(
      staffId: (json['id'] as num).toInt(),
      userId: (user['id'] as num?)?.toInt() ?? 0,
      firstName: user['firstName'] as String? ?? '',
      lastName: user['lastName'] as String? ?? '',
      email: user['email'] as String? ?? '',
      avatar: user['avatar'] as String?,
      propertyTitle: property?['title'] as String?,
      hotelTitle: hotel?['title'] as String?,
    );
  }

  String get displayName {
    final n = '${firstName.trim()} ${lastName.trim()}'.trim();
    return n.isNotEmpty ? n : email;
  }

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l'.isNotEmpty
        ? '$f$l'
        : email.isNotEmpty
        ? email[0].toUpperCase()
        : '?';
  }

  String get assignment {
    if (propertyTitle != null) return propertyTitle!;
    if (hotelTitle != null) return hotelTitle!;
    return 'Unassigned';
  }
}

class StaffController extends GetxController {
  final staff = <StaffMember>[].obs;
  final isLoading = false.obs;

  // Search state for the add-staff picker
  final userSearchResults = <Map<String, dynamic>>[].obs;
  final isSearchingUsers = false.obs;

  String get _token {
    try {
      return Get.find<ProfileController>().token;
    } catch (_) {
      return '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchStaff();
  }

  Future<void> fetchStaff() async {
    final token = _token;
    if (token.isEmpty) return;
    isLoading.value = true;
    try {
      final raw = await ApiService.getStaff(token: token);
      staff.value = raw.map(StaffMember.fromJson).toList();
    } catch (e) {
      _err('Failed to load staff', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchUsers(String query) async {
    final token = _token;
    if (token.isEmpty) return;
    isSearchingUsers.value = true;
    try {
      final raw = await ApiService.getUsers(token: token, query: query.trim());
      // Exclude users already on staff
      final existingIds = staff.map((s) => s.userId).toSet();

      // Also exclude the currently authenticated user
      try {
        final myId = Get.find<ProfileController>().userId;
        existingIds.add(myId);
      } catch (_) {}

      userSearchResults.value = raw
          .where((u) => !existingIds.contains((u['id'] as num?)?.toInt()))
          .toList();
    } catch (_) {
      userSearchResults.value = [];
    } finally {
      isSearchingUsers.value = false;
    }
  }

  void clearSearch() {
    userSearchResults.value = [];
    isSearchingUsers.value = false;
  }

  Future<void> addStaff({
    required int userId,
    int? propertyId,
    int? hotelId,
  }) async {
    final token = _token;
    if (token.isEmpty) return;
    try {
      await ApiService.addStaff(
        token: token,
        userId: userId,
        propertyId: propertyId,
        hotelId: hotelId,
      );
      _ok('Staff member added');
      await fetchStaff();
    } catch (e) {
      _err('Failed to add staff', e);
    }
  }

  Future<void> removeStaff(StaffMember member) async {
    final token = _token;
    if (token.isEmpty) return;
    try {
      await ApiService.removeStaff(token: token, staffId: member.staffId);
      _ok('${member.displayName} removed from staff');
      await fetchStaff();
    } catch (e) {
      _err('Failed to remove staff', e);
    }
  }

  void _ok(String msg) => Get.snackbar(
    'Done',
    msg,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
    backgroundColor: const Color(0xFF38CAC7),
    colorText: Colors.white,
  );

  void _err(String prefix, Object e) => Get.snackbar(
    'Error',
    '$prefix: ${e.toString().replaceFirst('Exception: ', '')}',
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
    backgroundColor: Colors.red.shade700,
    colorText: Colors.white,
  );
}
