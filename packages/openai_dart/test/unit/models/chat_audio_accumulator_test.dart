import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ChatDelta audio (CHAT-004)', () {
    for (final audioJson in <Map<String, dynamic>>[
      {},
      {'id': ''},
      {'data': ''},
      {'transcript': ''},
      {'expires_at': 0},
      {
        'id': 'audio_fixture',
        'data': 'data-private',
        'transcript': 'transcript-private',
        'expires_at': 0,
      },
    ]) {
      test('preserves independently optional fields: ${audioJson.keys}', () {
        final delta = ChatDelta.fromJson({'audio': audioJson});
        expect(delta.audio, isNotNull);
        expect(delta.toJson(), {'audio': audioJson});
        final restored = ChatDelta.fromJson(delta.toJson());
        expect(restored, delta);
        expect(restored.hashCode, delta.hashCode);
        expect(delta.copyWith(), delta);
        expect(delta.copyWith(audio: null), const ChatDelta());
        expect(delta.copyWith(audio: null).toJson(), isEmpty);
        expect(delta, isNot(const ChatDelta()));
        expect(delta.toString(), contains('audio:'));
        expect(delta.toString(), isNot(contains('-private')));
      });
    }
    test('normalizes valid string-keyed generic audio maps', () {
      final delta = ChatDelta.fromJson(const {
        'audio': <dynamic, dynamic>{'id': 'audio_fixture'},
      });
      expect(delta.audio!.id, 'audio_fixture');
      expect(delta.toJson(), {
        'audio': {'id': 'audio_fixture'},
      });
    });
    for (final invalid in <Object?>[
      null,
      false,
      1,
      [],
      'audio',
      <dynamic, dynamic>{1: 'bad key'},
    ]) {
      test('rejects malformed supplied audio object: $invalid', () {
        expect(
          () => ChatDelta.fromJson({'audio': invalid}),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'context',
              contains('ChatDelta.audio'),
            ),
          ),
        );
      });
    }
    test('copy supports all existing fields and nullable list clearing', () {
      const delta = ChatDelta(
        role: 'assistant',
        content: 'content-private',
        refusal: 'refusal-private',
        toolCalls: [ToolCallDelta(index: 0)],
        reasoningContent: 'reasoning-private',
        reasoning: 'summary-private',
        reasoningDetails: [],
        audio: ChatAudioDelta(id: 'audio_fixture'),
      );
      final changes = [
        delta.copyWith(role: 'other'),
        delta.copyWith(content: ''),
        delta.copyWith(refusal: ''),
        delta.copyWith(toolCalls: []),
        delta.copyWith(reasoningContent: ''),
        delta.copyWith(reasoning: ''),
        delta.copyWith(reasoningDetails: null),
        delta.copyWith(audio: const ChatAudioDelta(data: '')),
      ];
      for (final changed in changes) {
        expect(changed, isNot(delta));
        final restored = ChatDelta.fromJson(changed.toJson());
        expect(restored, changed);
        expect(restored.hashCode, changed.hashCode);
      }
      expect(delta.copyWith(), delta);
      expect(delta.copyWith(toolCalls: []).toolCalls, isEmpty);
      expect(delta.copyWith(reasoningDetails: []).reasoningDetails, isEmpty);
      expect(
        delta.copyWith(
          role: null,
          content: null,
          refusal: null,
          toolCalls: null,
          reasoningContent: null,
          reasoning: null,
          reasoningDetails: null,
          audio: null,
        ),
        const ChatDelta(),
      );
      for (final field in [
        'role',
        'content',
        'refusal',
        'toolCalls',
        'reasoningContent',
        'reasoning',
        'reasoningDetails',
        'audio',
      ]) {
        expect(delta.toString(), contains('$field:'));
      }
      expect(delta.toString(), isNot(contains('-private')));
      expect(const ChatDelta().toString(), isNot(contains('null items')));
    });
  });

  group('ChatStreamAccumulator audio (CHAT-005)', () {
    test('missing versus empty audio produces stable partial snapshots', () {
      final accumulator = ChatStreamAccumulator();
      expect(accumulator.audio, isNull);
      accumulator.add(_event(0, const ChatDelta(audio: ChatAudioDelta())));
      final empty = accumulator.audio!;
      final choice = accumulator.choices.single;
      expect(empty.toJson(), isEmpty);
      expect(empty.isComplete, isFalse);
      expect(choice.audio, empty);
      expect(accumulator.toChatCompletion, throwsStateError);
      accumulator.add(
        _event(
          0,
          const ChatDelta(
            audio: ChatAudioDelta(
              id: '',
              data: '',
              transcript: '',
              expiresAt: 0,
            ),
          ),
        ),
      );
      expect(accumulator.audio!.toJson(), {
        'id': '',
        'data': '',
        'transcript': '',
        'expires_at': 0,
      });
      expect(accumulator.audio!.isComplete, isTrue);
      expect(empty.toJson(), isEmpty);
      expect(choice.audio!.toJson(), isEmpty);
      final completion = accumulator.toChatCompletion();
      expect(completion.audio!.id, '');
      expect(completion.audio!.data, '');
      expect(completion.audio!.transcript, '');
      expect(completion.audio!.expiresAt, 0);
      expect(completion.choices.single.finishReason, isNull);
      accumulator.reset();
      expect(accumulator.audio, isNull);
      expect(accumulator.choices, isEmpty);
      expect(accumulator.finishReason, isNull);
      expect(choice.audio!.toJson(), isEmpty);
      accumulator.add(_event(0, const ChatDelta(content: 'after reset')));
      expect(accumulator.audio, isNull);
      expect(accumulator.toChatCompletion().text, 'after reset');
    });

    test(
      'interleaved choices append opaque fragments and update id/expiry',
      () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            _event(
              0,
              const ChatDelta(
                role: 'assistant',
                audio: ChatAudioDelta(
                  id: 'audio_0',
                  data: 'YW',
                  transcript: 'hel',
                ),
              ),
            ),
          )
          ..add(
            _event(
              1,
              const ChatDelta(
                role: 'assistant',
                audio: ChatAudioDelta(
                  id: 'audio_1',
                  data: 'AA',
                  transcript: 'first',
                ),
              ),
            ),
          );
        final earlyZero = accumulator.audio!;
        final earlyChoices = accumulator.choices;
        accumulator
          ..add(
            _event(
              1,
              const ChatDelta(
                audio: ChatAudioDelta(
                  data: '==',
                  transcript: ' second',
                  expiresAt: 20,
                ),
              ),
            ),
          )
          ..add(
            _event(
              0,
              const ChatDelta(
                audio: ChatAudioDelta(
                  id: 'audio_replaced',
                  data: 'Jj',
                  transcript: 'lo',
                ),
              ),
            ),
          )
          ..add(
            _event(
              0,
              const ChatDelta(
                audio: ChatAudioDelta(data: 'ZA==', expiresAt: 10),
              ),
            ),
          )
          ..add(
            _event(0, const ChatDelta(audio: ChatAudioDelta(expiresAt: 0))),
          );
        expect(accumulator.audio!.toJson(), {
          'id': 'audio_replaced',
          'data': 'YWJjZA==',
          'transcript': 'hello',
          'expires_at': 0,
        });
        expect(accumulator.choices[1].audio!.toJson(), {
          'id': 'audio_1',
          'data': 'AA==',
          'transcript': 'first second',
          'expires_at': 20,
        });
        expect(earlyZero.toJson(), {
          'id': 'audio_0',
          'data': 'YW',
          'transcript': 'hel',
        });
        expect(earlyChoices[0].audio, earlyZero);
        expect(earlyChoices[1].audio!.data, 'AA');
        expect(accumulator.finishReason, isNull);
        expect(accumulator.choices[0].finishReason, isNull);
        expect(accumulator.choices[1].finishReason, isNull);
        final completion = accumulator.toChatCompletion();
        expect(completion.audio!.data, 'YWJjZA==');
        expect(completion.choices[1].message.audio!.id, 'audio_1');
        expect(accumulator.content, isEmpty);
        expect(accumulator.reasoning, isEmpty);
        expect(accumulator.toolCalls, isEmpty);
      },
    );

    for (final existing in <FinishReason?>[
      null,
      FinishReason.length,
      FinishReason.toolCalls,
    ]) {
      test(
        'pure expiry infers stop without overwriting wire finish=$existing',
        () {
          final accumulator = _completeWithoutExpiry();
          if (existing != null) {
            accumulator.add(_event(0, const ChatDelta(), finish: existing));
          }
          final raw = _event(
            0,
            const ChatDelta(audio: ChatAudioDelta(expiresAt: 0)),
          );
          accumulator.add(raw);
          expect(raw.firstChoice!.finishReason, isNull);
          expect(raw.firstChoice!.isFinal, isFalse);
          expect(accumulator.finishReason, existing);
          expect(
            accumulator.toChatCompletion().choices.single.finishReason,
            existing ?? FinishReason.stop,
          );
        },
      );
    }

    final mixedDeltas = <String, ChatDelta>{
      'content empty': const ChatDelta(
        content: '',
        audio: ChatAudioDelta(expiresAt: 0),
      ),
      'refusal empty': const ChatDelta(
        refusal: '',
        audio: ChatAudioDelta(expiresAt: 0),
      ),
      'role': const ChatDelta(
        role: 'assistant',
        audio: ChatAudioDelta(expiresAt: 0),
      ),
      'tools empty': const ChatDelta(
        toolCalls: [],
        audio: ChatAudioDelta(expiresAt: 0),
      ),
      'reasoning': const ChatDelta(
        reasoning: '',
        audio: ChatAudioDelta(expiresAt: 0),
      ),
      'reasoning content': const ChatDelta(
        reasoningContent: '',
        audio: ChatAudioDelta(expiresAt: 0),
      ),
      'reasoning details': const ChatDelta(
        reasoningDetails: [],
        audio: ChatAudioDelta(expiresAt: 0),
      ),
      'data empty': const ChatDelta(
        audio: ChatAudioDelta(data: '', expiresAt: 0),
      ),
      'id empty': const ChatDelta(audio: ChatAudioDelta(id: '', expiresAt: 0)),
      'transcript empty': const ChatDelta(
        audio: ChatAudioDelta(transcript: '', expiresAt: 0),
      ),
    };
    for (final entry in mixedDeltas.entries) {
      test('${entry.key} prevents pure-expiry stop inference', () {
        final accumulator = _completeWithoutExpiry()
          ..add(_event(0, entry.value));
        expect(accumulator.audio!.isComplete, isTrue);
        expect(accumulator.finishReason, isNull);
        expect(
          accumulator.toChatCompletion().choices.single.finishReason,
          isNull,
        );
      });
    }
    test(
      'last processed delta marker survives absent/null delta and usage-only events',
      () {
        final accumulator = _completeWithoutExpiry()
          ..add(_event(0, const ChatDelta(audio: ChatAudioDelta(expiresAt: 0))))
          ..add(
            ChatStreamEvent.fromJson(const {
              'choices': [
                {'index': 0},
              ],
            }),
          )
          ..add(
            ChatStreamEvent.fromJson(const {
              'choices': [
                {'index': 0, 'delta': null},
              ],
            }),
          )
          ..add(
            const ChatStreamEvent(
              choices: [],
              usage: Usage(promptTokens: 1, totalTokens: 1),
            ),
          );
        expect(accumulator.finishReason, isNull);
        expect(
          accumulator.toChatCompletion().choices.single.finishReason,
          FinishReason.stop,
        );
        accumulator.add(_event(0, const ChatDelta()));
        expect(accumulator.finishReason, isNull);
        expect(
          accumulator.toChatCompletion().choices.single.finishReason,
          isNull,
        );
      },
    );

    test(
      'absent/null deltas retain logprobs without invalidating final audio inference',
      () {
        final accumulator = _completeWithoutExpiry()
          ..add(_event(0, const ChatDelta(audio: ChatAudioDelta(expiresAt: 0))))
          ..add(
            ChatStreamEvent.fromJson(const {
              'choices': [
                {
                  'index': 0,
                  'logprobs': {
                    'content': [
                      {'token': 'a', 'logprob': 0},
                    ],
                  },
                },
              ],
            }),
          );
        final early = accumulator.choices.single;
        accumulator.add(
          ChatStreamEvent.fromJson(const {
            'choices': [
              {
                'index': 0,
                'delta': null,
                'logprobs': {
                  'content': [
                    {'token': 'b', 'logprob': 0},
                  ],
                },
              },
            ],
          }),
        );
        expect(early.logprobs!.content!.map((token) => token.token), ['a']);
        expect(
          accumulator.choices.single.logprobs!.content!.map(
            (token) => token.token,
          ),
          ['a', 'b'],
        );
        expect(() => early.logprobs!.content!.clear(), throwsUnsupportedError);
        expect(
          accumulator.toChatCompletion().choices.single.finishReason,
          FinishReason.stop,
        );
        expect(
          accumulator.toChatCompletion().choices.single.logprobs!.content,
          hasLength(2),
        );
      },
    );

    test(
      'additional JSON provenance stays frozen and participates in value contracts',
      () {
        final nested = <String, dynamic>{
          'items': [1, 2],
          'opaque': 'payload-private',
        };
        final delta = ChatDelta.fromJson({
          'audio': const {'expires_at': 0},
          'future': nested,
          'reasoning': null,
        });
        final same = ChatDelta.fromJson(const {
          'reasoning': null,
          'future': {
            'opaque': 'payload-private',
            'items': [1, 2],
          },
          'audio': {'expires_at': 0},
        });
        expect(same, delta);
        expect(same.hashCode, delta.hashCode);
        expect({same, delta}, hasLength(1));
        expect(
          delta,
          isNot(const ChatDelta(audio: ChatAudioDelta(expiresAt: 0))),
        );
        nested['opaque'] = 'changed';
        (nested['items'] as List).clear();
        expect(delta.toJson()['future'], {
          'items': [1, 2],
          'opaque': 'payload-private',
        });
        expect(
          () => (delta.toJson()['future'] as Map<String, dynamic>)['opaque'] =
              'changed',
          throwsUnsupportedError,
        );
        expect(delta.toString(), isNot(contains('payload-private')));
        expect(
          delta.copyWith(reasoning: null).toJson().containsKey('reasoning'),
          isFalse,
        );
        for (final json in <Map<String, dynamic>>[
          {},
          {'delta': null},
          {'delta': <String, dynamic>{}},
        ]) {
          final choice = ChatStreamChoice.fromJson(json);
          expect(choice.toJson(), json);
          expect(ChatStreamChoice.fromJson(choice.toJson()), choice);
          expect(
            ChatStreamChoice.fromJson(choice.toJson()).hashCode,
            choice.hashCode,
          );
          expect(choice.copyWith(), choice);
        }
        expect(
          ChatStreamChoice.fromJson(const {}),
          isNot(const ChatStreamChoice(delta: ChatDelta())),
        );
        expect(
          ChatStreamChoice.fromJson(
            const {},
          ).copyWith(delta: const ChatDelta()),
          const ChatStreamChoice(delta: ChatDelta()),
        );
      },
    );

    test(
      'snapshot fields have complete copy/value contracts and readonly collections',
      () {
        final accumulator = ChatStreamAccumulator()
          ..add(
            _event(
              0,
              const ChatDelta(
                role: 'assistant',
                content: 'content-private',
                refusal: 'refusal-private',
                reasoningContent: 'reasoning-private',
                reasoning: 'summary-private',
                reasoningDetails: [],
                audio: ChatAudioDelta(id: 'audio_fixture'),
              ),
              finish: FinishReason.length,
            ),
          );
        final snapshot = accumulator.choices.single;
        final variants = <String, AccumulatedChoice>{
          'index': snapshot.copyWith(index: 1),
          'content': snapshot.copyWith(content: ''),
          'refusal': snapshot.copyWith(refusal: ''),
          'role': snapshot.copyWith(role: null),
          'finishReason': snapshot.copyWith(finishReason: null),
          'toolCalls': snapshot.copyWith(
            toolCalls: [
              const ToolCall(
                id: 'call',
                type: 'function',
                function: FunctionCall(name: 'lookup', arguments: '{}'),
              ),
            ],
          ),
          'reasoningContent': snapshot.copyWith(reasoningContent: ''),
          'reasoning': snapshot.copyWith(reasoning: ''),
          'reasoningDetails': snapshot.copyWith(
            reasoningDetails: [
              ReasoningDetail.fromJson(const {
                'type': 'reasoning.text',
                'text': 'detail',
              }),
            ],
          ),
          'reasoningDetailsPresent': snapshot.copyWith(
            reasoningDetailsPresent: false,
          ),
          'logprobs': snapshot.copyWith(logprobs: const Logprobs(content: [])),
          'audio': snapshot.copyWith(audio: null),
        };
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        for (final entry in variants.entries) {
          expect(entry.value, isNot(snapshot), reason: entry.key);
          expect(entry.value.copyWith(), entry.value);
          expect(entry.value.copyWith().hashCode, entry.value.hashCode);
          expect(snapshot.toString(), contains('${entry.key}:'));
        }
        expect(snapshot.copyWith(toolCalls: []).toolCalls, isEmpty);
        expect(
          snapshot.copyWith(reasoningDetails: []).reasoningDetails,
          isEmpty,
        );
        expect(
          snapshot
              .copyWith(
                role: null,
                finishReason: null,
                logprobs: null,
                audio: null,
              )
              .audio,
          isNull,
        );
        expect(snapshot.toString(), isNot(contains('-private')));
        expect(() => accumulator.choices.clear(), throwsUnsupportedError);
        expect(snapshot.toolCalls.clear, throwsUnsupportedError);
        expect(snapshot.reasoningDetails.clear, throwsUnsupportedError);
      },
    );

    for (final extra in <Map<String, dynamic>>[
      {'function_call': <String, dynamic>{}},
      {'unknown': null},
      {'reasoning': null},
      {'reasoning_content': null},
      {'reasoning_details': null},
    ]) {
      test(
        'additional parsed delta keys suppress inferred stop: ${extra.keys}',
        () {
          final delta = ChatDelta.fromJson({
            'audio': const {'expires_at': 0},
            ...extra,
          });
          final accumulator = _completeWithoutExpiry()..add(_event(0, delta));
          expect(accumulator.finishReason, isNull);
          expect(
            accumulator.toChatCompletion().choices.single.finishReason,
            isNull,
          );
          final restored = ChatDelta.fromJson(delta.toJson());
          expect(restored, delta);
          final roundTripped = _completeWithoutExpiry()
            ..add(_event(0, restored));
          expect(roundTripped.finishReason, isNull);
          expect(
            roundTripped.toChatCompletion().choices.single.finishReason,
            isNull,
          );
        },
      );
    }
    test(
      'legacy function_call null does not suppress pure expiry inference',
      () {
        final accumulator = _completeWithoutExpiry()
          ..add(
            _event(
              0,
              ChatDelta.fromJson(const {
                'audio': {'expires_at': 0},
                'function_call': null,
              }),
            ),
          );
        expect(accumulator.finishReason, isNull);
        expect(
          accumulator.toChatCompletion().choices.single.finishReason,
          FinishReason.stop,
        );
      },
    );

    test(
      'incomplete audio is never fabricated even with an explicit finish',
      () {
        for (final audio in const [
          ChatAudioDelta(),
          ChatAudioDelta(id: 'audio_fixture'),
          ChatAudioDelta(data: ''),
          ChatAudioDelta(transcript: ''),
          ChatAudioDelta(expiresAt: 0),
        ]) {
          final accumulator = ChatStreamAccumulator()
            ..add(
              _event(0, ChatDelta(audio: audio), finish: FinishReason.stop),
            );
          expect(accumulator.audio, audio);
          expect(
            accumulator.toChatCompletion,
            throwsA(
              isA<StateError>().having(
                (e) => e.message,
                'context',
                contains('choice 0'),
              ),
            ),
          );
        }
      },
    );
  });
}

ChatStreamAccumulator _completeWithoutExpiry() => ChatStreamAccumulator()
  ..add(
    _event(
      0,
      const ChatDelta(
        audio: ChatAudioDelta(id: 'audio_fixture', data: '', transcript: ''),
      ),
    ),
  );

ChatStreamEvent _event(int index, ChatDelta delta, {FinishReason? finish}) =>
    ChatStreamEvent(
      id: 'chatcmpl_fixture',
      model: 'fixture-model',
      created: 0,
      choices: [
        ChatStreamChoice(index: index, delta: delta, finishReason: finish),
      ],
    );
