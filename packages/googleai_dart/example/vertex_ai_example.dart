// ignore_for_file: avoid_print
/// Generates text with Gemini 3.8 Flash in the Vertex AI US multi-region.
///
/// Set GOOGLE_CLOUD_PROJECT and GOOGLE_CLOUD_ACCESS_TOKEN. Set
/// GOOGLE_CLOUD_LOCATION to use another location that supports the model.
///
/// Model availability:
/// https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/gemini/3-8-flash
library;

import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final project = Platform.environment['GOOGLE_CLOUD_PROJECT'];
  final token = Platform.environment['GOOGLE_CLOUD_ACCESS_TOKEN'];
  if (project == null || project.isEmpty || token == null || token.isEmpty) {
    print(
      'Set GOOGLE_CLOUD_PROJECT and GOOGLE_CLOUD_ACCESS_TOKEN to run this example.',
    );
    return;
  }

  final client = GoogleAIClient(
    config: GoogleAIConfig.vertexAI(
      projectId: project,
      location: Platform.environment['GOOGLE_CLOUD_LOCATION'] ?? 'us',
      apiVersion: ApiVersion.v1,
      authProvider: BearerTokenProvider(token),
    ),
  );
  try {
    final response = await client.models.generateContent(
      model: 'gemini-3.8-flash',
      request: GenerateContentRequest(
        contents: [Content.text('Explain Dart streams in two sentences.')],
      ),
    );
    final text = response.text;
    if (text != null) print(text);
  } finally {
    client.close();
  }
}
