import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  const first = ConfigurationUpdateItemResponse(
    id: 'cfg_1',
    reasoning: ConfigurationUpdateReasoning(effort: ReasoningEffort.high),
    agent: AgentTag(agentName: 'private_worker'),
  );
  const second = ConfigurationUpdateItemResponse(
    id: 'cfg_2',
    reasoning: ConfigurationUpdateReasoning(effort: ReasoningEffort.low),
  );
  const original = InputItemList(
    data: [first, second],
    object: 'list',
    hasMore: true,
    firstId: 'cfg_1',
    lastId: 'cfg_2',
  );

  group('InputItemList value and serialization contracts', () {
    test(
      'supports const construction and full contextual JSON round trips',
      () {
        final expected = {
          'object': 'list',
          'has_more': true,
          'first_id': 'cfg_1',
          'last_id': 'cfg_2',
          'data': [
            {
              'type': 'configuration_update',
              'id': 'cfg_1',
              'reasoning': {'effort': 'high'},
              'agent': {'agent_name': 'private_worker'},
            },
            {
              'type': 'configuration_update',
              'id': 'cfg_2',
              'reasoning': {'effort': 'low'},
            },
          ],
        };
        final parsed = InputItemList.fromJson(expected);

        expect(original.toJson(), expected);
        expect(parsed.toJson(), expected);
        expect(parsed, original);
        expect(parsed.hashCode, original.hashCode);
        expect(parsed.data, isNot(same(original.data)));
        expect(parsed.data.first, isA<ConfigurationUpdateItemResponse>());
        expect({parsed, original}, hasLength(1));
      },
    );

    test('omits absent optional IDs and preserves an empty page', () {
      const page = InputItemList(data: [], object: 'list', hasMore: false);
      expect(page.toJson(), {
        'data': <Object>[],
        'object': 'list',
        'has_more': false,
      });
      expect(InputItemList.fromJson(page.toJson()), page);
      expect(page.copyWith(), page);
      expect(page.toString(), contains('data: 0 items'));
      expect(page.toString(), contains('firstId: null'));
      expect(page.toString(), contains('lastId: null'));
    });

    test('preserves existing optional pagination-null normalization', () {
      final parsed = InputItemList.fromJson(const {
        'data': <Object>[],
        'object': 'list',
        'has_more': false,
        'first_id': null,
        'last_id': null,
      });
      expect(parsed.firstId, isNull);
      expect(parsed.lastId, isNull);
      expect(parsed.toJson(), {
        'data': <Object>[],
        'object': 'list',
        'has_more': false,
      });
    });

    test(
      'compares equal contents in independently created lists structurally',
      () {
        final independentlyConstructed = InputItemList(
          data: [
            ConfigurationUpdateItemResponse.fromJson(first.toJson()),
            ConfigurationUpdateItemResponse.fromJson(second.toJson()),
          ],
          object: 'list',
          hasMore: true,
          firstId: 'cfg_1',
          lastId: 'cfg_2',
        );

        expect(independentlyConstructed.data, isNot(same(original.data)));
        expect(independentlyConstructed, original);
        expect(independentlyConstructed.hashCode, original.hashCode);
        expect({original: 'page'}[independentlyConstructed], 'page');
      },
    );

    final changes = <(String, InputItemList, Object?)>[
      ('data', original.copyWith(data: const [first]), [first.toJson()]),
      ('object', original.copyWith(object: 'future_list'), 'future_list'),
      ('has_more', original.copyWith(hasMore: false), false),
      ('first_id', original.copyWith(firstId: 'cfg_start'), 'cfg_start'),
      ('first_id', original.copyWith(firstId: null), null),
      ('last_id', original.copyWith(lastId: 'cfg_end'), 'cfg_end'),
      ('last_id', original.copyWith(lastId: null), null),
    ];
    for (final (key, changed, value) in changes) {
      test('copy/value/hash include $key changed to $value', () {
        final expected = original.toJson();
        if (value == null) {
          expected.remove(key);
        } else {
          expected[key] = value;
        }
        final parsed = InputItemList.fromJson(expected);

        expect(changed.toJson(), expected);
        expect(changed, parsed);
        expect(changed.hashCode, parsed.hashCode);
        expect(changed, isNot(original));
        expect(changed.hashCode, isNot(original.hashCode));
        expect(original.firstId, 'cfg_1');
        expect(original.lastId, 'cfg_2');
        expect(original.hasMore, isTrue);
        expect(original.data, const [first, second]);
      });
    }

    test(
      'copy with omitted fields preserves their values and list identity',
      () {
        final copied = original.copyWith();
        expect(copied, original);
        expect(copied.hashCode, original.hashCode);
        expect(copied.data, same(original.data));
        expect(original.copyWith(firstId: null, lastId: null).toJson(), {
          'data': [first.toJson(), second.toJson()],
          'object': 'list',
          'has_more': true,
        });
      },
    );

    test('list order contributes to equality and hashing', () {
      final reversed = original.copyWith(data: const [second, first]);
      expect(reversed, isNot(original));
      expect(reversed.hashCode, isNot(original.hashCode));
      expect(InputItemList.fromJson(reversed.toJson()), reversed);
      expect(
        InputItemList.fromJson(reversed.toJson()).hashCode,
        reversed.hashCode,
      );
    });

    final nestedChanges = <(String, ConfigurationUpdateItemResponse)>[
      ('id', first.copyWith(id: 'cfg_changed')),
      (
        'reasoning effort',
        first.copyWith(
          reasoning: const ConfigurationUpdateReasoning(
            effort: ReasoningEffort.low,
          ),
        ),
      ),
      (
        'agent name',
        first.copyWith(agent: const AgentTag(agentName: 'other_worker')),
      ),
    ];
    for (final (field, item) in nestedChanges) {
      test('nested configuration $field contributes to list value/hash', () {
        final changed = original.copyWith(data: [item, second]);
        final parsed = InputItemList.fromJson(changed.toJson());

        expect(changed, isNot(original));
        expect(changed.hashCode, isNot(original.hashCode));
        expect(parsed, changed);
        expect(parsed.hashCode, changed.hashCode);
        expect(parsed.data.first, item);
      });
    }

    test('diagnostics cover all fields while summarizing item payloads', () {
      final diagnostic = original.toString();
      expect(diagnostic, contains('data: 2 items'));
      expect(diagnostic, contains('object: list'));
      expect(diagnostic, contains('hasMore: true'));
      expect(diagnostic, contains('firstId: cfg_1'));
      expect(diagnostic, contains('lastId: cfg_2'));
      expect(diagnostic, isNot(contains('private_worker')));
      expect(diagnostic, isNot(contains('effort')));
    });

    test(
      'preserves caller-owned mutable collections in constructor and copies',
      () {
        final callerData = <Item>[first];
        final page = InputItemList(
          data: callerData,
          object: 'list',
          hasMore: false,
        );
        final copied = page.copyWith();
        expect(page.data, same(callerData));
        expect(copied.data, same(callerData));
        callerData.add(second);
        expect(page.data, const [first, second]);
        expect(copied.data, const [first, second]);

        final replacement = <Item>[second];
        final replaced = page.copyWith(data: replacement);
        expect(replaced.data, same(replacement));
        expect(page.data, same(callerData));
      },
    );
  });
}
