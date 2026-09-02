// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Mid-conversation system message example.
///
/// This example demonstrates:
/// - Injecting updated system instructions partway through a conversation
///   via a `role: "system"` message ([InputMessage.system]) placed inside
///   the messages array, instead of a separate user turn or the top-level
///   `system` prompt.
/// - A turn-scoped reminder that renders for only the next model turn via
///   [SystemMessageClearAt.nextUserMessage], and must be re-sent verbatim
///   on later requests.
/// - An effort-only system message ([InputMessage.systemEffort]) that
///   changes the response effort from the next user turn on, without
///   carrying any content.
///
/// Mid-conversation system messages, the turn-scoped `clear_at`, and
/// per-message effort are supported on Claude Opus 4.8 and later Opus/Fable
/// models — not on Sonnet 5, so this example targets `claude-opus-5`.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // A content-carrying system message must follow a user turn / tool_result
    // turn and precede an assistant turn.
    final firstMessages = [
      InputMessage.user('What is the capital of France?'),
      InputMessage.assistant('The capital of France is Paris.'),
      InputMessage.user('And what is its population?'),
      // Update the system instructions mid-conversation, then ask a
      // follow-up — all within the messages array.
      InputMessage.system('From now on, always answer in French.'),
    ];

    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-opus-5',
        maxTokens: 1024,
        system: SystemPrompt.text(
          'You are a helpful assistant. Answer concisely.',
        ),
        messages: firstMessages,
      ),
    );

    print('=== Mid-conversation system instruction ===');
    for (final block in response.content) {
      if (block case TextBlock(:final text)) {
        print(text);
      }
    }

    // A turn-scoped reminder renders only for the user turn it follows: once
    // a later user message exists, the API stops showing it to the model,
    // but it must still be re-sent verbatim on every later request.
    print('\n=== Turn-scoped system reminder ===');
    const clearAtReminder = 'Keep this next answer under 20 words.';
    final reminderMessages = [
      ...firstMessages,
      response.toInputMessage(),
      InputMessage.user('Tell me about the Eiffel Tower.'),
      InputMessage.system(
        clearAtReminder,
        clearAt: SystemMessageClearAt.nextUserMessage,
      ),
    ];

    final reminderResponse = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-opus-5',
        maxTokens: 1024,
        system: SystemPrompt.text(
          'You are a helpful assistant. Answer concisely.',
        ),
        messages: reminderMessages,
      ),
      betas: ['mid-conversation-system-clear-at-2026-08-21'],
    );
    print(reminderResponse.text);

    // On the next turn the reminder is still sent verbatim — it now renders
    // as cleared (no longer shown to the model, no input tokens charged) —
    // but the message itself stays in `messages`.
    print('\n=== Next turn (reminder now cleared) ===');
    final nextTurnResponse = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-opus-5',
        maxTokens: 1024,
        system: SystemPrompt.text(
          'You are a helpful assistant. Answer concisely.',
        ),
        messages: [
          ...reminderMessages,
          reminderResponse.toInputMessage(),
          InputMessage.user('What about the Louvre?'),
        ],
      ),
      betas: ['mid-conversation-system-clear-at-2026-08-21'],
    );
    print(nextTurnResponse.text);

    // An effort-only system message is accepted anywhere in `messages` and
    // changes the response effort from the next user turn on, without
    // carrying any content of its own.
    print('\n=== Effort-only system message ===');
    final effortResponse = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-opus-5',
        maxTokens: 1024,
        messages: [
          InputMessage.systemEffort(EffortLevel.low),
          InputMessage.user('Summarize the plot of Hamlet in one sentence.'),
        ],
      ),
      betas: ['mid-conversation-output-config-2026-07-01'],
    );
    print(effortResponse.text);

    // Output token breakdown (e.g. reasoning tokens) is available via the
    // `outputTokensDetails` field on usage.
    final details = response.usage.outputTokensDetails;
    print('\nUsage:');
    print('  Output tokens: ${response.usage.outputTokens}');
    if (details != null) {
      print('  Thinking tokens: ${details.thinkingTokens}');
    }
  } finally {
    client.close();
  }
}
