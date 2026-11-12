// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Run with ANTHROPIC_API_KEY set. Pass --stream to use SSE.
Future<void> main(List<String> args) async {
  final client = AnthropicClient.fromEnvironment();
  final output = StructuredOutput<int>(
    schema: {
      'type': 'object',
      'properties': {
        'answer': {'type': 'integer'},
      },
      'required': ['answer'],
      'additionalProperties': false,
    },
    decode: (json) => switch (json) {
      {'answer': final int value} => value,
      _ => throw const FormatException('Expected an integer answer.'),
    },
  );
  final request = MessageCreateRequest(
    model: 'claude-sonnet-5',
    maxTokens: 128,
    messages: [InputMessage.user('What is 2 + 2?')],
  );

  try {
    final result = args.contains('--stream')
        ? await client.messages
              .parseStream(request, output: output)
              .finalParsedMessage()
        : await client.messages.parse(request, output: output);
    if (result.parsedOutput case final int answer) {
      print('Answer: $answer');
    } else {
      print(
        'Stopped with ${result.message.stopReason}: ${result.message.text}',
      );
    }
  } on StructuredOutputParseException catch (error) {
    print(
      'Could not parse message ${error.message.id}, block ${error.blockIndex}.',
    );
  } finally {
    client.close();
  }
}
