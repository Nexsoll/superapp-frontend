import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:superapp/controllers/profile_controller.dart';
import 'package:superapp/modal/my_wallet_modal.dart';
import 'package:superapp/services/api_service.dart';

class MyWalletController extends GetxController {
  final ProfileController profileController = Get.find<ProfileController>();
  final txns = <MyWalletModal>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    profileController.getProfile();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    isLoading.value = true;
    try {
      final token = profileController.token;
      if (token.isNotEmpty) {
        final data = await ApiService.getTransactions(token: token);
        final list = data.map((json) {
          final type = json['type']?.toString() ?? '';
          int iconType = 2; // Default to Refund
          if (type == 'BOOKING_PAYMENT') iconType = 0;
          if (type == 'WALLET_TOPUP') iconType = 1;

          final createdAt = DateTime.parse(json['createdAt']);
          final dateStr = DateFormat('MMM d, hh:mm a').format(createdAt);

          return MyWalletModal(
            title: json['description'] ?? 'Transaction',
            meta: dateStr,
            amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
            iconType: iconType,
          );
        }).toList();
        txns.assignAll(list);
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void back() => Get.back();

  void onTopUp() {}
  void onWithdraw() {}
  void onScan() {}
  void onMore() {}
  void onSeeAll() {}

  String get balanceFormatted =>
      "\$${profileController.balance.value.toStringAsFixed(2)}";

  String get deltaText {
    // For now, keeping a static delta or calculating if we had monthly comparison
    return "-5% vs last month";
  }
}
