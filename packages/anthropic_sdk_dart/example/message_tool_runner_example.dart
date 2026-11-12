// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Run with ANTHROPIC_API_KEY set. Pass --stream to observe completed turns over
/// SSE or --thread to use the Messages threads beta.
Future<void> main(List<String> args) async {
  final client = AnthropicClient.fromEnvironment();
  final square = RunnableMessageTool<int>(
    definition: const Tool(
      name: 'square',
      description: 'Square an integer.',
      inputSchema: InputSchema(
        properties: {
          'number': {'type': 'integer'},
        },
        required: ['number'],
        extra: {'additionalProperties': false},
      ),
      strict: true,
    ),
    decode: (input) => switch (input) {
      {'number': final int value} => value,
      _ => throw const FormatException('Expected an integer.'),
    },
    run: (value, call) {
      print('Running tool call ${call.toolUse.id}');
      return MessageToolResult.text('${value * value}');
    },
  );

  try {
    final result = await client.messages.runTools(
      MessageCreateRequest(
        model: 'claude-sonnet-5',
        maxTokens: 512,
        messages: [
          InputMessage.user('Use the square tool to calculate 17 squared.'),
        ],
      ),
      tools: [square],
      maxIterations: 4,
      stream: args.contains('--stream'),
      useThread: args.contains('--thread'),
      onTurn: (message) => print('Turn ${message.id}: ${message.stopReason}'),
    );
    print(result.message.text);
    if (result.iterationLimitReached) {
      print('Tool loop ended at the iteration limit.');
    }
  } finally {
    client.close();
  }
}
