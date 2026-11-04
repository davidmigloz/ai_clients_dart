import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/agent_automation_receive_fixtures.dart';

void main() {
  group('Frozen automation receive schemas', () {
    for (final fixture in automationReceiveFixtures) {
      for (final variant in {
        'minimal': fixture.minimal,
        'full': fixture.full,
      }.entries) {
        test(
          '${fixture.schema} ${variant.key}: exact owned copy/value contract',
          () {
            final source = _clone(variant.value);
            final expected = _clone(source);
            final model = fixture.parse(source);
            _damage(source);
            expect(model.toJson(), expected);
            expect(fixture.copy(model), model);
            expect(fixture.copy(model).hashCode, model.hashCode);
            expect(model.toString(), contains('[REDACTED]'));
            expect(model.toString(), isNot(contains('PRIVATE')));
          },
        );
      }
      test(
        '${fixture.schema}: required keys and nullability are independent',
        () {
          for (final key in fixture.requiredKeys) {
            expect(
              () => fixture.parse(_clone(fixture.full)..remove(key)),
              throwsFormatException,
              reason: key,
            );
            if (!fixture.nullableKeys.contains(key)) {
              expect(
                () => fixture.parse(_clone(fixture.full)..[key] = null),
                throwsFormatException,
                reason: key,
              );
            }
          }
          for (final key in fixture.nullableKeys) {
            final model = fixture.parse(_clone(fixture.full)..[key] = null);
            final json = model.toJson() as Map<String, dynamic>;
            expect(json.containsKey(key), isTrue, reason: key);
            expect(json[key], isNull, reason: key);
          }
        },
      );
      test('${fixture.schema}: malformed known fields fail privately', () {
        for (final entry in fixture.full.entries) {
          final wrong = entry.value is Map
              ? 'PRIVATE-malformed'
              : <String, Object?>{'PRIVATE': true};
          expect(
            () => fixture.parse(_clone(fixture.full)..[entry.key] = wrong),
            throwsA(
              isA<FormatException>().having(
                (error) => error.toString(),
                'private diagnostics',
                isNot(contains('PRIVATE')),
              ),
            ),
            reason: entry.key,
          );
        }
      });
      test(
        '${fixture.schema}: future extras are immutable and authoritative',
        () {
          final future = <String, dynamic>{
            'nested': <String>['PRIVATE'],
          };
          final model = fixture.parse({
            ..._clone(fixture.full),
            'future': future,
          });
          (future['nested'] as List<String>).add('changed');
          final json = model.toJson() as Map<String, dynamic>;
          expect(json['future'], {
            'nested': ['PRIVATE'],
          });
          expect(
            () => ((json['future'] as Map)['nested'] as List).clear(),
            throwsUnsupportedError,
          );
          expect(fixture.copy(model), model);
        },
      );
    }
  });

  group('Every automation receive field copies', () {
    for (final fixture in automationReceiveCopies) {
      test(fixture.name, () {
        final original = fixture.parse(_clone(fixture.original));
        final replacement = fixture.parse(_clone(fixture.replacement));
        final copied = fixture.copy(original, replacement);
        expect(copied.toJson(), fixture.replacement);
        expect(copied, replacement);
        expect(copied.hashCode, replacement.hashCode);
        expect(copied, isNot(original));
      });
    }
  });

  group('Future automation receive values', () {
    final unions = <String, AgentJsonModel Function(Map<String, dynamic>)>{
      'schedule': AgentAutomation.fromJson,
      'target': AgentAutomationTargetResource.fromJson,
      'environment': AgentAutomationEnvironmentResource.fromJson,
      'creator': AgentAutomationCreator.fromJson,
      'source': AgentAutomationInvocationSource.fromJson,
    };
    for (final entry in unions.entries) {
      test(
        '${entry.key}: future variant roundtrips without invented fields',
        () {
          final source = <String, dynamic>{
            'type': 'PRIVATE-future',
            'nested': <String, dynamic>{
              'items': <Object?>[1, true, null],
            },
          };
          final expected = _clone(source);
          final model = entry.value(source);
          _damage(source);
          expect(model.toJson(), expected);
          expect(model.toString(), isNot(contains('PRIVATE')));
          expect(
            () => ((model.toJson() as Map)['nested'] as Map).clear(),
            throwsUnsupportedError,
          );
        },
      );
      test('${entry.key}: cyclic and nonfinite future data fail privately', () {
        final cycle = <String, dynamic>{'type': 'PRIVATE-future'};
        cycle['future'] = cycle;
        for (final value in [
          cycle,
          {'type': 'future', 'private': double.nan},
        ]) {
          expect(() => entry.value(value), throwsFormatException);
        }
      });
    }
    test('unknown factories reject every reserved known tag', () {
      for (final tag in ['once', 'periodic']) {
        expect(
          () => UnknownAgentAutomation.fromJson({'type': tag}),
          throwsFormatException,
        );
      }
      for (final tag in ['existing_session', 'new_session']) {
        expect(
          () => UnknownAgentAutomationTargetResource.fromJson({'type': tag}),
          throwsFormatException,
        );
      }
      for (final tag in ['none', 'openai_hosted', 'self_hosted']) {
        expect(
          () =>
              UnknownAgentAutomationEnvironmentResource.fromJson({'type': tag}),
          throwsFormatException,
        );
      }
      for (final tag in ['agent', 'developer']) {
        expect(
          () => UnknownAgentAutomationCreator.fromJson({'type': tag}),
          throwsFormatException,
        );
      }
      for (final tag in ['manual', 'automation']) {
        expect(
          () => UnknownAgentAutomationInvocationSource.fromJson({'type': tag}),
          throwsFormatException,
        );
      }
    });
    test(
      'future schedule common fields are parsed without guessed semantics',
      () {
        final future = AgentAutomation.fromJson({
          ..._wire('AutomationResourceOnce'),
          'type': 'future_schedule',
          'status': 'active',
        });
        expect(future.status.value, 'active');
        expect(future.status.isKnown, isFalse);
        expect(future.id, _wire('AutomationResourceOnce')['id']);
        final incomplete = AgentAutomation.fromJson(const {'type': 'future'});
        expect(incomplete.toJson(), {'type': 'future'});
        expect(() => incomplete.status, throwsFormatException);
        expect(() => incomplete.id, throwsFormatException);
      },
    );
    test('known and future scalar statuses keep their exact context', () {
      for (final value in ['active', 'paused', 'completed']) {
        final status = AgentAutomationOnceStatus.fromJson(value);
        expect(status.isKnown, isTrue);
        expect(status.copyWith(), status);
      }
      for (final value in ['active', 'paused']) {
        expect(AgentAutomationPeriodicStatus.fromJson(value).isKnown, isTrue);
      }
      for (final value in [
        'queued',
        'completed',
        'failed',
        'skipped',
        'PRIVATE-future',
      ]) {
        final status = AgentAutomationInvocationStatus.fromJson(value);
        expect(status.value, value);
        expect(status.isKnown, value != 'PRIVATE-future');
        expect(status.copyWith().hashCode, status.hashCode);
        final invocation = AgentAutomationInvocation.fromJson({
          ..._wire('AutomationInvocationResource'),
          'status': value,
        });
        expect(invocation.status, status);
      }
      expect(AgentAutomationOnceStatus.fromJson('PRIVATE').isKnown, isFalse);
      expect(
        AgentAutomationPeriodicStatus.fromJson('completed').isKnown,
        isFalse,
      );
      expect(AgentAutomationFutureStatus.fromJson('active').isKnown, isFalse);
    });
  });

  group('Distinct stored configuration contexts', () {
    test(
      'hosted saved selection keeps all required nullable override keys',
      () {
        final minimal = _wire('AutomationEnvironmentResourceOpenaiHosted');
        expect(minimal.values.where((value) => value == null), hasLength(10));
        final environment =
            AgentAutomationEnvironmentResource.fromJson(minimal)
                as AgentAutomationHostedEnvironmentResource;
        expect(environment.toJson(), minimal);
        final full = AgentAutomationHostedEnvironmentResource.fromJson(
          _wire('AutomationEnvironmentResourceOpenaiHosted', full: true),
        );
        for (final copy in [
          full.copyWith(skills: []),
          full.copyWith(skills: const []),
          full.copyWith(files: []),
          full.copyWith(files: const []),
          full.copyWith(plugins: []),
          full.copyWith(capabilityDirectories: []),
        ]) {
          expect(copy.toJson(), isA<Map<String, dynamic>>());
        }
        expect(full.copyWith(skills: []).skills, isEmpty);
        expect(full.copyWith(files: []).files, isEmpty);
        expect(full.copyWith(skills: null).toJson()['skills'], isNull);
        expect(() => full.copyWith(skills: ['PRIVATE']), throwsFormatException);
        expect(
          () => full.copyWith(rawJson: const {'type': 'spoof'}),
          throwsFormatException,
        );
      },
    );
    test(
      'stored target requires both nullable agent references without identities',
      () {
        final target = AgentAutomationNewSessionTargetResource.fromJson(
          _wire('AutomationTargetResourceNewSession'),
        );
        expect(target.agent, isNull);
        expect(target.agentId, isNull);
        expect(target.input, isEmpty);
        final agent = AgentAutomationAgentConfig.fromJson(
          _wire('AutomationAgentConfigResource'),
        );
        expect(agent.toJson().containsKey('id'), isFalse);
        expect(agent.toJson().containsKey('name'), isFalse);
        final parsed = AgentAutomationNewSessionTargetResource.fromJson({
          ...target.toJson(),
          'agent': agent.toJson(),
        });
        expect(parsed.agent, agent);
        expect(parsed.agentId, isNull);
        expect(parsed.copyWith(agent: null).toJson()['agent'], isNull);
      },
    );
    test('stored message requires type and never fabricates a message ID', () {
      final message = AgentAutomationInputMessage.fromJson(
        _wire('InputMessageResource-2'),
      );
      expect(message.toJson(), {
        'type': 'message',
        'role': 'user',
        'content': <Object?>[],
      });
      expect(message.toJson().containsKey('id'), isFalse);
      expect(
        () => AgentAutomationInputMessage.fromJson(const {
          'role': 'user',
          'content': <Object?>[],
        }),
        throwsFormatException,
      );
    });
    test(
      'received strings/maps retain broader limits than writable requests',
      () {
        final automation = AgentAutomationOnce.fromJson({
          ..._wire('AutomationResourceOnce'),
          'name': 'x' * 257,
          'metadata': {for (var i = 0; i < 17; i++) '${'k' * 65}$i': 'v' * 513},
        });
        expect(automation.name, hasLength(257));
        expect(automation.metadata, hasLength(17));
        expect(
          AgentAutomationExistingSessionTargetResource.fromJson(const {
            'type': 'existing_session',
            'session_id': '',
            'instructions': '',
          }).instructions,
          isEmpty,
        );
      },
    );
    test('read collection limits are 2000, not request 16384', () {
      final message = AgentAutomationInputMessage.fromJson(
        _wire('InputMessageResource-2'),
      );
      final target = AgentAutomationNewSessionTargetResource.fromJson(
        _wire('AutomationTargetResourceNewSession'),
      );
      expect(
        target.copyWith(input: List.filled(2000, message)).input,
        hasLength(2000),
      );
      expect(
        () => target.copyWith(input: List.filled(2001, message)),
        throwsFormatException,
      );
      expect(
        () => target.copyWith(vaultIds: List.filled(2001, '')),
        throwsFormatException,
      );
      final environment = AgentAutomationHostedEnvironmentResource.fromJson(
        _wire('AutomationEnvironmentResourceOpenaiHosted'),
      );
      expect(
        environment
            .copyWith(capabilityDirectories: List.filled(2000, ''))
            .capabilityDirectories,
        hasLength(2000),
      );
      expect(
        () =>
            environment.copyWith(capabilityDirectories: List.filled(2001, '')),
        throwsFormatException,
      );
    });
    test('required nullable invocation facts and errors are not invented', () {
      final minimal = AgentAutomationInvocation.fromJson(
        _wire('AutomationInvocationResource'),
      );
      expect(minimal.scheduledAt, isNull);
      expect(minimal.sessionId, isNull);
      expect(minimal.error, isNull);
      expect(minimal.skipReason, isNull);
      final full = AgentAutomationInvocation.fromJson(
        _wire('AutomationInvocationResource', full: true),
      );
      expect(full.skipReason, 'pending_delivery');
      expect(full.error!.code, isNotEmpty);
      expect(
        full.copyWith(skipReason: 'PRIVATE-future').skipReason,
        'PRIVATE-future',
      );
      expect(
        full.copyWith(
          scheduledAt: null,
          sessionId: null,
          error: null,
          skipReason: null,
        ),
        minimal.copyWith(status: full.status, source: full.source),
      );
    });
    test('deleted false and page cursor facts remain actual server values', () {
      expect(
        DeletedAgentAutomation.fromJson(const {
          'object': 'agent.automation.deleted',
          'id': '',
          'deleted': false,
        }).deleted,
        isFalse,
      );
      final page = AgentAutomationList.fromJson(const {
        'object': 'list',
        'data': <Object?>[],
        'first_id': null,
        'last_id': null,
        'has_more': true,
      });
      expect(page.hasMore, isTrue);
      expect(page.lastId, isNull);
      expect(page.data, isEmpty);
    });
  });
}

Map<String, dynamic> _clone(Map<String, dynamic> value) =>
    jsonDecode(jsonEncode(value)) as Map<String, dynamic>;

Map<String, dynamic> _wire(String schema, {bool full = false}) {
  final fixture = automationReceiveFixtures.singleWhere(
    (value) => value.schema == schema,
  );
  return _clone(full ? fixture.full : fixture.minimal);
}

void _damage(Object? value) {
  if (value is Map<String, dynamic>) {
    value.values.toList().forEach(_damage);
    value.clear();
  } else if (value is List<dynamic>) {
    value.toList().forEach(_damage);
    value.clear();
  }
}
