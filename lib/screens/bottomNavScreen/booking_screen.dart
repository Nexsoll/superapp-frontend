import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../booking_details_screen.dart';
import '../add_review_screen.dart';
import '../booking_summary_screen.dart';
import '../../widgets/booking_card.dart';
import '../../controllers/main_screen_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../services/api_service.dart';
import '../../services/listing_service.dart';
import 'explore_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final profileController = Get.find<ProfileController>();
      final token = profileController.token.trim();

      if (token.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final bookings = await ApiService.getUserBookings(token: token);
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching bookings: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _upcomingBookings {
    return _bookings.where((b) {
      final isUpcoming = b['isUpcoming'] == true;
      final status = b['status'];
      return isUpcoming && status != 'CANCELLED';
    }).toList();
  }

  List<Map<String, dynamic>> get _pastBookings {
    return _bookings.where((b) {
      final isPast = b['isPast'] == true;
      final status = b['status'];
      return isPast && status != 'CANCELLED';
    }).toList();
  }

  List<Map<String, dynamic>> get _cancelledBookings {
    return _bookings.where((b) => b['status'] == 'CANCELLED').toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Row(
                children: [
                  Text('My Bookings'.tr,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2FC1BE),
                      decoration: TextDecoration.none,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(26),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: theme.textTheme.bodyMedium?.color,
                unselectedLabelColor: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF1D2330),
                labelStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past'),
                  Tab(text: 'Cancelled'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUpcomingTab(),
                  _buildPastTab(),
                  _buildCancelledTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_upcomingBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No upcoming bookings'.tr,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _upcomingBookings.length,
      itemBuilder: (context, index) {
        final booking = _upcomingBookings[index];
        final isHotel = booking['type'] == 'hotel';
        final hotelId = booking['hotelId'];
        final propertyId = booking['propertyId'];
        final imageUrl = isHotel && hotelId != null
            ? ListingService.hotelImageUrl(hotelId as int, 0)
            : (!isHotel && propertyId != null
                ? ListingService.propertyImageUrl(propertyId as int, 0)
                : (booking['imageUrl'] ?? 'assets/hotel1.png'));

        final isPending = booking['status'] == 'PENDING';

        return BookingCard(
          hotelName: booking['title'] ?? 'Booking',
          location: booking['location'] ?? '',
          imagePath: imageUrl,
          dateRange: _formatDateRange(booking),
          status: isPending ? 'Pending' : 'Confirmed',
          buttonLabel: isPending ? 'Complete Payment' : null,
          onBookingDetailsTap: () {
            if (isPending) {
              // Navigate to booking summary for payment
              final roomData = booking['room'] as Map<String, dynamic>?;

              // Helper to safely parse numeric values that might be String or num
              double parsePrice(dynamic value) {
                if (value == null) return 0.0;
                if (value is num) return value.toDouble();
                return double.tryParse(value.toString()) ?? 0.0;
              }

              Get.to(() => BookingSummaryScreen(
                bookingType: isHotel ? 'hotel' : 'property',
                hotelTitle: booking['title'] ?? '',
                hotelAddress: booking['location'] ?? '',
                hotelImageUrl: imageUrl,
                checkIn: DateTime.tryParse(booking['checkIn']?.toString() ?? ''),
                checkOut: DateTime.tryParse(booking['checkOut']?.toString() ?? ''),
                bookingTotal: parsePrice(booking['totalPrice']),
                selectedRooms: roomData != null
                    ? [{
                        'title': roomData['title'] ?? 'Room',
                        'price': parsePrice(roomData['price']),
                        'quantity': 1,
                        'specs': roomData['title'] ?? 'Standard Room',
                        'imageUrl': roomData['image'],
                      }]
                    : [],
                bookingResponse: booking,
              ))?.then((_) => _fetchBookings());
            } else {
              // Navigate to booking details for confirmed bookings
              Get.to(() => BookingDetailsScreen(bookingData: {
                ...booking,
                'imageUrl': imageUrl,
              }))?.then((_) => _fetchBookings());
            }
          },
        );
      },
    );
  }

  Widget _buildPastTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pastBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No past bookings'.tr,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _pastBookings.length,
      itemBuilder: (context, index) {
        final booking = _pastBookings[index];
        final isHotel = booking['type'] == 'hotel';
        final hotelId = booking['hotelId'];
        final propertyId = booking['propertyId'];
        final imageUrl = isHotel && hotelId != null
            ? ListingService.hotelImageUrl(hotelId as int, 0)
            : (!isHotel && propertyId != null
                ? ListingService.propertyImageUrl(propertyId as int, 0)
                : (booking['imageUrl'] ?? 'assets/hotel1.png'));

        final bookingData = {
          ...booking,
          'imageUrl': imageUrl,
        };

        return BookingCard(
          hotelName: booking['title'] ?? 'Booking',
          location: booking['location'] ?? '',
          imagePath: imageUrl,
          dateRange: _formatDateRange(booking),
          status: 'Completed',
          buttonLabel: 'Rate & Review',
          buttonIcon: const Icon(Icons.star_outline, size: 13, color: Color(0xFF2FC1BE)),
          onButtonTap: () {
            Get.to(() => AddReviewScreen(bookingData: bookingData));
          },
          onBookingDetailsTap: () {
            Get.to(() => BookingDetailsScreen(bookingData: bookingData))?.then((_) => _fetchBookings());
          },
        );
      },
    );
  }

  Widget _buildCancelledTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cancelledBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No cancelled bookings'.tr,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _cancelledBookings.length,
      itemBuilder: (context, index) {
        final booking = _cancelledBookings[index];
        final isHotel = booking['type'] == 'hotel';
        final hotelId = booking['hotelId'];
        final propertyId = booking['propertyId'];
        final imageUrl = isHotel && hotelId != null
            ? ListingService.hotelImageUrl(hotelId as int, 0)
            : (!isHotel && propertyId != null
                ? ListingService.propertyImageUrl(propertyId as int, 0)
                : (booking['imageUrl'] ?? 'assets/hotel1.png'));

        return BookingCard(
          hotelName: booking['title'] ?? 'Booking',
          location: booking['location'] ?? '',
          imagePath: imageUrl,
          dateRange: _formatDateRange(booking),
          status: 'Cancelled',
          showActionButton: false,
        );
      },
    );
  }

  String _formatDateRange(Map<String, dynamic> booking) {
    try {
      final checkIn = DateTime.parse(booking['checkIn']);
      final checkOut = DateTime.parse(booking['checkOut']);

      final checkInStr = '${_monthName(checkIn.month)} ${checkIn.day}';
      final checkOutStr = '${_monthName(checkOut.month)} ${checkOut.day}, ${checkOut.year}';

      return '$checkInStr - $checkOutStr';
    } catch (e) {
      return 'Date not available';
    }
  }

  String _monthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }
}
