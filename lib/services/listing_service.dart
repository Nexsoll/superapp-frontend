import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class ListingService {
  static String get baseUrl => ApiService.baseUrl;

  /// Returns a proxied image URL for a hotel image stored in private GCS bucket.
  static String hotelImageUrl(int hotelId, int imageIndex) {
    return '$baseUrl/listing/hotel-image/$hotelId/$imageIndex';
  }

  /// Returns a proxied image URL for a room image stored in private GCS bucket.
  static String roomImageUrl(int roomId) {
    return '$baseUrl/listing/room-image/$roomId';
  }

  /// Returns a proxied image URL for a property image stored in private GCS bucket.
  static String propertyImageUrl(int propertyId, int imageIndex) {
    return '$baseUrl/listing/property-image/$propertyId/$imageIndex';
  }

  /// Returns a proxied image URL for a user avatar stored in private GCS bucket.
  static String avatarImageUrl(String avatarUrl) {
    // Extract the filename from the GCS URL
    final uri = Uri.parse(avatarUrl);
    final filename = uri.pathSegments.last;
    return '$baseUrl/listing/avatar-image/$filename';
  }

  Map<String, String> _headers({String? token}) {
    final headers = <String, String>{};
    final t = (token ?? '').trim();
    if (t.isNotEmpty) {
      headers['Authorization'] = 'Bearer $t';
    }
    return headers;
  }

  Future<Map<String, dynamic>> createProperty({
    required String token,
    required String title,
    required String description,
    required List<XFile> images,
    required String address,
    required double price,
    required double latitude,
    required double longitude,
    String? listingType,
    double? area,
    int? rooms,
    int? bathrooms,
    String? type,
    List<String>? amenities,
    List<String>? neighborhoodInsights,
  }) async {
    final uri = Uri.parse('$baseUrl/listing/add-property');

    final request = http.MultipartRequest('POST', uri);

    // Add fields
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['address'] = address;
    request.fields['price'] = price.toString();
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    if (listingType != null) request.fields['listingType'] = listingType;
    if (area != null) request.fields['area'] = area.toString();
    if (rooms != null) request.fields['rooms'] = rooms.toString();
    if (bathrooms != null) request.fields['bathrooms'] = bathrooms.toString();
    if (type != null) request.fields['type'] = type;
    if (amenities != null && amenities.isNotEmpty) {
      for (int i = 0; i < amenities.length; i++) {
        request.fields['amenities[$i]'] = amenities[i];
      }
    }
    if (neighborhoodInsights != null && neighborhoodInsights.isNotEmpty) {
      for (int i = 0; i < neighborhoodInsights.length; i++) {
        request.fields['neighborhoodInsights[$i]'] = neighborhoodInsights[i];
      }
    }

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add images
    for (final image in images) {
      final file = File(image.path);
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();

      final multipartFile = http.MultipartFile(
        'images',
        stream,
        length,
        filename: image.name,
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to create property: $responseBody');
    }
  }

  Future<Map<String, dynamic>> updateProperty({
    required String token,
    required int propertyId,
    String? title,
    String? description,
    List<XFile>? newImages,
    String? address,
    double? latitude,
    double? longitude,
    double? price,
    String? listingType,
    double? area,
    int? rooms,
    int? bathrooms,
    String? type,
    List<String>? amenities,
    List<String>? neighborhoodInsights,
  }) async {
    final uri = Uri.parse('$baseUrl/listing/update-property/$propertyId');

    final request = http.MultipartRequest('PATCH', uri);

    if (title != null) request.fields['title'] = title;
    if (description != null) request.fields['description'] = description;
    if (address != null) request.fields['address'] = address;
    if (latitude != null) request.fields['latitude'] = latitude.toString();
    if (longitude != null) request.fields['longitude'] = longitude.toString();
    if (price != null) request.fields['price'] = price.toString();
    if (listingType != null) request.fields['listingType'] = listingType;
    if (area != null) request.fields['area'] = area.toString();
    if (rooms != null) request.fields['rooms'] = rooms.toString();
    if (bathrooms != null) request.fields['bathrooms'] = bathrooms.toString();
    if (type != null) request.fields['type'] = type;
    if (amenities != null && amenities.isNotEmpty) {
      for (int i = 0; i < amenities.length; i++) {
        request.fields['amenities[$i]'] = amenities[i];
      }
    }
    if (neighborhoodInsights != null && neighborhoodInsights.isNotEmpty) {
      for (int i = 0; i < neighborhoodInsights.length; i++) {
        request.fields['neighborhoodInsights[$i]'] = neighborhoodInsights[i];
      }
    }

    request.headers['Authorization'] = 'Bearer $token';

    if (newImages != null) {
      for (final image in newImages) {
        final file = File(image.path);
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();

        final multipartFile = http.MultipartFile(
          'images',
          stream,
          length,
          filename: image.name,
          contentType: MediaType('image', 'jpeg'),
        );

        request.files.add(multipartFile);
      }
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to update property: $responseBody');
    }
  }

  Future<Map<String, dynamic>> deleteProperty({
    required String token,
    required int propertyId,
  }) async {
    final uri = Uri.parse('$baseUrl/listing/delete-property/$propertyId');
    final response = await http.delete(uri, headers: _headers(token: token));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete property: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> togglePropertyStatus({
    required String token,
    required int propertyId,
    required bool isActive,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/listing/toggle-property-status/$propertyId',
    );
    final response = await http.patch(
      uri,
      headers: {
        ..._headers(token: token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'isActive': isActive}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to toggle property status: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createHotel({
    required String token,
    required String title,
    required String description,
    required List<XFile> images,
    required String address,
    double? latitude,
    double? longitude,
    List<String>? amenities,
    List<Map<String, dynamic>>? rooms,
    List<XFile?>? roomImages,
  }) async {
    final uri = Uri.parse('$baseUrl/listing/add-hotel');

    final request = http.MultipartRequest('POST', uri);

    // Add fields
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['address'] = address;
    if (latitude != null) request.fields['latitude'] = latitude.toString();
    if (longitude != null) request.fields['longitude'] = longitude.toString();
    if (amenities != null && amenities.isNotEmpty) {
      for (int i = 0; i < amenities.length; i++) {
        request.fields['amenities[$i]'] = amenities[i];
      }
    }
    if (rooms != null && rooms.isNotEmpty) {
      request.fields['rooms'] = jsonEncode(rooms);
    }

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add images
    for (final image in images) {
      final file = File(image.path);
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();

      final multipartFile = http.MultipartFile(
        'images',
        stream,
        length,
        filename: image.name,
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);
    }

    // Add room images
    if (roomImages != null) {
      for (final roomImage in roomImages) {
        if (roomImage != null) {
          final file = File(roomImage.path);
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();

          final multipartFile = http.MultipartFile(
            'roomImages',
            stream,
            length,
            filename: roomImage.name,
            contentType: MediaType('image', 'jpeg'),
          );

          request.files.add(multipartFile);
        }
      }
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to create hotel: $responseBody');
    }
  }

  Future<Map<String, dynamic>> updateHotel({
    required String token,
    required int hotelId,
    String? title,
    String? description,
    List<XFile>? newImages,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? amenities,
    List<Map<String, dynamic>>? rooms,
    List<XFile?>? roomImages,
  }) async {
    final uri = Uri.parse('$baseUrl/listing/update-hotel/$hotelId');

    final request = http.MultipartRequest('PATCH', uri);

    if (title != null) request.fields['title'] = title;
    if (description != null) request.fields['description'] = description;
    if (address != null) request.fields['address'] = address;
    if (latitude != null) request.fields['latitude'] = latitude.toString();
    if (longitude != null) request.fields['longitude'] = longitude.toString();
    if (amenities != null && amenities.isNotEmpty) {
      for (int i = 0; i < amenities.length; i++) {
        request.fields['amenities[$i]'] = amenities[i];
      }
    }

    if (rooms != null && rooms.isNotEmpty) {
      request.fields['rooms'] = jsonEncode(rooms);
    }

    request.headers['Authorization'] = 'Bearer $token';

    if (newImages != null) {
      for (final image in newImages) {
        final file = File(image.path);
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();

        final multipartFile = http.MultipartFile(
          'images',
          stream,
          length,
          filename: image.name,
          contentType: MediaType('image', 'jpeg'),
        );

        request.files.add(multipartFile);
      }
    }

    // Add room images
    if (roomImages != null) {
      for (final roomImage in roomImages) {
        if (roomImage != null) {
          final file = File(roomImage.path);
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();

          final multipartFile = http.MultipartFile(
            'roomImages',
            stream,
            length,
            filename: roomImage.name,
            contentType: MediaType('image', 'jpeg'),
          );

          request.files.add(multipartFile);
        }
      }
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to update hotel: $responseBody');
    }
  }

  Future<Map<String, dynamic>> deleteHotel({
    required String token,
    required int hotelId,
  }) async {
    final uri = Uri.parse('$baseUrl/listing/delete-hotel/$hotelId');
    final response = await http.delete(uri, headers: _headers(token: token));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete hotel: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> toggleHotelStatus({
    required String token,
    required int hotelId,
    required bool isActive,
  }) async {
    final uri = Uri.parse('$baseUrl/listing/toggle-hotel-status/$hotelId');
    final response = await http.patch(
      uri,
      headers: {
        ..._headers(token: token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'isActive': isActive}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to toggle hotel status: ${response.body}');
    }
  }

  Future<List<dynamic>> getAllProperties() async {
    final uri = Uri.parse('$baseUrl/listing/get-all-properties');
    final response = await http.get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get properties: ${response.body}');
    }
  }

  Future<List<dynamic>> getMyProperties(String token) async {
    final uri = Uri.parse('$baseUrl/listing/get-my-properties');
    final response = await http.get(uri, headers: _headers(token: token));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get my properties: ${response.body}');
    }
  }

  Future<List<dynamic>> getAllHotels() async {
    final uri = Uri.parse('$baseUrl/listing/get-all-hotels');
    final response = await http.get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get hotels: ${response.body}');
    }
  }

  Future<List<dynamic>> getMyHotels(String token) async {
    final uri = Uri.parse('$baseUrl/listing/get-my-hotels');
    final response = await http.get(uri, headers: _headers(token: token));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get my hotels: ${response.body}');
    }
  }

  /// Fetches AI-powered investment analysis for a property.
  Future<Map<String, dynamic>> getPropertyAnalysis(int propertyId) async {
    final uri = Uri.parse('$baseUrl/listing/property-analysis/$propertyId');
    final response = await http.get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get property analysis: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getHotelById(int hotelId) async {
    final uri = Uri.parse('$baseUrl/listing/hotel/$hotelId');
    final response = await http.get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get hotel: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getPropertyById(int propertyId) async {
    final uri = Uri.parse('$baseUrl/listing/property/$propertyId');
    final response = await http.get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get property: ${response.body}');
    }
  }
}
