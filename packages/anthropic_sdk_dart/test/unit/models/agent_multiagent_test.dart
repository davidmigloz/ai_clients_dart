import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> agentJson({Object? multiagent = #absent}) {
    return {
      'id': 'agent_test123',
      'type': 'agent',
      'version': 1,
      'name': 'Coordinator',
      'description': null,
      'model': {'id': 'claude-opus-4-7', 'type': 'model'},
      'system': null,
      'tools': <Map<String, dynamic>>[],
      'mcp_servers': <Map<String, dynamic>>[],
      'skills': <Map<String, dynamic>>[],
      'metadata': <String, String>{},
      if (multiagent != #absent) 'multiagent': multiagent,
      'created_at': '2026-04-01T00:00:00.000Z',
      'updated_at': '2026-04-01T00:00:00.000Z',
      'archived_at': null,
    };
  }

  const coordinatorJson = {
    'type': 'coordinator',
    'agents': [
      {'type': 'agent', 'id': 'agent_worker', 'version': 1},
    ],
  };

  group('Agent.multiagent wiring', () {
    test('parses and round-trips when present', () {
      final agent = Agent.fromJson(agentJson(multiagent: coordinatorJson));
      expect(agent.multiagent, isA<MultiagentCoordinator>());
      expect(agent.toJson()['multiagent'], coordinatorJson);
    });

    test('is null and omitted from toJson when absent', () {
      final agent = Agent.fromJson(agentJson());
      expect(agent.multiagent, isNull);
      expect(agent.toJson().containsKey('multiagent'), isFalse);
    });

    test('copyWith clears multiagent with explicit null', () {
      final agent = Agent.fromJson(agentJson(multiagent: coordinatorJson));
      expect(agent.copyWith(multiagent: null).multiagent, isNull);
      // Omitting preserves it.
      expect(
        agent.copyWith(name: 'x').multiagent,
        isA<MultiagentCoordinator>(),
      );
    });
  });

  group('SessionAgent.multiagent wiring', () {
    Map<String, dynamic> sessionAgentJson({Object? multiagent = #absent}) {
      return {
        'id': 'agent_test123',
        'type': 'agent',
        'version': 1,
        'name': 'Coordinator',
        'description': null,
        'system': null,
        'model': {'id': 'claude-opus-4-7', 'type': 'model'},
        'mcp_servers': <Map<String, dynamic>>[],
        'skills': <Map<String, dynamic>>[],
        'tools': <Map<String, dynamic>>[],
        if (multiagent != #absent) 'multiagent': multiagent,
      };
    }

    test('parses the resolved coordinator when present', () {
      final json = {
        'type': 'coordinator',
        'agents': [sessionAgentJson()],
      };
      final agent = SessionAgent.fromJson(sessionAgentJson(multiagent: json));
      final multiagent = agent.multiagent;
      expect(multiagent, isA<SessionMultiagentCoordinator>());
      expect(
        (multiagent! as SessionMultiagentCoordinator).agents.single.id,
        'agent_test123',
      );
      // Round-trips stably through serialization.
      expect(SessionAgent.fromJson(agent.toJson()), agent);
    });

    test('is null and omitted when absent', () {
      final agent = SessionAgent.fromJson(sessionAgentJson());
      expect(agent.multiagent, isNull);
      expect(agent.toJson().containsKey('multiagent'), isFalse);
    });
  });

  group('Session.outcomeEvaluations wiring', () {
    Map<String, dynamic> sessionJson({Object? outcomeEvaluations = #absent}) {
      return {
        'id': 'sesn_1',
        'type': 'session',
        'status': 'idle',
        'agent': {
          'id': 'agent_1',
          'type': 'agent',
          'version': 1,
          'name': 'A',
          'model': {'id': 'claude-opus-4-7', 'type': 'model'},
          'mcp_servers': <Map<String, dynamic>>[],
          'skills': <Map<String, dynamic>>[],
          'tools': <Map<String, dynamic>>[],
        },
        'environment_id': 'env_1',
        'title': null,
        'metadata': <String, String>{},
        'resources': <Map<String, dynamic>>[],
        'vault_ids': <String>[],
        'stats': {'active_seconds': 0, 'duration_seconds': 0},
        'usage': {
          'input_tokens': 0,
          'output_tokens': 0,
          'cache_read_input_tokens': 0,
          'cache_creation_input_tokens': 0,
        },
        if (outcomeEvaluations != #absent)
          'outcome_evaluations': outcomeEvaluations,
        'created_at': '2026-04-01T00:00:00.000Z',
        'updated_at': '2026-04-01T00:00:00.000Z',
        'archived_at': null,
      };
    }

    test('parses entries when present', () {
      final session = Session.fromJson(
        sessionJson(
          outcomeEvaluations: [
            {
              'type': 'outcome_evaluation',
              'outcome_id': 'outc_1',
              'description': 'task',
              'result': 'satisfied',
              'iteration': 0,
              'completed_at': null,
              'explanation': null,
            },
          ],
        ),
      );
      expect(session.outcomeEvaluations, hasLength(1));
      expect(session.outcomeEvaluations.single.outcomeId, 'outc_1');
    });

    test('defaults to empty list when absent and always emits in toJson', () {
      final session = Session.fromJson(sessionJson());
      expect(session.outcomeEvaluations, isEmpty);
      expect(session.toJson()['outcome_evaluations'], isEmpty);
    });
  });

  group('CreateAgentParams.multiagent wiring', () {
    test('serializes when set and omits when null', () {
      const withMa = CreateAgentParams(
        name: 'C',
        model: ModelParamsId(id: 'claude-opus-4-7'),
        multiagent: MultiagentCoordinatorParams(
          agents: [MultiagentSelfParams()],
        ),
      );
      expect(withMa.toJson()['multiagent'], {
        'type': 'coordinator',
        'agents': [
          {'type': 'self'},
        ],
      });

      const without = CreateAgentParams(
        name: 'C',
        model: ModelParamsId(id: 'claude-opus-4-7'),
      );
      expect(without.toJson().containsKey('multiagent'), isFalse);
    });
  });

  group('UpdateAgentParams.multiagent tri-state', () {
    const value = MultiagentCoordinatorParams(agents: [MultiagentSelfParams()]);

    test('omitted: no multiagent key in toJson', () {
      const params = UpdateAgentParams(version: 1);
      expect(params.toJson().containsKey('multiagent'), isFalse);
    });

    test('explicit null: emits multiagent: null (clear)', () {
      const params = UpdateAgentParams(version: 1, multiagent: null);
      expect(params.toJson().containsKey('multiagent'), isTrue);
      expect(params.toJson()['multiagent'], isNull);
    });

    test('value: emits the serialized object', () {
      const params = UpdateAgentParams(version: 1, multiagent: value);
      expect(params.toJson()['multiagent'], {
        'type': 'coordinator',
        'agents': [
          {'type': 'self'},
        ],
      });
    });

    test('fromJson round-trips each state', () {
      // Omitted.
      final omitted = UpdateAgentParams.fromJson(const {'version': 1});
      expect(omitted.toJson().containsKey('multiagent'), isFalse);
      // Null (clear).
      final cleared = UpdateAgentParams.fromJson(const {
        'version': 1,
        'multiagent': null,
      });
      expect(cleared.toJson()['multiagent'], isNull);
      expect(cleared.toJson().containsKey('multiagent'), isTrue);
      // Value.
      final set = UpdateAgentParams.fromJson({
        'version': 1,
        'multiagent': value.toJson(),
      });
      expect(set.multiagent, isA<MultiagentCoordinatorParams>());
    });
  });
}
