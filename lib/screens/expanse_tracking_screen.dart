import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/expanse_tracking_controller.dart';
import 'package:superapp/modal/expanse_tracking_modal.dart';
import 'package:superapp/screens/expanses_screen.dart';
import 'package:superapp/screens/expense_detail_screen.dart';

class ExpenseTrackingScreen extends StatelessWidget {
  const ExpenseTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExpenseTrackingController());
    final theme = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.ensureFresh();
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () async {
            await controller.onAddExpense();
          },
          backgroundColor: theme.colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  IconButton(
                    onPressed: controller.back,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text("Expense Tracking".tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Get.to(() => const ExpensesScreen());
                      await controller.ensureFresh();
                    },
                    child: Text('Details'.tr,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => _TotalExpenseCard(
                        total: controller.totalFormatted,
                        deltaText: controller.deltaText,
                        primary: theme.colorScheme.primary,
                        theme: theme,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Obx(
                      () => _InsightCard(
                        primary: theme.colorScheme.primary,
                        theme: theme,
                        insight: controller.insight.value,
                        tips: controller.tips,
                        isLoading: controller.isLoading.value,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Text("Transactions".tr,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Get.isDarkMode ? Colors.white : const Color(0xFF1D2330),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: controller.toggleSort,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),
                              child: Row(
                                children: [
                                  Text("Sort by Date".tr,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: Get.isDarkMode ? Colors.white70 : const Color(0xFF9AA0AF),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(width: 6),
                                  Obx(
                                    () => Icon(
                                      controller.sortNewestFirst.value
                                          ? Icons.arrow_downward_rounded
                                          : Icons.arrow_upward_rounded,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Obx(
                      () => Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                text: "All",
                                selected:
                                    controller.selectedFilter.value ==
                                    ExpenseTrackingFilter.all,
                                onTap: () => controller.setFilter(
                                  ExpenseTrackingFilter.all,
                                ),
                                primary: theme.colorScheme.primary,
                                theme: theme,
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                text: "Maintenance",
                                selected:
                                    controller.selectedFilter.value ==
                                    ExpenseTrackingFilter.maintenance,
                                onTap: () => controller.setFilter(
                                  ExpenseTrackingFilter.maintenance,
                                ),
                                primary: theme.colorScheme.primary,
                                theme: theme,
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                text: "Utilities",
                                selected:
                                    controller.selectedFilter.value ==
                                    ExpenseTrackingFilter.utilities,
                                onTap: () => controller.setFilter(
                                  ExpenseTrackingFilter.utilities,
                                ),
                                primary: theme.colorScheme.primary,
                                theme: theme,
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                text: "Tax",
                                selected:
                                    controller.selectedFilter.value ==
                                    ExpenseTrackingFilter.tax,
                                onTap: () => controller.setFilter(
                                  ExpenseTrackingFilter.tax,
                                ),
                                primary: theme.colorScheme.primary,
                                theme: theme,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Obx(() {
                      final items = controller.filteredTxns;

                      return Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                        child: _Card(
                          child: Column(
                            children: [
                              for (int i = 0; i < items.length; i++) ...[
                                _TxnRow(
                                  txn: items[i],
                                  primary: theme.colorScheme.primary,
                                ),
                                if (i != items.length - 1)
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Get.isDarkMode ? Colors.white24 : const Color(0xFFF2F2F2),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TotalExpenseCard extends StatelessWidget {
  const _TotalExpenseCard({
    required this.total,
    required this.deltaText,
    required this.primary,
    required this.theme,
  });

  final String total;
  final String deltaText;
  final Color primary;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isNegative = deltaText.trim().startsWith('-');
    final chipBg = Colors.white.withOpacity(0.20);
    final chipFg = Colors.white;

    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF38CAC7), Color(0xFF27B9B6), Color(0xFF119C99)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Total Expenses (This Month)".tr,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white.withOpacity(0.92),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/wallet_icon.png',
                  height: 16,
                  width: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            total,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 25),
          Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isNegative
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 14,
                  color: chipFg,
                ),
                const SizedBox(width: 6),
                Text(
                  deltaText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: chipFg,
                    fontWeight: FontWeight.w900,
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

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.primary,
    required this.theme,
    required this.insight,
    required this.tips,
    this.isLoading = false,
  });

  final Color primary;
  final ThemeData theme;
  final String insight;
  final List<String> tips;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    
    String displayText = insight;
    if (displayText.isEmpty) {
      displayText = isLoading 
          ? "Analyzing your expenses..."
          : "Add expenses to get AI-powered insights about your spending patterns.";
    } else if (tips.isNotEmpty) {
      displayText = "$insight\n\n${tips.take(2).map((t) => '• $t').join('\n')}";
    }
    
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primary,
                      ),
                    )
                  : Icon(Icons.auto_awesome_rounded, size: 18, color: primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("AI Insight".tr,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isDark ? Colors.white : const Color(0xFF1D2330),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayText,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark ? Colors.white70 : const Color(0xFF9AA0AF),
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.text,
    required this.selected,
    required this.onTap,
    required this.primary,
    required this.theme,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;
  final Color primary;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? primary : (isDark ? theme.cardColor : Colors.white),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? primary : (isDark ? Colors.white24 : const Color(0xFFE6E9F0)),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1D2330)),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn, required this.primary});

  final ExpenseTrackingModal txn;
  final Color primary;

  IconData _iconForTitle(String title) {
    final t = title.toLowerCase();

    if (t.contains('hvac') || t.contains('repair') || t.contains('plumbing')) {
      return Icons.build_outlined;
    }
    if (t.contains('water')) {
      return Icons.water_drop_outlined;
    }
    if (t.contains('repaint') ||
        t.contains('painting') ||
        t.contains('paint')) {
      return Icons.format_paint_outlined;
    }
    if (t.contains('tax')) {
      return Icons.receipt_long_outlined;
    }
    return Icons.payments_outlined;
  }

  String _catText(ExpenseTrackingFilter c) {
    switch (c) {
      case ExpenseTrackingFilter.maintenance:
        return "Maintenance";
      case ExpenseTrackingFilter.utilities:
        return "Utilities";
      case ExpenseTrackingFilter.tax:
        return "Tax";
      case ExpenseTrackingFilter.all:
        return "All";
      case ExpenseTrackingFilter.other:
        return "Other";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;
    final amountText = "- \$${txn.amount.abs().toStringAsFixed(2)}";

    return InkWell(
      onTap: () async {
        await Get.to(
          () => ExpenseDetailScreen(expenseId: txn.id),
        );
        // Always refresh when returning from detail screen
        if (Get.isRegistered<ExpenseTrackingController>()) {
          await Get.find<ExpenseTrackingController>()
              .fetchExpenses(forceReloadToken: true);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              height: 34,
              child: Icon(
                _iconForTitle(txn.title),
                size: 20,
                color: isDark ? Colors.white : const Color(0xFF1D2330),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isDark ? Colors.white : const Color(0xFF1D2330),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${txn.place}  •  ${txn.dateText}",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark ? Colors.white70 : const Color(0xFF9AA0AF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF1D2330),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _catText(txn.category),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? Colors.white70 : const Color(0xFF9AA0AF),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : const Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
