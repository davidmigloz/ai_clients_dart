import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _agent = AgentTag(agentName: 'worker');
const _otherAgent = AgentTag(agentName: 'other');
const _caller = ProgramToolCallCaller(callerId: 'program_1');
const _otherCaller = DirectToolCallCaller();

Map<String, dynamic> _json(Object item) => switch (item) {
  final Item item => item.toJson(),
  final OutputItem item => item.toJson(),
  _ => throw ArgumentError('Not a call item'),
};

String _type(Object item) => switch (item) {
  final FunctionCallItem item => item.type,
  final FunctionCallOutputItemResponse item => item.type,
  final CustomToolCallInputItem item => item.type,
  final CustomToolCallItem item => item.type,
  _ => throw ArgumentError('Not a call item'),
};

void _checkCopies(
  Object original,
  List<(String, Object, Object?)> changes,
  Object Function(Map<String, dynamic>) parse,
) {
  final before = _json(original);
  for (final (key, changed, value) in changes) {
    final expected = Map<String, dynamic>.from(before);
    if (value == null) {
      expected.remove(key);
    } else {
      expected[key] = value;
    }
    expect(_json(changed), expected, reason: 'copy of $key');
    final parsed = parse(expected);
    expect(changed, parsed, reason: 'value of $key');
    expect(changed.hashCode, parsed.hashCode, reason: 'hash of $key');
    expect(changed, isNot(original), reason: 'equality includes $key');
    expect(
      changed.hashCode,
      isNot(original.hashCode),
      reason: 'hash includes $key',
    );
    expect(_json(original), before, reason: 'original after $key');
  }
}

void main() {
  final variants =
      <(String, Map<String, dynamic>, Object Function(Map<String, dynamic>))>[
        (
          'FunctionCallItem',
          {
            'type': 'function_call',
            'call_id': 'c',
            'name': 'f',
            'arguments': '',
          },
          FunctionCallItem.fromJson,
        ),
        (
          'FunctionCallOutputItemResponse',
          {
            'type': 'function_call',
            'id': 'f1',
            'call_id': 'c',
            'name': 'f',
            'arguments': '',
          },
          FunctionCallOutputItemResponse.fromJson,
        ),
        (
          'CustomToolCallInputItem',
          {
            'type': 'custom_tool_call',
            'call_id': 'c',
            'name': 'f',
            'input': '',
          },
          CustomToolCallInputItem.fromJson,
        ),
        (
          'CustomToolCallItem',
          {
            'type': 'custom_tool_call',
            'id': 'f1',
            'call_id': 'c',
            'name': 'f',
            'input': '',
          },
          CustomToolCallItem.fromJson,
        ),
      ];
  for (final (name, json, parse) in variants) {
    group('$name async wire contract', () {
      test('exposes its fixed wire discriminator', () {
        expect(_type(parse(json)), json['type']);
      });
      test('omission is retained without implying false', () {
        expect(_json(parse(json)), json);
      });
      for (final value in [false, true]) {
        test('retains explicit $value', () {
          final wire = {...json, 'async': value};
          expect(_json(parse(wire)), wire);
        });
      }
      for (final value in [
        null,
        0,
        1,
        '',
        'true',
        <Object>[],
        <String, dynamic>{},
      ]) {
        test('rejects malformed ${value.runtimeType} async', () {
          expect(
            () => parse({...json, 'async': value}),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'field',
                contains('$name.async'),
              ),
            ),
          );
        });
      }
      test('keeps existing nullable caller/agent compatibility', () {
        expect(_json(parse({...json, 'caller': null, 'agent': null})), json);
      });
      for (final key in json.keys) {
        for (final invalid in ['missing', 'null', 'wrong type']) {
          test('rejects $invalid required $key contextually', () {
            final malformed = Map<String, dynamic>.from(json);
            switch (invalid) {
              case 'missing':
                malformed.remove(key);
              case 'null':
                malformed[key] = null;
              case 'wrong type':
                malformed[key] = 1;
            }
            expect(
              () => parse(malformed),
              throwsA(
                isA<FormatException>().having(
                  (e) => e.message,
                  'field',
                  contains('$name.$key'),
                ),
              ),
            );
          });
        }
      }
      test('rejects a mismatched string discriminator', () {
        expect(
          () => parse({...json, 'type': 'message'}),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'field',
              contains('$name.type'),
            ),
          ),
        );
      });
    });
  }

  group('function input contracts', () {
    const item = FunctionCallItem(
      id: 'f1',
      agent: _agent,
      callId: 'c1',
      name: 'lookup',
      arguments: '{"secret":"do not print"}',
      status: ItemStatus.completed,
      namespace: 'tools',
      caller: _caller,
      async: true,
    );
    test('all fields round-trip through the Item union and no-op copy', () {
      expect(Item.fromJson(item.toJson()), item);
      expect(item.copyWith(), item);
      expect(item.copyWith().hashCode, item.hashCode);
      expect(item.copyWith().toJson(), item.toJson());
      expect(item.copyWith(callId: null, name: null, arguments: null), item);
    });
    test('independently replaces every field', () {
      _checkCopies(item, [
        ('id', item.copyWith(id: 'f2'), 'f2'),
        ('agent', item.copyWith(agent: _otherAgent), _otherAgent.toJson()),
        ('call_id', item.copyWith(callId: 'c2'), 'c2'),
        ('name', item.copyWith(name: 'other'), 'other'),
        ('arguments', item.copyWith(arguments: '[]'), '[]'),
        ('status', item.copyWith(status: ItemStatus.incomplete), 'incomplete'),
        ('namespace', item.copyWith(namespace: 'other'), 'other'),
        ('caller', item.copyWith(caller: _otherCaller), _otherCaller.toJson()),
        ('async', item.copyWith(async: false), false),
      ], Item.fromJson);
    });
    test('independently clears every optional field', () {
      _checkCopies(item, [
        ('id', item.copyWith(id: null), null),
        ('agent', item.copyWith(agent: null), null),
        ('status', item.copyWith(status: null), null),
        ('namespace', item.copyWith(namespace: null), null),
        ('caller', item.copyWith(caller: null), null),
        ('async', item.copyWith(async: null), null),
      ], Item.fromJson);
    });
    test('redacts arguments and retains useful metadata', () {
      expect(item.toString(), isNot(contains('do not print')));
      for (final field in [
        'id:',
        'agent:',
        'callId:',
        'name:',
        'arguments: <redacted>',
        'status:',
        'namespace:',
        'caller:',
        'async: true',
      ]) {
        expect(item.toString(), contains(field));
      }
    });
  });

  group('function output contracts', () {
    const item = FunctionCallOutputItemResponse(
      id: 'f1',
      agent: _agent,
      callId: 'c1',
      name: 'lookup',
      arguments: '{"secret":"do not print"}',
      status: ItemStatus.completed,
      namespace: 'tools',
      createdBy: 'creator',
      caller: _caller,
      async: true,
    );
    test('all fields round-trip through output and no-op copy', () {
      expect(OutputItem.fromJson(item.toJson()), item);
      expect(item.copyWith(), item);
      expect(item.copyWith().hashCode, item.hashCode);
      expect(item.copyWith().toJson(), item.toJson());
      expect(
        item.copyWith(id: null, callId: null, name: null, arguments: null),
        item,
      );
    });
    test('independently replaces every field', () {
      _checkCopies(item, [
        ('id', item.copyWith(id: 'f2'), 'f2'),
        ('agent', item.copyWith(agent: _otherAgent), _otherAgent.toJson()),
        ('call_id', item.copyWith(callId: 'c2'), 'c2'),
        ('name', item.copyWith(name: 'other'), 'other'),
        ('arguments', item.copyWith(arguments: '[]'), '[]'),
        ('status', item.copyWith(status: ItemStatus.incomplete), 'incomplete'),
        ('namespace', item.copyWith(namespace: 'other'), 'other'),
        ('created_by', item.copyWith(createdBy: 'other'), 'other'),
        ('caller', item.copyWith(caller: _otherCaller), _otherCaller.toJson()),
        ('async', item.copyWith(async: false), false),
      ], OutputItem.fromJson);
    });
    test('independently clears every optional field', () {
      _checkCopies(item, [
        ('agent', item.copyWith(agent: null), null),
        ('status', item.copyWith(status: null), null),
        ('namespace', item.copyWith(namespace: null), null),
        ('created_by', item.copyWith(createdBy: null), null),
        ('caller', item.copyWith(caller: null), null),
        ('async', item.copyWith(async: null), null),
      ], OutputItem.fromJson);
    });
    test(
      'replay preserves every supported input field including beta agent',
      () {
        final replay = item.toFunctionCallItem();
        final expected = {...item.toJson()}..remove('created_by');
        expect(replay.toJson(), expected);
        expect(Item.fromJson(expected), replay);
        expect(item.toString(), isNot(contains('do not print')));
        for (final field in [
          'id:',
          'agent:',
          'callId:',
          'name:',
          'arguments: <redacted>',
          'status:',
          'namespace:',
          'createdBy:',
          'caller:',
          'async: true',
        ]) {
          expect(item.toString(), contains(field));
        }
      },
    );
  });

  group('custom input contracts', () {
    const item = CustomToolCallInputItem(
      id: 'f1',
      agent: _agent,
      callId: 'c1',
      name: 'lookup',
      input: 'private free form tool input',
      namespace: 'tools',
      caller: _caller,
      async: true,
    );
    test(
      'direct custom input parses through Item without coercing free form',
      () {
        expect(Item.fromJson(item.toJson()), item);
        expect(item.copyWith(), item);
        expect(item.copyWith().hashCode, item.hashCode);
        expect(item.copyWith().toJson(), item.toJson());
        expect(item.copyWith(callId: null, name: null, input: null), item);
      },
    );
    test('independently replaces every field', () {
      _checkCopies(item, [
        ('id', item.copyWith(id: 'f2'), 'f2'),
        ('agent', item.copyWith(agent: _otherAgent), _otherAgent.toJson()),
        ('call_id', item.copyWith(callId: 'c2'), 'c2'),
        ('name', item.copyWith(name: 'other'), 'other'),
        ('input', item.copyWith(input: 'other'), 'other'),
        ('namespace', item.copyWith(namespace: 'other'), 'other'),
        ('caller', item.copyWith(caller: _otherCaller), _otherCaller.toJson()),
        ('async', item.copyWith(async: false), false),
      ], Item.fromJson);
    });
    test('independently clears every optional field', () {
      _checkCopies(item, [
        ('id', item.copyWith(id: null), null),
        ('agent', item.copyWith(agent: null), null),
        ('namespace', item.copyWith(namespace: null), null),
        ('caller', item.copyWith(caller: null), null),
        ('async', item.copyWith(async: null), null),
      ], Item.fromJson);
    });
    test('redacts free form input and retains metadata', () {
      expect(item.toString(), isNot(contains(item.input)));
      for (final field in [
        'id:',
        'agent:',
        'callId:',
        'name:',
        'input: <redacted>',
        'namespace:',
        'caller:',
        'async: true',
      ]) {
        expect(item.toString(), contains(field));
      }
    });
    for (final key in ['type', 'call_id', 'name', 'input']) {
      test('rejects missing/null/wrong required $key', () {
        final wire = item.toJson();
        expect(
          () => CustomToolCallInputItem.fromJson({...wire}..remove(key)),
          throwsFormatException,
        );
        expect(
          () => CustomToolCallInputItem.fromJson({...wire, key: null}),
          throwsFormatException,
        );
        expect(
          () => CustomToolCallInputItem.fromJson({...wire, key: 1}),
          throwsFormatException,
        );
      });
    }
    for (final key in ['id', 'namespace']) {
      test('rejects null/wrong optional nonnull $key', () {
        expect(
          () => CustomToolCallInputItem.fromJson({...item.toJson(), key: null}),
          throwsFormatException,
        );
        expect(
          () => CustomToolCallInputItem.fromJson({...item.toJson(), key: 1}),
          throwsFormatException,
        );
      });
    }
  });

  group('custom output contracts', () {
    const item = CustomToolCallItem(
      id: 'f1',
      agent: _agent,
      callId: 'c1',
      name: 'lookup',
      input: 'private free form tool input',
      namespace: 'tools',
      status: ItemStatus.completed,
      createdBy: 'creator',
      caller: _caller,
      async: true,
    );
    test('all fields round-trip through output and no-op copy', () {
      expect(OutputItem.fromJson(item.toJson()), item);
      expect(item.copyWith(), item);
      expect(item.copyWith().hashCode, item.hashCode);
      expect(item.copyWith().toJson(), item.toJson());
      expect(
        item.copyWith(id: null, callId: null, name: null, input: null),
        item,
      );
    });
    test('independently replaces every field', () {
      _checkCopies(item, [
        ('id', item.copyWith(id: 'f2'), 'f2'),
        ('agent', item.copyWith(agent: _otherAgent), _otherAgent.toJson()),
        ('call_id', item.copyWith(callId: 'c2'), 'c2'),
        ('name', item.copyWith(name: 'other'), 'other'),
        ('input', item.copyWith(input: 'other'), 'other'),
        ('namespace', item.copyWith(namespace: 'other'), 'other'),
        ('status', item.copyWith(status: ItemStatus.incomplete), 'incomplete'),
        ('created_by', item.copyWith(createdBy: 'other'), 'other'),
        ('caller', item.copyWith(caller: _otherCaller), _otherCaller.toJson()),
        ('async', item.copyWith(async: false), false),
      ], OutputItem.fromJson);
    });
    test('independently clears every optional field', () {
      _checkCopies(item, [
        ('agent', item.copyWith(agent: null), null),
        ('namespace', item.copyWith(namespace: null), null),
        ('status', item.copyWith(status: null), null),
        ('created_by', item.copyWith(createdBy: null), null),
        ('caller', item.copyWith(caller: null), null),
        ('async', item.copyWith(async: null), null),
      ], OutputItem.fromJson);
    });
    test('replay retains supported fields without output-only metadata', () {
      final replay = item.toCustomToolCallInputItem();
      final expected = {...item.toJson()}
        ..remove('created_by')
        ..remove('status');
      expect(replay.toJson(), expected);
      expect(Item.fromJson(expected), replay);
      expect(item.toString(), isNot(contains(item.input)));
      for (final field in [
        'id:',
        'agent:',
        'callId:',
        'name:',
        'input: <redacted>',
        'namespace:',
        'status:',
        'createdBy:',
        'caller:',
        'async: true',
      ]) {
        expect(item.toString(), contains(field));
      }
    });
  });
}
