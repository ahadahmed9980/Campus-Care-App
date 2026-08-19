enum RequestEntryType {
  problem,
  complaint;

  String get title {
    switch (this) {
      case RequestEntryType.problem:
        return 'Report a Problem';
      case RequestEntryType.complaint:
        return 'Submit a Complaint';
    }
  }

  String get submitLabel {
    switch (this) {
      case RequestEntryType.problem:
        return 'Submit Request';
      case RequestEntryType.complaint:
        return 'Submit Complaint';
    }
  }

  String get successMessage {
    switch (this) {
      case RequestEntryType.problem:
        return 'Your problem report was submitted.';
      case RequestEntryType.complaint:
        return 'Your complaint was submitted.';
    }
  }
}
