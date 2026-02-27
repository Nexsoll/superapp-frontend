import 'package:get/get.dart';
import 'package:superapp/screens/notification_screen.dart';
import 'package:superapp/services/listing_service.dart';
import 'package:superapp/services/currency_service.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/controllers/dashboard_controller.dart';

import '../modal/announcement_modal.dart';

class MainScreenController extends GetxController {
  final RxInt bottomIndex = 0.obs;
  final RxInt categoryIndex = 0.obs;

  final _listingService = ListingService();

  // Real hotel data from backend (top 3 featured)
  final featuredHotelsData = <Map<String, dynamic>>[].obs;
  final isFetchingHotels = true.obs;

  // Real property data from backend (top 3 featured)
  final featuredPropertiesData = <Map<String, dynamic>>[].obs;
  final isFetchingProperties = true.obs;

  // Full lists for explore / search screens
  final allPropertiesData = <Map<String, dynamic>>[].obs;
  final allHotelsData = <Map<String, dynamic>>[].obs;

  final AnnouncementModal announcement = const AnnouncementModal(
    title: 'Summer Special!',
    description: 'Get 20% off on all hotel bookings this\nmonth',
    buttonText: 'Book now',
  );

  final AnnouncementModal propertyAnnouncement = const AnnouncementModal(
    title: 'Investment Alert!',
    description: 'Exclusive pre-launch properties with up\nto 15% ROI',
    buttonText: 'Explore now',
  );

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedHotels();
    fetchFeaturedProperties();
  }

  Future<void> fetchFeaturedHotels() async {
    isFetchingHotels.value = true;
    try {
      final allHotels = await _listingService.getAllHotels();
      final hotelList = allHotels.cast<Map<String, dynamic>>();
      allHotelsData.value = hotelList;
      // Take only top 3 for featured section
      featuredHotelsData.value = hotelList.take(3).toList();
    } catch (_) {
      // Silently fail – featured section will just be empty
    } finally {
      isFetchingHotels.value = false;
    }
  }

  Future<void> fetchFeaturedProperties() async {
    isFetchingProperties.value = true;
    try {
      final allProperties = await _listingService.getAllProperties();
      final propertyList = allProperties.cast<Map<String, dynamic>>();
      allPropertiesData.value = propertyList;
      // Take only top 3 for featured section
      featuredPropertiesData.value = propertyList.take(3).toList();
    } catch (_) {
      // Silently fail – featured section will just be empty
    } finally {
      isFetchingProperties.value = false;
    }
  }

  /// Get cheapest room price for display
  String getMinPrice(Map<String, dynamic> hotel) {
    final roomsData = hotel['rooms'];
    if (roomsData == null) return '';
    
    List<dynamic> rooms;
    if (roomsData is List) {
      rooms = roomsData;
    } else if (roomsData is Map) {
      // If it's a single room object, wrap it in a list
      rooms = [roomsData];
    } else {
      return '';
    }
    
    if (rooms.isEmpty) return '';
    double minPrice = double.infinity;
    for (final room in rooms) {
      if (room is! Map) continue;
      final priceValue = room['price'];
      if (priceValue == null) continue;
      final price = double.tryParse(priceValue.toString()) ?? 0;
      if (price > 0 && price < minPrice) minPrice = price;
    }
    if (minPrice == double.infinity) return '';

    // Get user's selected currency
    final profileController = Get.find<ProfileController>();
    final userCurrency = profileController.userCurrency.value;

    // Convert from USD to user's currency
    final convertedPrice = CurrencyService.convertFromUSD(minPrice, userCurrency);

    return CurrencyService.formatAmount(convertedPrice, userCurrency, decimals: 0) + '/night';
  }

  /// Get average rating from reviews (fallback to 0.0)
  double getRating(Map<String, dynamic> item) {
    final reviews = item['reviews'] as List<dynamic>?;
    if (reviews == null || reviews.isEmpty) return 0.0;
    double sum = 0;
    for (final r in reviews) {
      sum += (r['rating'] as num?)?.toDouble() ?? 0;
    }
    return sum / reviews.length;
  }

  /// Get property price for display
  String getPropertyPrice(Map<String, dynamic> property) {
    final price = double.tryParse(property['price']?.toString() ?? '');
    if (price == null || price == 0) return '';

    // Get user's selected currency
    final profileController = Get.find<ProfileController>();
    final userCurrency = profileController.userCurrency.value;

    // Convert from USD to user's currency
    final convertedPrice = CurrencyService.convertFromUSD(price, userCurrency);

    // Format with appropriate suffix
    if (convertedPrice >= 1000000) {
      return CurrencyService.formatAmount(convertedPrice / 1000000, userCurrency, decimals: 1) + 'M';
    } else if (convertedPrice >= 1000) {
      return CurrencyService.formatAmount(convertedPrice / 1000, userCurrency, decimals: 0) + 'K';
    }
    return CurrencyService.formatAmount(convertedPrice, userCurrency, decimals: 0);
  }

  /// Get property growth tag (placeholder for now)
  String getPropertyTag(Map<String, dynamic> property) {
    // Could be derived from market data in the future
    return '';
  }

  void onBottomNavTap(int index) {
    // If tapping the dashboard tab (index 2) while in property mode, refresh dashboard
    if (index == 2 && categoryIndex.value == 1) {
      try {
        final dashboardController = Get.find<DashboardController>();
        dashboardController.refreshOwnerSummary();
      } catch (_) {
        // DashboardController not yet registered, ignore
      }
    }
    bottomIndex.value = index;
  }

  void onCategoryTap(int index) {
    categoryIndex.value = index;
  }

  void goToNotifiction() {
    Get.to(() => const NotificationScreen());
  }
}
