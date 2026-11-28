import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

/// Streams GenerateContent output from a supported Gemini 4 model.
Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Set GOOGLE_GENAI_API_KEY and pass a prompt to '
      'dart run example/generate_content_long_decode.dart.',
    );
    return;
  }

  final client = GoogleAIClient.fromEnvironment(
    apiVersion: ApiVersion.v1beta,
    timeout: const Duration(minutes: 20),
  );
  try {
    UsageMetadata? usage;
    await for (final chunk in client.models.streamGenerateContent(
      model: 'gemini-4-hydrogen',
      request: GenerateContentRequest(
        contents: [Content.text(args.join(' '))],
        generationConfig: const GenerationConfig(maxOutputTokens: 120000),
      ),
      automaticContinuation: true,
    )) {
      stdout.write(chunk.text ?? '');
      usage = chunk.usageMetadata ?? usage;
    }
    stdout.writeln();
    stderr
      ..writeln('Initial prompt tokens: ${usage?.initialPromptTokenCount}')
      ..writeln('Total tokens: ${usage?.totalTokenCount}');
  } finally {
    client.close();
  }
}
