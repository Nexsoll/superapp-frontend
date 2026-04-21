import 'package:get/get.dart';
// job_model.dart

enum JobStatus {
  QUEUED,
  PENDING,
  IN_PROGRESS,
  COMPLETED,
  APPROVED,
  AWAITING_REVIEW,
  REJECTED,
}

enum JobUrgency { URGENT, NORMAL }

class Job {
  final int id;
  final String title;
  final String description;
  final JobUrgency urgency;
  final double? budget;
  final JobStatus status;
  final int ownerId;
  final String? ownerName;
  final String? assigneeName;
  final String? propertyName;
  final String? hotelName;
  final String? beforeImage;
  final String? afterImage;
  final String? rejectionReason;
  final DateTime createdAt;

  const Job({
    required this.id,
    required this.title,
    required this.description,
    required this.urgency,
    this.budget,
    required this.status,
    required this.ownerId,
    this.ownerName,
    this.assigneeName,
    this.propertyName,
    this.hotelName,
    this.beforeImage,
    this.afterImage,
    this.rejectionReason,
    required this.createdAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      urgency: _parseUrgency(json['urgency'] as String?),
      budget: json['budget'] != null
          ? (json['budget'] as num).toDouble()
          : null,
      status: _parseStatus(json['status'] as String?),
      ownerId: (json['ownerId'] as num).toInt(),
      ownerName: json['owner'] != null
          ? json['owner']['firstName'] as String?
          : null,
      assigneeName: () {
        if (json['assignments'] == null ||
            (json['assignments'] as List).isEmpty) {
          return null;
        }
        final firstAssignment = (json['assignments'] as List).first;
        if (firstAssignment == null || firstAssignment['applier'] == null) {
          return null;
        }
        final applier = firstAssignment['applier'];
        return applier['fullName'] as String? ??
            applier['firstName'] as String? ??
            'Staff Member';
      }(),
      propertyName: json['property'] != null
          ? json['property']['title'] as String?
          : null,
      hotelName: json['hotel'] != null
          ? json['hotel']['title'] as String?
          : null,
      beforeImage: json['beforeImage'] as String?,
      afterImage: json['afterImage'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static JobUrgency _parseUrgency(String? value) {
    switch (value) {
      case 'URGENT':
        return JobUrgency.URGENT;
      default:
        return JobUrgency.NORMAL;
    }
  }

  static JobStatus _parseStatus(String? value) {
    switch (value) {
      case 'PENDING':
        return JobStatus.PENDING;
      case 'IN_PROGRESS':
        return JobStatus.IN_PROGRESS;
      case 'COMPLETED':
        return JobStatus.COMPLETED;
      case 'APPROVED':
        return JobStatus.APPROVED;
      case 'AWAITING_REVIEW':
        return JobStatus.AWAITING_REVIEW;
      case 'REJECTED':
        return JobStatus.REJECTED;
      default:
        return JobStatus.QUEUED;
    }
  }

  /// Human-readable time-ago string
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
