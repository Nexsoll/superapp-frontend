import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:superapp/screens/booking_paypal_screen.dart';
import 'package:superapp/services/listing_service.dart';
import 'package:superapp/services/currency_service.dart';
import 'package:superapp/controllers/profile_controller.dart';

String _formatCurrency(double amountInUSD, {int decimals = 0}) {
  final profileCtrl = Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController());
  final currency = profileCtrl.userCurrency.value;
  final converted = CurrencyService.convertFromUSD(amountInUSD, currency);
  return CurrencyService.formatAmount(converted, currency, decimals: decimals);
}

String _formatCompactCurrency(double amountInUSD) {
  final profileCtrl = Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController());
  final currency = profileCtrl.userCurrency.value;
  final converted = CurrencyService.convertFromUSD(amountInUSD, currency);

  if (converted >= 1000000) {
    return CurrencyService.formatAmount(converted / 1000000, currency, decimals: 1) + 'M';
  }
  if (converted >= 1000) {
    return CurrencyService.formatAmount(converted / 1000, currency, decimals: 0) + 'K';
  }
  return CurrencyService.formatAmount(converted, currency, decimals: 0);
}

class BookingSummaryScreen extends StatefulWidget {
  final String bookingType; // 'hotel' or 'property'
  final String hotelTitle;
  final String hotelAddress;
  final String? hotelImageUrl;
  final Map<String, dynamic>? propertyData;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int? nights;
  final List<Map<String, dynamic>> selectedRooms;
  final double? bookingTotal;
  final Map<String, dynamic>? bookingResponse;

  const BookingSummaryScreen({
    super.key,
    this.bookingType = 'hotel',
    this.hotelTitle = '',
    this.hotelAddress = '',
    this.hotelImageUrl,
    this.propertyData,
    this.checkIn,
    this.checkOut,
    this.nights,
    this.selectedRooms = const [],
    this.bookingTotal,
    this.bookingResponse,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  int _adults = 2;
  int _children = 0;

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    const week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${week[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  String _formatMoney(double amount) {
    return _formatCurrency(amount);
  }

  @override
  void initState() {
    super.initState();
    final selectedRoomCount = widget.selectedRooms.fold<int>(
      0,
      (sum, room) => sum + _toInt(room['quantity'], fallback: 1),
    );
    _adults = selectedRoomCount > 0 ? selectedRoomCount * 2 : 2;
    _children = 0;
  }

  @override
  Widget build(BuildContext context) {
    final bool isProperty = widget.bookingType == 'property';
    final theme = Theme.of(context);

    final fallbackRooms = [
      {
        'title': 'Standard Room',
        'price': 180.0,
        'quantity': 1,
        'specs': '1 King Bed • 25 m²',
        'imagePath': 'assets/room1.png',
      },
      {
        'title': 'Deluxe Suite',
        'price': 350.0,
        'quantity': 1,
        'specs': '1 King Bed + Sofa • 25 m²',
        'imagePath': 'assets/room2.png',
      },
    ];

    final hotelRooms = !isProperty && widget.selectedRooms.isNotEmpty
        ? widget.selectedRooms
        : fallbackRooms;
    final computedNights =
        widget.nights ??
        ((widget.checkIn != null && widget.checkOut != null)
            ? widget.checkOut!.difference(widget.checkIn!).inDays
            : 3);
    final stayNights = computedNights > 0 ? computedNights : 1;
    final selectedRoomCount = hotelRooms.fold<int>(
      0,
      (sum, room) => sum + _toInt(room['quantity'], fallback: 1),
    );
    final roomSubtotal = hotelRooms.fold<double>(
      0,
      (sum, room) =>
          sum +
          (_toDouble(room['price']) *
              _toInt(room['quantity'], fallback: 1) *
              stayNights),
    );
    final effectiveRoomSubtotal =
        (!isProperty && (widget.bookingTotal ?? 0) > 0)
        ? widget.bookingTotal!
        : roomSubtotal;

    final includedAdults = isProperty
        ? 2
        : (selectedRoomCount > 0 ? selectedRoomCount * 2 : 2);
    final extraAdults = _adults > includedAdults ? _adults - includedAdults : 0;
    final guestSurcharge = isProperty
        ? 0.0
        : ((extraAdults * 20) + (_children * 10)) * stayNights.toDouble();

    final subtotalBeforeTax = effectiveRoomSubtotal + guestSurcharge;
    final taxes = subtotalBeforeTax * 0.10;
    final serviceCharge = subtotalBeforeTax > 0 ? 25.0 : 0.0;
    final totalPrice = subtotalBeforeTax + taxes + serviceCharge;
    final checkInLabel = isProperty
        ? 'Tue, 13 Dec'
        : _formatDate(widget.checkIn);
    final checkOutLabel = isProperty
        ? 'Fri, 16 Dec'
        : _formatDate(widget.checkOut);

    final propertyTitle =
        widget.propertyData?['title']?.toString() ?? 'Luxury Villa';
    final rawAddress = widget.propertyData?['address']?.toString() ?? '';
    final propertyAddress = rawAddress.trim().isNotEmpty
        ? rawAddress
        : 'Dubai Marina';
    final rawPropertyId = widget.propertyData?['id'];
    final propertyId = rawPropertyId is int
        ? rawPropertyId
        : int.tryParse(rawPropertyId?.toString() ?? '');
    final propertyImages = widget.propertyData?['images'] as List<dynamic>?;
    final propertyImageUrl =
        (propertyId != null && (propertyImages?.isNotEmpty ?? false))
        ? ListingService.propertyImageUrl(propertyId, 0)
        : null;

    final reviews =
        widget.propertyData?['reviews'] as List<dynamic>? ?? const [];
    double propertyRating = 4.8;
    if (reviews.isNotEmpty) {
      double sum = 0;
      int count = 0;
      for (final review in reviews) {
        if (review is! Map<String, dynamic>) continue;
        sum += _toDouble(review['rating']);
        count++;
      }
      if (count > 0) {
        propertyRating = sum / count;
      }
    }

    final rawPropertyPrice = _toDouble(widget.propertyData?['price']);
    final purchasePrice = rawPropertyPrice > 0 ? rawPropertyPrice : 1250000.0;
    final closingCosts = purchasePrice * 0.0148;
    final agentFees = purchasePrice * 0.03;
    final propertyTotal = purchasePrice + closingCosts + agentFees;

    final propertyCardPriceLabel = _formatCompactCurrency(purchasePrice);
    final purchasePriceLabel = _formatCurrency(purchasePrice, decimals: 2);
    final closingCostsLabel = _formatCurrency(closingCosts, decimals: 2);
    final agentFeesLabel = _formatCurrency(agentFees, decimals: 2);
    final propertyTotalLabel = _formatCurrency(propertyTotal, decimals: 0);
    final bookingItems = widget.bookingResponse?['bookings'] as List?;
    final bookingIds = bookingItems is List
        ? bookingItems
              .map((item) {
                if (item is Map<String, dynamic>) {
                  return _toInt(item['id']);
                }
                return null;
              })
              .whereType<int>()
              .where((id) => id > 0)
              .toList()
        : <int>[];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
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
                    Text('Summary'.tr,
                      style: TextStyle(
                        color: Color(0xFF2FC1BE),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Property card for property bookings
                    if (isProperty) ...[
                      _PropertySummaryCard(
                        title: propertyTitle,
                        address: propertyAddress,
                        priceLabel: propertyCardPriceLabel,
                        rating: propertyRating,
                        imageUrl: propertyImageUrl,
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Room cards for hotel bookings
                    if (!isProperty) ...[
                      if (widget.hotelTitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.hotelTitle,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF1D2330),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ...hotelRooms.asMap().entries.map((entry) {
                        final room = entry.value;
                        final qty = _toInt(room['quantity'], fallback: 1);
                        final title = room['title']?.toString() ?? 'Room';
                        final specs =
                            room['specs']?.toString() ??
                            '$qty Room${qty > 1 ? 's' : ''} selected';
                        final imagePath =
                            room['imagePath']?.toString() ?? 'assets/room1.png';
                        final imageUrl = room['imageUrl']?.toString();

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: entry.key == hotelRooms.length - 1 ? 0 : 16,
                          ),
                          child: _SummaryRoomCard(
                            title: '$title ($qty)',
                            specs: specs,
                            price: _formatMoney(_toDouble(room['price'])),
                            imagePath: imagePath,
                            imageUrl: imageUrl,
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _DateCard(
                              label: 'CHECK-IN',
                              date: checkInLabel,
                              icon: Icons.login,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _DateCard(
                              label: 'CHECK-OUT',
                              date: checkOutLabel,
                              icon: Icons.logout,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _GuestDetailsCard(
                        adults: _adults,
                        children: _children,
                        onAdultsChanged: (value) {
                          setState(() => _adults = value);
                        },
                        onChildrenChanged: (value) {
                          setState(() => _children = value);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                    const _PromoCodeSection(),
                    const SizedBox(height: 24),
                    // Different price details for property vs hotel
                    if (isProperty)
                      _PropertyPriceDetailsSection(
                        purchasePrice: purchasePriceLabel,
                        closingCosts: closingCostsLabel,
                        agentFees: agentFeesLabel,
                      )
                    else
                      _PriceDetailsSection(
                        roomNightsLabel:
                            '$selectedRoomCount Room${selectedRoomCount > 1 ? 's' : ''} x $stayNights Night${stayNights > 1 ? 's' : ''}',
                        roomSubtotal: effectiveRoomSubtotal,
                        guestCharge: guestSurcharge,
                        taxes: taxes,
                        serviceCharge: serviceCharge,
                      ),
                    const SizedBox(height: 24),
                    // Different total section for property
                    if (isProperty)
                      _PropertyTotalSection(totalLabel: propertyTotalLabel)
                    else
                      _TotalSection(total: totalPrice),
                    const SizedBox(height: 24),
                    if (!isProperty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF43A047).withOpacity(0.1)
                              : const Color(0xFFE3F9D6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xFF43A047),
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text('Free cancellation until 24 hours before check-in.\nAfter that cancellation fees may apply.'.tr,
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 12,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: theme.cardColor,
                      side: BorderSide(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white24
                            : const Color(0xFFB0B0B0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text('Cancel'.tr,
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF1D2330),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Get.to(
                      () => BookingPaypalScreen(
                        bookingType: widget.bookingType,
                        hotelTitle: widget.hotelTitle,
                        hotelAddress: widget.hotelAddress,
                        hotelImageUrl: widget.hotelImageUrl,
                        propertyData: widget.propertyData,
                        selectedRooms: widget.selectedRooms,
                        bookingIds: bookingIds,
                        propertyId: propertyId,
                        adults: _adults,
                        children: _children,
                        checkIn: widget.checkIn,
                        checkOut: widget.checkOut,
                        totalAmount: isProperty ? propertyTotal : totalPrice,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2FC1BE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isProperty
                            ? 'Proceed to Payment'
                            : 'Proceed to Checkout',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRoomCard extends StatelessWidget {
  final String title;
  final String specs;
  final String price;
  final String imagePath;
  final String? imageUrl;

  const _SummaryRoomCard({
    required this.title,
    required this.specs,
    required this.price,
    required this.imagePath,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF2FC1BE).withOpacity(0.3)
              : const Color(0xFF2FC1BE),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      imagePath,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    imagePath,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF1D2330),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  specs,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white70
                        : const Color(0xFF878787),
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: price,
                        style: const TextStyle(
                          color: Color(0xFF2FC1BE),
                          fontSize: 16, // Font size for price per night
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '/night',
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white70
                              : const Color(0xFF878787),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final String label;
  final String date;
  final IconData icon;

  const _DateCard({
    required this.label,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2FC1BE).withOpacity(0.1)
            : const Color(0x292FC1BE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2FC1BE), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white70
                      : const Color(0xFF878787),
                ),
              ),
              Icon(icon, color: const Color(0xFF2FC1BE), size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1D2330),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestDetailsCard extends StatelessWidget {
  final int adults;
  final int children;
  final ValueChanged<int> onAdultsChanged;
  final ValueChanged<int> onChildrenChanged;

  const _GuestDetailsCard({
    required this.adults,
    required this.children,
    required this.onAdultsChanged,
    required this.onChildrenChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white24
              : const Color(0xFFE0E0E0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCounterRow(
            label: 'Number of Adults',
            subLabel: 'Ages 12+',
            count: adults,
            theme: theme,
            onDecrement: adults > 1 ? () => onAdultsChanged(adults - 1) : null,
            onIncrement: () => onAdultsChanged(adults + 1),
          ),
          const SizedBox(height: 20),
          _buildCounterRow(
            label: 'Number of Children',
            subLabel: 'Ages 0-11',
            count: children,
            theme: theme,
            onDecrement: children > 0
                ? () => onChildrenChanged(children - 1)
                : null,
            onIncrement: () => onChildrenChanged(children + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow({
    required String label,
    required String subLabel,
    required int count,
    required ThemeData theme,
    required VoidCallback? onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1D2330),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subLabel,
              style: TextStyle(
                fontSize: 12,
                color: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : const Color(0xFF878787),
              ),
            ),
          ],
        ),
        Row(
          children: [
            _CounterButton(
              icon: Icons.remove,
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF2FC1BE).withOpacity(0.2)
                  : const Color(0xFFBEEBEA),
              onTap: onDecrement,
            ),
            const SizedBox(width: 14),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1D2330),
              ),
            ),
            const SizedBox(width: 14),
            _CounterButton(
              icon: Icons.add,
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF2FC1BE).withOpacity(0.2)
                  : const Color(0xFFBEEBEA),
              onTap: onIncrement,
            ),
          ],
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _CounterButton({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: const Color(0xFF2FC1BE)),
        ),
      ),
    );
  }
}

class _PromoCodeSection extends StatelessWidget {
  const _PromoCodeSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Promo Code'.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1D2330),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white24
                        : const Color(0xFFE0E0E0),
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: Text('Promo code'.tr,
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white60
                        : const Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2FC1BE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: Text('Apply'.tr,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceDetailsSection extends StatelessWidget {
  final String roomNightsLabel;
  final double roomSubtotal;
  final double guestCharge;
  final double taxes;
  final double serviceCharge;

  const _PriceDetailsSection({
    required this.roomNightsLabel,
    required this.roomSubtotal,
    required this.guestCharge,
    required this.taxes,
    required this.serviceCharge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price Details'.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1D2330),
          ),
        ),
        const SizedBox(height: 12),
        _buildPriceRow(
          roomNightsLabel,
          _formatCurrency(roomSubtotal),
          theme,
        ),
        if (guestCharge > 0) ...[
          const SizedBox(height: 8),
          _buildPriceRow(
            'Extra Guest Charges',
            _formatCurrency(guestCharge),
            theme,
          ),
        ],
        const SizedBox(height: 8),
        _buildPriceRow(
          'Taxes & Fees (10%)',
          _formatCurrency(taxes),
          theme,
        ),
        const SizedBox(height: 8),
        _buildPriceRow(
          'Service Charge',
          _formatCurrency(serviceCharge),
          theme,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final boxWidth = constraints.constrainWidth();
            const dashWidth = 5.0;
            const dashHeight = 1.0;
            final dashCount = (boxWidth / (2 * dashWidth)).floor();
            return Flex(
              children: List.generate(dashCount, (_) {
                return SizedBox(
                  width: dashWidth,
                  height: dashHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey[700]
                          : Colors.grey[300],
                    ),
                  ),
                );
              }),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.horizontal,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String amount, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: theme.brightness == Brightness.dark
                ? Colors.white70
                : const Color(0xFF878787),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1D2330),
          ),
        ),
      ],
    );
  }
}

class _TotalSection extends StatelessWidget {
  final double total;

  const _TotalSection({required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('Total'.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1D2330),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatCurrency(total),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF2FC1BE),
              ),
            ),
            const SizedBox(height: 2),
            Text('Includes all taxes'.tr,
              style: TextStyle(
                fontSize: 10,
                color: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : const Color(0xFF878787),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Property-specific widgets
class _PropertySummaryCard extends StatelessWidget {
  final String title;
  final String address;
  final String priceLabel;
  final double rating;
  final String? imageUrl;

  const _PropertySummaryCard({
    required this.title,
    required this.address,
    required this.priceLabel,
    required this.rating,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF2FC1BE).withOpacity(0.3)
              : const Color(0xFF2FC1BE),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/room1.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/room1.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF1D2330),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white70
                          : const Color(0xFF878787),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white70
                            : const Color(0xFF878787),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  priceLabel,
                  style: const TextStyle(
                    color: Color(0xFF2FC1BE),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFB300), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF1D2330),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyPriceDetailsSection extends StatelessWidget {
  final String purchasePrice;
  final String closingCosts;
  final String agentFees;

  const _PropertyPriceDetailsSection({
    required this.purchasePrice,
    required this.closingCosts,
    required this.agentFees,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Details'.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1D2330),
          ),
        ),
        const SizedBox(height: 14),
        _buildPriceRow('Purchase Price', purchasePrice, theme),
        const SizedBox(height: 10),
        _buildPriceRow('Closing Costs Estimate', closingCosts, theme),
        const SizedBox(height: 10),
        _buildPriceRow('Agent Fees', agentFees, theme),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final boxWidth = constraints.constrainWidth();
            const dashWidth = 5.0;
            const dashHeight = 1.0;
            final dashCount = (boxWidth / (2 * dashWidth)).floor();
            return Flex(
              children: List.generate(dashCount, (_) {
                return SizedBox(
                  width: dashWidth,
                  height: dashHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey[700]
                          : Colors.grey[300],
                    ),
                  ),
                );
              }),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.horizontal,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String amount, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: theme.brightness == Brightness.dark
                ? Colors.white70
                : const Color(0xFF878787),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1D2330),
          ),
        ),
      ],
    );
  }
}

class _PropertyTotalSection extends StatelessWidget {
  final String totalLabel;

  const _PropertyTotalSection({required this.totalLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Down Payment Required'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2FC1BE),
              ),
            ),
            const SizedBox(height: 4),
            Text('(20%)'.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2FC1BE),
              ),
            ),
            const SizedBox(height: 6),
            Text('Due today to secure property'.tr,
              style: TextStyle(
                fontSize: 12,
                color: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : const Color(0xFF878787),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              totalLabel,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF2FC1BE),
              ),
            ),
            const SizedBox(height: 4),
            Text('Includes all taxes'.tr,
              style: TextStyle(
                fontSize: 11,
                color: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : const Color(0xFF878787),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
