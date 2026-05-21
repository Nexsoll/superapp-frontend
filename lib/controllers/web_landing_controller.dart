import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superapp/services/api_service.dart';
import 'package:superapp/services/currency_service.dart';
import 'package:superapp/services/listing_service.dart';

class WebLandingController extends GetxController {
  final ListingService _listingService = ListingService();

  final allHotels = <Map<String, dynamic>>[].obs;
  final allProperties = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final detectedCountry = ''.obs;
  final detectedCountryCode = ''.obs;
  final detectedCurrency = 'USD'.obs;
  final detectedCurrencySymbol = 'USD'.obs;
  final detectedCurrencyRate = 1.0.obs;
  final detectedLanguageCode = 'en'.obs;
  final detectedLanguageName = 'English'.obs;
  final selectedLanguageCode = 'en'.obs;
  final translatedLabels = <String, String>{}.obs;
  final isTranslating = false.obs;
  final isResolvingCountry = false.obs;
  final hasResolvedCountry = false.obs;

  // Search form state
  final searchQuery = ''.obs;
  final selectedCategory = 'Stays'.obs; // Stays or Properties
  final selectedLocation = ''.obs;

  static const List<String> _translatableLabels = [
    'Verified Stays & Low Prices',
    'Find your next ',
    'perfect stay',
    'Search low prices on hotels, holiday homes, and premium real estate.',
    'List your property',
    'Register',
    'Sign in',
    'Where are you going?',
    'Check-in — Check-out',
    'Guests & Rooms',
    'Adults',
    'Children',
    'Rooms',
    'Done',
    'Voice search is not available on this browser.',
    'Search',
    'Why IDS EUROPE?',
    'We offer the best accommodation services and properties in top European cities.',
    'Book now, pay later',
    'Flexible bookings on selected stays',
    'Trusted by travelers',
    'Verified reviews and reliable listings',
    'Hotels & properties',
    'Discover stays in key destinations',
    '24/7 support',
    'We are here whenever you need help',
    'NEXT-GENERATION TRAVEL',
    'Experience Stays Like Never Before',
    'Explore room layouts with immersive Augmented Reality tours, and plan your trips conversationally using our advanced AI Travel Assistant.',
    'AI TRAVEL AGENT',
    'Smart AI Travel Planner',
    'Plan your trip conversationally. Ask about hotel rates, forecast prices, and get personal recommendations instantly.',
    'Find a quiet pool hotel in Paris under €200.',
    'I found Hotel de Paris (€165/night, 9.2 ★). Rate predicted to rise next week! 📈',
    'Voice search & real-time transcription',
    'Historical price forecasting engine',
    'Personalized stays tailored to you',
    'Chat with AI Assistant',
    'AR IMMERSIVE TOUR',
    'Interactive 3D & AR Tours',
    'Step inside your accommodation before booking. Explore room layouts, check exact dimensions, and interact with hotspots.',
    'AR Active',
    'King Bed (3.2m x 2.4m)',
    'Paris Balcony View',
    'Interactive hotspots with dimensions',
    'Full 360-degree immersive tours',
    'True-to-scale room visualization',
    'Launch AR Room Tour',
    'Popular Stays',
    'Popular Hotels',
    'Handpicked top-rated hotels recommended by our guests',
    'Hotels',
    'View All',
    'Popular Properties',
    'Discover premium villas, apartments, and houses for rent or sale',
    'Properties',
    'No hotels found for this location.',
    'No properties found for this location.',
    'No hotels found in',
    'No properties found in',
    'List your property on IDS EUROPE',
    'Reach thousands of travelers and property seekers in minutes. Simple setups, low fees, 24/7 help.',
    'Get Started Today',
    'Support',
    'Frequently Asked\nQuestions',
    'Everything you need to know before booking, paying, and managing your stay. Feel free to contact our support team if you have other questions.',
    'How do I book on IDS EUROPE?',
    'Search by destination, choose your dates, compare listings, and confirm your stay in a few steps.',
    'Can I cancel or modify my reservation?',
    'Yes. Most stays include flexible policies. Cancellation and modification options are shown before checkout.',
    'Are taxes and fees included in the shown price?',
    'Base nightly prices are shown first. Full price breakdown, including applicable fees and taxes, appears before payment.',
    'Is support available during my trip?',
    'Yes. Our support team is available 24/7 for booking issues, stay changes, and urgent assistance.',
    'Can I list my own property on IDS EUROPE?',
    'Yes. Use "List your property" to submit details and start receiving bookings.',
    'Find trusted hotels and properties across top destinations with secure booking and dedicated support.',
    'Enter your email',
    'Join',
    'Company',
    'About',
    'Careers',
    'Press',
    'Partners',
    'Explore',
    'Destinations',
    'Deals',
    'Help Center',
    'Contact Us',
    'Cancellation',
    'Safety',
    'Resources',
    'Travel Guides',
    'Blog',
    'FAQs',
    'Trust & Safety',
    '© 2026 IDS EUROPE. All rights reserved.',
    'Privacy Policy',
    'Terms of Service',
    'Cookies',
    '/night',
    '/ mo',
    'Currency',
    'Language',
    'English',
  ];

  static const Map<String, String> _googleLanguages = {
    'en': 'English',
    'af': 'Afrikaans',
    'sq': 'Albanian',
    'am': 'Amharic',
    'ar': 'Arabic',
    'hy': 'Armenian',
    'az': 'Azerbaijani',
    'eu': 'Basque',
    'be': 'Belarusian',
    'bn': 'Bengali',
    'bs': 'Bosnian',
    'bg': 'Bulgarian',
    'ca': 'Catalan',
    'ceb': 'Cebuano',
    'zh': 'Chinese',
    'hr': 'Croatian',
    'cs': 'Czech',
    'da': 'Danish',
    'nl': 'Dutch',
    'eo': 'Esperanto',
    'et': 'Estonian',
    'fi': 'Finnish',
    'fr': 'French',
    'gl': 'Galician',
    'ka': 'Georgian',
    'de': 'German',
    'el': 'Greek',
    'gu': 'Gujarati',
    'ht': 'Haitian Creole',
    'ha': 'Hausa',
    'haw': 'Hawaiian',
    'he': 'Hebrew',
    'hi': 'Hindi',
    'hmn': 'Hmong',
    'hu': 'Hungarian',
    'is': 'Icelandic',
    'ig': 'Igbo',
    'id': 'Indonesian',
    'ga': 'Irish',
    'it': 'Italian',
    'ja': 'Japanese',
    'jv': 'Javanese',
    'kn': 'Kannada',
    'kk': 'Kazakh',
    'km': 'Khmer',
    'rw': 'Kinyarwanda',
    'ko': 'Korean',
    'ku': 'Kurdish',
    'ky': 'Kyrgyz',
    'lo': 'Lao',
    'la': 'Latin',
    'lv': 'Latvian',
    'lt': 'Lithuanian',
    'lb': 'Luxembourgish',
    'mk': 'Macedonian',
    'mg': 'Malagasy',
    'ms': 'Malay',
    'ml': 'Malayalam',
    'mt': 'Maltese',
    'mi': 'Maori',
    'mr': 'Marathi',
    'mn': 'Mongolian',
    'my': 'Myanmar',
    'ne': 'Nepali',
    'no': 'Norwegian',
    'ny': 'Nyanja',
    'or': 'Odia',
    'ps': 'Pashto',
    'fa': 'Persian',
    'pl': 'Polish',
    'pt': 'Portuguese',
    'pa': 'Punjabi',
    'ro': 'Romanian',
    'ru': 'Russian',
    'sm': 'Samoan',
    'gd': 'Scots Gaelic',
    'sr': 'Serbian',
    'st': 'Sesotho',
    'sn': 'Shona',
    'sd': 'Sindhi',
    'si': 'Sinhala',
    'sk': 'Slovak',
    'sl': 'Slovenian',
    'so': 'Somali',
    'es': 'Spanish',
    'su': 'Sundanese',
    'sw': 'Swahili',
    'sv': 'Swedish',
    'tl': 'Tagalog',
    'tg': 'Tajik',
    'ta': 'Tamil',
    'tt': 'Tatar',
    'te': 'Telugu',
    'th': 'Thai',
    'tr': 'Turkish',
    'tk': 'Turkmen',
    'uk': 'Ukrainian',
    'ur': 'Urdu',
    'ug': 'Uyghur',
    'uz': 'Uzbek',
    'vi': 'Vietnamese',
    'cy': 'Welsh',
    'xh': 'Xhosa',
    'yi': 'Yiddish',
    'yo': 'Yoruba',
    'zu': 'Zulu',
  };

  static const Map<String, String> _iso639ThreeToGoogle = {
    'afr': 'af',
    'amh': 'am',
    'ara': 'ar',
    'aze': 'az',
    'bel': 'be',
    'ben': 'bn',
    'bos': 'bs',
    'bul': 'bg',
    'cat': 'ca',
    'ces': 'cs',
    'dan': 'da',
    'deu': 'de',
    'ell': 'el',
    'eng': 'en',
    'est': 'et',
    'fas': 'fa',
    'fin': 'fi',
    'fra': 'fr',
    'gle': 'ga',
    'heb': 'he',
    'hin': 'hi',
    'hrv': 'hr',
    'hun': 'hu',
    'hye': 'hy',
    'ind': 'id',
    'isl': 'is',
    'ita': 'it',
    'jpn': 'ja',
    'kat': 'ka',
    'kaz': 'kk',
    'khm': 'km',
    'kor': 'ko',
    'lao': 'lo',
    'lav': 'lv',
    'lit': 'lt',
    'mkd': 'mk',
    'mlt': 'mt',
    'msa': 'ms',
    'mya': 'my',
    'nep': 'ne',
    'nld': 'nl',
    'nor': 'no',
    'pol': 'pl',
    'por': 'pt',
    'pus': 'ps',
    'ron': 'ro',
    'rus': 'ru',
    'sin': 'si',
    'slk': 'sk',
    'slv': 'sl',
    'som': 'so',
    'spa': 'es',
    'sqi': 'sq',
    'srp': 'sr',
    'swa': 'sw',
    'swe': 'sv',
    'tam': 'ta',
    'tgk': 'tg',
    'tha': 'th',
    'tur': 'tr',
    'ukr': 'uk',
    'urd': 'ur',
    'uzb': 'uz',
    'vie': 'vi',
    'zho': 'zh',
    'zul': 'zu',
  };

  @override
  void onInit() {
    super.onInit();
    _fetchData();
    _detectUserCountry();
  }

  Future<void> _fetchData() async {
    isLoading.value = true;
    try {
      final hotels = await _listingService.getAllHotels();
      allHotels.value = hotels.cast<Map<String, dynamic>>();

      final properties = await _listingService.getAllProperties();
      allProperties.value = properties.cast<Map<String, dynamic>>();
    } catch (e) {
      // Error fetching landing data
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _detectUserCountry() async {
    if (isResolvingCountry.value || hasResolvedCountry.value) return;

    isResolvingCountry.value = true;
    try {
      final localeData = await _locationDataFromProviders();
      final savedCountry = await _countryFromSavedLocation();

      final countryName = (localeData['countryName'] ?? '').trim();
      if (countryName.isNotEmpty) {
        detectedCountry.value = countryName;
      } else if (savedCountry.isNotEmpty) {
        detectedCountry.value = savedCountry;
      }

      final countryCode = (localeData['countryCode'] ?? '')
          .trim()
          .toUpperCase();
      if (countryCode.isNotEmpty) {
        detectedCountryCode.value = countryCode;
      }

      final currencyCode = (localeData['currencyCode'] ?? '')
          .trim()
          .toUpperCase();
      if (currencyCode.isNotEmpty &&
          CurrencyService.isSupportedCurrency(currencyCode)) {
        detectedCurrency.value = currencyCode;
      }

      final currencySymbol = (localeData['currencySymbol'] ?? '').trim();
      if (currencySymbol.isNotEmpty) {
        detectedCurrencySymbol.value = currencySymbol;
        CurrencyService.setSymbol(detectedCurrency.value, currencySymbol);
      }

      await _loadDetectedCurrencyRate();

      final languageCode = _normalizeLanguageCode(localeData['languageCode'] ?? '');
      final languageName = (localeData['languageName'] ?? '').trim();

      detectedLanguageCode.value = languageCode;
      detectedLanguageName.value = languageName.isNotEmpty
          ? languageName
          : _languageNameForCode(languageCode);

      if (selectedLanguageCode.value == 'en' && languageCode != 'en') {
        await setSelectedLanguage(languageCode);
      }
    } catch (_) {
      // Locale detection is handled by backend providers; leave current values if unavailable.
    } finally {
      isResolvingCountry.value = false;
      hasResolvedCountry.value = true;
    }
  }

  Future<String> _countryFromSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = (prefs.getString('user_location') ?? '').trim();
    if (raw.isEmpty) return '';
    return _extractCountryFromText(raw);
  }

  Future<Map<String, String>> _locationDataFromBackend() async {
    final response = await http
        .get(Uri.parse('${ApiService.baseUrl}/localization/visitor-locale'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return {};

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) return {};

    return {
      'countryName': (data['countryName'] ?? '').toString().trim(),
      'countryCode': (data['countryCode'] ?? '').toString().trim(),
      'currencyCode': (data['currencyCode'] ?? '').toString().trim(),
      'currencySymbol': (data['currencySymbol'] ?? '').toString().trim(),
      'languageCode': (data['languageCode'] ?? '').toString().trim(),
      'languageName': (data['languageName'] ?? '').toString().trim(),
    };
  }

  Future<Map<String, String>> _locationDataFromProviders() async {
    final backendData = await _locationDataFromBackend();
    if ((backendData['countryCode'] ?? '').isNotEmpty) {
      return _withCountryMetadata(backendData);
    }

    final providers = [
      _locationDataFromIpWho,
      _locationDataFromIpApiCo,
      _locationDataFromIpInfo,
    ];

    for (final provider in providers) {
      try {
        final data = await provider();
        if ((data['countryCode'] ?? '').isNotEmpty) {
          return _withCountryMetadata(data);
        }
      } catch (_) {}
    }

    return {};
  }

  Future<Map<String, String>> _locationDataFromIpWho() async {
    final response = await http
        .get(Uri.parse('https://ipwho.is/'))
        .timeout(const Duration(seconds: 6));
    if (response.statusCode != 200) return {};

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic> || data['success'] == false) return {};

    final languages = data['languages'];
    String languageCode = '';
    if (languages is List && languages.isNotEmpty && languages.first is Map) {
      languageCode = (languages.first['code'] ?? '').toString();
    }

    return {
      'countryName': (data['country'] ?? '').toString().trim(),
      'countryCode': (data['country_code'] ?? '').toString().trim(),
      'currencyCode': (data['currency']?['code'] ?? '').toString().trim(),
      'currencySymbol': (data['currency']?['symbol'] ?? '').toString().trim(),
      'languageCode': languageCode,
      'languageName': '',
    };
  }

  Future<Map<String, String>> _locationDataFromIpApiCo() async {
    final response = await http
        .get(Uri.parse('https://ipapi.co/json/'))
        .timeout(const Duration(seconds: 6));
    if (response.statusCode != 200) return {};

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic> || data['error'] == true) return {};

    return {
      'countryName': (data['country_name'] ?? '').toString().trim(),
      'countryCode': (data['country_code'] ?? '').toString().trim(),
      'currencyCode': (data['currency'] ?? '').toString().trim(),
      'currencySymbol': '',
      'languageCode': _firstLanguage(data['languages']?.toString() ?? ''),
      'languageName': '',
    };
  }

  Future<Map<String, String>> _locationDataFromIpInfo() async {
    final response = await http
        .get(Uri.parse('https://ipinfo.io/json'))
        .timeout(const Duration(seconds: 6));
    if (response.statusCode != 200) return {};

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) return {};

    return {
      'countryName': '',
      'countryCode': (data['country'] ?? '').toString().trim(),
      'currencyCode': '',
      'currencySymbol': '',
      'languageCode': '',
      'languageName': '',
    };
  }

  Future<Map<String, String>> _withCountryMetadata(
    Map<String, String> input,
  ) async {
    final countryCode = (input['countryCode'] ?? '').trim().toUpperCase();
    if (countryCode.isEmpty) return input;

    try {
      final response = await http
          .get(
            Uri.parse(
              'https://restcountries.com/v3.1/alpha/$countryCode?fields=name,cca2,currencies,languages',
            ),
          )
          .timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return input;

      final decoded = jsonDecode(response.body);
      final country = decoded is List && decoded.isNotEmpty
          ? decoded.first
          : decoded;
      if (country is! Map<String, dynamic>) return input;

      final currencies = country['currencies'];
      final languages = country['languages'];
      final inputCurrencyCode = input['currencyCode'] ?? '';
      final inputCurrencySymbol = input['currencySymbol'] ?? '';
      final inputLanguageCode = input['languageCode'] ?? '';
      final inputLanguageName = input['languageName'] ?? '';
      final inputCountryName = input['countryName'] ?? '';

      final currencyCode = inputCurrencyCode.isNotEmpty
          ? inputCurrencyCode
          : currencies is Map && currencies.keys.isNotEmpty
          ? currencies.keys.first.toString()
          : '';
      final currency = currencies is Map && currencyCode.isNotEmpty
          ? currencies[currencyCode.toUpperCase()]
          : null;
      final languageKey = languages is Map && languages.keys.isNotEmpty
          ? languages.keys.first.toString()
          : '';
      final countryLanguageCode = _normalizeLanguageCode(
        inputLanguageCode.isNotEmpty
            ? inputLanguageCode
            : (_iso639ThreeToGoogle[languageKey] ?? languageKey),
      );
      final countryLanguageName = inputLanguageName.isNotEmpty
          ? inputLanguageName
          : (languages is Map && languageKey.isNotEmpty
                ? languages[languageKey]?.toString() ?? ''
                : _languageNameForCode(countryLanguageCode));

      return {
        'countryName': inputCountryName.isNotEmpty
            ? inputCountryName
            : (country['name']?['common'] ?? '').toString(),
        'countryCode': countryCode,
        'currencyCode': currencyCode.toUpperCase(),
        'currencySymbol': inputCurrencySymbol.isNotEmpty
            ? inputCurrencySymbol
            : (currency is Map ? currency['symbol']?.toString() ?? '' : ''),
        'languageCode': countryLanguageCode,
        'languageName': countryLanguageName,
      };
    } catch (_) {
      return input;
    }
  }

  String _firstLanguage(String raw) {
    final parts = raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.isEmpty ? '' : _normalizeLanguageCode(parts.first);
  }

  Future<void> _loadDetectedCurrencyRate() async {
    await CurrencyService.ensureLiveRates();
    detectedCurrencyRate.value = CurrencyService.rateFromUSD(
      detectedCurrency.value,
    );
  }

  String _extractCountryFromText(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return '';

    final parts = raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final candidate = parts.isNotEmpty ? parts.last : raw;
    if (candidate.length < 2 || RegExp(r'\d').hasMatch(candidate)) {
      return '';
    }
    return candidate;
  }

  String _normalizeLanguageCode(String rawCode) {
    final normalized = rawCode.trim().toLowerCase();
    if (normalized.isEmpty) return 'en';

    final primary = normalized.split('-').first;
    if (primary.isEmpty) return 'en';

    if (primary.length == 3 && _iso639ThreeToGoogle.containsKey(primary)) {
      return _iso639ThreeToGoogle[primary]!;
    }

    if (!RegExp(r'^[a-z]{2,3}$').hasMatch(primary)) {
      return 'en';
    }

    return primary;
  }

  String _languageNameForCode(String code) {
    switch (code.toLowerCase()) {
      case 'it':
        return 'Italiano';
      case 'fr':
        return 'Francais';
      case 'de':
        return 'Deutsch';
      case 'es':
        return 'Espanol';
      case 'tr':
        return 'Turkce';
      case 'ar':
        return 'Arabic';
      case 'ur':
        return 'Urdu';
      case 'pt':
        return 'Portugues';
      case 'nl':
        return 'Nederlands';
      case 'sv':
        return 'Svenska';
      case 'pl':
        return 'Polski';
      case 'ro':
        return 'Romana';
      case 'cs':
        return 'Cestina';
      case 'hu':
        return 'Magyar';
      default:
        return 'English';
    }
  }

  List<String> get languageOptions {
    final detected = _normalizeLanguageCode(detectedLanguageCode.value);
    final options = <String>['en'];
    if (detected != 'en' && _googleLanguages.containsKey(detected)) {
      options.add(detected);
    }
    return options;
  }

  String get currentLanguageCode => selectedLanguageCode.value;

  String get currentLanguageLabel {
    return languageLabelForCode(selectedLanguageCode.value);
  }

  String languageLabelForCode(String code) {
    final normalized = _normalizeLanguageCode(code);
    if (normalized == 'en') {
      return tr('English');
    }
    if (normalized == detectedLanguageCode.value) {
      return detectedLanguageName.value;
    }
    return _googleLanguages[normalized] ?? _languageNameForCode(normalized);
  }

  String get displayCurrency {
    final currency = detectedCurrency.value.toUpperCase();
    if (CurrencyService.isSupportedCurrency(currency)) {
      return currency;
    }
    return 'USD';
  }

  Future<void> setSelectedLanguage(String languageCode) async {
    final normalized = _normalizeLanguageCode(languageCode);
    selectedLanguageCode.value = normalized;

    if (normalized == 'en') {
      translatedLabels.clear();
      return;
    }

    await _loadTranslations(normalized);
  }

  Future<void> _loadTranslations(String targetLanguage) async {
    if (targetLanguage == 'en') {
      translatedLabels.clear();
      return;
    }

    isTranslating.value = true;
    try {
      final loadedFromBackend = await _loadTranslationsFromBackend(
        targetLanguage,
      );
      if (!loadedFromBackend) {
        await _loadTranslationsFromGooglePublic(targetLanguage);
      }
    } catch (_) {
      await _loadTranslationsFromGooglePublic(targetLanguage);
    } finally {
      isTranslating.value = false;
    }
  }

  Future<bool> _loadTranslationsFromBackend(String targetLanguage) async {
    final uri = Uri.parse('${ApiService.baseUrl}/localization/translate');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'texts': _translatableLabels,
            'sourceLanguage': 'en',
            'targetLanguage': targetLanguage,
          }),
        )
        .timeout(const Duration(seconds: 14));

    if (response.statusCode != 200 && response.statusCode != 201) {
      return false;
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return false;

    final translationsRaw = decoded['translations'];
    if (translationsRaw is! List || translationsRaw.isEmpty) return false;

    final translations = translationsRaw.map((item) => item?.toString() ?? '').toList();
    if (!_hasMeaningfulTranslations(translations)) {
      return false;
    }

    _setTranslationsFromList(translations);
    return true;
  }

  void _setTranslationsFromList(List<dynamic> translationsRaw) {
    final nextMap = <String, String>{};
    for (int i = 0; i < _translatableLabels.length; i++) {
      final key = _translatableLabels[i];
      final value = i < translationsRaw.length
          ? translationsRaw[i]?.toString() ?? key
          : key;
      nextMap[key] = value;
    }
    translatedLabels.value = nextMap;
  }

  Future<void> _loadTranslationsFromGooglePublic(String targetLanguage) async {
    final translatedRaw = List<String>.filled(_translatableLabels.length, '');
    const batchSize = 8;

    for (int start = 0; start < _translatableLabels.length; start += batchSize) {
      final end = (start + batchSize) > _translatableLabels.length
          ? _translatableLabels.length
          : (start + batchSize);
      final futures = <Future<void>>[];

      for (int i = start; i < end; i++) {
        final index = i;
        final sourceText = _translatableLabels[index];
        futures.add(
          _translateOneWithGooglePublic(sourceText, targetLanguage)
              .then((value) {
                translatedRaw[index] = value;
              })
              .catchError((_) {
                translatedRaw[index] = '';
              }),
        );
      }

      await Future.wait(futures);
    }

    final translations = List<String>.generate(
      _translatableLabels.length,
      (index) {
        final translated = translatedRaw[index].trim();
        return translated.isEmpty ? _translatableLabels[index] : translated;
      },
    );

    if (_hasMeaningfulTranslations(translations)) {
      _setTranslationsFromList(translations);
    }
  }

  bool _hasMeaningfulTranslations(List<String> translations) {
    if (translations.length != _translatableLabels.length) return false;

    var changedCount = 0;
    for (int i = 0; i < _translatableLabels.length; i++) {
      final source = _normalizeComparableText(_translatableLabels[i]);
      final translated = _normalizeComparableText(translations[i]);
      if (translated.isNotEmpty && source != translated) {
        changedCount++;
      }
    }

    return changedCount > 0;
  }

  String _normalizeComparableText(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<String> _translateOneWithGooglePublic(
    String text,
    String targetLanguage,
  ) async {
    final googleUri = Uri.https(
      'translate.googleapis.com',
      '/translate_a/single',
      {'client': 'gtx', 'sl': 'en', 'tl': targetLanguage, 'dt': 't', 'q': text},
    );

    String direct = '';
    try {
      direct = await _translateFromGoogleUri(googleUri);
    } catch (_) {
      direct = '';
    }
    if (direct.isNotEmpty) return direct;

    final proxiedUri = Uri.https('api.allorigins.win', '/raw', {
      'url': googleUri.toString(),
    });
    try {
      return await _translateFromGoogleUri(proxiedUri);
    } catch (_) {
      return '';
    }
  }

  Future<String> _translateFromGoogleUri(Uri uri) async {
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return '';

    final decoded = jsonDecode(response.body);
    if (decoded is! List || decoded.isEmpty || decoded.first is! List) {
      return '';
    }

    final segments = decoded.first as List;
    return segments
        .whereType<List>()
        .map((segment) => segment.isNotEmpty ? segment.first.toString() : '')
        .join()
        .trim();
  }

  String tr(String text) {
    if (selectedLanguageCode.value == 'en') {
      return text;
    }
    return translatedLabels[text] ?? text;
  }

  String _extractCountryFromItem(Map<String, dynamic> item) {
    final direct = (item['country'] ?? '').toString().trim();
    if (direct.isNotEmpty) return direct;

    final fromLocation = _extractCountryFromText(
      (item['location'] ?? '').toString(),
    );
    if (fromLocation.isNotEmpty) return fromLocation;

    return _extractCountryFromText((item['address'] ?? '').toString());
  }

  List<Map<String, dynamic>> _filterByCountry(
    List<Map<String, dynamic>> items,
    String country,
  ) {
    final normalizedCountry = country.toLowerCase().trim();
    if (normalizedCountry.isEmpty) return items;

    return items.where((item) {
      final itemCountry = _extractCountryFromItem(item).toLowerCase().trim();
      return itemCountry == normalizedCountry;
    }).toList();
  }

  bool get isCountryFilterActive => detectedCountry.value.trim().isNotEmpty;

  String? get activeCountryOrNull {
    final country = detectedCountry.value.trim();
    return country.isEmpty ? null : country;
  }

  String hotelsSubtitleForCountry(String? country) {
    if (country == null || country.trim().isEmpty) {
      return tr('Handpicked top-rated hotels recommended by our guests');
    }
    return '${tr('Popular Hotels')} · $country';
  }

  String propertiesSubtitleForCountry(String? country) {
    if (country == null || country.trim().isEmpty) {
      return tr(
        'Discover premium villas, apartments, and houses for rent or sale',
      );
    }
    return '${tr('Popular Properties')} · $country';
  }

  List<Map<String, dynamic>> getPopularHotelsForUserLocation() {
    final country = detectedCountry.value.trim();
    if (country.isEmpty) return allHotels;
    return _filterByCountry(allHotels, country);
  }

  List<Map<String, dynamic>> getPopularPropertiesForUserLocation() {
    final country = detectedCountry.value.trim();
    if (country.isEmpty) return allProperties;
    return _filterByCountry(allProperties, country);
  }

  String getMinPrice(Map<String, dynamic> hotel) {
    final roomsData = hotel['rooms'];
    if (roomsData == null) return '';

    List<dynamic> rooms;
    if (roomsData is List) {
      rooms = roomsData;
    } else if (roomsData is Map) {
      rooms = [roomsData];
    } else {
      return '';
    }

    if (rooms.isEmpty) return '';

    double minPrice = double.infinity;
    for (final room in rooms) {
      if (room is Map<String, dynamic>) {
        final priceStr = room['price']?.toString() ?? '0';
        final price = double.tryParse(priceStr) ?? 0;
        if (price > 0 && price < minPrice) {
          minPrice = price;
        }
      }
    }

    double? basePrice;
    if (minPrice != double.infinity) {
      basePrice = minPrice;
    } else {
      final hotelPrice = double.tryParse(hotel['price']?.toString() ?? '');
      if (hotelPrice != null && hotelPrice > 0) {
        basePrice = hotelPrice;
      }
    }

    if (basePrice == null || basePrice <= 0) return '';

    final targetCurrency = displayCurrency;
    final converted = basePrice * detectedCurrencyRate.value;
    return '${CurrencyService.formatAmount(converted, targetCurrency, decimals: 0)}${tr('/night')}';
  }

  String getPropertyPrice(Map<String, dynamic> property) {
    final listingType = property['listingType']?.toString() ?? '';

    final rawPrice = property['price'];
    final directPrice = double.tryParse(rawPrice?.toString() ?? '');
    double? basePrice;
    if (directPrice != null && directPrice > 0) {
      basePrice = directPrice;
    }

    final propertyDetails = property['propertyDetails'];
    if (propertyDetails != null && propertyDetails is Map<String, dynamic>) {
      if (listingType == 'FOR_SALE') {
        final salePrice = propertyDetails['salePrice'];
        if (salePrice != null) {
          final parsed = double.tryParse(salePrice.toString());
          if (parsed != null && parsed > 0) {
            basePrice ??= parsed;
          }
        }
      } else if (listingType == 'FOR_RENT') {
        final rentPrice = propertyDetails['rentPrice'];
        if (rentPrice != null) {
          final parsed = double.tryParse(rentPrice.toString());
          if (parsed != null && parsed > 0) {
            basePrice ??= parsed;
          }
        }
      }
    }

    if (basePrice == null || basePrice <= 0) return '';

    final targetCurrency = displayCurrency;
    final converted = basePrice * detectedCurrencyRate.value;
    final formatted = CurrencyService.formatAmount(
      converted,
      targetCurrency,
      decimals: 0,
    );
    return listingType == 'FOR_RENT' ? '$formatted ${tr('/ mo')}' : formatted;
  }

  List<String> getAutocompleteLocations() {
    final normalizedSeen = <String>{};
    final locations = <String>[];

    bool isLikelyCityOrCountry(String value) {
      if (value.isEmpty) return false;
      if (RegExp(r'\d').hasMatch(value)) return false;
      if (value.length > 40) return false;

      final lower = value.toLowerCase();
      const addressNoiseWords = [
        'street',
        'road',
        'avenue',
        'block',
        'phase',
        'building',
        'house',
        'plot',
        'sector',
        'near',
        'apt',
        'apartment',
      ];
      if (addressNoiseWords.any(lower.contains)) return false;

      if (!RegExp(r'[a-zA-Z]').hasMatch(value)) return false;
      return true;
    }

    void addCandidate(dynamic rawValue) {
      final value = rawValue?.toString().trim() ?? '';
      if (value.isEmpty) return;
      if (!isLikelyCityOrCountry(value)) return;
      final normalized = value.toLowerCase();
      if (normalizedSeen.add(normalized)) {
        locations.add(value);
      }
    }

    void addFromComposite(dynamic rawValue) {
      final value = rawValue?.toString().trim() ?? '';
      if (value.isEmpty) return;

      final parts = value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (parts.isEmpty) return;

      if (parts.length >= 2) {
        addCandidate(parts[parts.length - 2]);
        addCandidate(parts.last);
      } else {
        addCandidate(parts.first);
      }
    }

    void collectFromItem(Map<String, dynamic> item) {
      addCandidate(item['city']);
      addCandidate(item['country']);
      addFromComposite(item['location']);
      addFromComposite(item['address']);
    }

    for (final hotel in allHotels) {
      collectFromItem(hotel);
    }
    for (final property in allProperties) {
      collectFromItem(property);
    }

    locations.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return locations;
  }

  List<Map<String, dynamic>> getFilteredHotels(String? location) {
    if (location == null || location.isEmpty) {
      return allHotels;
    }

    return allHotels.where((hotel) {
      final hotelLocation = hotel['location']?.toString().toLowerCase() ?? '';
      final city = hotel['city']?.toString().toLowerCase() ?? '';
      final country = hotel['country']?.toString().toLowerCase() ?? '';
      final address = hotel['address']?.toString().toLowerCase() ?? '';

      final searchLower = location.toLowerCase();
      return hotelLocation.contains(searchLower) ||
          city.contains(searchLower) ||
          country.contains(searchLower) ||
          address.contains(searchLower);
    }).toList();
  }

  List<Map<String, dynamic>> getFilteredProperties(String? location) {
    if (location == null || location.isEmpty) {
      return allProperties;
    }

    return allProperties.where((property) {
      final propertyLocation =
          property['location']?.toString().toLowerCase() ?? '';
      final city = property['city']?.toString().toLowerCase() ?? '';
      final country = property['country']?.toString().toLowerCase() ?? '';
      final address = property['address']?.toString().toLowerCase() ?? '';

      final searchLower = location.toLowerCase();
      return propertyLocation.contains(searchLower) ||
          city.contains(searchLower) ||
          country.contains(searchLower) ||
          address.contains(searchLower);
    }).toList();
  }
}
