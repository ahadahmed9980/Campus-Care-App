import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../models/campus_models.dart';
import '../models/request_model.dart';
import '../services/storage_service.dart';
import '../services/cloudinary_service.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<StudentUser> getStudent(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return StudentUser.fromDoc(userDoc);
    }

    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return StudentUser.fallback(uid: uid, email: email);
  }

  Future<String?> getDepartmentName(String? departmentId) async {
    if (departmentId == null || departmentId.isEmpty) return null;
    final doc =
        await _firestore.collection('departments').doc(departmentId).get();
    return doc.data()?['name'] as String?;
  }
}

class CategoryRepository {
  CategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const fallbackCategories = [
    RequestCategory(id: 'electricity', name: 'Electricity'),
    RequestCategory(id: 'plumbing', name: 'Plumbing'),
    RequestCategory(id: 'furniture', name: 'Furniture'),
    RequestCategory(id: 'internet', name: 'Internet'),
    RequestCategory(id: 'cleaning', name: 'Cleaning'),
    RequestCategory(id: 'hostel', name: 'Hostel'),
    RequestCategory(id: 'security', name: 'Security'),
    RequestCategory(id: 'classroom', name: 'Classroom Maintenance'),
    RequestCategory(id: 'water', name: 'Water'),
    RequestCategory(id: 'other', name: 'Other'),
  ];

  Future<List<RequestCategory>> getActiveCategories() async {
    try {
      final snapshot = await _firestore.collection('requestCategories').get();
      final categories = snapshot.docs
          .map(RequestCategory.fromDoc)
          .where((category) => category.isActive)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      if (categories.isNotEmpty) return categories;
    } catch (_) {
      // Fall through to local defaults so the form still works.
    }
    return fallbackCategories;
  }
}

class AnnouncementRepository {
  AnnouncementRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<AnnouncementPreview?> latestPublished() async {
    try {
      final snapshot = await _firestore.collection('announcements').get();
      final items = snapshot.docs
          .where((doc) => doc.data()['isPublished'] != false)
          .map(AnnouncementPreview.fromDoc)
          .toList()
        ..sort((a, b) {
          final aDate = a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
      return items.isEmpty ? null : items.first;
    } catch (_) {
      return null;
    }
  }

  Future<int> publishedCount() async {
    try {
      final snapshot = await _firestore.collection('announcements').get();
      return snapshot.docs
          .where((doc) => doc.data()['isPublished'] != false)
          .length;
    } catch (_) {
      return 0;
    }
  }

  Future<List<AnnouncementPreview>> getPublishedAnnouncements() async {
    try {
      final snapshot = await _firestore
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .where((doc) => doc.data()['isPublished'] != false)
          .map(AnnouncementPreview.fromDoc)
          .toList();
    } catch (_) {
      // Fallback: get all and sort in memory
      try {
        final snapshot = await _firestore.collection('announcements').get();
        final list = snapshot.docs
            .where((doc) => doc.data()['isPublished'] != false)
            .map(AnnouncementPreview.fromDoc)
            .toList();
        list.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
        return list;
      } catch (_) {
        return [];
      }
    }
  }
}

class CampusInfoRepository {
  CampusInfoRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<CampusInfo>> getCampusInfoList() async {
    try {
      final snapshot = await _firestore
          .collection('campusInformation')
          .orderBy('category')
          .get();
      return snapshot.docs
          .where((doc) => doc.data()['isActive'] != false)
          .map(CampusInfo.fromDoc)
          .toList();
    } catch (_) {
      // Fallback: get all and sort in memory
      try {
        final snapshot = await _firestore.collection('campusInformation').get();
        final list = snapshot.docs
            .where((doc) => doc.data()['isActive'] != false)
            .map(CampusInfo.fromDoc)
            .toList();
        list.sort((a, b) => a.category.toLowerCase().compareTo(b.category.toLowerCase()));
        return list;
      } catch (_) {
        return [];
      }
    }
  }
}

class RequestRepository {
  RequestRepository({
    FirebaseFirestore? firestore,
    StorageService? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? StorageService();

  final FirebaseFirestore _firestore;
  // ignore: unused_field
  final StorageService _storage;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('requests');

  Stream<List<CampusRequest>> watchUserRequests(String userId) {
    return _requests.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final requests = snapshot.docs.map(CampusRequest.fromDoc).toList()
        ..sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
      return requests;
    });
  }

  Stream<CampusRequest?> watchRequest(String requestId) {
    return _requests.doc(requestId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CampusRequest.fromDoc(doc);
    });
  }

  Stream<List<StatusHistoryEntry>> watchStatusHistory(String requestId) {
    return _requests
        .doc(requestId)
        .collection('statusHistory')
        .snapshots()
        .map((snapshot) {
      final entries = snapshot.docs.map(StatusHistoryEntry.fromDoc).toList()
        ..sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aDate.compareTo(bDate);
        });
      return entries;
    });
  }

  Future<String> createRequest({
    required String userId,
    required String title,
    required String description,
    required String categoryId,
    required String location,
    required RequestPriority priority,
    XFile? image,
  }) async {
    final counterRef = _firestore.collection('counters').doc('requests');
    final nextId = await _firestore.runTransaction<String>((transaction) async {
      final counterSnapshot = await transaction.get(counterRef);
      int currentCount = 0;
      if (counterSnapshot.exists) {
        currentCount = counterSnapshot.data()?['currentCount'] as int? ?? 0;
      }
      final newCount = currentCount + 1;
      transaction.set(counterRef, {'currentCount': newCount});
      return 'REQ-${newCount.toString().padLeft(7, '0')}';
    });

    final doc = _requests.doc(nextId);
    final now = FieldValue.serverTimestamp();

    await doc.set({
      'userId': userId,
      'title': title.trim(),
      'description': description.trim(),
      'categoryId': categoryId,
      'location': location.trim(),
      'priority': priority.firestoreValue,
      'imageUrls': <String>[],
      'imageUrl': '',
      'status': RequestStatus.submitted.firestoreValue,
      'assignedDepartmentId': null,
      'resolutionInfo': null,
      'resolvedBy': null,
      'resolvedAt': null,
      'createdAt': now,
      'updatedAt': now,
    });

    await doc.collection('statusHistory').add({
      'status': RequestStatus.submitted.firestoreValue,
      'message': 'Request submitted by student.',
      'changedBy': userId,
      'changedByRole': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (image != null) {
      try {
        final bytes = await image.readAsBytes();
        final url = await CloudinaryService.uploadImage(
          bytes: bytes,
          fileName: image.name,
          folderName: 'requests',
        );
        if (url != null) {
          await doc.update({
            'imageUrl': url,
            'imageUrls': [url],
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (_) {
        // Keep the request even if the optional image upload fails.
      }
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': 'Request submitted successfully',
        'message': 'Your request "${title.trim()}" has been submitted.',
        'type': 'request_submitted',
        'requestId': doc.id,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': null,
      });
    } catch (_) {
      // Notification write is best-effort.
    }

    try {
      await _firestore.collection('admin_notifications').add({
        'title': 'New Request: ${title.trim()}',
        'message': 'A new request has been submitted by student.',
        'requestId': doc.id,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Admin notification write is best-effort.
    }

    return doc.id;
  }
}