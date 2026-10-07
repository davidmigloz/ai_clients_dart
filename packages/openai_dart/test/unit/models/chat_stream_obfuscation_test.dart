import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('StreamOptions obfuscation (CHAT-002)', () {
    for (final usage in [false, true]) {
      for (final obfuscation in [false, true]) {
        test('preserves both controls: usage=$usage padding=$obfuscation', () {
          final options = StreamOptions(
            includeUsage: usage,
            includeObfuscation: obfuscation,
          );
          final json = {
            'include_usage': usage,
            'include_obfuscation': obfuscation,
          };
          expect(options.toJson(), json);
          final restored = StreamOptions.fromJson(json);
          expect(restored, options);
          expect(restored.hashCode, options.hashCode);
          expect(options.copyWith(), options);
          expect(options.toString(), contains('includeUsage: $usage'));
          expect(
            options.toString(),
            contains('includeObfuscation: $obfuscation'),
          );
          expect(
            options.copyWith(includeObfuscation: !obfuscation),
            isNot(options),
          );
          expect(options.copyWith(includeUsage: !usage), isNot(options));
          expect(
            options.copyWith(includeUsage: null, includeObfuscation: null),
            const StreamOptions(),
          );
        });
      }
    }

    test(
      'absence, an empty object, and clearing retain the server default',
      () {
        const defaults = StreamOptions();
        expect(defaults.toJson(), isEmpty);
        expect(StreamOptions.fromJson(const {}), defaults);
        const configured = StreamOptions(
          includeUsage: true,
          includeObfuscation: false,
        );
        expect(configured.copyWith(includeObfuscation: null).toJson(), {
          'include_usage': true,
        });
        expect(
          const ChatCompletionCreateRequest(
                model: 'fixture-model',
                messages: [],
                streamOptions: configured,
              )
              .copyWith(streamOptions: null)
              .toJson()
              .containsKey('stream_options'),
          isFalse,
        );
        expect(StreamOptions.fromJson(const {'include_usage': null}), defaults);
      },
    );

    for (final invalid in <Object?>[null, 'false', 0, [], {}]) {
      test('rejects an invalid present include_obfuscation: $invalid', () {
        expect(
          () => StreamOptions.fromJson({'include_obfuscation': invalid}),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'context',
              contains('StreamOptions.include_obfuscation'),
            ),
          ),
        );
      });
    }
  });

  group('ChatStreamEvent obfuscation (CHAT-002)', () {
    for (final padding in ['padding-private', '']) {
      test('preserves ${padding.isEmpty ? 'empty' : 'nonempty'} padding', () {
        final json = {..._eventJson(), 'obfuscation': padding};
        final event = ChatStreamEvent.fromJson(json);
        expect(event.obfuscation, padding);
        expect(event.toJson(), json);
        final restored = ChatStreamEvent.fromJson(event.toJson());
        expect(restored, event);
        expect(restored.hashCode, event.hashCode);
        expect(event.copyWith(), event);
        expect(event.copyWith(obfuscation: null).toJson(), _eventJson());
        expect(event.copyWith(obfuscation: null), isNot(event));
        expect(event.copyWith(obfuscation: 'different'), isNot(event));
        expect(event.textDelta, isNull);
        expect(
          event.toString(),
          contains('obfuscation: ${padding.length} chars'),
        );
        expect(event.toString(), isNot(contains('padding-private')));
      });
    }

    test(
      'omission and nullable constructor fields preserve provider shapes',
      () {
        const empty = ChatStreamEvent();
        expect(empty.toJson(), isEmpty);
        expect(ChatStreamEvent.fromJson(const {}), empty);
        expect(ChatStreamEvent.fromJson(const {'usage': null}), empty);
        final provider = ChatStreamEvent.fromJson(const {
          'provider': 'fixture-provider',
          'choices': [
            {'delta': null},
          ],
        });
        expect(provider.id, isNull);
        expect(provider.created, isNull);
        expect(provider.firstChoice!.delta, const ChatDelta());
        expect(provider.firstChoice!.index, isNull);
        expect(provider.obfuscation, isNull);
        expect(provider.toJson().containsKey('obfuscation'), isFalse);
        expect(empty.toString(), contains('choices: null'));
        expect(empty.toString(), isNot(contains('null items')));
      },
    );

    for (final invalid in <Object?>[null, false, 7, [], {}]) {
      test('rejects invalid present obfuscation: $invalid', () {
        expect(
          () => ChatStreamEvent.fromJson({
            ..._eventJson(),
            'obfuscation': invalid,
          }),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'context',
              contains('ChatStreamEvent.obfuscation'),
            ),
          ),
        );
      });
    }

    test(
      'every event field participates in equality, copying, and diagnostics',
      () {
        final event = ChatStreamEvent.fromJson({
          ..._eventJson(),
          'choices': const [
            {
              'index': 0,
              'delta': {'content': 'content-private'},
            },
          ],
          'usage': const {
            'prompt_tokens': 1,
            'completion_tokens': 2,
            'total_tokens': 3,
          },
          'system_fingerprint': 'fp_fixture',
          'service_tier': 'default',
          'moderation': _moderationJson(),
          'provider': 'fixture-provider',
          'obfuscation': 'padding-private',
        });
        final changes = <String, ChatStreamEvent>{
          'id': event.copyWith(id: 'other-id'),
          'object': event.copyWith(object: 'other-object'),
          'created': event.copyWith(created: 1),
          'model': event.copyWith(model: 'other-model'),
          'choices': event.copyWith(choices: []),
          'usage': event.copyWith(
            usage: const Usage(promptTokens: 0, totalTokens: 0),
          ),
          'systemFingerprint': event.copyWith(
            systemFingerprint: 'other-fingerprint',
          ),
          'serviceTier': event.copyWith(serviceTier: 'other-tier'),
          'moderation': event.copyWith(moderation: null),
          'provider': event.copyWith(provider: 'other-provider'),
          'obfuscation': event.copyWith(obfuscation: ''),
        };
        for (final entry in changes.entries) {
          expect(entry.value, isNot(event), reason: entry.key);
          final restored = ChatStreamEvent.fromJson(entry.value.toJson());
          expect(restored, entry.value, reason: entry.key);
          expect(restored.hashCode, entry.value.hashCode, reason: entry.key);
          expect({entry.value, restored}, hasLength(1), reason: entry.key);
          expect(event.toString(), contains('${entry.key}:'));
        }
        expect(event.toString(), isNot(contains('content-private')));
        expect(event.toString(), isNot(contains('moderation-private')));
        expect(event.copyWith(choices: []).choices, isEmpty);
        expect(
          event.copyWith(
            id: null,
            object: null,
            created: null,
            model: null,
            choices: null,
            usage: null,
            systemFingerprint: null,
            serviceTier: null,
            moderation: null,
            provider: null,
            obfuscation: null,
          ),
          const ChatStreamEvent(),
        );
      },
    );
  });

  group('Streaming child value contracts', () {
    test(
      'choice finish reason, logprobs, and all copy fields are preserved',
      () {
        const choice = ChatStreamChoice(
          index: 0,
          delta: ChatDelta(content: 'content-private'),
          finishReason: FinishReason.stop,
          logprobs: Logprobs(content: [TokenLogprob(token: 'x', logprob: -1)]),
        );
        final variants = [
          choice.copyWith(index: 1),
          choice.copyWith(delta: const ChatDelta(refusal: 'refusal')),
          choice.copyWith(finishReason: FinishReason.length),
          choice.copyWith(logprobs: const Logprobs(refusal: [])),
        ];
        for (final variant in variants) {
          expect(variant, isNot(choice));
          final restored = ChatStreamChoice.fromJson(variant.toJson());
          expect(restored, variant);
          expect(restored.hashCode, variant.hashCode);
        }
        expect(choice.copyWith(), choice);
        expect(
          choice
              .copyWith(index: null, finishReason: null, logprobs: null)
              .toJson(),
          {
            'delta': {'content': 'content-private'},
          },
        );
        for (final field in ['index', 'delta', 'finishReason', 'logprobs']) {
          expect(choice.toString(), contains('$field:'));
        }
        expect(choice.toString(), isNot(contains('content-private')));
      },
    );

    test(
      'tool delta type and function contents participate through parent equality',
      () {
        const tool = ToolCallDelta(
          index: 0,
          id: 'call_fixture',
          type: 'function',
          function: FunctionCallDelta(
            name: 'function-private',
            arguments: 'args-private',
          ),
        );
        final variants = [
          tool.copyWith(index: 1),
          tool.copyWith(id: 'other-id'),
          tool.copyWith(type: 'other-type'),
          tool.copyWith(
            function: const FunctionCallDelta(
              name: 'other-name',
              arguments: 'args-private',
            ),
          ),
          tool.copyWith(
            function: const FunctionCallDelta(
              name: 'function-private',
              arguments: 'other-args',
            ),
          ),
        ];
        final original = _toolEvent(tool);
        for (final variant in variants) {
          expect(variant, isNot(tool));
          final restored = ToolCallDelta.fromJson(variant.toJson());
          expect(restored, variant);
          expect(restored.hashCode, variant.hashCode);
          expect(_toolEvent(variant), isNot(original));
          final eventRestored = ChatStreamEvent.fromJson(
            _toolEvent(variant).toJson(),
          );
          expect(eventRestored, _toolEvent(variant));
          expect(eventRestored.hashCode, _toolEvent(variant).hashCode);
        }
        expect(tool.copyWith(), tool);
        expect(tool.copyWith(id: null, type: null, function: null).toJson(), {
          'index': 0,
        });
        for (final field in ['index', 'id', 'type', 'function']) {
          expect(tool.toString(), contains('$field:'));
        }
        expect(tool.toString(), isNot(contains('-private')));
      },
    );

    test(
      'logprob byte and alternative changes reach stream event equality',
      () {
        ChatStreamEvent event(TokenLogprob token) => ChatStreamEvent(
          choices: [
            ChatStreamChoice(
              delta: const ChatDelta(),
              logprobs: Logprobs(content: [token]),
            ),
          ],
        );
        const token = TokenLogprob(
          token: 'x',
          logprob: -1,
          bytes: [120],
          topLogprobs: [
            TopLogprob(token: 'y', logprob: -2, bytes: [121]),
          ],
        );
        final original = event(token);
        final same = event(TokenLogprob.fromJson(token.toJson()));
        expect(same, original);
        expect(same.hashCode, original.hashCode);
        for (final json in [
          {
            ...token.toJson(),
            'bytes': [121],
          },
          {...token.toJson(), 'top_logprobs': <Object>[]},
          {
            ...token.toJson(),
            'top_logprobs': [
              {
                'token': 'y',
                'logprob': -2,
                'bytes': [122],
              },
            ],
          },
        ]) {
          expect(event(TokenLogprob.fromJson(json)), isNot(original));
        }
      },
    );
  });
}

Map<String, dynamic> _eventJson() => {
  'id': 'chatcmpl_fixture',
  'object': 'chat.completion.chunk',
  'created': 0,
  'model': 'fixture-model',
  'choices': <Object>[],
};

Map<String, dynamic> _moderationJson() => {
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
};

ChatStreamEvent _toolEvent(ToolCallDelta tool) => ChatStreamEvent(
  id: 'chatcmpl_fixture',
  created: 0,
  choices: [
    ChatStreamChoice(index: 0, delta: ChatDelta(toolCalls: [tool])),
  ],
);
