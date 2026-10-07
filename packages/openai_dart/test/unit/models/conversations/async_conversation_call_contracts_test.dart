import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final kind in ['function_call', 'custom_tool_call']) {
    group('Conversation $kind async contracts', () {
      final payloadKey = kind == 'function_call' ? 'arguments' : 'input';
      Map<String, dynamic> fixture() => {
        'type': kind,
        'id': 'item_one',
        'call_id': 'call_one',
        'name': 'tool_one',
        payloadKey: 'private tool payload',
        'namespace': 'namespace_one',
        'status': 'completed',
        'caller': {'type': 'program', 'caller_id': 'program_one'},
        'agent': {'agent_name': '/worker_one'},
        'async': true,
        'created_by': 'creator_one',
      };
      test('full JSON round trip and value contract', () {
        final first = ConversationItem.fromJson(fixture());
        final second = ConversationItem.fromJson(fixture());
        expect(first.toJson(), fixture());
        expect(switch (first) {
          final ConversationFunctionCallItem v => v.type,
          final ConversationCustomToolCallItem v => v.type,
          _ => throw StateError('unexpected fixture'),
        }, kind);
        expect(first, second);
        expect(first.hashCode, second.hashCode);
        expect({first, second}, hasLength(1));
        expect(first.toString(), contains('async: true'));
        expect(first.toString(), contains('createdBy: creator_one'));
        expect(first.toString(), contains('namespace: namespace_one'));
        expect(first.toString(), contains('[20 chars]'));
        expect(first.toString(), isNot(contains('private tool payload')));
      });
      for (final value in [null, false, true]) {
        test('async absent/false/true: $value', () {
          final json = fixture()..remove('async');
          if (value != null) json['async'] = value;
          final item = ConversationItem.fromJson(json);
          expect(item.toJson(), json);
        });
      }
      for (final invalid in [
        null,
        1,
        'true',
        <Object?>[],
        <String, Object?>{},
      ]) {
        test('rejects supplied malformed async: $invalid', () {
          expect(
            () => ConversationItem.fromJson({...fixture(), 'async': invalid}),
            throwsA(isA<FormatException>()),
          );
        });
      }
      final replacements = <String, Object?>{
        'id': 'item_two',
        'call_id': 'call_two',
        'name': 'tool_two',
        payloadKey: 'replacement tool payload',
        'namespace': 'namespace_two',
        'status': ItemStatus.incomplete,
        'caller': const DirectToolCallCaller(),
        'agent': const AgentTag(agentName: '/worker_two'),
        'async': false,
        'created_by': 'creator_two',
      };
      for (final entry in replacements.entries) {
        test('copy and equality include ${entry.key}', () {
          final source = ConversationItem.fromJson(fixture());
          final changed = _copy(source, entry.key, entry.value);
          final expected = fixture();
          expected[entry.key] = switch (entry.value) {
            final ItemStatus v => v.toJson(),
            final ToolCallCaller v => v.toJson(),
            final AgentTag v => v.toJson(),
            _ => entry.value,
          };
          expect(changed.toJson(), expected);
          expect(changed, isNot(source));
          expect(source.toJson(), fixture());
          expect(changed, ConversationItem.fromJson(expected));
          expect(
            changed.hashCode,
            ConversationItem.fromJson(expected).hashCode,
          );
        });
      }
      final clearable = [
        if (kind == 'custom_tool_call') 'id',
        'namespace',
        'status',
        'caller',
        'agent',
        'async',
        'created_by',
      ];
      for (final key in clearable) {
        test('copy clears $key without dropping other fields', () {
          final source = ConversationItem.fromJson(fixture());
          final cleared = _copy(source, key, null);
          expect(cleared.toJson(), fixture()..remove(key));
          expect(source.toJson(), fixture());
        });
      }
      test('copy omission retains all fields', () {
        final source = ConversationItem.fromJson(fixture());
        final copied = switch (source) {
          final ConversationFunctionCallItem v => v.copyWith(),
          final ConversationCustomToolCallItem v => v.copyWith(),
          _ => throw StateError('unexpected fixture'),
        };
        expect(copied.toJson(), fixture());
        expect(copied, source);
      });
      for (final key in ['call_id', 'name', payloadKey]) {
        test('required $key fails contextually', () {
          for (final value in [null, 12, <String, Object?>{}]) {
            expect(
              () => ConversationItem.fromJson({...fixture(), key: value}),
              throwsA(isA<FormatException>()),
            );
          }
          expect(
            () => ConversationItem.fromJson(fixture()..remove(key)),
            throwsA(isA<FormatException>()),
          );
        });
      }
      test('subtype discriminator rejects another call kind', () {
        final wrong = fixture()..['type'] = 'wrong';
        expect(
          () => kind == 'function_call'
              ? ConversationFunctionCallItem.fromJson(wrong)
              : ConversationCustomToolCallItem.fromJson(wrong),
          throwsA(isA<FormatException>()),
        );
      });
      test('existing optional-null metadata stays compatible', () {
        final json = fixture();
        for (final key in ['namespace', 'status', 'caller', 'agent']) {
          json[key] = null;
        }
        final expected = fixture();
        ['namespace', 'status', 'caller', 'agent'].forEach(expected.remove);
        expect(ConversationItem.fromJson(json).toJson(), expected);
      });
    });
  }
}

ConversationItem _copy(ConversationItem source, String key, Object? value) =>
    switch (source) {
      final ConversationFunctionCallItem v => switch (key) {
        'id' => v.copyWith(id: value as String?),
        'call_id' => v.copyWith(callId: value as String?),
        'name' => v.copyWith(name: value as String?),
        'arguments' => v.copyWith(arguments: value as String?),
        'namespace' => v.copyWith(namespace: value),
        'status' => v.copyWith(status: value),
        'caller' => v.copyWith(caller: value),
        'agent' => v.copyWith(agent: value),
        'async' => v.copyWith(async: value),
        'created_by' => v.copyWith(createdBy: value),
        _ => throw ArgumentError.value(key),
      },
      final ConversationCustomToolCallItem v => switch (key) {
        'id' => v.copyWith(id: value as String?),
        'call_id' => v.copyWith(callId: value as String?),
        'name' => v.copyWith(name: value as String?),
        'input' => v.copyWith(input: value as String?),
        'namespace' => v.copyWith(namespace: value),
        'status' => v.copyWith(status: value),
        'caller' => v.copyWith(caller: value),
        'agent' => v.copyWith(agent: value),
        'async' => v.copyWith(async: value),
        'created_by' => v.copyWith(createdBy: value),
        _ => throw ArgumentError.value(key),
      },
      _ => throw ArgumentError.value(source),
    };
