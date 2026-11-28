// ignore_for_file: avoid_print
/// Creates a Gemini managed-agent credential and retrieves its metadata.
library;

import 'dart:io' show Platform;

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  final apiKey = Platform.environment['GOOGLE_GENAI_API_KEY'];
  final token = Platform.environment['AGENT_BEARER_TOKEN'];
  if (apiKey == null || apiKey.isEmpty || token == null || token.isEmpty) {
    throw StateError('Set GOOGLE_GENAI_API_KEY and AGENT_BEARER_TOKEN.');
  }
  final client = GoogleAIClient(
    config: GoogleAIConfig.googleAI(
      apiVersion: ApiVersion.v1beta,
      authProvider: ApiKeyProvider(apiKey, placement: AuthPlacement.header),
    ),
  );

  try {
    final credential = await client.credentials.create(
      credential: HttpBearerConfig(id: 'deployment-token', token: token),
    );
    final metadata = await client.credentials.get(credential.id);
    print('Credential ${metadata.id} (${metadata.type.name})');
  } finally {
    client.close();
  }
}
