import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ClassificationResult', () {
    const testCategoryScores = CategoryScores(
      sexual: 0.1,
      hate: 0.2,
      violence: 0.3,
      selfHarm: 0.0,
      sexualMinors: 0.0,
      hateThreatening: 0.0,
      violenceGraphic: 0.0,
      selfHarmIntent: 0.0,
      selfHarmInstructions: 0.0,
      harassment: 0.0,
      harassmentThreatening: 0.0,
    );

    group('fromJson', () {
      test('should parse complete classification result', () {
        final json = <String, dynamic>{
          'categories': <String, dynamic>{
            'sexual': true,
            'hate': false,
            'violence': true,
          },
          'category_scores': <String, dynamic>{
            'sexual': 0.85,
            'hate': 0.1,
            'violence': 0.75,
          },
        };

        final result = ClassificationResult.fromJson(json);

        expect(result.categories['sexual'], isTrue);
        expect(result.categories['violence'], isTrue);
        expect(result.categories['hate'], isFalse);
        expect(result.categoryScores.sexual, 0.85);
        expect(result.categoryScores.violence, 0.75);
      });

      test('should derive flagged from categories', () {
        final json = <String, dynamic>{
          'categories': <String, dynamic>{'sexual': true, 'hate': false},
          'category_scores': <String, dynamic>{},
        };

        final result = ClassificationResult.fromJson(json);

        expect(result.flagged, isTrue);
      });

      test('should handle unflagged content', () {
        final json = <String, dynamic>{
          'categories': <String, dynamic>{'sexual': false, 'hate': false},
          'category_scores': <String, dynamic>{},
        };

        final result = ClassificationResult.fromJson(json);

        expect(result.flagged, isFalse);
      });

      test('should handle empty categories', () {
        final json = <String, dynamic>{
          'categories': <String, dynamic>{},
          'category_scores': <String, dynamic>{},
        };

        final result = ClassificationResult.fromJson(json);

        expect(result.flagged, isFalse);
        expect(result.categories, isEmpty);
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};

        final result = ClassificationResult.fromJson(json);

        expect(result.flagged, isFalse);
        expect(result.categories, isEmpty);
      });
    });

    group('toJson', () {
      test('should serialize classification result', () {
        const result = ClassificationResult(
          categories: {'sexual': true, 'pii': false},
          categoryScores: testCategoryScores,
        );

        final json = result.toJson();

        expect((json['categories'] as Map<String, dynamic>)['sexual'], isTrue);
        expect((json['categories'] as Map<String, dynamic>)['pii'], isFalse);
        expect(
          (json['category_scores'] as Map<String, dynamic>)['sexual'],
          0.1,
        );
      });
    });

    group('flagged getter', () {
      test('should return true if any category is true', () {
        const result = ClassificationResult(
          categories: {'sexual': false, 'hate': true, 'violence': false},
          categoryScores: testCategoryScores,
        );

        expect(result.flagged, isTrue);
      });

      test('should return false if all categories are false', () {
        const result = ClassificationResult(
          categories: {'sexual': false, 'hate': false},
          categoryScores: testCategoryScores,
        );

        expect(result.flagged, isFalse);
      });

      test('should return false if categories are empty', () {
        const result = ClassificationResult(
          categories: {},
          categoryScores: testCategoryScores,
        );

        expect(result.flagged, isFalse);
      });
    });

    group('equality', () {
      test('should be equal when categoryScores are the same', () {
        const result1 = ClassificationResult(
          categories: {'sexual': true},
          categoryScores: testCategoryScores,
        );
        const result2 = ClassificationResult(
          categories: {'sexual': true},
          categoryScores: testCategoryScores,
        );

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });
    });

    group('toString', () {
      test('should return a meaningful string representation', () {
        const result = ClassificationResult(
          categories: {'sexual': true},
          categoryScores: testCategoryScores,
        );

        expect(result.toString(), contains('ClassificationResult'));
        expect(result.toString(), contains('true'));
      });
    });
  });
}
