import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/modal/job_model.dart';
import 'package:superapp/services/api_service.dart';

class PhotoReviewController extends GetxController {
  final jobs = <Job>[].obs;
  final isLoading = false.obs;

  String get _token {
    try {
      return Get.find<ProfileController>().token;
    } catch (_) {
      return '';
    }
  }

  int get pendingCount => jobs.length;

  @override
  void onInit() {
    super.onInit();
    fetchPendingReviews();
  }

  Future<void> fetchPendingReviews() async {
    final token = _token;
    if (token.isEmpty) return;

    isLoading.value = true;
    try {
      final List<Map<String, dynamic>> rawJobs =
          await ApiService.getJobsByStatus(
            token: token,
            status: 'AWAITING_REVIEW',
          );
      jobs.value = rawJobs.map((j) => Job.fromJson(j)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load photo reviews: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reviewJob(int jobId, bool approve, {String? reason}) async {
    final token = _token;
    if (token.isEmpty) return;

    try {
      await ApiService.reviewJob(
        token: token,
        jobId: jobId,
        status: approve ? 'APPROVED' : 'REJECTED',
        reason: reason,
      );
      Get.snackbar(
        'Success',
        'Job ${approve ? 'approved' : 'rejected'} successfully',
        backgroundColor: approve ? Colors.green : Colors.red,
        colorText: Colors.white,
      );
      await fetchPendingReviews();
    } catch (e) {
      Get.snackbar('Error', 'Failed to review job: $e');
    }
  }
}
