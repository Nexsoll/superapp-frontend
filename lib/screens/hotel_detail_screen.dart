import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/main_screen_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../screens/main_screen.dart';
import '../screens/select_dates_screen.dart';
import '../services/currency_service.dart';
import '../services/listing_service.dart';
import '../widgets/main_bottom_bar.dart';
import '../widgets/hotel_image_carousel.dart';
import '../widgets/hotel_header_info.dart';
import '../widgets/check_in_out_section.dart';
import '../widgets/ar_experience_section.dart';
import '../widgets/hotel_amenities_section.dart';
import '../widgets/hotel_about_section.dart';
import '../widgets/select_room_section.dart';
import '../widgets/hotel_reviews_section.dart';

class HotelDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? hotelData;

  const HotelDetailScreen({super.key, this.hotelData});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  late Map<String, dynamic> _hotelData;
  final Map<int, int> _selectedRoomQuantities = <int, int>{};
  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  @override
  void initState() {
    super.initState();
    _hotelData = widget.hotelData ?? {};
    final now = DateTime.now();
    _checkInDate = now;
    _checkOutDate = now.add(const Duration(days: 2));
    _loadHotelData();
  }

  Future<void> _loadHotelData() async {
    final id = _toInt(widget.hotelData?['id']);
    if (id == null) return;

    try {
      final updatedData = await ListingService().getHotelById(id);
      if (mounted) {
        setState(() {
          _hotelData = updatedData;
        });
      }
    } catch (e) {
      debugPrint('Error loading hotel data: $e');
    }
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  void _onQuantityChanged(int roomId, bool increment) {
    setState(() {
      final current = _selectedRoomQuantities[roomId] ?? 0;
      final next = increment ? current + 1 : current - 1;

      if (next <= 0) {
        _selectedRoomQuantities.remove(roomId);
      } else {
        _selectedRoomQuantities[roomId] = next;
      }
    });
  }

  int _selectedRoomsCount() {
    return _selectedRoomQuantities.values.fold(0, (sum, qty) => sum + qty);
  }

  double _selectedNightlyTotal(List<dynamic> rooms) {
    final roomById = <int, Map<String, dynamic>>{};
    for (final room in rooms) {
      if (room is! Map<String, dynamic>) continue;
      final id = _toInt(room['id']);
      if (id != null) {
        roomById[id] = room;
      }
    }

    double total = 0;
    _selectedRoomQuantities.forEach((roomId, qty) {
      final room = roomById[roomId];
      if (room == null) return;
      total += _toDouble(room['price']) * qty;
    });

    return total;
  }

  String _formatNightlyPrice(double priceUsd) {
    if (priceUsd <= 0) return '\$0/night';

    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    final userCurrency = profileController.userCurrency.value;
    final convertedPrice = CurrencyService.convertFromUSD(
      priceUsd,
      userCurrency,
    );
    return '${CurrencyService.formatAmount(convertedPrice, userCurrency, decimals: 0)}/night';
  }

  Future<void> _openDatesSelection({
    required int initialTabIndex,
    required bool createBookingOnContinue,
    required int? hotelId,
    required String hotelTitle,
    required String hotelAddress,
    required String? hotelImageUrl,
    required List<dynamic> rooms,
  }) async {
    final result = await Get.to<Map<String, dynamic>>(
      () => SelectDatesScreen(
        initialTabIndex: initialTabIndex,
        initialCheckIn: _checkInDate,
        initialCheckOut: _checkOutDate,
        hotelId: hotelId,
        hotelTitle: hotelTitle,
        hotelAddress: hotelAddress,
        hotelImageUrl: hotelImageUrl,
        rooms: rooms,
        selectedRoomQuantities: _selectedRoomQuantities,
        createBookingOnContinue: createBookingOnContinue,
      ),
    );

    if (result == null) return;

    final checkInRaw = result['checkIn'];
    final checkOutRaw = result['checkOut'];
    final nextCheckIn = checkInRaw is String
        ? DateTime.tryParse(checkInRaw)
        : null;
    final nextCheckOut = checkOutRaw is String
        ? DateTime.tryParse(checkOutRaw)
        : null;

    if (nextCheckIn == null || nextCheckOut == null) return;

    setState(() {
      _checkInDate = nextCheckIn;
      _checkOutDate = nextCheckOut;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<MainScreenController>()
        ? Get.find<MainScreenController>()
        : Get.put(MainScreenController());
    final theme = Theme.of(context);

    // Extract data
    final title = _hotelData['title'] ?? 'Grand Plaza Hotel';
    final address = _hotelData['address'] ?? 'London';
    final description = _hotelData['description'] ?? '';
    final amenities =
        (_hotelData['amenities'] as List<dynamic>?)?.cast<String>() ?? [];
    final rooms = (_hotelData['rooms'] as List<dynamic>?) ?? [];
    final reviews = (_hotelData['reviews'] as List<dynamic>?) ?? [];
    final images = (_hotelData['images'] as List<dynamic>?) ?? [];
    final hotelId = _toInt(_hotelData['id']);
    final heroHotelImageUrl = images.isNotEmpty && hotelId != null
        ? ListingService.hotelImageUrl(hotelId, 0)
        : null;
    final selectedRoomsCount = _selectedRoomsCount();
    final selectedNightlyTotal = _selectedNightlyTotal(rooms);
    final isDesktopWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 900;
    final wishlistController = Get.isRegistered<WishlistController>()
        ? Get.find<WishlistController>()
        : Get.put(WishlistController());

    // Calculate rating
    double rating = 0.0;
    if (reviews.isNotEmpty) {
      double sum = 0;
      for (final r in reviews) {
        sum += (r['rating'] as num?)?.toDouble() ?? 0;
      }
      rating = sum / reviews.length;
    }

    // Rating label
    String ratingLabel = 'New';
    if (rating >= 4.5) {
      ratingLabel = 'Superb';
    } else if (rating >= 4.0) {
      ratingLabel = 'Excellent';
    } else if (rating >= 3.5) {
      ratingLabel = 'Very Good';
    } else if (rating >= 3.0) {
      ratingLabel = 'Good';
    } else if (rating > 0) {
      ratingLabel = 'Average';
    }

    if (isDesktopWeb) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(40, 28, 40, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: const Color(0xFF2FC1BE),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hotel details'.tr,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF2FC1BE),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: SizedBox(
                                      height: 420,
                                      width: double.infinity,
                                      child: heroHotelImageUrl != null
                                          ? Image.network(
                                              heroHotelImageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Image.asset(
                                                    'assets/hotel1.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                            )
                                          : Image.asset(
                                              'assets/hotel1.png',
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 18,
                                    right: 18,
                                    child: Row(
                                      children: [
                                        _DesktopHeroCircleButton(
                                          icon: Icons.share_outlined,
                                          onTap: () {},
                                        ),
                                        const SizedBox(width: 12),
                                        if (hotelId != null)
                                          Obx(
                                            () => _DesktopHeroHeartButton(
                                              isFilled: wishlistController
                                                  .isHotelInWishlistSync(
                                                    hotelId,
                                                  ),
                                              onTap: () => wishlistController
                                                  .toggleHotelWishlist(hotelId),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              HotelHeaderInfo(
                                name: title,
                                rating: rating,
                                ratingLabel: ratingLabel,
                                reviewCount: reviews.length,
                                location: address,
                              ),
                              const SizedBox(height: 28),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: CheckInOutSection(
                                      checkInDate: _checkInDate,
                                      checkOutDate: _checkOutDate,
                                      onCheckInTap: () => _openDatesSelection(
                                        initialTabIndex: 0,
                                        createBookingOnContinue: false,
                                        hotelId: hotelId,
                                        hotelTitle: title,
                                        hotelAddress: address,
                                        hotelImageUrl: heroHotelImageUrl,
                                        rooms: rooms,
                                      ),
                                      onCheckOutTap: () => _openDatesSelection(
                                        initialTabIndex: 1,
                                        createBookingOnContinue: false,
                                        hotelId: hotelId,
                                        hotelTitle: title,
                                        hotelAddress: address,
                                        hotelImageUrl: heroHotelImageUrl,
                                        rooms: rooms,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 22),
                                  const Expanded(child: ARExperienceSection()),
                                ],
                              ),
                              const SizedBox(height: 28),
                              HotelAmenitiesSection(amenities: amenities),
                              const SizedBox(height: 28),
                              HotelAboutSection(description: description),
                              const SizedBox(height: 28),
                              SelectRoomSection(
                                rooms: rooms,
                                selectedQuantities: _selectedRoomQuantities,
                                onQuantityChanged: _onQuantityChanged,
                              ),
                              const SizedBox(height: 28),
                              HotelReviewsSection(
                                reviews: reviews,
                                hotelId: hotelId,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 34),
                        SizedBox(
                          width: 360,
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: theme.dividerColor.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedRoomsCount > 0
                                          ? '$selectedRoomsCount Room${selectedRoomsCount > 1 ? 's' : ''}'
                                          : 'Select rooms'.tr,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      selectedRoomsCount > 0
                                          ? _formatNightlyPrice(
                                              selectedNightlyTotal,
                                            )
                                          : 'Choose a room to continue booking.'
                                                .tr,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            color: const Color(0xFF2FC1BE),
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    const SizedBox(height: 18),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton.icon(
                                        onPressed: selectedRoomsCount > 0
                                            ? () => _openDatesSelection(
                                                initialTabIndex: 0,
                                                createBookingOnContinue: true,
                                                hotelId: hotelId,
                                                hotelTitle: title,
                                                hotelAddress: address,
                                                hotelImageUrl:
                                                    heroHotelImageUrl,
                                                rooms: rooms,
                                              )
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF2FC1BE,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(Icons.login_rounded),
                                        label: Text('Check In'.tr),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2FC1BE,
                                  ).withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Text(
                                  'Free cancellation is available until 24 hours before check-in.'
                                      .tr,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HotelImageCarousel(
              imageUrls: images.isNotEmpty && hotelId != null
                  ? List.generate(
                      images.length,
                      (i) => ListingService.hotelImageUrl(hotelId, i),
                    )
                  : null,
              hotelId: hotelId,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  HotelHeaderInfo(
                    name: title,
                    rating: rating,
                    ratingLabel: ratingLabel,
                    reviewCount: reviews.length,
                    location: address,
                  ),
                  const SizedBox(height: 24),
                  CheckInOutSection(
                    checkInDate: _checkInDate,
                    checkOutDate: _checkOutDate,
                    onCheckInTap: () => _openDatesSelection(
                      initialTabIndex: 0,
                      createBookingOnContinue: false,
                      hotelId: hotelId,
                      hotelTitle: title,
                      hotelAddress: address,
                      hotelImageUrl: heroHotelImageUrl,
                      rooms: rooms,
                    ),
                    onCheckOutTap: () => _openDatesSelection(
                      initialTabIndex: 1,
                      createBookingOnContinue: false,
                      hotelId: hotelId,
                      hotelTitle: title,
                      hotelAddress: address,
                      hotelImageUrl: heroHotelImageUrl,
                      rooms: rooms,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const ARExperienceSection(),
                  const SizedBox(height: 24),
                  HotelAmenitiesSection(amenities: amenities),
                  const SizedBox(height: 24),
                  HotelAboutSection(description: description),
                  const SizedBox(height: 24),
                  SelectRoomSection(
                    rooms: rooms,
                    selectedQuantities: _selectedRoomQuantities,
                    onQuantityChanged: _onQuantityChanged,
                  ),
                  const SizedBox(height: 24),
                  HotelReviewsSection(reviews: reviews, hotelId: hotelId),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: selectedRoomsCount > 0
          ? _HotelBookingBottomBar(
              theme: theme,
              roomCount: selectedRoomsCount,
              priceText: _formatNightlyPrice(selectedNightlyTotal),
              onCheckInTap: () => _openDatesSelection(
                initialTabIndex: 0,
                createBookingOnContinue: true,
                hotelId: hotelId,
                hotelTitle: title,
                hotelAddress: address,
                hotelImageUrl: heroHotelImageUrl,
                rooms: rooms,
              ),
            )
          : Obx(
              () => MainBottomBar(
                currentIndex: controller.bottomIndex.value,
                isPropertySelected: controller.categoryIndex.value == 1,
                onTap: (index) {
                  controller.categoryIndex.value = 0;
                  controller.bottomIndex.value = index;
                  Get.offAll(() => const MainScreen());
                },
              ),
            ),
    );
  }
}

class _HotelBookingBottomBar extends StatelessWidget {
  final ThemeData theme;
  final int roomCount;
  final String priceText;
  final VoidCallback onCheckInTap;

  const _HotelBookingBottomBar({
    required this.theme,
    required this.roomCount,
    required this.priceText,
    required this.onCheckInTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFF2FC1BE), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$roomCount Room${roomCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF1D2330),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  priceText,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2FC1BE),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: onCheckInTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2FC1BE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Check In'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopHeroCircleButton extends StatelessWidget {
  const _DesktopHeroCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 22),
      ),
    );
  }
}

class _DesktopHeroHeartButton extends StatelessWidget {
  const _DesktopHeroHeartButton({required this.isFilled, required this.onTap});

  final bool isFilled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: isFilled
              ? const Color(0xFFFF6B6B).withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/heart.svg',
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(
              isFilled ? Colors.white : Colors.black,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
