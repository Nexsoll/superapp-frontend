import 'package:get/get.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/screens/earning_screen.dart';
import 'package:superapp/screens/my_listing_screen.dart';
import 'package:superapp/screens/expanse_tracking_screen.dart';
import 'package:superapp/screens/property_analytics_screen.dart';
import 'package:superapp/services/api_service.dart';

class DashboardController extends GetxController {
  final totalEarnings = 12450.0.obs;
  final growthPercent = 12.obs;

  final activeListings = 0.obs;
  final activeProperties = 0.obs;
  final activeHotels = 0.obs;
  final pendingRequestsBadge = 'Action needed'.obs;

  Future<void> refreshOwnerSummary() async {
    String token = '';
    try {
      final profile = Get.find<ProfileController>();
      token = profile.token;
    } catch (_) {
      token = '';
    }

    if (token.trim().isEmpty) return;

    try {
      final summary = await ApiService.getOwnerListingSummary(token: token);
      final v = summary['activeListings'];
      if (v is num) {
        activeListings.value = v.toInt();
      } else {
        activeListings.value = int.tryParse(v?.toString() ?? '') ?? 0;
      }
      final props = summary['activeProperties'];
      if (props is num) {
        activeProperties.value = props.toInt();
      } else {
        activeProperties.value = int.tryParse(props?.toString() ?? '') ?? 0;
      }
      final hotels = summary['activeHotels'];
      if (hotels is num) {
        activeHotels.value = hotels.toInt();
      } else {
        activeHotels.value = int.tryParse(hotels?.toString() ?? '') ?? 0;
      }
    } catch (_) {
      // ignore dashboard summary fetch failures
    }
  }

  @override
  void onInit() {
    super.onInit();
    refreshOwnerSummary();
  }

  void onViewReport() => Get.snackbar('Report', 'View Report');
  void onTotalEarnings() => Get.snackbar('Earnings', 'Total Earnings');
  void onActiveListings() => Get.snackbar('Listings', 'Active Listings');
  void onPendingRequests() => Get.snackbar('Requests', 'Pending Requests');

  Future<void> onMyListings() async {
    await Get.to(
      () => const MyListingScreen(category: ListingCategory.property),
    );
    await refreshOwnerSummary();
  }

  void onEarnings() => Get.to(() => EarningsScreen());
  void onExpenses() => Get.to(() => ExpenseTrackingScreen());
  void onAnalytics() => Get.to(() => PropertyAnalyticsScreen());

  String get earningsFormatted {
    final v = totalEarnings.value.toStringAsFixed(0);
    return '\$${v.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  String get growthText => '+${growthPercent.value}%';
}
