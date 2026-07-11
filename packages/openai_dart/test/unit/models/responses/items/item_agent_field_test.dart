import 'package:openai_dart/src/models/responses/config/message_role.dart';
import 'package:openai_dart/src/models/responses/config/program_output_status.dart';
import 'package:openai_dart/src/models/responses/content/input_content.dart';
import 'package:openai_dart/src/models/responses/items/item.dart';
import 'package:openai_dart/src/models/responses/multi_agent/agent_tag.dart';
import 'package:test/test.dart';

void main() {
  group('MessageItem.agent', () {
    test('round-trips through JSON', () {
      const item = MessageItem(
        agent: AgentTag(agentName: 'planner'),
        role: MessageRole.user,
        content: [InputTextContent('hi')],
      );

      final json = item.toJson();
      expect(json['agent'], {'agent_name': 'planner'});
      expect(Item.fromJson(json), item);
    });

    test('omits agent when null', () {
      const item = MessageItem(
        role: MessageRole.user,
        content: [InputTextContent('hi')],
      );

      final json = item.toJson();
      expect(json.containsKey('agent'), isFalse);
      expect((Item.fromJson(json) as MessageItem).agent, isNull);
    });

    test('equality distinguishes different agents', () {
      const a = MessageItem(
        agent: AgentTag(agentName: 'planner'),
        role: MessageRole.user,
        content: [InputTextContent('hi')],
      );
      const b = MessageItem(
        agent: AgentTag(agentName: 'researcher'),
        role: MessageRole.user,
        content: [InputTextContent('hi')],
      );

      expect(a, isNot(b));
    });
  });

  group('FunctionCallItem.agent', () {
    test('round-trips through JSON', () {
      const item = FunctionCallItem(
        agent: AgentTag(agentName: 'planner'),
        callId: 'call_1',
        name: 'get_weather',
        arguments: '{}',
      );

      final json = item.toJson();
      expect(json['agent'], {'agent_name': 'planner'});
      expect(Item.fromJson(json), item);
    });

    test('omits agent when null', () {
      const item = FunctionCallItem(
        callId: 'call_1',
        name: 'get_weather',
        arguments: '{}',
      );

      final json = item.toJson();
      expect(json.containsKey('agent'), isFalse);
      expect((Item.fromJson(json) as FunctionCallItem).agent, isNull);
    });

    test('equality distinguishes different agents', () {
      const a = FunctionCallItem(
        agent: AgentTag(agentName: 'planner'),
        callId: 'call_1',
        name: 'get_weather',
        arguments: '{}',
      );
      const b = FunctionCallItem(
        agent: AgentTag(agentName: 'researcher'),
        callId: 'call_1',
        name: 'get_weather',
        arguments: '{}',
      );

      expect(a, isNot(b));
    });
  });

  group('ItemReference.agent', () {
    test('round-trips through JSON', () {
      const item = ItemReference(
        id: 'item_1',
        agent: AgentTag(agentName: 'planner'),
      );

      final json = item.toJson();
      expect(json['agent'], {'agent_name': 'planner'});
      expect(Item.fromJson(json), item);
    });

    test('omits agent when null', () {
      const item = ItemReference(id: 'item_1');

      final json = item.toJson();
      expect(json.containsKey('agent'), isFalse);
      expect((Item.fromJson(json) as ItemReference).agent, isNull);
    });

    test('equality distinguishes different agents', () {
      const a = ItemReference(
        id: 'item_1',
        agent: AgentTag(agentName: 'planner'),
      );
      const b = ItemReference(
        id: 'item_1',
        agent: AgentTag(agentName: 'researcher'),
      );

      expect(a, isNot(b));
    });
  });

  group('ProgramItem.agent', () {
    test('round-trips through JSON', () {
      const item = ProgramItem(
        id: 'cm_1',
        agent: AgentTag(agentName: 'planner'),
        callId: 'call_1',
        code: 'return 1 + 1;',
        fingerprint: 'fp_1',
      );

      final json = item.toJson();
      expect(json['agent'], {'agent_name': 'planner'});
      expect(Item.fromJson(json), item);
    });

    test('omits agent when null', () {
      const item = ProgramItem(
        id: 'cm_1',
        callId: 'call_1',
        code: 'return 1 + 1;',
        fingerprint: 'fp_1',
      );

      final json = item.toJson();
      expect(json.containsKey('agent'), isFalse);
      expect((Item.fromJson(json) as ProgramItem).agent, isNull);
    });

    test('equality distinguishes different agents', () {
      const a = ProgramItem(
        id: 'cm_1',
        agent: AgentTag(agentName: 'planner'),
        callId: 'call_1',
        code: 'return 1 + 1;',
        fingerprint: 'fp_1',
      );
      const b = ProgramItem(
        id: 'cm_1',
        agent: AgentTag(agentName: 'researcher'),
        callId: 'call_1',
        code: 'return 1 + 1;',
        fingerprint: 'fp_1',
      );

      expect(a, isNot(b));
    });
  });

  group('remaining agent-bearing item variants', () {
    test('FunctionCallOutputItem round-trips agent and omits when null', () {
      final withAgent = FunctionCallOutputItem.string(
        agent: const AgentTag(agentName: 'planner'),
        callId: 'call_1',
        output: 'sunny',
      );
      final json = withAgent.toJson();
      expect(json['agent'], {'agent_name': 'planner'});
      expect(Item.fromJson(json), withAgent);

      final withoutAgent = FunctionCallOutputItem.string(
        callId: 'call_1',
        output: 'sunny',
      );
      expect(withoutAgent.toJson().containsKey('agent'), isFalse);
    });

    test(
      'CustomToolCallOutputInputItem round-trips agent and omits when null',
      () {
        final withAgent = CustomToolCallOutputInputItem.string(
          agent: const AgentTag(agentName: 'planner'),
          callId: 'call_1',
          output: 'done',
        );
        final json = withAgent.toJson();
        expect(json['agent'], {'agent_name': 'planner'});
        expect(Item.fromJson(json), withAgent);

        final withoutAgent = CustomToolCallOutputInputItem.string(
          callId: 'call_1',
          output: 'done',
        );
        expect(withoutAgent.toJson().containsKey('agent'), isFalse);
      },
    );

    test('ToolSearchCallItemParam round-trips agent and omits when null', () {
      const withAgent = ToolSearchCallItemParam(
        agent: AgentTag(agentName: 'planner'),
      );
      final json = withAgent.toJson();
      expect(json['agent'], {'agent_name': 'planner'});
      expect(Item.fromJson(json), withAgent);

      const withoutAgent = ToolSearchCallItemParam();
      expect(withoutAgent.toJson().containsKey('agent'), isFalse);
    });

    test('ToolSearchOutputItemParam round-trips agent and omits when null', () {
      const withAgent = ToolSearchOutputItemParam(
        agent: AgentTag(agentName: 'planner'),
        tools: [],
      );
      final json = withAgent.toJson();
      expect(json['agent'], {'agent_name': 'planner'});
      expect(Item.fromJson(json), withAgent);

      const withoutAgent = ToolSearchOutputItemParam(tools: []);
      expect(withoutAgent.toJson().containsKey('agent'), isFalse);
    });

    test('CompactionTriggerItem round-trips agent and omits when null', () {
      const withAgent = CompactionTriggerItem(
        agent: AgentTag(agentName: 'planner'),
      );
      final json = withAgent.toJson();
      expect(json['agent'], {'agent_name': 'planner'});
      expect(Item.fromJson(json), withAgent);

      const withoutAgent = CompactionTriggerItem();
      expect(withoutAgent.toJson().containsKey('agent'), isFalse);
    });

    test('AdditionalToolsItemParam round-trips agent and omits when null', () {
      const withAgent = AdditionalToolsItemParam(
        agent: AgentTag(agentName: 'planner'),
        tools: [],
      );
      final json = withAgent.toJson();
      expect(json['agent'], {'agent_name': 'planner'});
      expect(Item.fromJson(json), withAgent);

      const withoutAgent = AdditionalToolsItemParam(tools: []);
      expect(withoutAgent.toJson().containsKey('agent'), isFalse);
    });

    test('ProgramOutputItem round-trips agent and omits when null', () {
      const withAgent = ProgramOutputItem(
        id: 'cmo_1',
        agent: AgentTag(agentName: 'planner'),
        callId: 'call_1',
        result: '2',
        status: ProgramOutputStatus.completed,
      );
      final json = withAgent.toJson();
      expect(json['agent'], {'agent_name': 'planner'});
      expect(Item.fromJson(json), withAgent);

      const withoutAgent = ProgramOutputItem(
        id: 'cmo_1',
        callId: 'call_1',
        result: '2',
        status: ProgramOutputStatus.completed,
      );
      expect(withoutAgent.toJson().containsKey('agent'), isFalse);
    });
  });
}
