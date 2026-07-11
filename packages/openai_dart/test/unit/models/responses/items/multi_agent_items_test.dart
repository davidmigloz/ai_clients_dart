import 'package:openai_dart/src/models/responses/config/item_status.dart';
import 'package:openai_dart/src/models/responses/config/message_role.dart';
import 'package:openai_dart/src/models/responses/content/input_content.dart';
import 'package:openai_dart/src/models/responses/content/output_content.dart';
import 'package:openai_dart/src/models/responses/items/item.dart';
import 'package:openai_dart/src/models/responses/items/output_item.dart';
import 'package:openai_dart/src/models/responses/multi_agent/agent_tag.dart';
import 'package:openai_dart/src/models/responses/multi_agent/multi_agent_action.dart';
import 'package:test/test.dart';

void main() {
  group('AgentMessageItem', () {
    test('round-trips through JSON', () {
      const item = AgentMessageItem(
        id: 'amsg_1',
        agent: AgentTag(agentName: 'researcher'),
        author: 'agent-a',
        recipient: 'agent-b',
        content: [InputTextContent('hello')],
      );

      final json = item.toJson();
      expect(json, {
        'type': 'agent_message',
        'id': 'amsg_1',
        'agent': {'agent_name': 'researcher'},
        'author': 'agent-a',
        'recipient': 'agent-b',
        'content': [
          {'type': 'input_text', 'text': 'hello'},
        ],
      });

      expect(Item.fromJson(json), item);
    });

    test('omits optional fields when null', () {
      const item = AgentMessageItem(
        author: 'agent-a',
        recipient: 'agent-b',
        content: [InputTextContent('hi')],
      );

      final json = item.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('agent'), isFalse);

      final decoded = Item.fromJson(json) as AgentMessageItem;
      expect(decoded.id, isNull);
      expect(decoded.agent, isNull);
    });

    test('dispatches via Item.fromJson', () {
      final item = Item.fromJson({
        'type': 'agent_message',
        'author': 'a',
        'recipient': 'b',
        'content': <Map<String, dynamic>>[],
      });
      expect(item, isA<AgentMessageItem>());
    });
  });

  group('MultiAgentCallItem', () {
    test('round-trips through JSON', () {
      const item = MultiAgentCallItem(
        id: 'mac_1',
        agent: AgentTag(agentName: 'orchestrator'),
        callId: 'call_1',
        action: MultiAgentAction.spawnAgent,
        arguments: '{"task":"research"}',
      );

      final json = item.toJson();
      expect(json, {
        'type': 'multi_agent_call',
        'id': 'mac_1',
        'agent': {'agent_name': 'orchestrator'},
        'call_id': 'call_1',
        'action': 'spawn_agent',
        'arguments': '{"task":"research"}',
      });

      expect(Item.fromJson(json), item);
    });

    test('dispatches via Item.fromJson', () {
      final item = Item.fromJson({
        'type': 'multi_agent_call',
        'call_id': 'call_1',
        'action': 'wait_agent',
        'arguments': '{}',
      });
      expect(item, isA<MultiAgentCallItem>());
      expect((item as MultiAgentCallItem).action, MultiAgentAction.waitAgent);
    });
  });

  group('MultiAgentCallOutputItem', () {
    test('round-trips through JSON', () {
      const item = MultiAgentCallOutputItem(
        id: 'maco_1',
        agent: AgentTag(agentName: 'orchestrator'),
        callId: 'call_1',
        action: MultiAgentAction.listAgents,
        output: [OutputTextContent(text: 'done')],
      );

      final json = item.toJson();
      expect(json, {
        'type': 'multi_agent_call_output',
        'id': 'maco_1',
        'agent': {'agent_name': 'orchestrator'},
        'call_id': 'call_1',
        'action': 'list_agents',
        'output': [
          {'type': 'output_text', 'text': 'done'},
        ],
      });

      expect(Item.fromJson(json), item);
    });

    test('dispatches via Item.fromJson', () {
      final item = Item.fromJson({
        'type': 'multi_agent_call_output',
        'call_id': 'call_1',
        'action': 'followup_task',
        'output': <Map<String, dynamic>>[],
      });
      expect(item, isA<MultiAgentCallOutputItem>());
    });
  });

  group('AgentMessageOutputItem', () {
    test('round-trips through JSON', () {
      const item = AgentMessageOutputItem(
        id: 'amsg_1',
        agent: AgentTag(agentName: 'researcher'),
        author: 'agent-a',
        recipient: 'agent-b',
        content: [OutputTextContent(text: 'hello')],
      );

      final json = item.toJson();
      expect(json, {
        'type': 'agent_message',
        'id': 'amsg_1',
        'agent': {'agent_name': 'researcher'},
        'author': 'agent-a',
        'recipient': 'agent-b',
        'content': [
          {'type': 'output_text', 'text': 'hello'},
        ],
      });

      expect(OutputItem.fromJson(json), item);
    });

    test('dispatches via OutputItem.fromJson', () {
      final item = OutputItem.fromJson({
        'type': 'agent_message',
        'id': 'amsg_1',
        'author': 'a',
        'recipient': 'b',
        'content': <Map<String, dynamic>>[],
      });
      expect(item, isA<AgentMessageOutputItem>());
    });
  });

  group('MultiAgentCallOutputItemResponse', () {
    test('round-trips through JSON', () {
      const item = MultiAgentCallOutputItemResponse(
        id: 'mac_1',
        agent: AgentTag(agentName: 'orchestrator'),
        callId: 'call_1',
        action: MultiAgentAction.sendMessage,
        arguments: '{"to":"agent-b"}',
      );

      final json = item.toJson();
      expect(json, {
        'type': 'multi_agent_call',
        'id': 'mac_1',
        'agent': {'agent_name': 'orchestrator'},
        'call_id': 'call_1',
        'action': 'send_message',
        'arguments': '{"to":"agent-b"}',
      });

      expect(OutputItem.fromJson(json), item);
    });

    test('dispatches via OutputItem.fromJson', () {
      final item = OutputItem.fromJson({
        'type': 'multi_agent_call',
        'id': 'mac_1',
        'call_id': 'call_1',
        'action': 'interrupt_agent',
        'arguments': '{}',
      });
      expect(item, isA<MultiAgentCallOutputItemResponse>());
    });
  });

  group('MultiAgentCallOutputResultItem', () {
    test('round-trips through JSON', () {
      const item = MultiAgentCallOutputResultItem(
        id: 'maco_1',
        agent: AgentTag(agentName: 'orchestrator'),
        callId: 'call_1',
        action: MultiAgentAction.listAgents,
        output: [OutputTextContent(text: 'done')],
      );

      final json = item.toJson();
      expect(json, {
        'type': 'multi_agent_call_output',
        'id': 'maco_1',
        'agent': {'agent_name': 'orchestrator'},
        'call_id': 'call_1',
        'action': 'list_agents',
        'output': [
          {'type': 'output_text', 'text': 'done'},
        ],
      });

      expect(OutputItem.fromJson(json), item);
    });

    test('dispatches via OutputItem.fromJson', () {
      final item = OutputItem.fromJson({
        'type': 'multi_agent_call_output',
        'id': 'maco_1',
        'call_id': 'call_1',
        'action': 'followup_task',
        'output': <Map<String, dynamic>>[],
      });
      expect(item, isA<MultiAgentCallOutputResultItem>());
    });
  });

  group('agent field on other output item variants', () {
    test('MessageOutputItem round-trips agent and omits when null', () {
      const withAgent = MessageOutputItem(
        id: 'msg_1',
        agent: AgentTag(agentName: 'researcher'),
        role: MessageRole.assistant,
        content: [OutputTextContent(text: 'hello')],
      );
      final json = withAgent.toJson();
      expect(json['agent'], {'agent_name': 'researcher'});
      expect(OutputItem.fromJson(json), withAgent);

      const withoutAgent = MessageOutputItem(
        id: 'msg_1',
        role: MessageRole.assistant,
        content: [OutputTextContent(text: 'hello')],
      );
      final jsonWithout = withoutAgent.toJson();
      expect(jsonWithout.containsKey('agent'), isFalse);
      expect(
        (OutputItem.fromJson(jsonWithout) as MessageOutputItem).agent,
        isNull,
      );
    });

    test(
      'FunctionCallOutputItemResponse round-trips agent and omits when null',
      () {
        const withAgent = FunctionCallOutputItemResponse(
          id: 'fc_1',
          agent: AgentTag(agentName: 'researcher'),
          callId: 'call_1',
          name: 'get_weather',
          arguments: '{}',
        );
        final json = withAgent.toJson();
        expect(json['agent'], {'agent_name': 'researcher'});
        expect(OutputItem.fromJson(json), withAgent);

        const withoutAgent = FunctionCallOutputItemResponse(
          id: 'fc_1',
          callId: 'call_1',
          name: 'get_weather',
          arguments: '{}',
        );
        final jsonWithout = withoutAgent.toJson();
        expect(jsonWithout.containsKey('agent'), isFalse);
        expect(
          (OutputItem.fromJson(jsonWithout) as FunctionCallOutputItemResponse)
              .agent,
          isNull,
        );
      },
    );

    test('ReasoningItem round-trips agent and omits when null', () {
      const withAgent = ReasoningItem(
        id: 'rs_1',
        agent: AgentTag(agentName: 'researcher'),
        summary: [],
      );
      final json = withAgent.toJson();
      expect(json['agent'], {'agent_name': 'researcher'});
      expect(OutputItem.fromJson(json), withAgent);

      const withoutAgent = ReasoningItem(id: 'rs_1', summary: []);
      final jsonWithout = withoutAgent.toJson();
      expect(jsonWithout.containsKey('agent'), isFalse);
      expect((OutputItem.fromJson(jsonWithout) as ReasoningItem).agent, isNull);
    });

    test('ShellCallOutputItem round-trips agent and omits when null', () {
      const withAgent = ShellCallOutputItem(
        id: 'sc_1',
        agent: AgentTag(agentName: 'researcher'),
        callId: 'call_1',
        action: ShellCallAction(commands: ['ls']),
        status: ItemStatus.completed,
      );
      final json = withAgent.toJson();
      expect(json['agent'], {'agent_name': 'researcher'});
      expect(OutputItem.fromJson(json), withAgent);

      const withoutAgent = ShellCallOutputItem(
        id: 'sc_1',
        callId: 'call_1',
        action: ShellCallAction(commands: ['ls']),
        status: ItemStatus.completed,
      );
      final jsonWithout = withoutAgent.toJson();
      expect(jsonWithout.containsKey('agent'), isFalse);
      expect(
        (OutputItem.fromJson(jsonWithout) as ShellCallOutputItem).agent,
        isNull,
      );
    });
  });
}
