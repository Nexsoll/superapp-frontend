import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/hotel_card.dart';
import '../widgets/main_bottom_bar.dart';
import '../controllers/main_screen_controller.dart';
import '../services/listing_service.dart';
import 'main_screen.dart';
import 'hotel_detail_screen.dart';

class HotelSearchScreen extends StatefulWidget {
  final String? searchQuery;

  const HotelSearchScreen({super.key, this.searchQuery});

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final MainScreenController controller;
  List<Map<String, dynamic>> _filteredHotels = [];
  bool _hasSearched = false;
  bool _showSearchBar = true;

  // Filter state
  Map<String, dynamic>? _activeFilters;

  // Sort state
  String _sortBy = 'recommended';

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<MainScreenController>()
        ? Get.find<MainScreenController>()
        : Get.put(MainScreenController());

    if (controller.allHotelsData.isEmpty) {
      controller.fetchFeaturedHotels();
    }

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      _searchController.text = widget.searchQuery!;
      _performSearch(widget.searchQuery!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = filters;
    });
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> results = List.from(controller.allHotelsData);

    // Apply search filter
    if (_hasSearched && _searchController.text.isNotEmpty) {
      final queryLower = _searchController.text.toLowerCase();
      results = results.where((hotel) {
        final title = (hotel['title'] ?? '').toString().toLowerCase();
        final address = (hotel['address'] ?? '').toString().toLowerCase();
        return title.contains(queryLower) || address.contains(queryLower);
      }).toList();
    }

    // Apply amenities filter
    if (_activeFilters != null &&
        _activeFilters!['selectedAmenities'] != null) {
      final selectedAmenities =
          _activeFilters!['selectedAmenities'] as List<String>;
      if (selectedAmenities.isNotEmpty) {
        results = results.where((hotel) {
          final hotelAmenities =
              (hotel['amenities'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          return selectedAmenities.any((a) => hotelAmenities.contains(a));
        }).toList();
      }
    }

    // Apply sorting
    results = _sortHotels(results);

    setState(() {
      _filteredHotels = results;
    });
  }

  List<Map<String, dynamic>> _sortHotels(List<Map<String, dynamic>> hotels) {
    final sorted = List<Map<String, dynamic>>.from(hotels);
    switch (_sortBy) {
      case 'price_low':
        sorted.sort((a, b) {
          final priceA = (a['rooms'] as List<dynamic>?)?.isNotEmpty == true
              ? (a['rooms'][0]['price'] ?? 0)
              : 0;
          final priceB = (b['rooms'] as List<dynamic>?)?.isNotEmpty == true
              ? (b['rooms'][0]['price'] ?? 0)
              : 0;
          return (priceA as num).compareTo(priceB as num);
        });
        break;
      case 'price_high':
        sorted.sort((a, b) {
          final priceA = (a['rooms'] as List<dynamic>?)?.isNotEmpty == true
              ? (a['rooms'][0]['price'] ?? 0)
              : 0;
          final priceB = (b['rooms'] as List<dynamic>?)?.isNotEmpty == true
              ? (b['rooms'][0]['price'] ?? 0)
              : 0;
          return (priceB as num).compareTo(priceA as num);
        });
        break;
      case 'rating':
        sorted.sort((a, b) {
          final ratingA = controller.getRating(a);
          final ratingB = controller.getRating(b);
          return ratingB.compareTo(ratingA);
        });
        break;
      default:
        break;
    }
    return sorted;
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'price_low':
        return 'Price: Low to High';
      case 'price_high':
        return 'Price: High to Low';
      case 'rating':
        return 'Rating';
      default:
        return 'Recommended';
    }
  }

  void _performSearch(String query) {
    final queryLower = query.toLowerCase();

    final results = controller.allHotelsData.where((hotel) {
      final title = (hotel['title'] ?? '').toString().toLowerCase();
      final address = (hotel['address'] ?? '').toString().toLowerCase();
      return title.contains(queryLower) || address.contains(queryLower);
    }).toList();

    setState(() {
      _filteredHotels = results;
      _hasSearched = true;
    });
    _applyFiltersAndSort();
  }

  Widget _buildFilteredHotelList() {
    if (_filteredHotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hotels found'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term'.tr,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredHotels.length,
      itemBuilder: (context, index) {
        final hotel = _filteredHotels[index];
        final title = hotel['title'] ?? 'Untitled';
        final address = hotel['address'] ?? '';
        final rating = controller.getRating(hotel);
        final hotelId = hotel['id'] as int;
        final images = hotel['images'] as List<dynamic>?;
        final imageUrl = (images != null && images.isNotEmpty)
            ? ListingService.hotelImageUrl(hotelId, 0)
            : null;

        // Get minimum room price
        final rooms = hotel['rooms'] as List<dynamic>?;
        double minPrice = 0;
        if (rooms != null && rooms.isNotEmpty) {
          for (final room in rooms) {
            final priceData = room['price'];
            final price = priceData is num
                ? priceData.toDouble()
                : double.tryParse(priceData?.toString() ?? '0') ?? 0;
            if (minPrice == 0 || price < minPrice) {
              minPrice = price;
            }
          }
        }

        return HotelCard(
          title: title,
          location: address,
          imagePath: imageUrl ?? 'assets/hotel1.png',
          rating: rating,
          price: minPrice.toInt(),
          amenities: const [],
          onTap: () => Get.to(() => HotelDetailScreen(hotelData: hotel)),
        );
      },
    );
  }

  Widget _buildAllHotelsList(ThemeData theme) {
    return Obx(() {
      if (controller.isFetchingHotels.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2FC1BE)),
        );
      }

      final hotels = controller.allHotelsData;
      if (hotels.isEmpty) {
        return Center(
          child: Text(
            'No hotels found'.tr,
            style: TextStyle(
              fontSize: 16,
              color: theme.brightness == Brightness.dark
                  ? Colors.white70
                  : const Color(0xFF9AA0AF),
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: hotels.length,
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

          // Get minimum room price
          final rooms = hotel['rooms'] as List<dynamic>?;
          double minPrice = 0;
          if (rooms != null && rooms.isNotEmpty) {
            for (final room in rooms) {
              final priceData = room['price'];
              final price = priceData is num
                  ? priceData.toDouble()
                  : double.tryParse(priceData?.toString() ?? '0') ?? 0;
              if (minPrice == 0 || price < minPrice) {
                minPrice = price;
              }
            }
          }

          return HotelCard(
            title: title,
            location: address,
            imagePath: imageUrl ?? 'assets/hotel1.png',
            rating: rating,
            price: minPrice.toInt(),
            amenities: const [],
            onTap: () => Get.to(() => HotelDetailScreen(hotelData: hotel)),
          );
        },
      );
    });
  }

  Widget _buildDesktopHotelsGrid({
    required ThemeData theme,
    required List<Map<String, dynamic>> hotels,
  }) {
    if (hotels.isEmpty) {
      return Center(
        child: Text(
          'No hotels found'.tr,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.textTheme.titleMedium?.color?.withValues(alpha: 0.64),
          ),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 390,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 1.10,
      ),
      itemCount: hotels.length,
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
        final rooms = hotel['rooms'] as List<dynamic>?;
        double minPrice = 0;
        if (rooms != null && rooms.isNotEmpty) {
          for (final room in rooms) {
            final priceData = room['price'];
            final price = priceData is num
                ? priceData.toDouble()
                : double.tryParse(priceData?.toString() ?? '0') ?? 0;
            if (minPrice == 0 || price < minPrice) {
              minPrice = price;
            }
          }
        }

        return HotelCard(
          title: title,
          location: address,
          imagePath: imageUrl ?? 'assets/hotel1.png',
          rating: rating,
          price: minPrice.toInt(),
          amenities: const [],
          onTap: () => Get.to(() => HotelDetailScreen(hotelData: hotel)),
        );
      },
    );
  }

  Widget _desktopSortMenu(ThemeData theme) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() => _sortBy = value);
        _applyFiltersAndSort();
      },
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              _getSortLabel().tr,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'recommended', child: Text('Recommended'.tr)),
        PopupMenuItem(value: 'price_low', child: Text('Price: Low to High'.tr)),
        PopupMenuItem(
          value: 'price_high',
          child: Text('Price: High to Low'.tr),
        ),
        PopupMenuItem(value: 'rating', child: Text('Rating'.tr)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _showSearchBar = widget.searchQuery == null || widget.searchQuery!.isEmpty;
    final isDesktopWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 900;

    if (isDesktopWeb) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 30),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hotels'.tr,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: const Color(0xFF2FC1BE),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Explore hotels curated for your stay'.tr,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.textTheme.bodyLarge?.color
                                  ?.withValues(alpha: 0.66),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                _hasSearched = false;
                                _filteredHotels = [];
                              });
                            }
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty) _performSearch(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search hotels...'.tr,
                            prefixIcon: const Icon(Icons.search_rounded),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) =>
                                FilterBottomSheet(onApply: _applyFilters),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2FC1BE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.tune_rounded),
                        label: Text('Filters'.tr),
                      ),
                    ),
                    const SizedBox(width: 14),
                    _desktopSortMenu(theme),
                  ],
                ),
                const SizedBox(height: 22),
                Obx(() {
                  final allHotelsCount = controller.allHotelsData.length;
                  final foundCount = _hasSearched
                      ? _filteredHotels.length
                      : allHotelsCount;
                  return Text(
                    '$foundCount Hotels Found'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (controller.isFetchingHotels.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2FC1BE),
                        ),
                      );
                    }
                    final hotels = _hasSearched
                        ? _filteredHotels
                        : _sortHotels(
                            List<Map<String, dynamic>>.from(
                              controller.allHotelsData,
                            ),
                          );
                    return _buildDesktopHotelsGrid(
                      theme: theme,
                      hotels: hotels,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF2FC1BE),
                      size: 28,
                    ),
                  ),
                  Text(
                    'Hotels'.tr,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2FC1BE),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 56, right: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Explore hotels curated for your stay'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white70
                        : const Color(0xFF1D2330),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Search Bar & Filter - only show when no search query
            if (_showSearchBar) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white24
                          : const Color(0x9CBAB1B1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF9E9E9F),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                _hasSearched = false;
                                _filteredHotels = [];
                              });
                            }
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              _performSearch(value);
                            }
                          },
                          cursorColor: theme.colorScheme.primary,
                          selectionControls: materialTextSelectionControls,
                          decoration: InputDecoration(
                            hintText: 'Search hotels...'.tr,
                            hintStyle: TextStyle(
                              color: Color(0xFF9AA0AF),
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
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) =>
                                FilterBottomSheet(onApply: _applyFilters),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2FC1BE),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/filter.svg',
                              width: 18,
                              height: 18,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Results Info & Sort
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _hasSearched
                        ? '${_filteredHotels.length} Hotels Found'
                        : '${controller.allHotelsData.length} Hotels Found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF1D2330),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? theme.cardColor
                          : const Color(0xFFE8F1F1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2FC1BE),
                        width: 0.5,
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          _sortBy = value;
                        });
                        _applyFiltersAndSort();
                      },
                      offset: const Offset(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: theme.cardColor,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'sort by : ${_getSortLabel()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'recommended',
                          child: Text('Recommended'.tr),
                        ),
                        PopupMenuItem(
                          value: 'price_low',
                          child: Text('Price: Low to High'.tr),
                        ),
                        PopupMenuItem(
                          value: 'price_high',
                          child: Text('Price: High to Low'.tr),
                        ),
                        PopupMenuItem(
                          value: 'rating',
                          child: Text('Rating'.tr),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Hotel List
            Expanded(
              child: _hasSearched
                  ? _buildFilteredHotelList()
                  : _buildAllHotelsList(theme),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
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
