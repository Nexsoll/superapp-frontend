import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>)? onApply;

  const FilterBottomSheet({super.key, this.onApply});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int adults = 2;
  int children = 1;
  double priceRange = 500;
  List<String> selectedAmenities = ['Free wifi'];

  final List<String> amenities = [
    'Free wifi',
    'Gym',
    'Pool',
    'Pet Friendly',
    'Breakfast',
    'Parking'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? Colors.white24 : const Color(0xFFCFD6DC),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.close, color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330), size: 24),
              ),
              Text('Filter options'.tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    adults = 2;
                    children = 1;
                    priceRange = 500;
                    selectedAmenities = ['Free wifi'];
                  });
                },
                child: Text('Reset'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2FC1BE),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number of Guests
                  Text('Number of Guests'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2FC1BE).withOpacity(0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _circularButton(Icons.remove, () {
                          if (adults > 1) setState(() => adults--);
                        }, theme),
                        Text(
                          '$adults Adults, $children Child',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                          ),
                        ),
                        _circularButton(Icons.add, () => setState(() => adults++), theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _counterRow('Adults', adults, (val) => setState(() => adults = val), theme),
                  _counterRow('Childrens', children, (val) => setState(() => children = val), theme),
                  
                  const SizedBox(height: 32),
                  // Price Range
                  Text('Price Range'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$50',
                          style: TextStyle(
                              color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF9AA0AF),
                              fontWeight: FontWeight.w600,
                              fontSize: 16)),
                      Text('\$1000+',
                          style: TextStyle(
                              color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF9AA0AF),
                              fontWeight: FontWeight.w600,
                              fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: const Color(0xFF2FC1BE).withOpacity(0.3),
                      inactiveTrackColor: theme.brightness == Brightness.dark ? Colors.white24 : const Color(0xFFE8F1F1),
                      thumbColor: const Color(0xFF2FC1BE),
                      overlayColor: const Color(0xFF2FC1BE).withOpacity(0.2),
                      trackHeight: 6,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 12),
                      trackShape: _FullWidthTrackShape(),
                    ),
                    child: Slider(
                      value: priceRange,
                      min: 50,
                      max: 1000,
                      onChanged: (val) => setState(() => priceRange = val),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Calendar
                  Text('Check-in/Check-out Dates'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.brightness == Brightness.dark ? Colors.white24 : const Color(0xFFADAEBC), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text('December'.tr,
                          style: TextStyle(
                            color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF9AA0AF),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCalendarGrid(theme),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Check-in'.tr, style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white70 : Color(0xFF9AA0AF), fontSize: 14, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text('Dec 13'.tr, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: theme.brightness == Brightness.dark ? Colors.white : Color(0xFF1D2330))),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Check-out'.tr, style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white70 : Color(0xFF9AA0AF), fontSize: 14, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text('Dec 16'.tr, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: theme.brightness == Brightness.dark ? Colors.white : Color(0xFF1D2330))),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Amenities
                  Text('Amenities'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: amenities.map((amenity) {
                      bool isSelected = selectedAmenities.contains(amenity);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedAmenities.remove(amenity);
                            } else {
                              selectedAmenities.add(amenity);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? (theme.brightness == Brightness.dark ? const Color(0xFF2FC1BE).withOpacity(0.2) : const Color(0xFFE8F1F1))
                              : theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Color(0xFF2FC1BE) : (theme.brightness == Brightness.dark ? Colors.white24 : Colors.transparent),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            amenity,
                            style: const TextStyle(
                              color: Color(0xFF2FC1BE),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.onApply != null) {
                          widget.onApply!({
                            'adults': adults,
                            'children': children,
                            'priceRange': priceRange,
                            'selectedAmenities': selectedAmenities,
                          });
                        }
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2FC1BE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Text('Apply'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme) {
    final List<String> weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays.map((day) => Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  color: (day == 'Sa' || day == 'Su') ? const Color(0xFF2FC1BE) : (theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF9AA0AF)),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 35,
          itemBuilder: (context, index) {
            int day = index - 2;
            if (day < 1 || day > 31) return const SizedBox();
            
            bool isSelectedStart = day == 13;
            bool isSelectedEnd = day == 16;
            bool inRange = day > 13 && day < 16;
            bool isWeekend = (index % 7 == 5 || index % 7 == 6);

            return Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: (isSelectedStart || isSelectedEnd || inRange) 
                      ? const Color(0xFF1D2330) // Dark for selection
                      : (isWeekend ? const Color(0xFF2FC1BE) : (theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF9AA0AF))),
                  fontWeight: (isSelectedStart || isSelectedEnd) ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _circularButton(IconData icon, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF2FC1BE), size: 24),
      ),
    );
  }

  Widget _counterRow(String label, int value, Function(int) onChanged, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
            ),
          ),
          Row(
            children: [
              _smallCounterButton(Icons.remove, () {
                if (value > 0) onChanged(value - 1);
              }, theme),
              const SizedBox(width: 16),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                ),
              ),
              const SizedBox(width: 16),
              _smallCounterButton(Icons.add, () => onChanged(value + 1), theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallCounterButton(IconData icon, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark ? const Color(0xFF2C2C2E) : const Color(0xFFDDF4F4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF2FC1BE), size: 18),
      ),
    );
  }
}

class _FullWidthTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
