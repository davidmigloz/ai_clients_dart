import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _agentJson() => {
  'object': 'agent',
  'id': 'agent_1',
  'created_at': 0,
  'updated_at': 0,
  'instructions': null,
  'metadata': <String, String>{},
  'model': 'open-model',
  'multi_agent': {'enabled': false, 'max_concurrent_subagents': null},
  'name': null,
  'reasoning': {'effort': null, 'summary': null},
  'service_tier': 'ultrafast',
  'text': {
    'format': {'type': 'text'},
    'verbosity': 'low',
  },
  'tools': <Object?>[],
};

void main() {
  group('compaction settings', () {
    test('writable async preserves omitted, null, true and false', () {
      for (final json in <Map<String, dynamic>>[
        {},
        {'async': null},
        {'async': true},
        {'async': false},
      ]) {
        final value = AgentCompactionConfig.fromJson(json);
        expect(value.toJson(), json);
        expect(value.copyWith(), value);
        expect(value.copyWith().hashCode, value.hashCode);
      }
      const omitted = AgentCompactionConfig();
      const backgroundDefault = AgentCompactionConfig(clearAsync: true);
      expect(omitted.toJson(), isEmpty);
      expect(backgroundDefault.toJson(), {'async': null});
      expect(omitted, isNot(backgroundDefault));
      expect(omitted.copyWith(async: null), backgroundDefault);
      expect(backgroundDefault.copyWith(clearAsync: false), omitted);
      expect(backgroundDefault.copyWith(async: false).toJson(), {
        'async': false,
      });
      expect(
        const AgentCompactionConfig(async: false, clearAsync: true),
        backgroundDefault,
      );
    });

    test('writable compaction is closed and rejects coercion', () {
      for (final value in [
        0,
        1,
        '',
        'true',
        <Object?>[],
        <String, Object?>{},
      ]) {
        expect(
          () => AgentCompactionConfig.fromJson({'async': value}),
          throwsFormatException,
        );
        expect(
          () => const AgentCompactionConfig().copyWith(async: value),
          throwsFormatException,
        );
      }
      expect(
        () => AgentCompactionConfig.fromJson(const {'PRIVATE_extra': true}),
        throwsFormatException,
      );
    });

    test(
      'resolved async is required nonnull with immutable future metadata',
      () {
        for (final value in [true, false]) {
          final model = AgentCompaction.fromJson({
            'async': value,
            'future': const {
              'private': <String>['PRIVATE'],
            },
          });
          expect(model.async, value);
          expect(model.copyWith(), model);
          expect(model.copyWith().hashCode, model.hashCode);
          expect(model.copyWith(async: !value), isNot(model));
          expect(model.toString(), isNot(contains('PRIVATE')));
          expect(
            () => (model.rawJson['future'] as Map).clear(),
            throwsUnsupportedError,
          );
        }
        for (final json in <Map<String, dynamic>>[
          {},
          {'async': null},
          {'async': 1},
        ]) {
          expect(() => AgentCompaction.fromJson(json), throwsFormatException);
        }
        expect(
          () => AgentCompaction(async: true, rawJson: const {'async': false}),
          throwsFormatException,
        );
      },
    );
  });

  group('experimental settings', () {
    test(
      'create defaults and merge overrides remain absent until supplied',
      () {
        expect(const AgentExperimentalConfig().toJson(), isEmpty);
        expect(const AgentExperimentalOverridesConfig().toJson(), isEmpty);
        for (final value in [true, false]) {
          final json = {'time_awareness': value};
          final create = AgentExperimentalConfig.fromJson(json);
          final update = AgentExperimentalOverridesConfig.fromJson(json);
          expect(create.toJson(), json);
          expect(update.toJson(), json);
          expect(create.copyWith(), create);
          expect(update.copyWith(), update);
          expect(create.copyWith().hashCode, create.hashCode);
          expect(update.copyWith().hashCode, update.hashCode);
          expect(create.copyWith(timeAwareness: !value), isNot(create));
          expect(update.copyWith(timeAwareness: !value), isNot(update));
          expect(create.copyWith(clearTimeAwareness: true).toJson(), isEmpty);
          expect(update.copyWith(clearTimeAwareness: true).toJson(), isEmpty);
        }
      },
    );

    test(
      'nonnullable time awareness rejects null, coercion and extra keys',
      () {
        for (final value in [
          null,
          0,
          'false',
          <Object?>[],
          <String, Object?>{},
        ]) {
          expect(
            () => AgentExperimentalConfig.fromJson({'time_awareness': value}),
            throwsFormatException,
          );
          expect(
            () => AgentExperimentalOverridesConfig.fromJson({
              'time_awareness': value,
            }),
            throwsFormatException,
          );
          expect(
            () =>
                const AgentExperimentalConfig().copyWith(timeAwareness: value),
            throwsFormatException,
          );
          expect(
            () => const AgentExperimentalOverridesConfig().copyWith(
              timeAwareness: value,
            ),
            throwsFormatException,
          );
        }
        expect(
          () => AgentExperimentalConfig.fromJson(const {'PRIVATE_extra': true}),
          throwsFormatException,
        );
        expect(
          () => AgentExperimentalOverridesConfig.fromJson(const {
            'PRIVATE_extra': true,
          }),
          throwsFormatException,
        );
      },
    );

    test(
      'resolved time awareness is required nonnull and preserves extras',
      () {
        final raw = <String, dynamic>{
          'future': {
            'items': <String>['PRIVATE'],
          },
        };
        final model = AgentExperimental(timeAwareness: true, rawJson: raw);
        (raw['future'] as Map)['items'] = <String>[];
        expect(model.rawJson['future'], {
          'items': ['PRIVATE'],
        });
        expect(AgentExperimental.fromJson(model.toJson()), model);
        expect(model.copyWith(), model);
        expect(model.copyWith().hashCode, model.hashCode);
        expect(model.copyWith(timeAwareness: false), isNot(model));
        expect(model.toString(), isNot(contains('PRIVATE')));
        for (final json in <Map<String, dynamic>>[
          {},
          {'time_awareness': null},
          {'time_awareness': 'true'},
        ]) {
          expect(() => AgentExperimental.fromJson(json), throwsFormatException);
        }
        expect(
          () => AgentExperimental(
            timeAwareness: false,
            rawJson: const {'time_awareness': true},
          ),
          throwsFormatException,
        );
      },
    );

    test('received settings reject nonfinite and cyclic extras safely', () {
      final cycle = <String, dynamic>{};
      cycle['PRIVATE'] = cycle;
      for (final bad in <Map<String, dynamic>>[
        cycle,
        {'PRIVATE': double.nan},
        {'PRIVATE': Object()},
      ]) {
        expect(
          () => AgentCompaction(async: true, rawJson: bad),
          throwsFormatException,
        );
        expect(
          () => AgentExperimental(timeAwareness: true, rawJson: bad),
          throwsFormatException,
        );
      }
    });
  });

  group('saved Agent paths', () {
    test(
      'create and update encode full settings without inserting defaults',
      () {
        final createJson = {
          'model': 'm',
          'compaction': {'async': false},
          'experimental': {'time_awareness': true},
          'service_tier': 'ultrafast',
        };
        final create = CreateAgentRequest.fromJson(createJson);
        expect(create.toJson(), createJson);
        expect(create.copyWith(), create);
        expect(create.copyWith().hashCode, create.hashCode);
        final updateJson = {
          'compaction': {'async': null},
          'experimental': {'time_awareness': false},
          'service_tier': 'ultrafast',
        };
        final update = UpdateAgentRequest.fromJson(updateJson);
        expect(update.toJson(), updateJson);
        expect(update.copyWith(), update);
        expect(update.copyWith().hashCode, update.hashCode);
        expect(CreateAgentRequest(model: 'm').toJson(), {'model': 'm'});
        expect(UpdateAgentRequest().toJson(), isEmpty);
      },
    );

    test(
      'compaction update preserves omit/null/empty replacement distinctions',
      () {
        final omitted = UpdateAgentRequest();
        final nulled = UpdateAgentRequest(clearCompaction: true);
        final empty = UpdateAgentRequest(
          compaction: const AgentCompactionConfig(),
        );
        final blocking = UpdateAgentRequest(
          compaction: const AgentCompactionConfig(async: false),
        );
        expect(omitted.toJson(), isEmpty);
        expect(nulled.toJson(), {'compaction': null});
        expect(empty.toJson(), {'compaction': <String, Object?>{}});
        expect(blocking.toJson(), {
          'compaction': {'async': false},
        });
        expect(blocking.copyWith(compaction: null), nulled);
        expect(nulled.copyWith(clearCompaction: false), omitted);
        expect(
          nulled.copyWith(
            compaction: const AgentCompactionConfig(async: false),
          ),
          blocking,
        );
        expect(omitted, isNot(nulled));
        expect(nulled, isNot(empty));
        expect(empty, isNot(blocking));
        final create = CreateAgentRequest(
          model: 'm',
          compaction: const AgentCompactionConfig(async: false),
        );
        expect(create.copyWith(compaction: null).toJson(), {
          'model': 'm',
          'compaction': null,
        });
        expect(
          create.copyWith(compaction: null, clearCompaction: false).toJson(),
          {'model': 'm'},
        );
      },
    );

    test('experimental updates keep empty object distinct from omission', () {
      final omitted = UpdateAgentRequest();
      final empty = UpdateAgentRequest(
        experimental: const AgentExperimentalOverridesConfig(),
      );
      expect(empty.toJson(), {'experimental': <String, Object?>{}});
      expect(empty, isNot(omitted));
      expect(empty.copyWith(experimental: null), omitted);
      for (final json in <Map<String, dynamic>>[
        {'experimental': null},
        {
          'experimental': {'time_awareness': null},
        },
        {'compaction': true},
        {
          'compaction': {'async': 0},
        },
      ]) {
        expect(() => UpdateAgentRequest.fromJson(json), throwsFormatException);
        expect(
          () => CreateAgentRequest.fromJson({'model': 'm', ...json}),
          throwsFormatException,
        );
      }
      expect(() => omitted.copyWith(experimental: true), throwsFormatException);
      expect(
        () => CreateAgentRequest(model: 'm').copyWith(compaction: true),
        throwsFormatException,
      );
    });

    test('resources accept old omission and exact new resolved settings', () {
      final old = Agent.fromJson(_agentJson());
      expect(old.compaction, isNull);
      expect(old.experimental, isNull);
      expect(old.toJson(), _agentJson());
      final json = {
        ..._agentJson(),
        'compaction': {
          'async': false,
          'future': {'value': 'PRIVATE'},
        },
        'experimental': {
          'time_awareness': true,
          'future': <String>['PRIVATE'],
        },
      };
      final current = Agent.fromJson(json);
      expect(current.toJson(), json);
      expect(current.compaction!.async, false);
      expect(current.experimental!.timeAwareness, true);
      expect(current.copyWith(), current);
      expect(current.copyWith().hashCode, current.hashCode);
      expect(current.copyWith(compaction: null, experimental: null), old);
      expect(
        current.copyWith(compaction: current.compaction!.copyWith(async: true)),
        isNot(current),
      );
      expect(
        current.copyWith(
          experimental: current.experimental!.copyWith(timeAwareness: false),
        ),
        isNot(current),
      );
      expect(current.toString(), isNot(contains('PRIVATE')));
      for (final key in ['compaction', 'experimental']) {
        expect(
          () => Agent.fromJson({..._agentJson(), key: null}),
          throwsFormatException,
        );
        expect(
          () =>
              Agent.fromJson({..._agentJson(), key: const <String, Object?>{}}),
          throwsFormatException,
        );
      }
      expect(
        () => current.copyWith(
          rawJson: {
            'compaction': {'async': true},
          },
        ),
        throwsFormatException,
      );
      expect(() => current.copyWith(experimental: true), throwsFormatException);
    });

    test('ultrafast is a supported request value in both saved validators', () {
      expect(AgentServiceTierParam.ultrafast.isKnown, isTrue);
      expect(
        AgentServiceTierParam.fromJson('ultrafast'),
        AgentServiceTierParam.ultrafast,
      );
      expect(
        AgentServiceTierParam.ultrafast.copyWith(),
        AgentServiceTierParam.ultrafast,
      );
      expect(
        CreateAgentRequest(
          model: 'm',
          serviceTier: AgentServiceTierParam.ultrafast,
        ).toJson()['service_tier'],
        'ultrafast',
      );
      expect(
        UpdateAgentRequest(
          serviceTier: AgentServiceTierParam.ultrafast,
        ).toJson()['service_tier'],
        'ultrafast',
      );
      final future = AgentServiceTierParam.fromJson('PRIVATE-future');
      expect(future.isKnown, isFalse);
      expect(
        () => CreateAgentRequest(model: 'm', serviceTier: future),
        throwsFormatException,
      );
      expect(
        () => UpdateAgentRequest(serviceTier: future),
        throwsFormatException,
      );
    });
  });

  group('saved automations tool union', () {
    test('type-only request is writable and resource extras are immutable', () {
      const json = {'type': 'automations'};
      final request = AgentTool.fromJson(json);
      expect(request, const AgentTool.automations());
      expect(request, isA<AgentAutomationsTool>());
      expect((request as AgentAutomationsTool).copyWith(), request);
      expect(
        CreateAgentRequest(model: 'm', tools: [request]).toJson()['tools'],
        [json],
      );
      final resource = AgentToolResource.fromJson(const {
        'type': 'automations',
        'future': {
          'PRIVATE': <String>['PRIVATE'],
        },
      });
      expect(resource, isA<AgentAutomationsToolResource>());
      expect((resource as AgentAutomationsToolResource).copyWith(), resource);
      expect(resource.copyWith().hashCode, resource.hashCode);
      expect(
        () => (resource.rawJson['future'] as Map).clear(),
        throwsUnsupportedError,
      );
      expect(resource.toString(), isNot(contains('PRIVATE')));
      final saved = Agent.fromJson({
        ..._agentJson(),
        'tools': const [json],
      });
      expect(saved.tools.single, AgentToolResource.automations());
    });

    test(
      'known automations cannot fall through unknown or absorb request fields',
      () {
        expect(
          () => AgentTool.fromJson(const {
            'type': 'automations',
            'id': 'PRIVATE',
          }),
          throwsFormatException,
        );
        expect(
          () => UnknownAgentTool.fromJson(const {'type': 'automations'}),
          throwsFormatException,
        );
        expect(
          () =>
              UnknownAgentToolResource.fromJson(const {'type': 'automations'}),
          throwsFormatException,
        );
        expect(
          () => AgentAutomationsTool.fromJson(const {'type': 'function'}),
          throwsFormatException,
        );
        expect(
          () => AgentAutomationsToolResource.fromJson(const {'type': null}),
          throwsFormatException,
        );
        expect(
          () =>
              AgentAutomationsToolResource(rawJson: const {'type': 'PRIVATE'}),
          throwsFormatException,
        );
        final future = AgentTool.fromJson(const {
          'type': 'PRIVATE-future',
          'extra': true,
        });
        expect(future, isA<UnknownAgentTool>());
        expect(
          () => CreateAgentRequest(model: 'm', tools: [future]),
          throwsFormatException,
        );
      },
    );
  });
}
