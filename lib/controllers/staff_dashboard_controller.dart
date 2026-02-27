import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/modal/job_model.dart';
import 'package:superapp/services/api_service.dart';

class StaffDashboardController extends GetxController {
  final jobs = <Job>[].obs;
  final isLoadingJobs = false.obs;

  final earnings = 0.0.obs;
  final completedJobsCount = 0.obs;
  final completedJobs = <Map<String, dynamic>>[].obs;
  final isLoadingEarnings = false.obs;

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
    refreshDashboard();
  }

  Future<void> refreshDashboard() async {
    await Future.wait([fetchJobs(), fetchEarnings()]);
  }

  Future<void> fetchJobs() async {
    final token = _token;
    if (token.isEmpty) return;

    isLoadingJobs.value = true;
    try {
      final List<Map<String, dynamic>> rawJobs = await ApiService.getStaffJobs(
        token: token,
      );
      jobs.value = rawJobs.map((j) => Job.fromJson(j)).toList();
    } catch (e) {
      _err('Failed to load jobs', e);
    } finally {
      isLoadingJobs.value = false;
    }
  }

  Future<void> fetchEarnings() async {
    final token = _token;
    if (token.isEmpty) return;

    isLoadingEarnings.value = true;
    try {
      final Map<String, dynamic> data = await ApiService.getStaffEarnings(
        token: token,
      );
      earnings.value = (data['totalEarnings'] as num?)?.toDouble() ?? 0.0;
      completedJobsCount.value = (data['jobsCount'] as num?)?.toInt() ?? 0;
      completedJobs.value =
          (data['completedJobs'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      _err('Failed to load earnings', e);
    } finally {
      isLoadingEarnings.value = false;
    }
  }

  Future<void> acceptJob(Job job) async {
    final token = _token;
    if (token.isEmpty) return;

    try {
      await ApiService.acceptJob(token: token, jobId: job.id);
      _ok('Job accepted and started');
      await refreshDashboard();
    } catch (e) {
      _err('Failed to accept job', e);
    }
  }

  Future<void> rejectJob(Job job) async {
    final token = _token;
    if (token.isEmpty) return;

    try {
      await ApiService.rejectJob(token: token, jobId: job.id);
      _ok('Job rejected');
      await refreshDashboard();
    } catch (e) {
      _err('Failed to reject job', e);
    }
  }

  Future<void> submitJobCompletion(
    int jobId,
    String before,
    String after,
  ) async {
    final token = _token;
    if (token.isEmpty) return;

    try {
      await ApiService.submitStaffJob(
        token: token,
        jobId: jobId,
        beforeImage: before,
        afterImage: after,
      );
      await refreshDashboard();
    } catch (e) {
      _err('Failed to submit job', e);
      rethrow;
    }
  }

  void _ok(String msg) => Get.snackbar(
    'Success',
    msg,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFF38CAC7),
    colorText: Colors.white,
    margin: const EdgeInsets.all(12),
  );

  void _err(String title, dynamic e) => Get.snackbar(
    'Error',
    '$title: ${e.toString().replaceFirst('Exception: ', '')}',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red.shade700,
    colorText: Colors.white,
    margin: const EdgeInsets.all(12),
  );
}
