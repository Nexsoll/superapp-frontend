import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Assuming we might use SVGs or fallback to Icons

class QCScreen extends StatelessWidget {
  const QCScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? theme.scaffoldBackgroundColor
          : const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quality Control'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Review and approve completed jobs'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF6B7280).withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTabs(isDark),
                  const SizedBox(height: 20),
                  _buildReviewCard(context, isDark),
                  const SizedBox(height: 16),
                  _buildProgressCard(context, isDark),
                  const SizedBox(height: 16),
                  _buildStandardCard(context, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        bottom: 70, // Increased bottom padding to match home header height
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF38CAC7),
            Color(0xFF2DD4BF),
          ], // Teal gradient matching image
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          Expanded(
            child: Center(
              child: Text('Quality Control'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24), // Balance the back arrow
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    return Row(
      children: [
        _buildTabItem('Pending (5)', isActive: true, isDark: isDark),
        const SizedBox(width: 12),
        _buildTabItem('Reviewed', isActive: false, isDark: isDark),
        const SizedBox(width: 12),
        _buildTabItem('Flagged', isActive: false, isDark: isDark),
      ],
    );
  }

  Widget _buildTabItem(
    String label, {
    required bool isActive,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF38CAC7)
            : (isDark ? Colors.white12 : const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive
              ? Colors.white
              : (isDark ? Colors.white60 : const Color(0xFF6B7280)),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFCD34D),
          width: 1.5,
        ), // Yellow border
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            iconBg: null, // Use gradient instead
            iconGradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            iconAsset: 'assets/qc-card.svg',
            title: 'Villa Sunset',
            subtitle: 'Checkout clean',
            statusBg: isDark
                ? const Color(0xFFFEF3C7).withOpacity(0.2)
                : const Color(0xFFFEF3C7),
            statusText: 'Awaiting Review',
            statusTextColor: const Color(0xFFD97706),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildStaffInfo(
            avatarColor: const Color(0xFFEC4899),
            name: 'Ana M.',
            time: 'Completed 35 min ago',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (int i = 0; i < 4; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    child: Center(
                      child: Text('+3'.tr,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white60
                              : const Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Approve'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.white12
                        : const Color(0xFFE5E7EB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Request Redo'.tr,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCardHeader(
            iconBg: null,
            iconGradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF0891B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            iconAsset: 'assets/qc-card.svg',
            title: 'Apartment 204',
            subtitle: 'Deep clean',
            statusBg: isDark
                ? const Color(0xFFDBEAFE).withOpacity(0.2)
                : const Color(0xFFDBEAFE),
            statusText: 'In Progress',
            statusTextColor: const Color(0xFF2563EB),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildStaffInfo(
            avatarGradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF0891B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            name: 'Marko K.',
            time: 'Started 1 hr ago',
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white12 : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progress'.tr,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                    Text('65%'.tr,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF111827),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 8,
                    width: double.infinity,
                    color: isDark ? Colors.grey[700] : Colors.grey[200],
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.65,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF0891B2)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCardHeader(
            iconBg: null,
            iconGradient: const LinearGradient(
              colors: [Color(0xFF34D399), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            iconAsset: 'assets/qc-card.svg',
            title: 'Seaside Villa',
            subtitle: 'Standard turnover',
            statusBg: isDark
                ? const Color(0xFFFEF3C7).withOpacity(0.2)
                : const Color(0xFFFEF3C7),
            statusText: 'Awaiting Review',
            statusTextColor: const Color(0xFFD97706),
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildStaffInfo(
            avatarColor: const Color(0xFFA855F7),
            name: 'Ivana S.',
            time: 'Completed 2 hrs ago',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader({
    Color? iconBg,
    Gradient? iconGradient,
    String? iconAsset,
    required String title,
    required String subtitle,
    required Color statusBg,
    required String statusText,
    required Color statusTextColor,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBg,
            gradient: iconGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: iconAsset != null
              ? Center(
                  child: SvgPicture.asset(
                    iconAsset,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                )
              : const Icon(
                  Icons.apartment_rounded,
                  color: Colors.white,
                  size: 24,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStaffInfo({
    Color? avatarColor,
    Gradient? avatarGradient,
    required String name,
    required String time,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: avatarColor,
            gradient: avatarGradient,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF374151),
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.access_time_rounded,
          size: 16,
          color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
        ),
        const SizedBox(width: 6),
        Text(
          time,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
