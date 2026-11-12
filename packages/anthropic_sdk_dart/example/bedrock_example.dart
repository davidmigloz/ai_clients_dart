// ignore_for_file: avoid_print

import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Streams Claude on Bedrock Runtime or Mantle.
///
/// Run with "runtime" or "mantle" followed by a model or inference profile
/// ID. Set AWS_REGION and either AWS_BEARER_TOKEN_BEDROCK or the standard
/// AWS IAM environment credentials. For older models set
/// BEDROCK_ANTHROPIC_VERSION to the version the model accepts.
Future<void> main(List<String> arguments) async {
  if (arguments.length != 2 ||
      (arguments.first != 'runtime' && arguments.first != 'mantle')) {
    throw ArgumentError('Usage: bedrock_example.dart runtime|mantle model-id');
  }
  final config = AnthropicConfig(
    apiVersion:
        Platform.environment['BEDROCK_ANTHROPIC_VERSION'] ??
        AnthropicConfig.defaultApiVersion,
  );
  final AnthropicClient client = switch (arguments.first) {
    'runtime' => AnthropicBedrockClient(config: config),
    _ => AnthropicBedrockMantleClient(config: config),
  };
  try {
    await for (final event in client.messages.createStream(
      MessageCreateRequest(
        model: arguments.last,
        maxTokens: 128,
        messages: [
          InputMessage.user('Explain token counting in one sentence.'),
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
