import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

/// Builds a `moderation_result` outcome body JSON with all required fields.
Map<String, dynamic> _resultBodyJson({bool flagged = true}) => {
  'type': 'moderation_result',
  'model': 'omni-moderation-latest',
  'flagged': flagged,
  'categories': {'hate': false, 'violence': flagged},
  'category_scores': {'hate': 0.0001, 'violence': 0.97},
  'category_applied_input_types': {
    'hate': ['text'],
    'violence': ['text', 'image'],
  },
};

/// Builds an `error` outcome body JSON.
Map<String, dynamic> _errorBodyJson() => {
  'type': 'error',
  'code': 'moderation_failed',
  'message': 'Moderation could not be completed.',
};

void main() {
  group('ModerationConfig', () {
    test('round-trips through JSON', () {
      const config = ModerationConfig(model: 'omni-moderation-latest');
      expect(config.toJson(), {'model': 'omni-moderation-latest'});
      expect(ModerationConfig.fromJson(config.toJson()), config);
    });

    test('equality and hashCode', () {
      const a = ModerationConfig(model: 'omni-moderation-latest');
      const b = ModerationConfig(model: 'omni-moderation-latest');
      const c = ModerationConfig(model: 'text-moderation-latest');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('omits policy from JSON when null', () {
      const config = ModerationConfig(model: 'omni-moderation-latest');
      expect(config.toJson(), {'model': 'omni-moderation-latest'});
      expect(config.policy, isNull);
    });

    test('round-trips policy through JSON', () {
      const config = ModerationConfig(
        model: 'omni-moderation-latest',
        policy: ModerationPolicyParam(
          input: ModerationConfigParam(mode: ModerationMode.score),
          output: ModerationConfigParam(mode: ModerationMode.block),
        ),
      );
      expect(config.toJson(), {
        'model': 'omni-moderation-latest',
        'policy': {
          'input': {'mode': 'score'},
          'output': {'mode': 'block'},
        },
      });
      expect(ModerationConfig.fromJson(config.toJson()), config);
    });

    test('policy affects equality and hashCode', () {
      const withPolicy = ModerationConfig(
        model: 'omni-moderation-latest',
        policy: ModerationPolicyParam(
          input: ModerationConfigParam(mode: ModerationMode.block),
        ),
      );
      const withoutPolicy = ModerationConfig(model: 'omni-moderation-latest');
      expect(withPolicy, isNot(withoutPolicy));
      expect(
        withPolicy,
        const ModerationConfig(
          model: 'omni-moderation-latest',
          policy: ModerationPolicyParam(
            input: ModerationConfigParam(mode: ModerationMode.block),
          ),
        ),
      );
    });

    test('copyWith can set and clear policy explicitly', () {
      const config = ModerationConfig(model: 'omni-moderation-latest');
      final withPolicy = config.copyWith(
        policy: const ModerationPolicyParam(
          input: ModerationConfigParam(mode: ModerationMode.score),
        ),
      );
      expect(withPolicy.policy, isNotNull);
      expect(withPolicy.copyWith().policy, withPolicy.policy);
      expect(withPolicy.copyWith(policy: null).policy, isNull);
    });
  });

  group('ModerationInputType', () {
    test('maps known values', () {
      expect(ModerationInputType.fromJson('text'), ModerationInputType.text);
      expect(ModerationInputType.fromJson('image'), ModerationInputType.image);
      expect(ModerationInputType.text.toJson(), 'text');
    });

    test('falls back to unknown for unrecognized values', () {
      expect(
        ModerationInputType.fromJson('audio'),
        ModerationInputType.unknown,
      );
    });
  });

  group('ModerationOutcome', () {
    test('parses a moderation_result body', () {
      final outcome = ModerationOutcome.fromJson(_resultBodyJson());
      expect(outcome, isA<ModerationResultBody>());
      final result = outcome as ModerationResultBody;
      expect(result.type, 'moderation_result');
      expect(result.flagged, isTrue);
      expect(result.categories['violence'], isTrue);
      expect(result.categoryScores['violence'], 0.97);
      expect(result.categoryAppliedInputTypes['violence'], [
        ModerationInputType.text,
        ModerationInputType.image,
      ]);
      expect(result.toJson(), _resultBodyJson());
    });

    test('parses an error body', () {
      final outcome = ModerationOutcome.fromJson(_errorBodyJson());
      expect(outcome, isA<ModerationErrorBody>());
      final error = outcome as ModerationErrorBody;
      expect(error.code, 'moderation_failed');
      expect(error.toJson(), _errorBodyJson());
    });

    test('throws on unknown type', () {
      expect(
        () => ModerationOutcome.fromJson(const {'type': 'mystery'}),
        throwsFormatException,
      );
    });

    test('result body equality is content-based', () {
      final a = ModerationOutcome.fromJson(_resultBodyJson());
      final b = ModerationOutcome.fromJson(_resultBodyJson());
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('Moderation (Responses)', () {
    test('round-trips with result input and error output', () {
      final json = {'input': _resultBodyJson(), 'output': _errorBodyJson()};
      final moderation = Moderation.fromJson(json);
      expect(moderation.input, isA<ModerationResultBody>());
      expect(moderation.output, isA<ModerationErrorBody>());
      expect(moderation.toJson(), json);
      expect(Moderation.fromJson(moderation.toJson()), moderation);
    });
  });

  group('ChatCompletionModeration', () {
    test('round-trips moderation_results input', () {
      final json = {
        'input': {
          'type': 'moderation_results',
          'model': 'omni-moderation-latest',
          'results': [_resultBodyJson()],
        },
        'output': _errorBodyJson(),
      };
      final moderation = ChatCompletionModeration.fromJson(json);
      expect(moderation.input, isA<ChatCompletionModerationResults>());
      final results = moderation.input as ChatCompletionModerationResults;
      expect(results.results, hasLength(1));
      expect(results.results.first.flagged, isTrue);
      expect(moderation.output, isA<ChatCompletionModerationError>());
      expect(moderation.toJson(), json);
      expect(
        ChatCompletionModeration.fromJson(moderation.toJson()),
        moderation,
      );
    });
  });

  group('moderation on requests', () {
    test('ChatCompletionCreateRequest serializes moderation', () {
      const request = ChatCompletionCreateRequest(
        model: 'gpt-5.5',
        messages: [],
        moderation: ModerationConfig(model: 'omni-moderation-latest'),
      );
      expect(request.toJson()['moderation'], {
        'model': 'omni-moderation-latest',
      });
      final decoded = ChatCompletionCreateRequest.fromJson(request.toJson());
      expect(decoded.moderation, request.moderation);
    });

    test('CreateResponseRequest serializes and copies moderation', () {
      const request = CreateResponseRequest(
        model: 'gpt-5.5',
        input: ResponseInput.text('hello'),
        moderation: ModerationConfig(model: 'omni-moderation-latest'),
      );
      expect(request.toJson()['moderation'], {
        'model': 'omni-moderation-latest',
      });
      expect(
        CreateResponseRequest.fromJson(request.toJson()).moderation,
        request.moderation,
      );
      // copyWith preserves moderation when omitted, clears it when nulled.
      expect(request.copyWith().moderation, request.moderation);
      expect(request.copyWith(moderation: null).moderation, isNull);
    });
  });

  group('moderation on responses', () {
    test('ChatCompletion parses moderation', () {
      final completion = ChatCompletion.fromJson({
        'object': 'chat.completion',
        'model': 'gpt-5.5',
        'choices': const <Map<String, dynamic>>[],
        'moderation': {
          'input': {
            'type': 'moderation_results',
            'model': 'omni-moderation-latest',
            'results': [_resultBodyJson()],
          },
          'output': {
            'type': 'moderation_results',
            'model': 'omni-moderation-latest',
            'results': [_resultBodyJson(flagged: false)],
          },
        },
      });
      expect(completion.moderation, isNotNull);
      expect(completion.toJson()['moderation'], isNotNull);
    });

    test('Response parses moderation', () {
      final response = Response.fromJson({
        'id': 'resp_1',
        'object': 'response',
        'created_at': 0,
        'status': 'completed',
        'output': const <Map<String, dynamic>>[],
        'moderation': {'input': _resultBodyJson(), 'output': _errorBodyJson()},
      });
      expect(response.moderation, isNotNull);
      expect(response.moderation!.input, isA<ModerationResultBody>());
      expect(response.toJson()['moderation'], isNotNull);
    });
  });

  group('streaming moderation', () {
    test('ChatStreamEvent parses moderation chunk', () {
      final event = ChatStreamEvent.fromJson({
        'id': 'chatcmpl_1',
        'object': 'chat.completion.chunk',
        'choices': const <Map<String, dynamic>>[],
        'moderation': {
          'input': {
            'type': 'moderation_results',
            'model': 'omni-moderation-latest',
            'results': [_resultBodyJson()],
          },
          'output': _errorBodyJson(),
        },
      });
      expect(event.moderation, isNotNull);
      expect(event.toJson()['moderation'], isNotNull);
    });

    test('accumulator captures moderation and surfaces it on completion', () {
      final accumulator = ChatStreamAccumulator()
        ..add(
          ChatStreamEvent.fromJson(const {
            'id': 'chatcmpl_1',
            'object': 'chat.completion.chunk',
            'choices': [
              {
                'index': 0,
                'delta': {'content': 'hi'},
              },
            ],
          }),
        )
        ..add(
          ChatStreamEvent.fromJson({
            'id': 'chatcmpl_1',
            'object': 'chat.completion.chunk',
            'choices': const <Map<String, dynamic>>[],
            'moderation': {
              'input': {
                'type': 'moderation_results',
                'model': 'omni-moderation-latest',
                'results': [_resultBodyJson()],
              },
              'output': {
                'type': 'moderation_results',
                'model': 'omni-moderation-latest',
                'results': [_resultBodyJson(flagged: false)],
              },
            },
          }),
        );

      expect(accumulator.moderation, isNotNull);
      expect(accumulator.toChatCompletion().moderation, isNotNull);

      accumulator.reset();
      expect(accumulator.moderation, isNull);
    });
  });
}
