import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshOwnerSummary,
          color: theme.colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: controller.onViewReport,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('View Report'.tr,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Obx(
                  () => _EarningsCard(
                    total: controller.earningsFormatted,
                    chipText: controller.growthText,
                    onTap: controller.onTotalEarnings,
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _MiniStatCard(
                            onTap: controller.onActiveListings,
                            icon: Icons.home_outlined,
                            iconBg: const Color(0xFFE6F7F7),
                            iconColor: theme.colorScheme.primary,
                            title: 'Active Listings',
                            value: '${controller.activeListings.value}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => _MiniRequestCard(
                            onTap: controller.onPendingRequests,
                            badgeText: controller.pendingRequestsBadge.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Text('Management Tools'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Get.isDarkMode
                        ? Colors.white
                        : const Color(0xFF1D2330),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                  child: Obx(
                    () => _ToolsGrid(
                      onMyListings: controller.onMyListings,
                      onEarnings: controller.onEarnings,
                      onExpenses: controller.onExpenses,
                      onAnalytics: controller.onAnalytics,
                      propertyCount: controller.activeProperties.value,
                    ),
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

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({
    required this.total,
    required this.chipText,
    required this.onTap,
  });

  final String total;
  final String chipText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '\$',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    chipText,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Total Earnings'.tr,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              total,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text('This month'.tr,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.onTap,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  final VoidCallback onTap;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : const Color(0x0F000000),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? iconBg.withOpacity(0.2) : iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark ? Colors.white70 : const Color(0xFF9AA0AF),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: isDark ? Colors.white : const Color(0xFF1D2330),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniRequestCard extends StatelessWidget {
  const _MiniRequestCard({required this.onTap, required this.badgeText});

  final VoidCallback onTap;
  final String badgeText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : const Color(0x0F000000),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -18,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D6).withOpacity(isDark ? 0.2 : 1),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFFFF3D6,
                    ).withOpacity(isDark ? 0.2 : 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFFF59E0B),
                    size: 17,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Pending\nRequests'.tr,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isDark ? Colors.white70 : const Color(0xFF9AA0AF),
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('3'.tr,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFFE6B7,
                          ).withOpacity(isDark ? 0.2 : 1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFF59E0B),
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
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

class _ToolsGrid extends StatelessWidget {
  const _ToolsGrid({
    required this.onMyListings,
    required this.onEarnings,
    required this.onExpenses,
    required this.onAnalytics,
    required this.propertyCount,
  });

  final VoidCallback onMyListings;
  final VoidCallback onEarnings;
  final VoidCallback onExpenses;
  final VoidCallback onAnalytics;
  final int propertyCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.25,
      children: [
        _ToolTile(
          icon: Icons.home_outlined,
          iconBg: const Color(0xFFE6F7F7),
          iconColor: theme.colorScheme.primary,
          title: 'My Listings',
          subtitle: 'Manage $propertyCount\nproperties',
          onTap: onMyListings,
        ),
        _ToolTile(
          icon: Icons.receipt_long_outlined,
          iconBg: const Color(0xFFE9F7EC),
          iconColor: const Color(0xFF22C55E),
          title: 'Earnings',
          subtitle: 'Payouts & History',
          onTap: onEarnings,
        ),
        _ToolTile(
          icon: Icons.description_outlined,
          iconBg: const Color(0xFFFFECEC),
          iconColor: const Color(0xFFEF4444),
          title: 'Expenses',
          subtitle: 'Track\nmaintenance',
          onTap: onExpenses,
        ),
        _ToolTile(
          icon: Icons.bar_chart_rounded,
          iconBg: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF8B5CF6),
          title: 'Analytics',
          subtitle: 'Insights & Trends',
          onTap: onAnalytics,
        ),
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : const Color(0x0F000000),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? iconBg.withOpacity(0.2) : iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white : const Color(0xFF1D2330),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : const Color(0xFF9AA0AF),
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
