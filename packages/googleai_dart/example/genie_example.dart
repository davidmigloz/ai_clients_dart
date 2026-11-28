// ignore_for_file: avoid_print

import 'package:googleai_dart/googleai_dart.dart';

/// Run with a paid-tier Gemini Developer API key. This opens a billed session.
Future<void> main() async {
  final client = GoogleAIClient.fromEnvironment();
  try {
    final genie = client.interactions.genie;
    final interaction = await genie.create();
    final session = await genie.connect(interaction.id);
    try {
      session.send(
        const GenieWorldSetup(
          prompt: 'A wooden boardwalk winds through a sunny coastal village.',
        ),
      );
      var frames = 0;
      await for (final event in session.receive()) {
        if (event case GenieStepEvent(
          step: StepDeltaEvent(delta: VideoDelta()),
        )) {
          print('JPEG frame ${++frames}: ${event.mediaBytes?.length} bytes');
          // An interactive client could send movement or text here.
          if (frames == 4) await session.complete();
        } else if (event case GenieErrorEvent(:final error)) {
          throw StateError(error?.message ?? 'Genie reported a server error.');
        }
      }
    } catch (_) {
      try {
        await session.cancel();
      } on GenieConnectionException {
        // The socket is already unavailable.
      }
      rethrow;
    } finally {
      await session.detach();
    }
  } finally {
    client.close();
  }
}
