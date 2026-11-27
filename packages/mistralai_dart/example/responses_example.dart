// ignore_for_file: avoid_print
import 'package:mistralai_dart/mistralai_dart.dart';

/// Counts tokens and streams a stateless response.
Future<void> main(List<String> args) async {
  if (args.isEmpty || args.contains('--help')) {
    print('Usage: dart run example/responses_example.dart <prompt>');
    print('Set MISTRAL_API_KEY before sending a request.');
    return;
  }

  final client = MistralClient.fromEnvironment();
  try {
    const model = 'mistral-large-latest';
    final input = ResponseInput.text(args.join(' '));
    final count = await client.responses.countInputTokens(
      request: CountResponseInputTokensRequest(model: model, input: input),
    );
    print('Input tokens: ${count.inputTokens}');

    await for (final event in client.responses.createStream(
      request: CreateResponseRequest(model: model, input: input),
    )) {
      if (event is ResponseTextDeltaEvent) {
        print(event.delta);
      } else if (event is ResponseStreamErrorEvent) {
        print('Response error: ${event.message}');
      }
    }
  } finally {
    client.close();
  }
}
