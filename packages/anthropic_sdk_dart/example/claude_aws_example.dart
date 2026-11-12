// ignore_for_file: avoid_print

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Calls the native Claude Platform on AWS endpoint.
///
/// Set AWS_REGION and ANTHROPIC_AWS_WORKSPACE_ID. Authenticate with
/// ANTHROPIC_AWS_API_KEY or AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.
/// Set AWS_SESSION_TOKEN as well when using temporary credentials.
Future<void> main() async {
  final client = AnthropicAwsClient();
  try {
    final message = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 128,
        messages: [InputMessage.user('Say hello in Spanish.')],
      ),
    );
    print(message.text);
  } finally {
    client.close();
  }
}
