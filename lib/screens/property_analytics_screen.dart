import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/property_analytics_controller.dart';

class PropertyAnalyticsScreen extends StatelessWidget {
  const PropertyAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PropertyAnalyticsController());
    final theme = Theme.of(context);
    final isDesktopWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 900;

    if (isDesktopWeb) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: controller.back,
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Property Analytics".tr,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Track occupancy, yield, viewings, and income performance."
                                    .tr,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.textTheme.bodyLarge?.color
                                      ?.withValues(alpha: 0.66),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: controller.onExport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: Text("Export Full Report".tr),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () => SizedBox(
                        width: 560,
                        child: _RangeTabs(
                          selected: controller.range.value,
                          onTap: controller.setRange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () => GridView.count(
                        crossAxisCount: 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.35,
                        children: [
                          _StatCard(
                            label: "Occupancy",
                            valueText:
                                "${controller.occupancy.value.toStringAsFixed(0)}%",
                            deltaText:
                                "+${controller.occupancyDelta.value.toStringAsFixed(1)}%",
                            deltaSubText: "vs last mo",
                            positive: true,
                            icon: Icons.home_outlined,
                            iconBg: theme.colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            iconFg: theme.colorScheme.primary,
                          ),
                          _StatCard(
                            label: "Yield",
                            valueText:
                                "${controller.yieldValue.value.toStringAsFixed(1)}%",
                            deltaText:
                                "+${controller.yieldDelta.value.toStringAsFixed(1)}%",
                            deltaSubText: "vs target",
                            positive: true,
                            icon: Icons.percent_rounded,
                            iconBg: theme.colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            iconFg: theme.colorScheme.primary,
                          ),
                          _StatCard(
                            label: "Viewings",
                            valueText: "${controller.viewings.value}",
                            deltaText: "",
                            deltaSubText: "Total this month",
                            positive: true,
                            icon: Icons.visibility_outlined,
                            iconBg: theme.colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            iconFg: theme.colorScheme.primary,
                            showDelta: false,
                          ),
                          _StatCard(
                            label: "Avg. Stay",
                            valueText:
                                "${controller.avgStay.value.toStringAsFixed(1)}",
                            unitText: "Nights",
                            deltaText:
                                "+${controller.avgStayDelta.value.toStringAsFixed(1)}",
                            deltaSubText: "",
                            positive: true,
                            icon: Icons.access_time_rounded,
                            iconBg: theme.colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            iconFg: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _Card(
                            child: Padding(
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Occupancy Trends".tr,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.more_horiz_rounded,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Daily occupancy rate over selected period"
                                          .tr,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color
                                                ?.withValues(alpha: 0.62),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  SizedBox(
                                    height: 190,
                                    child: _LineChart(
                                      points: controller.occupancyTrend,
                                      stroke: theme.colorScheme.primary,
                                      dot: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: Obx(
                            () => _Card(
                              child: Padding(
                                padding: const EdgeInsets.all(22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Financial Breakdown".tr,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.bar_chart_rounded,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        Text(
                                          "\$${controller.netIncome.value.toStringAsFixed(0)}",
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Net income".tr,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                color: theme
                                                    .textTheme
                                                    .labelLarge
                                                    ?.color
                                                    ?.withValues(alpha: 0.62),
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    _Bars(
                                      gross: controller.grossValue.value,
                                      net: controller.netValue.value,
                                      primary: theme.colorScheme.primary,
                                      theme: theme,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
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
                        child: Text(
                          "Property Analytics".tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Obx(
                    () => _RangeTabs(
                      selected: controller.range.value,
                      onTap: controller.setRange,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Obx(
                    () => Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.45,
                        children: [
                          _StatCard(
                            label: "Occupancy",
                            valueText:
                                "${controller.occupancy.value.toStringAsFixed(0)}%",
                            deltaText:
                                "+${controller.occupancyDelta.value.toStringAsFixed(1)}%",
                            deltaSubText: "vs last mo",
                            positive: true,
                            icon: Icons.home_outlined,
                            iconBg: theme.colorScheme.primary.withOpacity(0.12),
                            iconFg: theme.colorScheme.primary,
                          ),
                          _StatCard(
                            label: "Yield",
                            valueText:
                                "${controller.yieldValue.value.toStringAsFixed(1)}%",
                            deltaText:
                                "+${controller.yieldDelta.value.toStringAsFixed(1)}%",
                            deltaSubText: "vs target",
                            positive: true,
                            icon: Icons.percent_rounded,
                            iconBg: theme.colorScheme.primary.withOpacity(0.12),
                            iconFg: theme.colorScheme.primary,
                          ),
                          _StatCard(
                            label: "Viewings",
                            valueText: "${controller.viewings.value}",
                            deltaText: "",
                            deltaSubText: "Total this month",
                            positive: true,
                            icon: Icons.visibility_outlined,
                            iconBg: theme.colorScheme.primary.withOpacity(0.12),
                            iconFg: theme.colorScheme.primary,
                            showDelta: false,
                          ),
                          _StatCard(
                            label: "Avg. Stay",
                            valueText:
                                "${controller.avgStay.value.toStringAsFixed(1)}",
                            unitText: "Nights",
                            deltaText:
                                "+${controller.avgStayDelta.value.toStringAsFixed(1)}",
                            deltaSubText: "",
                            positive: true,
                            icon: Icons.access_time_rounded,

                            iconBg: theme.colorScheme.primary.withOpacity(0.12),
                            iconFg: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Occupancy Trends".tr,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Get.isDarkMode
                                      ? Colors.white
                                      : const Color(0xFF1D2330),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.more_horiz_rounded,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Daily occupancy rate over selected period".tr,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Get.isDarkMode
                                    ? Colors.white54
                                    : const Color(0xFF9AA0AF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          _LineChart(
                            points: controller.occupancyTrend,
                            stroke: theme.colorScheme.primary,
                            dot: theme.colorScheme.primary,
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              _AxisLabel("Week 2"),
                              _AxisLabel("Week 3"),
                              _AxisLabel("Week 4"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Obx(
                    () => _Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Financial Breakdown".tr,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Get.isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF1D2330),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.bar_chart_rounded,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Text(
                                  "\$${controller.netIncome.value.toStringAsFixed(0)}",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Get.isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF1D2330),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Net income".tr,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Get.isDarkMode
                                        ? Colors.white54
                                        : const Color(0xFF9AA0AF),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "+${controller.netIncomeDelta.value.toStringAsFixed(0)}%",
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: const Color(0xFF22C55E),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),

                            _Bars(
                              gross: controller.grossValue.value,
                              net: controller.netValue.value,
                              primary: theme.colorScheme.primary,
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.onExport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: Icon(
                        Icons.download_rounded,
                        size: 18,
                        color: theme.iconTheme.color,
                      ),
                      label: Text(
                        "Export Full Report".tr,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeTabs extends StatelessWidget {
  const _RangeTabs({required this.selected, required this.onTap});

  final AnalyticsRange selected;
  final ValueChanged<AnalyticsRange> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    Widget pill(String text, AnalyticsRange v) {
      final isSel = selected == v;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onTap(v),
          child: Container(
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSel
                  ? theme.colorScheme.primary
                  : (isDark ? theme.cardColor : Colors.white),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSel
                    ? theme.colorScheme.primary
                    : (isDark ? Colors.white24 : const Color(0xFFE6E9F0)),
                width: 1,
              ),
            ),
            child: Text(
              text,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSel
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF1D2330)),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        pill("This Month", AnalyticsRange.thisMonth),
        const SizedBox(width: 10),
        pill("Last 3 Months", AnalyticsRange.last3Months),
        const SizedBox(width: 10),
        pill("Year to Date", AnalyticsRange.ytd),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.valueText,
    required this.deltaSubText,
    required this.positive,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    this.deltaText = "",
    this.unitText,
    this.showDelta = true,
  });

  final String label;
  final String valueText;
  final String deltaText;
  final String deltaSubText;
  final bool positive;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String? unitText;
  final bool showDelta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;
    final deltaColor = positive
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white24 : const Color(0xFFEDEFF5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark ? Colors.white70 : const Color(0xFF9AA0AF),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 16, color: iconFg),
              ),
            ],
          ),
          const Spacer(),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valueText,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF1D2330),
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (unitText != null) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unitText!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark ? Colors.white70 : const Color(0xFF9AA0AF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),

          if (showDelta)
            Row(
              children: [
                Icon(
                  positive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: deltaColor,
                ),
                const SizedBox(width: 4),
                Text(
                  deltaText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: deltaColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    deltaSubText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark ? Colors.white54 : const Color(0xFF9AA0AF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              deltaSubText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? Colors.white54 : const Color(0xFF9AA0AF),
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
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
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).cardColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white24 : const Color(0xFFEDEFF5),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: isDark ? Colors.white54 : const Color(0xFF9AA0AF),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({
    required this.points,
    required this.stroke,
    required this.dot,
  });

  final List<double> points;
  final Color stroke;
  final Color dot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      width: double.infinity,
      child: CustomPaint(
        painter: _LineChartPainter(points: points, stroke: stroke, dot: dot),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.points,
    required this.stroke,
    required this.dot,
  });

  final List<double> points;
  final Color stroke;
  final Color dot;

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = stroke
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintDot = Paint()
      ..color = dot
      ..style = PaintingStyle.fill;

    final baseline = Paint()
      ..color = Get.isDarkMode ? Colors.white24 : const Color(0xFFEDEFF5)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, size.height - 6),
      Offset(size.width, size.height - 6),
      baseline,
    );

    if (points.isEmpty) return;

    final stepX = size.width / (points.length - 1);
    final path = Path();

    for (int i = 0; i < points.length; i++) {
      final x = stepX * i;
      final y = (1 - points[i].clamp(0.0, 1.0)) * (size.height - 16) + 6;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paintLine);

    for (int i = 0; i < points.length; i++) {
      final x = stepX * i;
      final y = (1 - points[i].clamp(0.0, 1.0)) * (size.height - 16) + 6;
      canvas.drawCircle(Offset(x, y), 3.2, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.stroke != stroke ||
        oldDelegate.dot != dot;
  }
}

class _Bars extends StatelessWidget {
  const _Bars({
    required this.gross,
    required this.net,
    required this.primary,
    required this.theme,
  });

  final double gross;
  final double net;
  final Color primary;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final maxV = (gross > net ? gross : net).clamp(1, double.infinity);
    double h(double v) => (v / maxV) * 88;
    final isDark = Get.isDarkMode;

    return SizedBox(
      height: 135,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 110,
            child: _Bar(
              label: "Gross",
              valueLabel: "",
              height: h(gross),
              color: isDark ? Colors.white12 : const Color(0xFFEDEFF5),
              textColor: isDark ? Colors.white70 : const Color(0xFF9AA0AF),
            ),
          ),

          SizedBox(
            width: 110,
            child: _Bar(
              label: "Net",
              valueLabel: "\$4.2k",
              height: h(net),
              color: primary.withOpacity(0.85),
              textColor: primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.valueLabel,
    required this.height,
    required this.color,
    required this.textColor,
  });

  final String label;
  final String valueLabel;
  final double height;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (valueLabel.isNotEmpty)
          Text(
            valueLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        const SizedBox(height: 6),
        Container(
          width: 60,
          height: height.clamp(8, 100),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isDark ? Colors.white54 : const Color(0xFF9AA0AF),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
