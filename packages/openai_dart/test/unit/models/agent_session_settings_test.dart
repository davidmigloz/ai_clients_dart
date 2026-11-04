import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/agent_session_wire_fixtures.dart';

void main() {
  group('Session action review', () {
    for (final mode in [
      SessionReviewParam.none,
      SessionReviewParam.autoReview,
    ]) {
      test('${mode.value} is independent on create, update and receive', () {
        final create = CreateAgentSessionRequest.fromJson(
          _wire('CreateAgentSessionParams'),
        ).copyWith(review: mode);
        final update = UpdateAgentSessionRequest(review: mode);
        final received = AgentSession.fromJson({
          ..._wire('SessionResource'),
          'review': mode.value,
        });
        expect(create.toJson()['review'], mode.value);
        expect(update.toJson(), {'review': mode.value});
        expect(received.review!.value, mode.value);
        expect(received.toJson()['review'], mode.value);
        expect(create.copyWith(), create);
        expect(create.copyWith().hashCode, create.hashCode);
        expect(update.copyWith(), update);
        expect(update.copyWith().hashCode, update.hashCode);
        expect(received.copyWith(), received);
        expect(received.copyWith().hashCode, received.hashCode);
        expect(SessionReviewParam.fromJson(mode.value), mode);
        expect(SessionReviewParam.fromJson(mode.value).copyWith(), mode);
        expect(
          SessionReviewResource.fromJson(mode.value).copyWith().value,
          mode.value,
        );
      });
    }

    test('omission stays absent rather than inventing none or a null', () {
      final create = CreateAgentSessionRequest.fromJson(
        _wire('CreateAgentSessionParams'),
      );
      final received = AgentSession.fromJson(_wire('SessionResource'));
      expect(create.review, isNull);
      expect(create.toJson().containsKey('review'), isFalse);
      expect(UpdateAgentSessionRequest().toJson(), isEmpty);
      expect(received.review, isNull);
      expect(received.toJson().containsKey('review'), isFalse);
      expect(
        create
            .copyWith(review: SessionReviewParam.autoReview)
            .copyWith(review: null),
        create,
      );
      expect(
        UpdateAgentSessionRequest(
          review: SessionReviewParam.autoReview,
        ).copyWith(review: null).toJson(),
        isEmpty,
      );
      expect(
        received
            .copyWith(review: SessionReviewResource.autoReview)
            .copyWith(review: null),
        received,
      );
    });

    for (final value in [null, true, 1, <Object?>[], <String, Object?>{}]) {
      test('rejects malformed/nonnullable review ${value.runtimeType}', () {
        expect(
          () => CreateAgentSessionRequest.fromJson({
            ..._wire('CreateAgentSessionParams'),
            'review': value,
          }),
          throwsFormatException,
        );
        expect(
          () => UpdateAgentSessionRequest.fromJson({'review': value}),
          throwsFormatException,
        );
        expect(
          () => AgentSession.fromJson({
            ..._wire('SessionResource'),
            'review': value,
          }),
          throwsFormatException,
        );
      });
    }

    test('received future review is retained but cannot be written', () {
      const future = 'PRIVATE-future-review';
      final received = AgentSession.fromJson({
        ..._wire('SessionResource'),
        'review': future,
      });
      expect(received.review!.isKnown, isFalse);
      expect(received.toJson()['review'], future);
      expect(received.toString(), isNot(contains(future)));
      final requestMode = SessionReviewParam.fromJson(future);
      expect(requestMode.isKnown, isFalse);
      expect(
        () => UpdateAgentSessionRequest(review: requestMode),
        throwsFormatException,
      );
      expect(
        () => CreateAgentSessionRequest.fromJson({
          ..._wire('CreateAgentSessionParams'),
          'review': future,
        }),
        throwsFormatException,
      );
    });

    test(
      'removed spend fields are rejected instead of translated to review',
      () {
        for (final spend in [
          null,
          <String, Object?>{},
          {'limit': 100},
        ]) {
          expect(
            () => CreateAgentSessionRequest.fromJson({
              ..._wire('CreateAgentSessionParams'),
              'spend_control': spend,
            }),
            throwsFormatException,
          );
          expect(
            () => UpdateAgentSessionRequest.fromJson({'spend_control': spend}),
            throwsFormatException,
          );
        }
        expect(
          CreateAgentSessionRequest.fromJson(
            _wire('CreateAgentSessionParams'),
          ).toJson().containsKey('spend_control'),
          isFalse,
        );
        expect(
          UpdateAgentSessionRequest(
            review: SessionReviewParam.autoReview,
          ).toJson().containsKey('spend_control'),
          isFalse,
        );
      },
    );

    test('historical received spend remains detached opaque metadata', () {
      final legacy = <String, dynamic>{
        'limit': 100,
        'consumed': 5,
        'future': <String>['PRIVATE'],
      };
      final received = AgentSession.fromJson({
        ..._wire('SessionResource'),
        'spend_control': legacy,
      });
      (legacy['future'] as List<String>).add('changed');
      expect(received.rawJson['spend_control'], {
        'limit': 100,
        'consumed': 5,
        'future': ['PRIVATE'],
      });
      expect(
        received.toJson()['spend_control'],
        received.rawJson['spend_control'],
      );
      expect(received.review, isNull);
      expect(
        () => (received.rawJson['spend_control'] as Map)['limit'] = 7,
        throwsUnsupportedError,
      );
      expect(received.copyWith(), received);
    });
  });

  group('Session context settings', () {
    for (final value in [
      null,
      <String, Object?>{},
      {'async': null},
      {'async': false},
      {'async': true},
    ]) {
      test('inline compaction preserves replacement state $value', () {
        final wire = {'compaction': value};
        final config = AgentSessionAgentConfig.fromJson(wire);
        expect(config.toJson(), wire);
        expect(config.copyWith(), config);
        expect(config.copyWith().hashCode, config.hashCode);
        final create = CreateAgentSessionRequest.fromJson(
          _wire('CreateAgentSessionParams'),
        ).copyWith(agent: config.copyWith(model: 'future-model'));
        expect((create.toJson()['agent'] as Map)['compaction'], value);
      });
    }

    test(
      'compaction omission, explicit null and empty settings stay distinct',
      () {
        final omitted = AgentSessionAgentConfig();
        final disabledOverride = AgentSessionAgentConfig(clearCompaction: true);
        final defaultOverride = AgentSessionAgentConfig(
          compaction: const AgentCompactionConfig(),
        );
        expect(omitted.toJson(), isEmpty);
        expect(disabledOverride.toJson(), {'compaction': null});
        expect(defaultOverride.toJson(), {'compaction': <String, dynamic>{}});
        expect(omitted, isNot(disabledOverride));
        expect(defaultOverride, isNot(disabledOverride));
        expect(defaultOverride.copyWith(compaction: null), disabledOverride);
        expect(disabledOverride.copyWith(clearCompaction: false), omitted);
      },
    );

    for (final value in [
      <String, Object?>{},
      {'time_awareness': false},
      {'time_awareness': true},
    ]) {
      test('experimental merge overrides preserve original state $value', () {
        final wire = {'experimental': value};
        final config = AgentSessionAgentConfig.fromJson(wire);
        expect(config.toJson(), wire);
        expect(config.copyWith(), config);
        expect(config.copyWith().hashCode, config.hashCode);
        expect(config.copyWith(experimental: null).toJson(), isEmpty);
      });
    }

    test(
      'resolved optional settings require their nonnull effective fields',
      () {
        final raw = <String, dynamic>{
          'future': <String>['PRIVATE'],
        };
        final wire = {
          ..._wire('SessionAgentResource'),
          'compaction': {'async': false, ...raw},
          'experimental': {'time_awareness': true, ...raw},
        };
        final agent = AgentSessionAgent.fromJson(wire);
        (raw['future'] as List<String>).add('changed');
        expect(agent.compaction!.async, isFalse);
        expect(agent.experimental!.timeAwareness, isTrue);
        expect(agent.compaction!.rawJson['future'], ['PRIVATE']);
        expect(agent.experimental!.rawJson['future'], ['PRIVATE']);
        expect(agent.copyWith(), agent);
        expect(agent.copyWith().hashCode, agent.hashCode);
        final omitted = agent.copyWith(compaction: null, experimental: null);
        expect(omitted.toJson().containsKey('compaction'), isFalse);
        expect(omitted.toJson().containsKey('experimental'), isFalse);
        for (final name in ['compaction', 'experimental']) {
          for (final malformed in [
            null,
            <String, Object?>{},
            {name == 'compaction' ? 'async' : 'time_awareness': null},
          ]) {
            expect(
              () => AgentSessionAgent.fromJson({
                ..._wire('SessionAgentResource'),
                name: malformed,
              }),
              throwsFormatException,
            );
          }
        }
      },
    );

    test(
      'nonnullable experimental parent rejects null and unknown request keys',
      () {
        for (final value in [
          null,
          {'time_awareness': null},
          {'time_awareness': 'true'},
          {'PRIVATE': true},
        ]) {
          expect(
            () => AgentSessionAgentConfig.fromJson({'experimental': value}),
            throwsFormatException,
          );
        }
        for (final key in ['compaction', 'experimental']) {
          expect(
            () => AgentSessionAgentUpdate.fromJson({
              key: const <String, dynamic>{},
            }),
            throwsFormatException,
          );
        }
      },
    );

    test('ultrafast passes both duplicated session request validators', () {
      final config = AgentSessionAgentConfig(
        model: 'future-model',
        serviceTier: AgentServiceTierParam.ultrafast,
      );
      final update = AgentSessionAgentUpdate(
        serviceTier: AgentServiceTierParam.ultrafast,
      );
      expect(AgentSessionAgentConfig.fromJson(config.toJson()), config);
      expect(AgentSessionAgentUpdate.fromJson(update.toJson()), update);
      expect(update.toJson(), {'service_tier': 'ultrafast'});
      expect(UpdateAgentSessionRequest(agent: update).toJson(), {
        'agent': {'service_tier': 'ultrafast'},
      });
      final future = AgentServiceTierParam.fromJson('PRIVATE-future-tier');
      expect(
        () => AgentSessionAgentConfig(serviceTier: future),
        throwsFormatException,
      );
      expect(
        () => AgentSessionAgentUpdate(serviceTier: future),
        throwsFormatException,
      );
    });
  });

  group('Session agent tool updates', () {
    test(
      'omission, null, empty and replacement stay separate and immutable',
      () {
        final source = <AgentSessionTool>[const AgentSessionAutomationsTool()];
        final replacement = AgentSessionAgentUpdate(tools: source);
        source.clear();
        expect(replacement.toJson(), {
          'tools': [
            {'type': 'automations'},
          ],
        });
        expect(replacement.tools, hasLength(1));
        expect(() => replacement.tools!.clear(), throwsUnsupportedError);
        final omitted = AgentSessionAgentUpdate();
        final cleared = AgentSessionAgentUpdate(clearTools: true);
        final empty = AgentSessionAgentUpdate(tools: const []);
        expect(omitted.toJson(), isEmpty);
        expect(cleared.toJson(), {'tools': null});
        expect(empty.toJson(), {'tools': <Object?>[]});
        expect(cleared, isNot(empty));
        expect(replacement.copyWith(tools: null), cleared);
        expect(replacement.copyWith(tools: []), empty);
        expect(replacement.copyWith(tools: const []), empty);
        expect(replacement.copyWith(tools: null, clearTools: false), omitted);
        expect(cleared.copyWith(clearTools: false), omitted);
        for (final update in [omitted, cleared, empty, replacement]) {
          expect(AgentSessionAgentUpdate.fromJson(update.toJson()), update);
          expect(update.copyWith(), update);
          expect(update.copyWith().hashCode, update.hashCode);
        }
      },
    );

    test('enforces exact array bound and known writable variants', () {
      expect(
        AgentSessionAgentUpdate(
          tools: List.filled(16384, const AgentSessionAutomationsTool()),
        ).tools,
        hasLength(16384),
      );
      expect(
        () => AgentSessionAgentUpdate(
          tools: List.filled(16385, const AgentSessionAutomationsTool()),
        ),
        throwsFormatException,
      );
      expect(
        () => AgentSessionAgentUpdate(
          tools: [
            AgentSessionTool.fromJson(const {'type': 'PRIVATE-future-tool'}),
          ],
        ),
        throwsFormatException,
      );
      for (final value in [
        true,
        3,
        <String, Object?>{},
        [null],
        [true],
      ]) {
        expect(
          () => AgentSessionAgentUpdate.fromJson({'tools': value}),
          throwsFormatException,
        );
      }
      for (final invalid in [
        'PRIVATE',
        ['PRIVATE'],
        [<String, Object?>{}],
      ]) {
        expect(
          () => AgentSessionAgentUpdate().copyWith(tools: invalid),
          throwsA(
            isA<FormatException>().having(
              (error) => error.toString(),
              'private payload',
              isNot(contains('PRIVATE')),
            ),
          ),
        );
      }
    });
  });

  group('Session automations tool prerequisite', () {
    test('fixed writable union branch and copy are exact', () {
      const tool = AgentSessionTool.automations();
      expect(tool, isA<AgentSessionAutomationsTool>());
      expect(tool.toJson(), {'type': 'automations'});
      expect(AgentSessionTool.fromJson(tool.toJson()), tool);
      expect((tool as AgentSessionAutomationsTool).copyWith(), tool);
      expect(tool.copyWith().hashCode, tool.hashCode);
      expect(
        () => AgentSessionTool.fromJson(const {
          'type': 'automations',
          'extra': true,
        }),
        throwsFormatException,
      );
      expect(
        () => UnknownAgentSessionTool.fromJson(const {'type': 'automations'}),
        throwsFormatException,
      );
      expect(
        () => AgentSessionAutomationsTool.fromJson(const {'type': 'wrong'}),
        throwsFormatException,
      );
    });

    test(
      'received branch preserves future extras without discriminator spoofing',
      () {
        final original = <String, dynamic>{
          'type': 'automations',
          'future': <String>['PRIVATE'],
        };
        final tool =
            AgentSessionToolResource.fromJson(original)
                as AgentSessionAutomationsToolResource;
        (original['future'] as List<String>).add('changed');
        expect(tool.toJson(), {
          'type': 'automations',
          'future': ['PRIVATE'],
        });
        expect(tool.copyWith(), tool);
        expect(tool.copyWith().hashCode, tool.hashCode);
        expect(tool.toString(), isNot(contains('PRIVATE')));
        expect(
          () => UnknownAgentSessionToolResource.fromJson(const {
            'type': 'automations',
          }),
          throwsFormatException,
        );
        expect(
          () => AgentSessionToolResource.automations(
            rawJson: const {'type': 'wrong'},
          ),
          throwsFormatException,
        );
      },
    );
  });
}

Map<String, dynamic> _wire(String schema) =>
    jsonDecode(
          jsonEncode(
            agentSessionWireFixtures
                .singleWhere((fixture) => fixture.schema == schema)
                .minimal,
          ),
        )
        as Map<String, dynamic>;
