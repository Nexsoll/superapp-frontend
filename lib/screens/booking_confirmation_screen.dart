import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/main_screen_controller.dart';
import 'package:superapp/screens/main_screen.dart';
import 'package:superapp/widgets/booking_reference_card.dart';
import 'package:superapp/widgets/qr_code_card.dart';
import 'package:superapp/widgets/booking_details_card.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../services/receipt_service.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String referenceNumber;
  final String listingTitle;
  final String location;
  final String imageUrl;
  final String detailLabel;
  final String detailLine1;
  final String detailLine2;
  final String checkIn;
  final String checkOut;
  final int guests;
  final String totalPaid;
  final String email;
  final String? paymentMethod;
  final String bookingType;

  const BookingConfirmationScreen({
    super.key,
    this.referenceNumber = 'BK30687',
    this.listingTitle = 'Grand Plaza Hotel',
    this.location = 'Paris, France',
    this.imageUrl =
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
    this.detailLabel = 'Room Type',
    this.detailLine1 = 'Standard Room',
    this.detailLine2 = 'Deluxe Suite',
    this.checkIn = '12/03/2025',
    this.checkOut = '12/06/2025',
    this.guests = 3,
    this.totalPaid = '\$1774',
    this.email = 'alex@gmail.com',
    this.paymentMethod,
    this.bookingType = 'hotel',
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _downloadQRCode() async {
    try {
      // Generate PDF receipt
      final pdfFile = await ReceiptService.generateReceipt(
        bookingReference: widget.referenceNumber,
        bookingType: widget.bookingType,
        listingTitle: widget.listingTitle,
        location: widget.location,
        checkIn: widget.checkIn,
        checkOut: widget.checkOut,
        guests: widget.guests,
        totalPaid: widget.totalPaid,
        email: widget.email,
        paymentMethod: widget.paymentMethod ?? 'PayPal',
        roomType1: widget.detailLine1,
        roomType2: widget.detailLine2,
      );

      // Open the PDF
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
        'Failed to download receipt: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _shareQRCode() async {
    try {
      // Generate PDF receipt
      final pdfFile = await ReceiptService.generateReceipt(
        bookingReference: widget.referenceNumber,
        bookingType: widget.bookingType,
        listingTitle: widget.listingTitle,
        location: widget.location,
        checkIn: widget.checkIn,
        checkOut: widget.checkOut,
        guests: widget.guests,
        totalPaid: widget.totalPaid,
        email: widget.email,
        paymentMethod: widget.paymentMethod ?? 'PayPal',
        roomType1: widget.detailLine1,
        roomType2: widget.detailLine2,
      );

      await Share.shareXFiles([
        XFile(pdfFile.path),
      ], text: 'Booking Receipt: ${widget.referenceNumber}');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share receipt: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _generateQRData() {
    // Generate a URL that would show the receipt when scanned
    // In production, this would be a real URL to your receipt viewer
    return 'https://superapp.com/receipt/${widget.referenceNumber}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktopWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 900;

    if (isDesktopWeb) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 34),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/success.png',
                            width: 92,
                            height: 92,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Booking Confirmed!'.tr,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Your reservation has been successfully completed'
                                .tr,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.textTheme.titleMedium?.color
                                  ?.withValues(alpha: 0.66),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 28),
                          BookingReferenceCard(
                            referenceNumber: widget.referenceNumber,
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF79C7EE,
                              ).withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(
                                  0xFF79C7EE,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.mark_email_read_outlined,
                                  color: Color(0xFF2FC1BE),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${'Confirmation email sent to'.tr} ${widget.email}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 54,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final controller =
                                          Get.isRegistered<
                                            MainScreenController
                                          >()
                                          ? Get.find<MainScreenController>()
                                          : Get.put(
                                              MainScreenController(),
                                              permanent: true,
                                            );
                                      controller.bottomIndex.value = 2;
                                      controller.categoryIndex.value =
                                          widget.bookingType == 'property'
                                          ? 1
                                          : 0;
                                      Get.offAll(() => const MainScreen());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2FC1BE),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.calendar_today_outlined,
                                    ),
                                    label: Text('View My Bookings'.tr),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: SizedBox(
                                  height: 54,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Get.offAll(() => const MainScreen());
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: const Icon(Icons.home_outlined),
                                    label: Text('Back To Home'.tr),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 34),
                    SizedBox(
                      width: 440,
                      child: Column(
                        children: [
                          Screenshot(
                            controller: _screenshotController,
                            child: QrCodeCard(
                              qrData: _generateQRData(),
                              onDownload: _downloadQRCode,
                              onShare: _shareQRCode,
                            ),
                          ),
                          const SizedBox(height: 18),
                          BookingDetailsCard(
                            hotelName: widget.listingTitle,
                            location: widget.location,
                            imageUrl: widget.imageUrl,
                            detailLabel: widget.detailLabel,
                            roomType1: widget.detailLine1,
                            roomType2: widget.detailLine2,
                            checkIn: widget.checkIn,
                            checkOut: widget.checkOut,
                            guests: widget.guests,
                            totalPaid: widget.totalPaid,
                            paymentMethod: widget.paymentMethod,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // Success Image
                Image.asset('assets/success.png', width: 80, height: 80),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Booking Confirmed!'.tr,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Your reservation has been successfully\ncompleted'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Booking Reference Card
                BookingReferenceCard(referenceNumber: widget.referenceNumber),
                const SizedBox(height: 16),

                // QR Code Card with Screenshot
                Screenshot(
                  controller: _screenshotController,
                  child: QrCodeCard(
                    qrData: _generateQRData(),
                    onDownload: _downloadQRCode,
                    onShare: _shareQRCode,
                  ),
                ),
                const SizedBox(height: 16),

                // Booking Details Card
                BookingDetailsCard(
                  hotelName: widget.listingTitle,
                  location: widget.location,
                  imageUrl: widget.imageUrl,
                  detailLabel: widget.detailLabel,
                  roomType1: widget.detailLine1,
                  roomType2: widget.detailLine2,
                  checkIn: widget.checkIn,
                  checkOut: widget.checkOut,
                  guests: widget.guests,
                  totalPaid: widget.totalPaid,
                  paymentMethod: widget.paymentMethod,
                ),
                const SizedBox(height: 24),

                // Email Confirmation Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF79C7EE).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF79C7EE).withOpacity(0.3),
                    ),
                  ),

                  child: Column(
                    children: [
                      Text(
                        'Confirmation email sent to'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF5A606A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2FC1BE),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // View My Bookings Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      final controller =
                          Get.isRegistered<MainScreenController>()
                          ? Get.find<MainScreenController>()
                          : Get.put(MainScreenController(), permanent: true);
                      controller.bottomIndex.value = 2;
                      controller.categoryIndex.value =
                          widget.bookingType == 'property' ? 1 : 0;
                      Get.offAll(() => const MainScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2FC1BE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 22,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'View My Bookings'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Back To Home Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.offAll(() => const MainScreen());
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 22,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Back To Home'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
