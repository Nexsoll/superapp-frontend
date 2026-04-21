import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../services/api_service.dart';
import '../services/listing_service.dart';
import 'booking_summary_screen.dart';

class SelectDatesScreen extends StatefulWidget {
  const SelectDatesScreen({
    super.key,
    this.initialTabIndex = 0,
    this.initialCheckIn,
    this.initialCheckOut,
    this.hotelId,
    this.hotelTitle = '',
    this.hotelAddress = '',
    this.hotelImageUrl,
    this.rooms = const [],
    this.selectedRoomQuantities = const {},
    this.createBookingOnContinue = false,
  });

  final int initialTabIndex; // 0 = check-in, 1 = check-out
  final DateTime? initialCheckIn;
  final DateTime? initialCheckOut;
  final int? hotelId;
  final String hotelTitle;
  final String hotelAddress;
  final String? hotelImageUrl;
  final List<dynamic> rooms;
  final Map<int, int> selectedRoomQuantities;
  final bool createBookingOnContinue;

  @override
  State<SelectDatesScreen> createState() => _SelectDatesScreenState();
}

class _SelectDatesScreenState extends State<SelectDatesScreen> {
  late int _tabIndex;
  DateTime? _checkIn;
  DateTime? _checkOut;
  late DateTime _visibleMonth;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final defaultCheckIn = DateTime(now.year, now.month, now.day);
    _tabIndex = widget.initialTabIndex;
    _checkIn = widget.initialCheckIn ?? defaultCheckIn;
    _checkOut =
        widget.initialCheckOut ??
        (widget.initialCheckIn ?? defaultCheckIn).add(const Duration(days: 2));
    _visibleMonth = DateTime(_checkIn!.year, _checkIn!.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final bool isContinueEnabled =
        !_isSubmitting && _checkIn != null && _checkOut != null;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                  Text('Select Dates'.tr,
                    style: TextStyle(
                      color: Color(0xFF2FC1BE),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _dateTopCard(
                      label: 'CHECK-IN',
                      date: _formatTopDate(_checkIn),
                      isActive: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _dateTopCard(
                      label: 'CHECK-OUT',
                      date: _formatTopDate(_checkOut),
                      isActive: _tabIndex == 1,
                      onTap: () => setState(() => _tabIndex = 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _monthTitle(_visibleMonth),
                    style: TextStyle(
                      color: theme.textTheme.titleMedium?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _visibleMonth = _addMonths(_visibleMonth, -1);
                          });
                        },
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFFBFEFED),
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _visibleMonth = _addMonths(_visibleMonth, 1);
                          });
                        },
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF2FC1BE),
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  _weekHeader(),
                  const SizedBox(height: 12),
                  _calendarGrid(),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: SizedBox(
                  width: 280,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isContinueEnabled ? _onContinuePressed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2FC1BE),
                      disabledBackgroundColor: const Color(
                        0xFF2FC1BE,
                      ).withOpacity(0.45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isSubmitting
                          ? 'Please wait...'
                          : widget.createBookingOnContinue
                          ? 'Continue Booking'
                          : 'Save Dates',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  String _formatTopDate(DateTime? date) {
    if (date == null) return '--';
    const w = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const m = [
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
    final wd = w[date.weekday - 1];
    final mm = m[date.month - 1];
    return '$wd,${date.day} $mm';
  }

  Widget _dateTopCard({
    required String label,
    required String date,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final Color bg = isActive ? const Color(0xFF2FC1BE) : theme.cardColor;
    final Color labelColor = isActive ? Colors.white : const Color(0xFF2FC1BE);
    final Color dateColor = isActive ? Colors.white : const Color(0xFF2FC1BE);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? Color(0xFF2FC1BE) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: labelColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              date,
              style: TextStyle(
                color: dateColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weekHeader() {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Row(
      children: List.generate(days.length, (i) {
        final isWeekend = i >= 5;
        return Expanded(
          child: Center(
            child: Text(
              days[i],
              style: TextStyle(
                color: isWeekend
                    ? const Color(0xFF2FC1BE)
                    : const Color(0xFF9AA0AF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _calendarGrid() {
    final days = _buildCalendarDays();
    final start = _checkIn;
    final end = _checkOut;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final d = days[index];
        final bool selectable = d.isCurrentMonth;

        final bool isStart = start != null && _isSameDay(d.date, start);
        final bool isEnd = end != null && _isSameDay(d.date, end);
        final bool isBetween =
            start != null &&
            end != null &&
            d.date.isAfter(start) &&
            d.date.isBefore(end);

        // Pill/line highlight rules
        // - Between days: full pill across cell
        // - Start day: pill only to the right (not behind the start circle)
        // - End day: pill only to the left (not behind the end circle)
        final bool showLeftPill = isBetween || isEnd;
        final bool showRightPill = isBetween || isStart;

        return GestureDetector(
          onTap: selectable ? () => _onDayTap(d.date) : null,
          child: _DayCellView(
            text: '${d.date.day}',
            isMuted: !d.isCurrentMonth,
            isWeekend: d.isWeekend,
            isStart: isStart,
            isEnd: isEnd,
            showLeftPill: showLeftPill,
            showRightPill: showRightPill,
          ),
        );
      },
    );
  }

  void _onDayTap(DateTime date) {
    setState(() {
      if (_tabIndex == 0) {
        _checkIn = date;
        _checkOut = null;
        _tabIndex = 1;
        return;
      }

      // Selecting checkout
      if (_checkIn == null) {
        _checkIn = date;
        _checkOut = null;
        return;
      }

      if (!date.isAfter(_checkIn!)) {
        // If user taps before/at check-in, treat it as new check-in
        _checkIn = date;
        _checkOut = null;
        _tabIndex = 1;
        return;
      }

      _checkOut = date;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<_CalendarDay> _buildCalendarDays() {
    final days = <_CalendarDay>[];

    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final nextMonth = _addMonths(firstOfMonth, 1);
    final lastOfMonth = nextMonth.subtract(const Duration(days: 1));

    // Weekday (Mon=1 .. Sun=7). We want the grid to start on Monday.
    final int leading = firstOfMonth.weekday - DateTime.monday;
    final startDate = firstOfMonth.subtract(Duration(days: leading));

    // 6 weeks grid for stable layout
    for (int i = 0; i < 42; i++) {
      final date = startDate.add(Duration(days: i));
      final isCurrentMonth =
          date.isAfter(firstOfMonth.subtract(const Duration(days: 1))) &&
          date.isBefore(lastOfMonth.add(const Duration(days: 1)));
      days.add(_CalendarDay(date: date, isCurrentMonth: isCurrentMonth));
    }

    return days;
  }

  String _monthTitle(DateTime month) {
    const m = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${m[month.month - 1]} ${month.year}';
  }

  DateTime _addMonths(DateTime date, int months) {
    final int yearDelta = (date.month - 1 + months) ~/ 12;
    final int newMonthIndex = (date.month - 1 + months) % 12;
    final int newMonth = newMonthIndex < 0
        ? newMonthIndex + 12 + 1
        : newMonthIndex + 1;
    final int newYear = date.year + yearDelta + (newMonthIndex < 0 ? -1 : 0);
    return DateTime(newYear, newMonth, 1);
  }

  Future<void> _onContinuePressed() async {
    final checkIn = _checkIn;
    final checkOut = _checkOut;
    if (checkIn == null || checkOut == null) return;

    if (!widget.createBookingOnContinue) {
      Get.back(
        result: {
          'checkIn': checkIn.toIso8601String(),
          'checkOut': checkOut.toIso8601String(),
        },
      );
      return;
    }

    if (widget.hotelId == null) {
      Get.snackbar('Booking', 'Hotel details are missing');
      return;
    }

    final selectedPayload = widget.selectedRoomQuantities.entries
        .where((entry) => entry.value > 0)
        .map((entry) => {'roomId': entry.key, 'quantity': entry.value})
        .toList();

    if (selectedPayload.isEmpty) {
      Get.snackbar('Booking', 'Please select at least one room');
      return;
    }

    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    final token = profileController.token;
    if (token.trim().isEmpty) {
      Get.snackbar('Login required', 'Please login to continue your booking');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await ApiService.createHotelBooking(
        token: token,
        hotelId: widget.hotelId!,
        checkIn: checkIn,
        checkOut: checkOut,
        rooms: selectedPayload,
      );

      final nights = checkOut.difference(checkIn).inDays;
      final summaryRooms = _buildSummaryRooms();

      final bookingGroup = response['bookingGroup'] as Map<String, dynamic>?;
      final backendTotal = _toDouble(bookingGroup?['totalPrice']);

      Get.off(
        () => BookingSummaryScreen(
          bookingType: 'hotel',
          hotelTitle: widget.hotelTitle,
          hotelAddress: widget.hotelAddress,
          hotelImageUrl: widget.hotelImageUrl,
          checkIn: checkIn,
          checkOut: checkOut,
          nights: nights > 0 ? nights : 1,
          selectedRooms: summaryRooms,
          bookingTotal: backendTotal,
          bookingResponse: response,
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Booking failed',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  List<Map<String, dynamic>> _buildSummaryRooms() {
    final roomById = <int, Map<String, dynamic>>{};
    for (final item in widget.rooms) {
      if (item is! Map<String, dynamic>) continue;
      final id = _toInt(item['id']);
      if (id != null) {
        roomById[id] = item;
      }
    }

    final selected = <Map<String, dynamic>>[];
    widget.selectedRoomQuantities.forEach((roomId, qty) {
      if (qty <= 0) return;
      final room = roomById[roomId];
      if (room == null) return;
      selected.add({
        'roomId': roomId,
        'title': room['title']?.toString() ?? 'Room $roomId',
        'price': _toDouble(room['price']),
        'quantity': qty,
        'imageUrl': ListingService.roomImageUrl(roomId),
      });
    });

    return selected;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _CalendarDay {
  _CalendarDay({required this.date, required this.isCurrentMonth});

  final DateTime date;
  final bool isCurrentMonth;

  bool get isWeekend =>
      date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
}

class _DayCellView extends StatelessWidget {
  const _DayCellView({
    required this.text,
    required this.isMuted,
    required this.isWeekend,
    required this.isStart,
    required this.isEnd,
    required this.showLeftPill,
    required this.showRightPill,
  });

  final String text;
  final bool isMuted;
  final bool isWeekend;
  final bool isStart;
  final bool isEnd;
  final bool showLeftPill;
  final bool showRightPill;

  @override
  Widget build(BuildContext context) {
    final baseTextColor = isMuted
        ? const Color(0xFFC8CDD6)
        : isWeekend
        ? const Color(0xFF2FC1BE)
        : const Color(0xFF6B7280);

    // This draws a continuous line by bleeding into the grid spacing.
    // Range fill should not appear behind start/end circles, only between them.
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Must cover the grid spacing (crossAxisSpacing=8) so there are no seams.
        const double bleed = 14;
        const double pillHeight = 34;
        const double circleSize = 38;
        final double w = constraints.maxWidth;
        final double center = w / 2;
        final double circleRadius = circleSize / 2;

        final bool shouldShow =
            (showLeftPill || showRightPill) && !(isStart && isEnd);

        double? left;
        double? right;
        BorderRadius? radius;

        if (shouldShow) {
          // Full range day
          if (!isStart && !isEnd) {
            left = -bleed;
            right = -bleed;
            // Middle segments must be square so adjacent cells connect seamlessly.
            radius = BorderRadius.zero;
          }

          // Start day: draw only to the right, starting after the circle
          if (isStart && showRightPill) {
            left = center + circleRadius;
            right = -bleed;
            // Keep square edges so it connects seamlessly to the next cell.
            radius = BorderRadius.zero;
          }

          // End day: draw only to the left, ending before the circle
          if (isEnd && showLeftPill) {
            left = -bleed;
            right = w - (center - circleRadius);
            // Keep square edges so it connects seamlessly to the previous cell.
            radius = BorderRadius.zero;
          }
        }

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (left != null && right != null)
              Positioned(
                left: left,
                right: right,
                top: (constraints.maxHeight - pillHeight) / 2,
                height: pillHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      const Color(0xFF2FC1BE).withOpacity(0.18),
                      theme.scaffoldBackgroundColor,
                    ),
                    borderRadius: radius,
                  ),
                ),
              ),
            if (isStart || isEnd)
              Container(
                width: circleSize,
                height: circleSize,
                decoration: const BoxDecoration(
                  color: Color(0xFF1B7DAA),
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              text,
              style: TextStyle(
                color: (isStart || isEnd) ? Colors.white : baseTextColor,
                fontSize: 12,
                fontWeight: (isStart || isEnd)
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}
