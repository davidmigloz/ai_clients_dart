import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _json(Object item) => switch (item) {
  final Item item => item.toJson(),
  final ConversationItem item => item.toJson(),
  _ => throw ArgumentError('Not a configuration update'),
};

String _type(Object item) => switch (item) {
  final ConfigurationUpdateItem item => item.type,
  final ConfigurationUpdateItemResponse item => item.type,
  final ConversationConfigurationUpdateItem item => item.type,
  _ => throw ArgumentError('Not a configuration update'),
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
    expect(_json(original), before, reason: 'original after $key');
  }
}

void main() {
  const agent = AgentTag(agentName: 'worker');
  const reasoning = ConfigurationUpdateReasoning(effort: ReasoningEffort.high);
  const otherAgent = AgentTag(agentName: 'other');
  const otherReasoning = ConfigurationUpdateReasoning(
    effort: ReasoningEffort.low,
  );

  final variants =
      <(String, Map<String, dynamic>, Object Function(Map<String, dynamic>))>[
        (
          'ConfigurationUpdateItem',
          {'type': 'configuration_update'},
          ConfigurationUpdateItem.fromJson,
        ),
        (
          'ConfigurationUpdateItemResponse',
          {'type': 'configuration_update', 'id': 'cfg_1'},
          ConfigurationUpdateItemResponse.fromJson,
        ),
        (
          'ConversationConfigurationUpdateItem',
          {'type': 'configuration_update', 'id': 'cfg_1'},
          ConversationConfigurationUpdateItem.fromJson,
        ),
      ];

  for (final (name, minimal, parse) in variants) {
    group('$name contextual wire contract', () {
      test('round trips omitted optional fields and fixed discriminator', () {
        final parsed = parse(minimal);
        expect(_type(parsed), 'configuration_update');
        expect(_json(parsed), minimal);
        expect(parsed.toString(), contains('reasoning: null'));
        expect(parsed.toString(), contains('agent: null'));
      });

      for (final update in <Map<String, dynamic>>[
        {},
        {'effort': 'high'},
      ]) {
        test('retains supplied reasoning $update', () {
          final json = {...minimal, 'reasoning': update};
          final parsed = parse(json);
          expect(_json(parsed), json);
          final equal = parse(json);
          expect(parsed, equal);
          expect(parsed.hashCode, equal.hashCode);
          expect({parsed, equal}, hasLength(1));
        });
      }

      test('normalizes nullable effort within the supplied object', () {
        final parsed = parse({
          ...minimal,
          'reasoning': {'effort': null},
        });
        expect(_json(parsed), {...minimal, 'reasoning': <String, dynamic>{}});
      });

      test('retains beta agent metadata with a complete value contract', () {
        final json = {
          ...minimal,
          'id': 'cfg_1',
          'reasoning': {'effort': 'high'},
          'agent': {'agent_name': 'worker'},
        };
        final parsed = parse(json);
        expect(_json(parsed), json);
        expect(parsed, parse(json));
        expect(parsed.hashCode, parse(json).hashCode);
        expect(parsed.toString(), contains('type: configuration_update'));
        expect(parsed.toString(), contains('id: cfg_1'));
        expect(parsed.toString(), contains('reasoning: $reasoning'));
        expect(parsed.toString(), contains('agent: $agent'));
      });

      for (final type in <Object?>[null, 1, 'message']) {
        test('rejects wrong discriminator $type contextually', () {
          expect(
            () => parse({...minimal, 'type': type}),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'context',
                contains('$name.type'),
              ),
            ),
          );
        });
      }

      test('rejects omitted discriminator contextually', () {
        final json = Map<String, dynamic>.from(minimal)..remove('type');
        expect(
          () => parse(json),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'context',
              contains('$name.type'),
            ),
          ),
        );
      });

      for (final value in <Object?>[null, 0, 'high', []]) {
        test('rejects supplied reasoning $value contextually', () {
          expect(
            () => parse({...minimal, 'reasoning': value}),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'context',
                contains('$name.reasoning'),
              ),
            ),
          );
        });
      }

      for (final value in <Object>[0, false, [], {}]) {
        test('rejects wrong-type nested effort $value contextually', () {
          expect(
            () => parse({
              ...minimal,
              'reasoning': {'effort': value},
            }),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'context',
                contains('$name.reasoning.effort'),
              ),
            ),
          );
        });
      }

      for (final value in <Object>[0, 'worker', []]) {
        test('rejects wrong-type beta agent $value contextually', () {
          expect(
            () => parse({...minimal, 'agent': value}),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'context',
                contains('$name.agent'),
              ),
            ),
          );
        });
      }

      for (final value in <Object?>[null, 0, false, [], {}]) {
        test('rejects wrong-type agent_name $value contextually', () {
          expect(
            () => parse({
              ...minimal,
              'agent': {'agent_name': value},
            }),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'context',
                contains('$name.agent.agent_name'),
              ),
            ),
          );
        });
      }

      test('rejects an agent without its required agent_name', () {
        expect(
          () => parse({...minimal, 'agent': <String, dynamic>{}}),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'context',
              contains('$name.agent.agent_name'),
            ),
          ),
        );
      });

      test(
        'normalizes string-keyed dynamic objects and rejects nonstring keys',
        () {
          final parsed = parse({
            ...minimal,
            'reasoning': <Object?, Object?>{'effort': 'low'},
            'agent': <Object?, Object?>{'agent_name': 'worker'},
          });
          expect(_json(parsed), {
            ...minimal,
            'reasoning': {'effort': 'low'},
            'agent': {'agent_name': 'worker'},
          });
          expect(
            () => parse({
              ...minimal,
              'reasoning': <Object?, Object?>{1: 'low'},
            }),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'context',
                contains('$name.reasoning key'),
              ),
            ),
          );
        },
      );
    });
  }

  group('Input and returned contextual differences', () {
    test('input id and beta agent accept null and normalize to omission', () {
      final parsed = Item.fromJson({
        'type': 'configuration_update',
        'id': null,
        'agent': null,
      });
      expect(parsed, const ConfigurationUpdateItem());
      expect(parsed.toJson(), {'type': 'configuration_update'});
    });

    for (final value in <Object>[0, false, [], {}]) {
      test('input rejects nonstring id $value contextually', () {
        expect(
          () => Item.fromJson({'type': 'configuration_update', 'id': value}),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'context',
              contains('ConfigurationUpdateItem.id'),
            ),
          ),
        );
      });
    }

    for (final (name, minimal, parse) in variants.skip(1)) {
      for (final value in <Object?>[null, 0, false, [], {}]) {
        test('$name rejects invalid required id $value', () {
          expect(
            () => parse({...minimal, 'id': value}),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'context',
                contains('$name.id'),
              ),
            ),
          );
        });
      }
      test('$name rejects omitted required id', () {
        expect(
          () => parse({'type': 'configuration_update'}),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'context',
              contains('$name.id'),
            ),
          ),
        );
      });
      test('$name rejects explicit null agent', () {
        expect(
          () => parse({...minimal, 'agent': null}),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'context',
              contains('$name.agent'),
            ),
          ),
        );
      });
    }

    test('public factories dispatch to contextual variants', () {
      final json = {'type': 'configuration_update', 'id': 'cfg_1'};
      expect(Item.fromJson(json), const ConfigurationUpdateItem(id: 'cfg_1'));
      expect(
        Item.fromResourceJson(json),
        const ConfigurationUpdateItemResponse(id: 'cfg_1'),
      );
      expect(
        ConversationItem.fromJson(json),
        const ConversationConfigurationUpdateItem(id: 'cfg_1'),
      );
      expect(Item.fromJson(json), isNot(Item.fromResourceJson(json)));
      expect(
        () => Item.fromResourceJson({'type': 'configuration_update'}),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'context',
            contains('ConfigurationUpdateItemResponse.id'),
          ),
        ),
      );
    });

    test(
      'resource dispatch retains other item behavior and provider tolerance',
      () {
        final message = {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': 'hello'},
          ],
        };
        expect(Item.fromResourceJson(message), Item.fromJson(message));
        expect(
          () => Item.fromResourceJson({'type': 'future_item'}),
          throwsFormatException,
        );
        final unknown = {
          'type': 'future_item',
          'data': {'future': true},
        };
        expect(
          ConversationItem.fromJson(unknown),
          isA<ConversationUnknownItem>(),
        );
        expect(ConversationItem.fromJson(unknown).toJson(), unknown);
      },
    );

    test('does not invent a response output variant', () {
      expect(
        () => OutputItem.fromJson({
          'type': 'configuration_update',
          'id': 'cfg_1',
        }),
        throwsFormatException,
      );
    });
  });

  group('Full copy, value, and replay contracts', () {
    const input = ConfigurationUpdateItem(
      id: 'cfg_1',
      reasoning: reasoning,
      agent: agent,
    );
    const returned = ConfigurationUpdateItemResponse(
      id: 'cfg_1',
      reasoning: reasoning,
      agent: agent,
    );
    const conversation = ConversationConfigurationUpdateItem(
      id: 'cfg_1',
      reasoning: reasoning,
      agent: agent,
    );

    test(
      'input supports copies and explicit clearing of every optional field',
      () {
        expect(input.copyWith(), input);
        _checkCopies(input, [
          ('id', input.copyWith(id: 'cfg_2'), 'cfg_2'),
          ('id', input.copyWith(id: null), null),
          (
            'reasoning',
            input.copyWith(reasoning: otherReasoning),
            {'effort': 'low'},
          ),
          ('reasoning', input.copyWith(reasoning: null), null),
          ('agent', input.copyWith(agent: otherAgent), {'agent_name': 'other'}),
          ('agent', input.copyWith(agent: null), null),
        ], ConfigurationUpdateItem.fromJson);
      },
    );

    test('returned item supports copies and every optional clear', () {
      expect(returned.copyWith(), returned);
      _checkCopies(returned, [
        ('id', returned.copyWith(id: 'cfg_2'), 'cfg_2'),
        (
          'reasoning',
          returned.copyWith(reasoning: otherReasoning),
          {'effort': 'low'},
        ),
        ('reasoning', returned.copyWith(reasoning: null), null),
        (
          'agent',
          returned.copyWith(agent: otherAgent),
          {'agent_name': 'other'},
        ),
        ('agent', returned.copyWith(agent: null), null),
      ], ConfigurationUpdateItemResponse.fromJson);
    });

    test('conversation item supports copies and every optional clear', () {
      expect(conversation.copyWith(), conversation);
      _checkCopies(conversation, [
        ('id', conversation.copyWith(id: 'cfg_2'), 'cfg_2'),
        (
          'reasoning',
          conversation.copyWith(reasoning: otherReasoning),
          {'effort': 'low'},
        ),
        ('reasoning', conversation.copyWith(reasoning: null), null),
        (
          'agent',
          conversation.copyWith(agent: otherAgent),
          {'agent_name': 'other'},
        ),
        ('agent', conversation.copyWith(agent: null), null),
      ], ConversationConfigurationUpdateItem.fromJson);
    });

    test(
      'converts returned and conversation items to faithful request input',
      () {
        expect(returned.toConfigurationUpdateItem(), input);
        expect(conversation.toConfigurationUpdateItem(), input);
        expect(
          returned.toConfigurationUpdateItem().toJson(),
          returned.toJson(),
        );
        expect(
          conversation.toConfigurationUpdateItem().toJson(),
          conversation.toJson(),
        );
        const minimal = ConfigurationUpdateItemResponse(id: 'cfg_1');
        expect(
          minimal.toConfigurationUpdateItem(),
          const ConfigurationUpdateItem(id: 'cfg_1'),
        );
      },
    );
  });
}
