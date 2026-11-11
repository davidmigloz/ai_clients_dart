// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Configures server-side context editing and previews the token count.
///
/// Run with ANTHROPIC_API_KEY set in the environment.
Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();
  const betas = ['context-management-2025-06-27'];
  try {
    final request = MessageCreateRequest(
      model: 'claude-sonnet-5-5',
      maxTokens: 256,
      messages: [InputMessage.user('Explain why tool results accumulate.')],
      contextManagement: const ContextManagementConfig(
        edits: [
          ContextManagementEdit.clearToolUses(
            trigger: ContextEditTrigger.inputTokens(100000),
            keepToolUses: 3,
          ),
        ],
      ),
    );
    final count = await client.messages.countTokens(
      TokenCountRequest.fromMessageCreateRequest(request),
      betas: betas,
    );
    print('Input tokens: ${count.inputTokens}');
    final original = count.contextManagement?.originalInputTokens;
    if (original != null) print('Input tokens before editing: $original');

    final reply = await client.messages.create(request, betas: betas);
    reply.contextManagement?.appliedEdits.forEach(print);
    print(reply.text);
  } finally {
    client.close();
  }
}
