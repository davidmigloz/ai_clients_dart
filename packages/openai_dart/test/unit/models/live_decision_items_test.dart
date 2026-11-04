import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Matcher _safeError([String context = 'LiveDecision']) => throwsA(
  isA<FormatException>()
      .having((error) => error.message, 'safe context', contains(context))
      .having((error) => error.source, 'no source', isNull)
      .having(
        (error) => error.toString(),
        'private content',
        isNot(contains('private-')),
      ),
);
Map<String, dynamic> _future() => {
  'private-future': <String, dynamic>{
    'nested': <dynamic>[1, null],
  },
};
Map<String, dynamic> _message(String role) => {
  'role': role,
  'content': 'private-evidence',
};
Map<String, dynamic> _tool(String type) => {
  'type': type,
  'call_id': 'private-call',
  if (!type.endsWith('_output')) 'name': 'tool_name',
  if (type == 'function_call') 'arguments': 'private-arguments',
  if (type == 'custom_tool_call') 'input': 'private-input',
  if (type.endsWith('_output')) 'output': 'private-output',
};
const _toolTypes = [
  'function_call',
  'custom_tool_call',
  'function_call_output',
  'custom_tool_call_output',
];

void main() {
  group('native Live Decision parts', () {
    final fixtures = <String, Map<String, dynamic>>{
      'input_text': {'type': 'input_text', 'text': 'private-text'},
      'input_image': {
        'type': 'input_image',
        'image_url': 'data:image/png;base64,cHJpdmF0ZQ==',
      },
      'input_json': {
        'type': 'input_json',
        'data': <String, dynamic>{
          'private-key': <dynamic>[1, null],
        },
      },
      'output_text': {'type': 'output_text', 'text': 'private-output'},
      'refusal': {'type': 'refusal', 'refusal': 'private-refusal'},
    };
    for (final entry in fixtures.entries) {
      test(
        '${entry.key} retains required fields, future metadata and value identity',
        () {
          final wire = <String, dynamic>{...entry.value, ..._future()};
          final part = LiveDecisionContentPart.fromJson(wire);
          expect(part.type, entry.key);
          expect(part.toJson(), wire);
          final roundtrip = LiveDecisionContentPart.fromJson(part.toJson());
          expect(roundtrip, part);
          expect(roundtrip.hashCode, part.hashCode);
          expect(part.toString(), isNot(contains('private-')));
          (wire['private-future'] as Map<String, dynamic>)['nested'] = [
            'mutated',
          ];
          expect(part.toJson()['private-future'], {
            'nested': [1, null],
          });
          expect(() => part.rawJson['new'] = true, throwsUnsupportedError);
          expect(
            () =>
                (part.rawJson['private-future']
                        as Map<String, dynamic>)['nested'] =
                    const <Object?>[],
            throwsUnsupportedError,
          );
          for (final required in entry.value.keys) {
            expect(
              () => LiveDecisionContentPart.fromJson(
                {...entry.value}..remove(required),
              ),
              _safeError(),
            );
            expect(
              () => LiveDecisionContentPart.fromJson(
                {...entry.value}..[required] = null,
              ),
              _safeError(),
            );
          }
        },
      );
    }
    test('part copies include payload and authoritative future metadata', () {
      final input = LiveDecisionInputTextParam.fromJson({
        ...fixtures['input_text']!,
        ..._future(),
      });
      expect(input.copyWith(), input);
      expect(input.copyWith(text: 'other'), isNot(input));
      expect(input.copyWith(text: 'other').toJson()['text'], 'other');
      expect(
        input.copyWith(rawJson: {}).toJson().containsKey('private-future'),
        isFalse,
      );
      final output = LiveDecisionOutputTextParam(text: 'out');
      expect(output.copyWith(), output);
      expect(output.copyWith(text: 'other'), isNot(output));
      final refusal = LiveDecisionRefusalParam(refusal: 'no');
      expect(refusal.copyWith(), refusal);
      expect(refusal.copyWith(refusal: 'other'), isNot(refusal));
      final json = LiveDecisionInputJsonParam(data: const {'x': 1});
      expect(json.copyWith(), json);
      expect(json.copyWith(data: {'x': 2}), isNot(json));
      expect(() => json.copyWith(data: null), _safeError());
    });
    test('image detail preserves omission/null/value and explicit clear', () {
      final image = LiveDecisionInputImageParam(
        imageUrl: 'https://offline.invalid/image',
      );
      expect(image.hasDetail, isFalse);
      expect(image.toJson().containsKey('detail'), isFalse);
      final nullable = image.copyWith(detail: null);
      expect(nullable.hasDetail, isTrue);
      expect(nullable.toJson()['detail'], isNull);
      expect(LiveDecisionContentPart.fromJson(nullable.toJson()), nullable);
      expect(nullable, isNot(image));
      expect(nullable.copyWith(clearDetail: true), image);
      for (final detail in ['low', 'high', 'auto', 'original']) {
        final copy = nullable.copyWith(detail: detail);
        expect(copy.detail, detail);
        expect(LiveDecisionContentPart.fromJson(copy.toJson()), copy);
        expect(copy.copyWith(), copy);
      }
      expect(
        () => image.copyWith(detail: 'private-future-detail'),
        _safeError(),
      );
      expect(() => image.copyWith(detail: 3), _safeError());
      for (final url in ['file_123', 'ftp://offline.invalid', 'private-url']) {
        expect(() => image.copyWith(imageUrl: url), _safeError());
      }
      expect(image.copyWith(imageUrl: 'data:').imageUrl, 'data:');
    });
    test('native JSON admits evidence beyond standalone byte/depth limits', () {
      Object nested = {'leaf': null};
      for (var i = 0; i < 40; i++) {
        nested = {'child': nested};
      }
      final data = <String, dynamic>{
        'deep': nested,
        'long': 'x' * (256 * 1024 + 1),
      };
      final part = LiveDecisionInputJsonParam(data: data);
      expect((part.data as Map<String, dynamic>)['long'], data['long']);
      expect(LiveDecisionContentPart.fromJson(part.toJson()), part);
      final objects = LiveDecisionInputJsonParam(
        data: const <Map<String, dynamic>>[],
      );
      expect(objects.data, isEmpty);
      expect(
        () => (objects.data as List<dynamic>).add(const <String, Object?>{}),
        throwsUnsupportedError,
      );
      for (final bad in [
        null,
        'text',
        3,
        [1],
        [null],
      ]) {
        expect(
          () => LiveDecisionInputJsonParam.fromJson({
            'type': 'input_json',
            'data': bad,
          }),
          _safeError(),
        );
      }
    });
    test(
      'native parts reject cycles/nonfinite/nonJSON without payload disclosure',
      () {
        final cycle = <String, dynamic>{};
        cycle['private-cycle'] = cycle;
        for (final bad in [
          double.nan,
          double.infinity,
          cycle,
          Object(),
          {1: 'private-value'},
        ]) {
          expect(
            () => LiveDecisionInputJsonParam(data: {'private-data': bad}),
            _safeError(),
          );
          expect(
            () => LiveDecisionInputTextParam(
              text: 'text',
              rawJson: {'private-future': bad},
            ),
            _safeError(),
          );
        }
      },
    );
    test(
      'native character limits use code points and their own image bound',
      () {
        final text = 'x' * 10485760;
        expect(LiveDecisionInputTextParam(text: text).text.length, 10485760);
        expect(
          () => LiveDecisionInputTextParam(text: '${text}x'),
          _safeError(),
        );
        expect(
          () => LiveDecisionOutputTextParam(text: '${text}x'),
          _safeError(),
        );
        expect(
          () => LiveDecisionRefusalParam(refusal: '${text}x'),
          _safeError(),
        );
        final image = 'data:${'x' * (20971520 - 5)}';
        expect(
          LiveDecisionInputImageParam(imageUrl: image).imageUrl.length,
          20971520,
        );
        expect(
          () => LiveDecisionInputImageParam(imageUrl: '${image}x'),
          _safeError(),
        );
      },
    );
  });
  group('native Live role-specific Decision messages', () {
    test(
      'role factories preserve explicit local metadata and assistant phase',
      () {
        const content = LiveDecisionContent.text('text');
        final messages = [
          LiveDecisionMessageParam.user(content: content, hasId: true),
          LiveDecisionMessageParam.developer(content: content, id: 'developer'),
          LiveDecisionMessageParam.system(content: content, includeType: true),
          LiveDecisionMessageParam.assistant(content: content, hasPhase: true),
        ];
        expect(messages.map((item) => item.role), [
          'user',
          'developer',
          'system',
          'assistant',
        ]);
        expect(messages[0].toJson().containsKey('id'), isTrue);
        expect(messages[1].id, 'developer');
        expect(messages[2].toJson()['type'], 'message');
        expect(messages[3].toJson().containsKey('phase'), isTrue);
        for (final message in messages) {
          expect(
            LiveDecisionInputItemParam.fromJson(message.toJson()),
            message,
          );
        }
      },
    );
    for (final role in ['user', 'developer', 'system', 'assistant']) {
      test('$role preserves omitted/default type and local nullable ID', () {
        final wire = _message(role);
        final item =
            LiveDecisionInputItemParam.fromJson(wire)
                as LiveDecisionMessageParam;
        expect(item.role, role);
        expect(item.type, 'message');
        expect(item.includeType, isFalse);
        expect(item.toJson(), wire);
        final nullId = item.copyWith(id: null);
        expect(nullId.hasId, isTrue);
        expect(nullId.toJson().containsKey('id'), isTrue);
        expect(nullId.toJson()['id'], isNull);
        expect(nullId, isNot(item));
        expect(nullId.copyWith(clearId: true), item);
        final explicit = item.copyWith(id: 'local-id', includeType: true);
        expect(explicit.toJson()['type'], 'message');
        expect(explicit.id, 'local-id');
        expect(
          LiveDecisionInputItemParam.fromJson(explicit.toJson()),
          explicit,
        );
        expect(explicit.copyWith().hashCode, explicit.hashCode);
        expect(
          explicit.copyWith(content: const LiveDecisionContent.text('other')),
          isNot(explicit),
        );
        expect(explicit.toString(), isNot(contains('private-')));
        expect(
          () => LiveDecisionInputItemParam.fromJson({...wire, 'type': null}),
          _safeError(),
        );
        for (final field in ['role', 'content']) {
          expect(
            () => LiveDecisionInputItemParam.fromJson({...wire}..remove(field)),
            _safeError(),
          );
          expect(
            () =>
                LiveDecisionInputItemParam.fromJson({...wire}..[field] = null),
            _safeError(),
          );
        }
        final emptyParts = LiveDecisionMessageParam(
          role: role,
          content: LiveDecisionContent.parts(const []),
        );
        expect(emptyParts.toJson()['content'], isEmpty);
      });
    }
    test('each role admits only its canonical native content part union', () {
      final parts = <LiveDecisionContentPart>[
        LiveDecisionInputTextParam(text: 'text'),
        LiveDecisionInputImageParam(imageUrl: 'data:image/png;base64,eA=='),
        LiveDecisionInputJsonParam(data: const {'x': 1}),
        LiveDecisionOutputTextParam(text: 'out'),
        LiveDecisionRefusalParam(refusal: 'no'),
      ];
      for (final role in ['user', 'developer', 'system', 'assistant']) {
        for (final part in parts) {
          final allowed = switch (role) {
            'user' => {'input_text', 'input_image', 'input_json'},
            'assistant' => {'output_text', 'refusal'},
            _ => {'input_text'},
          };
          if (allowed.contains(part.type)) {
            final item = LiveDecisionMessageParam(
              role: role,
              content: LiveDecisionContent.parts([part]),
            );
            expect(LiveDecisionInputItemParam.fromJson(item.toJson()), item);
          } else {
            expect(
              () => LiveDecisionMessageParam(
                role: role,
                content: LiveDecisionContent.parts([part]),
              ),
              _safeError(),
            );
          }
        }
      }
    });
    test(
      'assistant nullable phase is independent from ID and copy omission',
      () {
        final item = LiveDecisionMessageParam(
          role: 'assistant',
          content: const LiveDecisionContent.text('text'),
        );
        final nullable = item.copyWith(phase: null);
        expect(nullable.hasPhase, isTrue);
        expect(nullable.toJson().containsKey('phase'), isTrue);
        expect(nullable, isNot(item));
        expect(nullable.copyWith(clearPhase: true), item);
        for (final phase in ['commentary', 'final_answer']) {
          final phased = item.copyWith(phase: phase);
          expect(phased.phase, phase);
          expect(LiveDecisionInputItemParam.fromJson(phased.toJson()), phased);
        }
        expect(() => item.copyWith(phase: 'private-phase'), _safeError());
        expect(() => item.copyWith(role: 'user', phase: null), _safeError());
      },
    );
    test(
      'clearing phase during a role change removes stale received phase',
      () {
        final assistant = LiveDecisionMessageParam.fromJson({
          'role': 'assistant',
          'content': 'evidence',
          'phase': 'commentary',
          ..._future(),
        });
        for (final role in ['user', 'developer', 'system']) {
          final copy = assistant.copyWith(role: role, clearPhase: true);
          expect(copy.hasPhase, isFalse);
          expect(copy.phase, isNull);
          expect(copy.rawJson.containsKey('phase'), isFalse);
          expect(copy.toJson().containsKey('phase'), isFalse);
          expect(copy.toJson()['private-future'], {
            'nested': [1, null],
          });
          final roundtrip = LiveDecisionInputItemParam.fromJson(copy.toJson());
          expect(roundtrip, copy);
          expect(roundtrip.hashCode, copy.hashCode);
        }
        final user = LiveDecisionMessageParam.fromJson(const {
          'role': 'user',
          'content': 'evidence',
          'phase': 'future-metadata',
        });
        expect(user.copyWith().toJson()['phase'], 'future-metadata');
        expect(
          user.copyWith(clearPhase: true).toJson().containsKey('phase'),
          isFalse,
        );
      },
    );
    test(
      'message future metadata detaches and typed copies override known raw values',
      () {
        final wire = {..._message('user'), ..._future()};
        final item = LiveDecisionMessageParam.fromJson(wire);
        (wire['private-future'] as Map<String, dynamic>)['nested'] = [
          'mutated',
        ];
        expect(item.toJson()['private-future'], {
          'nested': [1, null],
        });
        expect(
          item
              .copyWith(content: const LiveDecisionContent.text('new'))
              .toJson()['content'],
          'new',
        );
        expect(
          item.copyWith(rawJson: {}).toJson().containsKey('private-future'),
          isFalse,
        );
      },
    );
    test(
      'content string versus array, immutable parts and native adapters are retained',
      () {
        final text = LiveDecisionContent.fromJson('text');
        final source = [LiveDecisionInputTextParam(text: 'text')];
        final parts =
            LiveDecisionContent.parts(source) as LiveDecisionPartsContent;
        source.clear();
        expect(parts.parts, hasLength(1));
        expect(parts.parts.clear, throwsUnsupportedError);
        expect(text.toJson(), 'text');
        expect(parts.toJson(), [
          {'type': 'input_text', 'text': 'text'},
        ]);
        expect(text, isNot(parts));
        expect(parts.copyWith(), parts);
        expect(parts.copyWith().hashCode, parts.hashCode);
        final standalone = DecisionInputItem.fromJson(_message('user'));
        final adapted = LiveDecisionInputItemParam.fromDecisionInputItem(
          standalone,
        );
        expect(adapted.toJson(), standalone.toJson());
      },
    );
  });
  group('native Live function/custom history', () {
    for (final type in _toolTypes) {
      test('$type preserves full nullable metadata and wire identity', () {
        final base = _tool(type);
        final wire = <String, dynamic>{
          ...base,
          'id': null,
          'status': null,
          ..._future(),
          if (!type.endsWith('_output')) 'namespace': null,
        };
        final item = LiveDecisionInputItemParam.fromJson(wire);
        expect(item.type, type);
        expect(item.hasId, isTrue);
        expect(item.id, isNull);
        expect(item.toJson(), wire);
        final roundtrip = LiveDecisionInputItemParam.fromJson(item.toJson());
        expect(roundtrip, item);
        expect(roundtrip.hashCode, item.hashCode);
        expect(item.toString(), isNot(contains('private-')));
        (wire['private-future'] as Map<String, dynamic>)['nested'] = [
          'mutated',
        ];
        expect(item.toJson()['private-future'], {
          'nested': [1, null],
        });
        for (final field in base.keys) {
          expect(
            () => LiveDecisionInputItemParam.fromJson({...base}..remove(field)),
            _safeError(),
          );
          expect(
            () =>
                LiveDecisionInputItemParam.fromJson({...base}..[field] = null),
            _safeError(),
          );
        }
        for (final field in [
          'id',
          'status',
          if (!type.endsWith('_output')) 'namespace',
        ]) {
          expect(
            () => LiveDecisionInputItemParam.fromJson({...base, field: 1}),
            _safeError(),
          );
        }
        for (final bad in ['', 'x' * 65]) {
          expect(
            () =>
                LiveDecisionInputItemParam.fromJson({...base, 'call_id': bad}),
            _safeError(),
          );
        }
        expect(
          () => LiveDecisionInputItemParam.fromJson({
            ...base,
            'status': 'private-status',
          }),
          _safeError(),
        );
      });
    }
    test(
      'function and custom call names have separate canonical patterns and bounds',
      () {
        expect(
          LiveDecisionFunctionCallParam(
            callId: 'call',
            name: 'a.b-' * 25,
            arguments: '',
          ).name.length,
          100,
        );
        expect(
          LiveDecisionFunctionCallParam(
            callId: 'c' * 64,
            name: 'x' * 128,
            arguments: '',
            namespace: 'n' * 64,
          ).name.length,
          128,
        );
        expect(
          () => LiveDecisionFunctionCallParam(
            callId: 'call',
            name: 'x' * 129,
            arguments: '',
          ),
          _safeError(),
        );
        expect(
          () => LiveDecisionCustomToolCallParam(
            callId: 'call',
            name: 'has.dot',
            input: '',
          ),
          _safeError(),
        );
        expect(
          () => LiveDecisionCustomToolCallParam(
            callId: 'call',
            name: 'x' * 65,
            input: '',
          ),
          _safeError(),
        );
        expect(
          () => LiveDecisionFunctionCallParam(
            callId: 'call',
            name: 'tool',
            arguments: '',
            namespace: 'with.dot',
          ),
          _safeError(),
        );
        final large = 'x' * (1024 * 1024 + 1);
        expect(
          LiveDecisionFunctionCallParam(
            callId: 'call',
            name: 'tool',
            arguments: large,
          ).arguments,
          large,
        );
        expect(
          LiveDecisionCustomToolCallParam(
            callId: 'call',
            name: 'tool',
            input: large,
          ).input,
          large,
        );
      },
    );
    test(
      'function/custom outputs allow text/images and empty arrays but not JSON',
      () {
        final image = LiveDecisionInputImageParam(imageUrl: 'data:');
        for (final type in [
          'function_call_output',
          'custom_tool_call_output',
        ]) {
          for (final output in [
            '',
            const <Object?>[],
            [
              {'type': 'input_text', 'text': 'text'},
              image.toJson(),
            ],
          ]) {
            final item = LiveDecisionInputItemParam.fromJson({
              ..._tool(type),
              'output': output,
            });
            expect(item.toJson()['output'], output);
          }
          expect(
            () => LiveDecisionInputItemParam.fromJson({
              ..._tool(type),
              'output': const [
                {'type': 'input_json', 'data': <String, Object?>{}},
              ],
            }),
            _safeError(),
          );
        }
      },
    );
    test(
      'copies include every call/output field and preserve null versus omit',
      () {
        final function = LiveDecisionFunctionCallParam(
          callId: 'call',
          name: 'tool',
          arguments: 'args',
          id: 'local',
          namespace: 'ns',
          status: 'completed',
        );
        final custom = LiveDecisionCustomToolCallParam(
          callId: 'call',
          name: 'tool',
          input: 'input',
          id: 'local',
          namespace: 'ns',
          status: 'completed',
        );
        final functionOutput = LiveDecisionFunctionCallOutputParam(
          callId: 'call',
          output: const LiveDecisionContent.text('out'),
          id: 'local',
          status: 'completed',
        );
        final customOutput = LiveDecisionCustomToolCallOutputParam(
          callId: 'call',
          output: const LiveDecisionContent.text('out'),
          id: 'local',
          status: 'completed',
        );
        final copies =
            <(LiveDecisionInputItemParam, LiveDecisionInputItemParam)>[
              (function, function.copyWith(callId: 'other')),
              (function, function.copyWith(name: 'other')),
              (function, function.copyWith(arguments: 'other')),
              (function, function.copyWith(id: null)),
              (function, function.copyWith(namespace: null)),
              (function, function.copyWith(status: null)),
              (custom, custom.copyWith(callId: 'other')),
              (custom, custom.copyWith(name: 'other')),
              (custom, custom.copyWith(input: 'other')),
              (custom, custom.copyWith(id: null)),
              (custom, custom.copyWith(namespace: null)),
              (custom, custom.copyWith(status: null)),
              (functionOutput, functionOutput.copyWith(callId: 'other')),
              (
                functionOutput,
                functionOutput.copyWith(
                  output: const LiveDecisionContent.text('other'),
                ),
              ),
              (functionOutput, functionOutput.copyWith(id: null)),
              (functionOutput, functionOutput.copyWith(status: null)),
              (customOutput, customOutput.copyWith(callId: 'other')),
              (
                customOutput,
                customOutput.copyWith(
                  output: const LiveDecisionContent.text('other'),
                ),
              ),
              (customOutput, customOutput.copyWith(id: null)),
              (customOutput, customOutput.copyWith(status: null)),
            ];
        for (final (original, changed) in copies) {
          expect(changed, isNot(original));
          expect(
            LiveDecisionInputItemParam.fromJson(changed.toJson()),
            changed,
          );
        }
        for (final copy in [
          function.copyWith(),
          custom.copyWith(),
          functionOutput.copyWith(),
          customOutput.copyWith(),
        ]) {
          expect(copy, LiveDecisionInputItemParam.fromJson(copy.toJson()));
          expect(
            copy.hashCode,
            LiveDecisionInputItemParam.fromJson(copy.toJson()).hashCode,
          );
        }
        for (final cleared in [
          function.copyWith(
            clearId: true,
            clearNamespace: true,
            clearStatus: true,
          ),
          custom.copyWith(
            clearId: true,
            clearNamespace: true,
            clearStatus: true,
          ),
          functionOutput.copyWith(clearId: true, clearStatus: true),
          customOutput.copyWith(clearId: true, clearStatus: true),
        ]) {
          expect(cleared.toJson().containsKey('id'), isFalse);
          expect(cleared.toJson().containsKey('status'), isFalse);
          expect(cleared.toJson().containsKey('namespace'), isFalse);
        }
      },
    );
  });
  group('stored native Live Decision item ID boundary', () {
    for (final wire in [
      for (final role in ['user', 'developer', 'system', 'assistant'])
        _message(role),
      for (final type in _toolTypes) _tool(type),
    ]) {
      final label = wire['role'] ?? wire['type'];
      test(
        '$label stored item requires ID without inventing length bounds',
        () {
          expect(
            () => LiveDecisionStoredInputItemParam.fromJson(wire),
            _safeError(),
          );
          expect(
            () => LiveDecisionStoredInputItemParam.fromJson({
              ...wire,
              'id': null,
            }),
            _safeError(),
          );
          for (final id in ['', 'private-local-id', 'x' * 300]) {
            final stored = LiveDecisionStoredInputItemParam.fromJson({
              ...wire,
              'id': id,
              ..._future(),
            });
            expect(stored.id, id);
            expect(stored.type, wire['type'] ?? 'message');
            expect(
              LiveDecisionStoredInputItemParam.fromJson(stored.toJson()),
              stored,
            );
            expect(stored.copyWith(), stored);
            expect(stored.copyWith().hashCode, stored.hashCode);
            expect(stored.copyWith(id: 'other').toJson()['id'], 'other');
            expect(stored.toString(), isNot(contains('private-')));
            expect(
              () => stored.copyWith(
                item: LiveDecisionInputItemParam.fromJson(wire),
              ),
              _safeError(),
            );
          }
        },
      );
    }
  });
}
