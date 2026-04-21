import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:superapp/screens/map_location_picker_screen.dart';
import '../controllers/profile_controller.dart';
import '../services/listing_service.dart';

class AddHotelScreen extends StatefulWidget {
  /// If editing, pass the hotel JSON map; null means "Add" mode.
  final Map<String, dynamic>? editHotelData;

  const AddHotelScreen({super.key, this.editHotelData});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final List<String> _selectedAmenities = ['Wifi', 'Breakfast', 'Pool'];
  final List<XFile> _selectedImages = [];
  bool _isLoading = false;
  
  // Location state
  double _latitude = 0;
  double _longitude = 0;

  bool get _isEditMode => widget.editHotelData != null;
  int? get _editHotelId => widget.editHotelData?['id'] as int?;

  static const String _googleApiKey = 'AIzaSyCllvLEMmJTFyydQ7VKmgxtBAUrJyPLf5c';
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<TextEditingController> _roomNameControllers = [];
  final List<TextEditingController> _roomPriceControllers = [];
  final List<XFile?> _roomImages = [];
  final List<String?> _existingRoomImageUrls = [];
  final List<int?> _existingRoomIds = [];

  final ImagePicker _picker = ImagePicker();
  final ListingService _listingService = ListingService();

  // Keep track of existing image count (from backend) for edit mode
  int _existingImageCount = 0;

  final List<String> _amenities = [
    'Wifi',
    'Breakfast',
    'Parking',
    'Pool',
    'Gym',
    'Spa',
    'Air Conditioning',
    'Room Service',
    'Pet Friendly',
    'Airport Shuttle',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _populateFromEditData();
    } else {
      _addRoom();
    }
  }

  void _populateFromEditData() {
    final data = widget.editHotelData!;
    _titleController.text = (data['title'] ?? '') as String;
    _descriptionController.text = (data['description'] ?? '') as String;
    _locationController.text = (data['address'] ?? '') as String;

    // Amenities
    final amenities = data['amenities'] as List<dynamic>?;
    if (amenities != null) {
      _selectedAmenities.clear();
      for (final a in amenities) {
        _selectedAmenities.add(a.toString());
      }
    }

    // Existing images count (displayed via proxy)
    final images = data['images'] as List<dynamic>?;
    _existingImageCount = images?.length ?? 0;

    // Rooms
    final rooms = data['rooms'] as List<dynamic>?;
    if (rooms != null && rooms.isNotEmpty) {
      for (final room in rooms) {
        _roomNameControllers.add(
          TextEditingController(text: (room['title'] ?? '') as String),
        );
        _roomPriceControllers.add(
          TextEditingController(text: (room['price'] ?? '').toString()),
        );
        _roomImages.add(null);

        final roomId = room['id'] as int?;
        _existingRoomIds.add(roomId);

        final hasImage =
            room['image'] != null && room['image'].toString().isNotEmpty;
        if (hasImage && roomId != null) {
          _existingRoomImageUrls.add(ListingService.roomImageUrl(roomId));
        } else {
          _existingRoomImageUrls.add(null);
        }
      }
    } else {
      _addRoom();
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    for (final c in _roomNameControllers) {
      c.dispose();
    }
    for (final c in _roomPriceControllers) {
      c.dispose();
    }
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

  Future<void> _submitHotel() async {
    if (_titleController.text.isEmpty || _locationController.text.isEmpty) {
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
        'You must be logged in to add a hotel',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Collect room data from form
      final List<Map<String, dynamic>> roomsData = [];
      final List<XFile?> roomImagesForUpload = [];
      int validImageIndex = 0;

      for (int i = 0; i < _roomNameControllers.length; i++) {
        final name = _roomNameControllers[i].text.trim();
        final priceStr = _roomPriceControllers[i].text.trim();

        if (name.isNotEmpty && priceStr.isNotEmpty) {
          int? imgIdx;
          if (_roomImages[i] != null) {
            imgIdx = validImageIndex++;
          }

          roomsData.add({
            'id': i < _existingRoomIds.length ? _existingRoomIds[i] : null,
            'title': name,
            'price': double.tryParse(priceStr) ?? 0,
            'imageIndex': imgIdx,
          });
          roomImagesForUpload.add(_roomImages[i]);
        }
      }

      final bool isEdit = _isEditMode;
      if (isEdit) {
        await _listingService.updateHotel(
          token: token,
          hotelId: _editHotelId!,
          title: _titleController.text,
          description: _descriptionController.text,
          address: _locationController.text,
          latitude: _latitude,
          longitude: _longitude,
          amenities: _selectedAmenities,
          newImages: _selectedImages.isNotEmpty ? _selectedImages : null,
          rooms: roomsData,
          roomImages: roomImagesForUpload,
        );
      } else {
        await _listingService.createHotel(
          token: token,
          title: _titleController.text,
          description: _descriptionController.text,
          images: _selectedImages,
          address: _locationController.text,
          latitude: _latitude,
          longitude: _longitude,
          amenities: _selectedAmenities,
          rooms: roomsData,
          roomImages: roomImagesForUpload,
        );
      }
      Get.back(result: true);
      // Show snackbar after navigating back so it appears on the listing screen
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Success',
          isEdit ? 'Hotel updated successfully!' : 'Hotel added successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to ${_isEditMode ? "update" : "add"} hotel: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addRoom() {
    setState(() {
      _roomNameControllers.add(TextEditingController());
      _roomPriceControllers.add(TextEditingController());
      _roomImages.add(null);
      _existingRoomImageUrls.add(null);
      _existingRoomIds.add(null);
    });
  }

  void _removeRoom(int index) {
    setState(() {
      _roomNameControllers[index].dispose();
      _roomPriceControllers[index].dispose();
      _roomNameControllers.removeAt(index);
      _roomPriceControllers.removeAt(index);
      _roomImages.removeAt(index);
      _existingRoomImageUrls.removeAt(index);
      _existingRoomIds.removeAt(index);
    });
  }

  Widget _buildAddPhotoPlaceholder(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_rounded,
          size: 32,
          color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
        ),
        const SizedBox(height: 8),
        Text('Add Room Image'.tr,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
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
          _isEditMode ? 'Edit Hotel' : 'Add Hotel',
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
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel('Hotel Images'),
            const SizedBox(height: 12),

            // Show existing images from server in edit mode
            if (_isEditMode && _existingImageCount > 0) ...[
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImageCount,
                  itemBuilder: (context, index) {
                    final imageUrl = ListingService.hotelImageUrl(
                      _editHotelId!,
                      index,
                    );
                    return Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2FC1BE).withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text('Current images (upload new to replace)'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (_selectedImages.isEmpty &&
                !(_isEditMode && _existingImageCount > 0))
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
            else if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      _selectedImages.length +
                      (_selectedImages.length < 5 ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
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
                              image: FileImage(
                                File(_selectedImages[index].path),
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
              )
            else if (_isEditMode && _existingImageCount > 0)
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
                        Icons.add_photo_alternate_outlined,
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF9CA3AF),
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text('New Photos'.tr,
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
              ),
            const SizedBox(height: 24),
            _SectionLabel('Hotel Name'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _titleController,
              hint: 'Enter hotel name',
            ),
            const SizedBox(height: 24),
            _SectionLabel('Location'),
            const SizedBox(height: 12),
            _buildPlacesAutoCompleteField(
              theme: theme,
              isDark: isDark,
              controller: _locationController,
              hintText: 'Enter address'.tr,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionLabel('Rooms'),
                TextButton.icon(
                  onPressed: _addRoom,
                  icon: const Icon(Icons.add, color: Color(0xFF2FC1BE)),
                  label: Text('Add Room'.tr,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF2FC1BE),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: List.generate(_roomNameControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardColor : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white24
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Room ${index + 1}',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1F2937),
                                ),
                              ),
                            ),
                            if (_roomNameControllers.length > 1)
                              IconButton(
                                onPressed: () => _removeRoom(index),
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _roomNameControllers[index],
                          decoration: InputDecoration(
                            hintText: 'Room name'.tr,
                            hintStyle: GoogleFonts.outfit(
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF9CA3AF),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? theme.scaffoldBackgroundColor
                                : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? Colors.white24
                                    : const Color(0xFF9CA3AF),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF2FC1BE),
                                width: 1.5,
                              ),
                            ),
                          ),
                          style: GoogleFonts.outfit(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1F2937),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _roomPriceControllers[index],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Price per night'.tr,
                            hintStyle: GoogleFonts.outfit(
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF9CA3AF),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? theme.scaffoldBackgroundColor
                                : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? Colors.white24
                                    : const Color(0xFF9CA3AF),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF2FC1BE),
                                width: 1.5,
                              ),
                            ),
                          ),
                          style: GoogleFonts.outfit(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1F2937),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Room image picker
                        GestureDetector(
                          onTap: () async {
                            final picked = await _picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 1200,
                              maxHeight: 900,
                              imageQuality: 85,
                            );
                            if (picked != null) {
                              setState(() {
                                _roomImages[index] = picked;
                              });
                            }
                          },
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? theme.scaffoldBackgroundColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white24
                                    : const Color(0xFF9CA3AF),
                                width: 1,
                              ),
                            ),
                            child: _roomImages[index] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(11),
                                    child: Image.file(
                                      File(_roomImages[index]!.path),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                : (_existingRoomImageUrls[index] != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            11,
                                          ),
                                          child: Image.network(
                                            _existingRoomImageUrls[index]!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder: (_, __, ___) =>
                                                _buildAddPhotoPlaceholder(
                                                  isDark,
                                                ),
                                          ),
                                        )
                                      : _buildAddPhotoPlaceholder(isDark)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
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
            _SectionLabel('Description'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _descriptionController,
              hint: 'Describe your hotel...',
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitHotel,
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
                    : Text(_isEditMode ? 'Update Hotel' : 'Add Hotel'),
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
          print('Opening MapLocationPickerScreen from AddHotelScreen');
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
  }) {
    final isDark = Get.isDarkMode;
    return TextField(
      controller: controller,
      maxLines: maxLines,
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
        final end = metric.getTangentForOffset(distance + 4)!.position;
        canvas.drawLine(start, end, paint);
        distance += 8;
      }
    }
  }
}
