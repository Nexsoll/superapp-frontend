import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superapp/modal/earning_expanses_modal.dart';
import 'package:superapp/screens/all_transactions_screen.dart';
import 'package:superapp/services/api_service.dart';
import 'package:superapp/services/report_export_service.dart';

class EarningExpansesController extends GetxController {
  EarningExpansesController({required this.mode});

  final ReportMode mode;

  final range = ReportRange.thisMonth.obs;

  final isLoading = false.obs;
  final total = 0.0.obs;
  final percent = 0.0.obs;

  final bars = <double>[].obs;
  final txns = <EarningExpansesModal>[].obs;

  String? _token;

  bool get isExpense => mode == ReportMode.expenses;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('user_token');
    if (_token != null && _token!.isNotEmpty) {
      await fetchData();
    }
  }

  Future<void> fetchData() async {
    if (_token == null || _token!.isEmpty) return;
    isLoading.value = true;
    try {
      // Fetch summary and expenses in parallel
      final results = await Future.wait([
        ApiService.getExpenseSummary(token: _token!),
        ApiService.getExpenses(token: _token!),
      ]);

      final summary = results[0] as Map<String, dynamic>;
      final expenses = results[1] as List<Map<String, dynamic>>;

      // Update totals - handle both String and num types from backend
      total.value = _parseDouble(summary['totalThisMonth']);
      final delta = _parseDouble(summary['deltaPercent']);
      // Convert to fraction for display (backend returns percentage like -8.0 for -8%)
      percent.value = delta / 100;

      // Generate trend bars from weekly data
      bars.value = _calculateWeeklyTrend(expenses);

      // Map expenses to transaction models
      txns.value = expenses.take(5).map((e) => _mapExpenseToModal(e)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<double> _calculateWeeklyTrend(List<Map<String, dynamic>> expenses) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    // Group expenses by week
    final weeklyTotals = <int, double>{};
    for (int i = 0; i < 5; i++) {
      weeklyTotals[i] = 0;
    }

    for (final expense in expenses) {
      final dateStr = expense['date']?.toString();
      if (dateStr == null) continue;

      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;

      // Only consider current month expenses
      if (date.isBefore(startOfMonth)) continue;

      final weekOfMonth = ((date.day - 1) / 7).floor();
      if (weekOfMonth >= 0 && weekOfMonth < 5) {
        final amount = _parseDouble(expense['amount']);
        weeklyTotals[weekOfMonth] = (weeklyTotals[weekOfMonth] ?? 0) + amount;
      }
    }

    // Normalize to 0-1 range for bar display
    final values = weeklyTotals.values.toList();
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    if (maxVal == 0) {
      return [0.2, 0.2, 0.2, 0.2, 0.2];
    }

    return values.map((v) => (v / maxVal).clamp(0.1, 1.0)).toList();
  }

  EarningExpansesModal _mapExpenseToModal(Map<String, dynamic> e) {
    final title = e['title']?.toString() ?? 'Unknown';
    final amount = _parseDouble(e['amount']);
    final dateStr = e['date']?.toString() ?? '';
    final id = e['id']?.toString() ?? '';

    // Format date
    String formattedDate = dateStr;
    try {
      final date = DateTime.parse(dateStr);
      final monthNames = [
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
      formattedDate = '${monthNames[date.month - 1]} ${date.day}';
    } catch (_) {}

    return EarningExpansesModal(
      title: title,
      meta: "$formattedDate  •  REF-${id.padLeft(4, '0')}",
      amount: isExpense ? -amount.abs() : amount.abs(),
      iconType: _getIconType(title),
    );
  }

  int _getIconType(String title) {
    final t = title.toLowerCase();
    if (t.contains('electric') || t.contains('bill')) return 1;
    if (t.contains('shopping') || t.contains('grocery') || t.contains('mart'))
      return 2;
    if (t.contains('gas') || t.contains('fuel') || t.contains('petrol'))
      return 3;
    if (t.contains('sea') || t.contains('villa') || t.contains('property'))
      return 0;
    return 3;
  }

  String get title => isExpense ? "Expenses" : "Earnings";

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String get totalLabel => isExpense ? "TOTAL EXPENSES" : "TOTAL EARNINGS";
  String get trendLabel => isExpense ? "Expense Trend" : "Earning Trend";

  String get dateRangeText {
    final now = DateTime.now();
    final monthNames = [
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

    switch (range.value) {
      case ReportRange.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return "${monthNames[start.month - 1]} ${start.day} - ${monthNames[end.month - 1]} ${end.day}";
      case ReportRange.last3Months:
        final start = DateTime(now.year, now.month - 2, 1);
        return "${monthNames[start.month - 1]} - ${monthNames[now.month - 1]} ${now.year}";
      case ReportRange.ytd:
        return "Jan 1 - ${monthNames[now.month - 1]} ${now.day}, ${now.year}";
    }
  }

  String get rangeText {
    switch (range.value) {
      case ReportRange.thisMonth:
        return "This Month";
      case ReportRange.last3Months:
        return "Last 3 Months";
      case ReportRange.ytd:
        return "Year to Date";
    }
  }

  String get totalFormatted => "\$${total.value.toStringAsFixed(2)}";
  String get percentText {
    final p = (percent.value * 100).abs().toStringAsFixed(0);
    return "${percent.value >= 0 ? "+" : "-"}$p% vs last month";
  }

  void setRange(ReportRange v) {
    if (range.value != v) {
      range.value = v;
      fetchData();
    }
  }

  void back() => Get.back();

  void onViewAll() {
    Get.to(() => AllTransactionsScreen(isExpense: isExpense));
  }

  void onExport() async {
    // Fetch all transactions for export
    if (_token == null || _token!.isEmpty) return;

    final allExpenses = await ApiService.getExpenses(token: _token!);

    Get.dialog(
      _ExportDialog(
        transactions: allExpenses,
        total: total.value,
        dateRange: dateRangeText,
        isExpense: isExpense,
        trendBars: bars.toList(),
      ),
      barrierDismissible: true,
    );
  }
}

class _ExportDialog extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final double total;
  final String dateRange;
  final bool isExpense;
  final List<double> trendBars;

  const _ExportDialog({
    required this.transactions,
    required this.total,
    required this.dateRange,
    required this.isExpense,
    required this.trendBars,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.download_rounded,
                color: theme.colorScheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Export Report',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred format',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _ExportOption(
              icon: Icons.picture_as_pdf_rounded,
              title: 'Export as PDF',
              subtitle: 'Beautiful formatted report',
              color: const Color(0xFFEF4444),
              onTap: () async {
                Get.back();
                await ReportExportService.exportReport(
                  context: context,
                  format: ExportFormat.pdf,
                  transactions: transactions,
                  total: total,
                  reportTitle: isExpense ? 'Expense Report' : 'Earnings Report',
                  dateRange: dateRange,
                  trendBars: trendBars,
                );
              },
            ),
            const SizedBox(height: 12),
            _ExportOption(
              icon: Icons.table_chart_rounded,
              title: 'Export as CSV',
              subtitle: 'Spreadsheet format',
              color: const Color(0xFF22C55E),
              onTap: () async {
                Get.back();
                await ReportExportService.exportReport(
                  context: context,
                  format: ExportFormat.csv,
                  transactions: transactions,
                  total: total,
                  reportTitle: isExpense ? 'Expense Report' : 'Earnings Report',
                  dateRange: dateRange,
                  trendBars: [],
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
