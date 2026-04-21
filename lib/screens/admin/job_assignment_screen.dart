import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/job_assignment_controller.dart';
import 'package:superapp/modal/job_model.dart';
import 'package:superapp/screens/admin/create_job_screen.dart';
import 'package:superapp/services/listing_service.dart';

String _normalizeAvatar(String rawUrl) {
  if (rawUrl.trim().isEmpty) return '';
  if (rawUrl.startsWith('https://storage.googleapis.com/')) {
    return ListingService.avatarImageUrl(rawUrl);
  }
  return rawUrl;
}

class JobAssignmentScreen extends StatelessWidget {
  const JobAssignmentScreen({super.key, this.showAppBar = true});

  /// When false the back-button header is hidden.
  /// Use this when the screen is embedded inside another scaffold
  /// (e.g. AdminDashboardScreen) that already provides navigation chrome.
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JobAssignmentController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Only show standalone FAB when used as an independent route
      floatingActionButton: showAppBar
          ? FloatingActionButton(
              heroTag: 'create_job_fab',
              onPressed: () async {
                await Get.to(() => const CreateJobScreen());
              },
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: theme.colorScheme.primary,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          // Back button only on standalone route
                          if (showAppBar)
                            IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(Icons.arrow_back),
                              color: Colors.white,
                            )
                          else
                            const SizedBox(width: 16),
                          Expanded(
                            child: Center(
                              child: Text('Jobs'.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          // Refresh button
                          Obx(
                            () => IconButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.fetchJobs,
                              icon: const Icon(Icons.refresh_rounded),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Tab bar ────────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Obx(() {
                        final tabs = ['All', 'Queued', 'In Progress', 'Done'];
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(tabs.length, (i) {
                              final selected =
                                  controller.selectedTab.value == i;
                              return GestureDetector(
                                onTap: () => controller.onTabTap(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: EdgeInsets.only(
                                    right: i < tabs.length - 1 ? 8 : 0,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    tabs[i],
                                    style: TextStyle(
                                      color: selected
                                          ? theme.colorScheme.primary
                                          : Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  );
                }

                final items = controller.filteredJobs;

                if (items.isEmpty) {
                  return _EmptyState(theme: theme);
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchJobs,
                  color: theme.colorScheme.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _JobCard(job: items[i], controller: controller),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline_rounded,
              size: 36,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text('No jobs found'.tr,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text('Tap + to create a new job'.tr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Job card ───────────────────────────────────────────────────────────────────

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.controller});
  final Job job;
  final JobAssignmentController controller;
  void _confirmDelete(BuildContext context, ThemeData theme, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? theme.cardColor : Colors.white,
        title: Text('Delete Job'.tr,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${job.title}"?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr,
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade500,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              controller.deleteJob(job);
            },
            child: Text('Delete'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isUrgent = job.urgency == JobUrgency.URGENT;

    final urgentBg = isDark
        ? const Color(0xFFEF4444).withOpacity(0.15)
        : const Color(0xFFFEE2E2);
    final urgentFg = const Color(0xFFEF4444);

    final normalBg = isDark
        ? theme.colorScheme.primary.withOpacity(0.15)
        : const Color(0xFFE6F7F7);
    final normalFg = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : const Color(0x08000000),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isUrgent ? urgentBg : normalBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isUrgent
                      ? Icons.local_fire_department_rounded
                      : Icons.work_outline_rounded,
                  color: isUrgent ? urgentFg : normalFg,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          job.timeAgo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (job.ownerName != null) ...[
                          Text('•'.tr,
                            style: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                          Text(
                            job.ownerName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (job.assigneeName != null &&
                            job.status != JobStatus.QUEUED) ...[
                          Text('→'.tr,
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                          const Icon(
                            Icons.person_pin_circle_rounded,
                            size: 14,
                            color: Color(0xFF38CAC7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job.assigneeName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? const Color(0xFF38CAC7)
                                  : const Color(0xFF27B9B6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _UrgencyChip(isUrgent: isUrgent, isDark: isDark),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _confirmDelete(context, theme, isDark),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red.shade400,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Description ───────────────────────────────────────────────────
          Text(
            job.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
              fontWeight: FontWeight.w400,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 12),

          // ── Footer row ────────────────────────────────────────────────────
          Row(
            children: [
              if (job.budget != null) ...[
                Icon(Icons.attach_money_rounded, size: 14, color: normalFg),
                Text(
                  '${job.budget!.toStringAsFixed(0)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: normalFg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              _StatusChip(status: job.status, isDark: isDark),
              const Spacer(),
              _ActionButton(job: job, controller: controller, theme: theme),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Urgency chip ──────────────────────────────────────────────────────────────

class _UrgencyChip extends StatelessWidget {
  const _UrgencyChip({required this.isUrgent, required this.isDark});
  final bool isUrgent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isUrgent
        ? (isDark
              ? const Color(0xFFEF4444).withOpacity(0.2)
              : const Color(0xFFFEE2E2))
        : (isDark ? Colors.white10 : const Color(0xFFF1F5F9));
    final fg = isUrgent ? const Color(0xFFEF4444) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        isUrgent ? 'Urgent' : 'Normal',
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.isDark});
  final JobStatus status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color fg;

    switch (status) {
      case JobStatus.PENDING:
        label = 'Assigned';
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

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.job,
    required this.controller,
    required this.theme,
  });
  final Job job;
  final JobAssignmentController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    switch (job.status) {
      case JobStatus.QUEUED:
        return _SmallButton(
          label: 'Assign',
          color: theme.colorScheme.primary,
          onTap: () => _showAssignOptions(context),
        );
      case JobStatus.IN_PROGRESS:
        // Maybe "View Details" or "Track"?
        return const SizedBox.shrink();
      case JobStatus.COMPLETED:
        return _SmallButton(
          label: 'Approve',
          color: const Color(0xFF8B5CF6),
          onTap: () => controller.approveJob(job),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showAssignOptions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? theme.cardColor : Colors.white,
        title: Text('Assignment Method'.tr,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text('How would you like to assign this job?'.tr,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38CAC7),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            icon: const Icon(Icons.person_search_rounded, size: 18),
            label: Text('Manual'.tr),
            onPressed: () {
              Navigator.pop(context);
              controller.clearUserSearch();
              controller.searchUsers('');
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) =>
                    _AssignUserSheet(job: job, controller: controller),
              );
            },
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: Text('AI Auto-Assign'.tr),
            onPressed: () {
              Navigator.pop(context);
              controller.autoAssignJob(job);
            },
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

// ── Assign user bottom sheet ──────────────────────────────────────────────────

class _AssignUserSheet extends StatefulWidget {
  const _AssignUserSheet({required this.job, required this.controller});
  final Job job;
  final JobAssignmentController controller;

  @override
  State<_AssignUserSheet> createState() => _AssignUserSheetState();
}

class _AssignUserSheetState extends State<_AssignUserSheet> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.controller.searchUsers(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Handle ─────────────────────────────────────────────────────
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 16),

              // ── Title ──────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Assign Job'.tr,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.job.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Search bar ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearch,
                    autofocus: true,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by name or email...'.tr,
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.white30
                            : const Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: isDark
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
                                    color: theme.colorScheme.primary,
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

              // ── User list ──────────────────────────────────────────────────
              Expanded(
                child: Obx(() {
                  final users = widget.controller.userResults;
                  final isLoading = widget.controller.isSearchingUsers.value;

                  if (isLoading && users.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                        strokeWidth: 2,
                      ),
                    );
                  }

                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_search_rounded,
                            size: 48,
                            color: isDark
                                ? Colors.white24
                                : const Color(0xFFCBD5E1),
                          ),
                          const SizedBox(height: 12),
                          Text('No users found'.tr,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
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
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDark ? Colors.white12 : const Color(0xFFF1F5F9),
                    ),
                    itemBuilder: (_, i) => _UserTile(
                      user: users[i],
                      isDark: isDark,
                      theme: theme,
                      onAssign: () async {
                        Navigator.pop(context);
                        await widget.controller.assignJobToUser(
                          widget.job,
                          users[i],
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── User tile ─────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isDark,
    required this.theme,
    required this.onAssign,
  });

  final AppUser user;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onAssign,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            // Avatar
            user.avatar != null && user.avatar!.isNotEmpty
                ? CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                      _normalizeAvatar(user.avatar!),
                    ),
                  )
                : Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      user.initials,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
            const SizedBox(width: 12),
            // Name + email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Assign chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Assign'.tr,
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
  }
}
