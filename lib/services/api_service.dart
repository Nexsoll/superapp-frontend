import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String _devBaseUrlWebAndIOS = 'http://localhost:3000';
  static const String _devBaseUrlAndroidEmulator = 'http://10.0.2.2:3000';
  static const String _prodBaseUrl =
      'https://super-app-831462757011.asia-south1.run.app';

  static String get baseUrl {
    return _prodBaseUrl;
  }

  static const String hotelBookingsEndpoint = '/listing/hotel-bookings';
  static const String bookingsEndpoint = '/listing/bookings';
  static const String paypalCreateOrderEndpoint =
      '/payments/paypal/create-order';
  static const String paypalCaptureOrderEndpoint =
      '/payments/paypal/capture-order';
    static const String cashConfirmEndpoint = '/payments/cash/confirm';
  static const String transactionsEndpoint = '/payments/transactions';
  static const String ownerListingSummaryEndpoint = '/listing/owner-summary';
  static const String expensesEndpoint = '/expenses';
  static const String expenseSummaryEndpoint = '/expenses/summary';
  static const String expenseByCategoryEndpoint = '/expenses/by-category';
  static const String expenseInsightEndpoint = '/expenses/insight';
  static const String jobsEndpoint = '/admin/jobs';
  static const String staffEndpoint = '/admin/staff';
  static const String adminEndpoint = '/admin';

  // http://localhost:3000
  // https://super-app-831462757011.asia-south1.run.app
  static Map<String, String> headers({String? token}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static Future<http.Response> get(String endpoint, {String? token}) async {
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers(token: token),
    );
  }

  static Future<http.Response> post(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers(token: token),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> patch(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    return await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers(token: token),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> delete(String endpoint, {String? token}) async {
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers(token: token),
    );
  }

  static Future<Map<String, dynamic>> createHotelBooking({
    required String token,
    required int hotelId,
    required DateTime checkIn,
    required DateTime checkOut,
    required List<Map<String, dynamic>> rooms,
  }) async {
    final response = await post(
      hotelBookingsEndpoint,
      token: token,
      body: {
        'hotelId': hotelId,
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
        'rooms': rooms,
      },
    );

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    throw Exception(
      map['message']?.toString() ?? 'Failed to create hotel booking',
    );
  }

  static Future<Map<String, dynamic>> createPaypalOrder({
    required String token,
    required String bookingType,
    required double amount,
    List<int>? bookingIds,
    int? propertyId,
    int? adults,
    int? children,
    String currency = 'USD',
  }) async {
    final body = <String, dynamic>{
      'bookingType': bookingType,
      'amount': double.parse(amount.toStringAsFixed(2)),
      'currency': currency,
    };

    if (bookingIds != null && bookingIds.isNotEmpty) {
      body['bookingIds'] = bookingIds;
    }
    if (propertyId != null) {
      body['propertyId'] = propertyId;
    }
    if (adults != null) {
      body['adults'] = adults;
    }
    if (children != null) {
      body['children'] = children;
    }

    final response = await post(
      paypalCreateOrderEndpoint,
      token: token,
      body: body,
    );

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    throw Exception(
      map['message']?.toString() ?? 'Failed to create PayPal order',
    );
  }

  static Future<Map<String, dynamic>> capturePaypalOrder({
    required String token,
    required String orderId,
  }) async {
    final response = await post(
      paypalCaptureOrderEndpoint,
      token: token,
      body: {'orderId': orderId},
    );

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    throw Exception(
      map['message']?.toString() ?? 'Failed to capture PayPal order',
    );
  }

  static Future<Map<String, dynamic>> confirmCashPayment({
    required String token,
    required String bookingType,
    List<int>? bookingIds,
    int? propertyId,
    int? adults,
    int? children,
  }) async {
    final body = <String, dynamic>{
      'bookingType': bookingType,
    };

    if (bookingIds != null && bookingIds.isNotEmpty) {
      body['bookingIds'] = bookingIds;
    }
    if (propertyId != null) {
      body['propertyId'] = propertyId;
    }
    if (adults != null) {
      body['adults'] = adults;
    }
    if (children != null) {
      body['children'] = children;
    }

    final response = await post(
      cashConfirmEndpoint,
      token: token,
      body: body,
    );

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    throw Exception(
      map['message']?.toString() ?? 'Failed to confirm cash payment',
    );
  }

  static Future<Map<String, dynamic>> getOwnerListingSummary({
    required String token,
  }) async {
    final response = await get(ownerListingSummaryEndpoint, token: token);

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    throw Exception(
      map['message']?.toString() ?? 'Failed to load owner summary',
    );
  }

  // Expense APIs
  static Future<Map<String, dynamic>> uploadReceipt({
    required String token,
    required List<int> fileBytes,
    required String filename,
  }) async {
    final uri = Uri.parse('$baseUrl/expenses/upload-receipt');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes('receipt', fileBytes, filename: filename),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    final dynamic decoded = responseBody.isNotEmpty
        ? jsonDecode(responseBody)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    throw Exception(map['message']?.toString() ?? 'Failed to upload receipt');
  }

  static Future<Map<String, dynamic>> createExpense({
    required String token,
    required String title,
    required double amount,
    String? description,
    String? category,
    String? date,
    int? propertyId,
    int? hotelId,
    String? receiptUrl,
  }) async {
    final body = <String, dynamic>{'title': title, 'amount': amount};
    if (description != null) body['description'] = description;
    if (category != null) body['category'] = category;
    if (date != null) body['date'] = date;
    if (propertyId != null) body['propertyId'] = propertyId;
    if (hotelId != null) body['hotelId'] = hotelId;
    if (receiptUrl != null) body['receiptUrl'] = receiptUrl;

    final response = await post(expensesEndpoint, token: token, body: body);

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    throw Exception(map['message']?.toString() ?? 'Failed to create expense');
  }

  static Future<List<Map<String, dynamic>>> getExpenses({
    required String token,
  }) async {
    final response = await get(expensesEndpoint, token: token);

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : [];

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    }

    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    throw Exception(map['message']?.toString() ?? 'Failed to load expenses');
  }

  static Future<Map<String, dynamic>> getExpense({
    required String token,
    required int expenseId,
  }) async {
    final response = await get('$expensesEndpoint/$expenseId', token: token);

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    throw Exception(map['message']?.toString() ?? 'Failed to load expense');
  }

  static Future<Map<String, dynamic>> getExpenseSummary({
    required String token,
  }) async {
    final response = await get(expenseSummaryEndpoint, token: token);

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    throw Exception(
      map['message']?.toString() ?? 'Failed to load expense summary',
    );
  }

  static Future<List<Map<String, dynamic>>> getExpensesByCategory({
    required String token,
  }) async {
    final response = await get(expenseByCategoryEndpoint, token: token);

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : [];

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    }

    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    throw Exception(
      map['message']?.toString() ?? 'Failed to load expenses by category',
    );
  }

  static Future<Map<String, dynamic>> getExpenseInsight({
    required String token,
  }) async {
    final response = await get(expenseInsightEndpoint, token: token);

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    throw Exception(
      map['message']?.toString() ?? 'Failed to load expense insight',
    );
  }

  static Future<Map<String, dynamic>> updateExpense({
    required String token,
    required int expenseId,
    String? title,
    double? amount,
    String? description,
    String? category,
    String? date,
    int? propertyId,
    String? receiptUrl,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (amount != null) body['amount'] = amount;
    if (description != null) body['description'] = description;
    if (category != null) body['category'] = category;
    if (date != null) body['date'] = date;
    if (propertyId != null) body['propertyId'] = propertyId;
    if (receiptUrl != null) body['receiptUrl'] = receiptUrl;

    final response = await patch(
      '$expensesEndpoint/$expenseId',
      token: token,
      body: body,
    );

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    throw Exception(map['message']?.toString() ?? 'Failed to update expense');
  }

  static Future<void> deleteExpense({
    required String token,
    required int expenseId,
  }) async {
    final response = await delete('$expensesEndpoint/$expenseId', token: token);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final dynamic decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};
      final map = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};
      throw Exception(map['message']?.toString() ?? 'Failed to delete expense');
    }
  }

  // ─── Job APIs ────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllJobs({
    required String token,
  }) async {
    final response = await get('$jobsEndpoint/all', token: token);

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = decoded is Map ? decoded['data'] : null;
      if (data is List) return data.cast<Map<String, dynamic>>();
      return [];
    }
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    throw Exception(map['message']?.toString() ?? 'Failed to load jobs');
  }

  static Future<Map<String, dynamic>> createJob({
    required String token,
    required String title,
    required String description,
    String? urgency,
    double? budget,
    int? propertyId,
    int? hotelId,
  }) async {
    final body = <String, dynamic>{'title': title, 'description': description};
    if (urgency != null) body['urgency'] = urgency;
    if (budget != null) body['budget'] = budget;
    if (propertyId != null) body['propertyId'] = propertyId;
    if (hotelId != null) body['hotelId'] = hotelId;

    final response = await post(jobsEndpoint, token: token, body: body);

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }
    throw Exception(map['message']?.toString() ?? 'Failed to create job');
  }

  static Future<Map<String, dynamic>> deleteJob({
    required String token,
    required int jobId,
  }) async {
    final response = await delete('$jobsEndpoint/$jobId', token: token);

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }
    throw Exception(map['message']?.toString() ?? 'Failed to delete job');
  }

  static Future<Map<String, dynamic>> applyToJob({
    required String token,
    required int jobId,
  }) async {
    final response = await post('$jobsEndpoint/$jobId/apply', token: token);

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }
    throw Exception(map['message']?.toString() ?? 'Failed to apply to job');
  }

  static Future<Map<String, dynamic>> approveJob({
    required String token,
    required int jobId,
  }) async {
    final response = await post('$jobsEndpoint/$jobId/approve', token: token);

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }
    throw Exception(map['message']?.toString() ?? 'Failed to approve job');
  }

  // Staff Dashboard Endpoints
  static const String staffDashboardEndpoint = '/staff';

  static Future<List<Map<String, dynamic>>> getStaffJobs({
    required String token,
  }) async {
    final response = await get('$staffDashboardEndpoint/jobs', token: token);
    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded['data'] is List)
        return (decoded['data'] as List).cast<Map<String, dynamic>>();
      return [];
    }
    throw Exception(
      decoded['message']?.toString() ?? 'Failed to load staff jobs',
    );
  }

  static Future<Map<String, dynamic>> acceptJob({
    required String token,
    required int jobId,
  }) async {
    final response = await post(
      '$staffDashboardEndpoint/jobs/$jobId/accept',
      token: token,
    );
    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded is Map<String, dynamic> ? decoded : {};
    }
    throw Exception(decoded['message']?.toString() ?? 'Failed to accept job');
  }

  static Future<Map<String, dynamic>> submitStaffJob({
    required String token,
    required int jobId,
    required String beforeImage,
    required String afterImage,
  }) async {
    final response = await post(
      '$staffDashboardEndpoint/jobs/$jobId/submit',
      token: token,
      body: {'beforeImage': beforeImage, 'afterImage': afterImage},
    );
    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded is Map<String, dynamic> ? decoded : {};
    }
    throw Exception(decoded['message']?.toString() ?? 'Failed to submit job');
  }

  static Future<Map<String, dynamic>> rejectJob({
    required String token,
    required int jobId,
  }) async {
    final response = await post(
      '$staffDashboardEndpoint/jobs/$jobId/reject',
      token: token,
    );
    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded is Map<String, dynamic> ? decoded : {};
    }
    throw Exception(decoded['message']?.toString() ?? 'Failed to reject job');
  }

  static Future<Map<String, dynamic>> getStaffEarnings({
    required String token,
  }) async {
    final response = await get(
      '$staffDashboardEndpoint/earnings',
      token: token,
    );
    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return (decoded['data'] as Map<String, dynamic>?) ?? {};
    }
    throw Exception(
      decoded['message']?.toString() ?? 'Failed to load earnings',
    );
  }

  static Future<Map<String, dynamic>> autoAssignJob({
    required String token,
    required int jobId,
  }) async {
    final response = await post(
      '$jobsEndpoint/$jobId/auto-assign',
      token: token,
    );

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }
    throw Exception(map['message']?.toString() ?? 'Failed to auto-assign job');
  }

  static Future<List<Map<String, dynamic>>> getUsers({
    required String token,
    String? query,
  }) async {
    final endpoint = query != null && query.isNotEmpty
        ? '/users?q=${Uri.encodeComponent(query)}'
        : '/users';
    final response = await get(endpoint, token: token);

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : [];
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is List) return decoded.cast<Map<String, dynamic>>();
      return [];
    }
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    throw Exception(map['message']?.toString() ?? 'Failed to load users');
  }

  static Future<Map<String, dynamic>> assignJobToUser({
    required String token,
    required int jobId,
    required int applierId,
  }) async {
    final response = await post(
      '$jobsEndpoint/$jobId/assign',
      token: token,
      body: {'jobId': jobId, 'applierId': applierId},
    );

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (response.statusCode >= 200 && response.statusCode < 300) return map;
    throw Exception(map['message']?.toString() ?? 'Failed to assign job');
  }

  static Future<Map<String, dynamic>> submitJob({
    required String token,
    required int jobId,
  }) async {
    final response = await post('$jobsEndpoint/$jobId/submit', token: token);

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }
    throw Exception(map['message']?.toString() ?? 'Failed to submit job');
  }

  // ── Staff ───────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getStaff({
    required String token,
  }) async {
    final response = await get(staffEndpoint, token: token);
    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = map['data'];
      if (data is List) return data.cast<Map<String, dynamic>>();
      return [];
    }
    throw Exception(map['message']?.toString() ?? 'Failed to fetch staff');
  }

  static Future<List<Map<String, dynamic>>> getStaffForAssignment({
    required String token,
    String? query,
  }) async {
    final endpoint = query != null && query.isNotEmpty
        ? '$staffEndpoint/assign?q=${Uri.encodeComponent(query)}'
        : '$staffEndpoint/assign';
    final response = await get(endpoint, token: token);
    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = map['data'];
      if (data is List) return data.cast<Map<String, dynamic>>();
      return [];
    }
    throw Exception(map['message']?.toString() ?? 'Failed to fetch staff');
  }

  static Future<Map<String, dynamic>> addStaff({
    required String token,
    required int userId,
    int? propertyId,
    int? hotelId,
  }) async {
    final body = <String, dynamic>{'userId': userId};
    if (propertyId != null) body['propertyId'] = propertyId;
    if (hotelId != null) body['hotelId'] = hotelId;

    final response = await post(staffEndpoint, token: token, body: body);
    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (response.statusCode >= 200 && response.statusCode < 300) return map;
    throw Exception(map['message']?.toString() ?? 'Failed to add staff');
  }

  static Future<Map<String, dynamic>> removeStaff({
    required String token,
    required int staffId,
  }) async {
    final response = await delete('$staffEndpoint/$staffId', token: token);
    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (response.statusCode >= 200 && response.statusCode < 300) return map;
    throw Exception(map['message']?.toString() ?? 'Failed to remove staff');
  }

  static Future<List<Map<String, dynamic>>> getJobsByStatus({
    required String token,
    required String status,
  }) async {
    final response = await get(
      '$adminEndpoint/jobs/status/$status',
      token: token,
    );
    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded['data'] is List)
        return (decoded['data'] as List).cast<Map<String, dynamic>>();
      return [];
    }
    throw Exception(
      decoded['message']?.toString() ?? 'Failed to load jobs by status',
    );
  }

  static Future<Map<String, dynamic>> reviewJob({
    required String token,
    required int jobId,
    required String status,
    String? reason,
  }) async {
    final response = await post(
      '$adminEndpoint/jobs/$jobId/review',
      token: token,
      body: {'status': status, if (reason != null) 'reason': reason},
    );
    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded is Map<String, dynamic> ? decoded : {};
    }
    throw Exception(decoded['message']?.toString() ?? 'Failed to review job');
  }

  static Future<Map<String, dynamic>> getAdminStats({
    required String token,
  }) async {
    final response = await get('$adminEndpoint/stats', token: token);
    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded['data'] is Map<String, dynamic> ? decoded['data'] : {};
    }
    throw Exception(
      decoded['message']?.toString() ?? 'Failed to load admin stats',
    );
  }

  static Future<Map<String, dynamic>> getAdminInsights({
    required String token,
  }) async {
    final response = await get('$adminEndpoint/insights', token: token);
    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded['data'] is Map<String, dynamic> ? decoded['data'] : {};
    }
    throw Exception(
      decoded['message']?.toString() ?? 'Failed to load admin insights',
    );
  }

  static Future<dynamic> getIoTDevices(String token) async {
    final response = await get('/iot', token: token);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<bool> createIoTDevice({
    required String token,
    required String name,
    String? location,
    required String status,
    int? propertyId,
    int? hotelId,
  }) async {
    final response = await post(
      '/iot',
      token: token,
      body: {
        'name': name,
        'location': location,
        'status': status,
        'propertyId': propertyId,
        'hotelId': hotelId,
      },
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  static Future<bool> removeIoTDevice(String token, int id) async {
    final response = await delete('/iot/$id', token: token);
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  // Admin Notifications API
  static Future<List<dynamic>> getAdminNotifications(String token) async {
    final response = await get('/admin/notifications', token: token);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    }
    throw Exception('Failed to fetch admin notifications');
  }

  static Future<bool> markNotificationsAsRead(String token) async {
    final response = await patch('/admin/notifications/read-all', token: token);
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  // Bookings API
  static Future<List<Map<String, dynamic>>> getUserBookings({
    required String token,
  }) async {
    final response = await get(bookingsEndpoint, token: token);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : [];

      if (decoded is List) {
        return decoded.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    }

    throw Exception('Failed to fetch bookings');
  }

  static Future<List<Map<String, dynamic>>> getTransactions({
    required String token,
  }) async {
    final response = await get(transactionsEndpoint, token: token);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    }

    throw Exception('Failed to fetch transactions');
  }

  static Future<Map<String, dynamic>> getAiRecommendations({
    required String token,
    String? type,
  }) async {
    final queryParams = type != null ? '?type=$type' : '';
    final response = await get(
      '/ai-assistant/recommendations$queryParams',
      token: token,
    );

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    throw Exception(
      map['message']?.toString() ?? 'Failed to load AI recommendations',
    );
  }

  static Future<Map<String, dynamic>> getInvestmentAnnouncement({
    required String token,
  }) async {
    final response = await get(
      '/ai-assistant/investment-announcement',
      token: token,
    );

    final dynamic decoded = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return map;
    }

    throw Exception(
      map['message']?.toString() ?? 'Failed to load investment announcement',
    );
  }
}
