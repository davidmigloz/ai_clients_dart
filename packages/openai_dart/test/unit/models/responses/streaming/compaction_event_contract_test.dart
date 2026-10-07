import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  const type = 'response.compaction.compacting';
  const context = 'ResponseCompactionCompactingEvent';
  const privateAgentName = 'private-compaction-agent';
  const agent = AgentTag(agentName: privateAgentName);

  Map<String, dynamic> fixture({bool beta = false}) => {
    'type': type,
    'sequence_number': 3,
    'output_index': 1,
    'item_id': 'cmp_123',
    if (beta) 'agent': agent.toJson(),
  };

  Matcher formatError(String field) => throwsA(
    isA<FormatException>().having(
      (error) => error.message,
      'context',
      contains('$context.$field'),
    ),
  );

  group('ResponseCompactionCompactingEvent', () {
    for (final beta in [false, true]) {
      group(beta ? 'beta payload' : 'canonical payload', () {
        test('public dispatcher and direct parser preserve exact fields', () {
          final json = fixture(beta: beta);
          final event = ResponseStreamEvent.fromJson(json);
          expect(event, isA<ResponseCompactionCompactingEvent>());
          final direct = ResponseCompactionCompactingEvent.fromJson(json);
          expect(direct.type, type);
          expect(direct.sequenceNumber, 3);
          expect(direct.outputIndex, 1);
          expect(direct.itemId, 'cmp_123');
          expect(direct.agent, beta ? agent : isNull);
          expect(event, direct);
          expect(event.hashCode, direct.hashCode);
          expect(event.toJson(), json);
          expect(
            ResponseStreamEvent.fromJson(
              jsonDecode(jsonEncode(event.toJson())) as Map<String, dynamic>,
            ),
            event,
          );
        });

        test('progress is nonterminal and contains no content fields', () {
          final event = ResponseStreamEvent.fromJson(fixture(beta: beta));
          expect(event.isFinal, isFalse);
          expect(event.toJson().containsKey('summary'), isFalse);
          expect(event.toJson().containsKey('encrypted_content'), isFalse);
          expect(event.toJson().containsKey('status'), isFalse);
        });

        test('copy preserves all fields when none are replaced', () {
          final event = ResponseCompactionCompactingEvent.fromJson(
            fixture(beta: beta),
          );
          final copied = event.copyWith();
          expect(copied, event);
          expect(copied.hashCode, event.hashCode);
          expect(copied.toJson(), event.toJson());
          expect(copied.isFinal, isFalse);
        });

        test('diagnostics include all metadata and redact the agent name', () {
          final event = ResponseCompactionCompactingEvent.fromJson(
            fixture(beta: beta),
          );
          final text = event.toString();
          expect(text, startsWith('$context('));
          expect(text, contains('sequenceNumber: 3'));
          expect(text, contains('outputIndex: 1'));
          expect(text, contains('itemId: cmp_123'));
          expect(
            text,
            contains(
              'agent: ${beta ? '[${privateAgentName.length} chars]' : 'null'}',
            ),
          );
          expect(text, isNot(contains(privateAgentName)));
          expect(text, isNot(contains('summary:')));
          expect(text, isNot(contains('encryptedContent:')));
          expect(event.toJson(), fixture(beta: beta));
        });
      });
    }

    for (final field in ['sequence_number', 'output_index', 'item_id']) {
      test('requires $field in both parsing paths', () {
        final json = fixture(beta: true)..remove(field);
        expect(
          () => ResponseCompactionCompactingEvent.fromJson(json),
          formatError(field),
        );
        expect(() => ResponseStreamEvent.fromJson(json), formatError(field));
      });

      final values = field == 'item_id'
          ? <Object?>[null, 1, true, <String, dynamic>{}, <Object>[]]
          : <Object?>[
              null,
              1.5,
              1.0,
              '1',
              true,
              <String, dynamic>{},
              <Object>[],
            ];
      for (final value in values) {
        test('rejects malformed $field $value in both parsing paths', () {
          final json = {...fixture(beta: true), field: value};
          expect(
            () => ResponseCompactionCompactingEvent.fromJson(json),
            formatError(field),
          );
          expect(() => ResponseStreamEvent.fromJson(json), formatError(field));
        });
      }
    }

    for (final value in [
      null,
      '',
      'response.compaction.completed',
      1,
      true,
      <String, dynamic>{},
      <Object>[],
    ]) {
      test('direct parser rejects malformed discriminator $value', () {
        expect(
          () => ResponseCompactionCompactingEvent.fromJson({
            ...fixture(),
            'type': value,
          }),
          formatError('type'),
        );
      });
    }

    test('direct parser requires discriminator', () {
      expect(
        () => ResponseCompactionCompactingEvent.fromJson(
          fixture()..remove('type'),
        ),
        formatError('type'),
      );
    });

    for (final value in [null, 1, true, '', <Object>[]]) {
      test('rejects supplied nonobject agent $value in both parsing paths', () {
        final json = {...fixture(), 'agent': value};
        expect(
          () => ResponseCompactionCompactingEvent.fromJson(json),
          formatError('agent'),
        );
        expect(() => ResponseStreamEvent.fromJson(json), formatError('agent'));
      });
    }

    for (final value in [
      <String, dynamic>{},
      {'agent_name': null},
      {'agent_name': 1},
      {'agent_name': true},
      {'agent_name': <String, dynamic>{}},
      {'agent_name': <Object>[]},
    ]) {
      test('rejects malformed agent_name $value with nested context', () {
        final json = {...fixture(), 'agent': value};
        expect(
          () => ResponseCompactionCompactingEvent.fromJson(json),
          formatError('agent.agent_name'),
        );
        expect(
          () => ResponseStreamEvent.fromJson(json),
          formatError('agent.agent_name'),
        );
      });
    }

    test('rejects an agent object with a nonstring key', () {
      expect(
        () => ResponseStreamEvent.fromJson({
          ...fixture(),
          'agent': const <Object?, Object?>{1: 'not-a-name'},
        }),
        formatError('agent key'),
      );
    });

    test('accepts dynamically typed string-keyed agent maps', () {
      final event = ResponseCompactionCompactingEvent.fromJson({
        ...fixture(),
        'agent': const <Object?, Object?>{'agent_name': privateAgentName},
      });
      expect(event.agent, agent);
      expect(event.toJson(), fixture(beta: true));
    });

    test(
      'empty strings and zero indices are retained without fabricated defaults',
      () {
        final json = {
          'type': type,
          'sequence_number': 0,
          'output_index': 0,
          'item_id': '',
          'agent': {'agent_name': ''},
        };
        final event = ResponseCompactionCompactingEvent.fromJson(json);
        expect(event.toJson(), json);
        expect(event.agent!.agentName, '');
        expect(event.toString(), contains('agent: [0 chars]'));
      },
    );

    test('constructor is const and preserves required metadata', () {
      const event = ResponseCompactionCompactingEvent(
        sequenceNumber: 3,
        outputIndex: 1,
        itemId: 'cmp_123',
        agent: agent,
      );
      expect(event.toJson(), fixture(beta: true));
      expect(event.isFinal, isFalse);
    });

    final replacements = <String, Object>{
      'sequence_number': 8,
      'output_index': 4,
      'item_id': 'cmp_changed',
      'agent': const AgentTag(agentName: 'other-agent'),
    };
    for (final entry in replacements.entries) {
      test('copy, equality and hash include ${entry.key}', () {
        final original = ResponseCompactionCompactingEvent.fromJson(
          fixture(beta: true),
        );
        final changed = switch (entry.key) {
          'sequence_number' => original.copyWith(
            sequenceNumber: entry.value as int,
          ),
          'output_index' => original.copyWith(outputIndex: entry.value as int),
          'item_id' => original.copyWith(itemId: entry.value as String),
          _ => original.copyWith(agent: entry.value),
        };
        final expected = {
          ...fixture(beta: true),
          entry.key: entry.value is AgentTag
              ? (entry.value as AgentTag).toJson()
              : entry.value,
        };
        final parsed = ResponseCompactionCompactingEvent.fromJson(expected);
        expect(changed, isNot(original));
        expect(changed.toJson(), expected);
        expect(changed, parsed);
        expect(changed.hashCode, parsed.hashCode);
        expect({changed, parsed}, hasLength(1));
      });
    }

    test('copy replaces all fields together', () {
      final event = ResponseCompactionCompactingEvent.fromJson(
        fixture(beta: true),
      );
      final changed = event.copyWith(
        sequenceNumber: 8,
        outputIndex: 4,
        itemId: 'cmp_changed',
        agent: const AgentTag(agentName: 'other-agent'),
      );
      final json = {
        'type': type,
        'sequence_number': 8,
        'output_index': 4,
        'item_id': 'cmp_changed',
        'agent': {'agent_name': 'other-agent'},
      };
      final parsed = ResponseCompactionCompactingEvent.fromJson(json);
      expect(changed.toJson(), json);
      expect(changed, parsed);
      expect(changed.hashCode, parsed.hashCode);
    });

    test('copy clears agent and can restore it', () {
      final original = ResponseCompactionCompactingEvent.fromJson(
        fixture(beta: true),
      );
      final cleared = original.copyWith(agent: null);
      final canonical = ResponseCompactionCompactingEvent.fromJson(fixture());
      expect(cleared.agent, isNull);
      expect(cleared.toJson(), fixture());
      expect(cleared.toString(), contains('agent: null'));
      expect(cleared, isNot(original));
      expect(cleared, canonical);
      expect(cleared.hashCode, canonical.hashCode);
      expect(cleared.copyWith(agent: agent), original);
      expect(original.agent, agent);
    });

    test('copy rejects an invalid agent value at runtime', () {
      final event = ResponseCompactionCompactingEvent.fromJson(fixture());
      expect(() => event.copyWith(agent: 'worker'), throwsA(isA<TypeError>()));
    });

    test('same nested agent value has matching equality and hash', () {
      const first = ResponseCompactionCompactingEvent(
        sequenceNumber: 3,
        outputIndex: 1,
        itemId: 'cmp_123',
        agent: agent,
      );
      final parsed = ResponseCompactionCompactingEvent.fromJson(
        fixture(beta: true),
      );
      expect(first, parsed);
      expect(parsed, first);
      expect(first.hashCode, parsed.hashCode);
      expect({first, parsed}, hasLength(1));
    });

    test('unrelated objects and same-field subclasses are unequal', () {
      const original = ResponseCompactionCompactingEvent(
        sequenceNumber: 3,
        outputIndex: 1,
        itemId: 'cmp_123',
        agent: agent,
      );
      const child = _DerivedCompactionEvent(
        sequenceNumber: 3,
        outputIndex: 1,
        itemId: 'cmp_123',
        agent: agent,
      );
      const sameChild = _DerivedCompactionEvent(
        sequenceNumber: 3,
        outputIndex: 1,
        itemId: 'cmp_123',
        agent: agent,
      );
      expect(original == Object(), isFalse);
      expect(original == child, isFalse);
      expect(child == original, isFalse);
      expect(child, sameChild);
      expect(child.hashCode, sameChild.hashCode);
      final distinctEvents = {original, child}..add(sameChild);
      expect(distinctEvents, hasLength(2));
    });
  });

  test('unknown event dispatch retains future JSON and stays nonterminal', () {
    final json = {
      'type': 'response.compaction.future_progress',
      'sequence_number': 9,
      'future': {
        'values': [1, 'opaque'],
      },
    };
    final event = ResponseStreamEvent.fromJson(json);
    expect(event, isA<UnknownEvent>());
    expect(event.type, 'response.compaction.future_progress');
    expect(event.sequenceNumber, 9);
    expect(event.toJson(), json);
    expect(event.isFinal, isFalse);
  });
}

class _DerivedCompactionEvent extends ResponseCompactionCompactingEvent {
  const _DerivedCompactionEvent({
    required super.sequenceNumber,
    required super.outputIndex,
    required super.itemId,
    super.agent,
  });
}
