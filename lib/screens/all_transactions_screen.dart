import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superapp/services/api_service.dart';

class AllTransactionsScreen extends StatefulWidget {
  final bool isExpense;

  const AllTransactionsScreen({
    super.key,
    required this.isExpense,
  });

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> transactions = [];
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('user_token');
    if (_token != null && _token!.isNotEmpty) {
      await _fetchTransactions();
    }
  }

  Future<void> _fetchTransactions() async {
    setState(() => isLoading = true);
    try {
      final expenses = await ApiService.getExpenses(token: _token!);
      setState(() {
        transactions = expenses;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('Error', 'Failed to load transactions: $e');
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${monthNames[date.month - 1]} ${date.day}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _imageFromTitle(String title, Color? iconColor) {
    final t = title.toLowerCase().trim();
    String asset;

    if (t.contains("sea")) {
      asset = "assets/earning_home.png";
    } else if (t.contains("electric") ||
        t.contains("electricity") ||
        t.contains("bill") ||
        t.contains("downtown")) {
      asset = "assets/earning_flash.png";
    } else if (t.contains("shopping") ||
        t.contains("mart") ||
        t.contains("grocery")) {
      asset = "assets/expanse_shopping.png";
    } else if (t.contains("fuel") ||
        t.contains("petrol") ||
        t.contains("gas") ||
        t.contains("plumbing")) {
      asset = "assets/expanse_fuel.png";
    } else {
      asset = "assets/expanse_fuel.png";
    }

    return Image.asset(
      asset,
      width: 15,
      height: 15,
      fit: BoxFit.contain,
      color: iconColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          widget.isExpense ? "All Expenses" : "All Earnings",
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTransactions,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : transactions.isEmpty
                ? Center(
                    child: Text("No transactions found".tr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : const Color(0xFF9AA0AF),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final txn = transactions[index];
                      final title = txn['title']?.toString() ?? 'Unknown';
                      final amount = _parseDouble(txn['amount']);
                      final dateStr = txn['date']?.toString() ?? '';
                      final id = txn['id']?.toString() ?? '';
                      final formattedDate = _formatDate(dateStr);

                      final isPositive = widget.isExpense ? false : true;
                      final displayAmount = widget.isExpense ? -amount.abs() : amount.abs();
                      final amountColor = isPositive
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444);
                      final amountText =
                          "${isPositive ? "+" : "-\$${displayAmount.abs().toStringAsFixed(2)}"}";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? theme.cardColor : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? Colors.white24 : const Color(0xFFEDEFF5),
                          ),
                        ),
                        child: Row(
                          children: [
                            _imageFromTitle(title, theme.iconTheme.color),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: isDark ? Colors.white : const Color(0xFF1D2330),
                                      fontWeight: FontWeight.w600,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "$formattedDate  •  REF-${id.padLeft(4, '0')}",
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isDark ? Colors.white70 : const Color(0xFF9AA0AF),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              amountText,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: amountColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
