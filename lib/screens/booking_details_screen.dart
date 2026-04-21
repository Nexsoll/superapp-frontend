import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/booking_details_card.dart';
import '../widgets/qr_code_card.dart';
import '../services/receipt_service.dart';
import '../services/api_service.dart';
import '../controllers/profile_controller.dart';
import '../services/currency_service.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const BookingDetailsScreen({
    super.key,
    required this.bookingData,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  bool _isCancelling = false;

  String _formatDate(dynamic date) {
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatAmount(dynamic value) {
    if (value == null) return '\$0';
    double amount = 0;
    if (value is num) amount = value.toDouble();
    else amount = double.tryParse(value.toString()) ?? 0;
    
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    final currency = profileController.userCurrency.value;
    final converted = CurrencyService.convertFromUSD(amount, currency);
    return CurrencyService.formatAmount(converted, currency, decimals: 0);
  }

  Future<void> _downloadReceipt() async {
    try {
      final pdfFile = await ReceiptService.generateReceipt(
        bookingReference: widget.bookingData['bookingReference'] ?? 'N/A',
        bookingType: widget.bookingData['type'] ?? 'hotel',
        listingTitle: widget.bookingData['title'] ?? 'Booking',
        location: widget.bookingData['location'] ?? '',
        checkIn: _formatDate(widget.bookingData['checkIn']),
        checkOut: _formatDate(widget.bookingData['checkOut']),
        guests: 2,
        totalPaid: _formatAmount(widget.bookingData['totalPrice']),
        email: Get.find<ProfileController>().email.value,
        paymentMethod: 'PayPal',
        roomType1: widget.bookingData['roomType'],
      );

      await OpenFile.open(pdfFile.path);

      Get.snackbar(
        'Success',
        'Receipt downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2FC1BE),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download receipt',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _cancelBooking() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Cancel Booking'.tr),
        content: Text('Are you sure you want to cancel this booking? Refund will be processed according to your payment method.'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('No'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Yes, Cancel'.tr, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);

    try {
      final profileController = Get.find<ProfileController>();
      final token = profileController.token.trim();

      final response = await ApiService.post(
        '/listing/bookings/${widget.bookingData['id']}/cancel',
        token: token,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String refundAmount = data['refundAmount'] ?? '0.00';
        final bool wasCashPayment = data['wasCashPayment'] ?? false;
        
        // Only refresh profile for non-cash payments (wallet refund)
        if (!wasCashPayment) {
          await profileController.getProfile();
        }
        
        Get.back(); // Go back to bookings list
        
        // Show different message based on payment method
        final String successMessage = wasCashPayment
            ? 'Booking cancelled successfully. Refund of ${_formatAmount(refundAmount)} has been initiated. You will receive the refund at check-in/pickup.'
            : 'Booking cancelled successfully. ${_formatAmount(refundAmount)} has been refunded to your wallet.';
        
        Get.snackbar(
          'Success',
          successMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2FC1BE),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        throw Exception('Failed to cancel booking');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel booking: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingRef = widget.bookingData['bookingReference'] ?? 'N/A';
    final isCancelled = widget.bookingData['status'] == 'CANCELLED';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF2FC1BE),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking Details'.tr,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2FC1BE),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Booking #$bookingRef',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF5A606A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // QR Code Card
              QrCodeCard(
                qrData: 'https://superapp.com/receipt/$bookingRef',
                onDownload: _downloadReceipt,
                onShare: () async {
                  try {
                    final pdfFile = await ReceiptService.generateReceipt(
                      bookingReference: bookingRef,
                      bookingType: widget.bookingData['type'] ?? 'hotel',
                      listingTitle: widget.bookingData['title'] ?? 'Booking',
                      location: widget.bookingData['location'] ?? '',
                      checkIn: _formatDate(widget.bookingData['checkIn']),
                      checkOut: _formatDate(widget.bookingData['checkOut']),
                      guests: 2,
                      totalPaid: _formatAmount(widget.bookingData['totalPrice']),
                      email: Get.find<ProfileController>().email.value,
                      paymentMethod: 'PayPal',
                      roomType1: widget.bookingData['roomType'],
                    );
                    await Share.shareXFiles([XFile(pdfFile.path)], text: 'Booking Receipt: $bookingRef');
                  } catch (e) {
                    Get.snackbar('Error', 'Failed to share receipt');
                  }
                },
              ),
              const SizedBox(height: 20),

              // Booking Details Card
              BookingDetailsCard(
                hotelName: widget.bookingData['title'] ?? 'Booking',
                location: widget.bookingData['location'] ?? '',
                imageUrl: widget.bookingData['imageUrl'] ?? '',
                roomType1: widget.bookingData['roomType'] ?? (widget.bookingData['type'] == 'property' ? 'Schedule Visit' : 'Room'),
                roomType2: '',
                checkIn: _formatDate(widget.bookingData['checkIn']),
                checkOut: _formatDate(widget.bookingData['checkOut']),
                guests: widget.bookingData['guests'] ?? 2,
                totalPaid: _formatAmount(widget.bookingData['totalPrice']),
                paymentMethod: 'Paid via PayPal',
                bookingType: widget.bookingData['type'] ?? 'hotel',
              ),

              const SizedBox(height: 24),

              // Buttons
              _ActionButton(
                icon: Icons.download,
                iconWidget: SvgPicture.asset(
                  'assets/material-symbols_download-rounded.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                    BlendMode.srcIn,
                  ),
                ),
                label: 'Download Invoice',
                onTap: _downloadReceipt,
                isPrimary: false,
              ),
              const SizedBox(height: 12),
              if (!isCancelled)
                _ActionButton(
                  icon: Icons.cancel_outlined,
                  label: _isCancelling ? 'Cancelling...' : 'Cancel Booking',
                  onTap: _isCancelling ? () {} : _cancelBooking,
                  isPrimary: false,
                  textColor: Colors.red,
                  iconColor: Colors.red,
                ),

              const SizedBox(height: 24),

              // Info Banner
              if (!isCancelled)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? const Color(0xFF1B5E20).withOpacity(0.3) : const Color(0xFFD0FBAF).withOpacity(0.57),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: theme.brightness == Brightness.dark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Free cancellation until 24 hours before check-in. After that cancellation fees may apply.'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.brightness == Brightness.dark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Widget? iconWidget;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final Color? textColor;
  final Color? iconColor;

  const _ActionButton({
    required this.icon,
    this.iconWidget,
    required this.label,
    required this.onTap,
    this.isPrimary = true,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF2FC1BE) : theme.cardColor,
          borderRadius: BorderRadius.circular(30),
          border: isPrimary ? null : Border.all(color: theme.brightness == Brightness.dark ? Colors.white24 : const Color(0xFFE0E0E0)),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFF2FC1BE).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconWidget != null)
              IconTheme(
                data: IconThemeData(
                  color: iconColor ?? (isPrimary ? Colors.white : (theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330))),
                  size: 20,
                ),
                child: iconWidget!,
              )
            else
              Icon(
                icon,
                color: iconColor ?? (isPrimary ? Colors.white : (theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330))),
                size: 20,
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor ?? (isPrimary ? Colors.white : (theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
