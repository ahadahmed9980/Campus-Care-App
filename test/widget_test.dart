import 'package:flutter_test/flutter_test.dart';

import 'package:campus_care_app/core/utils/request_validator.dart';
import 'package:campus_care_app/data/models/request_model.dart';

void main() {
  group('RequestValidator', () {
    test('rejects empty and short titles', () {
      expect(RequestValidator.title(null), isNotNull);
      expect(RequestValidator.title('Hi'), isNotNull);
      expect(RequestValidator.title('Broken classroom fan'), isNull);
    });

    test('requires a clear description', () {
      expect(RequestValidator.description('Too short'), isNotNull);
      expect(
        RequestValidator.description(
          'The ceiling fan in Block A room 203 is not working.',
        ),
        isNull,
      );
    });

    test('requires a location and category', () {
      expect(RequestValidator.location('A'), isNotNull);
      expect(RequestValidator.location('Block A - Room 203'), isNull);
      expect(RequestValidator.categoryId(null), isNotNull);
      expect(RequestValidator.categoryId('electricity'), isNull);
    });

    test('only allows supported priorities', () {
      expect(RequestValidator.priority('urgent'), isNotNull);
      expect(RequestValidator.priority('high'), isNull);
    });
  });

  group('RequestStatus', () {
    test('parses firestore values', () {
      expect(
        RequestStatus.fromString('under_review'),
        RequestStatus.underReview,
      );
      expect(
        RequestStatus.fromString('in_progress'),
        RequestStatus.inProgress,
      );
      expect(RequestStatus.fromString('submitted').isOpen, isTrue);
      expect(RequestStatus.resolved.isOpen, isFalse);
    });
  });
}
