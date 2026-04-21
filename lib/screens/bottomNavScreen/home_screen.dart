import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';

import '../../controllers/main_screen_controller.dart';
import '../../controllers/profile_controller.dart';
import '../hotel_search_screen.dart';
import '../hotel_detail_screen.dart';
import '../property_detail_screen.dart';
import '../wishlist_screen.dart';
import '../property_search_screen.dart';
import '../my_listing_screen.dart';
import '../../services/listing_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainScreenController>();

    return SafeArea(
      child: Column(
        children: [
          const _MainHeader(),
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF2FC1BE),
              onRefresh: () async {
                final controller = Get.find<MainScreenController>();
                await Future.wait([
                  controller.fetchFeaturedHotels(),
                  controller.fetchFeaturedProperties(),
                ]);
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _LocationDropdown(),
                    const SizedBox(height: 14),
                    const _RecommendationCard(),
                    const SizedBox(height: 18),
                    Obx(() {
                      final isProperty = controller.categoryIndex.value == 1;
                      return _SectionHeader(
                        title: isProperty
                            ? 'Featured Properties'
                            : 'Featured Hotels',
                        actionText: 'See All',
                        onActionTap: () {
                          if (controller.categoryIndex.value == 1) {
                            Get.to(() => const PropertySearchScreen());
                          } else {
                            Get.to(() => const HotelSearchScreen());
                          }
                        },
                      );
                    }),
                    const SizedBox(height: 10),
                    const _FeaturedHotelsList(),
                    Obx(() {
                      if (controller.categoryIndex.value == 1) {
                        return Column(
                          children: const [
                            SizedBox(height: 18),
                            _PropertyQuickActions(),
                          ],
                        );
                      }

                      if (controller.categoryIndex.value == 0) {
                        return Column(
                          children: const [
                            SizedBox(height: 18),
                            _HotelQuickActions(),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    }),
                    const SizedBox(height: 18),
                    const _AnnouncementCard(),
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

class _MainHeader extends StatelessWidget {
  const _MainHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<MainScreenController>();
    final profileController = Get.find<ProfileController>();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.02, 0.49, 1.0],
          colors: [Color(0xFF38CAC7), Color(0xFF27B9B6), Color(0xFF119C99)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(44),
          bottomRight: Radius.circular(44),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Obx(() {
                final photo = profileController.photoUrl.value;
                return Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF2B705),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: photo.isNotEmpty
                        ? Image.network(
                            photo,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/avatar.png',
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/avatar.png',
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                          ),
                  ),
                );
              }),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        height: 1.05,
                      ),
                    ),
                    Obx(
                      () => Text(
                        'Hello ${profileController.displayName}!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 10),
                  Stack(
                    children: [
                      _HeaderImageIconButton(
                        imagePath: 'assets/bell.png',
                        onTap: controller.goToNotifiction,
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/uit_wallet.png',
                          width: 16,
                          height: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Obx(
                          () => Text(
                            '\$${profileController.balance.value.toStringAsFixed(2)}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
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
          const SizedBox(height: 30),
          Obx(
            () => _CategoryToggle(
              selectedIndex: controller.categoryIndex.value,
              onChanged: controller.onCategoryTap,
            ),
          ),
          const SizedBox(height: 12),
          const _SearchBar(),
        ],
      ),
    );
  }
}

class _HeaderImageIconButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _HeaderImageIconButton({required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            width: 20,
            height: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _CategoryToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _CategoryToggle({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFADD4E8).withOpacity(0.57),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CategoryChip(
              selected: selectedIndex == 0,
              iconAssetPath: 'assets/hotel-header.png',
              label: 'Hotels',
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CategoryChip(
              selected: selectedIndex == 1,
              iconAssetPath: 'assets/property-header.png',
              label: 'Properties',
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final bool selected;
  final String iconAssetPath;
  final String label;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.selected,
    required this.iconAssetPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconAssetPath,
              width: 22,
              height: 22,
              color: selected ? theme.colorScheme.primary : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 18,
                color: selected ? theme.colorScheme.primary : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<MainScreenController>();

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF9E9E9F), size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(
              () => TextField(
                onSubmitted: (value) {
                  if (controller.categoryIndex.value == 1) {
                    Get.to(() => PropertySearchScreen(searchQuery: value));
                  } else {
                    Get.to(() => HotelSearchScreen(searchQuery: value));
                  }
                },
                cursorColor: theme.colorScheme.primary,
                selectionControls: materialTextSelectionControls,
                decoration: InputDecoration(
                  hintText: controller.categoryIndex.value == 1
                      ? 'Search properties...'
                      : 'Search hotels...',
                  hintStyle: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF9AA0AF),
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/search-location.png',
                  width: 18,
                  height: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationDropdown extends StatelessWidget {
  const _LocationDropdown();

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    final theme = Theme.of(context);

    final locations = [
      'Montenegro',
      'Serbia',
      'Bosnia',
      'Croatia',
      'Albania',
      'Slovenia',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: profileController.selectedLocation.value,
            isExpanded: true,
            icon: Icon(
              Icons.location_on_rounded,
              color: theme.colorScheme.primary,
            ),
            items: locations.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                profileController.saveUserData(location: newValue);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatefulWidget {
  const _RecommendationCard();

  @override
  State<_RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<_RecommendationCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<MainScreenController>();
      controller.fetchAiRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<MainScreenController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.cardColor
            : const Color(0xFFDDF4F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.55),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Image.asset(
                'assets/ai.png',
                width: 16,
                height: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Recommendations Ready'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF747477),
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() {
                  final count = controller.aiRecommendationCount.value;
                  final isLoading = controller.isFetchingRecommendations.value;
                  if (isLoading) {
                    return Text(
                      'Loading recommendations...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.7)
                            : const Color(0xFF747477),
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    );
                  }
                  if (count == 0) {
                    return Text(
                      'No recommendations found.\nPull to refresh.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.7)
                            : const Color(0xFF747477),
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    );
                  }
                  return Text(
                    'We found $count perfect matches based\non your preferences'
                        .tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xFF747477),
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  );
                }),
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () async {
                      final ctrl = Get.find<MainScreenController>();
                      // Always fetch fresh recommendations based on current category
                      await ctrl.fetchAiRecommendations();
                      if (ctrl.aiRecommendations.isNotEmpty) {
                        _showRecommendationsSheet(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'View Suggestions'.tr,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRecommendationsSheet(BuildContext context) {
    final controller = Get.find<MainScreenController>();
    final recommendations = controller.aiRecommendations;
    if (recommendations.isEmpty) return;

    final theme = Theme.of(context);
    final isProperty = controller.categoryIndex.value == 1;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isProperty
                  ? 'AI Property Recommendations'
                  : 'AI Hotel Recommendations',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${controller.aiRecommendationCount.value} properties found',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: recommendations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = recommendations[index];
                  final title = item['title'] ?? item['name'] ?? 'Unknown';
                  final address = item['address'] ?? item['location'] ?? '';
                  final price = item['price'] ?? 0;
                  final id = item['id'] as int?;

                  // Use ListingService to get proper proxied image URL
                  final String? imageUrl = (id != null && !isProperty)
                      ? ListingService.hotelImageUrl(id, 0)
                      : (id != null && isProperty)
                      ? ListingService.propertyImageUrl(id, 0)
                      : null;

                  return InkWell(
                    onTap: () {
                      Get.back();
                      if (isProperty) {
                        Get.to(() => PropertyDetailScreen(propertyData: item));
                      } else {
                        Get.to(() => HotelDetailScreen(hotelData: item));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: imageUrl != null
                                ? Image.network(
                                    imageUrl.toString(),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image),
                                    ),
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  address,
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$$price',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onActionTap;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.textTheme.titleMedium?.color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        InkWell(
          onTap: onActionTap,
          child: Text(
            actionText,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedHotelsList extends StatelessWidget {
  const _FeaturedHotelsList();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainScreenController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 270,
      child: Obx(() {
        final isProperty = controller.categoryIndex.value == 1;

        if (isProperty) {
          // Still loading
          if (controller.isFetchingProperties.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2FC1BE)),
            );
          }

          // Loaded but empty
          final properties = controller.featuredPropertiesData;
          if (properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 48,
                    color: isDark ? Colors.white38 : Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No featured properties yet'.tr,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: properties.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final property = properties[index];
              final title = property['title'] ?? 'Untitled';
              final address = property['address'] ?? '';
              final rating = controller.getRating(property);
              final propertyId = property['id'] as int;
              final images = property['images'] as List<dynamic>?;
              final imageUrl = (images != null && images.isNotEmpty)
                  ? ListingService.propertyImageUrl(propertyId, 0)
                  : null;
              final price = controller.getPropertyPrice(property);
              final tag = controller.getPropertyTag(property);

              return _FeaturedHotelCard(
                title: title,
                location: address,
                rating: rating,
                price: price.isNotEmpty ? price : null,
                tag: tag.isNotEmpty ? tag : null,
                imageUrl: imageUrl,
                onTap: () =>
                    Get.to(() => PropertyDetailScreen(propertyData: property)),
              );
            },
          );
        }

        // Still loading hotels
        if (controller.isFetchingHotels.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2FC1BE)),
          );
        }

        // Loaded but empty
        final hotels = controller.featuredHotelsData;
        if (hotels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hotel_outlined,
                  size: 48,
                  color: isDark ? Colors.white38 : Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No featured hotels yet'.tr,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: hotels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final hotel = hotels[index];
            final title = hotel['title'] ?? 'Untitled';
            final address = hotel['address'] ?? '';
            final rating = controller.getRating(hotel);
            final hotelId = hotel['id'] as int;
            final images = hotel['images'] as List<dynamic>?;
            final imageUrl = (images != null && images.isNotEmpty)
                ? ListingService.hotelImageUrl(hotelId, 0)
                : null;

            return _FeaturedHotelCard(
              title: title,
              location: address,
              rating: rating,
              imageUrl: imageUrl,
              onTap: () => Get.to(() => HotelDetailScreen(hotelData: hotel)),
            );
          },
        );
      }),
    );
  }
}

class _FeaturedHotelCard extends StatelessWidget {
  final String title;
  final String location;
  final double rating;
  final String? imageUrl;
  final VoidCallback onTap;
  final String? price;
  final String? tag;

  const _FeaturedHotelCard({
    required this.title,
    required this.location,
    required this.rating,
    this.imageUrl,
    required this.onTap,
    this.price,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 240,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16000000),
                    blurRadius: 14,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    Container(
                      color: const Color(0xFF0F6CCF),
                      alignment: Alignment.center,
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    Positioned(
                      left: 14,
                      top: 14,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFFFC107),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: const Color(0xFF2FC1BE).withOpacity(0.30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              if (price != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  price!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: onTap,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2FC1BE),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 14,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.north_east_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (tag != null)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PropertyQuickActions extends StatelessWidget {
  const _PropertyQuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.home_outlined,
            title: 'My Properties',
            subtitle: 'Manage Listings',
            color: const Color(0xFF2FC1BE),
            onTap: () => Get.to(() => const MyListingScreen()),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.favorite_border_rounded,
            title: 'Wishlist',
            subtitle: 'Saved properties',
            color: const Color(0xFF2FC1BE),
            onTap: () => Get.to(() => const WishlistScreen(initialTab: 1)),
          ),
        ),
      ],
    );
  }
}

class _HotelQuickActions extends StatelessWidget {
  const _HotelQuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.hotel_outlined,
            title: 'My Hotels',
            subtitle: 'Manage Listings',
            color: const Color(0xFF2FC1BE),
            onTap: () => Get.to(
              () => const MyListingScreen(category: ListingCategory.hotel),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.favorite_border_rounded,
            title: 'Wishlist',
            subtitle: 'Saved hotels',
            color: const Color(0xFF2FC1BE),
            onTap: () => Get.to(() => const WishlistScreen(initialTab: 0)),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFDDF4F4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2FC1BE).withOpacity(0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2FC1BE).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2330),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF747477),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<MainScreenController>();

    return Obx(() {
      final isProperty = controller.categoryIndex.value == 1;
      final announcement = isProperty
        ? controller.propertyAnnouncement
        : controller.announcement;

      final recommendation = controller.investmentRecommendation;
      final isLoadingInvestment =
        isProperty &&
        controller.isFetchingInvestmentAnnouncement.value &&
        recommendation == null;

      final title = isProperty
        ? controller.investmentAnnouncementTitle
        : announcement.title;

      final description = isProperty
        ? (isLoadingInvestment
          ? 'Analyzing today market with Gemini AI...'
          : controller.investmentAnnouncementDescription)
        : announcement.description;

      final buttonText = isProperty
        ? controller.investmentAnnouncementButtonText
        : announcement.buttonText;

      final chance = (recommendation?['investmentChancePercent'] as num?)
        ?.round();
      final roi = (recommendation?['expectedRoiPercent'] as num?)?.toDouble();
      final profitUsd =
        (recommendation?['estimatedProfit12MonthsUsd'] as num?)?.toDouble();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isProperty
                ? const [Color(0xFF21C96A), Color(0xFF0FAE5B)]
                : const [Color(0xFFFF7A2F), Color(0xFFFF4D6D)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color:
                  (isProperty
                          ? const Color(0xFF21C96A)
                          : const Color(0xFFFF7A2F))
                      .withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
            if (isProperty &&
                chance != null &&
                roi != null &&
                profitUsd != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Chance: $chance%  •  Profit: ${controller.formatProjectedProfit(profitUsd)}  •  ROI: ${roi.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isProperty) {
                    final propertyData = controller.recommendedInvestmentProperty;
                    if (propertyData != null) {
                      Get.to(() => PropertyDetailScreen(propertyData: propertyData));
                    } else {
                      Get.to(() => const PropertySearchScreen());
                    }
                    return;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2FC1BE),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
