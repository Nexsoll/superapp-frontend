import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class PropertyFilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>)? onApply;

  const PropertyFilterBottomSheet({super.key, this.onApply});

  @override
  State<PropertyFilterBottomSheet> createState() => _PropertyFilterBottomSheetState();
}

class _PropertyFilterBottomSheetState extends State<PropertyFilterBottomSheet> {
  int selectedPropertyTypeIndex = 0;
  double priceRange = 2500000; // Default middle value roughly
  int selectedBedroomsIndex = 2; // Default to 2
  int selectedBathroomsIndex = 0; // Default to Any
  final TextEditingController minAreaController = TextEditingController();
  final TextEditingController maxAreaController = TextEditingController();

  final List<Map<String, dynamic>> propertyTypes = [
    {'iconPath': 'assets/filter-home.svg', 'label': 'House'},
    {'iconPath': 'assets/appartment.svg', 'label': 'Appartment'},
    {'iconPath': 'assets/condo.svg', 'label': 'Condo'},
    {'iconPath': 'assets/land.svg', 'label': 'Land'},
    {'iconPath': 'assets/vila.svg', 'label': 'Villa'},
    {'iconPath': 'assets/twinhouse.svg', 'label': 'Townhouse'},
  ];

  final List<String> bedroomOptions = ['Any', '1', '2', '3', '4+'];
  final List<String> bathroomOptions = ['Any', '1', '2', '3', '4+'];

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
                    selectedPropertyTypeIndex = 0;
                    priceRange = 50;
                    selectedBedroomsIndex = 0;
                    selectedBathroomsIndex = 0;
                    minAreaController.clear();
                    maxAreaController.clear();
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
                  // Property Type
                  Text('Property Type'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: propertyTypes.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedPropertyTypeIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => selectedPropertyTypeIndex = index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? (theme.brightness == Brightness.dark ? const Color(0xFF2FC1BE).withOpacity(0.2) : const Color(0xFFE0F7F6)) 
                                : theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2FC1BE) : (theme.brightness == Brightness.dark ? Colors.white24 : const Color(0xFFE8E8E8)),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                propertyTypes[index]['iconPath'],
                                height: 34,
                                width: 34,
                                colorFilter: ColorFilter.mode(
                                  isSelected ? const Color(0xFF2FC1BE) : const Color(0xFF747477),
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                propertyTypes[index]['label'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? const Color(0xFF2FC1BE) : const Color(0xFF747477),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
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
                      Text('\$8M+',
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
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      trackShape: _FullWidthTrackShape(),
                    ),
                    child: Slider(
                      value: priceRange,
                      min: 50,
                      max: 8000000,
                      onChanged: (val) => setState(() => priceRange = val),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Bedrooms
                  Text('Bedrooms'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(bedroomOptions.length, (index) {
                      final isSelected = selectedBedroomsIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => selectedBedroomsIndex = index),
                        child: Container(
                          width: 50,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2FC1BE) : theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2FC1BE) : (theme.brightness == Brightness.dark ? Colors.white24 : const Color(0xFFE8E8E8)),
                            ),
                          ),
                          child: Text(
                            bedroomOptions[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF9AA0AF),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),
                  // Bathrooms
                  Text('Bathrooms'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(bathroomOptions.length, (index) {
                      final isSelected = selectedBathroomsIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => selectedBathroomsIndex = index),
                        child: Container(
                          width: 50,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2FC1BE) : theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2FC1BE) : (theme.brightness == Brightness.dark ? Colors.white24 : const Color(0xFFE8E8E8)),
                            ),
                          ),
                          child: Text(
                            bathroomOptions[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF9AA0AF),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),
                  // Living Area
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Living Area'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                        ),
                      ),
                      Text('sqft'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF9AA0AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.brightness == Brightness.dark ? Colors.white24 : const Color(0xFFE8E8E8)),
                          ),
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            controller: minAreaController,
                            style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330)),
                            decoration: InputDecoration(
                              hintText: 'Min'.tr,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintStyle: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white54 : const Color(0xFF9AA0AF)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('-'.tr,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: theme.brightness == Brightness.dark ? Colors.white54 : const Color(0xFF9AA0AF),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.brightness == Brightness.dark ? Colors.white24 : const Color(0xFFE8E8E8)),
                          ),
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            controller: maxAreaController,
                            style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330)),
                            decoration: InputDecoration(
                              hintText: 'Max'.tr,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintStyle: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white54 : const Color(0xFF9AA0AF)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // Footer Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (widget.onApply != null) {
                  widget.onApply!({
                    'propertyTypeIndex': selectedPropertyTypeIndex,
                    'priceRange': priceRange,
                    'bedroomsIndex': selectedBedroomsIndex,
                    'bathroomsIndex': selectedBathroomsIndex,
                    'minArea': minAreaController.text.isNotEmpty ? double.tryParse(minAreaController.text) : null,
                    'maxArea': maxAreaController.text.isNotEmpty ? double.tryParse(maxAreaController.text) : null,
                  });
                }
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2FC1BE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text('Apply'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
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
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
