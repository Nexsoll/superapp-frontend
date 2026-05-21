import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/property_filter_bottom_sheet.dart';
import '../widgets/property_card.dart';
import '../widgets/main_bottom_bar.dart';
import '../controllers/main_screen_controller.dart';
import '../services/listing_service.dart';
import 'property_detail_screen.dart';
import 'main_screen.dart';

class PropertySearchScreen extends StatefulWidget {
  final String? searchQuery;

  const PropertySearchScreen({super.key, this.searchQuery});

  @override
  State<PropertySearchScreen> createState() => _PropertySearchScreenState();
}

class _PropertySearchScreenState extends State<PropertySearchScreen> {
  int _selectedType = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredProperties = [];
  bool _hasSearched = false;
  late final MainScreenController controller;
  bool _showSearchBar = true;

  // Filter state
  Map<String, dynamic>? _activeFilters;

  // Sort state
  String _sortBy = 'recommended';

  List<Map<String, dynamic>> _filterByListingType(
    List<Map<String, dynamic>> input,
  ) {
    final desired = _selectedType == 1 ? 'FOR_RENT' : 'FOR_SALE';
    return input.where((property) {
      final raw = property['listingType'];
      final listingType = raw?.toString();
      if (listingType == null || listingType.isEmpty) {
        return true;
      }
      return listingType == desired;
    }).toList();
  }

  Widget _buildCountRow({required ThemeData theme, required int count}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count Properties Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1D2330),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? theme.cardColor
                  : const Color(0xFFE8F1F1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2FC1BE), width: 0.5),
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
                PopupMenuItem(value: 'rating', child: Text('Rating'.tr)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyList({
    required ThemeData theme,
    required MainScreenController controller,
    required List<Map<String, dynamic>> properties,
  }) {
    if (properties.isEmpty) {
      return Center(
        child: Text(
          'No properties found'.tr,
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
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        final title = property['title'] ?? 'Property';
        final address = property['address'] ?? '';
        final rating = controller.getRating(property);
        final price = controller.getPropertyPrice(property);
        final tag = controller.getPropertyTag(property);
        final propertyId = property['id'] as int;
        final images = property['images'] as List<dynamic>?;
        final imageUrl = (images != null && images.isNotEmpty)
            ? ListingService.propertyImageUrl(propertyId, 0)
            : null;

        return PropertyCard(
          title: title,
          location: address,
          imagePath: 'assets/hotel1.png',
          imageUrl: imageUrl,
          rating: rating,
          price: price.isNotEmpty ? price : '\$0',
          tag: tag.isNotEmpty ? tag : null,
          onTap: () =>
              Get.to(() => PropertyDetailScreen(propertyData: property)),
        );
      },
    );
  }

  Widget _buildDesktopPropertyGrid({
    required ThemeData theme,
    required MainScreenController controller,
    required List<Map<String, dynamic>> properties,
  }) {
    if (properties.isEmpty) {
      return Center(
        child: Text(
          'No properties found'.tr,
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
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        final title = property['title'] ?? 'Property';
        final address = property['address'] ?? '';
        final rating = controller.getRating(property);
        final price = controller.getPropertyPrice(property);
        final tag = controller.getPropertyTag(property);
        final propertyId = property['id'] as int;
        final images = property['images'] as List<dynamic>?;
        final imageUrl = (images != null && images.isNotEmpty)
            ? ListingService.propertyImageUrl(propertyId, 0)
            : null;

        return PropertyCard(
          title: title,
          location: address,
          imagePath: 'assets/property-header.png',
          imageUrl: imageUrl,
          rating: rating,
          price: price.isNotEmpty ? price : '\$0',
          tag: tag.isNotEmpty ? tag : null,
          onTap: () =>
              Get.to(() => PropertyDetailScreen(propertyData: property)),
        );
      },
    );
  }

  Widget _desktopListingTypeToggle(ThemeData theme) {
    Widget option(String label, int value) {
      final selected = _selectedType == value;
      return Expanded(
        child: InkWell(
          onTap: () {
            setState(() => _selectedType = value);
            _applyFiltersAndSort();
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? theme.cardColor : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              label.tr,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected
                    ? const Color(0xFF2FC1BE)
                    : theme.textTheme.labelLarge?.color?.withValues(
                        alpha: 0.58,
                      ),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 300,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2C2C2E)
            : const Color(0xFFE8F1F1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(children: [option('Buy', 0), option('Rent', 1)]),
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
  void initState() {
    super.initState();

    controller = Get.isRegistered<MainScreenController>()
        ? Get.find<MainScreenController>()
        : Get.put(MainScreenController());

    if (controller.allPropertiesData.isEmpty) {
      controller.fetchFeaturedProperties().then((_) {
        if (mounted &&
            widget.searchQuery != null &&
            widget.searchQuery!.isNotEmpty) {
          _performSearch(widget.searchQuery!);
        }
      });
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

  bool _matchesSearchQuery(
    Map<String, dynamic> property,
    String queryLower,
  ) {
    final title = (property['title'] ?? '').toString().toLowerCase();
    final address = (property['address'] ?? '').toString().toLowerCase();
    final city = (property['city'] ?? '').toString().toLowerCase();
    final country = (property['country'] ?? '').toString().toLowerCase();
    final location = (property['location'] ?? '').toString().toLowerCase();

    return title.contains(queryLower) ||
        address.contains(queryLower) ||
        city.contains(queryLower) ||
        country.contains(queryLower) ||
        location.contains(queryLower);
  }

  void _performSearch(String query) {
    final queryLower = query.toLowerCase();

    final results = controller.allPropertiesData
        .where((property) => _matchesSearchQuery(property, queryLower))
        .toList();

    setState(() {
      _filteredProperties = results;
      _hasSearched = true;
    });
    _applyFiltersAndSort();
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = filters;
    });
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> results = List.from(
      controller.allPropertiesData,
    );

    // Apply search filter
    if (_hasSearched && _searchController.text.isNotEmpty) {
      final queryLower = _searchController.text.toLowerCase();
      results = results
          .where((property) => _matchesSearchQuery(property, queryLower))
          .toList();
    }

    // Apply listing type filter (Buy/Rent tabs)
    results = _filterByListingType(results);

    // Apply property type filter
    if (_activeFilters != null &&
        _activeFilters!['propertyTypeIndex'] != null) {
      final typeIndex = _activeFilters!['propertyTypeIndex'] as int;
      final propertyTypes = [
        'House',
        'Apartment',
        'Condo',
        'Land',
        'Villa',
        'Townhouse',
      ];
      if (typeIndex > 0 && typeIndex <= propertyTypes.length) {
        final selectedType = propertyTypes[typeIndex - 1];
        results = results.where((property) {
          final type = (property['type'] ?? '').toString();
          return type.contains(selectedType.toUpperCase());
        }).toList();
      }
    }

    // Apply sorting
    results = _sortProperties(results);

    setState(() {
      _filteredProperties = results;
    });
  }

  List<Map<String, dynamic>> _sortProperties(
    List<Map<String, dynamic>> properties,
  ) {
    final sorted = List<Map<String, dynamic>>.from(properties);
    switch (_sortBy) {
      case 'price_low':
        sorted.sort((a, b) {
          final priceA = (a['price'] ?? 0) as num;
          final priceB = (b['price'] ?? 0) as num;
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_high':
        sorted.sort((a, b) {
          final priceA = (a['price'] ?? 0) as num;
          final priceB = (b['price'] ?? 0) as num;
          return priceB.compareTo(priceA);
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
                            'Featured Properties'.tr,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: const Color(0xFF2FC1BE),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Discover exclusive properties'.tr,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.textTheme.bodyLarge?.color
                                  ?.withValues(alpha: 0.66),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _desktopListingTypeToggle(theme),
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
                                _filteredProperties = [];
                              });
                            }
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty) _performSearch(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search Properties...'.tr,
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
                            builder: (context) => PropertyFilterBottomSheet(
                              onApply: _applyFilters,
                            ),
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
                  final allProperties = _filterByListingType(
                    controller.allPropertiesData,
                  );
                  final foundCount = _hasSearched
                      ? _filterByListingType(_filteredProperties).length
                      : allProperties.length;
                  return Text(
                    '$foundCount Properties Found'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (controller.isFetchingProperties.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2FC1BE),
                        ),
                      );
                    }
                    final properties = _hasSearched
                        ? _filterByListingType(_filteredProperties)
                        : _filterByListingType(controller.allPropertiesData);
                    return _buildDesktopPropertyGrid(
                      theme: theme,
                      controller: controller,
                      properties: properties,
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
                    'Featured Properties'.tr,
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
                  'Discover exclusive properties'.tr,
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
                                _filteredProperties = [];
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
                            hintText: 'Search Properties...'.tr,
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
                            builder: (context) => PropertyFilterBottomSheet(
                              onApply: _applyFilters,
                            ),
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
              const SizedBox(height: 16),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF2C2C2E)
                      : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = 0),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _selectedType == 0
                                ? theme.cardColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _selectedType == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Buy'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedType == 0
                                  ? const Color(0xFF2FC1BE)
                                  : (theme.brightness == Brightness.dark
                                        ? Colors.white54
                                        : const Color(0xFF9E9E9F)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = 1),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _selectedType == 1
                                ? theme.cardColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _selectedType == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Rent'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedType == 1
                                  ? const Color(0xFF2FC1BE)
                                  : (theme.brightness == Brightness.dark
                                        ? Colors.white54
                                        : const Color(0xFF9E9E9F)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_hasSearched)
              _buildCountRow(
                theme: theme,
                count: _filterByListingType(_filteredProperties).length,
              )
            else
              Obx(() {
                final filtered = _filterByListingType(
                  controller.allPropertiesData,
                );
                return _buildCountRow(theme: theme, count: filtered.length);
              }),
            const SizedBox(height: 20),

            Expanded(
              child: _hasSearched
                  ? _buildPropertyList(
                      theme: theme,
                      controller: controller,
                      properties: _filterByListingType(_filteredProperties),
                    )
                  : Obx(() {
                      final filtered = _filterByListingType(
                        controller.allPropertiesData,
                      );
                      return _buildPropertyList(
                        theme: theme,
                        controller: controller,
                        properties: filtered,
                      );
                    }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => MainBottomBar(
          currentIndex: controller.bottomIndex.value,
          isPropertySelected: true,
          onTap: (index) {
            controller.categoryIndex.value = 1;
            controller.bottomIndex.value = index;
            Get.offAll(() => const MainScreen());
          },
        ),
      ),
    );
  }
}
