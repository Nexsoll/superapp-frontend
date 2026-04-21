import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/staff_controller.dart';
import 'package:superapp/modal/job_model.dart';
import 'package:superapp/screens/admin/job_assignment_screen.dart';
import 'package:superapp/screens/admin/create_job_screen.dart';
import 'package:superapp/screens/admin/community_screen.dart';
import 'package:superapp/screens/admin/photo_review_screen.dart';
import 'package:superapp/widgets/admin_bottom_bar.dart';
import 'package:superapp/screens/admin/qc_screen.dart';
import 'package:superapp/screens/bottomNavScreen/ai_assistant_screen.dart';
import 'package:superapp/screens/admin/iot_diagnostic_screen.dart';
import 'package:superapp/screens/admin/payment_insights_screen.dart';
import 'package:superapp/services/listing_service.dart';
import 'package:superapp/controllers/admin_dashboard_controller.dart';
import 'package:superapp/controllers/iot_controller.dart';
import 'package:intl/intl.dart';

String _normalizeAvatar(String rawUrl) {
  if (rawUrl.trim().isEmpty) return '';
  if (rawUrl.startsWith('https://storage.googleapis.com/')) {
    return ListingService.avatarImageUrl(rawUrl);
  }
  return rawUrl;
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isJobsTab = _currentIndex == 2;
    Get.put(AdminDashboardController());
    Get.put(IoTController());

    return Scaffold(
      backgroundColor: isDark
          ? theme.scaffoldBackgroundColor
          : const Color(0xFFF5F7FA),
      body: _currentIndex == 0
          ? _AdminDashboardBody(
              onSeeAllTasks: () => setState(() => _currentIndex = 2),
            )
          : _currentIndex == 1
          ? const QCScreen()
          : _currentIndex == 2
          ? const JobAssignmentScreen(showAppBar: false)
          : _currentIndex == 3
          ? const PaymentInsightsScreen()
          : _currentIndex == 4
          ? CommunityScreen()
          : _currentIndex == 5
          ? const PhotoReviewScreen()
          : _AdminDashboardBody(
              onSeeAllTasks: () => setState(() => _currentIndex = 2),
            ),
      floatingActionButton: isJobsTab
          ? FloatingActionButton(
              heroTag: 'admin_create_job_fab',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateJobScreen()),
              ),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      bottomNavigationBar: Obx(() {
        final ctrl = Get.find<AdminDashboardController>();
        final iot = Get.find<IoTController>();
        return AdminBottomBar(
          currentIndex: _currentIndex,
          badges: {
            2: ctrl.queuedCount > 0 ? ctrl.queuedCount.toString() : '',
            22: iot.alertCount > 0
                ? iot.alertCount.toString()
                : '', // Just an example, maybe index 6 for photos?
          },
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        );
      }),
    );
  }
}

class _AdminDashboardBody extends StatelessWidget {
  final VoidCallback onSeeAllTasks;
  _AdminDashboardBody({required this.onSeeAllTasks});

  AdminDashboardController get controller =>
      Get.find<AdminDashboardController>();
  IoTController get iotController => Get.find<IoTController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Teal Header with solid bottom
        _buildHeader(context),
        // Refresh Indicator
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => controller.fetchStats(),
            color: const Color(0xFF38CAC7),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Obx(() {
                if (controller.isLoading.value && controller.stats.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: CircularProgressIndicator(
                        color: Color(0xFF38CAC7),
                      ),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Search Bar
                    _buildSearchBar(context, isDark),
                    const SizedBox(height: 20),
                    // Stats Grid
                    _buildStatsGrid(context, isDark),
                    const SizedBox(height: 16),
                    // Action Cards
                    _buildActionCards(context),
                    const SizedBox(height: 30),
                    // Today's Tasks
                    _buildSectionTitle(
                      context,
                      'Today\'s Tasks',
                      isDark,
                      showSeeAll: true,
                      onSeeAll: onSeeAllTasks,
                    ),
                    const SizedBox(height: 16),
                    _buildTodaysTasks(context, isDark),
                    const SizedBox(height: 24),
                    // IoT Diagnostic
                    _buildIoTDiagnosticCard(context, isDark),
                    const SizedBox(height: 16),
                    // Job Assignment White Card
                    _buildJobAssignmentWhiteCard(context, isDark),
                    const SizedBox(height: 24),
                    // Staff Section
                    _buildStaffSection(context, isDark),
                    const SizedBox(height: 30),
                    // Today's Overview
                    _buildSectionTitle(context, 'Today\'s Overview', isDark),
                    const SizedBox(height: 16),
                    _buildTodaysOverview(context, isDark),
                    const SizedBox(height: 50), // Extra padding for bottom
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    bool isDark, {
    bool showSeeAll = false,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (showSeeAll)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('See all'.tr,
              style: TextStyle(
                color: Color(0xFF38CAC7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTodaysTasks(BuildContext context, bool isDark) {
    if (controller.todaysTasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text('No tasks for today'.tr,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      children: controller.todaysTasks.map((job) {
        String subtitle = job.description;
        if (job.assigneeName != null) {
          subtitle = '${job.title} • ${job.assigneeName}';
        } else if (job.propertyName != null) {
          subtitle = '${job.title} • ${job.propertyName}';
        }

        // Map status to color
        Color statusColor = Colors.grey;
        switch (job.status) {
          case JobStatus.QUEUED:
            statusColor = const Color(0xFF3B82F6);
            break;
          case JobStatus.PENDING:
            statusColor = const Color(0xFFF59E0B);
            break;
          case JobStatus.IN_PROGRESS:
            statusColor = const Color(0xFF10B981);
            break;
          default:
            statusColor = Colors.grey;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TaskCard(
            title: job.title,
            subtitle: subtitle,
            time: 'Due ${job.timeAgo}',
            tag: job.urgency == JobUrgency.URGENT ? 'Urgent' : 'Normal',
            tagColor: job.urgency == JobUrgency.URGENT
                ? const Color(0xFFFEF3C7)
                : const Color(0xFFE5E7EB),
            tagTextColor: job.urgency == JobUrgency.URGENT
                ? const Color(0xFFD97706)
                : const Color(0xFF4B5563),
            statusColor: statusColor,
            isDark: isDark,
            cardBgColor: isDark ? Theme.of(context).cardColor : Colors.white,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIoTDiagnosticCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const IoTDiagnosticScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.memory_rounded,
                color: Color(0xFFA855F7),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('IoT Diagnostic'.tr,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Monitor\nconnected devices'.tr,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF6B7280).withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              final count = iotController.alertCount;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: count > 0
                      ? const Color(0xFFFEE2E2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: count == 0
                      ? Border.all(
                          color: isDark
                              ? Colors.white10
                              : const Color(0xFFE5E7EB),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    if (count > 0) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      '$count alerts',
                      style: TextStyle(
                        color: count > 0
                            ? const Color(0xFFEF4444)
                            : (isDark
                                  ? Colors.white38
                                  : const Color(0xFF94A3B8)),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF9CA3AF),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobAssignmentWhiteCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JobAssignmentScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SvgPicture.asset(
                'assets/Ai.svg',
                width: 28,
                height: 28,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF2563EB),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Job Assignment'.tr,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Ai & Manual Assign'.tr,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF6B7280).withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF9CA3AF),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysOverview(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _OverviewRow(
            label: 'Jobs Created',
            value: controller.createdToday.toString(),
            isDark: isDark,
          ),
          Divider(
            height: 32,
            color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
          ),
          _OverviewRow(
            label: 'Jobs Closed',
            value: controller.closedToday.toString(),
            valueColor: const Color(0xFF10B981),
            isDark: isDark,
          ),
          Divider(
            height: 32,
            color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
          ),
          _OverviewRow(
            label: 'Avg. Resolution',
            value: '${controller.avgResolution} hrs',
            valueColor: isDark ? Colors.white : const Color(0xFF1F2937),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        left: 20,
        right: 20,
        bottom: 40, // Increased bottom padding to match image
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF38CAC7), Color(0xFF27B9B6), Color(0xFF119C99)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back'.tr,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text('Admin Dashboard'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
          // Notification Bell with Badge
          GestureDetector(
            onTap: () {
              // Open Notifications Bottom Sheet
              _showNotifications(context, isDark);
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  'assets/bell.png',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
                Obx(() {
                  final count = controller.unreadNotificationsCount;
                  if (count == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: -2,
                    top: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF27B9B6),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          count > 9 ? '9+' : count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context, bool isDark) {
    if (controller.unreadNotificationsCount > 0) {
      controller.markNotificationsAsRead();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Theme.of(context).cardColor : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Notifications'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    final notifications = controller.notifications;
                    if (notifications.isEmpty) {
                      return Center(
                        child: Text('No notifications'.tr,
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final n = notifications[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: n['type'] == 'INFO'
                                ? Colors.blue.withOpacity(0.1)
                                : n['type'] == 'WARNING'
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            child: Icon(
                              Icons.notifications_active,
                              color: n['type'] == 'INFO'
                                  ? Colors.blue
                                  : n['type'] == 'WARNING'
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                          title: Text(
                            n['title'] ?? '',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            n['message'] ?? '',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Get.to(() => AiAssistantScreen()),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                // color: const Color(0xFF38CAC7), // Removed to let SVG gradient show
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/mic.svg',
                  width: 44, // Match container width
                  height: 44, // Match container height
                  fit: BoxFit.cover,
                  // No color filter, let original colors show
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ask anything...'.tr,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('Search tasks, staff, properties'.tr,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF9CA3AF),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF38CAC7).withOpacity(0.2)
                    : const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('AI'.tr,
                style: TextStyle(
                  color: Color(0xFF38CAC7),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // First Row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: controller.queuedCount.toString(),
                label: 'Jobs Queue',
                icon: Icons.assignment_outlined, // Fallback
                iconAsset: 'assets/jobs-admin.svg',
                iconBgColor: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF2563EB),
                valueColor: isDark ? Colors.white : const Color(0xFF111827),
                cardBgColor: isDark ? theme.cardColor : Colors.white,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                value: controller.pendingCount.toString(),
                label: 'Pending',
                icon: Icons.access_time_rounded,
                iconBgColor: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                valueColor: isDark ? Colors.white : const Color(0xFF111827),
                cardBgColor: isDark ? theme.cardColor : Colors.white,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Second Row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: controller.completedCount.toString(),
                label: 'Completed',
                icon: Icons.check_circle_outline_rounded, // Fallback
                iconAsset: 'assets/tick.svg',
                iconBgColor: const Color(0xFFD1FAE5),
                iconColor: const Color(0xFF059669),
                valueColor: const Color(0xFF059669),
                cardBgColor: isDark ? theme.cardColor : Colors.white,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCardWithBadge(
                value: controller.photoReviewCount.toString(),
                label: 'Photo Review',
                icon: Icons.camera_alt_outlined, // Fallback
                iconAsset: 'assets/photo.svg',
                iconBgColor: const Color(0xFFFFEDD5),
                iconColor: const Color(0xFFEA580C),
                valueColor: const Color(0xFFEA580C),
                cardBgColor: isDark ? theme.cardColor : const Color(0xFFFFF7ED),
                badgeText: controller.photoReviewCount > 0
                    ? 'Needs Attention'
                    : 'All Caught Up',
                badgeColor: controller.photoReviewCount > 0
                    ? const Color(0xFFF97316)
                    : const Color(0xFF10B981),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context) {
    final currency = NumberFormat.compactCurrency(
      symbol: '\$',
      decimalDigits: 1,
    );
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JobAssignmentScreen(),
                ),
              );
            },
            child: _ActionCard(
              title: 'Job\nAssignment',
              subtitle: 'AI & Manual assign',
              badgeText: '${controller.queuedCount} unassigned',
              gradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
              icon: Icons.auto_awesome, // Fallback
              iconAsset: 'assets/Ai.svg',
              badgeBgColor: const Color(0xFF60A5FA),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            title: 'Earnings',
            subtitle: 'Track revenue',
            badgeText: '${currency.format(controller.totalEarnings)} total',
            gradient: const [Color(0xFF10B981), Color(0xFF059669)],
            icon: Icons.attach_money_rounded, // Fallback
            iconAsset: 'assets/dollar.svg',
            badgeBgColor: const Color(0xFF34D399),
          ),
        ),
      ],
    );
  }

  // ── Staff Section ──────────────────────────────────────────────────────────

  Widget _buildStaffSection(BuildContext context, bool isDark) {
    final staffCtrl = Get.put(StaffController());
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Staff Members'.tr,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  _showAddStaffSheet(context, staffCtrl, isDark, theme),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_add_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (staffCtrl.isLoading.value) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          if (staffCtrl.staff.isEmpty) {
            return GestureDetector(
              onTap: () =>
                  _showAddStaffSheet(context, staffCtrl, isDark, theme),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 40,
                      color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                    ),
                    const SizedBox(height: 10),
                    Text('No staff yet — tap + to add'.tr,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white38
                            : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: staffCtrl.staff.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final member = staffCtrl.staff[i];
                return GestureDetector(
                  onLongPress: () =>
                      _confirmRemove(context, staffCtrl, member, theme, isDark),
                  child: Container(
                    width: 86,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardColor : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black26
                              : const Color(0x0A000000),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        member.avatar != null && member.avatar!.isNotEmpty
                            ? CircleAvatar(
                                radius: 22,
                                backgroundImage: NetworkImage(
                                  _normalizeAvatar(member.avatar!),
                                ),
                              )
                            : Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  member.initials,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 8),
                        Text(
                          member.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          member.assignment,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
        const SizedBox(height: 6),
        Text('Long-press a member to remove'.tr,
          style: TextStyle(
            color: isDark ? Colors.white30 : const Color(0xFFCBD5E1),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  void _showAddStaffSheet(
    BuildContext context,
    StaffController staffCtrl,
    bool isDark,
    ThemeData theme,
  ) {
    staffCtrl.clearSearch();
    staffCtrl.searchUsers('');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _AddStaffSheet(controller: staffCtrl, isDark: isDark, theme: theme),
    );
  }

  void _confirmRemove(
    BuildContext context,
    StaffController staffCtrl,
    StaffMember member,
    ThemeData theme,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove Staff'.tr,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Remove ${member.displayName} from staff?',
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              staffCtrl.removeStaff(member);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Remove'.tr),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color valueColor;
  final Color cardBgColor;
  final bool isDark;

  final String? iconAsset;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    this.iconAsset,
    required this.iconBgColor,
    required this.iconColor,
    required this.valueColor,
    required this.cardBgColor,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 185,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: iconAsset != null
                ? Center(
                    child: SvgPicture.asset(
                      iconAsset!,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  )
                : Icon(icon, color: iconColor, size: 24),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCardWithBadge extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color valueColor;
  final Color cardBgColor;
  final String badgeText;
  final Color badgeColor;
  final bool isDark;

  final String? iconAsset;

  const _StatCardWithBadge({
    required this.value,
    required this.label,
    required this.icon,
    this.iconAsset,
    required this.iconBgColor,
    required this.iconColor,
    required this.valueColor,
    required this.cardBgColor,
    required this.badgeText,
    required this.badgeColor,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 185,
      padding: const EdgeInsets.all(16), // Reduced padding slightly
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: iconAsset != null
                ? Center(
                    child: SvgPicture.asset(
                      iconAsset!,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  )
                : Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12), // Reduced spacing
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 6), // Reduced spacing
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeText;
  final List<Color> gradient;
  final IconData icon;
  final Color badgeBgColor;

  final String? iconAsset;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.gradient,
    required this.icon,
    this.iconAsset,
    required this.badgeBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: iconAsset != null
                ? Center(
                    child: SvgPicture.asset(
                      iconAsset!,
                      width: 26,
                      height: 26,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 26),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: badgeBgColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final Color statusColor;
  final bool isDark;
  final Color cardBgColor;

  const _TaskCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
    required this.statusColor,
    this.isDark = false,
    this.cardBgColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Fixed height for the task card to ensure consistent spacing
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark
                      ? Colors.white70
                      : const Color(0xFF6B7280).withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    time,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Top Right Tag
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: tagTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Bottom Right Status Circle
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDark;

  const _OverviewRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? Colors.white70
                : const Color(0xFF6B7280).withOpacity(0.9),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color:
                valueColor ?? (isDark ? Colors.white : const Color(0xFF1F2937)),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Add Staff Bottom Sheet widget ─────────────────────────────────────────────

class _AddStaffSheet extends StatefulWidget {
  const _AddStaffSheet({
    required this.controller,
    required this.isDark,
    required this.theme,
  });
  final StaffController controller;
  final bool isDark;
  final ThemeData theme;

  @override
  State<_AddStaffSheet> createState() => _AddStaffSheetState();
}

class _AddStaffSheetState extends State<_AddStaffSheet> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: widget.isDark
              ? widget.theme.scaffoldBackgroundColor
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.white24 : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Add Staff Member'.tr,
                      style: widget.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: widget.isDark
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: widget.isDark
                          ? Colors.white54
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? widget.theme.cardColor
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.white12
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  onChanged: widget.controller.searchUsers,
                  style: TextStyle(
                    color: widget.isDark
                        ? Colors.white
                        : const Color(0xFF1E293B),
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...'.tr,
                    hintStyle: TextStyle(
                      color: widget.isDark
                          ? Colors.white30
                          : const Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: widget.isDark
                          ? Colors.white38
                          : const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    suffixIcon: Obx(
                      () => widget.controller.isSearchingUsers.value
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: widget.theme.colorScheme.primary,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                final users = widget.controller.userSearchResults;
                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 48,
                          color: widget.isDark
                              ? Colors.white24
                              : const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 12),
                        Text('No users found'.tr,
                          style: TextStyle(
                            color: widget.isDark
                                ? Colors.white38
                                : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: widget.isDark
                        ? Colors.white12
                        : const Color(0xFFF1F5F9),
                  ),
                  itemBuilder: (_, i) {
                    final u = users[i];
                    final fn = u['firstName'] as String? ?? '';
                    final ln = u['lastName'] as String? ?? '';
                    final email = u['email'] as String? ?? '';
                    final rawAvatar = u['avatar'] as String? ?? '';
                    final name = '${fn.trim()} ${ln.trim()}'.trim();
                    final initials =
                        '${fn.isNotEmpty ? fn[0].toUpperCase() : ''}${ln.isNotEmpty ? ln[0].toUpperCase() : ''}';

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        Navigator.pop(context);
                        await widget.controller.addStaff(
                          userId: (u['id'] as num).toInt(),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 4,
                        ),
                        child: Row(
                          children: [
                            rawAvatar.isNotEmpty
                                ? CircleAvatar(
                                    radius: 22,
                                    backgroundImage: NetworkImage(
                                      _normalizeAvatar(rawAvatar),
                                    ),
                                  )
                                : Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: widget.theme.colorScheme.primary
                                          .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      initials.isNotEmpty ? initials : '?',
                                      style: TextStyle(
                                        color: widget.theme.colorScheme.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.isNotEmpty ? name : email,
                                    style: widget.theme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: widget.isDark
                                              ? Colors.white
                                              : const Color(0xFF1E293B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    email,
                                    style: widget.theme.textTheme.bodySmall
                                        ?.copyWith(
                                          color: widget.isDark
                                              ? Colors.white54
                                              : const Color(0xFF94A3B8),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: widget.theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('Add'.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
