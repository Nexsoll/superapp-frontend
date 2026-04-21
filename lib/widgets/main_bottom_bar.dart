import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isPropertySelected;

  const MainBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isPropertySelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const inactiveColor = Color(0xFFCFD6DC);

    final items = <({String label, String assetPath})>[
      (label: 'Home', assetPath: 'assets/bottombar1.svg'),
      (label: 'Explore', assetPath: 'assets/bottombar2.svg'),
      if (isPropertySelected) ...[
        (label: 'Dashboard', assetPath: 'assets/dashboard.svg'),
        (label: 'Messages', assetPath: 'assets/chat.svg'),
      ] else ...[
        (label: 'Bookings', assetPath: 'assets/bottombar3.svg'),
        (label: 'AI', assetPath: 'assets/bottombar4.svg'),
      ],
      (label: 'Profile', assetPath: 'assets/bottombar5.svg'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? theme.cardColor : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == currentIndex;
              final iconColor = selected ? Colors.white : inactiveColor;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        bottom: selected ? 40 : 20,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedScale(
                              duration: const Duration(milliseconds: 300),
                              scale: selected ? 1.1 : 1.0,
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  item.assetPath,
                                  width: 24,
                                  height: 24,
                                  colorFilter: ColorFilter.mode(
                                    iconColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: selected ? 1.0 : 0.0,
                          child: Text(
                            item.label,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
