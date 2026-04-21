import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/staff_dashboard_controller.dart';
import 'package:superapp/screens/admin/community_screen.dart';
import 'package:superapp/modal/job_model.dart';
import 'package:superapp/screens/staff/job_completion_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  int _currentIndex = 0;
  final controller = Get.put(StaffDashboardController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? theme.scaffoldBackgroundColor
          : const Color(0xFFF5F7FA),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _StaffJobsTab(controller: controller),
          CommunityScreen(),
          _StaffEarningsTab(controller: controller),
        ],
      ),
      bottomNavigationBar: _StaffBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _StaffJobsTab extends StatelessWidget {
  const _StaffJobsTab({required this.controller});
  final StaffDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildHeader(context, 'Assigned Jobs'),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingJobs.value && controller.jobs.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.jobs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_late_outlined,
                      size: 64,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text('No jobs assigned to you yet'.tr,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: controller.fetchJobs,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                itemCount: controller.jobs.length,
                itemBuilder: (context, index) {
                  return _StaffJobCard(
                    job: controller.jobs[index],
                    controller: controller,
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF38CAC7), Color(0xFF27B9B6), Color(0xFF119C99)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StaffJobCard extends StatelessWidget {
  const _StaffJobCard({required this.job, required this.controller});
  final Job job;
  final StaffDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusBadge(status: job.status, isDark: isDark),
              Text(
                '\$${job.budget?.toStringAsFixed(0) ?? '0'}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            job.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (job.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              job.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Divider(color: Colors.grey.withOpacity(0.1)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.person_pin_circle_outlined,
                size: 16,
                color: Color(0xFF38CAC7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Owner: ${job.ownerName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (job.propertyName != null || job.hotelName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF38CAC7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.propertyName ?? job.hotelName ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF38CAC7),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          if (job.status == JobStatus.PENDING)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.rejectJob(job),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Reject'.tr,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.acceptJob(job),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38CAC7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Accept'.tr,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            )
          else if (job.status == JobStatus.IN_PROGRESS ||
              job.status == JobStatus.REJECTED)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(() => JobCompletionScreen(job: job)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: job.status == JobStatus.REJECTED
                      ? Colors.red
                      : const Color(0xFF38CAC7),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  job.status == JobStatus.REJECTED
                      ? 'Rejected - Update Status'
                      : 'Update Status',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            )
          else if (job.status == JobStatus.AWAITING_REVIEW)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('Awaiting Review'.tr,
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StaffEarningsTab extends StatelessWidget {
  const _StaffEarningsTab({required this.controller});
  final StaffDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context, 'My Earnings'),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingEarnings.value &&
                controller.completedJobs.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return RefreshIndicator(
              onRefresh: controller.fetchEarnings,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                children: [
                  _buildEarningsSummary(context),
                  const SizedBox(height: 24),
                  Text('Payment History'.tr,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  if (controller.completedJobs.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text('No completed jobs yet'.tr,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...controller.completedJobs
                        .map((j) => _buildEarningsTile(context, j))
                        .toList(),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF38CAC7), Color(0xFF27B9B6), Color(0xFF119C99)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEarningsSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Total Balance'.tr,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            '\$${controller.earnings.value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryStat(
                'Completed',
                '${controller.completedJobsCount.value}',
              ),
              Container(width: 1, height: 40, color: Colors.white10),
              _buildSummaryStat(
                'Avg. Job',
                '\$${(controller.earnings.value / (controller.completedJobsCount.value > 0 ? controller.completedJobsCount.value : 1)).toStringAsFixed(0)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEarningsTile(BuildContext context, Map<String, dynamic> job) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF059669),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title'] ?? 'Job',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Completed'.tr,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '+\$${(job['budget'] as num?)?.toStringAsFixed(0) ?? '0'}',
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.isDark});
  final JobStatus status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color fg;

    switch (status) {
      case JobStatus.PENDING:
        label = 'New Request';
        bg = isDark ? Colors.blue.withOpacity(0.2) : const Color(0xFFDBEAFE);
        fg = Colors.blue;
        break;
      case JobStatus.IN_PROGRESS:
        label = 'In Progress';
        bg = isDark
            ? const Color(0xFFF59E0B).withOpacity(0.2)
            : const Color(0xFFFEF3C7);
        fg = const Color(0xFFF59E0B);
        break;
      case JobStatus.COMPLETED:
        label = 'Completed';
        bg = isDark
            ? const Color(0xFF10B981).withOpacity(0.2)
            : const Color(0xFFD1FAE5);
        fg = const Color(0xFF10B981);
        break;
      case JobStatus.APPROVED:
        label = 'Approved';
        bg = isDark
            ? const Color(0xFF8B5CF6).withOpacity(0.2)
            : const Color(0xFFF3E8FF);
        fg = const Color(0xFF8B5CF6);
        break;
      case JobStatus.QUEUED:
        label = 'Queued';
        bg = isDark ? Colors.white10 : const Color(0xFFF1F5F9);
        fg = isDark ? Colors.white54 : const Color(0xFF64748B);
        break;
      case JobStatus.AWAITING_REVIEW:
        label = 'Reviewing';
        bg = isDark
            ? Colors.blue.withOpacity(0.2)
            : Colors.blue.withOpacity(0.1);
        fg = Colors.blue;
        break;
      case JobStatus.REJECTED:
        label = 'Rejected';
        bg = isDark ? Colors.red.withOpacity(0.2) : Colors.red.withOpacity(0.1);
        fg = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StaffBottomBar extends StatelessWidget {
  const _StaffBottomBar({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.assignment_rounded,
                label: 'Jobs',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.people_rounded,
                label: 'Community',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Earnings',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF38CAC7);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? activeColor : Colors.grey, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
