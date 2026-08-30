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
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.imageUrl,
    this.isPublished = true,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String? priority;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final String? imageUrl;
  final bool isPublished;

  factory AnnouncementPreview.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return AnnouncementPreview(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'General',
      priority: data['priority'] as String?,
      publishedAt: parseTimestamp(data['publishedAt'] ?? data['createdAt']),
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
      expiresAt: parseTimestamp(data['expiresAt']),
      imageUrl: data['imageUrl'] as String?,
      isPublished: data['isPublished'] as bool? ?? true,
    );
  }
}

class ContactInfo {
  final String email;
  final String phone;
  final String website;

  const ContactInfo({
    required this.email,
    required this.phone,
    required this.website,
  });

  factory ContactInfo.fromMap(Map<String, dynamic> map) {
    return ContactInfo(
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      website: map['website'] as String? ?? '',
    );
  }
}

class LocationInfo {
  final String building;
  final String floor;
  final String room;

  const LocationInfo({
    required this.building,
    required this.floor,
    required this.room,
  });

  String get formatted {
    final parts = <String>[];
    if (building.isNotEmpty) parts.add(building);
    if (floor.isNotEmpty) parts.add('$floor Floor');
    if (room.isNotEmpty) parts.add('Room $room');
    return parts.isEmpty ? '—' : parts.join(' - ');
  }

  factory LocationInfo.fromMap(Map<String, dynamic> map) {
    return LocationInfo(
      building: map['building'] as String? ?? '',
      floor: map['floor'] as String? ?? '',
      room: map['room'] as String? ?? '',
    );
  }
}

class TimeSlot {
  final String? open;
  final String? close;
  final bool isOpen;

  const TimeSlot({
    this.open,
    this.close,
    required this.isOpen,
  });

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      open: map['open'] as String?,
      close: map['close'] as String?,
      isOpen: map['isOpen'] as bool? ?? false,
    );
  }
}

class CampusInfo {
  final String id;
  final String category;
  final ContactInfo contact;
  final DateTime? createdAt;
  final String description;
  final bool isActive;
  final LocationInfo location;
  final Map<String, TimeSlot> timings;
  final String title;
  final DateTime? updatedAt;

  const CampusInfo({
    required this.id,
    required this.category,
    required this.contact,
    this.createdAt,
    required this.description,
    required this.isActive,
    required this.location,
    required this.timings,
    required this.title,
    this.updatedAt,
  });

  factory CampusInfo.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    
    final contactMap = data['contact'] as Map<String, dynamic>? ?? {};
    final contact = ContactInfo.fromMap(contactMap);

    final locationMap = data['location'] as Map<String, dynamic>? ?? {};
    final location = LocationInfo.fromMap(locationMap);

    final timingsMap = data['timings'] as Map<String, dynamic>? ?? {};
    final timings = <String, TimeSlot>{};
    timingsMap.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        timings[key] = TimeSlot.fromMap(value);
      }
    });

    return CampusInfo(
      id: doc.id,
      category: data['category'] as String? ?? 'General',
      contact: contact,
      createdAt: parseTimestamp(data['createdAt']),
      description: data['description'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      location: location,
      timings: timings,
      title: data['title'] as String? ?? '',
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }
}
