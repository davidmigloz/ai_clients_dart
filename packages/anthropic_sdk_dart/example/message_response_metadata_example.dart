import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Reads the provider's diagnostic identifiers on a successful Messages call.
///
/// Set ANTHROPIC_API_KEY in your environment.
Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();
  try {
    final response = await client.messages.createWithResponse(
      MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 128,
        messages: [InputMessage.user('Give one tip for writing Dart tests.')],
      ),
    );
    stdout
      ..writeln(response.message.text)
      ..writeln('HTTP ${response.statusCode}');
    if (response.requestId case final String requestId) {
      stdout.writeln('Request ID: $requestId');
    }
    if (response.workspaceId case final String workspaceId) {
      stdout.writeln('Workspace ID: $workspaceId');
    }
    if (response.awsRequestId case final String requestId) {
      stdout.writeln('AWS request ID: $requestId');
    }
    if (response.azureRequestId case final String requestId) {
      stdout.writeln('Azure request ID: $requestId');
    }
  } finally {
    client.close();
  }
}
