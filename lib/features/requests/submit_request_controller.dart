import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/utils/request_validator.dart';
import '../../data/models/campus_models.dart';
import '../../data/models/request_model.dart';
import '../../data/repositories/campus_repositories.dart';

class SubmitRequestController extends ChangeNotifier {
  SubmitRequestController({
    required this.userId,
    required RequestRepository requestRepository,
    required CategoryRepository categoryRepository,
  })  : _requestRepository = requestRepository,
        _categoryRepository = categoryRepository;

  final String userId;
  final RequestRepository _requestRepository;
  final CategoryRepository _categoryRepository;
  final ImagePicker _picker = ImagePicker();

  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  List<RequestCategory> categories = const [];
  String? categoryId;
  RequestPriority priority = RequestPriority.medium;
  XFile? image;
  bool loadingCategories = true;
  bool submitting = false;
  String? error;
  bool dirty = false;

  Future<void> loadCategories() async {
    loadingCategories = true;
    notifyListeners();
    categories = await _categoryRepository.getActiveCategories();
    loadingCategories = false;
    notifyListeners();
  }

  void markDirty() {
    if (dirty) return;
    dirty = true;
    notifyListeners();
  }

  void setCategory(String? value) {
    categoryId = value;
    markDirty();
    notifyListeners();
  }

  void setPriority(RequestPriority value) {
    priority = value;
    markDirty();
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1600,
    );
    if (picked == null) return;
    image = picked;
    markDirty();
    notifyListeners();
  }

  void removeImage() {
    image = null;
    notifyListeners();
  }

  String? validate() {
    return RequestValidator.title(titleController.text) ??
        RequestValidator.categoryId(categoryId) ??
        RequestValidator.location(locationController.text) ??
        RequestValidator.priority(priority.firestoreValue) ??
        RequestValidator.description(descriptionController.text);
  }

  Future<String?> submit() async {
    final validationError = validate();
    if (validationError != null) {
      error = validationError;
      notifyListeners();
      return null;
    }

    submitting = true;
    error = null;
    notifyListeners();

    try {
      final id = await _requestRepository.createRequest(
        userId: userId,
        title: titleController.text,
        description: descriptionController.text,
        categoryId: categoryId!,
        location: locationController.text,
        priority: priority,
        image: image,
      );
      dirty = false;
      submitting = false;
      notifyListeners();
      return id;
    } catch (e) {
      submitting = false;
      error = _friendlyError(e);
      notifyListeners();
      return null;
    }
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('permission-denied')) {
      return 'You do not have permission to submit this request.';
    }
    if (text.contains('network') || text.contains('unavailable')) {
      return 'Network issue. Check your connection and try again.';
    }
    if (text.contains('storage') || text.contains('object')) {
      return 'The request was created, but the image could not be uploaded.';
    }
    return 'Unable to submit your request. Please try again.';
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
