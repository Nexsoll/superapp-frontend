enum ExpenseTrackingFilter { all, maintenance, utilities, tax, other }

class ExpenseTrackingModal {
  final int id;
  final String title;
  final String place;
  final String dateText;
  final double amount;
  final ExpenseTrackingFilter category;
  final String? description;

  const ExpenseTrackingModal({
    this.id = 0,
    required this.title,
    required this.place,
    required this.dateText,
    required this.amount,
    required this.category,
    this.description,
  });

  factory ExpenseTrackingModal.fromJson(Map<String, dynamic> json) {
    // Parse category from backend enum
    ExpenseTrackingFilter category = ExpenseTrackingFilter.other;
    final categoryStr = json['category'] as String?;
    if (categoryStr != null) {
      switch (categoryStr.toUpperCase()) {
        case 'MAINTENANCE':
          category = ExpenseTrackingFilter.maintenance;
          break;
        case 'UTILITIES':
          category = ExpenseTrackingFilter.utilities;
          break;
        case 'TAX':
          category = ExpenseTrackingFilter.tax;
          break;
        default:
          category = ExpenseTrackingFilter.other;
      }
    }

    // Parse date
    String dateText = '';
    final dateStr = json['date'] as String?;
    if (dateStr != null) {
      try {
        final date = DateTime.parse(dateStr);
        dateText = "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}";
      } catch (_) {
        dateText = dateStr;
      }
    }

    // Parse property/place
    String place = 'N/A';
    if (json['property'] != null && json['property'] is Map) {
      place = json['property']['title'] ?? 'N/A';
    } else if (json['hotel'] != null && json['hotel'] is Map) {
      place = json['hotel']['title'] ?? 'N/A';
    }

    return ExpenseTrackingModal(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      place: place,
      dateText: dateText,
      amount: -(double.tryParse(json['amount']?.toString() ?? '0') ?? 0),
      category: category,
      description: json['description'],
    );
  }
}
