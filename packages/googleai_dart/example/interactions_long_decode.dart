import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

/// Runs a foreground Gemini 4 interaction with automatic continuation enabled.
Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Set GOOGLE_GENAI_API_KEY and pass a prompt to '
      'dart run example/interactions_long_decode.dart.',
    );
    return;
  }

  final client = GoogleAIClient.fromEnvironment(
    interactionsApiVersion: ApiVersion.v1,
    timeout: const Duration(minutes: 20),
  );
  try {
    final interaction = await client.interactions.create(
      model: 'gemini-4-neon',
      input: InteractionInput.text(args.join(' ')),
      generationConfig: const InteractionGenerationConfig(
        maxOutputTokens: 131072,
      ),
      automaticContinuation: true,
    );
    stdout.writeln(interaction.outputText ?? '');
    stderr
      ..writeln('Status: ${interaction.status.toJson()}')
      ..writeln('Input tokens: ${interaction.usage?.initialInputTokens}')
      ..writeln('Total tokens: ${interaction.usage?.totalTokens}');
  } finally {
    client.close();
  }
}
