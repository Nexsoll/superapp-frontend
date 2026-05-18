import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controllers/main_screen_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../services/listing_service.dart';
import '../services/currency_service.dart';
import '../widgets/hotel_image_carousel.dart';
import '../widgets/hotel_reviews_section.dart';
import '../widgets/main_bottom_bar.dart';
import '../modal/chat_item_modal.dart';
import 'booking_summary_screen.dart';
import 'chat_detail_screen.dart';
import 'main_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? propertyData;

  const PropertyDetailScreen({super.key, this.propertyData});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();

  // icon lookup for neighborhood insights
  static IconData _insightIcon(String label) {
    switch (label.toLowerCase()) {
      case 'school':
        return Icons.school_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'transportation':
        return Icons.directions_bus_outlined;
      case 'hospital':
        return Icons.local_hospital_outlined;
      case 'park':
        return Icons.park_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'café':
      case 'cafe':
        return Icons.coffee_outlined;
      case 'bank':
        return Icons.account_balance_outlined;
      case 'gym':
        return Icons.fitness_center_outlined;
      case 'pharmacy':
        return Icons.local_pharmacy_outlined;
      default:
        return Icons.place_outlined;
    }
  }
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late Map<String, dynamic> _propertyData;

  @override
  void initState() {
    super.initState();
    _propertyData = widget.propertyData ?? {};
    _loadPropertyData();
  }

  Future<void> _loadPropertyData() async {
    final id = widget.propertyData?['id'];
    if (id == null) return;

    try {
      final updatedData = await ListingService().getPropertyById(id as int);
      if (mounted) {
        setState(() {
          _propertyData = updatedData;
        });
      }
    } catch (e) {
      debugPrint('Error loading property data: $e');
    }
  }

  // ── helpers ──────────────────────────────────────────────────────────
  static const Map<String, String> _enumToType = {
    'VILLA': 'Villa',
    'BUNGALOW': 'Apartment',
    'PALACE': 'Condo',
  };

  String get _title => (_propertyData['title'] ?? 'Luxury Villa') as String;
  String get _description => (_propertyData['description'] ?? '') as String;
  String get _address => (_propertyData['address'] ?? '') as String;

  int get _rooms {
    final r = _propertyData['rooms'];
    if (r == null) return 0;
    if (r is int) return r;
    return int.tryParse(r.toString()) ?? 0;
  }

  int get _bathrooms {
    final b = _propertyData['bathrooms'];
    if (b == null) return 0;
    if (b is int) return b;
    return int.tryParse(b.toString()) ?? 0;
  }

  double get _area {
    final a = _propertyData['area'];
    if (a == null) return 0;
    if (a is num) return a.toDouble();
    return double.tryParse(a.toString()) ?? 0;
  }

  String get _propertyType {
    final t = _propertyData['type'] as String?;
    if (t != null && _enumToType.containsKey(t)) return _enumToType[t]!;
    return 'Property';
  }

  List<String> get _amenities {
    final a = _propertyData['amenities'] as List<dynamic>?;
    if (a == null || a.isEmpty) return [];
    return a.map((e) => e.toString()).toList();
  }

  List<String> get _neighborhoodInsights {
    final n = _propertyData['neighborhoodInsights'] as List<dynamic>?;
    if (n == null || n.isEmpty) return [];
    return n.map((e) => e.toString()).toList();
  }

  List<String> get _imageUrls {
    final id = _propertyData['id'];
    if (id == null) return [];
    final images = _propertyData['images'] as List<dynamic>?;
    if (images == null || images.isEmpty) return [];
    return List.generate(
      images.length,
      (i) => ListingService.propertyImageUrl(id as int, i),
    );
  }

  int get _ownerId {
    final ownerId = _propertyData['ownerId'];
    if (ownerId is int) return ownerId;
    return int.tryParse(ownerId.toString()) ?? 0;
  }

  Map<String, dynamic>? get _owner {
    return _propertyData['owner'] as Map<String, dynamic>?;
  }

  bool get _isOwner {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    return _ownerId == profileController.userId;
  }

  String _priceLabel() {
    final price = _propertyData['price'];
    var priceStr = '\$1.8 M';

    if (price == null) return priceStr;

    double priceValue = 0;
    if (price is num) {
      priceValue = price.toDouble();
    } else if (price is String) {
      priceValue = double.tryParse(price) ?? 0;
    }

    if (priceValue <= 0) return priceStr;

    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    final userCurrency = profileController.userCurrency.value;
    final convertedPrice = CurrencyService.convertFromUSD(
      priceValue,
      userCurrency,
    );

    if (convertedPrice >= 1000000) {
      return '${CurrencyService.formatAmount(convertedPrice / 1000000, userCurrency, decimals: 1)} M';
    }
    if (convertedPrice >= 1000) {
      return '${CurrencyService.formatAmount(convertedPrice / 1000, userCurrency, decimals: 0)} K';
    }
    return CurrencyService.formatAmount(
      convertedPrice,
      userCurrency,
      decimals: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<MainScreenController>()
        ? Get.find<MainScreenController>()
        : Get.put(MainScreenController());
    final theme = Theme.of(context);
    final isDesktopWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 900;
    final wishlistController = Get.isRegistered<WishlistController>()
        ? Get.find<WishlistController>()
        : Get.put(WishlistController());

    if (isDesktopWeb) {
      final propertyId = _propertyData['id'] as int?;
      final reviews = (_propertyData['reviews'] as List<dynamic>?) ?? [];
      final imageUrl = _imageUrls.isNotEmpty ? _imageUrls.first : null;

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
                          'Property details'.tr,
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
                                      height: 430,
                                      width: double.infinity,
                                      child: imageUrl != null
                                          ? Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Image.asset(
                                                    'assets/property-header.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                            )
                                          : Image.asset(
                                              'assets/property-header.png',
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 18,
                                    right: 18,
                                    child: Row(
                                      children: [
                                        _DesktopPropertyHeroCircleButton(
                                          icon: Icons.share_outlined,
                                          onTap: () {},
                                        ),
                                        const SizedBox(width: 12),
                                        if (propertyId != null)
                                          Obx(
                                            () =>
                                                _DesktopPropertyHeroHeartButton(
                                                  isFilled: wishlistController
                                                      .isPropertyInWishlistSync(
                                                        propertyId,
                                                      ),
                                                  onTap: () => wishlistController
                                                      .togglePropertyWishlist(
                                                        propertyId,
                                                      ),
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              _PropertyHeaderInfo(
                                theme: theme,
                                title: _title,
                                address: _address,
                              ),
                              const SizedBox(height: 28),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _PropertyFeaturesSection(
                                      theme: theme,
                                      bedrooms: _rooms,
                                      bathrooms: _bathrooms,
                                      area: _area,
                                      type: _propertyType,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: _PropertyARExperienceSection(theme),
                                  ),
                                ],
                              ),
                              if (_amenities.isNotEmpty) ...[
                                const SizedBox(height: 28),
                                _PropertyAmenitiesSection(
                                  theme: theme,
                                  amenities: _amenities,
                                ),
                              ],
                              const SizedBox(height: 28),
                              _InvestmentAnalysisSection(
                                theme: theme,
                                propertyId: propertyId,
                              ),
                              if (_description.isNotEmpty) ...[
                                const SizedBox(height: 28),
                                _AboutSection(
                                  theme: theme,
                                  description: _description,
                                ),
                              ],
                              if (_neighborhoodInsights.isNotEmpty) ...[
                                const SizedBox(height: 28),
                                _NeighborhoodInsightsSection(
                                  theme: theme,
                                  insights: _neighborhoodInsights,
                                ),
                              ],
                              const SizedBox(height: 28),
                              HotelReviewsSection(
                                reviews: reviews,
                                propertyId: propertyId,
                              ),
                              if (!_isOwner && _owner != null) ...[
                                const SizedBox(height: 28),
                                _ListedBySection(
                                  theme: theme,
                                  owner: _owner!,
                                  propertyData: _propertyData,
                                ),
                              ],
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
                                      'Price'.tr,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _priceLabel(),
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            color: const Color(0xFF2FC1BE),
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _propertyType,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                                ?.withValues(alpha: 0.66),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 22),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton.icon(
                                        onPressed: _isOwner
                                            ? null
                                            : () {
                                                Get.to(
                                                  () => BookingSummaryScreen(
                                                    bookingType: 'property',
                                                    propertyData: _propertyData,
                                                  ),
                                                );
                                              },
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
                                        icon: const Icon(
                                          Icons.calendar_today_outlined,
                                        ),
                                        label: Text('Schedule Visit'.tr),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Buyer tools'.tr,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Review features, neighborhood signals, investment analysis, and owner contact before scheduling.'
                                          .tr,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(height: 1.45),
                                    ),
                                  ],
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
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HotelImageCarousel(
                imageUrls: _imageUrls.isNotEmpty ? _imageUrls : null,
                propertyId: _propertyData['id'] as int?,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _PropertyHeaderInfo(
                      theme: theme,
                      title: _title,
                      address: _address,
                    ),
                    const SizedBox(height: 18),
                    _PropertyARExperienceSection(theme),
                    const SizedBox(height: 24),
                    _PropertyFeaturesSection(
                      theme: theme,
                      bedrooms: _rooms,
                      bathrooms: _bathrooms,
                      area: _area,
                      type: _propertyType,
                    ),
                    if (_amenities.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _PropertyAmenitiesSection(
                        theme: theme,
                        amenities: _amenities,
                      ),
                    ],
                    const SizedBox(height: 22),
                    _InvestmentAnalysisSection(
                      theme: theme,
                      propertyId: _propertyData['id'] as int?,
                    ),
                    if (_description.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _AboutSection(theme: theme, description: _description),
                    ],
                    if (_neighborhoodInsights.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _NeighborhoodInsightsSection(
                        theme: theme,
                        insights: _neighborhoodInsights,
                      ),
                    ],
                    const SizedBox(height: 22),
                    HotelReviewsSection(
                      reviews:
                          (_propertyData['reviews'] as List<dynamic>?) ?? [],
                      propertyId: _propertyData['id'] as int?,
                    ),
                    if (!_isOwner && _owner != null) ...[
                      const SizedBox(height: 22),
                      _ListedBySection(
                        theme: theme,
                        owner: _owner!,
                        propertyData: _propertyData,
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _isOwner
          ? Obx(
              () => MainBottomBar(
                currentIndex: controller.bottomIndex.value,
                isPropertySelected: true,
                onTap: (index) {
                  controller.categoryIndex.value = 1;
                  controller.bottomIndex.value = index;
                  Get.offAll(() => const MainScreen());
                },
              ),
            )
          : _BottomBar(theme, _propertyData),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Child Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PropertyHeaderInfo extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String address;

  const _PropertyHeaderInfo({
    required this.theme,
    required this.title,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1D2330),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Superb'.tr,
                    style: TextStyle(
                      color: Color(0xFF2FC1BE),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (address.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.near_me,
                      size: 16,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white70
                          : const Color(0xFF9AA0AF),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white70
                              : const Color(0xFF9AA0AF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF2FC1BE).withValues(alpha: 0.2)
                : const Color(0xFFDDF4F4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF2FC1BE).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFFFB300), size: 18),
              const SizedBox(width: 4),
              Text(
                '4.8'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Color(0xFF1D2330),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PropertyARExperienceSection extends StatelessWidget {
  final ThemeData theme;
  const _PropertyARExperienceSection(this.theme);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2FC1BE).withValues(alpha: 0.1)
            : const Color(0x292FC1BE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2FC1BE), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF2FC1BE),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/ai.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Experience in AR'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF1D2330),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Take a closer property in augmented reality'.tr,
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white70
                            : const Color(0xFF1D2330),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2FC1BE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Start Tour'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyFeaturesSection extends StatelessWidget {
  final ThemeData theme;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final String type;

  const _PropertyFeaturesSection({
    required this.theme,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Features'.tr,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1D2330),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _FeatureTile(
              iconPath: 'assets/bedroom.svg',
              label: '$bedrooms Bedroom${bedrooms != 1 ? 's' : ''}',
              theme: theme,
            ),
            _FeatureTile(
              iconPath: 'assets/bathroom.svg',
              label: '$bathrooms Bathroom${bathrooms != 1 ? 's' : ''}',
              theme: theme,
            ),
            _FeatureTile(
              iconPath: 'assets/sqft.svg',
              label: '${area.toStringAsFixed(0)} sqft',
              theme: theme,
            ),
            _FeatureTile(
              iconPath: 'assets/vila.svg',
              label: type,
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String iconPath;
  final String label;
  final ThemeData theme;

  const _FeatureTile({
    required this.iconPath,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF2FC1BE).withValues(alpha: 0.1)
                : const Color(0x292FC1BE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2FC1BE), width: 1.5),
          ),
          child: Center(
            child: SvgPicture.asset(
              iconPath,
              width: 26,
              height: 26,
              colorFilter: ColorFilter.mode(
                theme.brightness == Brightness.dark
                    ? const Color(0xFF2FC1BE)
                    : const Color(0xFF1B8785),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? Colors.white70
                  : const Color(0xFF9AA0AF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PropertyAmenitiesSection extends StatelessWidget {
  final ThemeData theme;
  final List<String> amenities;

  const _PropertyAmenitiesSection({
    required this.theme,
    required this.amenities,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities'.tr,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1D2330),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: amenities
              .map(
                (a) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2FC1BE),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    a,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _InvestmentAnalysisSection extends StatefulWidget {
  final ThemeData theme;
  final int? propertyId;

  const _InvestmentAnalysisSection({required this.theme, this.propertyId});

  @override
  State<_InvestmentAnalysisSection> createState() =>
      _InvestmentAnalysisSectionState();
}

class _InvestmentAnalysisSectionState
    extends State<_InvestmentAnalysisSection> {
  bool _isLoading = true;
  String _projectedROI = '+5.0%';
  String _priceTrend = '↑3% YoY';
  String _source = 'loading';

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

  Future<void> _fetchAnalysis() async {
    if (widget.propertyId == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final data = await ListingService().getPropertyAnalysis(
        widget.propertyId!,
      );
      if (mounted) {
        setState(() {
          _projectedROI = data['projectedROI'] ?? '+5.0%';
          _priceTrend = data['priceTrend'] ?? '↑3% YoY';
          _source = data['source'] ?? 'unknown';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1D2330);
    final subColor = isDark ? Colors.white70 : const Color(0xFF1D2330);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF21C96A).withValues(alpha: 0.15)
            : const Color(0xFFE6FBEA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF21C96A).withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF21C96A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/ai.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Investment Analysis'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLoading
                          ? 'Analyzing property data...'
                          : _source == 'gemini-ai'
                          ? 'Powered by Gemini AI'
                          : 'Based on market trends and location data',
                      style: TextStyle(
                        color: subColor,
                        fontSize: 13,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF21C96A),
                  ),
                ),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Projected ROI',
                    value: _projectedROI,
                    color: const Color(0xFF21C96A),
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Price Trend',
                    value: _priceTrend,
                    color: const Color(0xFF21C96A),
                    theme: theme,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: theme.brightness == Brightness.dark
                ? Colors.white70
                : const Color(0xFF9AA0AF),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  final ThemeData theme;
  final String description;

  const _AboutSection({required this.theme, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About This Property'.tr,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1D2330),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: TextStyle(
            fontSize: 15,
            color: theme.brightness == Brightness.dark
                ? Colors.white70
                : const Color(0xFF9AA0AF),
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _NeighborhoodInsightsSection extends StatelessWidget {
  final ThemeData theme;
  final List<String> insights;

  const _NeighborhoodInsightsSection({
    required this.theme,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Neighborhood Insights'.tr,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1D2330),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF2FC1BE).withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Column(
            children: List.generate(insights.length, (index) {
              return Column(
                children: [
                  if (index > 0) const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF2FC1BE).withValues(alpha: 0.15)
                              : const Color(0xFFE8F7F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            PropertyDetailScreen._insightIcon(insights[index]),
                            size: 18,
                            color: const Color(0xFF2FC1BE),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          insights[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : const Color(0xFF1D2330),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.check_circle,
                        size: 20,
                        color: Color(0xFF2FC1BE),
                      ),
                    ],
                  ),
                  if (index < insights.length - 1) ...[
                    const SizedBox(height: 16),
                    Divider(
                      height: 1,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white10
                          : const Color(0xFFE5E7EB),
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ListedBySection extends StatelessWidget {
  final ThemeData theme;
  final Map<String, dynamic> owner;
  final Map<String, dynamic>? propertyData;

  const _ListedBySection({
    required this.theme,
    required this.owner,
    this.propertyData,
  });

  @override
  Widget build(BuildContext context) {
    final ownerName =
        owner['fullName'] ?? owner['firstName'] ?? 'Property Owner';
    final ownerAvatar = owner['avatar'] as String?;
    final avatarUrl = (ownerAvatar != null && ownerAvatar.isNotEmpty)
        ? ListingService.avatarImageUrl(ownerAvatar)
        : null;

    // Get initials from name
    String getInitials(String name) {
      final parts = name.trim().split(' ');
      if (parts.isEmpty) return 'PO';
      if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
      return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
          .toUpperCase();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Listed By'.tr,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1D2330),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2FC1BE), width: 1.5),
          ),
          child: Row(
            children: [
              // Avatar with initials or image
              avatarUrl != null
                  ? CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(avatarUrl),
                      backgroundColor: const Color(0xFFE8F7F7),
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF2FC1BE).withOpacity(0.2)
                            : const Color(0xFFE8F7F7),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          getInitials(ownerName),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF2FC1BE)
                                : const Color(0xFF1D2330),
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(width: 14),
              // Name and rating section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ownerName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF1D2330),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFB300),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.9'.tr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : const Color(0xFF1D2330),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(127 reviews)'.tr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white70
                                : const Color(0xFF9AA0AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Verified badge and Contact button column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Verified badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/verified.svg',
                          width: 12,
                          height: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Contact button
                  GestureDetector(
                    onTap: () {
                      final ownerId = owner['id'] as int?;
                      final ownerName =
                          owner['fullName'] ??
                          owner['firstName'] ??
                          'Property Owner';
                      final ownerAvatar = owner['avatar'] as String?;
                      final avatarUrl =
                          (ownerAvatar != null && ownerAvatar.isNotEmpty)
                          ? ListingService.avatarImageUrl(ownerAvatar)
                          : '';

                      if (ownerId != null) {
                        final chatItem = ChatItem(
                          peerUserId: ownerId,
                          name: ownerName,
                          message: '',
                          date: '',
                          avatarUrl: avatarUrl,
                          status: MessageStatus.none,
                          unreadCount: 0,
                          propertyData: propertyData,
                          propertyId: propertyData?['id'] as int?,
                        );
                        Get.to(() => ChatDetailScreen(), arguments: chatItem);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white24
                              : const Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 16,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : const Color(0xFF1D2330),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Contact'.tr,
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF1D2330),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final ThemeData theme;
  final Map<String, dynamic>? propertyData;

  const _BottomBar(this.theme, this.propertyData);

  @override
  Widget build(BuildContext context) {
    final price = propertyData?['price'];
    String priceStr = '\$1.8 M';

    if (price != null) {
      double priceValue = 0;
      if (price is num) {
        priceValue = price.toDouble();
      } else if (price is String) {
        priceValue = double.tryParse(price) ?? 0;
      }

      if (priceValue > 0) {
        final profileController = Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController());
        final userCurrency = profileController.userCurrency.value;
        final convertedPrice = CurrencyService.convertFromUSD(
          priceValue,
          userCurrency,
        );

        if (convertedPrice >= 1000000) {
          priceStr =
              CurrencyService.formatAmount(
                convertedPrice / 1000000,
                userCurrency,
                decimals: 1,
              ) +
              ' M';
        } else if (convertedPrice >= 1000) {
          priceStr =
              CurrencyService.formatAmount(
                convertedPrice / 1000,
                userCurrency,
                decimals: 0,
              ) +
              ' K';
        } else {
          priceStr = CurrencyService.formatAmount(
            convertedPrice,
            userCurrency,
            decimals: 0,
          );
        }
      }
    }

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
                  'Price'.tr,
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
                  priceStr,
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
                onPressed: () {
                  Get.to(
                    () => BookingSummaryScreen(
                      bookingType: 'property',
                      propertyData: propertyData,
                    ),
                  );
                },
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
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Schedule Visit'.tr,
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

class _DesktopPropertyHeroCircleButton extends StatelessWidget {
  const _DesktopPropertyHeroCircleButton({
    required this.icon,
    required this.onTap,
  });

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

class _DesktopPropertyHeroHeartButton extends StatelessWidget {
  const _DesktopPropertyHeroHeartButton({
    required this.isFilled,
    required this.onTap,
  });

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
