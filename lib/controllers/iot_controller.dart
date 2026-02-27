import 'package:get/get.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/modal/iot_device_modal.dart';
import 'package:superapp/services/api_service.dart';
import 'package:superapp/services/listing_service.dart';

class IoTController extends GetxController {
  final devices = <IoTDevice>[].obs;
  final isLoading = false.obs;

  int get alertCount => devices.where((d) => d.status == 'Urgent').length;

  final properties = <dynamic>[].obs;
  final hotels = <dynamic>[].obs;
  final isLoadingListings = false.obs;

  String get _token {
    try {
      return Get.find<ProfileController>().token;
    } catch (_) {
      return '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchDevices();
    fetchListings();
  }

  Future<void> fetchDevices() async {
    final token = _token;
    if (token.isEmpty) return;

    isLoading.value = true;
    try {
      // Assuming we'll add this to ApiService
      final response = await ApiService.getIoTDevices(token);
      if (response != null) {
        devices.assignAll(
          (response as List).map((d) => IoTDevice.fromJson(d)).toList(),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch devices: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchListings() async {
    final token = _token;
    if (token.isEmpty) {
      print('IoTController: No token found, skipping listing fetch');
      return;
    }

    print('IoTController: Fetching listings for token: $token');
    isLoadingListings.value = true;
    try {
      final api = ListingService();

      // Fetch both 'my' and 'all' as a fallback or to see what's available
      final props = await api.getMyProperties(token);
      final hots = await api.getMyHotels(token);

      print(
        'IoTController: Fetched ${props.length} properties and ${hots.length} hotels',
      );

      properties.assignAll(props);
      hotels.assignAll(hots);

      // If still empty, maybe try getAll as fallback for admin?
      if (properties.isEmpty && hotels.isEmpty) {
        print(
          'IoTController: My listings empty, trying to fetch all as fallback',
        );
        final allProps = await api.getAllProperties();
        final allHots = await api.getAllHotels();
        print(
          'IoTController: Fetched ALL: ${allProps.length} properties and ${allHots.length} hotels',
        );
        properties.assignAll(allProps);
        hotels.assignAll(allHots);
      }
    } catch (e) {
      print('IoTController: Error fetching listings: $e');
    } finally {
      isLoadingListings.value = false;
    }
  }

  Future<void> addDevice({
    required String name,
    String? location,
    required String status,
    int? propertyId,
    int? hotelId,
  }) async {
    final token = _token;
    if (token.isEmpty) return;

    try {
      final success = await ApiService.createIoTDevice(
        token: token,
        name: name,
        location: location,
        status: status,
        propertyId: propertyId,
        hotelId: hotelId,
      );

      if (success) {
        fetchDevices(); // Refresh list
        Get.snackbar('Success', 'Device added successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add device: $e');
    }
  }

  Future<void> removeDevice(int id) async {
    final token = _token;
    if (token.isEmpty) return;

    try {
      final success = await ApiService.removeIoTDevice(token, id);
      if (success) {
        devices.removeWhere((device) => int.tryParse(device.id) == id);
        Get.snackbar('Success', 'Device removed successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove device: $e');
    }
  }
}
