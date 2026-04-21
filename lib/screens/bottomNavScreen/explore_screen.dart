import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/explore_hotel_card.dart';
import '../../controllers/main_screen_controller.dart';
import '../../services/listing_service.dart';
import '../property_detail_screen.dart';
import '../hotel_detail_screen.dart';
import 'directions_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final RxBool isMapView = false.obs;
  final RxInt propertyTypeIndex = 0.obs;
  GoogleMapController? _mapController;

  Map<String, dynamic>? _selectedMapListing;
  bool _selectedMapIsProperty = false;

  String? _getListingImageUrl(Map<String, dynamic> listing, bool isProperty) {
    final images = listing['images'];
    if (images is! List || images.isEmpty) return null;

    final id = listing['id'];
    if (id is! int) return null;

    return isProperty
        ? ListingService.propertyImageUrl(id, 0)
        : ListingService.hotelImageUrl(id, 0);
  }

  Set<Marker> _buildMarkers(List listings, bool isProperty, BuildContext context) {
    final markers = <Marker>{};
    for (final listing in listings) {
      final lat = (listing['latitude'] as num).toDouble();
      final lng = (listing['longitude'] as num).toDouble();
      final title = listing['title'] ?? 'Unknown';
      final id = listing['id'] as int;
      
      markers.add(
        Marker(
          markerId: MarkerId(isProperty ? 'property_$id' : 'hotel_$id'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(170.0),
          infoWindow: InfoWindow(
            title: title,
            snippet: isProperty ? 'Property' : 'Hotel',
          ),
          onTap: () {
            setState(() {
              _selectedMapListing = listing;
              _selectedMapIsProperty = isProperty;
            });
          },
        ),
      );
    }
    return markers;
  }

  Widget _buildMapListingCard(ThemeData theme, MainScreenController controller) {
    final listing = _selectedMapListing;
    if (listing == null) return const SizedBox.shrink();

    final isProperty = _selectedMapIsProperty;
    final title = listing['title'] ?? 'Unknown';
    final description = (listing['description'] ?? '').toString();
    final rating = (listing['rating'] as num?)?.toDouble();
    final reviewsCount = listing['reviewsCount'];
    final address = (listing['address'] ?? '').toString();

    final String price = isProperty
        ? controller.getPropertyPrice(listing)
        : controller.getMinPrice(listing);

    final imageUrl = _getListingImageUrl(listing, isProperty);

    return GestureDetector(
      onTap: () {
        if (isProperty) {
          Get.to(() => PropertyDetailScreen(propertyData: listing));
        } else {
          Get.to(() => HotelDetailScreen(hotelData: listing));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 120,
                height: 90,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: theme.dividerColor,
                        ),
                      )
                    : Container(
                        color: theme.dividerColor,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedMapListing = null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (rating != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFA500),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.brightness == Brightness.dark
                                ? Colors.grey[400]
                                : const Color(0xFF878787),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        if (reviewsCount != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            'Reviews ($reviewsCount)',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : const Color(0xFF878787),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ],
                    )
                  else if (address.isNotEmpty)
                    Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[400]
                            : const Color(0xFF878787),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[400]
                            : const Color(0xFF878787),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          price.isNotEmpty ? price : 'Price on request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final lat = (listing['latitude'] as num?)?.toDouble();
                          final lng = (listing['longitude'] as num?)?.toDouble();
                          if (lat == null || lng == null) {
                            Get.snackbar('Error', 'Location not available');
                            return;
                          }
                          Get.to(
                            () => DirectionsScreen(
                              destinationLatitude: lat,
                              destinationLongitude: lng,
                              destinationTitle: title,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2FC1BE),
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                'assets/direction.svg',
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('Directions'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2FC1BE),
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainScreenController>();
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  Text('Explore'.tr,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2FC1BE),
                      decoration: TextDecoration.none,
                      fontFamily: 'Inter', // Assuming default font
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Header Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(
                () => _CategoryToggle(
                  selectedIndex: controller.categoryIndex.value,
                  onChanged: controller.onCategoryTap,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // View Toggles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(
                () => Row(
                  children: [
                    GestureDetector(
                      onTap: () => isMapView.value = false,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: !isMapView.value
                              ? const Color(0xFF2FC1BE)
                              : (theme.brightness == Brightness.dark
                                    ? theme.cardColor
                                    : const Color(0xFFF1F2F3)),
                          borderRadius: BorderRadius.circular(12),
                          border: isMapView.value
                              ? Border.all(
                                  color: const Color(0xFFE8E8E8),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/card.svg',
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              !isMapView.value
                                  ? Colors.white
                                  : (theme.brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF1D2330)),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => isMapView.value = true,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isMapView.value
                              ? const Color(0xFF2FC1BE)
                              : (theme.brightness == Brightness.dark
                                    ? theme.cardColor
                                    : const Color(0xFFF1F2F3)),
                          borderRadius: BorderRadius.circular(12),
                          border: !isMapView.value
                              ? Border.all(
                                  color: const Color(0xFFE8E8E8),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/map.svg',
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              isMapView.value
                                  ? Colors.white
                                  : (theme.brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF1D2330)),
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
            // Search Bar
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _SearchBar(),
            ),
            const SizedBox(height: 16),
            // Buy/Rent Toggle (Only visible when Properties tab is selected)
            Obx(() {
              if (controller.categoryIndex.value == 1) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 20,
                  ),
                  child: _PropertyTypeToggle(
                    selectedIndex: propertyTypeIndex.value,
                    onChanged: (index) => propertyTypeIndex.value = index,
                  ),
                );
              }
              return const SizedBox(height: 4); // Small spacer when hidden
            }),
            // Content
            Expanded(
              child: Obx(() {
                if (isMapView.value) {
                  // Debug logging
                  print('Total hotels in DB: ${controller.allHotelsData.length}');
                  print('Total properties in DB: ${controller.allPropertiesData.length}');
                  
                  // Check first few hotels for coordinates
                  for (int i = 0; i < controller.allHotelsData.length && i < 3; i++) {
                    final h = controller.allHotelsData[i];
                    print('Hotel ${h['title']}: lat=${h['latitude']}, lng=${h['longitude']}');
                  }
                  
                  // Get hotels and properties with coordinates
                  final hotelsWithCoords = controller.allHotelsData.where((h) {
                    final lat = h['latitude'];
                    final lng = h['longitude'];
                    return lat != null && lng != null && (lat as num) != 0 && (lng as num) != 0;
                  }).toList();
                  
                  final propertiesWithCoords = controller.allPropertiesData.where((p) {
                    final lat = p['latitude'];
                    final lng = p['longitude'];
                    return lat != null && lng != null && (lat as num) != 0 && (lng as num) != 0;
                  }).toList();

                  final isProperty = controller.categoryIndex.value == 1;
                  final allListings = isProperty ? controller.allPropertiesData : controller.allHotelsData;
                  final listingsWithCoords = isProperty ? propertiesWithCoords : hotelsWithCoords;

                  print('${isProperty ? 'Properties' : 'Hotels'} with coords: ${listingsWithCoords.length}/${allListings.length}');

                  // Build markers in build method
                  final markers = _buildMarkers(listingsWithCoords, isProperty, context);

                  final initialPosition = listingsWithCoords.isNotEmpty 
                      ? LatLng(
                          (listingsWithCoords.first['latitude'] as num).toDouble(),
                          (listingsWithCoords.first['longitude'] as num).toDouble(),
                        )
                      : const LatLng(37.7749, -122.4194);

                  return Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: initialPosition,
                          zoom: 12,
                        ),
                        markers: markers,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        onMapCreated: (mapController) {
                          _mapController = mapController;
                          // Fit all markers in view if we have listings with coords
                          if (listingsWithCoords.isNotEmpty) {
                            double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
                            for (final listing in listingsWithCoords) {
                              final lat = (listing['latitude'] as num).toDouble();
                              final lng = (listing['longitude'] as num).toDouble();
                              if (lat < minLat) minLat = lat;
                              if (lat > maxLat) maxLat = lat;
                              if (lng < minLng) minLng = lng;
                              if (lng > maxLng) maxLng = lng;
                            }
                            mapController.animateCamera(
                              CameraUpdate.newLatLngBounds(
                                LatLngBounds(
                                  southwest: LatLng(minLat, minLng),
                                  northeast: LatLng(maxLat, maxLng),
                                ),
                                50,
                              ),
                            );
                          }
                        },
                      ),
                      // Show count of listings with coordinates
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            '${listingsWithCoords.length}/${allListings.length} ${isProperty ? 'properties' : 'hotels'} on map',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark 
                                  ? Colors.white 
                                  : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      
                      // Zoom controls
                      Positioned(
                        right: 16,
                        bottom: 160,
                        child: Column(
                          children: [
                            FloatingActionButton(
                              mini: true,
                              backgroundColor: theme.cardColor,
                              heroTag: 'zoomIn',
                              onPressed: () {
                                _mapController?.animateCamera(
                                  CameraUpdate.zoomIn(),
                                );
                              },
                              child: const Icon(
                                Icons.add,
                                color: Color(0xFF2FC1BE),
                              ),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton(
                              mini: true,
                              backgroundColor: theme.cardColor,
                              heroTag: 'zoomOut',
                              onPressed: () {
                                _mapController?.animateCamera(
                                  CameraUpdate.zoomOut(),
                                );
                              },
                              child: const Icon(
                                Icons.remove,
                                color: Color(0xFF2FC1BE),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Current location button
                      Positioned(
                        right: 16,
                        bottom: 100,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: theme.cardColor,
                          heroTag: 'myLocation',
                          onPressed: () async {
                            try {
                              final permission = await Geolocator.checkPermission();
                              if (permission == LocationPermission.denied) {
                                await Geolocator.requestPermission();
                              }
                              
                              final position = await Geolocator.getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high,
                              );
                              _mapController?.animateCamera(
                                CameraUpdate.newLatLng(
                                  LatLng(position.latitude, position.longitude),
                                ),
                              );
                            } catch (e) {
                              Get.snackbar('Error', 'Could not get current location');
                            }
                          },
                          child: const Icon(
                            Icons.my_location,
                            color: Color(0xFF2FC1BE),
                          ),
                        ),
                      ),

                      if (_selectedMapListing != null)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: _buildMapListingCard(theme, controller),
                        ),
                    ],
                  );
                }
                return Obx(() {
                  final isProperty = controller.categoryIndex.value == 1;
                  final theme = Theme.of(context);

                  if (isProperty) {
                    // Filter properties by Buy/Rent
                    final desiredType = propertyTypeIndex.value == 1 ? 'FOR_RENT' : 'FOR_SALE';
                    final allProperties = controller.allPropertiesData;
                    final properties = allProperties.where((property) {
                      final raw = property['listingType'];
                      final listingType = raw?.toString();
                      if (listingType == null || listingType.isEmpty) {
                        return true;
                      }
                      return listingType == desiredType;
                    }).toList();
                    
                    if (properties.isEmpty) {
                      return Center(
                        child: Text('No properties found'.tr,
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
                        final propertyId = property['id'] as int;
                        final images = property['images'] as List<dynamic>?;
                        final imageUrl = (images != null && images.isNotEmpty)
                            ? ListingService.propertyImageUrl(propertyId, 0)
                            : null;
                        
                        // Get property price using controller like property_search_screen.dart
                        final price = controller.getPropertyPrice(property);
                        // Debug: print actual price data
                        print('Property: ${property['title']}, Raw price: ${property['price']}, Formatted: $price');
                        final priceDisplay = price.isNotEmpty ? price : '\$0';
                        
                        return ExploreHotelCard(
                          title: title,
                          location: address,
                          imagePath: 'assets/hotel1.png',
                          imageUrl: imageUrl,
                          rating: rating,
                          price: priceDisplay,
                          showPerNight: false,
                          onTap: () => Get.to(
                            () => PropertyDetailScreen(propertyData: property),
                          ),
                        );
                      },
                    );
                  } else {
                    // Real hotel data
                    final hotels = controller.allHotelsData;
                    if (hotels.isEmpty) {
                      return Center(
                        child: Text('No hotels found'.tr,
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
                        final title = hotel['title'] ?? 'Hotel';
                        final address = hotel['address'] ?? '';
                        final rating = controller.getRating(hotel);
                        final hotelId = hotel['id'] as int;
                        final images = hotel['images'] as List<dynamic>?;
                        final imageUrl = (images != null && images.isNotEmpty)
                            ? ListingService.hotelImageUrl(hotelId, 0)
                            : null;
                        
                        // Get minimum room price with /night suffix for hotels
                        final rooms = hotel['rooms'] as List<dynamic>?;
                        int minPrice = 0;
                        if (rooms != null && rooms.isNotEmpty) {
                          for (final room in rooms) {
                            final priceData = room['price'];
                            final price = priceData is num 
                                ? priceData.toInt() 
                                : int.tryParse(priceData?.toString() ?? '0') ?? 0;
                            if (minPrice == 0 || (price > 0 && price < minPrice)) {
                              minPrice = price;
                            }
                          }
                        }
                        
                        final priceDisplay = minPrice > 0 ? '\$$minPrice' : '\$0';
                        
                        return ExploreHotelCard(
                          title: title,
                          location: address,
                          imagePath: 'assets/hotel1.png',
                          imageUrl: imageUrl,
                          rating: rating,
                          price: priceDisplay,
                          showPerNight: true,
                          onTap: () => Get.to(
                            () => HotelDetailScreen(hotelData: hotel),
                          ),
                        );
                      },
                    );
                  }
                });
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showListingOnMap(Map<String, dynamic> listing, bool isProperty, BuildContext context) {
    final controller = Get.find<MainScreenController>();
    final title = listing['title'] ?? 'Unknown';
    final address = listing['address'] ?? '';
    final price = isProperty 
        ? controller.getPropertyPrice(listing)
        : controller.getMinPrice(listing);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(ctx).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            if (address.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                address,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              price.isNotEmpty ? '\$$price' : 'Price on request',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2FC1BE),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (isProperty) {
                    Get.to(() => PropertyDetailScreen(propertyData: listing));
                  } else {
                    Get.to(() => HotelDetailScreen(hotelData: listing));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2FC1BE),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('View Details'.tr,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
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
        color: const Color(0xFF2FC1BE).withOpacity(0.15),
        borderRadius: BorderRadius.circular(28),
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
            if (iconAssetPath.endsWith('.svg'))
              SvgPicture.asset(
                iconAssetPath,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  selected
                      ? theme.colorScheme.primary
                      : const Color(0xFF2FC1BE),
                  BlendMode.srcIn,
                ),
              )
            else
              Image.asset(
                iconAssetPath,
                width: 22,
                height: 22,
                color: selected
                    ? theme.colorScheme.primary
                    : const Color(0xFF2FC1BE),
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: selected
                    ? theme.colorScheme.primary
                    : const Color(0xFF2FC1BE),
                fontWeight: FontWeight.w600,
                fontSize: 18,
                decoration: TextDecoration.none,
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

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0x9CBAB1B1), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: theme.brightness == Brightness.dark
                ? Colors.grey[400]
                : const Color(0xFF9E9E9F),
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: Obx(
                () => TextField(
                  cursorColor: theme.colorScheme.primary,
                  selectionControls: materialTextSelectionControls,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText:
                        Get.find<MainScreenController>().categoryIndex.value ==
                            1
                        ? 'Search properties...'
                        : 'Search hotels...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9AA0AF),
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ),
          Container(
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
        ],
      ),
    );
  }
}

class _PropertyTypeToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _PropertyTypeToggle({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(0),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? const Color(0xFF2FC1BE)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(23),
                ),
                alignment: Alignment.center,
                child: Text('Buy'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: selectedIndex == 0
                        ? Colors.white
                        : const Color(0xFF878787),
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(1),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? const Color(0xFF2FC1BE)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(23),
                ),
                alignment: Alignment.center,
                child: Text('Rent'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: selectedIndex == 1
                        ? Colors.white
                        : const Color(0xFF878787),
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
