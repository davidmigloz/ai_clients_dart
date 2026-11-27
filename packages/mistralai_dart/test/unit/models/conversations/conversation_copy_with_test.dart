import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  test('Agent handoffs accept plain literals and explicit null', () {
    const create = CreateAgentRequest(name: 'Agent', model: 'model');
    final createWithHandoffs = create.copyWith(handoffs: ['agent-2']);
    expect(createWithHandoffs.copyWith().handoffs, ['agent-2']);
    expect(
      createWithHandoffs.copyWith(handoffs: []).toJson()['handoffs'],
      isEmpty,
    );
    expect(
      createWithHandoffs.copyWith(handoffs: null).toJson(),
      isNot(contains('handoffs')),
    );

    final update = const UpdateAgentRequest().copyWith(handoffs: ['agent-3']);
    expect(update.copyWith().handoffs, ['agent-3']);
    expect(update.copyWith(handoffs: []).toJson()['handoffs'], isEmpty);
    expect(
      update.copyWith(handoffs: null).toJson(),
      isNot(contains('handoffs')),
    );
  });

  test('Conversation tools and guardrails accept plain list literals', () {
    final conversation = const Conversation(id: 'c').copyWith(
      tools: [const Tool.codeInterpreter()],
      guardrails: [const GuardrailConfig(blockOnError: true)],
    );
    expect(conversation.copyWith().tools, [const Tool.codeInterpreter()]);
    expect(conversation.copyWith().guardrails?.single.blockOnError, isTrue);
    final empty = conversation.copyWith(tools: [], guardrails: []);
    expect(empty.toJson()['tools'], isEmpty);
    expect(empty.toJson()['guardrails'], isEmpty);

    final cleared = conversation.copyWith(tools: null, guardrails: null);
    expect(cleared.toJson(), isNot(contains('tools')));
    expect(cleared.toJson(), isNot(contains('guardrails')));
  });

  test(
    'Restart input and metadata accept plain literals and preserve null',
    () {
      final restart = const RestartConversationRequest(entryId: 'e').copyWith(
        inputs: [const MessageInputEntry(content: 'Try again')],
        metadata: {'attempt': 1},
      );
      expect(restart.copyWith().inputs?.single, isA<MessageInputEntry>());
      expect(restart.copyWith().metadata, {'attempt': 1});
      final empty = restart.copyWith(inputs: [], metadata: {});
      expect(empty.toJson()['inputs'], isEmpty);
      expect(empty.toJson()['metadata'], isEmpty);

      final cleared = restart.copyWith(inputs: null, metadata: null);
      expect(cleared.toJson(), isNot(contains('inputs')));
      expect(cleared.toJson(), isNot(contains('metadata')));
    },
  );

  test('Tool argument and execution info maps accept plain literals', () {
    final call = const FunctionCallEntry(
      name: 'lookup',
      arguments: '{}',
    ).copyWith(argumentsObject: {'city': 'Paris'});
    expect(call.copyWith().toJson()['arguments'], {'city': 'Paris'});
    expect(call.copyWith(argumentsObject: {}).toJson()['arguments'], isEmpty);
    expect(call.copyWith(argumentsObject: null).argumentsObject, isNull);

    final entry = const ToolExecutionEntry(
      toolType: 'web_search',
    ).copyWith(info: {'page': 1});
    expect(entry.copyWith().output, {'page': 1});
    expect(entry.copyWith(info: {}).toJson()['info'], isEmpty);
    expect(entry.copyWith(info: null).toJson(), isNot(contains('info')));

    final event = const ConversationToolExecutionDone(
      id: 'tool-1',
      name: 'web_search',
    ).copyWith(info: {'page': 1});
    expect(event.copyWith().info, {'page': 1});
    expect(event.copyWith(info: {}).toJson()['info'], isEmpty);
    expect(event.copyWith(info: null).toJson(), isNot(contains('info')));
  });

  test('Connector usage accepts empty and populated map literals', () {
    final usage = const UsageInfo(
      promptTokens: 3,
      completionTokens: 2,
      totalTokens: 5,
    ).copyWith(connectors: {'web_search': 3});
    expect(usage.copyWith().toJson()['connectors'], {'web_search': 3});
    expect(usage.copyWith(connectors: {}).toJson()['connectors'], isEmpty);
    expect(
      usage.copyWith(connectors: null).toJson(),
      isNot(contains('connectors')),
    );
  });
}
