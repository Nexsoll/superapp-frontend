import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superapp/services/api_service.dart';
import 'package:superapp/services/listing_service.dart';
import 'package:superapp/controllers/expanse_tracking_controller.dart';

class AddExpenseController extends GetxController {
  final amountCtrl = TextEditingController(text: "0.00");
  final descCtrl = TextEditingController();

  final property = ''.obs;
  final category = ''.obs;
  final date = ''.obs;
  final receiptName = ''.obs;
  final isLoading = false.obs;
  final isLoadingProperties = false.obs;

  // Real properties from backend - list of maps with id and title
  final userProperties = <Map<String, dynamic>>[].obs;
  final userHotels = <Map<String, dynamic>>[].obs;

  final categories = <String>["Maintenance", "Utilities", "Tax", "Other"];

  String? _token;
  int? _selectedPropertyId;
  int? _selectedHotelId;
  File? receiptFile;

  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadTokenAndFetchProperties();
  }

  Future<void> _loadTokenAndFetchProperties() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('user_token');
    if (_token != null && _token!.isNotEmpty) {
      await fetchUserListings();
    }
  }

  Future<void> fetchUserListings() async {
    isLoadingProperties.value = true;
    try {
      final listingService = ListingService();
      final results = await Future.wait([
        listingService.getMyProperties(_token!),
        listingService.getMyHotels(_token!),
      ]);

      userProperties.value = (results[0] as List<dynamic>).cast<Map<String, dynamic>>();
      userHotels.value = (results[1] as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching listings: $e');
    } finally {
      isLoadingProperties.value = false;
    }
  }

  // Get hotel/property names for dropdown
  List<String> get listingNames {
    final props = userProperties
        .map((p) => 'Property: ${p['title'] as String? ?? 'Untitled'}')
        .toList();
    final hotels = userHotels
        .map((h) => 'Hotel: ${h['title'] as String? ?? 'Untitled'}')
        .toList();
    return [...props, ...hotels];
  }

  void back() => Get.back();

  void pickProperty(String v) {
    property.value = v;

    _selectedPropertyId = null;
    _selectedHotelId = null;

    if (v.startsWith('Property: ')) {
      final title = v.replaceFirst('Property: ', '');
      final selectedProp = userProperties.firstWhereOrNull(
        (p) => p['title'] == title,
      );
      _selectedPropertyId = selectedProp?['id'] as int?;
    } else if (v.startsWith('Hotel: ')) {
      final title = v.replaceFirst('Hotel: ', '');
      final selectedHotel = userHotels.firstWhereOrNull(
        (h) => h['title'] == title,
      );
      _selectedHotelId = selectedHotel?['id'] as int?;
    }
  }

  void pickCategory(String v) => category.value = v;

  void pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDate: now,
    );
    if (picked == null) return;
    date.value =
        "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
  }

  void pickReceipt() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Upload Receipt'.tr,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_rounded,
                  color: Get.theme.colorScheme.primary,
                ),
                title: Text('Take a Photo'.tr),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library_rounded,
                  color: Get.theme.colorScheme.primary,
                ),
                title: Text('Choose from Gallery'.tr),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        receiptFile = File(pickedFile.path);
        receiptName.value = pickedFile.name;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> saveExpense() async {
    debugPrint('[AddExpense] saveExpense tapped');
    if (_token == null || _token!.isEmpty) {
      Get.snackbar("Error", "Please login to save expenses");
      return;
    }

    final amount = double.tryParse(amountCtrl.text);
    if (amount == null || amount <= 0) {
      Get.snackbar("Error", "Please enter a valid amount");
      return;
    }

    if (descCtrl.text.isEmpty) {
      Get.snackbar("Error", "Please enter a description");
      return;
    }

    Get.snackbar("Saving", "Please wait...");

    isLoading.value = true;

    try {
      // Map category string to enum value
      String? categoryValue;
      if (category.value == "Maintenance") {
        categoryValue = "MAINTENANCE";
      } else if (category.value == "Utilities") {
        categoryValue = "UTILITIES";
      } else if (category.value == "Tax") {
        categoryValue = "TAX";
      } else if (category.value == "Other") {
        categoryValue = "OTHER";
      }

      // Format date for API
      String? dateValue;
      if (date.value.isNotEmpty) {
        final parts = date.value.split('/');
        if (parts.length == 3) {
          dateValue = "${parts[2]}-${parts[0]}-${parts[1]}";
        }
      }

      // Upload receipt if selected
      String? receiptUrl;
      if (receiptFile != null) {
        Get.snackbar("Uploading", "Uploading receipt image...");
        final fileBytes = await receiptFile!.readAsBytes();
        final uploadResult = await ApiService.uploadReceipt(
          token: _token!,
          fileBytes: fileBytes,
          filename: receiptName.value,
        );
        receiptUrl = uploadResult['receiptUrl']?.toString();
      }

      await ApiService.createExpense(
        token: _token!,
        title: descCtrl.text,
        amount: amount,
        description: descCtrl.text,
        category: categoryValue,
        date: dateValue,
        propertyId: _selectedPropertyId,
        hotelId: _selectedHotelId,
        receiptUrl: receiptUrl,
      ).timeout(const Duration(seconds: 20));

      if (Get.isRegistered<ExpenseTrackingController>()) {
        await Get.find<ExpenseTrackingController>()
            .fetchExpenses(forceReloadToken: true);
      }

      Get.snackbar("Saved", "Expense saved successfully");
      Get.back(result: true);
    } catch (e) {
      debugPrint('[AddExpense] saveExpense error: $e');
      Get.snackbar(
        "Error",
        "Failed to save expense: ${e.toString()}",
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }
}
