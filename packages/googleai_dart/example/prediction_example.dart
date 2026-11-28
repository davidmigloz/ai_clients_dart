import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

/// Starts and polls a Vertex AI Veo prediction with request labels.
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
    var operation = await client.models.predictLongRunning(
      model: 'veo-3.1-generate-001',
      instances: [
        {'prompt': args.join(' ')},
      ],
      parameters: {'aspectRatio': '16:9', 'sampleCount': 1},
      labels: {'safety_identifier': safetyIdentifier},
    );
    while (!operation.done) {
      final name = operation.name;
      if (name == null) {
        throw StateError('No operation name returned by Vertex AI.');
      }
      await Future<void>.delayed(const Duration(seconds: 15));
      operation = await client.models.fetchPredictOperation(
        operationName: name,
      );
    }
    if (operation.error case final error?) {
      stderr.writeln(error.message);
      exitCode = 1;
      return;
    }
    if (operation.response case final response?) {
      for (final video in response.videos ?? const <Video>[]) {
        stdout.writeln(
          video.uri ?? 'Received inline ${video.mimeType ?? 'video'}.',
        );
      }
    }
  } finally {
    client.close();
  }
}
