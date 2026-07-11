import 'package:openai_dart/src/models/responses/multi_agent/agent_tag.dart';
import 'package:test/test.dart';

void main() {
  group('AgentTag', () {
    test('round-trips through JSON', () {
      const tag = AgentTag(agentName: 'researcher');

      final json = tag.toJson();
      expect(json, {'agent_name': 'researcher'});
      expect(AgentTag.fromJson(json), tag);
    });

    test('supports equality/hashCode', () {
      const a = AgentTag(agentName: 'researcher');
      const b = AgentTag(agentName: 'researcher');
      const c = AgentTag(agentName: 'writer');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('supports copyWith', () {
      const tag = AgentTag(agentName: 'researcher');
      final updated = tag.copyWith(agentName: 'writer');

      expect(updated.agentName, 'writer');
    });
  });
}
