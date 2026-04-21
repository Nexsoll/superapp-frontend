import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superapp/screens/notification_screen.dart';
import 'package:superapp/services/listing_service.dart';
import 'package:superapp/services/currency_service.dart';
import 'package:superapp/services/api_service.dart';
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

  // AI Recommendations
  final aiRecommendations = <Map<String, dynamic>>[].obs;
  final aiRecommendationCount = 0.obs;
  final isFetchingRecommendations = false.obs;

  // AI investment announcement for property mode
  final investmentAnnouncementData = Rxn<Map<String, dynamic>>();
  final isFetchingInvestmentAnnouncement = false.obs;

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
    fetchInvestmentAnnouncement();
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

  Future<void> fetchAiRecommendations({String? forceType}) async {
    isFetchingRecommendations.value = true;
    try {
      final type =
          forceType ?? (categoryIndex.value == 1 ? 'Property' : 'Hotel');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      if (token == null || token.isEmpty) return;

      final result = await ApiService.getAiRecommendations(
        token: token,
        type: type,
      );
      final recommendations = result['recommendations'] as List? ?? [];

      aiRecommendations.value = recommendations.cast<Map<String, dynamic>>();
      aiRecommendationCount.value = result['count'] ?? recommendations.length;
    } catch (e) {
      aiRecommendationCount.value = 0;
    } finally {
      isFetchingRecommendations.value = false;
    }
  }

  Future<void> fetchInvestmentAnnouncement({bool forceRefresh = false}) async {
    if (isFetchingInvestmentAnnouncement.value) return;
    if (!forceRefresh && investmentAnnouncementData.value != null) return;

    isFetchingInvestmentAnnouncement.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      if (token == null || token.isEmpty) return;

      final result = await ApiService.getInvestmentAnnouncement(token: token);
      investmentAnnouncementData.value = result;
    } catch (_) {
      // Keep static announcement fallback on failure
    } finally {
      isFetchingInvestmentAnnouncement.value = false;
    }
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(key.toString(), val),
      );
    }
    return null;
  }

  Map<String, dynamic>? get investmentRecommendation {
    return _asMap(investmentAnnouncementData.value?['recommendation']);
  }

  int? get recommendedInvestmentPropertyId {
    final id = investmentRecommendation?['propertyId'];
    if (id is num) return id.toInt();
    return null;
  }

  Map<String, dynamic>? get recommendedInvestmentProperty {
    final recommendedId = recommendedInvestmentPropertyId;
    if (recommendedId != null) {
      for (final property in allPropertiesData) {
        final propertyId = (property['id'] as num?)?.toInt();
        if (propertyId == recommendedId) {
          return property;
        }
      }
    }

    final rec = investmentRecommendation;
    if (rec == null || recommendedId == null) return null;

    return {
      'id': recommendedId,
      'title': rec['propertyTitle'],
      'address': rec['address'],
      'price': rec['priceUsd'],
    };
  }

  String get investmentAnnouncementTitle {
    final announcementMap = _asMap(investmentAnnouncementData.value?['announcement']);
    final title = announcementMap?['title']?.toString().trim();
    if (title != null && title.isNotEmpty) return title;
    return 'Property for Investment';
  }

  String get investmentAnnouncementButtonText {
    final announcementMap = _asMap(investmentAnnouncementData.value?['announcement']);
    final text = announcementMap?['buttonText']?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
    return propertyAnnouncement.buttonText;
  }

  String get investmentAnnouncementDescription {
    final rec = investmentRecommendation;
    if (rec != null) {
      final title = rec['propertyTitle']?.toString().trim();
      final chance = (rec['investmentChancePercent'] as num?)?.round();
      final roi = (rec['expectedRoiPercent'] as num?)?.toDouble();
      final profitUsd = (rec['estimatedProfit12MonthsUsd'] as num?)?.toDouble();

      if (title != null &&
          title.isNotEmpty &&
          chance != null &&
          roi != null &&
          profitUsd != null) {
        return 'Buy "$title" for investment. Today market chance: $chance%. Estimated 12-month profit: ${formatProjectedProfit(profitUsd)} (${roi.toStringAsFixed(1)}% ROI).';
      }
    }

    final announcementMap = _asMap(investmentAnnouncementData.value?['announcement']);
    final desc = announcementMap?['description']?.toString().trim();
    if (desc != null && desc.isNotEmpty) return desc;

    return propertyAnnouncement.description;
  }

  String formatProjectedProfit(double usdAmount) {
    final profileController = Get.find<ProfileController>();
    final userCurrency = profileController.userCurrency.value;
    final converted = CurrencyService.convertFromUSD(usdAmount, userCurrency);
    return CurrencyService.formatAmount(converted, userCurrency, decimals: 0);
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
    final convertedPrice = CurrencyService.convertFromUSD(
      minPrice,
      userCurrency,
    );

    return CurrencyService.formatAmount(
          convertedPrice,
          userCurrency,
          decimals: 0,
        ) +
        '/night';
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
      return CurrencyService.formatAmount(
            convertedPrice / 1000000,
            userCurrency,
            decimals: 1,
          ) +
          'M';
    } else if (convertedPrice >= 1000) {
      return CurrencyService.formatAmount(
            convertedPrice / 1000,
            userCurrency,
            decimals: 0,
          ) +
          'K';
    }
    return CurrencyService.formatAmount(
      convertedPrice,
      userCurrency,
      decimals: 0,
    );
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
    if (index == 1) {
      fetchInvestmentAnnouncement();
    }
  }

  void goToNotifiction() {
    Get.to(() => const NotificationScreen());
  }
}
