class IoTDevice {
  final String id;
  final String name;
  final String location; // Property or Hotel name
  final String status; // 'Urgent', 'Normal', etc.
  final DateTime createdAt;
  final int? propertyId;
  final int? hotelId;

  IoTDevice({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.createdAt,
    this.propertyId,
    this.hotelId,
  });

  factory IoTDevice.fromJson(Map<String, dynamic> json) {
    String loc = json['location'] as String? ?? '';
    if (json['property'] != null) {
      loc = json['property']['title'] as String;
    } else if (json['hotel'] != null) {
      loc = json['hotel']['title'] as String;
    }

    return IoTDevice(
      id: json['id'].toString(),
      name: json['name'] as String,
      location: loc,
      status: json['status'] as String? ?? 'Normal',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      propertyId: json['propertyId'] as int?,
      hotelId: json['hotelId'] as int?,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
