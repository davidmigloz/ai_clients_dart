import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/agent_subagent_wire_fixtures.dart';

void main() {
  test(
    'received active/closed/resumed state retains nullable content and original opening',
    () {
      final states =
          jsonDecode(
                r'''{"active":{"id":"subagent_child","object":"agent.session.subagent","session_id":"session_synthetic","name":null,"instructions":null,"parent_agent_id":"root_agent","status":"active","opened_at":1,"closed_at":null},"closed":{"closed_at":2,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"closed"},"resumed":{"closed_at":null,"id":"subagent_child","instructions":[{"type":"output_text","text":"PRIVATE-task-café🚀 [image preview] [audio preview]"},{"type":"encrypted_content","encrypted_content":"PRIVATE-encrypted-opaque"}],"name":"PRIVATE-field-café🚀","object":"agent.session.subagent","opened_at":1,"parent_agent_id":"root_agent","session_id":"session_synthetic","status":"active"}}''',
              )
              as Map<String, dynamic>;
      final active = AgentSessionSubagent.fromJson(
        states['active'] as Map<String, dynamic>,
      );
      final closed = AgentSessionSubagent.fromJson(
        states['closed'] as Map<String, dynamic>,
      );
      final resumed = AgentSessionSubagent.fromJson(
        states['resumed'] as Map<String, dynamic>,
      );
      expect(active.closedAt, isNull);
      expect(closed.closedAt, isNotNull);
      expect(resumed.closedAt, isNull);
      expect(resumed.openedAt, active.openedAt);
      expect(closed.openedAt, active.openedAt);
      expect(
        resumed.toJson()['instructions'],
        (states['resumed'] as Map<String, dynamic>)['instructions'],
      );
      expect(
        closed
            .copyWith(
              closedAt: null,
              status: AgentSessionSubagentStatusResource.active,
            )
            .closedAt,
        isNull,
      );
      expect(closed.copyWith().hashCode, closed.hashCode);
      for (final value in [active, closed, resumed]) {
        expect(value.toString(), isNot(contains('PRIVATE')));
      }
    },
  );

  for (final fixture in subagentWireFixtures) {
    test(
      '${fixture.schema}: independent minimal/full wire and value semantics',
      () {
        for (final wire in [fixture.minimal, fixture.full]) {
          final value = fixture.parse(wire);
          expect(value.toJson(), wire);
          final copied = copySubagentFixture(value);
          expect(copied.toJson(), wire);
          expect(copied, value);
          expect(copied.hashCode, value.hashCode);
          expect(value.toString(), isNot(contains('PRIVATE')));
        }
      },
    );
    if (fixture.full is Map<String, dynamic>) {
      test(
        '${fixture.schema}: required presence and nonnull types fail privately',
        () {
          for (final key in fixture.requiredKeys) {
            final missing = Map<String, dynamic>.from(fixture.full! as Map)
              ..remove(key);
            expect(() => fixture.parse(missing), throwsA(_privateFormat));
            if (!fixture.nullableKeys.contains(key)) {
              expect(
                () => fixture.parse({...missing, key: null}),
                throwsA(_privateFormat),
              );
            }
          }
          for (final key in fixture.optionalNonnullKeys) {
            expect(
              () => fixture.parse({
                ...fixture.full! as Map<String, dynamic>,
                key: null,
              }),
              throwsA(_privateFormat),
            );
          }
        },
      );
      test(
        '${fixture.schema}: future extras are closed for writes and owned for reads',
        () {
          final extra = <String, dynamic>{
            'nested': <Object?>['PRIVATE-future', null, true],
          };
          final input = {
            ...fixture.full! as Map<String, dynamic>,
            'future': extra,
          };
          if (fixture.writable) {
            expect(() => fixture.parse(input), throwsA(_privateFormat));
          } else {
            final value = fixture.parse(input);
            final expected = jsonDecode(jsonEncode(input));
            (extra['nested'] as List)[0] = 'changed';
            expect(value.toJson(), expected);
            expect(value.toString(), isNot(contains('PRIVATE')));
            expect(copySubagentFixture(value), value);
            expect(
              () =>
                  (((value.toJson() as Map<String, dynamic>)['future']
                              as Map<String, dynamic>)['nested']
                          as List<Object?>)
                      .add(0),
              throwsUnsupportedError,
            );
            expect(
              () => fixture.parse({
                ...fixture.full! as Map<String, dynamic>,
                'future': double.nan,
              }),
              throwsA(_privateFormat),
            );
            final cycle = <String, dynamic>{};
            cycle['self'] = cycle;
            expect(
              () => fixture.parse({
                ...fixture.full! as Map<String, dynamic>,
                'future': cycle,
              }),
              throwsA(_privateFormat),
            );
          }
        },
      );
    }
  }
}

final TypeMatcher<FormatException> _privateFormat = isA<FormatException>()
    .having(
      (error) => error.toString(),
      'private message',
      isNot(contains('PRIVATE')),
    );
