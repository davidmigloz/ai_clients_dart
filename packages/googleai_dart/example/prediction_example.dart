import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

/// Starts a Vertex AI Veo prediction with request labels.
Future<void> main(List<String> args) async {
  final environment = Platform.environment;
  final project = environment['GOOGLE_CLOUD_PROJECT'];
  final token = environment['GOOGLE_CLOUD_ACCESS_TOKEN'];
  final safetyIdentifier = environment['GOOGLE_CLOUD_SAFETY_IDENTIFIER'];
  if (project == null ||
      token == null ||
      safetyIdentifier == null ||
      args.isEmpty) {
    stderr.writeln(
      'Set GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_ACCESS_TOKEN, and '
      'GOOGLE_CLOUD_SAFETY_IDENTIFIER, then pass a text prompt to '
      'dart run example/prediction_example.dart. Use an anonymized identifier.',
    );
    return;
  }

  final client = GoogleAIClient(
    config: GoogleAIConfig.vertexAI(
      projectId: project,
      location: environment['GOOGLE_CLOUD_LOCATION'] ?? 'us-central1',
      authProvider: BearerTokenProvider(token),
    ),
  );
  try {
    final operation = await client.models.predictLongRunning(
      model: 'veo-3.1-generate-001',
      instances: [
        {'prompt': args.join(' ')},
      ],
      parameters: {'aspectRatio': '16:9', 'sampleCount': 1},
      labels: {'safety_identifier': safetyIdentifier},
    );
    stdout.writeln(operation.name);
  } finally {
    client.close();
  }
}
