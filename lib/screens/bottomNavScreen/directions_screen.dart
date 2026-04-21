import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/main_bottom_bar.dart';
import '../../controllers/main_screen_controller.dart';
import 'booking_screen.dart';

class DirectionsScreen extends StatefulWidget {
  const DirectionsScreen({
    super.key,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.destinationTitle,
  });

  final double destinationLatitude;
  final double destinationLongitude;
  final String destinationTitle;

  @override
  State<DirectionsScreen> createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends State<DirectionsScreen> {
  static const String _googleApiKey = 'AIzaSyCllvLEMmJTFyydQ7VKmgxtBAUrJyPLf5c';

  GoogleMapController? _mapController;
  bool _loading = true;
  LatLng? _origin;
  late final LatLng _destination = LatLng(widget.destinationLatitude, widget.destinationLongitude);
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initDirections();
  }

  Future<void> _initDirections() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final origin = LatLng(position.latitude, position.longitude);

      final routePoints = await _fetchRoutePolyline(origin, _destination);

      final markers = <Marker>{
        Marker(
          markerId: const MarkerId('origin'),
          position: origin,
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
        Marker(
          markerId: const MarkerId('destination'),
          position: _destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(170.0),
          infoWindow: InfoWindow(title: widget.destinationTitle),
        ),
      };

      final polylines = <Polyline>{
        if (routePoints.isNotEmpty)
          Polyline(
            polylineId: const PolylineId('route'),
            points: routePoints,
            width: 6,
            color: const Color(0xFF2FC1BE),
          ),
      };

      setState(() {
        _origin = origin;
        _markers = markers;
        _polylines = polylines;
        _loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitBounds(origin, _destination);
      });
    } catch (_) {
      setState(() {
        _loading = false;
      });
      Get.snackbar('Error', 'Could not load directions');
    }
  }

  Future<List<LatLng>> _fetchRoutePolyline(LatLng origin, LatLng destination) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$_googleApiKey',
    );
    final res = await http.get(url);
    final data = json.decode(res.body);
    if (data['status'] != 'OK') {
      return [];
    }
    final routes = data['routes'] as List<dynamic>;
    if (routes.isEmpty) return [];
    final polyline = routes[0]['overview_polyline']?['points']?.toString();
    if (polyline == null || polyline.isEmpty) return [];
    return _decodePolyline(polyline);
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  void _fitBounds(LatLng a, LatLng b) {
    final controller = _mapController;
    if (controller == null) return;

    final southWest = LatLng(
      a.latitude < b.latitude ? a.latitude : b.latitude,
      a.longitude < b.longitude ? a.longitude : b.longitude,
    );
    final northEast = LatLng(
      a.latitude > b.latitude ? a.latitude : b.latitude,
      a.longitude > b.longitude ? a.longitude : b.longitude,
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southWest, northeast: northEast),
        60,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF2FC1BE),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Directions'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2FC1BE),
                    ),
                  ),
                ],
              ),
            ),
            
            // Input Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicators
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                              width: 2.5,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              3,
                              (index) => Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.red,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Text Fields
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.brightness == Brightness.dark ? Colors.white24 : const Color(0xFFE8E8E8)),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Your Location'.tr,
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF555555),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.brightness == Brightness.dark ? Colors.white24 : const Color(0xFFE8E8E8)),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            widget.destinationTitle,
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF555555),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Map Area
            Expanded(
              child: Stack(
                children: [
                  if (_loading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2FC1BE),
                      ),
                    )
                  else
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _origin ?? _destination,
                        zoom: 14,
                      ),
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      onMapCreated: (c) => _mapController = c,
                    ),
                  // Gradient overlay at top to blend map with white background
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainBottomBar(
        currentIndex: 1, // Explore tab
        onTap: (index) {
          final controller = Get.find<MainScreenController>();
          if (index == 1) {
             Get.back(); // Go back to Explore main view
             return;
          }

          if (index == 0) {
            controller.bottomIndex.value = 0;
            Get.back(); // Back to explore
            Get.back(); // Back to home if needed, or just let MainScreen handle it
            // Since we are pushing this screen, we might need to handle nav carefully.
            // For now, assuming simple back + controller update
          } else if (index == 2) {
            controller.bottomIndex.value = 2;
            Get.off(() => const BookingScreen());
          } else {
            controller.onBottomNavTap(index);
          }
        },
      ),
    );
  }
}
