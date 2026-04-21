import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 250,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0.02, 0.49, 1.0],
                    colors: [
                      Color(0xFF38CAC7),
                      Color(0xFF27B9B6),
                      Color(0xFF119C99),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Profile'.tr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Obx(() {
                            final url = controller.photoUrl.value;
                            return Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: url.isNotEmpty
                                    ? Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Image.asset(
                                              'assets/avatar.png',
                                              fit: BoxFit.cover,
                                            ),
                                      )
                                    : Image.asset(
                                        'assets/avatar.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            );
                          }),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(
                                  () => Text(
                                    controller.username.value,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Obx(
                                  () => Text(
                                    controller.email.value,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withOpacity(0.85),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 16,
                right: 16,
                bottom: -40,
                child: SizedBox(
                  height: 82,
                  child: Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _StatCard(
                            value: controller.bookings.value,
                            label: 'Bookings',
                            primary: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(
                          () => _StatCard(
                            value: controller.reviews.value,
                            label: 'Reviews',
                            primary: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(
                          () => _StatCard(
                            value: controller.points.value,
                            label: 'Points',
                            primary: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 42),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              children: [
                _SectionTitle(title: 'Account', theme: theme),
                const SizedBox(height: 8),
                _CardGroup(
                  children: [
                    _MenuTile(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      onTap: controller.onEditProfile,
                    ),
                    _MenuTile(
                      icon: Icons.verified_user_outlined,
                      title: 'Identity Verification',
                      trailing: const _Pending(
                        text: 'Pending',
                        bg: Color(0xFFFFF3D6),
                        fg: Color(0xFFF59E0B),
                      ),
                      onTap: controller.onIdentity,
                    ),
                    _MenuTile(
                      icon: Icons.tune_rounded,
                      title: 'Preferences',
                      onTap: controller.onPreferences,
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                _SectionTitle(title: 'Wallet & Payments', theme: theme),
                const SizedBox(height: 14),
                _CardGroup(
                  children: [
                    _MenuTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'My Wallet',
                      onTap: controller.onMyWallet,
                    ),
                    _MenuTile(
                      icon: Icons.credit_card_outlined,
                      title: 'Payment Methods',
                      onTap: controller.onPaymentMethods,
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                _SectionTitle(title: 'Notifications & Settings', theme: theme),
                const SizedBox(height: 14),
                _CardGroup(
                  children: [
                    _MenuTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      onTap: controller.onNotifications,
                    ),
                    _MenuTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Security Settings',
                      onTap: controller.onSecurity,
                    ),

                    Obx(
                      () => _SwitchMenuTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        value: controller.isDark.value,
                        onChanged: controller.toggleTheme,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                _SectionTitle(title: 'Support', theme: theme),
                const SizedBox(height: 14),
                _CardGroup(
                  children: [
                    _MenuTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help Center',
                      onTap: controller.onHelpCenter,
                    ),
                    _MenuTile(
                      icon: Icons.policy_outlined,
                      title: 'Term & Policy',
                      onTap: controller.onTermPolicy,
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                _SectionTitle(title: 'Admin', theme: theme),
                const SizedBox(height: 14),
                _CardGroup(
                  children: [
                    _MenuTile(
                      icon: Icons.dashboard_rounded,
                      title: 'Admin Dashboard',
                      onTap: controller.onAdminDashboard,
                    ),
                    _MenuTile(
                      icon: Icons.assignment_outlined,
                      title: 'Staff Dashboard',
                      onTap: controller.onStaffDashboard,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _CardGroup(
                  children: [
                    _MenuTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      titleColor: const Color(0xFFEF4444),
                      iconColor: const Color(0xFFEF4444),
                      onTap: controller.onLogout,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchMenuTile extends StatelessWidget {
  const _SwitchMenuTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final effectiveBg = primary.withOpacity(0.10);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: effectiveBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.primary,
  });

  final int value;
  final String label;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: theme.textTheme.titleLarge?.copyWith(
              color: primary,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF9AA0AF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.theme});

  final String title;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: const Color(0xFF9AA0AF),
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    );
  }
}

class _CardGroup extends StatelessWidget {
  const _CardGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white10
                    : const Color(0xFFF2F2F2),
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.titleColor,
    this.iconColor,
  });

  final IconData? icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? titleColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final effectiveBg = (iconColor ?? primary).withOpacity(0.10);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: effectiveBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon ?? Icons.circle,
                size: 18,
                color: iconColor ?? primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: titleColor ?? theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA0AF)),
          ],
        ),
      ),
    );
  }
}

class _Pending extends StatelessWidget {
  const _Pending({required this.text, required this.bg, required this.fg});

  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          fontFamily: 'Inter',
        ).copyWith(color: fg),
      ),
    );
  }
}
