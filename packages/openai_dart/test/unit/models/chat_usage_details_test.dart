import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

typedef _PromptField = ({
  String wire,
  bool strict,
  int? Function(PromptTokensDetails) read,
  PromptTokensDetails Function(PromptTokensDetails, int?) replace,
});

typedef _CompletionField = ({
  String wire,
  bool strict,
  int? Function(CompletionTokensDetails) read,
  CompletionTokensDetails Function(CompletionTokensDetails, int?) replace,
});

void main() {
  const prompt = PromptTokensDetails(
    audioTokens: 1,
    cachedTokens: 2,
    cacheWriteTokens: 3,
    imageTokens: 4,
    textTokens: 5,
  );
  const completion = CompletionTokensDetails(
    audioTokens: 6,
    reasoningTokens: 7,
    acceptedPredictionTokens: 8,
    rejectedPredictionTokens: 9,
    textTokens: 10,
  );
  const usage = Usage(
    promptTokens: 100,
    completionTokens: 200,
    totalTokens: 300,
    promptTokensDetails: prompt,
    completionTokensDetails: completion,
  );

  final promptFields = <String, _PromptField>{
    'audioTokens': (
      wire: 'audio_tokens',
      strict: false,
      read: (d) => d.audioTokens,
      replace: (d, value) => d.copyWith(audioTokens: value),
    ),
    'cachedTokens': (
      wire: 'cached_tokens',
      strict: false,
      read: (d) => d.cachedTokens,
      replace: (d, value) => d.copyWith(cachedTokens: value),
    ),
    'cacheWriteTokens': (
      wire: 'cache_write_tokens',
      strict: true,
      read: (d) => d.cacheWriteTokens,
      replace: (d, value) => d.copyWith(cacheWriteTokens: value),
    ),
    'imageTokens': (
      wire: 'image_tokens',
      strict: true,
      read: (d) => d.imageTokens,
      replace: (d, value) => d.copyWith(imageTokens: value),
    ),
    'textTokens': (
      wire: 'text_tokens',
      strict: true,
      read: (d) => d.textTokens,
      replace: (d, value) => d.copyWith(textTokens: value),
    ),
  };

  group('PromptTokensDetails (CHAT-001)', () {
    for (final entry in promptFields.entries) {
      final field = entry.value;
      test('${entry.key} preserves zero and distinguishes absence', () {
        final wire = <String, dynamic>{field.wire: 0};
        final parsed = PromptTokensDetails.fromJson(wire);
        final independentlyParsed = PromptTokensDetails.fromJson({
          field.wire: 0,
        });
        final absent = PromptTokensDetails.fromJson(const {});

        expect(field.read(parsed), 0);
        expect(parsed.toJson(), wire);
        expect(field.read(absent), isNull);
        expect(absent.toJson(), isEmpty);
        expect(parsed, isNot(absent));
        expect(parsed, independentlyParsed);
        expect(parsed.hashCode, independentlyParsed.hashCode);
        expect(parsed.copyWith(), parsed);
        expect(parsed.toString(), contains('${entry.key}: 0'));
        expect(absent.toString(), contains('${entry.key}: null'));
        expect({parsed, independentlyParsed, absent}, hasLength(2));
      });

      test(
        '${entry.key} replacement and clearing preserve every other field',
        () {
          final changed = field.replace(prompt, 20);
          final cleared = field.replace(prompt, null);
          final expectedClear = prompt.toJson()..remove(field.wire);

          expect(changed.toJson(), {...prompt.toJson(), field.wire: 20});
          expect(changed, isNot(prompt));
          expect(changed, field.replace(prompt.copyWith(), 20));
          expect(
            changed.hashCode,
            field.replace(prompt.copyWith(), 20).hashCode,
          );
          expect(cleared.toJson(), expectedClear);
          expect(field.read(cleared), isNull);
          expect(cleared, isNot(prompt));
          final independentlyCleared = PromptTokensDetails.fromJson(
            expectedClear,
          );
          expect(cleared, independentlyCleared);
          expect(cleared.hashCode, independentlyCleared.hashCode);
        },
      );

      if (field.strict) {
        test(
          '${entry.key} rejects malformed present counters contextually',
          () {
            for (final invalid in <Object?>[
              null,
              1.5,
              1.0,
              '0',
              true,
              [],
              {},
            ]) {
              final json = <String, dynamic>{field.wire: invalid};
              expect(
                () => PromptTokensDetails.fromJson(json),
                throwsA(
                  isA<FormatException>().having(
                    (error) => error.message,
                    'field context',
                    contains('PromptTokensDetails.${field.wire}'),
                  ),
                ),
              );
            }
            // The schema defines an integer without a minimum.
            final negative = PromptTokensDetails.fromJson({field.wire: -1});
            expect(field.read(negative), -1);
          },
        );
      } else {
        test('${entry.key} retains legacy parsed-null compatibility', () {
          final parsed = PromptTokensDetails.fromJson({field.wire: null});
          expect(field.read(parsed), isNull);
          expect(parsed.toJson(), isEmpty);
          expect(parsed, const PromptTokensDetails());
        });
      }
    }

    test(
      'const construction and full value contract retain all prompt fields',
      () {
        expect(prompt.toJson(), {
          'audio_tokens': 1,
          'cached_tokens': 2,
          'cache_write_tokens': 3,
          'image_tokens': 4,
          'text_tokens': 5,
        });
        final parsed = PromptTokensDetails.fromJson(prompt.toJson());
        expect(parsed, prompt);
        expect(parsed.hashCode, prompt.hashCode);
        expect(prompt.copyWith(), prompt);
        expect(
          prompt.copyWith(
            audioTokens: null,
            cachedTokens: null,
            cacheWriteTokens: null,
            imageTokens: null,
            textTokens: null,
          ),
          const PromptTokensDetails(),
        );
        for (final field in promptFields.keys) {
          expect(prompt.toString(), contains('$field:'));
        }
      },
    );
  });

  final completionFields = <String, _CompletionField>{
    'audioTokens': (
      wire: 'audio_tokens',
      strict: false,
      read: (d) => d.audioTokens,
      replace: (d, value) => d.copyWith(audioTokens: value),
    ),
    'reasoningTokens': (
      wire: 'reasoning_tokens',
      strict: false,
      read: (d) => d.reasoningTokens,
      replace: (d, value) => d.copyWith(reasoningTokens: value),
    ),
    'acceptedPredictionTokens': (
      wire: 'accepted_prediction_tokens',
      strict: false,
      read: (d) => d.acceptedPredictionTokens,
      replace: (d, value) => d.copyWith(acceptedPredictionTokens: value),
    ),
    'rejectedPredictionTokens': (
      wire: 'rejected_prediction_tokens',
      strict: false,
      read: (d) => d.rejectedPredictionTokens,
      replace: (d, value) => d.copyWith(rejectedPredictionTokens: value),
    ),
    'textTokens': (
      wire: 'text_tokens',
      strict: true,
      read: (d) => d.textTokens,
      replace: (d, value) => d.copyWith(textTokens: value),
    ),
  };

  group('CompletionTokensDetails (CHAT-001)', () {
    for (final entry in completionFields.entries) {
      final field = entry.value;
      test('${entry.key} preserves zero and distinguishes absence', () {
        final wire = <String, dynamic>{field.wire: 0};
        final parsed = CompletionTokensDetails.fromJson(wire);
        final independentlyParsed = CompletionTokensDetails.fromJson({
          field.wire: 0,
        });
        final absent = CompletionTokensDetails.fromJson(const {});

        expect(field.read(parsed), 0);
        expect(parsed.toJson(), wire);
        expect(field.read(absent), isNull);
        expect(absent.toJson(), isEmpty);
        expect(parsed, isNot(absent));
        expect(parsed, independentlyParsed);
        expect(parsed.hashCode, independentlyParsed.hashCode);
        expect(parsed.copyWith(), parsed);
        expect(parsed.toString(), contains('${entry.key}: 0'));
        expect(absent.toString(), contains('${entry.key}: null'));
        expect({parsed, independentlyParsed, absent}, hasLength(2));
      });

      test(
        '${entry.key} replacement and clearing preserve every other field',
        () {
          final changed = field.replace(completion, 20);
          final cleared = field.replace(completion, null);
          final expectedClear = completion.toJson()..remove(field.wire);

          expect(changed.toJson(), {...completion.toJson(), field.wire: 20});
          expect(changed, isNot(completion));
          expect(changed, field.replace(completion.copyWith(), 20));
          expect(
            changed.hashCode,
            field.replace(completion.copyWith(), 20).hashCode,
          );
          expect(cleared.toJson(), expectedClear);
          expect(field.read(cleared), isNull);
          expect(cleared, isNot(completion));
          final independentlyCleared = CompletionTokensDetails.fromJson(
            expectedClear,
          );
          expect(cleared, independentlyCleared);
          expect(cleared.hashCode, independentlyCleared.hashCode);
        },
      );

      if (field.strict) {
        test(
          '${entry.key} rejects malformed present counters contextually',
          () {
            for (final invalid in <Object?>[
              null,
              1.5,
              1.0,
              '0',
              true,
              [],
              {},
            ]) {
              final json = <String, dynamic>{field.wire: invalid};
              expect(
                () => CompletionTokensDetails.fromJson(json),
                throwsA(
                  isA<FormatException>().having(
                    (error) => error.message,
                    'field context',
                    contains('CompletionTokensDetails.${field.wire}'),
                  ),
                ),
              );
            }
            final negative = CompletionTokensDetails.fromJson({field.wire: -1});
            expect(field.read(negative), -1);
          },
        );
      } else {
        test('${entry.key} retains legacy parsed-null compatibility', () {
          final parsed = CompletionTokensDetails.fromJson({field.wire: null});
          expect(field.read(parsed), isNull);
          expect(parsed.toJson(), isEmpty);
          expect(parsed, const CompletionTokensDetails());
        });
      }
    }

    test(
      'const construction and full value contract retain all completion fields',
      () {
        expect(completion.toJson(), {
          'audio_tokens': 6,
          'reasoning_tokens': 7,
          'accepted_prediction_tokens': 8,
          'rejected_prediction_tokens': 9,
          'text_tokens': 10,
        });
        final parsed = CompletionTokensDetails.fromJson(completion.toJson());
        expect(parsed, completion);
        expect(parsed.hashCode, completion.hashCode);
        expect(completion.copyWith(), completion);
        expect(
          completion.copyWith(
            audioTokens: null,
            reasoningTokens: null,
            acceptedPredictionTokens: null,
            rejectedPredictionTokens: null,
            textTokens: null,
          ),
          const CompletionTokensDetails(),
        );
        for (final field in completionFields.keys) {
          expect(completion.toString(), contains('$field:'));
        }
      },
    );
  });

  group('Usage holders and compatibility (CHAT-001)', () {
    test(
      'both detail objects survive a full usage round-trip and diagnostics',
      () {
        final parsed = Usage.fromJson(usage.toJson());
        expect(parsed, usage);
        expect(parsed.hashCode, usage.hashCode);
        expect(parsed.promptTokensDetails, prompt);
        expect(parsed.completionTokensDetails, completion);
        expect(usage.copyWith(), usage);
        final diagnostic = usage.toString();
        for (final field in [
          'promptTokens',
          'completionTokens',
          'totalTokens',
          'promptTokensDetails',
          'completionTokensDetails',
          ...promptFields.keys,
          ...completionFields.keys,
        ]) {
          expect(diagnostic, contains('$field:'));
        }
      },
    );

    test(
      'nested counter changes and clears affect Usage equality and hashes',
      () {
        final changes = <Usage>[
          usage.copyWith(promptTokens: 101),
          usage.copyWith(completionTokens: 201),
          usage.copyWith(totalTokens: 301),
          for (final field in promptFields.values)
            usage.copyWith(promptTokensDetails: field.replace(prompt, 20)),
          for (final field in completionFields.values)
            usage.copyWith(
              completionTokensDetails: field.replace(completion, 20),
            ),
        ];
        for (final changed in changes) {
          expect(changed, isNot(usage));
          final independent = Usage.fromJson(changed.toJson());
          expect(changed, independent);
          expect(changed.hashCode, independent.hashCode);
          expect({usage, changed, independent}, hasLength(2));
        }
        final cleared = usage.copyWith(
          completionTokens: null,
          promptTokensDetails: null,
          completionTokensDetails: null,
        );
        expect(cleared.toJson(), {'prompt_tokens': 100, 'total_tokens': 300});
        expect(cleared, isNot(usage));
        expect(Usage.fromJson(cleared.toJson()), cleared);
        expect(cleared.toString(), contains('promptTokensDetails: null'));
        expect(cleared.toString(), contains('completionTokensDetails: null'));
      },
    );

    test(
      'provider omission, outer nulls, and old counter nulls remain compatible',
      () {
        final json = <String, dynamic>{'prompt_tokens': 10, 'total_tokens': 10};
        final omitted = Usage.fromJson(json);
        final explicitNull = Usage.fromJson({
          ...json,
          'completion_tokens': null,
          'prompt_tokens_details': null,
          'completion_tokens_details': null,
        });
        expect(omitted.completionTokens, isNull);
        expect(omitted.promptTokensDetails, isNull);
        expect(omitted.completionTokensDetails, isNull);
        expect(explicitNull, omitted);
        expect(explicitNull.hashCode, omitted.hashCode);
        expect(explicitNull.toJson(), json);

        final legacy = Usage.fromJson({
          ...json,
          'prompt_tokens_details': const {
            'audio_tokens': null,
            'cached_tokens': null,
          },
          'completion_tokens_details': const {
            'audio_tokens': null,
            'reasoning_tokens': null,
            'accepted_prediction_tokens': null,
            'rejected_prediction_tokens': null,
          },
        });
        expect(legacy.promptTokensDetails, const PromptTokensDetails());
        expect(legacy.completionTokensDetails, const CompletionTokensDetails());
        expect(legacy.toJson(), {
          ...json,
          'prompt_tokens_details': <String, dynamic>{},
          'completion_tokens_details': <String, dynamic>{},
        });
      },
    );

    test(
      'embedding-shaped usage and the separate embedding holder stay compatible',
      () {
        const embeddingJson = {'prompt_tokens': 10, 'total_tokens': 10};
        final generic = Usage.fromJson(embeddingJson);
        expect(generic.toJson(), embeddingJson);
        expect(generic.completionTokens, isNull);

        final response = EmbeddingResponse.fromJson(const {
          'object': 'list',
          'model': 'fixture-embedding-model',
          'data': [
            {
              'object': 'embedding',
              'index': 0,
              'embedding': [0.1, 0.2],
            },
          ],
          'usage': embeddingJson,
        });
        expect(
          response.usage,
          const EmbeddingUsage(promptTokens: 10, totalTokens: 10),
        );
        expect(response.usage!.toJson(), embeddingJson);
      },
    );

    test(
      'ordinary Chat and the final usage-only chunk preserve all counters',
      () {
        final ordinary = ChatCompletion.fromJson({
          'id': 'chatcmpl_fixture',
          'object': 'chat.completion',
          'created': 0,
          'model': 'fixture-model',
          'choices': const [
            {
              'index': 0,
              'message': {'role': 'assistant', 'content': 'ok'},
              'finish_reason': 'stop',
              'logprobs': null,
            },
          ],
          'usage': usage.toJson(),
        });
        expect(ordinary.usage, usage);
        expect(ordinary.usage!.toJson(), usage.toJson());
        expect(ordinary.usage!.hashCode, usage.hashCode);
        final finalChunk = ChatStreamEvent.fromJson({
          'id': 'chatcmpl_fixture',
          'object': 'chat.completion.chunk',
          'created': 0,
          'model': 'fixture-model',
          'choices': const <Object>[],
          'usage': usage.toJson(),
        });
        expect(finalChunk.choices, isEmpty);
        expect(finalChunk.usage, usage);
        expect(finalChunk.toJson()['usage'], usage.toJson());
        expect(finalChunk.usage!.hashCode, usage.hashCode);
      },
    );
  });
}
