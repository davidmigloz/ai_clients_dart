// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Run with an ANTHROPIC_API_KEY and no arguments for the current API.
/// Pass --legacy to demonstrate the older API's sampling controls.
Future<void> main(List<String> args) async {
  final useLegacyVersion = args.contains('--legacy');
  final config = AnthropicConfig.fromEnvironment();
  final client = AnthropicClient(
    config: useLegacyVersion
        ? config.copyWith(apiVersion: AnthropicConfig.legacyApiVersion)
        : config,
  );

  try {
    final response = await client.messages.create(
      MessageCreateRequest(
        model: useLegacyVersion ? 'claude-sonnet-4-6' : 'claude-sonnet-5-5',
        maxTokens: 512,
        messages: [InputMessage.user('Give a short explanation of SSE.')],
        temperature: useLegacyVersion ? 0.2 : null,
      ),
    );
    print(response.text);
  } finally {
    client.close();
  }
}
