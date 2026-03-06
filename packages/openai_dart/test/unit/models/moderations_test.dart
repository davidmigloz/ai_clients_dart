import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

/// Helper to build a complete moderation result JSON with all required fields.
Map<String, dynamic> _buildResultJson({
  bool flagged = false,
  Map<String, bool?>? categoryOverrides,
  Map<String, num>? scoreOverrides,
}) {
  final categories = {
    'hate': false,
    'hate/threatening': false,
    'harassment': false,
    'harassment/threatening': false,
    'illicit': null, // nullable per spec
    'illicit/violent': null, // nullable per spec
    'self-harm': false,
    'self-harm/intent': false,
    'self-harm/instructions': false,
    'sexual': false,
    'sexual/minors': false,
    'violence': false,
    'violence/graphic': false,
    ...?categoryOverrides,
  };
  final scores = {
    'hate': 0.001,
    'hate/threatening': 0.0001,
    'harassment': 0.01,
    'harassment/threatening': 0.01,
    'illicit': 0.001,
    'illicit/violent': 0.001,
    'self-harm': 0.0001,
    'self-harm/intent': 0.0001,
    'self-harm/instructions': 0.0001,
    'sexual': 0.001,
    'sexual/minors': 0.0001,
    'violence': 0.01,
    'violence/graphic': 0.001,
    ...?scoreOverrides,
  };
  final appliedInputTypes = {
    'hate': ['text'],
    'hate/threatening': ['text'],
    'harassment': ['text'],
    'harassment/threatening': ['text'],
    'illicit': ['text'],
    'illicit/violent': ['text'],
    'self-harm': ['text', 'image'],
    'self-harm/intent': ['text', 'image'],
    'self-harm/instructions': ['text', 'image'],
    'sexual': ['text', 'image'],
    'sexual/minors': ['text'],
    'violence': ['text', 'image'],
    'violence/graphic': ['text', 'image'],
  };
  return {
    'flagged': flagged,
    'categories': categories,
    'category_scores': scores,
    'category_applied_input_types': appliedInputTypes,
  };
}

/// Helper to build a complete moderation response JSON.
Map<String, dynamic> _buildResponseJson({
  String id = 'modr-abc123',
  String model = 'omni-moderation-latest',
  List<Map<String, dynamic>>? results,
}) {
  return {
    'id': id,
    'model': model,
    'results': results ?? [_buildResultJson()],
  };
}

/// Helper to build a complete ModerationCategoryAppliedInputTypes for tests.
const _defaultAppliedInputTypes = ModerationCategoryAppliedInputTypes(
  hate: ['text'],
  hateThreatening: ['text'],
  harassment: ['text'],
  harassmentThreatening: ['text'],
  illicit: ['text'],
  illicitViolent: ['text'],
  selfHarm: ['text', 'image'],
  selfHarmIntent: ['text', 'image'],
  selfHarmInstructions: ['text', 'image'],
  sexual: ['text', 'image'],
  sexualMinors: ['text'],
  violence: ['text', 'image'],
  violenceGraphic: ['text', 'image'],
);

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

    test('toJson serializes multi-modal input', () {
      final request = ModerationRequest(
        input: ModerationInput.multiModal([
          ModerationInputItem.text('Check this text'),
          ModerationInputItem.imageUrl('https://example.com/image.jpg'),
        ]),
        model: 'omni-moderation-latest',
      );

      final json = request.toJson();

      expect(json['input'], [
        {'type': 'text', 'text': 'Check this text'},
        {
          'type': 'image_url',
          'image_url': {'url': 'https://example.com/image.jpg'},
        },
      ]);
      expect(json['model'], 'omni-moderation-latest');
    });

    test('fromJson parses multi-modal input', () {
      final json = {
        'input': [
          {'type': 'text', 'text': 'Hello'},
          {
            'type': 'image_url',
            'image_url': {'url': 'https://example.com/img.png'},
          },
        ],
        'model': 'omni-moderation-latest',
      };

      final request = ModerationRequest.fromJson(json);

      expect(request.input, isA<ModerationInputMultiModal>());
      final multiModal = request.input as ModerationInputMultiModal;
      expect(multiModal.items.length, 2);
      expect(multiModal.items[0], isA<ModerationInputItemText>());
      expect(multiModal.items[1], isA<ModerationInputItemImageUrl>());
      expect((multiModal.items[0] as ModerationInputItemText).text, 'Hello');
      expect(
        (multiModal.items[1] as ModerationInputItemImageUrl).url,
        'https://example.com/img.png',
      );
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

    test('multiModal() creates multi-modal input', () {
      final input = ModerationInput.multiModal([
        ModerationInputItem.text('text'),
        ModerationInputItem.imageUrl('https://example.com/img.png'),
      ]);
      expect(input, isA<ModerationInputMultiModal>());
      expect((input as ModerationInputMultiModal).items.length, 2);
    });

    test('fromJson parses string', () {
      final input = ModerationInput.fromJson('Hello');
      expect(input.toJson(), 'Hello');
    });

    test('fromJson parses array of strings', () {
      final input = ModerationInput.fromJson(['Hello', 'World']);
      expect(input.toJson(), ['Hello', 'World']);
    });

    test('fromJson parses array of objects as multi-modal', () {
      final input = ModerationInput.fromJson([
        {'type': 'text', 'text': 'Hello'},
      ]);
      expect(input, isA<ModerationInputMultiModal>());
    });
  });

  group('ModerationInputItem', () {
    test('text item serializes correctly', () {
      final item = ModerationInputItem.text('Hello');
      expect(item.toJson(), {'type': 'text', 'text': 'Hello'});
    });

    test('image URL item serializes correctly', () {
      final item = ModerationInputItem.imageUrl('https://example.com/img.png');
      expect(item.toJson(), {
        'type': 'image_url',
        'image_url': {'url': 'https://example.com/img.png'},
      });
    });

    test('fromJson parses text item', () {
      final item = ModerationInputItem.fromJson({
        'type': 'text',
        'text': 'Hello',
      });
      expect(item, isA<ModerationInputItemText>());
      expect((item as ModerationInputItemText).text, 'Hello');
    });

    test('fromJson parses image URL item', () {
      final item = ModerationInputItem.fromJson({
        'type': 'image_url',
        'image_url': {'url': 'https://example.com/img.png'},
      });
      expect(item, isA<ModerationInputItemImageUrl>());
      expect(
        (item as ModerationInputItemImageUrl).url,
        'https://example.com/img.png',
      );
    });
  });

  group('ModerationResponse', () {
    test('fromJson parses correctly', () {
      final json = _buildResponseJson(
        results: [
          _buildResultJson(
            flagged: true,
            categoryOverrides: {'harassment': true},
            scoreOverrides: {'harassment': 0.95},
          ),
        ],
      );

      final response = ModerationResponse.fromJson(json);

      expect(response.id, 'modr-abc123');
      expect(response.model, 'omni-moderation-latest');
      expect(response.results.length, 1);
      expect(response.results[0].flagged, isTrue);
      expect(response.results[0].categories.harassment, isTrue);
      expect(
        response.results[0].categoryScores.harassment,
        closeTo(0.95, 0.01),
      );
    });

    test(
      'fromJson parses omni-moderation response with illicit categories',
      () {
        final json = _buildResponseJson(
          results: [
            _buildResultJson(
              flagged: true,
              categoryOverrides: {
                'harassment': true,
                'harassment/threatening': true,
                'illicit': false,
                'illicit/violent': false,
                'violence': true,
                'violence/graphic': true,
              },
              scoreOverrides: {
                'harassment': 0.818,
                'harassment/threatening': 0.804,
                'illicit': 0.030,
                'illicit/violent': 0.008,
                'violence': 0.999,
                'violence/graphic': 0.843,
              },
            ),
          ],
        );

        final response = ModerationResponse.fromJson(json);

        expect(response.model, 'omni-moderation-latest');
        final result = response.results[0];
        expect(result.flagged, isTrue);

        // illicit categories (nullable bools in categories)
        expect(result.categories.illicit, isFalse);
        expect(result.categories.illicitViolent, isFalse);
        // illicit scores (required doubles)
        expect(result.categoryScores.illicit, closeTo(0.030, 0.001));
        expect(result.categoryScores.illicitViolent, closeTo(0.008, 0.001));

        // category_applied_input_types
        expect(result.categoryAppliedInputTypes, isNotNull);
        expect(result.categoryAppliedInputTypes!.hate, ['text']);
        expect(result.categoryAppliedInputTypes!.selfHarm, ['text', 'image']);
        expect(result.categoryAppliedInputTypes!.sexual, ['text', 'image']);
        expect(result.categoryAppliedInputTypes!.violence, ['text', 'image']);
      },
    );

    test('fromJson parses response with null illicit categories', () {
      final json = _buildResponseJson(
        results: [
          _buildResultJson(
            categoryOverrides: {'illicit': null, 'illicit/violent': null},
          ),
        ],
      );

      final response = ModerationResponse.fromJson(json);
      final result = response.results[0];

      // illicit category flags can be null
      expect(result.categories.illicit, isNull);
      expect(result.categories.illicitViolent, isNull);
      // scores are still present (omni-moderation response)
      expect(result.categoryScores.illicit, isA<double>());
      expect(result.categoryScores.illicitViolent, isA<double>());
    });

    test('fromJson parses legacy text-moderation response', () {
      // text-moderation models don't return illicit scores or
      // category_applied_input_types
      final json = {
        'id': 'modr-legacy',
        'model': 'text-moderation-007',
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
        ],
      };

      final response = ModerationResponse.fromJson(json);
      final result = response.results[0];

      expect(result.flagged, isFalse);
      expect(result.categories.illicit, isNull);
      expect(result.categories.illicitViolent, isNull);
      expect(result.categoryScores.illicit, isNull);
      expect(result.categoryScores.illicitViolent, isNull);
      expect(result.categoryAppliedInputTypes, isNull);
    });

    test('anyFlagged returns true when any result is flagged', () {
      final json = _buildResponseJson(
        results: [
          _buildResultJson(flagged: false),
          _buildResultJson(
            flagged: true,
            categoryOverrides: {'hate': true},
            scoreOverrides: {'hate': 0.99},
          ),
        ],
      );

      final response = ModerationResponse.fromJson(json);

      expect(response.anyFlagged, isTrue);
    });

    test('first getter returns first result', () {
      final json = _buildResponseJson(
        results: [
          _buildResultJson(
            flagged: true,
            categoryOverrides: {'hate': true},
            scoreOverrides: {'hate': 0.95},
          ),
        ],
      );

      final response = ModerationResponse.fromJson(json);

      expect(response.first.flagged, isTrue);
      expect(response.first.categories.hate, isTrue);
    });
  });

  group('ModerationResult', () {
    test('fromJson parses correctly', () {
      final json = _buildResultJson();

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
          illicit: 0.01,
          illicitViolent: 0.01,
          selfHarm: 0.01,
          selfHarmIntent: 0.01,
          selfHarmInstructions: 0.01,
          sexual: 0.01,
          sexualMinors: 0.01,
          violence: 0.01,
          violenceGraphic: 0.01,
        ),
        categoryAppliedInputTypes: _defaultAppliedInputTypes,
      );

      final json = result.toJson();

      expect(json['flagged'], isTrue);
      expect((json['categories'] as Map)['hate'], isTrue);
      expect((json['category_scores'] as Map)['hate'], 0.95);
      expect(json['category_applied_input_types'], isNotNull);
    });

    test('toJson with illicit categories', () {
      const result = ModerationResult(
        flagged: true,
        categories: ModerationCategories(
          hate: false,
          hateThreatening: false,
          harassment: false,
          harassmentThreatening: false,
          illicit: true,
          illicitViolent: false,
          selfHarm: false,
          selfHarmIntent: false,
          selfHarmInstructions: false,
          sexual: false,
          sexualMinors: false,
          violence: false,
          violenceGraphic: false,
        ),
        categoryScores: ModerationCategoryScores(
          hate: 0.01,
          hateThreatening: 0.01,
          harassment: 0.01,
          harassmentThreatening: 0.01,
          illicit: 0.95,
          illicitViolent: 0.02,
          selfHarm: 0.01,
          selfHarmIntent: 0.01,
          selfHarmInstructions: 0.01,
          sexual: 0.01,
          sexualMinors: 0.01,
          violence: 0.01,
          violenceGraphic: 0.01,
        ),
        categoryAppliedInputTypes: _defaultAppliedInputTypes,
      );

      final json = result.toJson();

      expect((json['categories'] as Map)['illicit'], isTrue);
      expect((json['categories'] as Map)['illicit/violent'], isFalse);
      expect((json['category_scores'] as Map)['illicit'], 0.95);
      expect((json['category_scores'] as Map)['illicit/violent'], 0.02);
      final applied =
          json['category_applied_input_types'] as Map<String, dynamic>;
      expect(applied['hate'], ['text']);
      expect(applied['self-harm'], ['text', 'image']);
    });
  });
}
