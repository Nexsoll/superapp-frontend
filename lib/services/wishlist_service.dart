import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class WishlistService {
  static String get baseUrl => '${ApiService.baseUrl}/wishlist';

  Map<String, String> _headers({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final t = (token ?? '').trim();
    if (t.isNotEmpty) {
      headers['Authorization'] = 'Bearer $t';
    }
    return headers;
  }

  Future<Map<String, dynamic>> addPropertyToWishlist({
    required String token,
    required int propertyId,
  }) async {
    final url = Uri.parse('$baseUrl/add-property/$propertyId');
    try {
      final response = await http.post(url, headers: _headers(token: token));
      return _handleResponse(response, 'add property to wishlist');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> addHotelToWishlist({
    required String token,
    required int hotelId,
  }) async {
    final url = Uri.parse('$baseUrl/add-hotel/$hotelId');
    try {
      final response = await http.post(url, headers: _headers(token: token));
      return _handleResponse(response, 'add hotel to wishlist');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> removePropertyFromWishlist({
    required String token,
    required int propertyId,
  }) async {
    final url = Uri.parse('$baseUrl/remove-property/$propertyId');
    try {
      final response = await http.delete(url, headers: _headers(token: token));
      return _handleResponse(response, 'remove property from wishlist');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> removeHotelFromWishlist({
    required String token,
    required int hotelId,
  }) async {
    final url = Uri.parse('$baseUrl/remove-hotel/$hotelId');
    try {
      final response = await http.delete(url, headers: _headers(token: token));
      return _handleResponse(response, 'remove hotel from wishlist');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> getMyWishlist({
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/my-wishlist');
    try {
      final response = await http.get(url, headers: _headers(token: token));
      return _handleResponse(response, 'get wishlist');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> getPropertyCostBreakdown({
    required String token,
    required int propertyId,
  }) async {
    final url = Uri.parse('$baseUrl/property-cost-breakdown/$propertyId');
    try {
      final response = await http.get(url, headers: _headers(token: token));
      return _handleResponse(response, 'get property cost breakdown');
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<bool> isPropertyInWishlist({
    required String token,
    required int propertyId,
  }) async {
    final url = Uri.parse('$baseUrl/check-property/$propertyId');
    try {
      final response = await http.get(url, headers: _headers(token: token));
      final data = _handleResponse(response, 'check property in wishlist');
      return data['inWishlist'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isHotelInWishlist({
    required String token,
    required int hotelId,
  }) async {
    final url = Uri.parse('$baseUrl/check-hotel/$hotelId');
    try {
      final response = await http.get(url, headers: _headers(token: token));
      final data = _handleResponse(response, 'check hotel in wishlist');
      return data['inWishlist'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response, String action) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      try {
        final body = jsonDecode(response.body);
        final message = body['message'] ?? body['error'] ?? 'Unknown error';
        throw Exception('Failed to $action: $message');
      } catch (_) {
        throw Exception('Failed to $action: ${response.body}');
      }
    }
  }
}
