import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/wishlist_service.dart';
import '../services/currency_service.dart';
import '../controllers/profile_controller.dart';

class WishlistController extends GetxController {
  final WishlistService _wishlistService = WishlistService();
  SharedPreferences? _prefs;

  var isLoading = false.obs;
  var properties = <Map<String, dynamic>>[].obs;
  var hotels = <Map<String, dynamic>>[].obs;
  var propertyWishlistStatus = <int, bool>{}.obs;
  var hotelWishlistStatus = <int, bool>{}.obs;
  var propertyCostBreakdowns = <int, Map<String, dynamic>>{}.obs;
  var isCalculatingPropertyCosts = <int, bool>{}.obs;

  String? get token => _prefs?.getString('user_token');

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (token != null) {
      fetchWishlist();
    }
  }

  Future<void> fetchWishlist() async {
    if (token == null) return;

    try {
      isLoading.value = true;
      final data = await _wishlistService.getMyWishlist(token: token!);

      properties.value = (data['properties'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];

      hotels.value = (data['hotels'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];

      // Update status maps
      for (var property in properties) {
        propertyWishlistStatus[property['id'] as int] = true;
      }
      for (var hotel in hotels) {
        hotelWishlistStatus[hotel['id'] as int] = true;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load wishlist: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> togglePropertyWishlist(int propertyId) async {
    if (token == null) {
      Get.snackbar('Error', 'Please login to add to wishlist');
      return;
    }

    try {
      final isInWishlist = propertyWishlistStatus[propertyId] ?? false;

      if (isInWishlist) {
        await _wishlistService.removePropertyFromWishlist(
          token: token!,
          propertyId: propertyId,
        );
        propertyWishlistStatus[propertyId] = false;
        properties.removeWhere((p) => p['id'] == propertyId);
        Get.snackbar('Success', 'Removed from wishlist');
      } else {
        await _wishlistService.addPropertyToWishlist(
          token: token!,
          propertyId: propertyId,
        );
        propertyWishlistStatus[propertyId] = true;
        Get.snackbar('Success', 'Added to wishlist');
        fetchWishlist();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update wishlist: $e');
    }
  }

  Future<void> toggleHotelWishlist(int hotelId) async {
    if (token == null) {
      Get.snackbar('Error', 'Please login to add to wishlist');
      return;
    }

    try {
      final isInWishlist = hotelWishlistStatus[hotelId] ?? false;

      if (isInWishlist) {
        await _wishlistService.removeHotelFromWishlist(
          token: token!,
          hotelId: hotelId,
        );
        hotelWishlistStatus[hotelId] = false;
        hotels.removeWhere((h) => h['id'] == hotelId);
        Get.snackbar('Success', 'Removed from wishlist');
      } else {
        await _wishlistService.addHotelToWishlist(
          token: token!,
          hotelId: hotelId,
        );
        hotelWishlistStatus[hotelId] = true;
        Get.snackbar('Success', 'Added to wishlist');
        fetchWishlist();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update wishlist: $e');
    }
  }

  Future<bool> checkPropertyInWishlist(int propertyId) async {
    if (token == null) return false;

    if (propertyWishlistStatus.containsKey(propertyId)) {
      return propertyWishlistStatus[propertyId]!;
    }

    try {
      final isInWishlist = await _wishlistService.isPropertyInWishlist(
        token: token!,
        propertyId: propertyId,
      );
      propertyWishlistStatus[propertyId] = isInWishlist;
      return isInWishlist;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkHotelInWishlist(int hotelId) async {
    if (token == null) return false;

    if (hotelWishlistStatus.containsKey(hotelId)) {
      return hotelWishlistStatus[hotelId]!;
    }

    try {
      final isInWishlist = await _wishlistService.isHotelInWishlist(
        token: token!,
        hotelId: hotelId,
      );
      hotelWishlistStatus[hotelId] = isInWishlist;
      return isInWishlist;
    } catch (e) {
      return false;
    }
  }

  bool isPropertyInWishlistSync(int propertyId) {
    return propertyWishlistStatus[propertyId] ?? false;
  }

  bool isHotelInWishlistSync(int hotelId) {
    return hotelWishlistStatus[hotelId] ?? false;
  }

  bool isCalculatingPropertyCost(int propertyId) {
    return isCalculatingPropertyCosts[propertyId] ?? false;
  }

  Future<Map<String, dynamic>?> calculatePropertyCostBreakdown(
    int propertyId, {
    bool forceRefresh = false,
  }) async {
    if (token == null) {
      Get.snackbar('Error', 'Please login to continue');
      return null;
    }

    if (!forceRefresh && propertyCostBreakdowns.containsKey(propertyId)) {
      return propertyCostBreakdowns[propertyId];
    }

    try {
      isCalculatingPropertyCosts[propertyId] = true;
      final result = await _wishlistService.getPropertyCostBreakdown(
        token: token!,
        propertyId: propertyId,
      );
      propertyCostBreakdowns[propertyId] = result;
      return result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to calculate costs: $e');
      return null;
    } finally {
      isCalculatingPropertyCosts[propertyId] = false;
      isCalculatingPropertyCosts.refresh();
    }
  }

  String formatUsdAmount(double usdAmount, {int decimals = 0}) {
    final profileController = Get.find<ProfileController>();
    final userCurrency = profileController.userCurrency.value;
    final convertedPrice = CurrencyService.convertFromUSD(usdAmount, userCurrency);
    return CurrencyService.formatAmount(
      convertedPrice,
      userCurrency,
      decimals: decimals,
    );
  }

  /// Get formatted price for hotel (cheapest room)
  String getHotelPrice(Map<String, dynamic> hotel) {
    final rooms = hotel['rooms'] as List<dynamic>?;
    if (rooms == null || rooms.isEmpty) return 'N/A';

    double minPrice = double.infinity;
    for (final room in rooms) {
      final price = double.tryParse(room['price'].toString()) ?? 0;
      if (price > 0 && price < minPrice) minPrice = price;
    }
    if (minPrice == double.infinity) return 'N/A';

    // Get user's selected currency
    final profileController = Get.find<ProfileController>();
    final userCurrency = profileController.userCurrency.value;

    // Convert from USD to user's currency
    final convertedPrice = CurrencyService.convertFromUSD(minPrice, userCurrency);

    return CurrencyService.formatAmount(convertedPrice, userCurrency, decimals: 0);
  }

  /// Get formatted price for property
  String getPropertyPrice(Map<String, dynamic> property) {
    final price = double.tryParse(property['price']?.toString() ?? '');
    if (price == null || price == 0) return 'N/A';

    // Get user's selected currency
    final profileController = Get.find<ProfileController>();
    final userCurrency = profileController.userCurrency.value;

    // Convert from USD to user's currency
    final convertedPrice = CurrencyService.convertFromUSD(price, userCurrency);

    if (convertedPrice >= 1000000) {
      return CurrencyService.formatAmount(convertedPrice / 1000000, userCurrency, decimals: 1) + 'M';
    } else if (convertedPrice >= 1000) {
      return CurrencyService.formatAmount(convertedPrice / 1000, userCurrency, decimals: 0) + 'K';
    }
    return CurrencyService.formatAmount(convertedPrice, userCurrency, decimals: 0);
  }
}
