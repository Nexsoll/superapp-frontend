import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:superapp/screens/all_review_screen.dart';
import 'package:superapp/services/listing_service.dart';

class HotelReviewsSection extends StatelessWidget {
  final List<dynamic> reviews;
  final int? hotelId;
  final int? propertyId;

  const HotelReviewsSection({
    super.key,
    required this.reviews,
    this.hotelId,
    this.propertyId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reviews'.tr,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => AllReviewsScreen(
                    hotelId: hotelId,
                    propertyId: propertyId,
                    initialReviews: reviews,
                  )),
              child: Text('See All'.tr,
                style: TextStyle(
                  color: Color(0xFF2FC1BE),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (reviews.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No reviews yet. Be the first to review!'.tr,
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ...reviews.take(3).map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _ReviewCard(theme, r),
              )),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ThemeData theme;
  final dynamic review;
  const _ReviewCard(this.theme, this.review);

  @override
  Widget build(BuildContext context) {
    final user = review['user'] as Map<String, dynamic>?;
    final firstName = user?['firstName'] ?? 'User';
    final lastName = user?['lastName'] ?? '';
    final avatar = user?['avatar'] as String?;
    final avatarUrl = (avatar != null && avatar.isNotEmpty) 
        ? ListingService.avatarImageUrl(avatar) 
        : null;
    final rating = (review['rating'] as num?)?.toDouble() ?? 0.0;
    final comment = review['comment'] ?? '';
    final date = review['createdAt'] != null ? DateTime.parse(review['createdAt']).toString().split(' ')[0] : '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: const Color(0xFF2FC1BE).withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark ? const Color(0xFF2FC1BE).withOpacity(0.1) : const Color(0xFFDDF4F4),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: avatarUrl != null
                          ? Image.network(
                              avatarUrl,
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/avatar.png',
                                width: 45,
                                height: 45,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/avatar.png',
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$firstName $lastName',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1D2330),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9AA0AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2FC1BE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF9AA0AF),
            ),
          ),
        ],
      ),
    );
  }
}
