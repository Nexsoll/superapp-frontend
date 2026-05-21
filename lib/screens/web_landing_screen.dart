import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:superapp/app_routes.dart';
import 'package:superapp/controllers/web_landing_controller.dart';
import 'package:superapp/services/listing_service.dart';
import 'package:superapp/screens/hotel_search_screen.dart';
import 'package:superapp/screens/hotel_detail_screen.dart';
import 'package:superapp/screens/property_search_screen.dart';
import 'package:superapp/screens/property_detail_screen.dart';
import 'package:superapp/screens/ar_room_tour_screen.dart';
import 'package:superapp/screens/dedicated_ai_chat_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class WebLandingScreen extends StatefulWidget {
  const WebLandingScreen({super.key});

  @override
  State<WebLandingScreen> createState() => _WebLandingScreenState();
}

class _WebLandingScreenState extends State<WebLandingScreen> {
  final WebLandingController _controller = Get.put(WebLandingController());

  // Search form state
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _locationFocusNode = FocusNode();
  DateTimeRange? _selectedDates;
  int _adults = 2;
  int _children = 0;
  int _rooms = 1;

  // Location autocomplete
  bool _showLocationDropdown = false;
  List<String> _filteredLocations = [];
  bool _isSelectingLocationFromDropdown = false;
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isSpeechAvailable = false;
  bool _isListening = false;
  int _popularTabIndex = 0;

  List<String> get _allLocations {
    return _controller.getAutocompleteLocations();
  }

  @override
  void initState() {
    super.initState();
    _locationController.addListener(_onLocationChanged);
    _initSpeech();
    _locationFocusNode.addListener(() {
      if (!_locationFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 120), () {
          if (!mounted ||
              _locationFocusNode.hasFocus ||
              _isSelectingLocationFromDropdown) {
            return;
          }
          setState(() {
            _showLocationDropdown = false;
          });
        });
      }
    });
  }

  Future<void> _initSpeech() async {
    final available = await _speechToText.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
        });
      },
    );
    if (!mounted) return;
    setState(() {
      _isSpeechAvailable = available;
    });
  }

  @override
  void dispose() {
    _speechToText.stop();
    _locationController.removeListener(_onLocationChanged);
    _locationController.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  void _onLocationChanged() {
    final rawQuery = _locationController.text.trim();
    setState(() {
      _filteredLocations = [];
      _showLocationDropdown = false;
      _controller.selectedLocation.value = rawQuery;
    });
  }

  Future<void> _toggleVoiceSearch() async {
    if (_isListening) {
      await _speechToText.stop();
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
      return;
    }

    if (!_isSpeechAvailable) {
      await _initSpeech();
    }
    if (!_isSpeechAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _controller.tr('Voice search is not available on this browser.'),
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isListening = true;
      _showLocationDropdown = false;
    });

    await _speechToText.listen(
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 2),
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.search,
        partialResults: true,
        cancelOnError: true,
      ),
      onResult: (result) {
        final transcript = result.recognizedWords.trim();
        if (transcript.isEmpty) return;
        _locationController.value = TextEditingValue(
          text: transcript,
          selection: TextSelection.collapsed(offset: transcript.length),
        );
        _controller.selectedLocation.value = transcript;
        if (result.finalResult) {
          _onSearch();
        }
      },
    );
  }

  void _selectLocation(String location) {
    _isSelectingLocationFromDropdown = true;
    _locationController.value = TextEditingValue(
      text: location,
      selection: TextSelection.collapsed(offset: location.length),
    );
    _controller.selectedLocation.value = location;
    setState(() {
      _filteredLocations = _allLocations;
      _showLocationDropdown = false;
    });
    _locationFocusNode.unfocus();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _isSelectingLocationFromDropdown = false;
      }
    });
  }

  void _onSearch() {
    final query = _locationController.text.trim();
    _controller.selectedLocation.value = query;
    setState(() {
      _showLocationDropdown = false;
    });
    _locationFocusNode.unfocus();
    Get.to(
      () => HotelSearchScreen(searchQuery: query.isNotEmpty ? query : null),
    );
  }

  Future<void> _selectDates() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange:
          _selectedDates ??
          DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 1)),
          ),
      builder: (context, child) {
        final primary = Theme.of(context).colorScheme.primary;
        final pickerTheme = ThemeData.light(useMaterial3: true);
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 650),
            child: Theme(
              data: pickerTheme.copyWith(
                colorScheme: pickerTheme.colorScheme.copyWith(
                  primary: primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  headerBackgroundColor: primary,
                  headerForegroundColor: Colors.white,
                  rangePickerBackgroundColor: Colors.white,
                  rangePickerHeaderBackgroundColor: primary,
                  rangePickerHeaderForegroundColor: Colors.white,
                ),
                dialogTheme: const DialogThemeData(
                  backgroundColor: Colors.white,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: primary),
                ),
              ),
              child: child!,
            ),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDates = picked;
      });
    }
  }

  void _showGuestsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(_controller.tr('Guests & Rooms')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGuestCounter(_controller.tr('Adults'), _adults, (val) {
                    if (val >= 1) {
                      setDialogState(() => _adults = val);
                      setState(() => _adults = val);
                    }
                  }),
                  const SizedBox(height: 16),
                  _buildGuestCounter(_controller.tr('Children'), _children, (
                    val,
                  ) {
                    if (val >= 0) {
                      setDialogState(() => _children = val);
                      setState(() => _children = val);
                    }
                  }),
                  const SizedBox(height: 16),
                  _buildGuestCounter(_controller.tr('Rooms'), _rooms, (val) {
                    if (val >= 1) {
                      setDialogState(() => _rooms = val);
                      setState(() => _rooms = val);
                    }
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_controller.tr('Done')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildGuestCounter(
    String label,
    int value,
    ValueChanged<int> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () => onChanged(value - 1),
            ),
            SizedBox(
              width: 30,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }

  String _whyIconSvg(String iconKey) {
    switch (iconKey) {
      case 'calendar':
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="3" y="5" width="18" height="16" rx="3" stroke="#2FC1BE" stroke-width="1.8"/>
  <path d="M3 10H21" stroke="#2FC1BE" stroke-width="1.8"/>
  <path d="M8 3V7M16 3V7" stroke="#2FC1BE" stroke-width="1.8" stroke-linecap="round"/>
  <path d="M8.5 14.5L10.8 16.8L15.5 12.2" stroke="#2FC1BE" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';
      case 'shield':
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 3L19 6V11C19 15.5 16.1 19.6 12 21C7.9 19.6 5 15.5 5 11V6L12 3Z" stroke="#2FC1BE" stroke-width="1.8"/>
  <path d="M9 12.5L11.2 14.7L15.2 10.7" stroke="#2FC1BE" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';
      case 'globe':
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="9" stroke="#2FC1BE" stroke-width="1.8"/>
  <path d="M3.5 12H20.5" stroke="#2FC1BE" stroke-width="1.8"/>
  <path d="M12 3C14.4 5.4 15.8 8.6 15.8 12C15.8 15.4 14.4 18.6 12 21" stroke="#2FC1BE" stroke-width="1.8"/>
  <path d="M12 3C9.6 5.4 8.2 8.6 8.2 12C8.2 15.4 9.6 18.6 12 21" stroke="#2FC1BE" stroke-width="1.8"/>
</svg>
''';
      default:
        return '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M5 11C5 7.1 8.1 4 12 4C15.9 4 19 7.1 19 11V17C19 18.7 17.7 20 16 20H8C6.3 20 5 18.7 5 17V11Z" stroke="#2FC1BE" stroke-width="1.8"/>
  <path d="M8 11V9.5C8 7.3 9.8 5.5 12 5.5C14.2 5.5 16 7.3 16 9.5V11" stroke="#2FC1BE" stroke-width="1.8"/>
  <circle cx="9" cy="12.8" r="1" fill="#2FC1BE"/>
  <circle cx="15" cy="12.8" r="1" fill="#2FC1BE"/>
</svg>
''';
    }
  }

  String _resolveImageUrl(
    Map<String, dynamic> item, {
    required bool isProperty,
  }) {
    final idRaw = item['id'];
    final id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '');
    if (id == null) return '';

    final photos = item['photos'];
    if (photos is List && photos.isNotEmpty) {
      if (isProperty) {
        return ListingService.propertyImageUrl(id, 0);
      }
      return ListingService.hotelImageUrl(id, 0);
    }

    final images = item['images'];
    if (images is List && images.isNotEmpty) {
      if (isProperty) {
        return ListingService.propertyImageUrl(id, 0);
      }
      return ListingService.hotelImageUrl(id, 0);
    }

    return '';
  }

  // 1. HERO SECTION & TOP NAVBAR
  Widget _buildHeroSection(Color primaryColor) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0C2424), // Extra deep visual base
            Color(0xFF144746), // Deep rich theme blend
            Color(0xFF2FC1BE), // Actual kPrimaryColor
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top Navbar
          _buildTopNav(),

          // Hero Title
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFFFB700),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _controller.tr('Verified Stays & Low Prices'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.5,
                        height: 1.1,
                      ),
                      children: [
                        TextSpan(text: _controller.tr('Find your next ')),
                        TextSpan(
                          text: _controller.tr('perfect stay'),
                          style: const TextStyle(color: Color(0xFF2FC1BE)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _controller.tr(
                      'Search low prices on hotels, holiday homes, and premium real estate.',
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav() {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Obx(
      () => Container(
        width: double.infinity,
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Row(
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 90,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'IDS EUROPE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    );
                  },
                ),
                const Spacer(),
                if (isDesktop) ...[
                  _buildLocalePill(
                    icon: Icons.currency_exchange,
                    label: _controller.tr('Currency'),
                    value: _controller.displayCurrency,
                  ),
                  const SizedBox(width: 10),
                  _buildLanguageSwitcher(),
                  const SizedBox(width: 14),
                  _NavTextButton(_controller.tr('List your property'), () {}),
                  const SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: () => Get.toNamed(AppRoutes.signUp),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      _controller.tr('Register'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Get.toNamed(AppRoutes.signIn),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2FC1BE),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      _controller.tr('Sign in'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ] else ...[
                  _buildCompactCurrencyPill(),
                  const SizedBox(width: 8),
                  _buildCompactLanguageSwitcher(),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Get.toNamed(AppRoutes.signIn),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2FC1BE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      _controller.tr('Sign in'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCurrencyPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.currency_exchange, size: 13, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            _controller.displayCurrency,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLanguageSwitcher() {
    return PopupMenuButton<String>(
      initialValue: _controller.currentLanguageCode,
      onSelected: (code) => _controller.setSelectedLanguage(code),
      color: const Color(0xFF0F3E3D),
      itemBuilder: (context) {
        return _controller.languageOptions
            .map(
              (code) => PopupMenuItem<String>(
                value: code,
                child: Text(
                  _controller.languageLabelForCode(code),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
            .toList();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: const Icon(Icons.language, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildLocalePill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSwitcher() {
    return PopupMenuButton<String>(
      initialValue: _controller.currentLanguageCode,
      onSelected: (code) => _controller.setSelectedLanguage(code),
      color: const Color(0xFF0F3E3D),
      itemBuilder: (context) {
        return _controller.languageOptions
            .map(
              (code) => PopupMenuItem<String>(
                value: code,
                child: Text(
                  _controller.languageLabelForCode(code),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
            .toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 14, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              '${_controller.tr('Language')}: ${_controller.currentLanguageLabel}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, size: 14, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  // 2. RESPONSIVE SEARCH BAR
  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 960;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.06),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  Row(
                    children: [
                      Expanded(flex: 3, child: _buildLocationField()),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark ? Colors.white10 : Colors.grey[200],
                      ),
                      Expanded(
                        flex: 3,
                        child: _buildDatesField(verticalPadding: 18),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark ? Colors.white10 : Colors.grey[200],
                      ),
                      Expanded(
                        flex: 3,
                        child: _buildGuestsField(verticalPadding: 18),
                      ),
                      const SizedBox(width: 12),
                      _buildSearchButton(isFullWidth: false),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildLocationField(),
                      Divider(
                        height: 1,
                        color: isDark
                            ? Colors.white10
                            : const Color(0xFFF1F5F9),
                      ),
                      _buildDatesField(verticalPadding: 16),
                      Divider(
                        height: 1,
                        color: isDark
                            ? Colors.white10
                            : const Color(0xFFF1F5F9),
                      ),
                      _buildGuestsField(verticalPadding: 16),
                      const SizedBox(height: 12),
                      _buildSearchButton(isFullWidth: true),
                    ],
                  ),
                if (_showLocationDropdown) _buildLocationDropdown(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: _locationController,
      focusNode: _locationFocusNode,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        fillColor: theme.cardColor,
        filled: true,
        hintText: _controller.tr('Where are you going?'),
        hintStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white54 : Colors.black54,
          fontSize: 15,
        ),
        prefixIcon: const Icon(
          Icons.location_on_outlined,
          color: Color(0xFF2FC1BE),
          size: 22,
        ),
        suffixIcon: _locationController.text.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: _isListening
                        ? 'Stop voice search'
                        : 'Voice search',
                    icon: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? const Color(0xFF2FC1BE)
                            : const Color(0xFF2FC1BE).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        size: 18,
                        color: _isListening
                            ? Colors.white
                            : const Color(0xFF2FC1BE),
                      ),
                    ),
                    onPressed: _toggleVoiceSearch,
                  ),
                  IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _locationController.clear();
                      _controller.selectedLocation.value = '';
                      setState(() {
                        _showLocationDropdown = false;
                      });
                    },
                  ),
                ],
              )
            : IconButton(
                tooltip: _isListening ? 'Stop voice search' : 'Voice search',
                icon: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _isListening
                        ? const Color(0xFF2FC1BE)
                        : const Color(0xFF2FC1BE).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 18,
                    color: _isListening
                        ? Colors.white
                        : const Color(0xFF2FC1BE),
                  ),
                ),
                onPressed: _toggleVoiceSearch,
              ),
        suffixIconConstraints: const BoxConstraints(minWidth: 96),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildDatesField({required double verticalPadding}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: _selectDates,
      borderRadius: BorderRadius.circular(8),
      hoverColor: const Color(0xFF2FC1BE).withOpacity(0.05),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: verticalPadding,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF2FC1BE),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDates == null
                    ? _controller.tr('Check-in — Check-out')
                    : '${DateFormat('MMM d').format(_selectedDates!.start)} — ${DateFormat('MMM d').format(_selectedDates!.end)}',
                style: TextStyle(
                  fontWeight: _selectedDates == null
                      ? FontWeight.w500
                      : FontWeight.w600,
                  color: _selectedDates == null
                      ? (isDark ? Colors.white54 : Colors.black54)
                      : (isDark ? Colors.white : Colors.black),
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestsField({required double verticalPadding}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: _showGuestsDialog,
      borderRadius: BorderRadius.circular(8),
      hoverColor: const Color(0xFF2FC1BE).withOpacity(0.05),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: verticalPadding,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF2FC1BE),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$_adults adults · $_children children · $_rooms room',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton({required bool isFullWidth}) {
    final searchBtnColor = Theme.of(context).colorScheme.primary;
    final button = ElevatedButton(
      onPressed: _onSearch,
      style: ElevatedButton.styleFrom(
        backgroundColor: searchBtnColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: searchBtnColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
      ),
      child: Text(
        _controller.tr('Search'),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _buildLocationDropdown() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _filteredLocations.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                'No locations found',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: _filteredLocations.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
              ),
              itemBuilder: (context, index) {
                final location = _filteredLocations[index];
                return InkWell(
                  onTapDown: (_) {
                    _isSelectingLocationFromDropdown = true;
                  },
                  onTap: () => _selectLocation(location),
                  hoverColor: const Color(0xFF2FC1BE).withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF2FC1BE),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white.withOpacity(0.87)
                                  : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // 3. STATS SECTION (NEW!)
  Widget _buildStatsSection() {
    final stats = [
      (
        value: '15,000+',
        label: 'Happy Guests',
        icon: Icons.people_outline_rounded,
      ),
      (
        value: '1,200+',
        label: 'Verified Stays',
        icon: Icons.verified_user_outlined,
      ),
      (value: '150+', label: 'Top Destinations', icon: Icons.map_outlined),
      (
        value: '4.9 / 5',
        label: 'Guest Rating',
        icon: Icons.star_border_rounded,
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return Wrap(
                spacing: 24,
                runSpacing: 20,
                alignment: WrapAlignment.spaceEvenly,
                children: stats.map((stat) {
                  return Container(
                    width: isWide
                        ? (constraints.maxWidth - 3 * 24) / 4
                        : (constraints.maxWidth - 24) / 2,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2FC1BE).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            stat.icon,
                            color: const Color(0xFF2FC1BE),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stat.value,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF111827),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                stat.label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  // 4. WHY IDS EUROPE SECTION (Alternating Background)
  Widget _buildWhySection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8FAFC),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _controller.tr('Why IDS EUROPE?'),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _controller.tr(
                    'We offer the best accommodation services and properties in top European cities.',
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 36),
                _buildWhySectionCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhySectionCards() {
    final cards = [
      {
        'iconKey': 'calendar',
        'title': 'Book now, pay later',
        'subtitle': 'Flexible bookings on selected stays',
      },
      {
        'iconKey': 'shield',
        'title': 'Trusted by travelers',
        'subtitle': 'Verified reviews and reliable listings',
      },
      {
        'iconKey': 'globe',
        'title': 'Hotels & properties',
        'subtitle': 'Discover stays in key destinations',
      },
      {
        'iconKey': 'support',
        'title': '24/7 support',
        'subtitle': 'We are here whenever you need help',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 980
            ? 4
            : constraints.maxWidth >= 680
            ? 2
            : 1;
        const spacing = 24.0;
        final itemWidth =
            (constraints.maxWidth - (columns - 1) * spacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.map((card) {
            return SizedBox(
              width: itemWidth,
              child: _WhyCard(
                cardData: {
                  ...card,
                  'title': _controller.tr(card['title']!),
                  'subtitle': _controller.tr(card['subtitle']!),
                },
                icon: SvgPicture.string(
                  _whyIconSvg(card['iconKey']!),
                  fit: BoxFit.contain,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // AI & AR FEATURES SECTION (Stunning Dark Modern Showcase)
  Widget _buildAiArFeaturesSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A), // Premium futuristic dark slate
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2FC1BE).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF2FC1BE).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF2FC1BE),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _controller.tr('NEXT-GENERATION TRAVEL'),
                      style: const TextStyle(
                        color: Color(0xFF2FC1BE),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _controller.tr('Experience Stays Like Never Before'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Text(
                  _controller.tr(
                    'Explore room layouts with immersive Augmented Reality tours, and plan your trips conversationally using our advanced AI Travel Assistant.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 54),
              // Side by side or stacked layout
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 960;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _AiFeatureCard(
                            onTapChat: () {
                              Get.to(() => const DedicatedAiChatScreen());
                            },
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: _ArFeatureCard(
                            onTapAr: () {
                              Get.to(() => const ArRoomTourScreen());
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _AiFeatureCard(
                          onTapChat: () {
                            Get.to(() => const DedicatedAiChatScreen());
                          },
                        ),
                        const SizedBox(height: 32),
                        _ArFeatureCard(
                          onTapAr: () {
                            Get.to(() => const ArRoomTourScreen());
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. EXPLORE DESTINATIONS SECTION (NEW!)
  Widget _buildDestinationsSection(ThemeData theme) {
    final destinations = [
      (
        name: 'Paris',
        properties: '320+ stays',
        imageUrl:
            'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=600&q=80',
      ),
      (
        name: 'London',
        properties: '450+ stays',
        imageUrl:
            'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=600&q=80',
      ),
      (
        name: 'Rome',
        properties: '280+ stays',
        imageUrl:
            'https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&w=600&q=80',
      ),
      (
        name: 'Amsterdam',
        properties: '190+ stays',
        imageUrl:
            'https://images.unsplash.com/photo-1519608487953-e999c86e7455?auto=format&fit=crop&w=600&q=80',
      ),
    ];

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Top Destinations',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111827),
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Discover stays and properties in the most visited cities in Europe',
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 36),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double width = constraints.maxWidth;
                    int columns = 4;
                    if (width < 600)
                      columns = 1;
                    else if (width < 900)
                      columns = 2;
                    else if (width < 1200)
                      columns = 3;

                    const spacing = 24.0;
                    final itemWidth =
                        (width - (columns - 1) * spacing) / columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: destinations.map((dest) {
                        return SizedBox(
                          width: itemWidth,
                          child: _DestinationCard(dest: dest),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 6. POPULAR LISTINGS SECTION (Tabbed hotels/properties)
  Widget _buildPopularListingsSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8FAFC),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: CircularProgressPadding());
              }

              final hotels = _controller.getPopularHotelsForUserLocation();
              final properties = _controller
                  .getPopularPropertiesForUserLocation();
              final activeCountry = _controller.activeCountryOrNull;
              final isPropertyTab = _popularTabIndex == 1;
              final title = isPropertyTab
                  ? _controller.tr('Popular Properties')
                  : _controller.tr('Popular Hotels');
              final subtitle = isPropertyTab
                  ? _controller.propertiesSubtitleForCountry(activeCountry)
                  : _controller.hotelsSubtitleForCountry(activeCountry);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _controller.tr('Popular Stays'),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF4B5563),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: () {
                          if (isPropertyTab) {
                            Get.to(() => const PropertySearchScreen());
                          } else {
                            Get.to(() => HotelSearchScreen());
                          }
                        },
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: Text(
                          _controller.tr('View All'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildPopularTab(
                        label: _controller.tr('Hotels'),
                        selected: !isPropertyTab,
                        onTap: () => setState(() => _popularTabIndex = 0),
                      ),
                      _buildPopularTab(
                        label: _controller.tr('Properties'),
                        selected: isPropertyTab,
                        onTap: () => setState(() => _popularTabIndex = 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildListingsGrid(
                    items: isPropertyTab ? properties : hotels,
                    isProperty: isPropertyTab,
                    theme: theme,
                    countryContext: activeCountry,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2FC1BE) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF2FC1BE) : const Color(0xFFE2E8F0),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2FC1BE).withOpacity(0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // 7. HOST/PARTNER CTA BANNER (NEW!)
  Widget _buildCtaBanner() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F3E3D), Color(0xFF2FC1BE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2FC1BE).withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _controller.tr('List your property on IDS EUROPE'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _controller.tr(
                        'Reach thousands of travelers and property seekers in minutes. Simple setups, low fees, 24/7 help.',
                      ),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );

                final button = ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F3E3D),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                  ),
                  child: Text(
                    _controller.tr('Get Started Today'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );

                if (!isWide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      content,
                      const SizedBox(height: 24),
                      SizedBox(width: double.infinity, child: button),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: content),
                    const SizedBox(width: 40),
                    button,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListingsGrid({
    required List<Map<String, dynamic>> items,
    required bool isProperty,
    required ThemeData theme,
    String? countryContext,
  }) {
    if (items.isEmpty) {
      final normalizedCountry = countryContext?.trim();
      final emptyForLocation = isProperty
          ? _controller.tr('No properties found for this location.')
          : _controller.tr('No hotels found for this location.');
      final emptyInCountry = isProperty
          ? _controller.tr('No properties found in')
          : _controller.tr('No hotels found in');
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          normalizedCountry == null || normalizedCountry.isEmpty
              ? emptyForLocation
              : '$emptyInCountry $normalizedCountry.',
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        int columns = 4;
        if (width < 600) {
          columns = 1;
        } else if (width < 900) {
          columns = 2;
        } else if (width < 1200) {
          columns = 3;
        }

        final displayCount = items.length > 8 ? 8 : items.length;
        const spacing = 24.0;
        final itemWidth = (width - (columns - 1) * spacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.take(displayCount).map((item) {
            final title = (item['title'] ?? item['name'] ?? '').toString();
            final address = (item['address'] ?? '').toString();
            final String price = isProperty
                ? _controller.getPropertyPrice(item)
                : _controller.getMinPrice(item);
            final imageUrl = _resolveImageUrl(item, isProperty: isProperty);

            final rawRating = item['overallRating'] ?? item['rating'];
            final rating = rawRating != null
                ? double.tryParse(rawRating.toString())?.toStringAsFixed(1) ??
                      'New'
                : 'New';

            return SizedBox(
              width: itemWidth,
              child: _ListingCard(
                item: item,
                isProperty: isProperty,
                title: title,
                address: address,
                price: price,
                rating: rating,
                imageUrl: imageUrl,
                onTap: () {
                  if (isProperty) {
                    Get.to(() => PropertyDetailScreen(propertyData: item));
                  } else {
                    Get.to(() => HotelDetailScreen(hotelData: item));
                  }
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // 9. TESTIMONIALS SECTION (NEW!)
  Widget _buildTestimonialsSection() {
    final reviews = [
      (
        name: 'Sophia Laurent',
        role: 'Verified Traveler',
        text:
            'The best booking experience I\'ve ever had. Properties are highly verified, matching exactly what\'s shown on the page. Simply amazing!',
        rating: 5,
      ),
      (
        name: 'Marcus Vance',
        role: 'Property Owner',
        text:
            'Listing my London apartments on IDS Europe was simple. Within two weeks, I filled three vacancies. The support team has been responsive 24/7.',
        rating: 5,
      ),
      (
        name: 'Elena Rostova',
        role: 'Family Vacationer',
        text:
            'Highly recommend this platform. The search bar filters let us find an excellent kid-friendly villa in Rome at a low price.',
        rating: 5,
      ),
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What Our Users Say',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Read stories from travelers and property hosts across the continent',
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 36),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double width = constraints.maxWidth;
                    int columns = 3;
                    if (width < 700)
                      columns = 1;
                    else if (width < 1100)
                      columns = 2;

                    const spacing = 24.0;
                    final itemWidth =
                        (width - (columns - 1) * spacing) / columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: reviews.map((rev) {
                        return Container(
                          width: itemWidth,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(
                                  rev.rating,
                                  (index) => const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFFB700),
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                '"${rev.text}"',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF4B5563),
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(
                                      0xFF2FC1BE,
                                    ).withOpacity(0.1),
                                    child: Text(
                                      rev.name[0],
                                      style: const TextStyle(
                                        color: Color(0xFF2FC1BE),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rev.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        rev.role,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 10. FREQUENTLY ASKED QUESTIONS SECTION (White Background)
  Widget _buildFaqSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: _buildFaqContent(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqContent(ThemeData theme) {
    final faqs = [
      (
        q: 'How do I book on IDS EUROPE?',
        a: 'Search by destination, choose your dates, compare listings, and confirm your stay in a few steps.',
      ),
      (
        q: 'Can I cancel or modify my reservation?',
        a: 'Yes. Most stays include flexible policies. Cancellation and modification options are shown before checkout.',
      ),
      (
        q: 'Are taxes and fees included in the shown price?',
        a: 'Base nightly prices are shown first. Full price breakdown, including applicable fees and taxes, appears before payment.',
      ),
      (
        q: 'Is support available during my trip?',
        a: 'Yes. Our support team is available 24/7 for booking issues, stay changes, and urgent assistance.',
      ),
      (
        q: 'Can I list my own property on IDS EUROPE?',
        a: 'Yes. Use "List your property" to submit details and start receiving bookings.',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDark = theme.brightness == Brightness.dark;
        final intro = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2FC1BE).withOpacity(0.08),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _controller.tr('Support'),
                style: const TextStyle(
                  color: Color(0xFF2FC1BE),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _controller.tr('Frequently Asked\nQuestions'),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                height: 1.1,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _controller.tr(
                'Everything you need to know before booking, paying, and managing your stay. Feel free to contact our support team if you have other questions.',
              ),
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF475569),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        );

        final accordion = Column(
          children: faqs.map((faq) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  iconColor: const Color(0xFF2FC1BE),
                  collapsedIconColor: isDark
                      ? Colors.white
                      : const Color(0xFF0F172A),
                  title: Text(
                    _controller.tr(faq.q),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  children: [
                    Text(
                      _controller.tr(faq.a),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF475569),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );

        final isWide = constraints.maxWidth > 900;

        if (!isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [intro, const SizedBox(height: 32), accordion],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: intro),
            const SizedBox(width: 48),
            Expanded(flex: 6, child: accordion),
          ],
        );
      },
    );
  }

  // 11. FOOTER SECTION (Dark Slate Background)
  Widget _buildFooterSection() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: _buildFooterContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterContent() {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;

            final brandCol = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'IDS EUROPE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 320,
                  child: Text(
                    _controller.tr(
                      'Find trusted hotels and properties across top destinations with secure booking and dedicated support.',
                    ),
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.mail_outline_rounded,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            filled: false,
                            fillColor: Colors.transparent,
                            hintText: _controller.tr('Enter your email'),
                            hintStyle: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2FC1BE),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          _controller.tr('Join'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final linksArea = Wrap(
              spacing: 48,
              runSpacing: 24,
              children: [
                _footerColumn('Company', [
                  'About',
                  'Careers',
                  'Press',
                  'Partners',
                ]),
                _footerColumn('Explore', [
                  'Hotels',
                  'Properties',
                  'Destinations',
                  'Deals',
                ]),
                _footerColumn('Support', [
                  'Help Center',
                  'Contact Us',
                  'Cancellation',
                  'Safety',
                ]),
                _footerColumn('Resources', [
                  'Travel Guides',
                  'Blog',
                  'FAQs',
                  'Trust & Safety',
                ]),
              ],
            );

            if (!isWide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [brandCol, const SizedBox(height: 40), linksArea],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: brandCol),
                const SizedBox(width: 40),
                Expanded(flex: 7, child: linksArea),
              ],
            );
          },
        ),
        const SizedBox(height: 48),
        const Divider(height: 1, color: Colors.white12),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final copyright = Text(
              _controller.tr('© 2026 IDS EUROPE. All rights reserved.'),
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            );

            final links = Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _FooterLink(
                  text: _controller.tr('Privacy Policy'),
                  onTap: () {},
                ),
                _FooterLink(
                  text: _controller.tr('Terms of Service'),
                  onTap: () {},
                ),
                _FooterLink(text: _controller.tr('Cookies'), onTap: () {}),
              ],
            );

            if (!isWide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [links, const SizedBox(height: 12), copyright],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [copyright, links],
            );
          },
        ),
      ],
    );
  }

  Widget _footerTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _footerText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
    );
  }

  Widget _footerColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerTitle(_controller.tr(title)),
        const SizedBox(height: 16),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FooterLink(text: _controller.tr(item), onTap: () {}),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HERO SECTION (Teal Gradient Background)
              _buildHeroSection(primaryColor),

              // 2. SEARCH BAR (Overlapping bottom of Hero)
              Transform.translate(
                offset: const Offset(0, -32),
                child: _buildSearchBar(),
              ),

              // 4. WHY IDS EUROPE (Alternating Light Grey Background)
              _buildWhySection(),

              // AI & AR FEATURES SECTION (Stunning Dark Modern Showcase)
              _buildAiArFeaturesSection(theme),

              // 6. POPULAR HOTELS/PROPERTIES (Tabbed)
              _buildPopularListingsSection(theme),

              // 7. CTA BANNER FOR HOSTS (NEW!)
              _buildCtaBanner(),

              // 10. FAQs SECTION (White Background)
              _buildFaqSection(theme),

              // 11. FOOTER SECTION (Dark slate Background)
              _buildFooterSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: const _FloatingAiButton(),
    );
  }
}

// ==================== PREMIUM HELPER WIDGETS ====================

class _WhyCard extends StatefulWidget {
  final Map<String, String> cardData;
  final Widget icon;

  const _WhyCard({required this.cardData, required this.icon});

  @override
  State<_WhyCard> createState() => _WhyCardState();
}

class _WhyCardState extends State<_WhyCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF2FC1BE).withOpacity(0.5)
                : (isDark ? Colors.white10 : const Color(0xFFE5E7EB)),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0xFF2FC1BE).withOpacity(0.12)
                  : Colors.black.withOpacity(isDark ? 0.3 : 0.03),
              blurRadius: _isHovered ? 24 : 12,
              offset: Offset(0, _isHovered ? 12 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2FC1BE).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.icon,
            ),
            Text(
              widget.cardData['title']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.cardData['subtitle']!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isProperty;
  final String title;
  final String address;
  final String price;
  final String rating;
  final String imageUrl;
  final VoidCallback onTap;

  const _ListingCard({
    required this.item,
    required this.isProperty,
    required this.title,
    required this.address,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<_ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<_ListingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -8.0 : 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: isDark
                          ? const Color(0xFF2C2C2E)
                          : const Color(0xFFF1F5F9),
                      height: 220,
                      width: double.infinity,
                      child: AnimatedScale(
                        scale: _isHovered ? 1.06 : 1.0,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        child: widget.imageUrl.isNotEmpty
                            ? Image.network(
                                widget.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C1C1E).withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: Color(0xFFFFB700),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            widget.rating,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.isProperty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              widget.item['listingType']?.toString() ==
                                  'FOR_SALE'
                              ? const Color(0xFF2FC1BE)
                              : const Color(0xFF2FC1BE).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.item['listingType']?.toString() == 'FOR_SALE'
                              ? 'For Sale'
                              : 'For Rent',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.address,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.price.isNotEmpty
                          ? widget.price
                          : 'Price on request',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: Color(0xFF2FC1BE),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({required this.text, required this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.text,
          style: TextStyle(
            color: _isHovered
                ? const Color(0xFF2FC1BE)
                : const Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration: _isHovered
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _NavTextButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavTextButton(this.label, this.onTap);

  @override
  State<_NavTextButton> createState() => _NavTextButtonState();
}

class _NavTextButtonState extends State<_NavTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: _isHovered ? const Color(0xFF2FC1BE) : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

class _DestinationCard extends StatefulWidget {
  final ({String name, String properties, String imageUrl}) dest;

  const _DestinationCard({required this.dest});

  @override
  State<_DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<_DestinationCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedScale(
                  scale: _isHovered ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  child: Image.network(
                    widget.dest.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(color: const Color(0xFFF1F5F9));
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(
                        Icons.image,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dest.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.dest.properties,
                      style: const TextStyle(
                        color: Color(0xFF2FC1BE),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularProgressPadding extends StatelessWidget {
  const CircularProgressPadding({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: CircularProgressIndicator(),
    );
  }
}

// ==================== NEXT-GEN AI & AR WIDGETS ====================

class _AiFeatureCard extends StatefulWidget {
  final VoidCallback onTapChat;
  const _AiFeatureCard({required this.onTapChat});

  @override
  State<_AiFeatureCard> createState() => _AiFeatureCardState();
}

class _AiFeatureCardState extends State<_AiFeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WebLandingController>();
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Premium dark card background
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF2FC1BE).withOpacity(0.6)
                : Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0xFF2FC1BE).withOpacity(0.15)
                  : Colors.black.withOpacity(0.3),
              blurRadius: _isHovered ? 24 : 16,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x208B5CF6), // Subtle purple accent
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFA78BFA),
                        size: 12,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        controller.tr('AI TRAVEL AGENT'),
                        style: const TextStyle(
                          color: Color(0xFFA78BFA),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.white.withOpacity(0.3),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              controller.tr('Smart AI Travel Planner'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            // Description
            Text(
              controller.tr(
                'Plan your trip conversationally. Ask about hotel rates, forecast prices, and get personal recommendations instantly.',
              ),
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Visual Mockup: AI Chat simulator
            Container(
              height: 220,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User message
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2FC1BE),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        controller.tr(
                          'Find a quiet pool hotel in Paris under €200.',
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // AI response message with mini card
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.tr(
                                'I found Hotel de Paris (€165/night, 9.2 ★). Rate predicted to rise next week! 📈',
                              ),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Mini hotel card
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.asset(
                                      'assets/room1.png',
                                      width: 44,
                                      height: 36,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 44,
                                        height: 36,
                                        color: const Color(
                                          0xFF2FC1BE,
                                        ).withOpacity(0.2),
                                        child: const Icon(
                                          Icons.hotel,
                                          color: Color(0xFF2FC1BE),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hotel de Paris',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              color: Color(0xFFFFB700),
                                              size: 10,
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              '9.2 (142 reviews)',
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 8,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Text(
                                    '€165',
                                    style: TextStyle(
                                      color: Color(0xFF2FC1BE),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
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
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Bullets
            _FeatureBullet(
              text: controller.tr('Voice search & real-time transcription'),
            ),
            const SizedBox(height: 12),
            _FeatureBullet(
              text: controller.tr('Historical price forecasting engine'),
            ),
            const SizedBox(height: 12),
            _FeatureBullet(
              text: controller.tr('Personalized stays tailored to you'),
            ),
            const SizedBox(height: 32),
            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: widget.onTapChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isHovered
                      ? const Color(0xFF2FC1BE)
                      : Colors.transparent,
                  foregroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.black.withOpacity(0.2),
                  side: BorderSide(
                    color: _isHovered
                        ? const Color(0xFF2FC1BE)
                        : Colors.white24,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _isHovered ? 4 : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.tr('Chat with AI Assistant'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _isHovered
                            ? Colors.white
                            : Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: _isHovered
                          ? Colors.white
                          : Colors.white.withOpacity(0.9),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArFeatureCard extends StatefulWidget {
  final VoidCallback onTapAr;
  const _ArFeatureCard({required this.onTapAr});

  @override
  State<_ArFeatureCard> createState() => _ArFeatureCardState();
}

class _ArFeatureCardState extends State<_ArFeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WebLandingController>();
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF2FC1BE).withOpacity(0.6)
                : Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0xFF2FC1BE).withOpacity(0.15)
                  : Colors.black.withOpacity(0.3),
              blurRadius: _isHovered ? 24 : 16,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x200EA5E9), // Subtle cyan/blue accent
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF0EA5E9).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.view_in_ar_rounded,
                        color: Color(0xFF38BDF8),
                        size: 12,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        controller.tr('AR IMMERSIVE TOUR'),
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.threed_rotation_rounded,
                  color: Colors.white.withOpacity(0.3),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              controller.tr('Interactive 3D & AR Tours'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            // Description
            Text(
              controller.tr(
                'Step inside your accommodation before booking. Explore room layouts, check exact dimensions, and interact with hotspots.',
              ),
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Visual Mockup: AR room with hotspots
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Background room image
                    Positioned.fill(
                      child: Image.asset(
                        'assets/room1.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF0F172A),
                          child: const Icon(
                            Icons.roofing_rounded,
                            color: Colors.white24,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                    // Dark overlay for contrast
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.2)),
                    ),
                    // AR Badge indicator
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF2FC1BE),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981), // Pulsing green dot
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              controller.tr('AR Active'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Pulsing hotspot 1
                    Positioned(
                      left: 45,
                      top: 75,
                      child: _PulsingHotspot(
                        label: controller.tr('King Bed (3.2m x 2.4m)'),
                      ),
                    ),
                    // Pulsing hotspot 2
                    Positioned(
                      right: 55,
                      bottom: 50,
                      child: _PulsingHotspot(
                        label: controller.tr('Paris Balcony View'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Bullets
            _FeatureBullet(
              text: controller.tr('Interactive hotspots with dimensions'),
            ),
            const SizedBox(height: 12),
            _FeatureBullet(
              text: controller.tr('Full 360-degree immersive tours'),
            ),
            const SizedBox(height: 12),
            _FeatureBullet(
              text: controller.tr('True-to-scale room visualization'),
            ),
            const SizedBox(height: 32),
            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: widget.onTapAr,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isHovered
                      ? const Color(0xFF2FC1BE)
                      : Colors.transparent,
                  foregroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.black.withOpacity(0.2),
                  side: BorderSide(
                    color: _isHovered
                        ? const Color(0xFF2FC1BE)
                        : Colors.white24,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _isHovered ? 4 : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.tr('Launch AR Room Tour'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _isHovered
                            ? Colors.white
                            : Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.threed_rotation_rounded,
                      size: 16,
                      color: _isHovered
                          ? Colors.white
                          : Colors.white.withOpacity(0.9),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingHotspot extends StatefulWidget {
  final String label;
  const _PulsingHotspot({required this.label});

  @override
  State<_PulsingHotspot> createState() => _PulsingHotspotState();
}

class _PulsingHotspotState extends State<_PulsingHotspot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Ripple Ring
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 32 * (0.4 + _controller.value),
              height: 32 * (0.4 + _controller.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFF2FC1BE,
                ).withOpacity(1.0 - _controller.value),
              ),
            );
          },
        ),
        // Center Dot
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF2FC1BE),
            boxShadow: [BoxShadow(color: Color(0xFF2FC1BE), blurRadius: 6)],
          ),
        ),
        // Floating Label Tag next to it
        Positioned(
          left: 14,
          top: -10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF2FC1BE).withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final String text;
  const _FeatureBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Color(0x202FC1BE),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF2FC1BE),
            size: 14,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FloatingAiButton extends StatefulWidget {
  const _FloatingAiButton();

  @override
  State<_FloatingAiButton> createState() => _FloatingAiButtonState();
}

class _FloatingAiButtonState extends State<_FloatingAiButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF1CB5B3), Color(0xFF2ECCE8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF1CB5B3,
              ).withValues(alpha: _isHovered ? 0.55 : 0.35),
              blurRadius: _isHovered ? 18 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => Get.to(() => const DedicatedAiChatScreen()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/Ai.svg',
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Assistant'.tr,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.3,
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
}
