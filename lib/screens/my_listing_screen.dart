import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superapp/controllers/my_listing_controller.dart';
import 'package:superapp/screens/add_property_screen.dart';
import 'package:superapp/screens/add_hotel_screen.dart';
import 'hotel_detail_screen.dart';
import 'property_detail_screen.dart';

enum ListingCategory { property, hotel }

class MyListingScreen extends StatefulWidget {
  final ListingCategory category;

  const MyListingScreen({super.key, this.category = ListingCategory.property});

  @override
  State<MyListingScreen> createState() => _MyListingScreenState();
}

class _MyListingScreenState extends State<MyListingScreen> {
  final List<String> _filters = ['All', 'Active', 'Inactive'];

  bool get _isHotel => widget.category == ListingCategory.hotel;

  late final MyListingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(MyListingController());
  }

  @override
  void dispose() {
    Get.delete<MyListingController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF2FC1BE),
          ),
        ),
        title: Text(
          _isHotel ? 'My Hotels' : 'My Listings',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2FC1BE),
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Obx(() {
            final selectedTab = _isHotel
                ? _controller.selectedTab.value
                : _controller.selectedPropertyTab.value;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = index == selectedTab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        if (_isHotel) {
                          _controller.selectedTab.value = index;
                        } else {
                          _controller.selectedPropertyTab.value = index;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2FC1BE)
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(30),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: isDark
                                      ? Colors.white24
                                      : const Color(0xFFE5E7EB),
                                ),
                        ),
                        child: Text(
                          _filters[index],
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : isDark
                                ? Colors.white70
                                : const Color(0xFF5A6375),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),

          // Listings List
          Expanded(child: _isHotel ? _buildHotelList() : _buildPropertyList()),
        ],
      ),
      floatingActionButton: Container(
        height: 50,
        margin: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
          onPressed: () async {
            if (_isHotel) {
              final result = await Get.to(() => const AddHotelScreen());
              if (result == true) {
                _controller.fetchMyHotels();
              }
            } else {
              final result = await Get.to(() => const AddPropertyScreen());
              if (result == true) {
                _controller.fetchMyProperties();
              }
            }
          },
          backgroundColor: const Color(0xFF2FC1BE),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          label: Row(
            children: [
              const Icon(Icons.add, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                _isHotel ? 'Add Hotel' : 'Add Property',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHotelList() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2FC1BE)),
        );
      }

      if (_controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('Failed to load hotels'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _controller.fetchMyHotels(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2FC1BE),
                ),
                child: Text('Retry'.tr,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }

      final filteredHotels = _controller.filteredHotels;
      final isInactiveTab = _controller.selectedTab.value == 2;

      if (filteredHotels.isEmpty) {
        final emptyMessage = _controller.selectedTab.value == 0
            ? 'No hotels yet'
            : _controller.selectedTab.value == 1
            ? 'No active hotels'
            : 'No inactive hotels';
        final emptyHint = _controller.selectedTab.value == 0
            ? 'Tap + Add Hotel to list your first hotel'
            : _controller.selectedTab.value == 1
            ? 'All your hotels are currently inactive'
            : 'All your hotels are currently active';

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptyHint,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _controller.fetchMyHotels(),
        color: const Color(0xFF2FC1BE),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredHotels.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index == filteredHotels.length) {
              return const SizedBox(height: 80);
            }

            final hotel = filteredHotels[index];
            final imageUrl = _controller.getImageUrl(hotel);
            final price = _controller.getMinPrice(hotel);
            final title = hotel['title'] ?? 'Untitled';
            final address = hotel['address'] ?? '';
            final hotelId = hotel['id'] as int;
            final isActive = hotel['isActive'] == true;

            return ListingCard(
              title: title,
              price: price,
              priceSuffix: price == 'N/A' ? '' : ' /night',
              address: address,
              status: isActive ? 'ACTIVE' : 'INACTIVE',
              statusColor: isActive
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
              imageUrl: imageUrl,
              onEdit: () async {
                final result = await Get.to(
                  () => AddHotelScreen(editHotelData: hotel),
                );
                if (result == true) {
                  _controller.fetchMyHotels();
                }
              },
              onDelete: () => _showDeleteConfirmation(
                context,
                hotelId,
                title,
                isHotel: true,
              ),
              onToggleActive: isInactiveTab
                  ? null
                  : isActive
                  ? () => _toggleHotelStatus(hotelId, title, false)
                  : () => _toggleHotelStatus(hotelId, title, true),
              onActivate: isInactiveTab
                  ? () => _toggleHotelStatus(hotelId, title, true)
                  : null,
              isActive: isActive,
              showActivateButton: isInactiveTab,
              onViewDetails: () => Get.to(
                () => HotelDetailScreen(hotelData: hotel),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildPropertyList() {
    return Obx(() {
      if (_controller.isLoadingProperties.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF2FC1BE)),
        );
      }

      if (_controller.errorMessageProperties.value.isNotEmpty) {
        return RefreshIndicator(
          onRefresh: () => _controller.fetchMyProperties(),
          color: const Color(0xFF2FC1BE),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text('Failed to load properties'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _controller.fetchMyProperties(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2FC1BE),
                      ),
                      child: Text('Retry'.tr,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      final filteredProperties = _controller.filteredProperties;
      final isInactiveTab = _controller.selectedPropertyTab.value == 2;

      if (filteredProperties.isEmpty) {
        final emptyMessage = _controller.selectedPropertyTab.value == 0
            ? 'No properties yet'
            : _controller.selectedPropertyTab.value == 1
            ? 'No active properties'
            : 'No inactive properties';
        final emptyHint = _controller.selectedPropertyTab.value == 0
            ? 'Tap + Add Property to list your first property'
            : _controller.selectedPropertyTab.value == 1
            ? 'All your properties are currently inactive'
            : 'All your properties are currently active';

        return RefreshIndicator(
          onRefresh: () => _controller.fetchMyProperties(),
          color: const Color(0xFF2FC1BE),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      emptyMessage,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      emptyHint,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _controller.fetchMyProperties(),
        color: const Color(0xFF2FC1BE),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredProperties.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index == filteredProperties.length) {
              return const SizedBox(height: 80);
            }

            final property = filteredProperties[index];
            final imageUrl = _controller.getPropertyImageUrl(property);
            final price = _controller.getPropertyPrice(property);
            final title = property['title'] ?? 'Untitled';
            final address = property['address'] ?? '';
            final propertyId = property['id'] as int;
            final isActive = property['isActive'] == true;

            return ListingCard(
              title: title,
              price: price,
              priceSuffix: '',
              address: address,
              status: isActive ? 'ACTIVE' : 'INACTIVE',
              statusColor: isActive
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
              imageUrl: imageUrl,
              onEdit: () async {
                final result = await Get.to(
                  () => AddPropertyScreen(editPropertyData: property),
                );
                if (result == true) {
                  _controller.fetchMyProperties();
                }
              },
              onDelete: () => _showDeleteConfirmation(
                context,
                propertyId,
                title,
                isHotel: false,
              ),
              onToggleActive: isInactiveTab
                  ? null
                  : isActive
                  ? () => _togglePropertyStatus(propertyId, title, false)
                  : () => _togglePropertyStatus(propertyId, title, true),
              onActivate: isInactiveTab
                  ? () => _togglePropertyStatus(propertyId, title, true)
                  : null,
              isActive: isActive,
              showActivateButton: isInactiveTab,
              onViewDetails: () => Get.to(
                () => PropertyDetailScreen(propertyData: property),
              ),
            );
          },
        ),
      );
    });
  }

  void _toggleHotelStatus(int hotelId, String title, bool newStatus) async {
    final success = await _controller.toggleHotelStatus(hotelId, newStatus);
    if (success) {
      Get.snackbar(
        newStatus ? 'Activated' : 'Deactivated',
        '"$title" is now ${newStatus ? "active" : "inactive"}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _togglePropertyStatus(
    int propertyId,
    String title,
    bool newStatus,
  ) async {
    final success = await _controller.togglePropertyStatus(
      propertyId,
      newStatus,
    );
    if (success) {
      Get.snackbar(
        newStatus ? 'Activated' : 'Deactivated',
        '"$title" is now ${newStatus ? "active" : "inactive"}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    int id,
    String name, {
    required bool isHotel,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final typeName = isHotel ? 'Hotel' : 'Property';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete $typeName',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$name"? This action cannot be undone.',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'.tr,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              bool success;
              if (isHotel) {
                success = await _controller.deleteHotel(id);
              } else {
                success = await _controller.deleteProperty(id);
              }
              if (success) {
                Get.snackbar(
                  'Deleted',
                  '"$name" has been deleted',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Delete'.tr,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListingCard extends StatelessWidget {
  final String title;
  final String? titleLine2;
  final String price;
  final String priceSuffix;
  final String address;
  final String status;
  final Color? statusColor;
  final String? imageUrl;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewDetails;
  final VoidCallback? onToggleActive;
  final VoidCallback? onActivate;
  final bool isActive;
  final bool showActivateButton;

  const ListingCard({
    super.key,
    required this.title,
    this.titleLine2,
    required this.price,
    required this.priceSuffix,
    required this.address,
    required this.status,
    this.statusColor,
    this.imageUrl,
    this.onEdit,
    this.onDelete,
    this.onViewDetails,
    this.onToggleActive,
    this.onActivate,
    this.isActive = true,
    this.showActivateButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _imagePlaceholder();
                        },
                      )
                    : _imagePlaceholder(),
              ),
              if (status.isNotEmpty)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor ?? const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, color: Colors.white, size: 8),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Delete button on image
              if (onDelete != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF111827),
                            ),
                          ),
                          if (titleLine2 != null)
                            Text(
                              titleLine2!,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: price,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2FC1BE),
                            ),
                          ),
                          TextSpan(
                            text: priceSuffix,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF2FC1BE),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Activate button for inactive tab
                if (showActivateButton && onActivate != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onActivate,
                      icon: const Icon(Icons.visibility, size: 18),
                      label: Text('Activate'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2FC1BE),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        textStyle: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text('Edit'.tr),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? Colors.white
                              : const Color(0xFF374151),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white24
                                : const Color(0xFFE5E7EB),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: showActivateButton
                          ? OutlinedButton(
                              onPressed: onViewDetails,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark
                                    ? Colors.white
                                    : const Color(0xFF374151),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white24
                                      : const Color(0xFFE5E7EB),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                textStyle: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: Text('View Details'.tr),
                            )
                          : ElevatedButton(
                              onPressed: onViewDetails,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2FC1BE),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 0,
                                textStyle: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: Text('View Details'.tr),
                            ),
                    ),
                  ],
                ),

                // Deactivate button for active items on non-inactive tab
                if (!showActivateButton &&
                    onToggleActive != null &&
                    isActive) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onToggleActive,
                      icon: const Icon(
                        Icons.visibility_off_outlined,
                        size: 18,
                        color: Color(0xFFEF4444),
                      ),
                      label: Text('Deactivate'.tr,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }
}
