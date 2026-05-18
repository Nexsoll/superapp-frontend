import 'package:flutter/material.dart';

class AuthDesktopShell extends StatelessWidget {
  const AuthDesktopShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.logoAsset,
    this.footer,
    this.leading,
    this.heroTitle,
    this.heroSubtitle,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final String? logoAsset;
  final Widget? footer;
  final Widget? leading;
  final String? heroTitle;
  final String? heroSubtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark
        ? const Color(0xFFB7C1CC)
        : const Color(0xFF617080);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B1014)
          : const Color(0xFFF5FAFA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 34,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.apartment_rounded,
                                color: theme.colorScheme.primary,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'IDS EUROPE',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (logoAsset != null) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                logoAsset!,
                                height: 210,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 34),
                          ],
                          Container(
                            width: 64,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(height: 26),
                          Text(
                            heroTitle ??
                                'Stay, invest, and manage with clarity',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF101820),
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            heroSubtitle ??
                                'A focused workspace for bookings, properties, and guest operations.',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: mutedColor,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: const [
                              _HeroChip(
                                icon: Icons.verified_user_outlined,
                                text: 'Secure access',
                              ),
                              _HeroChip(
                                icon: Icons.home_work_outlined,
                                text: 'Properties',
                              ),
                              _HeroChip(
                                icon: Icons.hotel_outlined,
                                text: 'Hotels',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 56),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 470),
                        child: SingleChildScrollView(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 4,
                                height: 136,
                                margin: const EdgeInsets.only(top: 10),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const SizedBox(width: 28),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (leading != null) ...[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: leading!,
                                      ),
                                      const SizedBox(height: 22),
                                    ],
                                    Text(
                                      title,
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: theme.colorScheme.primary,
                                            height: 1.08,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      subtitle,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: mutedColor,
                                            height: 1.45,
                                          ),
                                    ),
                                    const SizedBox(height: 32),
                                    ...children,
                                    if (footer != null) ...[
                                      const SizedBox(height: 18),
                                      footer!,
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFD5DAE1))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFD5DAE1))),
      ],
    );
  }
}
