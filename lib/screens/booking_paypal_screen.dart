import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/screens/booking_confirmation_screen.dart';
import 'package:superapp/services/api_service.dart';
import 'package:superapp/services/listing_service.dart';
import 'package:superapp/services/currency_service.dart';

class BookingPaypalScreen extends StatefulWidget {
  final String bookingType;
  final String hotelTitle;
  final String hotelAddress;
  final String? hotelImageUrl;
  final Map<String, dynamic>? propertyData;
  final List<Map<String, dynamic>> selectedRooms;
  final List<int> bookingIds;
  final int? propertyId;
  final int adults;
  final int children;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double totalAmount;

  const BookingPaypalScreen({
    super.key,
    required this.bookingType,
    required this.totalAmount,
    this.hotelTitle = '',
    this.hotelAddress = '',
    this.hotelImageUrl,
    this.propertyData,
    this.selectedRooms = const [],
    this.bookingIds = const [],
    this.propertyId,
    this.adults = 2,
    this.children = 0,
    this.checkIn,
    this.checkOut,
  });

  @override
  State<BookingPaypalScreen> createState() => _BookingPaypalScreenState();
}

class _BookingPaypalScreenState extends State<BookingPaypalScreen> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _paypalLinkSubscription;
  Completer<bool>? _paypalApprovalCompleter;
  String? _paypalReturnUrl;
  String? _paypalCancelUrl;
  bool _isProcessing = false;
  String _selectedMethod = 'paypal';

  bool get _isProperty => widget.bookingType == 'property';
  bool get _isCashSelected => _selectedMethod == 'cash';

  @override
  void initState() {
    super.initState();
    _paypalLinkSubscription = _appLinks.uriLinkStream.listen(_handlePaypalRedirect);
  }

  @override
  void dispose() {
    _paypalLinkSubscription?.cancel();
    super.dispose();
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatAmount(double amount) {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    final currency = profileController.userCurrency.value;
    final converted = CurrencyService.convertFromUSD(amount, currency);
    return CurrencyService.formatAmount(converted, currency, decimals: 0);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  void _handlePaypalRedirect(Uri uri) {
    final completer = _paypalApprovalCompleter;
    if (completer == null || completer.isCompleted) {
      return;
    }

    if (uri.scheme == 'superapp' && uri.host == 'paypal') {
      final path = uri.path;
      if (path == '/success' || path.startsWith('/success/')) {
        completer.complete(true);
        _resetPaypalRedirectState();
        return;
      }

      if (path == '/cancel' || path.startsWith('/cancel/')) {
        completer.complete(false);
        _resetPaypalRedirectState();
        return;
      }
    }

    final redirectUrl = uri.toString();
    if (_paypalReturnUrl != null && redirectUrl.startsWith(_paypalReturnUrl!)) {
      completer.complete(true);
      _resetPaypalRedirectState();
      return;
    }

    if (_paypalCancelUrl != null && redirectUrl.startsWith(_paypalCancelUrl!)) {
      completer.complete(false);
      _resetPaypalRedirectState();
    }
  }

  void _resetPaypalRedirectState() {
    _paypalApprovalCompleter = null;
    _paypalReturnUrl = null;
    _paypalCancelUrl = null;
  }

  Future<bool> _openPaypalCheckout({
    required String approvalUrl,
    required String returnUrl,
    required String cancelUrl,
  }) async {
    final approvalUri = Uri.tryParse(approvalUrl);
    if (approvalUri == null) {
      throw Exception('Invalid PayPal approval URL');
    }

    final completer = Completer<bool>();
    _paypalApprovalCompleter = completer;
    _paypalReturnUrl = returnUrl;
    _paypalCancelUrl = cancelUrl;

    final launched = await launchUrl(
      approvalUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      _resetPaypalRedirectState();
      throw Exception('Could not open PayPal checkout');
    }

    final approved = await completer.future.timeout(
      const Duration(minutes: 10),
      onTimeout: () {
        _resetPaypalRedirectState();
        return false;
      },
    );

    _resetPaypalRedirectState();
    return approved;
  }

  Future<void> _payWithPaypal() async {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    final token = profileController.token.trim();

    if (token.isEmpty) {
      Get.snackbar('Login required', 'Please login to continue your booking');
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final createResponse = await ApiService.createPaypalOrder(
        token: token,
        bookingType: widget.bookingType,
        amount: widget.totalAmount,
        bookingIds: widget.bookingIds.isNotEmpty ? widget.bookingIds : null,
        propertyId: widget.propertyId,
        adults: widget.adults,
        children: widget.children,
      );

      final orderId = createResponse['orderId']?.toString() ?? '';
      final approvalUrl = createResponse['approvalUrl']?.toString() ?? '';
      final returnUrl = createResponse['returnUrl']?.toString() ?? '';
      final cancelUrl = createResponse['cancelUrl']?.toString() ?? '';
      final approvedAmount = _toDouble(createResponse['amount']);

      if (
        orderId.isEmpty ||
        approvalUrl.isEmpty ||
        returnUrl.isEmpty ||
        cancelUrl.isEmpty
      ) {
        throw Exception('Invalid PayPal order response');
      }

      final approved = await _openPaypalCheckout(
        approvalUrl: approvalUrl,
        returnUrl: returnUrl,
        cancelUrl: cancelUrl,
      );

      if (approved != true) {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
        return;
      }

      final captureResponse = await ApiService.capturePaypalOrder(
        token: token,
        orderId: orderId,
      );

      final payment = captureResponse['payment'] as Map<String, dynamic>?;
      final reference =
          payment?['captureId']?.toString().trim().isNotEmpty == true
          ? payment!['captureId'].toString()
          : orderId;
      _openConfirmationScreen(
        email: profileController.email.value,
        reference: reference,
        paymentMethod: 'Paid with PayPal',
        amountUsd: approvedAmount > 0 ? approvedAmount : widget.totalAmount,
      );
    } catch (e) {
      Get.snackbar(
        'Payment failed',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _confirmCashPayment() async {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    final token = profileController.token.trim();

    if (token.isEmpty) {
      Get.snackbar('Login required', 'Please login to continue your booking');
      return;
    }

    if (!_isProperty && widget.bookingIds.isEmpty) {
      Get.snackbar('Booking not found', 'No pending hotel booking found.');
      return;
    }

    if (_isProperty && widget.propertyId == null) {
      Get.snackbar('Property not found', 'Unable to confirm cash payment.');
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final response = await ApiService.confirmCashPayment(
        token: token,
        bookingType: widget.bookingType,
        bookingIds: widget.bookingIds.isNotEmpty ? widget.bookingIds : null,
        propertyId: widget.propertyId,
        adults: widget.adults,
        children: widget.children,
      );

      final payment = response['payment'] as Map<String, dynamic>?;
      final reference =
          payment?['referenceId']?.toString().trim().isNotEmpty == true
          ? payment!['referenceId'].toString()
          : 'CASH-${DateTime.now().millisecondsSinceEpoch}';

      _openConfirmationScreen(
        email: profileController.email.value,
        reference: reference,
        paymentMethod: 'Cash Payment',
        amountUsd: widget.totalAmount,
      );
    } catch (e) {
      Get.snackbar(
        'Cash confirmation failed',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _openConfirmationScreen({
    required String email,
    required String reference,
    required String paymentMethod,
    required double amountUsd,
  }) {
    final propertyData = widget.propertyData;
    final propertyTitle = propertyData == null
        ? 'Property Booking'
        : (propertyData['title']?.toString() ?? 'Property Booking');
    final propertyAddress = propertyData == null
        ? ''
        : (propertyData['address']?.toString() ?? '');
    final propertyType = propertyData == null
        ? ''
        : (propertyData['type']?.toString() ?? '');

    final title = _isProperty ? propertyTitle : widget.hotelTitle;
    final location = _isProperty ? propertyAddress : widget.hotelAddress;
    final imageUrl = _isProperty ? _propertyImageUrl() : (widget.hotelImageUrl ?? '');
    final roomTitles = widget.selectedRooms
        .map((room) => room['title']?.toString() ?? '')
        .where((title) => title.trim().isNotEmpty)
        .toList();
    final primaryItem = roomTitles.isNotEmpty
        ? roomTitles.first
        : (_isProperty ? 'Property Purchase' : 'Booking');
    final secondaryItem = roomTitles.length > 1
        ? roomTitles.skip(1).join(', ')
        : (_isProperty ? propertyType : '');

    Get.off(
      () => BookingConfirmationScreen(
        referenceNumber: reference,
        listingTitle: title,
        location: location,
        imageUrl: imageUrl,
        detailLabel: _isProperty ? 'Purchase Type' : 'Room Type',
        detailLine1: primaryItem,
        detailLine2: secondaryItem,
        checkIn: _formatDate(widget.checkIn),
        checkOut: _formatDate(widget.checkOut),
        guests: widget.adults + widget.children,
        totalPaid: _formatAmount(amountUsd),
        email: email,
        paymentMethod: paymentMethod,
      ),
    );
  }

  Widget _paymentMethodTab({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final selected = _selectedMethod == id;
    return Expanded(
      child: GestureDetector(
        onTap: _isProcessing
            ? null
            : () => setState(() => _selectedMethod = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF28C2C0) : const Color(0xFF28C2C0).withOpacity(0.16),
            borderRadius: BorderRadius.circular(30),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF28C2C0).withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? Colors.white : const Color(0xFF0A9D9A),
              ),
              const SizedBox(width: 6),
              Text(
                label.tr,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF0A9D9A),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _propertyImageUrl() {
    final propertyId = widget.propertyId;
    final images = widget.propertyData?['images'];
    if (propertyId != null && images is List && images.isNotEmpty) {
      return ListingService.propertyImageUrl(propertyId, 0);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(width: 12),
                    Text('Payment'.tr,
                      style: TextStyle(
                        color: Color(0xFF2FC1BE),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF38CAC7),
                        Color(0xFF27B9B6),
                        Color(0xFF119C99),
                      ],
                      stops: [0.02, 0.49, 1.0],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total amount'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatAmount(widget.totalAmount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Including taxes and fees'.tr,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _paymentMethodTab(
                      id: 'paypal',
                      label: 'PayPal',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(width: 12),
                    _paymentMethodTab(
                      id: 'cash',
                      label: 'Cash',
                      icon: Icons.payments_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white24
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: _isCashSelected
                            ? const Icon(
                                Icons.payments_rounded,
                                size: 52,
                                color: Color(0xFF2FC1BE),
                              )
                            : SvgPicture.asset('assets/logos_paypal.svg', height: 52),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _isCashSelected
                            ? (_isProperty
                                  ? 'Confirm your property booking with cash payment and pay directly at final handover.'
                                  : 'Confirm your hotel booking with cash payment and pay at check-in.')
                            : (_isProperty
                                  ? 'Complete your property booking securely with PayPal.'
                                  : 'Complete your hotel booking securely with PayPal.'),
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white70
                              : const Color(0xFF5A606A),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF2C2C2E)
                              : const Color(0xFFF8FAFB),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isCashSelected
                                  ? Icons.info_outline
                                  : Icons.lock_outline,
                              color: const Color(0xFF2FC1BE),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _isCashSelected
                                    ? 'Cash payment will be confirmed now, and your booking email receipt will be sent right away.'
                                    : 'PayPal confirmation activates your booking instantly and sends your email receipt.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white70
                                      : const Color(0xFF5A606A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isProcessing
                              ? null
                              : (_isCashSelected
                                    ? _confirmCashPayment
                                    : _payWithPaypal),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isCashSelected
                                ? const Color(0xFF2FC1BE)
                                : const Color(0xFFF5A623),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isCashSelected)
                                      const Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.white,
                                        size: 22,
                                      )
                                    else
                                      SvgPicture.asset('assets/logos_paypal.svg', height: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isCashSelected
                                          ? 'Confirm Cash Payment'
                                          : 'Continue with PayPal',
                                      style: TextStyle(
                                        color: _isCashSelected
                                            ? Colors.white
                                            : const Color(0xFF003087),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
