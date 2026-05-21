import 'dart:convert';

import 'package:http/http.dart' as http;

class CurrencyService {
  static Map<String, double>? _liveExchangeRates;

  // Exchange rates relative to USD (base currency)
  static const Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'INR': 83.25,
    'PKR': 278.50,
    'GBP': 0.79,
    'AED': 3.67,
    'SAR': 3.75,
    'TRY': 32.30,
    'CHF': 0.90,
    'SEK': 10.70,
    'NOK': 10.60,
    'DKK': 6.86,
    'PLN': 3.95,
    'CZK': 22.60,
    'HUF': 360.00,
    'RON': 4.58,
  };

  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'INR': '₹',
    'PKR': 'Rs',
    'GBP': '£',
    'AED': 'د.إ',
    'SAR': 'ر.س',
    'TRY': '₺',
    'CHF': 'CHF',
    'SEK': 'kr',
    'NOK': 'kr',
    'DKK': 'kr',
    'PLN': 'zł',
    'CZK': 'Kč',
    'HUF': 'Ft',
    'RON': 'lei',
  };

  static void setSymbol(String currency, String symbol) {
    final normalizedCurrency = currency.toUpperCase().trim();
    final normalizedSymbol = symbol.trim();
    if (normalizedCurrency.length != 3 || normalizedSymbol.isEmpty) return;
    _runtimeCurrencySymbols[normalizedCurrency] = normalizedSymbol;
  }

  static final Map<String, String> _runtimeCurrencySymbols = {};

  static Future<void> ensureLiveRates() async {
    if (_liveExchangeRates != null) return;

    try {
      final response = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return;

      final rates = decoded['rates'];
      if (rates is! Map) return;

      _liveExchangeRates = rates.map((key, value) {
        final parsed = double.tryParse(value.toString());
        return MapEntry(key.toString().toUpperCase(), parsed ?? 1.0);
      });
    } catch (_) {
      _liveExchangeRates = const {};
    }
  }

  static double rateFromUSD(String targetCurrency) {
    final normalizedCurrency = targetCurrency.toUpperCase().trim();
    return _liveExchangeRates?[normalizedCurrency] ??
        _exchangeRates[normalizedCurrency] ??
        1.0;
  }

  /// Convert amount from USD to target currency
  static double convertFromUSD(double amountInUSD, String targetCurrency) {
    final rate = rateFromUSD(targetCurrency);
    return amountInUSD * rate;
  }

  /// Convert amount from source currency to USD
  static double convertToUSD(double amount, String sourceCurrency) {
    final rate = rateFromUSD(sourceCurrency);
    return amount / rate;
  }

  /// Convert amount from source currency to target currency
  static double convert(double amount, String fromCurrency, String toCurrency) {
    final amountInUSD = convertToUSD(amount, fromCurrency);
    return convertFromUSD(amountInUSD, toCurrency);
  }

  /// Format amount with currency symbol
  static String formatAmount(
    double amount,
    String currency, {
    int decimals = 0,
  }) {
    final normalizedCurrency = currency.toUpperCase().trim();
    final symbol =
        _runtimeCurrencySymbols[normalizedCurrency] ??
        _currencySymbols[normalizedCurrency] ??
        normalizedCurrency;
    final formatted = amount.toStringAsFixed(decimals);

    // Format with commas for thousands
    final parts = formatted.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? '.${parts[1]}' : '';

    final formattedInt = intPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return '$symbol$formattedInt$decPart';
  }

  /// Get currency symbol
  static String getSymbol(String currency) {
    final normalizedCurrency = currency.toUpperCase().trim();
    return _runtimeCurrencySymbols[normalizedCurrency] ??
        _currencySymbols[normalizedCurrency] ??
        normalizedCurrency;
  }

  /// Get all supported currencies
  static List<String> getSupportedCurrencies() {
    return _exchangeRates.keys.toList();
  }

  static bool isSupportedCurrency(String currency) {
    final normalizedCurrency = currency.toUpperCase().trim();
    return RegExp(r'^[A-Z]{3}$').hasMatch(normalizedCurrency);
  }

  /// Fetch live exchange rates (optional - for future enhancement)
  static Future<Map<String, double>> fetchLiveRates() async {
    try {
      // You can integrate with a real API like exchangerate-api.com
      // For now, return static rates
      return _exchangeRates;
    } catch (e) {
      return _exchangeRates;
    }
  }
}
