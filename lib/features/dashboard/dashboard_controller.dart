import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/campus_models.dart';
import '../../data/models/request_model.dart';
import '../../data/repositories/campus_repositories.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    required this.uid,
    required UserRepository userRepository,
    required RequestRepository requestRepository,
    required AnnouncementRepository announcementRepository,
  })  : _userRepository = userRepository,
        _requestRepository = requestRepository,
        _announcementRepository = announcementRepository;

  final String uid;
  final UserRepository _userRepository;
  final RequestRepository _requestRepository;
  final AnnouncementRepository _announcementRepository;

  StreamSubscription<List<CampusRequest>>? _requestsSub;

  bool loading = true;
  String? error;
  StudentUser? user;
  String? departmentName;
  List<CampusRequest> requests = const [];
  AnnouncementPreview? latestAnnouncement;
  int announcementCount = 0;

  int get openCount =>
      requests.where((request) => request.status.isOpen).length;

  int get inProgressCount => requests
      .where((request) => request.status == RequestStatus.inProgress)
      .length;

  int get resolvedCount => requests
      .where((request) => request.status == RequestStatus.resolved)
      .length;

  CampusRequest? get latestRequest =>
      requests.isEmpty ? null : requests.first;

  Future<void> start() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      user = await _userRepository.getStudent(uid);
      departmentName = user?.departmentName ??
          await _userRepository.getDepartmentName(user?.departmentId);
      latestAnnouncement = await _announcementRepository.latestPublished();
      announcementCount = await _announcementRepository.publishedCount();
    } catch (e) {
      error = 'Unable to load your dashboard right now.';
    }

    await _requestsSub?.cancel();
    _requestsSub = _requestRepository.watchUserRequests(uid).listen(
      (items) {
        requests = items;
        loading = false;
        notifyListeners();
      },
      onError: (_) {
        error = 'Unable to load your requests.';
        loading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _requestsSub?.cancel();
    super.dispose();
  }
}
