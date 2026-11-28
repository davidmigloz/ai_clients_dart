// ignore_for_file: avoid_print
/// Streams a raw PCM clip to the Gemini Developer API and displays captions.
///
/// Set GOOGLE_GENAI_API_KEY and run:
/// dart run example/live_transcription_example.dart speech.pcm
library;

import 'dart:io' as io;
import 'dart:math' as math;

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    io.stderr.writeln(
      'Usage: dart run example/live_transcription_example.dart '
      '<16-kHz 16-bit mono little-endian PCM file>',
    );
    io.exitCode = 64;
    return;
  }

  final pcm = await io.File(args.single).readAsBytes();
  if (pcm.isEmpty || pcm.length.isOdd) {
    io.stderr.writeln('Supply nonempty, 16-bit raw PCM audio.');
    io.exitCode = 65;
    return;
  }

  final client = GoogleAIClient.fromEnvironment(apiVersion: ApiVersion.v1beta);
  final live = client.createLiveClient();
  try {
    final session = await live.connect(
      model: 'gemini-3.5-transcribe-live',
      liveConfig: LiveConfig(
        generationConfig: LiveGenerationConfig.textOnly(),
        inputAudioTranscription: const AudioTranscriptionConfig(),
        realtimeInputConfig: RealtimeInputConfig.manual(
          interimTranscriptTimestampEnabled: true,
        ),
      ),
    );

    final transcript = session.messages.firstWhere((message) {
      if (message is! BidiGenerateContentServerContent) return false;
      final interim = message.interimInputTranscription;
      if (interim?.text case final preview?) {
        print(
          'Interim (${interim?.endOffset ?? 'offset unavailable'}): $preview',
        );
      }
      return message.inputTranscription != null;
    });

    const chunkSize = 3200; // 100 ms at 16 kHz, 16 bits per sample.
    session.signalActivityStart();
    for (var start = 0; start < pcm.length; start += chunkSize) {
      session.sendAudio(
        pcm.sublist(start, math.min(start + chunkSize, pcm.length)),
      );
    }
    session.signalActivityEnd();

    final finalMessage = await transcript.timeout(const Duration(seconds: 30));
    final finalized =
        (finalMessage as BidiGenerateContentServerContent).inputTranscription;
    print('Final: ${finalized?.text ?? ''}');
  } finally {
    await live.close();
    client.close();
  }
}
