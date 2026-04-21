import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:superapp/controllers/my_wallet_controllr.dart';
import 'package:superapp/modal/my_wallet_modal.dart';

class MyWalletScreen extends StatelessWidget {
  const MyWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyWalletController());
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: controller.back,
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      size: 35,
                      color: primary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
                  const SizedBox(width: 8),
                  Text("My Wallet".tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => _WalletTopCard(
                        theme: theme,
                        total: controller.balanceFormatted,
                        deltaText: controller.deltaText,
                        primary: primary,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ActionTile(
                            image: 'assets/wallet_add.png',
                            label: "Top Up",
                            onTap: controller.onTopUp,
                            primary: primary,
                            filled: true,
                          ),
                          _ActionTile(
                            image: 'assets/wallet_withdraw.png',
                            label: "Withdraw",
                            onTap: controller.onWithdraw,
                            primary: primary,
                          ),
                          _ActionTile(
                            image: 'assets/wallet_scan.png',
                            label: "Scan",
                            onTap: controller.onScan,
                            primary: primary,
                          ),
                          _ActionTile(
                            image: 'assets/wallet_more.png',
                            label: "More",
                            onTap: controller.onMore,
                            primary: primary,
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: _InfoCard(primary: primary, theme: theme),
                    ),

                    const SizedBox(height: 18),

                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Text("Recent Transactions".tr,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: controller.onSeeAll,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text("See All".tr,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: primary,
                                fontWeight: FontWeight.w800,
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
                        child: Column(
                          children: [
                            for (
                              int i = 0;
                              i < controller.txns.length;
                              i++
                            ) ...[
                              _TxnTile(
                                txn: controller.txns[i],
                                primary: primary,
                              ),
                              if (i != controller.txns.length - 1)
                                const SizedBox(height: 8),
                            ],
                          ],
                        ),
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

class _WalletTopCard extends StatelessWidget {
  const _WalletTopCard({
    required this.theme,
    required this.total,
    required this.deltaText,
    required this.primary,
  });

  final ThemeData theme;
  final String total;
  final String deltaText;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final isNegative = deltaText.trim().startsWith('-');
    final arrow = isNegative
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

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
              Text("Wallet Balance".tr,
                style: theme.textTheme.labelSmall?.copyWith(
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
                  height: 15,
                  width: 15,
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
              height: 1.05,
            ),
          ),
          SizedBox(height: 30),
          Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(arrow, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  deltaText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
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

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.image,
    required this.label,
    required this.onTap,
    required this.primary,
    this.filled = false,
  });

  final String image;
  final String label;
  final VoidCallback onTap;
  final Color primary;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = filled ? primary : theme.cardColor;

    return SizedBox(
      width: 66,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Image.asset(
                image, 
                height: 20, 
                width: 20,
                color: filled ? Colors.white : (theme.brightness == Brightness.dark ? Colors.white : null),
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF1D2330),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.primary, required this.theme});

  final Color primary;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              'assets/wallet_question.png',
              height: 18,
              width: 18,
              color: theme.brightness == Brightness.dark ? Colors.white : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ready for your next trip?".tr,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text("Use your wallet balance to book hotels instantly without fees.".tr,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF9AA0AF),
                    fontWeight: FontWeight.w600,
                    height: 1.25,
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

class _TxnTile extends StatelessWidget {
  const _TxnTile({required this.txn, required this.primary});

  final MyWalletModal txn;
  final Color primary;

  String _assetFromType(int t) {
    switch (t) {
      case 0:
        return "assets/wallet_hotel.png";
      case 1:
        return "assets/wallet_topup.png";
      case 2:
        return "assets/wallet_refund.png";
      default:
        return "assets/wallet_refund.png";
    }
  }

  String _rightTagFromType(int t) {
    switch (t) {
      case 0:
        return "Booking";
      case 1:
        return "Top Up";
      case 2:
        return "Refund";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isPositive = txn.amount >= 0;
    final amountColor = isPositive
        ? const Color(0xFF22C55E)
        : (theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330));
    final amountText =
        "${isPositive ? "+" : "-"} \$${txn.amount.abs().toStringAsFixed(2)}";

    final tag = _rightTagFromType(txn.iconType);
    final assetPath = _assetFromType(txn.iconType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        children: [
          Image.asset(
            height: 18,
            width: 18,
            assetPath,
            fit: BoxFit.contain,

            color: txn.iconType == 1
                ? const Color(0xFF22C55E)
                : (theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  txn.meta,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF9AA0AF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (tag.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  tag,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF9AA0AF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
