// ignore_for_file: avoid_print

/// Creates a Vertex AI model interaction using Google Cloud OAuth.
library;

import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final project = Platform.environment['GOOGLE_CLOUD_PROJECT'];
  final accessToken = Platform.environment['GOOGLE_CLOUD_ACCESS_TOKEN'];
  if (project == null || accessToken == null) {
    throw StateError(
      'Set GOOGLE_CLOUD_PROJECT and GOOGLE_CLOUD_ACCESS_TOKEN first.',
    );
  }

  final client = GoogleAIClient(
    config: GoogleAIConfig.vertexAI(
      projectId: project,
      location: 'global',
      authProvider: BearerTokenProvider(accessToken),
    ),
  );

  try {
    final interaction = await client.interactions.create(
      model: 'gemini-3.8-flash',
      input: const InteractionInput.text('Explain serverless computing.'),
      store: true,
    );
    print(interaction.outputText);

    final recent = await client.interactions.list(pageSize: 5);
    for (final metadata
        in recent.interactionMetadatas ?? const <InteractionMetadata>[]) {
      print(metadata.id);
    }
  } finally {
    client.close();
  }
}
