// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Run with ANTHROPIC_API_KEY set. Pass --stream for SSE, --thread for the
/// Messages threads beta, or --compact for on-demand compaction on a
/// supported platform.
Future<void> main(List<String> args) async {
  final compact = args.contains('--compact');
  final useThread = args.contains('--thread');
  if (compact && useThread) {
    throw ArgumentError('Choose either --compact or --thread.');
  }
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
        model: compact ? 'claude-sonnet-5-5' : 'claude-sonnet-5',
        maxTokens: compact ? 4096 : 512,
        messages: [
          InputMessage.user('Use the square tool to calculate 17 squared.'),
        ],
      ),
      tools: [square],
      maxIterations: 4,
      stream: args.contains('--stream'),
      useThread: useThread,
      betas: [if (compact) 'compact-2026-09-04'],
      compactBeforeNextTurn: compact
          ? (_) => const CompactionConfig.summarize()
          : null,
      onTurn: (message) => print('Turn ${message.id}: ${message.stopReason}'),
    );
    print(result.message.text);
    if (result.compactionMessage case final message?) {
      print('Compaction response ${message.id}: ${message.stopReason}');
    }
    if (result.iterationLimitReached) {
      print('Tool loop ended at the iteration limit.');
    }
  } finally {
    client.close();
  }
}
