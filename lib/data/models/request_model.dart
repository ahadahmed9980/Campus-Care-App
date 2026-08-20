import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

DateTime? parseTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

enum RequestStatus {
  submitted,
  underReview,
  inProgress,
  resolved,
  rejected;

  String get firestoreValue {
    switch (this) {
      case RequestStatus.submitted:
        return 'submitted';
      case RequestStatus.underReview:
        return 'under_review';
      case RequestStatus.inProgress:
        return 'in_progress';
      case RequestStatus.resolved:
        return 'resolved';
      case RequestStatus.rejected:
        return 'rejected';
    }
  }

  String get label {
    switch (this) {
      case RequestStatus.submitted:
        return 'Submitted';
      case RequestStatus.underReview:
        return 'Under Review';
      case RequestStatus.inProgress:
        return 'In Progress';
      case RequestStatus.resolved:
        return 'Resolved';
      case RequestStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case RequestStatus.submitted:
        return AppColors.open;
      case RequestStatus.underReview:
        return AppColors.underReview;
      case RequestStatus.inProgress:
        return AppColors.inProgress;
      case RequestStatus.resolved:
        return AppColors.resolved;
      case RequestStatus.rejected:
        return AppColors.rejected;
    }
  }

  bool get isOpen =>
      this == RequestStatus.submitted || this == RequestStatus.underReview;

  bool get isActive => isOpen || this == RequestStatus.inProgress;

  static RequestStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'under_review':
      case 'underreview':
      case 'under review':
        return RequestStatus.underReview;
      case 'in_progress':
      case 'inprogress':
      case 'in progress':
        return RequestStatus.inProgress;
      case 'resolved':
        return RequestStatus.resolved;
      case 'rejected':
        return RequestStatus.rejected;
      default:
        return RequestStatus.submitted;
    }
  }
}

enum RequestPriority {
  low,
  medium,
  high;

  String get firestoreValue => name;

  String get label {
    switch (this) {
      case RequestPriority.low:
        return 'Low';
      case RequestPriority.medium:
        return 'Medium';
      case RequestPriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case RequestPriority.low:
        return AppColors.lowPriority;
      case RequestPriority.medium:
        return AppColors.mediumPriority;
      case RequestPriority.high:
        return AppColors.highPriority;
    }
  }

  static RequestPriority fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'low':
        return RequestPriority.low;
      case 'high':
        return RequestPriority.high;
      default:
        return RequestPriority.medium;
    }
  }
}

class CampusRequest {
  const CampusRequest({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.location,
    required this.priority,
    required this.imageUrls,
    required this.status,
    this.assignedDepartmentId,
    this.resolutionInfo,
    this.resolvedBy,
    this.resolvedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String description;
  final String categoryId;
  final String location;
  final RequestPriority priority;
  final List<String> imageUrls;
  final RequestStatus status;
  final String? assignedDepartmentId;
  final String? resolutionInfo;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayId {
    final suffix = id.length >= 4 ? id.substring(0, 4).toUpperCase() : id.toUpperCase();
    final year = createdAt?.year ?? DateTime.now().year;
    return 'REQ-$year-$suffix';
  }

  factory CampusRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return CampusRequest.fromMap(doc.id, data);
  }

  factory CampusRequest.fromMap(String id, Map<String, dynamic> data) {
    return CampusRequest(
      id: id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      location: data['location'] as String? ?? '',
      priority: RequestPriority.fromString(data['priority'] as String?),
      imageUrls: (data['imageUrls'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList(),
      status: RequestStatus.fromString(data['status'] as String?),
      assignedDepartmentId: data['assignedDepartmentId'] as String?,
      resolutionInfo: data['resolutionInfo'] as String?,
      resolvedBy: data['resolvedBy'] as String?,
      resolvedAt: parseTimestamp(data['resolvedAt']),
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }
}

class StatusHistoryEntry {
  const StatusHistoryEntry({
    required this.id,
    required this.status,
    required this.message,
    required this.changedBy,
    required this.changedByRole,
    this.createdAt,
  });

  final String id;
  final RequestStatus status;
  final String message;
  final String changedBy;
  final String changedByRole;
  final DateTime? createdAt;

  factory StatusHistoryEntry.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return StatusHistoryEntry(
      id: doc.id,
      status: RequestStatus.fromString(data['status'] as String?),
      message: data['message'] as String? ?? '',
      changedBy: data['changedBy'] as String? ?? '',
      changedByRole: data['changedByRole'] as String? ?? '',
      createdAt: parseTimestamp(data['createdAt']),
    );
  }
}
