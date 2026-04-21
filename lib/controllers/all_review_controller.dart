import 'package:get/get.dart';
import 'package:superapp/modal/all_review_modal.dart';
import 'package:superapp/services/listing_service.dart';

class AllReviewsController extends GetxController {
  final int? hotelId;
  final int? propertyId;
  final List<dynamic>? initialReviews;

  AllReviewsController({this.hotelId, this.propertyId, this.initialReviews});

  final RxInt selectedFilter = 0.obs;

  final List<ReviewFilter> filters = const [
    ReviewFilter(label: 'All', stars: null),
    ReviewFilter(label: '5', stars: 5),
    ReviewFilter(label: '4', stars: 4),
    ReviewFilter(label: '3', stars: 3),
    ReviewFilter(label: '2', stars: 2),
  ];

  final RxList<AllReviewItem> allReviews = <AllReviewItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (initialReviews != null) {
      allReviews.value = initialReviews!.map((r) {
        final user = r['user'] as Map<String, dynamic>?;
        final firstName = user?['firstName'] ?? 'User';
        final lastName = user?['lastName'] ?? '';
        final avatar = user?['avatar'] as String?;
        final avatarUrl = (avatar != null && avatar.isNotEmpty) 
            ? ListingService.avatarImageUrl(avatar) 
            : null;
        return AllReviewItem(
          initials: (firstName.isNotEmpty ? firstName[0] : '') + (lastName.isNotEmpty ? lastName[0] : ''),
          name: '$firstName $lastName',
          role: 'Guest',
          stars: (r['rating'] as num?)?.toInt() ?? 0,
          text: r['comment'] ?? '',
          avatarUrl: avatarUrl,
        );
      }).toList();
    }
  }

  void onFilterTap(int index) => selectedFilter.value = index;

  List<AllReviewItem> get filteredReviews {
    final f = filters[selectedFilter.value];
    if (f.stars == null) return allReviews;
    return allReviews.where((r) => r.stars == f.stars).toList();
  }
}

class ReviewFilter {
  final String label;
  final int? stars;
  const ReviewFilter({required this.label, required this.stars});
}
