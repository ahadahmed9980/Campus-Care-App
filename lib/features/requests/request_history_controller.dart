import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/campus_models.dart';
import '../../data/models/request_model.dart';
import '../../data/repositories/campus_repositories.dart';

enum RequestSortOption {
  newest,
  oldest,
  highestPriority,
  lowestPriority,
}

class RequestHistoryController extends GetxController {
  RequestHistoryController({
    RequestRepository? requestRepository,
    CategoryRepository? categoryRepository,
  })  : _requestRepository =
            requestRepository ?? Get.find<RequestRepository>(),
        _categoryRepository =
            categoryRepository ?? Get.find<CategoryRepository>();

  final RequestRepository _requestRepository;
  final CategoryRepository _categoryRepository;

  final searchController = TextEditingController();

  final requests = <CampusRequest>[].obs;
  final categories = <RequestCategory>[].obs;

  final isLoading = true.obs;
  final errorMessage = RxnString();

  final searchQuery = ''.obs;
  final selectedStatus = Rxn<RequestStatus>();
  final selectedCategoryId = RxnString();
  final selectedDateFrom = Rxn<DateTime>();
  final selectedDateTo = Rxn<DateTime>();
  final searchFocusNode = FocusNode();

  final sortOption = RequestSortOption.newest.obs;

  StreamSubscription<List<CampusRequest>>? _requestSubscription;

  String? get _currentUserId =>
      FirebaseAuth.instance.currentUser?.uid;

  List<CampusRequest> get filteredRequests {
    Iterable<CampusRequest> result = requests;

    final query = searchQuery.value.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where((request) {
        return request.title.toLowerCase().contains(query) ||
            request.description.toLowerCase().contains(query) ||
            request.location.toLowerCase().contains(query) ||
            request.displayId.toLowerCase().contains(query);
      });
    }

    final status = selectedStatus.value;

    if (status != null) {
      result = result.where(
        (request) => request.status == status,
      );
    }

    final categoryId = selectedCategoryId.value;

    if (categoryId != null && categoryId.isNotEmpty) {
      result = result.where(
        (request) => request.categoryId == categoryId,
      );
    }

    final from = selectedDateFrom.value;

    if (from != null) {
      final startOfDay = DateTime(
        from.year,
        from.month,
        from.day,
      );

      result = result.where((request) {
        final createdAt = request.createdAt;

        if (createdAt == null) {
          return false;
        }

        return !createdAt.isBefore(startOfDay);
      });
    }

    final to = selectedDateTo.value;

    if (to != null) {
      final endOfDay = DateTime(
        to.year,
        to.month,
        to.day,
        23,
        59,
        59,
        999,
      );

      result = result.where((request) {
        final createdAt = request.createdAt;

        if (createdAt == null) {
          return false;
        }

        return !createdAt.isAfter(endOfDay);
      });
    }

    final sorted = result.toList();

    sorted.sort((a, b) {
      switch (sortOption.value) {
        case RequestSortOption.newest:
          return _compareDatesDescending(
            a.createdAt,
            b.createdAt,
          );

        case RequestSortOption.oldest:
          return _compareDatesAscending(
            a.createdAt,
            b.createdAt,
          );

        case RequestSortOption.highestPriority:
          return _priorityRank(b.priority)
              .compareTo(_priorityRank(a.priority));

        case RequestSortOption.lowestPriority:
          return _priorityRank(a.priority)
              .compareTo(_priorityRank(b.priority));
      }
    });

    return sorted;
  }

  bool get hasActiveFilters {
    return selectedStatus.value != null ||
        selectedCategoryId.value != null ||
        selectedDateFrom.value != null ||
        selectedDateTo.value != null;
  }

  int get activeFilterCount {
    var count = 0;

    if (selectedStatus.value != null) count++;
    if (selectedCategoryId.value != null) count++;
    if (selectedDateFrom.value != null ||
        selectedDateTo.value != null) {
      count++;
    }

    return count;
  }

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(
      () => searchQuery.value = searchController.text,
    );

    _loadCategories();
    _listenToRequests();
  }

  void _listenToRequests() {
    final uid = _currentUserId;

    if (uid == null) {
      isLoading.value = false;
      errorMessage.value = 'You need to be signed in to view requests.';
      return;
    }

    _requestSubscription = _requestRepository
        .watchUserRequests(uid)
        .listen(
      (items) {
        requests.assignAll(items);
        isLoading.value = false;
        errorMessage.value = null;
      },
      onError: (Object error) {
        isLoading.value = false;
        errorMessage.value =
            'Unable to load your requests right now.';
      },
    );
  }

  Future<void> _loadCategories() async {
    try {
      final items = await _categoryRepository.getActiveCategories();
      categories.assignAll(items);
    } catch (_) {
      categories.clear();
    }
  }

  void setStatus(RequestStatus? status) {
    selectedStatus.value = status;
  }

  void setCategory(String? categoryId) {
    selectedCategoryId.value = categoryId;
  }

  void setDateRange(DateTime? from, DateTime? to) {
    selectedDateFrom.value = from;
    selectedDateTo.value = to;
  }

  void setSortOption(RequestSortOption option) {
    sortOption.value = option;
  }

  void clearFilters() {
    selectedStatus.value = null;
    selectedCategoryId.value = null;
    selectedDateFrom.value = null;
    selectedDateTo.value = null;
  }

  void clearSearch() {
    searchController.clear();
  }

  Future<void> reload() async {
    // Firestore stream is live. Refresh is intentionally lightweight.
    // The subscription will automatically receive the latest snapshot.
    await _loadCategories();
  }

  int _priorityRank(RequestPriority priority) {
    switch (priority) {
      case RequestPriority.low:
        return 1;
      case RequestPriority.medium:
        return 2;
      case RequestPriority.high:
        return 3;
    }
  }

  int _compareDatesDescending(
    DateTime? a,
    DateTime? b,
  ) {
    final aDate =
        a ?? DateTime.fromMillisecondsSinceEpoch(0);

    final bDate =
        b ?? DateTime.fromMillisecondsSinceEpoch(0);

    return bDate.compareTo(aDate);
  }

  int _compareDatesAscending(
    DateTime? a,
    DateTime? b,
  ) {
    final aDate =
        a ?? DateTime.fromMillisecondsSinceEpoch(0);

    final bDate =
        b ?? DateTime.fromMillisecondsSinceEpoch(0);

    return aDate.compareTo(bDate);
  }

  @override
  void onClose() {
    _requestSubscription?.cancel();
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }
}