import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Multiagent (resolved)', () {
    test('MultiagentCoordinator round-trips via dispatch', () {
      final json = {
        'type': 'coordinator',
        'agents': [
          {
            'type': 'agent',
            'id': 'agent_011CZkYqphY8vELVzwCUpqiQ',
            'version': 1,
          },
          {'type': 'agent', 'id': 'agent_022', 'version': 3},
        ],
      };
      final m = Multiagent.fromJson(json);
      expect(m, isA<MultiagentCoordinator>());
      final coord = m as MultiagentCoordinator;
      expect(coord.agents, hasLength(2));
      expect(coord.agents.first.id, 'agent_011CZkYqphY8vELVzwCUpqiQ');
      expect(coord.agents.first.version, 1);
      expect(m.toJson(), json);
    });

    test('AgentReference round-trips and copyWith works', () {
      const ref = AgentReference(id: 'agent_x', version: 2);
      expect(ref.toJson(), {'type': 'agent', 'id': 'agent_x', 'version': 2});
      expect(AgentReference.fromJson(ref.toJson()), ref);
      expect(ref.copyWith(version: 5).version, 5);
      expect(ref.copyWith(version: 5), isNot(ref));
    });

    test('MultiagentCoordinator copyWith replaces the roster', () {
      const coord = MultiagentCoordinator(
        agents: [AgentReference(id: 'a', version: 1)],
      );
      final updated = coord.copyWith(
        agents: const [AgentReference(id: 'b', version: 2)],
      );
      expect(updated.agents.single.id, 'b');
      expect(updated, isNot(coord));
    });

    test('unknown discriminator falls back to UnknownMultiagent', () {
      final json = {'type': 'swarm', 'agents': <dynamic>[]};
      final m = Multiagent.fromJson(json);
      expect(m, isA<UnknownMultiagent>());
      expect(m.toJson(), json);
    });
  });

  group('MultiagentParams', () {
    test('round-trips a roster with all three entry forms', () {
      const params = MultiagentCoordinatorParams(
        agents: [
          MultiagentRosterEntryAgent(agent: AgentParamsId(id: 'agent_x')),
          MultiagentRosterEntryAgent(
            agent: AgentParamsObject(id: 'agent_y', version: 2),
          ),
          MultiagentSelfParams(),
        ],
      );
      final json = params.toJson();
      expect(json, {
        'type': 'coordinator',
        'agents': [
          'agent_x',
          {'type': 'agent', 'id': 'agent_y', 'version': 2},
          {'type': 'self'},
        ],
      });
      expect(MultiagentParams.fromJson(json), params);
    });

    test('AgentParamsObject without version omits it', () {
      const entry = MultiagentRosterEntryAgent(
        agent: AgentParamsObject(id: 'agent_z'),
      );
      expect(entry.toJson(), {'type': 'agent', 'id': 'agent_z'});
    });

    test('copyWith replaces the roster', () {
      const params = MultiagentCoordinatorParams(
        agents: [MultiagentRosterEntryAgent(agent: AgentParamsId(id: 'a'))],
      );
      final updated = params.copyWith(agents: const [MultiagentSelfParams()]);
      expect(updated.agents.single, isA<MultiagentSelfParams>());
    });

    test('unknown topology falls back to UnknownMultiagentParams', () {
      final json = {'type': 'swarm', 'agents': <dynamic>[]};
      final m = MultiagentParams.fromJson(json);
      expect(m, isA<UnknownMultiagentParams>());
      expect(m.toJson(), json);
    });
  });

  group('MultiagentRosterEntryParams', () {
    test('a bare string parses to an agent-id entry', () {
      final entry = MultiagentRosterEntryParams.fromJson('agent_x');
      expect(entry, isA<MultiagentRosterEntryAgent>());
      expect((entry as MultiagentRosterEntryAgent).agent, isA<AgentParamsId>());
      expect(entry.toJson(), 'agent_x');
    });

    test('a versioned object parses to an agent-ref entry', () {
      final entry = MultiagentRosterEntryParams.fromJson({
        'type': 'agent',
        'id': 'agent_y',
        'version': 4,
      });
      expect(entry, isA<MultiagentRosterEntryAgent>());
      expect(
        (entry as MultiagentRosterEntryAgent).agent,
        isA<AgentParamsObject>(),
      );
    });

    test('a self object parses to MultiagentSelfParams', () {
      final entry = MultiagentRosterEntryParams.fromJson({'type': 'self'});
      expect(entry, isA<MultiagentSelfParams>());
      expect(entry.toJson(), {'type': 'self'});
    });

    test('an unknown object falls back to Unknown', () {
      final entry = MultiagentRosterEntryParams.fromJson({'type': 'mystery'});
      expect(entry, isA<UnknownMultiagentRosterEntryParams>());
      expect(entry.toJson(), {'type': 'mystery'});
    });
  });

  group('SessionMultiagent', () {
    Map<String, dynamic> sessionAgentJson(String id) => {
      'id': id,
      'type': 'agent',
      'version': 1,
      'name': 'Worker',
      'description': null,
      'system': null,
      'model': {'id': 'claude-opus-4-7'},
      'mcp_servers': <dynamic>[],
      'skills': <dynamic>[],
      'tools': <dynamic>[],
    };

    test('SessionMultiagentCoordinator round-trips with full agents', () {
      final json = {
        'type': 'coordinator',
        'agents': [sessionAgentJson('agent_worker')],
      };
      final m = SessionMultiagent.fromJson(json);
      expect(m, isA<SessionMultiagentCoordinator>());
      final coord = m as SessionMultiagentCoordinator;
      expect(coord.agents.single.id, 'agent_worker');
      expect(coord.agents.single.multiagent, isNull);
      expect(m.toJson(), json);
    });

    test('unknown topology falls back to UnknownSessionMultiagent', () {
      final json = {'type': 'swarm', 'agents': <dynamic>[]};
      final m = SessionMultiagent.fromJson(json);
      expect(m, isA<UnknownSessionMultiagent>());
      expect(m.toJson(), json);
    });
  });
}
