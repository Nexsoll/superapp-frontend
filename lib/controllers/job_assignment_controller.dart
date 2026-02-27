import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/modal/job_model.dart';
import 'package:superapp/services/api_service.dart';

/// Simple user model for the assign picker.
class AppUser {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatar;

  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: (json['id'] as num).toInt(),
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    avatar: json['avatar'] as String?,
  );

  String get displayName {
    final full = '${firstName.trim()} ${lastName.trim()}'.trim();
    return full.isNotEmpty ? full : email;
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
}

class JobAssignmentController extends GetxController {
  final selectedTab = 0.obs;
  final isLoading = false.obs;
  final jobs = <Job>[].obs;

  // ── User search state (for the assign bottom sheet) ──
  final userSearchQuery = ''.obs;
  final userResults = <AppUser>[].obs;
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
    fetchJobs();
  }

  // ── Jobs ────────────────────────────────────────────────────────────────────

  Future<void> fetchJobs() async {
    final token = _token;
    if (token.trim().isEmpty) return;

    isLoading.value = true;
    try {
      final raw = await ApiService.getAllJobs(token: token);
      jobs.value = raw.map((j) => Job.fromJson(j)).toList();
    } catch (e) {
      _showError('Failed to load jobs', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createJob({
    required String title,
    required String description,
    String? urgency,
    double? budget,
    int? propertyId,
    int? hotelId,
  }) async {
    final token = _token;
    if (token.trim().isEmpty) return false;

    try {
      await ApiService.createJob(
        token: token,
        title: title,
        description: description,
        urgency: urgency,
        budget: budget,
        propertyId: propertyId,
        hotelId: hotelId,
      );
      await fetchJobs();
      return true;
    } catch (e) {
      _showError('Failed to create job', e);
      return false;
    }
  }

  Future<void> approveJob(Job job) async {
    final token = _token;
    if (token.trim().isEmpty) return;

    try {
      await ApiService.approveJob(token: token, jobId: job.id);
      _showSuccess('"${job.title}" approved successfully');
      await fetchJobs();
    } catch (e) {
      _showError('Failed to approve job', e);
    }
  }

  Future<void> deleteJob(Job job) async {
    final token = _token;
    if (token.trim().isEmpty) return;

    try {
      await ApiService.deleteJob(token: token, jobId: job.id);
      jobs.removeWhere((j) => j.id == job.id);
      _showSuccess('"${job.title}" deleted successfully');
    } catch (e) {
      _showError('Failed to delete job', e);
    }
  }

  // ── Assign job ──────────────────────────────────────────────────────────────

  /// Assigns [job] to [user]. Called from the user-picker bottom sheet.
  Future<void> assignJobToUser(Job job, AppUser user) async {
    final token = _token;
    if (token.trim().isEmpty) return;

    try {
      await ApiService.assignJobToUser(
        token: token,
        jobId: job.id,
        applierId: user.id,
      );
      _showSuccess('"${job.title}" assigned to ${user.displayName}');
      await fetchJobs();
    } catch (e) {
      _showError('Failed to assign job', e);
    }
  }

  Future<bool> autoAssignJob(Job job) async {
    final token = _token;
    if (token.trim().isEmpty) return false;

    try {
      await ApiService.autoAssignJob(token: token, jobId: job.id);
      _showSuccess(
        '"${job.title}" auto-assigned to an available staff member successfully!',
      );
      await fetchJobs();
      return true;
    } catch (e) {
      _showError('Failed to auto-assign job', e);
      return false;
    }
  }

  // ── User search ─────────────────────────────────────────────────────────────

  Future<void> searchUsers(String query) async {
    final token = _token;
    if (token.trim().isEmpty) return;

    userSearchQuery.value = query;
    isSearchingUsers.value = true;
    try {
      // Only show staff members in the assignment picker
      final raw = await ApiService.getStaffForAssignment(
        token: token,
        query: query.trim(),
      );
      // Each raw item is a Staff record; the user is nested under 'user'
      userResults.value = raw.map((item) {
        final u = item['user'] as Map<String, dynamic>? ?? item;
        return AppUser.fromJson(u);
      }).toList();
    } catch (_) {
      userResults.value = [];
    } finally {
      isSearchingUsers.value = false;
    }
  }

  void clearUserSearch() {
    userSearchQuery.value = '';
    userResults.value = [];
    isSearchingUsers.value = false;
  }

  // ── Tabs ────────────────────────────────────────────────────────────────────

  void onTabTap(int index) => selectedTab.value = index;

  List<Job> get filteredJobs {
    switch (selectedTab.value) {
      case 1:
        return jobs.where((j) => j.status == JobStatus.QUEUED).toList();
      case 2:
        return jobs.where((j) => j.status == JobStatus.PENDING).toList();
      case 3:
        return jobs
            .where(
              (j) =>
                  j.status == JobStatus.COMPLETED ||
                  j.status == JobStatus.APPROVED,
            )
            .toList();
      default:
        return jobs;
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  void _showSuccess(String message) => Get.snackbar(
    'Success',
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
    backgroundColor: const Color(0xFF38CAC7),
    colorText: Colors.white,
  );

  void _showError(String prefix, Object e) => Get.snackbar(
    'Error',
    '$prefix: ${e.toString().replaceFirst('Exception: ', '')}',
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
    backgroundColor: Colors.red.shade700,
    colorText: Colors.white,
  );
}
