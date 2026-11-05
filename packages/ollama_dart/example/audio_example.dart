// ignore_for_file: avoid_print
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

/// Generates speech, transcribes audio, or translates audio into text.
///
/// Pull a compatible model first. For speech, run `ollama pull phonon`.
///
/// ```sh
/// dart run example/audio_example.dart [TEXT] [VOICE]
/// dart run example/audio_example.dart --transcribe FILE.wav MODEL [LANGUAGE]
/// dart run example/audio_example.dart --translate FILE.wav MODEL [TO_LANGUAGE] [SOURCE_LANGUAGE]
/// ```
Future<void> main(List<String> args) async {
  final transcribe = args.isNotEmpty && args[0] == '--transcribe';
  final translate = args.isNotEmpty && args[0] == '--translate';
  if ((transcribe || translate) && args.length < 3) {
    stderr.writeln(
      'Usage: dart run example/audio_example.dart '
      '${args[0]} FILE.wav MODEL [LANGUAGE]',
    );
    exitCode = 64;
    return;
  }

  final client = OllamaClient.fromEnvironment();
  try {
    if (transcribe || translate) {
      final file = File(args[1]);
      final audio = AudioFile(
        bytes: await file.readAsBytes(),
        filename: file.uri.pathSegments.last,
      );
      final result = translate
          ? await client.audio.createTranslation(
              request: TranslationRequest(
                model: args[2],
                file: audio,
                toLanguage: args.length > 3 ? args[3] : null,
                language: args.length > 4 ? args[4] : null,
              ),
            )
          : await client.audio.createTranscription(
              request: TranscriptionRequest(
                model: args[2],
                file: audio,
                language: args.length > 3 ? args[3] : null,
                responseFormat: AudioTextResponseFormat.verboseJson,
              ),
            );
      print(result.text);
    } else {
      final output = File('speech.wav').openWrite();
      try {
        await output.addStream(
          client.audio.createSpeechStream(
            request: SpeechRequest(
              model: 'phonon',
              input: args.isEmpty ? 'Hello from Ollama.' : args[0],
              voice: args.length > 1 ? args[1] : null,
              responseFormat: SpeechResponseFormat.wav,
            ),
          ),
        );
        print('Saved speech.wav');
      } finally {
        await output.close();
      }
    }
  } finally {
    client.close();
  }
}
