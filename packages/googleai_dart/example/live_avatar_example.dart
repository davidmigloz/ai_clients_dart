import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

/// Requests video from a prebuilt Vertex AI Live avatar.
Future<void> main() async {
  final environment = Platform.environment;
  final project = environment['GOOGLE_CLOUD_PROJECT'];
  final location = environment['GOOGLE_CLOUD_LOCATION'];
  final token = environment['GOOGLE_CLOUD_ACCESS_TOKEN'];
  if (project == null || location == null || token == null) {
    stderr.writeln(
      'Set GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_LOCATION, and '
      'GOOGLE_CLOUD_ACCESS_TOKEN for a Vertex AI project.',
    );
    return;
  }

  final client = GoogleAIClient(
    config: GoogleAIConfig.vertexAI(
      projectId: project,
      location: location,
      authProvider: BearerTokenProvider(token),
    ).copyWith(apiVersion: ApiVersion.v1),
  );
  final live = client.createLiveClient();
  try {
    final session = await live.connect(
      model: 'gemini-3.8-live',
      liveConfig: LiveConfig(
        avatarConfig: const LiveAvatarConfig(avatarName: 'Ben'),
        generationConfig: LiveGenerationConfig(
          responseModalities: const [ResponseModality.video],
          speechConfig: SpeechConfig.withVoice(LiveVoices.puck),
        ),
      ),
    );
    session.send(
      const BidiGenerateContentRealtimeInput(
        text: 'Say hello in one sentence.',
      ),
    );

    await for (final message in session.messages.timeout(
      const Duration(seconds: 30),
    )) {
      if (message is! BidiGenerateContentServerContent) continue;
      for (final part in message.modelTurn?.parts ?? const <Part>[]) {
        if (part case InlineDataPart(
          :final inlineData,
        ) when inlineData.mimeType == 'video/mp4') {
          stdout.writeln(
            'Received ${inlineData.toBytes().length} bytes of MP4 data.',
          );
        }
      }
      if (message.turnComplete ?? false) break;
    }
  } finally {
    await live.close();
    client.close();
  }
}
