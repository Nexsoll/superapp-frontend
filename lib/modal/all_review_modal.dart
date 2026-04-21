class AllReviewItem {
  final String initials;
  final String name;
  final String role;
  final int stars;
  final String text;
  final String? avatarUrl;

  const AllReviewItem({
    required this.initials,
    required this.name,
    required this.role,
    required this.stars,
    required this.text,
    this.avatarUrl,
  });
}
