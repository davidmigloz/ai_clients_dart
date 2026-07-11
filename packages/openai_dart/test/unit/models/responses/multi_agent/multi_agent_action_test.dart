import 'package:openai_dart/src/models/responses/multi_agent/multi_agent_action.dart';
import 'package:test/test.dart';

void main() {
  group('MultiAgentAction', () {
    test('round-trips known values', () {
      const values = {
        'spawn_agent': MultiAgentAction.spawnAgent,
        'interrupt_agent': MultiAgentAction.interruptAgent,
        'list_agents': MultiAgentAction.listAgents,
        'send_message': MultiAgentAction.sendMessage,
        'followup_task': MultiAgentAction.followupTask,
        'wait_agent': MultiAgentAction.waitAgent,
      };

      for (final entry in values.entries) {
        expect(MultiAgentAction.fromJson(entry.key), entry.value);
        expect(entry.value.toJson(), entry.key);
      }
    });

    test('falls back to unknown for unrecognized values', () {
      expect(MultiAgentAction.fromJson('bogus'), MultiAgentAction.unknown);
    });
  });
}
