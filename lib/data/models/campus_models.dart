import 'package:cloud_firestore/cloud_firestore.dart';

import 'request_model.dart';

class StudentUser {
  const StudentUser({
    required this.uid,
    required this.fullName,
    required this.studentId,
    required this.email,
    this.departmentId,
    this.departmentName,
    this.semester,
    this.profileImageUrl,
    this.role = 'student',
    this.isActive = true,
  });

  final String uid;
  final String fullName;
  final String studentId;
  final String email;
  final String? departmentId;
  final String? departmentName;
  final String? semester;
  final String? profileImageUrl;
  final String role;
  final bool isActive;

  String get semesterLabel {
    final value = semester?.trim() ?? '';
    if (value.isEmpty || value == '—') return '—';
    if (value.toLowerCase().contains('semester')) return value;
    return 'Semester $value';
  }

  String get firstName {
    if (fullName.trim().isEmpty) return 'Student';
    return fullName.trim().split(RegExp(r'\s+')).first;
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'S';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory StudentUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return StudentUser.fromMap(doc.id, doc.data() ?? <String, dynamic>{});
  }

  factory StudentUser.fromMap(String id, Map<String, dynamic> data) {
    final departmentName = (data['department'] as String?)?.trim();
    final photo = (data['profileImageUrl'] as String?) ??
        (data['profilePicture'] as String?);

    return StudentUser(
      uid: data['uid'] as String? ?? data['id'] as String? ?? id,
      fullName: data['fullName'] as String? ?? '',
      studentId: data['studentId'] as String? ?? '',
      email: data['email'] as String? ?? '',
      departmentId: data['departmentId'] as String?,
      departmentName:
          departmentName != null && departmentName.isNotEmpty
              ? departmentName
              : null,
      semester: data['semester']?.toString(),
      profileImageUrl: photo != null && photo.isNotEmpty ? photo : null,
      role: data['role'] as String? ?? 'student',
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  factory StudentUser.fallback({
    required String uid,
    required String email,
  }) {
    return StudentUser(
      uid: uid,
      fullName: email.split('@').first,
      studentId: '—',
      email: email,
    );
  }
}

class RequestCategory {
  const RequestCategory({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? description;
  final bool isActive;

  factory RequestCategory.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return RequestCategory(
      id: doc.id,
      name: data['name'] as String? ?? doc.id,
      description: data['description'] as String?,
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}

class AnnouncementPreview {
  const AnnouncementPreview({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.priority,
    this.publishedAt,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String? priority;
  final DateTime? publishedAt;

  factory AnnouncementPreview.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return AnnouncementPreview(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'general',
      priority: data['priority'] as String?,
      publishedAt: parseTimestamp(data['publishedAt'] ?? data['createdAt']),
    );
  }
}
