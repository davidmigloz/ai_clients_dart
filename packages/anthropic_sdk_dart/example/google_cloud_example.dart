// ignore_for_file: avoid_print

import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Sends a Claude message through an Anthropic-managed or Google-managed project.
///
/// Run with "native" or "vertex" followed by the provider's model ID. Set
/// GOOGLE_CLOUD_PROJECT and GOOGLE_OAUTH_ACCESS_TOKEN. Native additionally
/// uses ANTHROPIC_GOOGLE_CLOUD_WORKSPACE_ID. Vertex defaults to a global route
/// unless CLOUD_ML_REGION is set.
Future<void> main(List<String> arguments) async {
  if (arguments.length != 2 ||
      (arguments.first != 'native' && arguments.first != 'vertex')) {
    throw ArgumentError(
      'Usage: google_cloud_example.dart native|vertex model-id',
    );
  }
  final environment = Platform.environment;
  final accessToken = environment['GOOGLE_OAUTH_ACCESS_TOKEN'];
  if (accessToken == null || accessToken.isEmpty) {
    throw StateError('Set GOOGLE_OAUTH_ACCESS_TOKEN to a Google access token');
  }
  final AnthropicClient client = switch (arguments.first) {
    'native' => AnthropicGoogleCloudClient(accessToken: accessToken),
    _ => AnthropicVertexClient(
      projectId: environment['GOOGLE_CLOUD_PROJECT'],
      region: environment['CLOUD_ML_REGION'] ?? 'global',
      accessToken: accessToken,
    ),
  };
  try {
    final message = await client.messages.create(
      MessageCreateRequest(
        model: arguments.last,
        maxTokens: 128,
        messages: [InputMessage.user('What is a cursor in an API?')],
      ),
    );
    for (final block in message.content.whereType<TextBlock>()) {
      stdout.writeln(block.text);
    }
  } finally {
    client.close();
  }
}
