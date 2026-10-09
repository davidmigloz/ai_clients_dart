import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/agent_session_copy_fixtures.dart';
import '../fixtures/agent_session_wire_fixtures.dart';

void main() {
  group('Frozen durable-session canonical contracts', () {
    for (final fixture in agentSessionWireFixtures) {
      for (final entry in {
        'minimal': fixture.minimal,
        'full': fixture.full,
      }.entries) {
        test(
          '${fixture.schema} ${entry.key}: exact round trip, copy, hash and privacy',
          () {
            final source = jsonDecode(jsonEncode(entry.value));
            final model = fixture.parse(source);
            expect(model.toJson(), equals(source));
            final copy = fixture.copy(model);
            expect(copy, model);
            expect(copy.hashCode, model.hashCode);
            expect(copy.toJson(), equals(source));
            expect(model.toString(), isNot(contains('PRIVATE')));
            expect(model.toString(), contains('[REDACTED]'));
          },
        );
      }
      if (fixture.full is Map<String, dynamic>) {
        test('${fixture.schema}: all required keys fail when absent', () {
          for (final key in fixture.requiredKeys) {
            final malformed = Map<String, dynamic>.of(
              fixture.full! as Map<String, dynamic>,
            )..remove(key);
            expect(
              () => fixture.parse(malformed),
              throwsA(isA<FormatException>()),
              reason: key,
            );
          }
        });
        test('${fixture.schema}: malformed known fields fail privately', () {
          for (final key in fixture.requiredKeys) {
            final malformed =
                Map<String, dynamic>.of(fixture.full! as Map<String, dynamic>)
                  ..[key] = (fixture.full! as Map<String, dynamic>)[key] is Map
                      ? 'PRIVATE-invalid-known-field'
                      : {'PRIVATE-invalid-known-field': true};
            // Arbitrary function/MCP arguments admit JSON objects.
            if (key == 'arguments' ||
                (fixture.schema == 'McpCallItemResource' &&
                    const {'output', 'error'}.contains(key))) {
              continue;
            }
            expect(
              () => fixture.parse(malformed),
              throwsA(
                isA<FormatException>().having(
                  (error) => error.toString(),
                  'private error',
                  isNot(contains('PRIVATE')),
                ),
              ),
              reason: key,
            );
          }
        });
        if (fixture.writable) {
          test('${fixture.schema}: closed request extras are rejected', () {
            final malformed = Map<String, dynamic>.of(
              fixture.full! as Map<String, dynamic>,
            )..['unsupported_private_field'] = 'PRIVATE';
            expect(
              () => fixture.parse(malformed),
              throwsA(isA<FormatException>()),
            );
          });
        }
      }
    }
  });

  group('Canonical per-field copy/clear contracts', () {
    for (final fixture in agentSessionFieldCopies) {
      test(fixture.name, () {
        final original = fixture.parse(fixture.original);
        final replacement = fixture.parse(fixture.replacement);
        final changed = fixture.copy(original, replacement);
        expect(changed.toJson(), fixture.replacement);
        expect(changed, replacement);
        expect(changed.hashCode, replacement.hashCode);
        expect(changed, isNot(original));
        expect(changed.toString(), isNot(contains('PRIVATE')));
      });
    }
  });

  group('Session spending and creation', () {
    test('exact portable maximum and required nullable cap', () {
      const maximum = 4503599627370495;
      final cap = AgentSessionSpendControlConfig(limit: maximum);
      expect(cap.toJson(), {'limit': maximum});
      expect(
        AgentSessionSpendControlConfig.fromJson(
          jsonDecode(jsonEncode(cap.toJson())) as Map<String, dynamic>,
        ),
        cap,
      );
      expect(cap.copyWith(limit: null).toJson(), {'limit': null});
      expect(
        () => AgentSessionSpendControlConfig(limit: 0),
        throwsFormatException,
      );
      expect(
        () => AgentSessionSpendControlConfig(limit: maximum + 1),
        throwsFormatException,
      );
      expect(
        () => AgentSessionSpendControlConfig.fromJson(const {}),
        throwsFormatException,
      );
      final received = AgentSessionSpendControl(limit: maximum, consumed: null);
      expect(received.copyWith(consumed: 0).toJson(), {
        'limit': maximum,
        'consumed': 0,
      });
      expect(
        () => AgentSessionSpendControl.fromJson(const {
          'limit': null,
          'consumed': null,
        }),
        throwsFormatException,
      );
      expect(
        () => AgentSessionSpendControl(limit: 1, consumed: -1),
        throwsFormatException,
      );
    });
    test('cap omission, top-level null and nullable limit remain distinct', () {
      final omitted = UpdateAgentSessionRequest();
      final clear = UpdateAgentSessionRequest(clearSpendControl: true);
      final unlimited = UpdateAgentSessionRequest(
        spendControl: AgentSessionSpendControlConfig(limit: null),
      );
      expect(omitted.toJson(), <String, dynamic>{});
      expect(clear.toJson(), {'spend_control': null});
      expect(unlimited.toJson(), {
        'spend_control': {'limit': null},
      });
      expect(omitted, isNot(clear));
      expect(clear.copyWith(), clear);
      expect(unlimited.copyWith(spendControl: null), clear);
    });
    test('inline and environment-dependent input are validated', () {
      final none = AgentSessionEnvironment.none();
      expect(
        () => CreateAgentSessionRequest(environment: none),
        throwsFormatException,
      );
      expect(
        () => CreateAgentSessionRequest(
          agent: AgentSessionAgentConfig(model: 'requested'),
          environment: none,
        ),
        throwsFormatException,
      );
      final created = CreateAgentSessionRequest(
        agent: AgentSessionAgentConfig(model: 'requested'),
        environment: none,
        input: AgentSessionInitialInput.text('hello'),
      );
      expect(created.agent!.model, 'requested');
      expect(() => created.copyWith(input: null), throwsFormatException);
      final selfHosted = CreateAgentSessionRequest(
        agentId: 'saved',
        environment: AgentSessionEnvironment.selfHosted(
          workspaceDirectory: '/workspace',
        ),
        stream: true,
      );
      expect(selfHosted.input, isNull);
      final hosted = CreateAgentSessionRequest(
        agentId: 'saved',
        environment: AgentSessionEnvironment.openaiHosted(),
      );
      expect(() => hosted.copyWith(stream: true), throwsFormatException);
    });
    test(
      'hosted ID excludes every present inline/template field including null',
      () {
        final existing = AgentSessionEnvironment.openaiHosted(
          environmentId: 'env_valid',
        );
        expect(existing.toJson(), {
          'type': 'openai_hosted',
          'environment_id': 'env_valid',
        });
        final schema = agentSessionWireFixtures.singleWhere(
          (fixture) => fixture.schema == 'EnvironmentParamOpenaiHosted',
        );
        final full = schema.full! as Map<String, dynamic>;
        for (final key in full.keys.where(
          (key) => key != 'type' && key != 'environment_id',
        )) {
          expect(
            () => AgentSessionEnvironment.fromJson({
              'type': 'openai_hosted',
              'environment_id': 'env_valid',
              key: full[key],
            }),
            throwsFormatException,
            reason: key,
          );
          if (schema.nullableKeys.contains(key)) {
            expect(
              () => AgentSessionEnvironment.fromJson({
                'type': 'openai_hosted',
                'environment_id': 'env_valid',
                key: null,
              }),
              throwsFormatException,
              reason: '$key explicit null',
            );
          }
        }
        expect(
          () => (existing as AgentSessionHostedEnvironment).copyWith(
            clearDesktop: true,
          ),
          throwsFormatException,
        );
      },
    );
    test(
      'user role, image wire and optional message tag are separate from Responses',
      () {
        final message = AgentSessionInputMessage.fromJson(const {
          'role': 'user',
          'content': <Object?>[],
        });
        expect(message.toJson(), {'role': 'user', 'content': <Object?>[]});
        expect(message.copyWith().toJson(), message.toJson());
        expect(
          () => AgentSessionInputMessage.fromJson(const {
            'role': 'assistant',
            'content': <Object?>[],
          }),
          throwsFormatException,
        );
        expect(
          () => AgentSessionInputContent.fromJson(const {
            'type': 'input_image',
            'image_url': 'https://example.invalid/image.png',
            'detail': 'high',
          }),
          throwsFormatException,
        );
      },
    );
  });
}
