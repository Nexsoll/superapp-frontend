import 'package:get/get.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/modal/job_model.dart';
import 'package:superapp/services/api_service.dart';

class AdminDashboardController extends GetxController {
  final stats = <String, dynamic>{}.obs;
  final insights = <String, dynamic>{}.obs;
  final todaysTasks = <Job>[].obs;
  final createdToday = 0.obs;
  final closedToday = 0.obs;
  final notifications = <dynamic>[].obs;

  final isLoading = false.obs;
  final isLoadingInsights = false.obs;

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
    refreshAll();
  }

  Future<void> refreshAll() async {
    await fetchStats();
    await fetchInsights();
    await fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final token = _token;
    if (token.isEmpty) return;
    try {
      final items = await ApiService.getAdminNotifications(token);
      notifications.assignAll(items);
    } catch (e) {
      print('Failed to fetch notifications: $e');
    }
  }

  Future<void> fetchStats() async {
    final token = _token;
    if (token.isEmpty) return;

    isLoading.value = true;
    try {
      final data = await ApiService.getAdminStats(token: token);
      stats.value = data;

      todaysTasks.assignAll(
        (data['todaysTasks'] as List?)?.map((j) => Job.fromJson(j)).toList() ??
            [],
      );
      createdToday.value = data['createdToday'] ?? 0;
      closedToday.value = data['closedToday'] ?? 0;
    } catch (e) {
      print('Error fetching stats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchInsights() async {
    final token = _token;
    if (token.isEmpty) return;

    isLoadingInsights.value = true;
    try {
      final data = await ApiService.getAdminInsights(token: token);
      insights.value = data;
    } catch (e) {
      print('Error fetching insights: $e');
    } finally {
      isLoadingInsights.value = false;
    }
  }

  int get queuedCount => stats['queuedJobs'] ?? 0;
  int get pendingCount => stats['pendingJobs'] ?? 0;
  int get completedCount => stats['completedJobs'] ?? 0;
  int get photoReviewCount => stats['awaitingReview'] ?? 0;
  double get totalEarnings =>
      (stats['totalEarnings'] as num?)?.toDouble() ?? 0.0;
  double get avgResolution =>
      (stats['avgResolution'] as num?)?.toDouble() ?? 4.2;

  // Insights getters
  double get monthlyRevenue =>
      (insights['monthlyRevenue'] as num?)?.toDouble() ?? 0.0;
  double get revenueTrend =>
      (insights['revenueTrend'] as num?)?.toDouble() ?? 0.0;
  double get avgRating => (insights['avgRating'] as num?)?.toDouble() ?? 4.8;
  int get jobsDone => insights['jobsDone'] ?? 0;
  List<dynamic> get staffPerformance => insights['staffPerformance'] ?? [];
  List<dynamic> get topListings => insights['topListings'] ?? [];

  int get unreadNotificationsCount =>
      notifications.where((n) => n['isRead'] == false).length;

  Future<void> markNotificationsAsRead() async {
    final token = _token;
    if (token.isEmpty) return;
    try {
      final success = await ApiService.markNotificationsAsRead(token);
      if (success) {
        for (var i = 0; i < notifications.length; i++) {
          final n = Map<String, dynamic>.from(notifications[i]);
          n['isRead'] = true;
          notifications[i] = n;
        }
        notifications.refresh();
      }
    } catch (e) {
      print('Failed to mark notifications as read: $e');
    }
  }
}
