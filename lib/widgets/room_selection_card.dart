import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoomSelectionCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String size;
  final String bedType;
  final String guests;
  final String price;
  final List<String> amenities;
  final int? matchPercentage;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const RoomSelectionCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.size,
    required this.bedType,
    required this.guests,
    required this.price,
    required this.amenities,
    this.matchPercentage,
    this.quantity = 0,
    required this.onAdd,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2FC1BE).withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  imagePath,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                if (matchPercentage != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECD76),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$matchPercentage% Match',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white70
                          : const Color(0xFF878787),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _IconText(
                        icon: Icon(
                          Icons.crop_free,
                          size: 17.5,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white70
                              : const Color(0xFF5A606A),
                        ),
                        text: size,
                      ),
                      _IconText(
                        icon: SvgPicture.asset(
                          'assets/bed.svg',
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(
                            theme.brightness == Brightness.dark
                                ? Colors.white70
                                : const Color(0xFF6B7280),
                            BlendMode.srcIn,
                          ),
                        ),
                        text: bedType,
                      ),
                      _IconText(
                        icon: SvgPicture.asset(
                          'assets/guests.svg',
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(
                            theme.brightness == Brightness.dark
                                ? Colors.white70
                                : const Color(0xFF6B7280),
                            BlendMode.srcIn,
                          ),
                        ),
                        text: guests,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: amenities
                        .map((e) => _AmenityTag(text: e))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white24
                        : const Color(0xFFE0E0E0),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price per night'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white70
                                  : const Color(0xFF878787),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$$price',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2FC1BE), // Primary color
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _QuantityButton(icon: Icons.remove, onTap: onRemove),
                          const SizedBox(width: 14),
                          Text(
                            '$quantity',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(width: 14),
                          _QuantityButton(icon: Icons.add, onTap: onAdd),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  final Widget icon;
  final String text;

  const _IconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        icon,
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: theme.brightness == Brightness.dark
                ? Colors.white70
                : const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AmenityTag extends StatelessWidget {
  final String text;

  const _AmenityTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(
          0xFF2FC1BE,
        ).withOpacity(0.83), // Primary color with opacity
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2FC1BE).withOpacity(0.2)
              : const Color(0xFFDFF9F8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF2FC1BE)),
      ),
    );
  }
}
