import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  const audio = ChatCompletionAudio(
    id: 'audio-private',
    data: 'data-private',
    transcript: 'transcript-private',
    expiresAt: 0,
  );

  group('Complete and reference audio (CHAT-003)', () {
    test(
      'const factories keep complete output distinct from replay references',
      () {
        const complete = ChatAudio.completion(
          id: 'audio-private',
          data: 'data-private',
          transcript: 'transcript-private',
          expiresAt: 0,
        );
        const reference = ChatAudio.reference(id: 'audio-private');
        expect(complete, audio);
        expect(complete.hashCode, audio.hashCode);
        expect(reference, const ChatAudioReference(id: 'audio-private'));
        expect(reference.toJson(), {'id': 'audio-private'});
        expect(ChatAudio.fromJson(reference.toJson()), reference);
        expect(ChatAudio.fromJson(audio.toJson()), audio);
        expect(audio, isNot(reference));
        const typedReference = reference as ChatAudioReference;
        expect(typedReference.copyWith(), reference);
        expect(typedReference.copyWith(id: 'other'), isNot(reference));
        expect(audio.copyWith(), audio);
        for (final changed in [
          audio.copyWith(id: 'other'),
          audio.copyWith(data: ''),
          audio.copyWith(transcript: ''),
          audio.copyWith(expiresAt: 1),
        ]) {
          expect(changed, isNot(audio));
          final parsed = ChatCompletionAudio.fromJson(changed.toJson());
          expect(parsed, changed);
          expect(parsed.hashCode, changed.hashCode);
          expect({audio, changed, parsed}, hasLength(2));
        }
        expect(audio.toString(), isNot(contains('-private')));
        expect(reference.toString(), isNot(contains('-private')));
        for (final field in ['id', 'data', 'transcript', 'expiresAt']) {
          expect(audio.toString(), contains('$field:'));
        }
      },
    );

    for (final field in ['id', 'data', 'transcript', 'expires_at']) {
      test(
        'complete $field is required and typed without fabricated values',
        () {
          final missing = audio.toJson()..remove(field);
          expect(
            () => ChatCompletionAudio.fromJson(missing),
            throwsA(_fieldError('ChatCompletionAudio.$field')),
          );
          for (final invalid in <Object?>[
            null,
            false,
            [],
            {},
            if (field == 'expires_at') ...['0', 1.5] else 1,
          ]) {
            final json = <String, dynamic>{...audio.toJson(), field: invalid};
            expect(
              () => ChatCompletionAudio.fromJson(json),
              throwsA(_fieldError('ChatCompletionAudio.$field')),
            );
          }
        },
      );
    }

    test(
      'reference requires a string ID and any output member selects complete parsing',
      () {
        for (final json in <Map<String, dynamic>>[
          {},
          {'id': null},
          {'id': 0},
        ]) {
          expect(
            () => ChatAudioReference.fromJson(json),
            throwsA(_fieldError('ChatAudioReference.id')),
          );
        }
        for (final field in ['data', 'transcript', 'expires_at']) {
          final json = <String, dynamic>{
            'id': 'audio-private',
            field: field == 'expires_at' ? 0 : '',
          };
          expect(() => ChatAudio.fromJson(json), throwsFormatException);
        }
        const empty = ChatCompletionAudio(
          id: '',
          data: '',
          transcript: '',
          expiresAt: 0,
        );
        expect(ChatCompletionAudio.fromJson(empty.toJson()), empty);
      },
    );
  });

  group('Partial audio model (CHAT-004)', () {
    const delta = ChatAudioDelta(
      id: 'audio-private',
      data: 'data-private',
      transcript: 'transcript-private',
      expiresAt: 0,
    );
    final fields =
        <
          String,
          (String, Object, ChatAudioDelta Function(ChatAudioDelta, Object?))
        >{
          'id': ('id', '', (d, value) => d.copyWith(id: value)),
          'data': ('data', '', (d, value) => d.copyWith(data: value)),
          'transcript': (
            'transcript',
            '',
            (d, value) => d.copyWith(transcript: value),
          ),
          'expiresAt': (
            'expires_at',
            0,
            (d, value) => d.copyWith(expiresAt: value),
          ),
        };
    for (final entry in fields.entries) {
      final (wire, emptyValue, replace) = entry.value;
      test(
        '${entry.key} works independently, preserves empty/zero, and clears',
        () {
          final partial = ChatAudioDelta.fromJson({wire: emptyValue});
          expect(partial.toJson(), {wire: emptyValue});
          expect(partial, isNot(const ChatAudioDelta()));
          expect(partial.isComplete, isFalse);
          expect(partial.toCompleteAudio, throwsStateError);
          final independent = ChatAudioDelta.fromJson(partial.toJson());
          expect(independent, partial);
          expect(independent.hashCode, partial.hashCode);
          expect(partial.copyWith(), partial);
          final cleared = replace(delta, null);
          expect(cleared.toJson(), delta.toJson()..remove(wire));
          expect(cleared.isComplete, isFalse);
          expect(cleared.toCompleteAudio, throwsStateError);
          expect(cleared, isNot(delta));
          final changed = replace(delta, wire == 'expires_at' ? 1 : 'other');
          expect(changed, isNot(delta));
          expect(changed, ChatAudioDelta.fromJson(changed.toJson()));
          expect(
            changed.hashCode,
            ChatAudioDelta.fromJson(changed.toJson()).hashCode,
          );
          expect(delta.toString(), contains('${entry.key}:'));
          expect(cleared.toString(), contains('${entry.key}: null'));
        },
      );

      test(
        '${entry.key} rejects present null and malformed partial values',
        () {
          for (final invalid in <Object?>[
            null,
            false,
            [],
            {},
            if (wire == 'expires_at') ...['0', 1.5] else 1,
          ]) {
            final json = <String, dynamic>{wire: invalid};
            expect(
              () => ChatAudioDelta.fromJson(json),
              throwsA(_fieldError('ChatAudioDelta.$wire')),
            );
          }
        },
      );
    }

    test(
      'complete conversion preserves empty strings and fails on missing members',
      () {
        expect(delta.isComplete, isTrue);
        expect(delta.toCompleteAudio(), audio);
        expect(ChatAudioDelta.fromJson(delta.toJson()), delta);
        expect(delta.copyWith(), delta);
        expect(delta.toString(), isNot(contains('-private')));
        const empty = ChatAudioDelta(
          id: '',
          data: '',
          transcript: '',
          expiresAt: 0,
        );
        expect(empty.isComplete, isTrue);
        expect(empty.toCompleteAudio().toJson(), empty.toJson());
        expect(const ChatAudioDelta().toJson(), isEmpty);
        expect(const ChatAudioDelta().toCompleteAudio, throwsStateError);
        expect(
          delta.copyWith(
            id: null,
            data: null,
            transcript: null,
            expiresAt: null,
          ),
          const ChatAudioDelta(),
        );
      },
    );
  });

  group('Assistant audio boundaries and value contracts', () {
    test(
      'generic parsing accepts references; response parsing requires complete audio',
      () {
        final reference = AssistantMessage.fromJson(const {
          'role': 'assistant',
          'audio': {'id': 'audio-private'},
        });
        expect(reference.audio, const ChatAudioReference(id: 'audio-private'));
        expect(reference.content, isNull);
        expect(reference.toJson(), {
          'role': 'assistant',
          'audio': {'id': 'audio-private'},
        });
        expect(
          () => AssistantMessage.fromResponseJson(reference.toJson()),
          throwsA(_fieldError('AssistantMessage.audio')),
        );
        final raw = <String, dynamic>{
          'role': 'assistant',
          'content': null,
          'audio': <dynamic, dynamic>{...audio.toJson()},
        };
        final response = AssistantMessage.fromResponseJson(raw);
        expect(response.audio, audio);
        expect(response.content, isNull);
        expect(response.toResponseJson(), raw);
        expect(response.toJson().containsKey('content'), isFalse);
        expect(response.toApiJson(), {
          'role': 'assistant',
          'audio': {'id': 'audio-private'},
        });
        expect(AssistantMessage.fromJson(response.toResponseJson()), response);
        expect(
          (ChatMessage.assistant(audio: audio) as AssistantMessage).audio,
          audio,
        );
      },
    );

    test(
      'outer null stays nullable and malformed audio fails with holder context',
      () {
        for (final response in [false, true]) {
          final parse = response
              ? AssistantMessage.fromResponseJson
              : AssistantMessage.fromJson;
          final omitted = parse(const {'role': 'assistant'});
          expect(parse(const {'role': 'assistant', 'audio': null}), omitted);
          expect(omitted.audio, isNull);
          for (final raw in <Object?>[
            false,
            '',
            [],
            <dynamic, dynamic>{1: 'bad'},
          ]) {
            final json = <String, dynamic>{'role': 'assistant', 'audio': raw};
            expect(
              () => parse(json),
              throwsA(_fieldError('AssistantMessage.audio')),
            );
          }
        }
      },
    );

    test(
      'all assistant fields participate with null clearing and payload summaries',
      () {
        final original = _assistant(audio);
        final changes = <String, AssistantMessage>{
          'content': original.copyWith(content: 'other'),
          'name': original.copyWith(name: 'other'),
          'refusal': original.copyWith(refusal: 'other'),
          'toolCalls': original.copyWith(toolCalls: []),
          'reasoningContent': original.copyWith(reasoningContent: 'other'),
          'reasoning': original.copyWith(reasoning: 'other'),
          'reasoningDetails': original.copyWith(reasoningDetails: []),
          'audio': original.copyWith(audio: audio.copyWith(data: 'other')),
        };
        expect(original.copyWith(), original);
        for (final entry in changes.entries) {
          expect(entry.value, isNot(original), reason: entry.key);
          final restored = AssistantMessage.fromJson(entry.value.toJson());
          expect(restored, entry.value, reason: entry.key);
          expect(restored.hashCode, entry.value.hashCode, reason: entry.key);
          expect(original.toString(), contains('${entry.key}:'));
        }
        final cleared = original.copyWith(
          content: null,
          name: null,
          refusal: null,
          toolCalls: null,
          reasoningContent: null,
          reasoning: null,
          reasoningDetails: null,
          audio: null,
        );
        expect(cleared, const AssistantMessage());
        expect(cleared.toJson(), {'role': 'assistant'});
        expect(cleared.toResponseJson(), {
          'role': 'assistant',
          'content': null,
        });
        expect(original.toString(), isNot(contains('-private')));
        expect(cleared.toString(), isNot(contains('null items')));
      },
    );
  });

  group('Complete audio response holders', () {
    test('audio-only response preserves the complete canonical message', () {
      final response = ChatCompletion.fromJson(_completionJson(audio));
      expect(response.audio, audio);
      expect(response.text, isNull);
      expect(response.toJson(), _completionJson(audio));
      final restored = ChatCompletion.fromJson(response.toJson());
      expect(restored, response);
      expect(restored.hashCode, response.hashCode);
      expect(response.toString(), isNot(contains('-private')));
      expect(response.firstChoice!.toString(), isNot(contains('-private')));
      expect(
        const ChatCompletion(
          object: 'chat.completion',
          model: 'model',
          choices: [],
        ).audio,
        isNull,
      );
      for (final partial in <Map<String, dynamic>>[
        {'id': 'audio-private'},
        {'id': 'audio-private', 'data': 'data-private'},
      ]) {
        final json = _completionJson(audio);
        ((json['choices'] as List).single as Map<String, dynamic>)['message'] =
            {'role': 'assistant', 'content': null, 'audio': partial};
        expect(
          () => ChatCompletion.fromJson(json),
          throwsA(_fieldError('AssistantMessage.audio')),
        );
      }
    });

    test(
      'full completion and choice field contracts preserve provider behavior',
      () {
        final base = ChatCompletion.fromJson(_completionJson(audio));
        final changes = <String, ChatCompletion>{
          'id': base.copyWith(id: 'other'),
          'object': base.copyWith(object: 'other'),
          'created': base.copyWith(created: 1),
          'model': base.copyWith(model: 'other'),
          'choices': base.copyWith(choices: []),
          'usage': base.copyWith(
            usage: const Usage(promptTokens: 1, totalTokens: 1),
          ),
          'systemFingerprint': base.copyWith(systemFingerprint: 'other'),
          'serviceTier': base.copyWith(serviceTier: 'other'),
          'moderation': base.copyWith(moderation: null),
          'provider': base.copyWith(provider: 'other'),
        };
        for (final entry in changes.entries) {
          expect(entry.value, isNot(base), reason: entry.key);
          final restored = ChatCompletion.fromJson(entry.value.toJson());
          expect(restored, entry.value, reason: entry.key);
          expect(restored.hashCode, entry.value.hashCode, reason: entry.key);
          expect(base.toString(), contains('${entry.key}:'));
        }
        expect(base.copyWith(), base);
        final cleared = base.copyWith(
          id: null,
          created: null,
          usage: null,
          systemFingerprint: null,
          serviceTier: null,
          moderation: null,
          provider: null,
        );
        for (final wire in [
          'id',
          'created',
          'usage',
          'system_fingerprint',
          'service_tier',
          'moderation',
          'provider',
        ]) {
          expect(cleared.toJson().containsKey(wire), isFalse);
        }
        final choice = base.firstChoice!;
        final choiceChanges = <String, ChatChoice>{
          'index': choice.copyWith(index: 1),
          'message': choice.copyWith(
            message: _assistant(audio.copyWith(transcript: 'other')),
          ),
          'finishReason': choice.copyWith(finishReason: FinishReason.length),
          'logprobs': choice.copyWith(logprobs: const Logprobs(content: [])),
        };
        for (final entry in choiceChanges.entries) {
          expect(entry.value, isNot(choice));
          final restored = ChatChoice.fromJson(entry.value.toJson());
          expect(restored, entry.value);
          expect(restored.hashCode, entry.value.hashCode);
          expect(choice.toString(), contains('${entry.key}:'));
        }
        expect(choice.copyWith(), choice);
        final clearedChoice = choice.copyWith(
          index: null,
          finishReason: null,
          logprobs: null,
        );
        expect(clearedChoice.toJson().keys, ['message']);
        final provider = ChatCompletion.fromJson(const {
          'choices': [
            {
              'message': {'role': 'assistant', 'content': 'text'},
            },
          ],
        });
        expect(provider.object, 'chat.completion');
        expect(provider.model, isEmpty);
        expect(provider.id, isNull);
        expect(provider.created, isNull);
        expect(provider.text, 'text');
        expect(provider.audio, isNull);
        expect(ChatCompletion.fromJson(const {}).choices, isEmpty);
      },
    );
  });
}

Matcher _fieldError(String field) => isA<FormatException>().having(
  (error) => error.message,
  'field context',
  contains(field),
);

AssistantMessage _assistant(ChatAudio audio) => AssistantMessage(
  content: 'content-private',
  name: 'name-private',
  refusal: 'refusal-private',
  toolCalls: const [
    ToolCall(
      id: 'call-private',
      type: 'function',
      function: FunctionCall(name: 'tool-private', arguments: '{}'),
    ),
  ],
  reasoningContent: 'reasoning-content-private',
  reasoning: 'reasoning-private',
  reasoningDetails: [
    ReasoningDetail.fromJson(const {
      'type': 'reasoning.text',
      'text': 'detail-private',
    }),
  ],
  audio: audio,
);

Map<String, dynamic> _completionJson(ChatCompletionAudio audio) => {
  'id': 'chatcmpl_fixture',
  'object': 'chat.completion',
  'created': 0,
  'model': 'fixture-model',
  'choices': [
    {
      'index': 0,
      'message': {
        'role': 'assistant',
        'content': null,
        'audio': audio.toJson(),
      },
      'finish_reason': 'stop',
      'logprobs': {'content': <Object>[], 'refusal': <Object>[]},
    },
  ],
  'usage': {'prompt_tokens': 1, 'completion_tokens': 1, 'total_tokens': 2},
  'system_fingerprint': 'fp_fixture',
  'service_tier': 'default',
  'moderation': {
    'input': {
      'type': 'error',
      'code': 'fixture',
      'message': 'moderation-private',
    },
    'output': {
      'type': 'error',
      'code': 'fixture',
      'message': 'moderation-private',
    },
  },
  'provider': 'fixture-provider',
};
