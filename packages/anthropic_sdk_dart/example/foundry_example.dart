// ignore_for_file: avoid_print

import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Streams from a Claude deployment in Microsoft Foundry.
///
/// Pass the deployment name. Set ANTHROPIC_FOUNDRY_RESOURCE and either
/// ANTHROPIC_FOUNDRY_API_KEY or an Entra token in AZURE_ACCESS_TOKEN.
Future<void> main(List<String> arguments) async {
  if (arguments.length != 1) {
    throw ArgumentError('Usage: foundry_example.dart deployment-name');
  }
  final token = Platform.environment['AZURE_ACCESS_TOKEN'];
  final client = AnthropicFoundryClient(
    tokenProvider: token == null ? null : () => token,
    azureHosted:
        Platform.environment['ANTHROPIC_FOUNDRY_AZURE_HOSTED'] == 'true',
  );
  try {
    await for (final event in client.messages.createStream(
      MessageCreateRequest(
        model: arguments.single,
        maxTokens: 128,
        messages: [
          InputMessage.user('Explain a message stream in one sentence.'),
        ],
      ),
    )) {
      if (event case ContentBlockDeltaEvent(delta: TextDelta(:final text))) {
        stdout.write(text);
      }
    }
    stdout.writeln();
  } finally {
    client.close();
  }
}
