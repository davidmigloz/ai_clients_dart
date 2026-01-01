import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ModerationResponse', () {
    const testCategoryScores = CategoryScores(
      sexual: 0.9,
      hate: 0.0,
      violence: 0.0,
      selfHarm: 0.0,
      sexualMinors: 0.0,
      hateThreatening: 0.0,
      violenceGraphic: 0.0,
      selfHarmIntent: 0.0,
      selfHarmInstructions: 0.0,
      harassment: 0.0,
      harassmentThreatening: 0.0,
    );

    const zeroCategoryScores = CategoryScores(
      sexual: 0.0,
      hate: 0.0,
      violence: 0.0,
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
      test('should parse complete moderation response', () {
        final json = <String, dynamic>{
          'id': 'mod-123',
          'model': 'mistral-moderation-latest',
          'results': [
            {
              'categories': <String, dynamic>{'sexual': true},
              'category_scores': <String, dynamic>{'sexual': 0.95},
            },
            {
              'categories': <String, dynamic>{},
              'category_scores': <String, dynamic>{},
            },
          ],
        };

        final response = ModerationResponse.fromJson(json);

        expect(response.id, 'mod-123');
        expect(response.model, 'mistral-moderation-latest');
        expect(response.results, hasLength(2));
        expect(response.results[0].flagged, isTrue);
        expect(response.results[1].flagged, isFalse);
      });

      test('should handle empty results', () {
        final json = <String, dynamic>{
          'id': 'mod-456',
          'model': 'mistral-moderation-latest',
          'results': <Map<String, dynamic>>[],
        };

        final response = ModerationResponse.fromJson(json);

        expect(response.id, 'mod-456');
        expect(response.results, isEmpty);
      });

      test('should handle missing optional fields', () {
        final json = <String, dynamic>{'results': <Map<String, dynamic>>[]};

        final response = ModerationResponse.fromJson(json);

        expect(response.id, isEmpty);
        expect(response.model, isEmpty);
      });
    });

    group('toJson', () {
      test('should serialize moderation response', () {
        const response = ModerationResponse(
          id: 'mod-123',
          model: 'mistral-moderation-latest',
          results: [
            ModerationResult(
              categories: {'sexual': true},
              categoryScores: testCategoryScores,
            ),
          ],
        );

        final json = response.toJson();

        expect(json['id'], 'mod-123');
        expect(json['model'], 'mistral-moderation-latest');
        expect(json['results'], hasLength(1));
        final firstResult =
            (json['results'] as List).first as Map<String, dynamic>;
        final categories = firstResult['categories'] as Map<String, dynamic>;
        expect(categories['sexual'], isTrue);
      });
    });

    group('flagged getter', () {
      test('should return true if any result is flagged', () {
        const response = ModerationResponse(
          id: 'mod-123',
          model: 'mistral-moderation-latest',
          results: [
            ModerationResult(
              categories: {'sexual': false},
              categoryScores: zeroCategoryScores,
            ),
            ModerationResult(
              categories: {'hate': true},
              categoryScores: zeroCategoryScores,
            ),
            ModerationResult(
              categories: {'violence': false},
              categoryScores: zeroCategoryScores,
            ),
          ],
        );

        expect(response.flagged, isTrue);
      });

      test('should return false if no results are flagged', () {
        const response = ModerationResponse(
          id: 'mod-123',
          model: 'mistral-moderation-latest',
          results: [
            ModerationResult(
              categories: {'sexual': false},
              categoryScores: zeroCategoryScores,
            ),
            ModerationResult(
              categories: {'hate': false},
              categoryScores: zeroCategoryScores,
            ),
          ],
        );

        expect(response.flagged, isFalse);
      });

      test('should return false if results are empty', () {
        const response = ModerationResponse(
          id: 'mod-123',
          model: 'mistral-moderation-latest',
          results: [],
        );

        expect(response.flagged, isFalse);
      });
    });

    group('firstResult getter', () {
      test('should return first result when available', () {
        const response = ModerationResponse(
          id: 'mod-123',
          model: 'mistral-moderation-latest',
          results: [
            ModerationResult(
              categories: {'sexual': true},
              categoryScores: testCategoryScores,
            ),
          ],
        );

        expect(response.firstResult, isNotNull);
        expect(response.firstResult!.flagged, isTrue);
      });

      test('should return null when no results', () {
        const response = ModerationResponse(
          id: 'mod-123',
          model: 'mistral-moderation-latest',
          results: [],
        );

        expect(response.firstResult, isNull);
      });
    });

    group('equality', () {
      test('should be equal when id and model are the same', () {
        const response1 = ModerationResponse(
          id: 'mod-123',
          model: 'mistral-moderation-latest',
          results: [],
        );
        const response2 = ModerationResponse(
          id: 'mod-123',
          model: 'mistral-moderation-latest',
          results: [],
        );

        expect(response1, equals(response2));
        expect(response1.hashCode, equals(response2.hashCode));
      });

      test('should not be equal when id differs', () {
        const response1 = ModerationResponse(
          id: 'mod-123',
          model: '',
          results: [],
        );
        const response2 = ModerationResponse(
          id: 'mod-456',
          model: '',
          results: [],
        );

        expect(response1, isNot(equals(response2)));
      });
    });

    group('toString', () {
      test('should return a meaningful string representation', () {
        const response = ModerationResponse(
          id: 'mod-123',
          model: 'mistral-moderation-latest',
          results: [
            ModerationResult(
              categories: {'sexual': true},
              categoryScores: testCategoryScores,
            ),
          ],
        );

        expect(response.toString(), contains('ModerationResponse'));
        expect(response.toString(), contains('mod-123'));
        expect(response.toString(), contains('1'));
      });
    });
  });
}
