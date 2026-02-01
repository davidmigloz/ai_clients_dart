import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ModerationRequest', () {
    test('toJson serializes string input', () {
      final request = ModerationRequest(
        input: ModerationInput.text('Test content'),
        model: 'text-moderation-latest',
      );

      final json = request.toJson();

      expect(json['input'], 'Test content');
      expect(json['model'], 'text-moderation-latest');
    });

    test('toJson serializes array input', () {
      final request = ModerationRequest(
        input: ModerationInput.textList(['Text 1', 'Text 2']),
      );

      final json = request.toJson();

      expect(json['input'], ['Text 1', 'Text 2']);
    });
  });

  group('ModerationInput', () {
    test('text() creates single text input', () {
      final input = ModerationInput.text('Hello');
      expect(input.toJson(), 'Hello');
    });

    test('textList() creates multiple text inputs', () {
      final input = ModerationInput.textList(['Hello', 'World']);
      expect(input.toJson(), ['Hello', 'World']);
    });

    test('fromJson parses string', () {
      final input = ModerationInput.fromJson('Hello');
      expect(input.toJson(), 'Hello');
    });

    test('fromJson parses array', () {
      final input = ModerationInput.fromJson(['Hello', 'World']);
      expect(input.toJson(), ['Hello', 'World']);
    });
  });

  group('ModerationResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'modr-abc123',
        'model': 'text-moderation-latest',
        'results': [
          {
            'flagged': true,
            'categories': {
              'hate': false,
              'hate/threatening': false,
              'harassment': true,
              'harassment/threatening': false,
              'self-harm': false,
              'self-harm/intent': false,
              'self-harm/instructions': false,
              'sexual': false,
              'sexual/minors': false,
              'violence': false,
              'violence/graphic': false,
            },
            'category_scores': {
              'hate': 0.001,
              'hate/threatening': 0.0001,
              'harassment': 0.95,
              'harassment/threatening': 0.01,
              'self-harm': 0.0001,
              'self-harm/intent': 0.0001,
              'self-harm/instructions': 0.0001,
              'sexual': 0.001,
              'sexual/minors': 0.0001,
              'violence': 0.01,
              'violence/graphic': 0.001,
            },
          },
        ],
      };

      final response = ModerationResponse.fromJson(json);

      expect(response.id, 'modr-abc123');
      expect(response.model, 'text-moderation-latest');
      expect(response.results.length, 1);
      expect(response.results[0].flagged, isTrue);
      expect(response.results[0].categories.harassment, isTrue);
      expect(
        response.results[0].categoryScores.harassment,
        closeTo(0.95, 0.01),
      );
    });

    test('anyFlagged returns true when any result is flagged', () {
      final json = {
        'id': 'modr-abc123',
        'model': 'text-moderation-latest',
        'results': [
          {
            'flagged': false,
            'categories': {
              'hate': false,
              'hate/threatening': false,
              'harassment': false,
              'harassment/threatening': false,
              'self-harm': false,
              'self-harm/intent': false,
              'self-harm/instructions': false,
              'sexual': false,
              'sexual/minors': false,
              'violence': false,
              'violence/graphic': false,
            },
            'category_scores': {
              'hate': 0.001,
              'hate/threatening': 0.0001,
              'harassment': 0.01,
              'harassment/threatening': 0.01,
              'self-harm': 0.0001,
              'self-harm/intent': 0.0001,
              'self-harm/instructions': 0.0001,
              'sexual': 0.001,
              'sexual/minors': 0.0001,
              'violence': 0.01,
              'violence/graphic': 0.001,
            },
          },
          {
            'flagged': true,
            'categories': {
              'hate': true,
              'hate/threatening': false,
              'harassment': false,
              'harassment/threatening': false,
              'self-harm': false,
              'self-harm/intent': false,
              'self-harm/instructions': false,
              'sexual': false,
              'sexual/minors': false,
              'violence': false,
              'violence/graphic': false,
            },
            'category_scores': {
              'hate': 0.99,
              'hate/threatening': 0.0001,
              'harassment': 0.01,
              'harassment/threatening': 0.01,
              'self-harm': 0.0001,
              'self-harm/intent': 0.0001,
              'self-harm/instructions': 0.0001,
              'sexual': 0.001,
              'sexual/minors': 0.0001,
              'violence': 0.01,
              'violence/graphic': 0.001,
            },
          },
        ],
      };

      final response = ModerationResponse.fromJson(json);

      expect(response.anyFlagged, isTrue);
    });

    test('first getter returns first result', () {
      final json = {
        'id': 'modr-abc123',
        'model': 'text-moderation-latest',
        'results': [
          {
            'flagged': true,
            'categories': {
              'hate': true,
              'hate/threatening': false,
              'harassment': false,
              'harassment/threatening': false,
              'self-harm': false,
              'self-harm/intent': false,
              'self-harm/instructions': false,
              'sexual': false,
              'sexual/minors': false,
              'violence': false,
              'violence/graphic': false,
            },
            'category_scores': {
              'hate': 0.95,
              'hate/threatening': 0.01,
              'harassment': 0.01,
              'harassment/threatening': 0.01,
              'self-harm': 0.01,
              'self-harm/intent': 0.01,
              'self-harm/instructions': 0.01,
              'sexual': 0.01,
              'sexual/minors': 0.01,
              'violence': 0.01,
              'violence/graphic': 0.01,
            },
          },
        ],
      };

      final response = ModerationResponse.fromJson(json);

      expect(response.first.flagged, isTrue);
      expect(response.first.categories.hate, isTrue);
    });
  });

  group('ModerationResult', () {
    test('fromJson parses correctly', () {
      final json = {
        'flagged': false,
        'categories': {
          'hate': false,
          'hate/threatening': false,
          'harassment': false,
          'harassment/threatening': false,
          'self-harm': false,
          'self-harm/intent': false,
          'self-harm/instructions': false,
          'sexual': false,
          'sexual/minors': false,
          'violence': false,
          'violence/graphic': false,
        },
        'category_scores': {
          'hate': 0.001,
          'hate/threatening': 0.0001,
          'harassment': 0.01,
          'harassment/threatening': 0.01,
          'self-harm': 0.0001,
          'self-harm/intent': 0.0001,
          'self-harm/instructions': 0.0001,
          'sexual': 0.001,
          'sexual/minors': 0.0001,
          'violence': 0.01,
          'violence/graphic': 0.001,
        },
      };

      final result = ModerationResult.fromJson(json);

      expect(result.flagged, isFalse);
      expect(result.categories.hate, isFalse);
      expect(result.categoryScores.hate, closeTo(0.001, 0.0001));
    });

    test('toJson serializes correctly', () {
      const result = ModerationResult(
        flagged: true,
        categories: ModerationCategories(
          hate: true,
          hateThreatening: false,
          harassment: false,
          harassmentThreatening: false,
          selfHarm: false,
          selfHarmIntent: false,
          selfHarmInstructions: false,
          sexual: false,
          sexualMinors: false,
          violence: false,
          violenceGraphic: false,
        ),
        categoryScores: ModerationCategoryScores(
          hate: 0.95,
          hateThreatening: 0.01,
          harassment: 0.01,
          harassmentThreatening: 0.01,
          selfHarm: 0.01,
          selfHarmIntent: 0.01,
          selfHarmInstructions: 0.01,
          sexual: 0.01,
          sexualMinors: 0.01,
          violence: 0.01,
          violenceGraphic: 0.01,
        ),
      );

      final json = result.toJson();

      expect(json['flagged'], isTrue);
      expect((json['categories'] as Map)['hate'], isTrue);
      expect((json['category_scores'] as Map)['hate'], 0.95);
    });
  });
}
