import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:superapp/screens/map_location_picker_screen.dart';
import '../controllers/profile_controller.dart';
import '../services/listing_service.dart';

class AddPropertyScreen extends StatefulWidget {
  /// If editing, pass the property JSON map; null means "Add" mode.
  final Map<String, dynamic>? editPropertyData;

  const AddPropertyScreen({super.key, this.editPropertyData});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  // State variables for selections
  String _selectedPropertyType = 'Villa';
  String _listingType = 'For Sale';
  final List<String> _selectedAmenities = ['Wifi', 'Parking', 'Pool'];
  final List<String> _selectedInsights = [];
  final List<XFile> _selectedImages = [];
  bool _isLoading = false;
  
  // Location state
  double _latitude = 0;
  double _longitude = 0;

  bool get _isEditMode => widget.editPropertyData != null;
  int? get _editPropertyId => widget.editPropertyData?['id'] as int?;

  // Keep track of existing image count (from backend) for edit mode
  int _existingImageCount = 0;

  static const String _googleApiKey = 'AIzaSyCllvLEMmJTFyydQ7VKmgxtBAUrJyPLf5c';
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _sqftController = TextEditingController();
  final TextEditingController _customInsightController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final ListingService _listingService = ListingService();

  ImageProvider _imageProviderForXFile(XFile file) {
    if (kIsWeb) {
      return NetworkImage(file.path);
    }
    return FileImage(File(file.path));
  }

  final List<String> _propertyTypes = ['Villa', 'Apartment', 'House', 'Condo'];

  // Map frontend display names to backend Prisma enum values
  static const Map<String, String> _typeToEnum = {
    'Villa': 'VILLA',
    'Apartment': 'BUNGALOW',
    'House': 'BUNGALOW',
    'Condo': 'PALACE',
  };

  static const Map<String, String> _enumToType = {
    'VILLA': 'Villa',
    'BUNGALOW': 'Apartment',
    'PALACE': 'Condo',
  };

  final List<String> _amenities = [
    'Wifi',
    'Parking',
    'Washer',
    'Gym',
    'Balcony',
    'Air Conditioning',
    'Pool',
    'Heating',
    'Dryer',
    'Elevator',
  ];

  final List<Map<String, dynamic>> _insightOptions = [
    {'label': 'School', 'icon': Icons.school_outlined},
    {'label': 'Shopping', 'icon': Icons.shopping_bag_outlined},
    {'label': 'Transportation', 'icon': Icons.directions_bus_outlined},
    {'label': 'Hospital', 'icon': Icons.local_hospital_outlined},
    {'label': 'Park', 'icon': Icons.park_outlined},
    {'label': 'Restaurant', 'icon': Icons.restaurant_outlined},
    {'label': 'Café', 'icon': Icons.coffee_outlined},
    {'label': 'Bank', 'icon': Icons.account_balance_outlined},
    {'label': 'Gym', 'icon': Icons.fitness_center_outlined},
    {'label': 'Pharmacy', 'icon': Icons.local_pharmacy_outlined},
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _populateFromEditData();
    }
  }

  void _populateFromEditData() {
    final data = widget.editPropertyData!;
    _titleController.text = (data['title'] ?? '') as String;
    _descriptionController.text = (data['description'] ?? '') as String;
    _locationController.text = (data['address'] ?? '') as String;
    _priceController.text = (data['price'] ?? '').toString();
    _bedroomsController.text = (data['rooms'] ?? '').toString();
    _bathroomsController.text = (data['bathrooms'] ?? '').toString();
    _sqftController.text = (data['area'] ?? '').toString();

    final listingTypeEnum = data['listingType'] as String?;
    if (listingTypeEnum == 'FOR_RENT') {
      _listingType = 'For Rent';
    } else if (listingTypeEnum == 'FOR_SALE') {
      _listingType = 'For Sale';
    }

    // Property type
    final typeEnum = data['type'] as String?;
    if (typeEnum != null && _enumToType.containsKey(typeEnum)) {
      _selectedPropertyType = _enumToType[typeEnum]!;
    }

    // Amenities
    final amenities = data['amenities'] as List<dynamic>?;
    if (amenities != null) {
      _selectedAmenities.clear();
      for (final a in amenities) {
        _selectedAmenities.add(a.toString());
      }
    }

    // Neighborhood insights
    final insights = data['neighborhoodInsights'] as List<dynamic>?;
    if (insights != null) {
      _selectedInsights.clear();
      for (final i in insights) {
        _selectedInsights.add(i.toString());
      }
    }

    // Existing images count (displayed via proxy)
    final images = data['images'] as List<dynamic>?;
    _existingImageCount = images?.length ?? 0;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _sqftController.dispose();
    _customInsightController.dispose();
    super.dispose();
  }

  String get _token {
    try {
      final profile = Get.find<ProfileController>();
      return profile.token;
    } catch (_) {
      return '';
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        // Limit to 5 images
        final availableSlots = 5 - _selectedImages.length;
        if (availableSlots > 0) {
          _selectedImages.addAll(images.take(availableSlots));
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitProperty() async {
    if (_titleController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _priceController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all required fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final token = _token;
    if (token.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'You must be logged in to add a property',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bool isEdit = _isEditMode;
      final listingTypeEnum =
          _listingType == 'For Rent' ? 'FOR_RENT' : 'FOR_SALE';
      if (isEdit) {
        await _listingService.updateProperty(
          token: token,
          propertyId: _editPropertyId!,
          title: _titleController.text,
          description: _descriptionController.text,
          newImages: _selectedImages.isNotEmpty ? _selectedImages : null,
          address: _locationController.text,
          latitude: _latitude,
          longitude: _longitude,
          price: double.tryParse(_priceController.text),
          listingType: listingTypeEnum,
          area: double.tryParse(_sqftController.text),
          rooms: int.tryParse(_bedroomsController.text),
          bathrooms: int.tryParse(_bathroomsController.text),
          type: _typeToEnum[_selectedPropertyType],
          amenities: _selectedAmenities,
          neighborhoodInsights: _selectedInsights,
        );

        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Property updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        await _listingService.createProperty(
          token: token,
          title: _titleController.text,
          description: _descriptionController.text,
          images: _selectedImages,
          address: _locationController.text,
          price: double.parse(_priceController.text),
          latitude: _latitude,
          longitude: _longitude,
          listingType: listingTypeEnum,
          area: double.tryParse(_sqftController.text),
          rooms: int.tryParse(_bedroomsController.text),
          bathrooms: int.tryParse(_bathroomsController.text),
          type: _typeToEnum[_selectedPropertyType],
          amenities: _selectedAmenities,
          neighborhoodInsights: _selectedInsights,
        );

        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Property added successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to ${_isEditMode ? "update" : "add"} property: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

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
          _isEditMode ? 'Edit Property' : 'Add Property',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2FC1BE),
          ),
        ),
        centerTitle: false, // Aligned to left
        titleSpacing: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Images
            _SectionLabel('Property Images'),
            const SizedBox(height: 12),

            // Show existing images from backend in edit mode
            if (_isEditMode && _existingImageCount > 0) ...[
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImageCount,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          ListingService.propertyImageUrl(
                            _editPropertyId!,
                            index,
                          ),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text('Add new images below (existing images are preserved)'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 8),
            ],

            if (_selectedImages.isEmpty)
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 140,
                  height: 120,
                  decoration: DottedDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF9CA3AF),
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text('Add Photo'.tr,
                        style: GoogleFonts.outfit(
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF9CA3AF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      _selectedImages.length +
                      (_selectedImages.length < 5 ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      // Add more button
                      return GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: DottedDecoration(
                            color: isDark
                                ? Colors.white24
                                : const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF9CA3AF),
                              size: 32,
                            ),
                          ),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: _imageProviderForXFile(
                                _selectedImages[index],
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 16,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),

            // Property Name
            _SectionLabel('Property Name'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _titleController,
              hint: 'Enter property name',
            ),
            const SizedBox(height: 24),

            // Property Type
            _SectionLabel('Property Type'),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _propertyTypes.map((type) {
                  final isSelected = _selectedPropertyType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPropertyType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2FC1BE)
                              : (isDark ? theme.cardColor : Colors.white),
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
                          type,
                          style: GoogleFonts.outfit(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.white70
                                      : const Color(0xFF4B5563)),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Listing Type
            _SectionLabel('Listing Type'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _listingType = 'For Sale'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _listingType == 'For Sale'
                            ? const Color(0xFF2FC1BE)
                            : (isDark ? theme.cardColor : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: _listingType == 'For Sale'
                            ? null
                            : Border.all(
                                color: isDark
                                    ? Colors.white24
                                    : const Color(0xFFE5E7EB),
                              ),
                      ),
                      child: Text('For Sale'.tr,
                        style: GoogleFonts.outfit(
                          color: _listingType == 'For Sale'
                              ? Colors.white
                              : (isDark
                                    ? Colors.white70
                                    : const Color(0xFF4B5563)),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _listingType = 'For Rent'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _listingType == 'For Rent'
                            ? const Color(0xFF2FC1BE)
                            : (isDark ? theme.cardColor : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: _listingType == 'For Rent'
                            ? null
                            : Border.all(
                                color: isDark
                                    ? Colors.white24
                                    : const Color(0xFFE5E7EB),
                              ),
                      ),
                      child: Text('For Rent'.tr,
                        style: GoogleFonts.outfit(
                          color: _listingType == 'For Rent'
                              ? Colors.white
                              : (isDark
                                    ? Colors.white70
                                    : const Color(0xFF4B5563)),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Price
            _SectionLabel('Price'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _priceController,
              hint: '0.00',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Location
            _SectionLabel('Location'),
            const SizedBox(height: 12),
            _buildPlacesAutoCompleteField(
              theme: theme,
              isDark: isDark,
              controller: _locationController,
              hintText: 'Enter address'.tr,
            ),
            const SizedBox(height: 24),

            // Property Details
            _SectionLabel('Property Details'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailInput(
                    controller: _bedroomsController,
                    label: 'Bedrooms',
                    hint: '0',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailInput(
                    controller: _bathroomsController,
                    label: 'Bathrooms',
                    hint: '0',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailInput(
                    controller: _sqftController,
                    label: 'Sqft',
                    hint: '0',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amenities
            _SectionLabel('Amenities'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _amenities.map((amenity) {
                final isSelected = _selectedAmenities.contains(amenity);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedAmenities.remove(amenity);
                      } else {
                        _selectedAmenities.add(amenity);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2FC1BE)
                          : (isDark ? theme.cardColor : Colors.white),
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
                      amenity,
                      style: GoogleFonts.outfit(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? Colors.white70
                                  : const Color(0xFF4B5563)),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Neighborhood Insights
            _SectionLabel('Neighborhood Insights'),
            const SizedBox(height: 4),
            Text('What\'s nearby? Help buyers know the area.'.tr,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _insightOptions.map((option) {
                final label = option['label'] as String;
                final icon = option['icon'] as IconData;
                final isSelected = _selectedInsights.contains(label);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedInsights.remove(label);
                      } else {
                        _selectedInsights.add(label);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2FC1BE)
                          : (isDark ? theme.cardColor : Colors.white),
                      borderRadius: BorderRadius.circular(30),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: isDark
                                  ? Colors.white24
                                  : const Color(0xFFE5E7EB),
                            ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.white54
                                    : const Color(0xFF6B7280)),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: GoogleFonts.outfit(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.white70
                                      : const Color(0xFF4B5563)),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // Custom insights that were added
            if (_selectedInsights.any(
              (i) => !_insightOptions.any((o) => o['label'] == i),
            )) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedInsights
                    .where((i) => !_insightOptions.any((o) => o['label'] == i))
                    .map((custom) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2FC1BE),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.place_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              custom,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedInsights.remove(custom);
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                    .toList(),
              ),
            ],

            const SizedBox(height: 12),
            // Add custom insight
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _customInsightController,
                    hint: 'Add custom (e.g. Metro Station)',
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    final text = _customInsightController.text.trim();
                    if (text.isNotEmpty && !_selectedInsights.contains(text)) {
                      setState(() {
                        _selectedInsights.add(text);
                        _customInsightController.clear();
                      });
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2FC1BE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            _SectionLabel('Description'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _descriptionController,
              hint: 'Describe your property...',
              maxLines: 5,
            ),
            const SizedBox(height: 32),

            // Add/Update Property Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitProperty,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2FC1BE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  textStyle: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_isEditMode ? 'Update Property' : 'Add Property'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacesAutoCompleteField({
    required ThemeData theme,
    required bool isDark,
    required TextEditingController controller,
    required String hintText,
  }) {
    final inputDecoration = InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.outfit(
        color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: isDark ? theme.cardColor : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white24 : const Color(0xFF9CA3AF),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2FC1BE), width: 1.5),
      ),
      suffixIcon: IconButton(
        icon: const Icon(Icons.location_on, color: Color(0xFF2FC1BE)),
        onPressed: () async {
          print('Opening MapLocationPickerScreen from AddPropertyScreen');
          final result = await Get.to(
            () => MapLocationPickerScreen(
              initialLatitude: _latitude,
              initialLongitude: _longitude,
              initialAddress: controller.text,
            ),
          );
          print('Returned from MapLocationPickerScreen with result: $result');
          if (result != null) {
            print('Setting address: ${result['address']}, lat: ${result['latitude']}, lng: ${result['longitude']}');
            controller.text = result['address'] ?? '';
            setState(() {
              _latitude = result['latitude'] ?? 0;
              _longitude = result['longitude'] ?? 0;
            });
          }
        },
      ),
    );

    return GooglePlaceAutoCompleteTextField(
      textEditingController: controller,
      googleAPIKey: _googleApiKey,
      inputDecoration: inputDecoration,
      debounceTime: 800,
      isLatLngRequired: false,
      getPlaceDetailWithLatLng: (prediction) {},
      itemClick: (prediction) {
        final description = prediction.description ?? '';
        controller.text = description;
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: description.length),
        );
      },
      itemBuilder: (context, index, prediction) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white12 : const Color(0xFFE5E7EB),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  prediction.description ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      seperatedBuilder: const SizedBox.shrink(),
      isCrossBtnShown: true,
      containerHorizontalPadding: 0,
    );
  }

  Widget _buildTextField({
    required String hint,
    int maxLines = 1,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isDark = Get.isDarkMode;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(
          color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: isDark ? Theme.of(context).cardColor : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : const Color(0xFF9CA3AF),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2FC1BE), width: 1.5),
        ),
      ),
      style: GoogleFonts.outfit(
        color: isDark ? Colors.white : const Color(0xFF1F2937),
        fontSize: 16,
      ),
    );
  }

  Widget _buildDetailInput({
    required String label,
    required String hint,
    TextEditingController? controller,
  }) {
    final isDark = Get.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: controller,
          hint: hint,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: Get.isDarkMode ? Colors.white : const Color(0xFF374151),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// Custom painter for dotted border decoration
class DottedDecoration extends Decoration {
  final Color color;
  final BorderRadius borderRadius;

  const DottedDecoration({required this.color, required this.borderRadius});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DottedBoxPainter(color, borderRadius);
  }
}

class _DottedBoxPainter extends BoxPainter {
  final Color color;
  final BorderRadius borderRadius;

  _DottedBoxPainter(this.color, this.borderRadius);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rect = offset & configuration.size!;
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance)!.position;
        final end = metric
            .getTangentForOffset(distance + 4)!
            .position; // Dash length
        canvas.drawLine(start, end, paint);
        distance += 8; // Dash length + Gap length
      }
    }
  }
}
