class RequestValidator {
  RequestValidator._();

  static String? title(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter a request title.';
    if (text.length < 5) return 'Title must be at least 5 characters.';
    if (text.length > 80) return 'Title must be under 80 characters.';
    return null;
  }

  static String? description(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please describe the issue.';
    if (text.length < 20) {
      return 'Description must be at least 20 characters.';
    }
    if (text.length > 1000) {
      return 'Description must be under 1000 characters.';
    }
    return null;
  }

  static String? location(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter a location.';
    if (text.length < 3) return 'Location must be at least 3 characters.';
    if (text.length > 80) return 'Location must be under 80 characters.';
    return null;
  }

  static String? categoryId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a category.';
    }
    return null;
  }

  static String? priority(String? value) {
    const allowed = {'low', 'medium', 'high'};
    if (value == null || !allowed.contains(value)) {
      return 'Please select a priority.';
    }
    return null;
  }
}
