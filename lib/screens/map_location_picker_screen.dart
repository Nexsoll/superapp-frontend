import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapLocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  const MapLocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(0, 0);
  bool _isLoading = true;
  String _currentAddress = '';
  final TextEditingController _searchController = TextEditingController();
  
  // Search suggestions
  List<dynamic> _searchSuggestions = [];
  bool _showSuggestions = false;
  bool _isSearching = false;

  static const String _googleApiKey = 'AIzaSyCllvLEMmJTFyydQ7VKmgxtBAUrJyPLf5c';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    double lat = widget.initialLatitude ?? 0;
    double lng = widget.initialLongitude ?? 0;
    print('Initializing map with lat: $lat, lng: $lng');

    if (lat == 0 && lng == 0) {
      // Default to a known location (e.g., New York) instead of 0,0
      lat = 40.7128;
      lng = -74.0060;
      
      // Try to get current location
      try {
        final permission = await Geolocator.checkPermission();
        print('Location permission: $permission');
        if (permission == LocationPermission.denied) {
          final result = await Geolocator.requestPermission();
          print('Permission request result: $result');
        }
        
        if (permission == LocationPermission.whileInUse || 
            permission == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          lat = position.latitude;
          lng = position.longitude;
          print('Got current location: $lat, $lng');
        }
      } catch (e) {
        print('Could not get current location: $e');
        // Keep default location
      }
    }

    setState(() {
      _selectedLocation = LatLng(lat, lng);
      _currentAddress = widget.initialAddress ?? '';
      _searchController.text = _currentAddress;
      _isLoading = false;
    });
    print('Map initialized at: $_selectedLocation');
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Use Google Geocoding API
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$_googleApiKey'
      );
      
      final response = await http.get(url);
      final data = json.decode(response.body);
      
      print('Geocoding response: $data');

      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        final formattedAddress = data['results'][0]['formatted_address'];

        setState(() {
          _selectedLocation = LatLng(lat, lng);
          _currentAddress = formattedAddress;
          _isLoading = false;
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation, 15),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        Get.snackbar('Error', 'Location not found: ${data['status']}');
      }
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('Error', 'Failed to search location: $e');
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    // Move camera to tapped location
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(position),
    );
    _getAddressFromLatLng(position);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      print('Fetching address for: ${position.latitude}, ${position.longitude}');
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$_googleApiKey'
      );
      
      final response = await http.get(url);
      final data = json.decode(response.body);
      
      print('Reverse geocoding response: ${data['status']}');

      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final formattedAddress = data['results'][0]['formatted_address'];
        print('Got address: $formattedAddress');
        setState(() {
          _currentAddress = formattedAddress;
          _searchController.text = formattedAddress;
        });
      } else {
        print('No address found, using coordinates');
        // Fallback to coordinates if no address found
        setState(() {
          _currentAddress = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          _searchController.text = _currentAddress;
        });
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
      // Fallback to coordinates on error
      setState(() {
        _currentAddress = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        _searchController.text = _currentAddress;
      });
    }
  }

  Future<void> _fetchSearchSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _searchSuggestions = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$_googleApiKey&types=geocode'
      );
      
      final response = await http.get(url);
      final data = json.decode(response.body);

      print('Autocomplete response: ${data['status']}');

      if (data['status'] == 'OK') {
        setState(() {
          _searchSuggestions = data['predictions'] ?? [];
          _showSuggestions = _searchSuggestions.isNotEmpty;
          _isSearching = false;
        });
      } else {
        setState(() {
          _showSuggestions = false;
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Autocomplete error: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _selectSuggestion(dynamic prediction) async {
    final placeId = prediction['place_id'];
    final description = prediction['description'];

    setState(() {
      _showSuggestions = false;
      _isLoading = true;
      _searchController.text = description;
    });

    try {
      // Get place details
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_googleApiKey'
      );
      
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final location = data['result']['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];

        setState(() {
          _selectedLocation = LatLng(lat, lng);
          _currentAddress = description;
          _isLoading = false;
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation, 15),
        );
      }
    } catch (e) {
      print('Place details error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _confirmLocation() {
    // Ensure we have a readable address
    String addressToReturn = _currentAddress;
    if (addressToReturn.isEmpty) {
      addressToReturn = _searchController.text;
    }
    if (addressToReturn.isEmpty) {
      addressToReturn = '${_selectedLocation.latitude.toStringAsFixed(4)}, ${_selectedLocation.longitude.toStringAsFixed(4)}';
    }
    
    print('Confirming location: $addressToReturn at $_selectedLocation');
    Get.back(result: {
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
      'address': addressToReturn,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.cardColor,
              child: Column(
                children: [
                  Row(
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
                      Text('Select Location'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2FC1BE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search field
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Color(0xFF9AA0AF),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search location...'.tr,
                              hintStyle: TextStyle(color: Color(0xFF9AA0AF)),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              if (value.length >= 2) {
                                _fetchSearchSuggestions(value);
                              } else {
                                setState(() {
                                  _showSuggestions = false;
                                });
                              }
                            },
                            onSubmitted: (value) {
                              _searchLocation(value);
                              setState(() {
                                _showSuggestions = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Search suggestions
                  if (_showSuggestions)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchSuggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _searchSuggestions[index];
                          final mainText = suggestion['structured_formatting']?['main_text'] ?? suggestion['description'];
                          final secondaryText = suggestion['structured_formatting']?['secondary_text'] ?? '';
                          
                          return ListTile(
                            leading: const Icon(Icons.location_on, color: Color(0xFF2FC1BE)),
                            title: Text(
                              mainText,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF1D2330),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: secondaryText.isNotEmpty
                                ? Text(
                                    secondaryText,
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                            onTap: () => _selectSuggestion(suggestion),
                          );
                        },
                      ),
                    ),
                  
                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF2FC1BE),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Map
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF2FC1BE)))
                  : Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _selectedLocation,
                            zoom: 15,
                          ),
                          onMapCreated: (controller) {
                            print('Google Map created successfully');
                            _mapController = controller;
                          },
                          onTap: _onMapTap,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          mapType: MapType.normal,
                        ),
                        
                        // Center marker
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: const Color(0xFF2FC1BE),
                                size: 50,
                              ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2FC1BE),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // My location button
                        Positioned(
                          right: 16,
                          bottom: 100,
                          child: FloatingActionButton(
                            mini: true,
                            backgroundColor: theme.cardColor,
                            onPressed: () async {
                              try {
                                final position = await Geolocator.getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.high,
                                );
                                setState(() {
                                  _selectedLocation = LatLng(position.latitude, position.longitude);
                                });
                                _mapController?.animateCamera(
                                  CameraUpdate.newLatLng(_selectedLocation),
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
                      ],
                    ),
            ),
            
            // Bottom confirm bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF2FC1BE),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _currentAddress.isEmpty ? 'Tap on map to select location' : _currentAddress,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1D2330),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2FC1BE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text('Confirm Location'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
