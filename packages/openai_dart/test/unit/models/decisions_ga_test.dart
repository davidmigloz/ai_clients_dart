import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Decisions GA history', () {
    final fixtures = <Map<String, dynamic>>[
      {
        'role': 'user',
        'content': [
          {
            'type': 'input_json',
            'data': {'urgent': true},
          },
        ],
      },
      {
        'role': 'developer',
        'content': [
          {
            'type': 'input_text',
            'text': 'Policy',
            'prompt_cache_breakpoint': {'mode': 'explicit'},
          },
        ],
      },
      {'role': 'system', 'content': 'Classify evidence.'},
      {
        'role': 'assistant',
        'content': [
          {'type': 'output_text', 'text': 'Checking'},
          {'type': 'refusal', 'refusal': 'Unable'},
        ],
        'phase': 'commentary',
      },
      {
        'type': 'function_call',
        'call_id': 'call_1',
        'name': 'order.lookup',
        'namespace': 'orders',
        'arguments': '{}',
        'status': 'completed',
        'id': 'item_1',
      },
      {
        'type': 'function_call_output',
        'call_id': 'call_1',
        'output': [
          {'type': 'input_text', 'text': 'Found'},
          {'type': 'input_image', 'image_url': 'https://example.com/order.png'},
        ],
        'status': 'completed',
      },
      {
        'type': 'custom_tool_call',
        'call_id': 'call_2',
        'name': 'lookup',
        'namespace': 'orders',
        'input': 'order 1',
      },
      {
        'type': 'custom_tool_call_output',
        'call_id': 'call_2',
        'output': 'Delivered',
        'id': null,
        'status': null,
      },
    ];

    test(
      'round-trips every input variant in order without executing tools',
      () {
        final input = DecisionInput.fromJson(fixtures) as MessagesDecisionInput;
        expect(input.items, hasLength(8));
        expect(input.items[0], isA<DecisionInputMessage>());
        expect(input.items[1], isA<DeveloperDecisionInputMessage>());
        expect(input.items[2], isA<SystemDecisionInputMessage>());
        expect(input.items[3], isA<AssistantDecisionInputMessage>());
        expect(input.items[4], isA<DecisionFunctionCall>());
        expect(input.items[5], isA<DecisionFunctionCallOutput>());
        expect(input.items[6], isA<DecisionCustomToolCall>());
        expect(input.items[7], isA<DecisionCustomToolCallOutput>());
        expect(input, DecisionInput.fromJson(input.toJson()));
        expect(input.hashCode, DecisionInput.fromJson(input.toJson()).hashCode);
        final serialized = input.toJson();
        expect(serialized.first['type'], 'message');
        expect(serialized.last.containsKey('status'), isFalse);
        expect(input.items.clear, throwsUnsupportedError);
      },
    );

    test('keeps legacy const messages and predicates usable', () {
      const message = DecisionInputMessage(
        content: DecisionContent.text('Hello'),
      );
      const question = DecisionQuestion.predicate(instructions: 'True?');
      expect(DecisionInput.messages(const [message]).toJson(), [
        {'type': 'message', 'role': 'user', 'content': 'Hello'},
      ]);
      expect(question.instructions, const DecisionInstructions.text('True?'));
      expect(question.toJson()['instructions'], 'True?');
    });

    test(
      'typed content constructors preserve role-specific arrays and copy values',
      () {
        final textParts = [const TextDecisionInputPart('policy')];
        final content =
            DecisionDeveloperContent.parts(textParts)
                as PartsDecisionDeveloperContent;
        textParts.clear();
        final developer = DeveloperDecisionInputMessage(content: content);
        final system = SystemDecisionInputMessage(content: content);
        final assistant = AssistantDecisionInputMessage(
          content: DecisionAssistantContent.parts(const [
            DecisionAssistantPart.text('Done'),
          ]),
          phase: DecisionMessagePhase.finalAnswer,
        );
        final toolOutput = DecisionToolOutput.parts([
          const TextDecisionInputPart('result'),
          ImageDecisionInputPart(imageUrl: 'http://example.com/result.png'),
        ]);
        final function = DecisionFunctionCall(
          callId: 'f',
          name: 'lookup.order',
          arguments: '',
          id: 'id',
          namespace: 'orders',
          status: DecisionToolStatus.incomplete,
        );
        final custom = DecisionCustomToolCall(
          callId: 'c',
          name: 'lookup',
          input: '',
          id: 'id',
          namespace: 'orders',
          status: DecisionToolStatus.inProgress,
        );
        final result = DecisionFunctionCallOutput(
          callId: 'f',
          output: toolOutput,
          id: 'id',
          status: DecisionToolStatus.completed,
        );
        final customResult = DecisionCustomToolCallOutput(
          callId: 'c',
          output: const DecisionToolOutput.text(''),
          id: 'id',
          status: DecisionToolStatus.completed,
        );
        for (final item in <DecisionInputItem>[
          developer,
          system,
          assistant,
          function,
          custom,
          result,
          customResult,
        ]) {
          final restored = DecisionInputItem.fromJson(item.toJson());
          expect(restored, item);
          expect(restored.hashCode, item.hashCode);
        }
        expect(content.parts, hasLength(1));
        expect(content.parts.clear, throwsUnsupportedError);
        expect(developer.copyWith(), developer);
        expect(system.copyWith(), system);
        expect(assistant.copyWith(phase: null).phase, isNull);
        expect(
          function.copyWith(id: null, namespace: null, status: null).toJson(),
          {
            'type': 'function_call',
            'call_id': 'f',
            'name': 'lookup.order',
            'arguments': '',
          },
        );
        expect(
          custom.copyWith(id: null, namespace: null, status: null).status,
          isNull,
        );
        expect(result.copyWith(id: null, status: null).id, isNull);
        expect(customResult.copyWith(id: null, status: null).status, isNull);
      },
    );

    test('rejects unsupported roles, role content and tool-history fields', () {
      final bad = <Map<String, dynamic>>[
        {'role': 'tool', 'content': ''},
        {
          'role': 'developer',
          'content': [
            {'type': 'input_image', 'image_url': 'https://example.com/a.png'},
          ],
        },
        {
          'role': 'system',
          'content': [
            {'type': 'input_json', 'data': <String, dynamic>{}},
          ],
        },
        {
          'role': 'assistant',
          'content': [
            {'type': 'input_text', 'text': ''},
          ],
        },
        {'role': 'assistant', 'content': '', 'phase': 'future'},
        {'type': 'function_call', 'call_id': '', 'name': 'f', 'arguments': ''},
        {
          'type': 'custom_tool_call',
          'call_id': 'c',
          'name': 'not.allowed',
          'input': '',
        },
        {
          'type': 'function_call_output',
          'call_id': 'c',
          'output': [
            {'type': 'input_json', 'data': <String, dynamic>{}},
          ],
        },
        {
          'type': 'custom_tool_call_output',
          'call_id': 'c',
          'output': '',
          'status': 'failed',
        },
        {'type': 'future'},
      ];
      for (final json in bad) {
        expect(
          () => DecisionInputItem.fromJson(json),
          throwsFormatException,
          reason: json.toString(),
        );
      }
      expect(
        () => DecisionFunctionCall(
          callId: 'c',
          name: 'f',
          arguments: '',
          namespace: '',
        ),
        throwsArgumentError,
      );
      expect(
        () => DecisionCustomToolCall(callId: 'x' * 65, name: 'f', input: ''),
        throwsArgumentError,
      );
    });
  });

  group('JSON evidence', () {
    test(
      'deeply snapshots objects and object arrays with stable value equality',
      () {
        final values = <Object?>['evidence', true, null, 1.25];
        final data = <String, dynamic>{'nested': values};
        final part = DecisionInputPart.json(data) as JsonDecisionInputPart;
        final hash = part.hashCode;
        final parts = {part};
        values.clear();
        data.clear();
        expect(part.data, {
          'nested': ['evidence', true, null, 1.25],
        });
        expect(part.hashCode, hash);
        expect(parts.contains(part), isTrue);
        expect(
          (part.data as Map<String, dynamic>).clear,
          throwsUnsupportedError,
        );
        final nested = (part.data as Map<String, dynamic>)['nested'] as List;
        expect(nested.clear, throwsUnsupportedError);
        expect(part, JsonDecisionInputPart.fromJson(part.toJson()));
        expect(part.copyWith(), part);
        expect(
          DecisionInputPart.json(
            const <Map<String, dynamic>>[],
          ).toJson()['data'],
          isEmpty,
        );
        expect(
          DecisionInputPart.json(const [
            {'a': 1},
            {'a': 2},
          ]).toJson()['data'],
          hasLength(2),
        );
      },
    );

    test(
      'enforces object roots, finite values, string keys and acyclic JSON',
      () {
        final cycle = <String, dynamic>{};
        cycle['self'] = cycle;
        for (final data in <Object>[
          42,
          'text',
          true,
          [1],
          [null],
          {1: 'bad'},
          {'x': double.nan},
          {'x': double.infinity},
          {'x': Object()},
          cycle,
        ]) {
          expect(() => JsonDecisionInputPart(data), throwsArgumentError);
          expect(
            () => JsonDecisionInputPart.fromJson({
              'type': 'input_json',
              'data': data,
            }),
            throwsFormatException,
          );
        }
        expect(
          () => JsonDecisionInputPart.fromJson(const {
            'type': 'input_json',
            'data': null,
          }),
          throwsFormatException,
        );
      },
    );

    test('enforces exact container, value and UTF-8 byte boundaries', () {
      Object nested = <String, dynamic>{};
      for (var i = 1; i < 32; i++) {
        nested = <String, dynamic>{'v': nested};
      }
      expect(JsonDecisionInputPart(nested).data, isA<Map<String, dynamic>>());
      expect(() => JsonDecisionInputPart({'v': nested}), throwsArgumentError);
      expect(
        JsonDecisionInputPart({'v': List<Object?>.filled(9998, null)}).data,
        isA<Map<String, dynamic>>(),
      );
      expect(
        () => JsonDecisionInputPart({'v': List<Object?>.filled(9999, null)}),
        throwsArgumentError,
      );
      // Compact {"v":""} consumes eight bytes before the string content.
      final exact = <String, dynamic>{'v': 'x' * (256 * 1024 - 8)};
      expect(utf8.encode(jsonEncode(exact)), hasLength(256 * 1024));
      expect(JsonDecisionInputPart(exact).data, exact);
      expect(
        () => JsonDecisionInputPart({'v': 'x' * (256 * 1024 - 7)}),
        throwsArgumentError,
      );
      expect(
        () => JsonDecisionInputPart({'v': 'é' * (128 * 1024)}),
        throwsArgumentError,
      );
    });
  });

  group('question instructions', () {
    test(
      'all question types round-trip text, images and JSON in instruction arrays',
      () {
        final source = <DecisionQuestionPart>[
          const DecisionQuestionPart.text('Compare this evidence'),
          DecisionQuestionPart.image(
            imageUrl: 'https://example.com/reference.png',
            detail: ImageDetail.original,
          ),
          DecisionQuestionPart.json(const {
            'reference': [1, 2],
          }),
        ];
        final instructions =
            DecisionInstructions.parts(source) as PartsDecisionInstructions;
        source.clear();
        final questions = <DecisionQuestion>[
          DecisionQuestion.predicateWithInstructions(
            instructions: instructions,
            name: 'p',
          ),
          DecisionQuestion.choiceWithInstructions(
            instructions: instructions,
            choices: const [
              DecisionChoiceOption(value: DecisionChoiceValue.string('yes')),
              DecisionChoiceOption(value: DecisionChoiceValue.string('no')),
            ],
          ),
          DecisionQuestion.scoreWithInstructions(
            instructions: instructions,
            levels: const [
              DecisionScoreLevel(label: 'low'),
              DecisionScoreLevel(label: 'high'),
            ],
          ),
        ];
        for (final question in questions) {
          final parsed = DecisionQuestion.fromJson(question.toJson());
          expect(parsed, question);
          expect(parsed.hashCode, question.hashCode);
          expect(question.toJson()['instructions'], hasLength(3));
        }
        expect(instructions.parts.clear, throwsUnsupportedError);
        expect(
          (questions.first as PredicateDecisionQuestion)
              .copyWith(instructions: const DecisionInstructions.text('New'))
              .toJson()['instructions'],
          'New',
        );
        final image = instructions.parts[1] as ImageDecisionQuestionPart;
        expect(image.copyWith(detail: null).detail, isNull);
        final json = instructions.parts[2] as JsonDecisionQuestionPart;
        expect(json.copyWith(), json);
      },
    );

    test(
      'rejects empty instruction arrays and cache markers on any question part',
      () {
        expect(() => DecisionInstructions.parts(const []), throwsArgumentError);
        expect(
          () => DecisionInstructions.fromJson(const []),
          throwsFormatException,
        );
        for (final part in <Map<String, dynamic>>[
          {'type': 'input_text', 'text': ''},
          {'type': 'input_image', 'image_url': 'https://example.com/a.png'},
          {'type': 'input_json', 'data': <String, dynamic>{}},
        ]) {
          expect(
            () => DecisionQuestionPart.fromJson({
              ...part,
              'prompt_cache_breakpoint': const {'mode': 'explicit'},
            }),
            throwsFormatException,
          );
        }
        expect(
          () => DecisionInstructions.fromJson(const [
            {'type': 'input_file', 'file_id': 'file_1'},
          ]),
          throwsFormatException,
        );
      },
    );
  });

  test(
    'evidence equality distinguishes subclasses consistently with hashing',
    () {
      const base = OutputTextDecisionPart('same');
      const derived = _DerivedOutputText('same');
      expect(base, isNot(derived));
      expect(derived, isNot(base));
      expect({base, derived}, hasLength(2));
    },
  );

  test('assistant evidence parsers validate their discriminators', () {
    expect(
      OutputTextDecisionPart.fromJson(const {
        'type': 'output_text',
        'text': 'ok',
      }),
      const DecisionAssistantPart.text('ok'),
    );
    expect(
      RefusalDecisionPart.fromJson(const {'type': 'refusal', 'refusal': 'no'}),
      const DecisionAssistantPart.refusal('no'),
    );
    expect(
      () => OutputTextDecisionPart.fromJson(const {
        'type': 'refusal',
        'text': 'ok',
      }),
      throwsFormatException,
    );
    expect(
      () => RefusalDecisionPart.fromJson(const {'type': 'refusal'}),
      throwsFormatException,
    );
  });

  test(
    'shared-input cache boundaries survive copies and explicit clearing',
    () {
      const marker = DecisionPromptCacheBreakpoint();
      const text = TextDecisionInputPart(
        'private evidence',
        promptCacheBreakpoint: marker,
      );
      final image = ImageDecisionInputPart(
        imageUrl: 'https://example.invalid/private.png',
        detail: ImageDetail.original,
        promptCacheBreakpoint: marker,
      );
      for (final part in <DecisionInputPart>[text, image]) {
        final decoded = DecisionInputPart.fromJson(part.toJson());
        expect(decoded, part);
        expect(decoded.hashCode, part.hashCode);
        expect(part.toString(), contains('promptCacheBreakpoint:'));
        expect(part.toString(), isNot(contains('private')));
      }
      expect(
        text
            .copyWith(promptCacheBreakpoint: null)
            .toJson()
            .containsKey('prompt_cache_breakpoint'),
        isFalse,
      );
      expect(
        image
            .copyWith(promptCacheBreakpoint: null)
            .toJson()
            .containsKey('prompt_cache_breakpoint'),
        isFalse,
      );
      expect(text.copyWith(promptCacheBreakpoint: null), isNot(text));
      expect(image.copyWith(promptCacheBreakpoint: null), isNot(image));
      expect(text.copyWith(), text);
      expect(image.copyWith(), image);
      expect(
        DecisionPromptCacheOptions.fromJson(const {'mode': 'implicit'}),
        const DecisionPromptCacheOptions(mode: DecisionCacheMode.implicit),
      );
    },
  );

  test(
    'history diagnostics include metadata without exposing captured text',
    () {
      final call = DecisionFunctionCall(
        callId: 'private-call',
        name: 'private_name',
        arguments: 'private arguments',
        id: 'private-id',
        namespace: 'private_ns',
        status: DecisionToolStatus.completed,
      );
      final custom = DecisionCustomToolCall(
        callId: 'private-call',
        name: 'private_name',
        input: 'private input',
        id: 'private-id',
        namespace: 'private_ns',
        status: DecisionToolStatus.inProgress,
      );
      final outputs = <DecisionInputItem>[
        DecisionFunctionCallOutput(
          callId: 'private-call',
          id: 'private-id',
          output: const DecisionToolOutput.text('private output'),
          status: DecisionToolStatus.completed,
        ),
        DecisionCustomToolCallOutput(
          callId: 'private-call',
          id: 'private-id',
          output: const DecisionToolOutput.text('private output'),
          status: DecisionToolStatus.incomplete,
        ),
      ];
      for (final item in <DecisionInputItem>[call, custom, ...outputs]) {
        final diagnostic = item.toString();
        expect(diagnostic, isNot(contains('private')));
        for (final field in ['callId:', 'id:', 'status:']) {
          expect(diagnostic, contains(field));
        }
      }
      expect(call.toString(), contains('namespace:'));
      expect(custom.toString(), contains('namespace:'));
    },
  );

  group('Decisions caching and limits', () {
    test('rejects oversized cache keys consistently when parsing requests', () {
      final request = DecisionRequest(
        model: 'gpt-6-luna',
        input: const DecisionInput.text('evidence'),
        questions: const [DecisionQuestion.predicate(instructions: 'True?')],
      );
      expect(
        () => DecisionRequest.fromJson({
          ...request.toJson(),
          'prompt_cache_key': 'x' * 65,
        }),
        throwsFormatException,
      );
      expect(
        request.copyWith(promptCacheKey: 'é' * 64).promptCacheKey,
        hasLength(64),
      );
    });

    test(
      'round-trips cache controls, snapshots 400 questions and clears optional values',
      () {
        final questions = List<DecisionQuestion>.generate(
          400,
          (i) => DecisionQuestion.predicate(instructions: 'Question $i'),
        );
        final request = DecisionRequest(
          model: 'gpt-6-luna',
          input: DecisionInput.items([
            DecisionInputMessage(
              content: DecisionContent.parts([
                const DecisionInputPart.text(
                  'Shared policy',
                  promptCacheBreakpoint: DecisionPromptCacheBreakpoint(),
                ),
                DecisionInputPart.image(
                  imageUrl: 'https://example.com/a.png',
                  promptCacheBreakpoint: const DecisionPromptCacheBreakpoint(),
                ),
              ]),
            ),
          ]),
          questions: questions,
          promptCacheKey: 'tenant-1',
          promptCacheOptions: const DecisionPromptCacheOptions(
            ttl: DecisionCacheTtl.thirtyMinutes,
            mode: DecisionCacheMode.explicit,
          ),
        );
        questions.clear();
        expect(request.questions, hasLength(400));
        final restored = DecisionRequest.fromJson(request.toJson());
        expect(restored, request);
        expect(restored.hashCode, request.hashCode);
        expect(
          request
              .copyWith(promptCacheKey: null, promptCacheOptions: null)
              .toJson()
              .keys,
          isNot(contains('prompt_cache_key')),
        );
        expect(
          request.promptCacheOptions!.copyWith(ttl: null, mode: null).toJson(),
          isEmpty,
        );
        expect(const DecisionPromptCacheOptions().toJson(), isEmpty);
        expect(
          () => DecisionPromptCacheOptions.fromJson(const {'ttl': '12h'}),
          throwsFormatException,
        );
        expect(
          () => DecisionPromptCacheOptions.fromJson(const {'ttl': null}),
          throwsFormatException,
        );
        expect(
          () => DecisionPromptCacheOptions.fromJson(const {'mode': 'future'}),
          throwsFormatException,
        );
        expect(
          () => DecisionPromptCacheBreakpoint.fromJson(const {
            'mode': 'explicit',
            'ttl': '30m',
          }),
          throwsFormatException,
        );
        expect(
          () => DecisionPromptCacheBreakpoint.fromJson(const {
            'mode': 'implicit',
          }),
          throwsFormatException,
        );
        expect(
          DecisionPromptCacheOptions.fromJson(const {'mode': null}).toJson(),
          isEmpty,
        );
        expect(
          () => request.copyWith(promptCacheKey: 'x' * 65),
          throwsArgumentError,
        );
      },
    );
  });
}

class _DerivedOutputText extends OutputTextDecisionPart {
  const _DerivedOutputText(super.text);
}
