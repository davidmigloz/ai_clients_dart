import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Asks Claude to cite text from two explicitly supplied document chunks.
///
/// Set ANTHROPIC_API_KEY before running the example.
Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();
  try {
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 512,
        messages: [
          InputMessage.userBlocks([
            InputContentBlock.document(
              DocumentSource.contentBlocks(const [
                TextInputBlock('Monday hours are 09:00 to 17:00.'),
                TextInputBlock('Saturday hours are 10:00 to 13:00.'),
              ]),
              title: 'Library opening hours',
              citations: const RequestCitationsConfig(enabled: true),
            ),
            InputContentBlock.text('When does the library close on Saturday?'),
          ]),
        ],
      ),
    );
    stdout.writeln(response.text);
    for (final text in response.content.whereType<TextBlock>()) {
      for (final citation in text.citations ?? const <Citation>[]) {
        if (citation case ContentBlockLocationCitation(
          :final startBlockIndex,
        )) {
          stdout.writeln('Cited content block $startBlockIndex');
        }
      }
    }
  } finally {
    client.close();
  }
}
