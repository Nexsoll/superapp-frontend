import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superapp/modal/expanse_tracking_modal.dart';
import 'package:superapp/screens/add_expanse_screen.dart';
import 'package:superapp/services/api_service.dart';

class ExpenseTrackingController extends GetxController {
  final selectedFilter = ExpenseTrackingFilter.all.obs;
  final sortNewestFirst = true.obs;

  final totalThisMonth = 0.0.obs;
  final deltaPercent = 0.0.obs;
  final isLoading = false.obs;
  final insight = ''.obs;
  final tips = <String>[].obs;

  final txns = <ExpenseTrackingModal>[].obs;

  String? _token;
  DateTime? _lastFetchAt;

  @override
  void onInit() {
    super.onInit();
    _loadTokenAndFetch();
  }

  Future<void> _loadTokenAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('user_token');
    await fetchExpenses();
  }

  Future<void> ensureFresh() async {
    // If you return to this screen, ensure data is refreshed.
    // Prevent aggressive refetching during rebuilds.
    final now = DateTime.now();
    if (isLoading.value) return;
    if (_lastFetchAt != null && now.difference(_lastFetchAt!).inSeconds < 2) {
      return;
    }
    await fetchExpenses(forceReloadToken: true);
  }

  Future<void> fetchExpenses({bool forceReloadToken = false}) async {
    if (forceReloadToken || _token == null || _token!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('user_token');
    }

    if (_token == null || _token!.isEmpty) return;

    isLoading.value = true;

    try {
      final results = await Future.wait([
        ApiService.getExpenses(token: _token!),
        ApiService.getExpenseSummary(token: _token!),
        ApiService.getExpenseInsight(token: _token!),
      ]);

      // Parse expenses
      final expenseList = results[0] as List<Map<String, dynamic>>;
      txns.assignAll(
        expenseList.map((json) => ExpenseTrackingModal.fromJson(json)).toList(),
      );

      // Parse summary
      final summary = results[1] as Map<String, dynamic>;
      totalThisMonth.value = (summary['totalThisMonth'] as num?)?.toDouble() ?? 0.0;
      deltaPercent.value = (summary['deltaPercent'] as num?)?.toDouble() ?? 0.0;

      // Parse insight
      final insightData = results[2] as Map<String, dynamic>;
      insight.value = insightData['insight'] as String? ?? '';
      final tipsList = insightData['tips'] as List?;
      if (tipsList != null) {
        tips.assignAll(tipsList.map((e) => e.toString()).toList());
      }

      _lastFetchAt = DateTime.now();
    } catch (e) {
      print('Error fetching expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await fetchExpenses();
  }

  void back() => Get.back();

  void setFilter(ExpenseTrackingFilter f) => selectedFilter.value = f;

  void toggleSort() => sortNewestFirst.value = !sortNewestFirst.value;

  Future<void> onAddExpense() async {
    await Get.to(() => AddExpenseScreen());
    // Always refresh when returning from Add Expense.
    // Some navigation paths may return null/false even after saving.
    // We still refetch to guarantee latest data without manual pull-to-refresh.
    await Future.delayed(const Duration(milliseconds: 200));
    await fetchExpenses(forceReloadToken: true);
    await Future.delayed(const Duration(milliseconds: 600));
    await fetchExpenses(forceReloadToken: true);
  }

  List<ExpenseTrackingModal> get filteredTxns {
    final f = selectedFilter.value;

    final list = f == ExpenseTrackingFilter.all
        ? txns.toList()
        : txns.where((e) => e.category == f).toList();

    if (sortNewestFirst.value) {
      return list;
    } else {
      return list.reversed.toList();
    }
  }

  String get totalFormatted => "\$${totalThisMonth.value.toStringAsFixed(2)}";

  String get deltaText {
    final p = deltaPercent.value.abs().toStringAsFixed(0);
    return "${deltaPercent.value < 0 ? "-" : "+"}$p% vs last month";
  }
}
