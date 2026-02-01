// ignore_for_file: avoid_print
/// Example demonstrating audio capabilities with OpenAI.
///
/// This example shows text-to-speech and speech-to-text operations.
/// Run with: dart run example/audio_example.dart
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  // Create client from environment variable
  final client = OpenAIClient.fromEnvironment();

  try {
    // Text-to-Speech
    print('=== Text-to-Speech ===\n');

    final audioBytes = await client.audio.speech.create(
      const SpeechRequest(
        model: 'gpt-4o-mini-tts',
        input: 'Hello! This is a demonstration of OpenAI text-to-speech.',
        voice: SpeechVoice.alloy,
      ),
    );

    print('Generated ${audioBytes.length} bytes of audio');

    // Save to file
    final outputFile = File('output_speech.mp3');
    await outputFile.writeAsBytes(audioBytes);
    print('Saved to ${outputFile.path}\n');

    // Text-to-Speech with different voices
    print('=== Different Voices ===\n');

    for (final voice in [SpeechVoice.nova, SpeechVoice.shimmer]) {
      final bytes = await client.audio.speech.create(
        SpeechRequest(
          model: 'gpt-4o-mini-tts',
          input: 'Hello from ${voice.name}!',
          voice: voice,
        ),
      );

      final file = File('output_${voice.name}.mp3');
      await file.writeAsBytes(bytes);
      print('Saved ${voice.name} voice to ${file.path}');
    }
    print('');

    // Text-to-Speech with HD quality
    print('=== HD Quality ===\n');

    final hdBytes = await client.audio.speech.create(
      const SpeechRequest(
        model: 'gpt-4o-mini-tts',
        input: 'This is high definition audio quality.',
        voice: SpeechVoice.onyx,
      ),
    );

    final hdFile = File('output_hd.mp3');
    await hdFile.writeAsBytes(hdBytes);
    print('Saved HD audio to ${hdFile.path}\n');

    // Text-to-Speech with speed adjustment
    print('=== Speed Adjustment ===\n');

    final fastBytes = await client.audio.speech.create(
      const SpeechRequest(
        model: 'gpt-4o-mini-tts',
        input: 'This is fast speech.',
        voice: SpeechVoice.alloy,
        speed: 1.5,
      ),
    );

    final fastFile = File('output_fast.mp3');
    await fastFile.writeAsBytes(fastBytes);
    print('Saved fast speech to ${fastFile.path}\n');

    // Speech-to-Text (Transcription)
    print('=== Speech-to-Text (Transcription) ===\n');

    // Transcribe the audio we just generated
    final transcription = await client.audio.transcriptions.create(
      TranscriptionRequest(
        file: audioBytes,
        filename: 'speech.mp3',
        model: 'gpt-4o-mini-transcribe',
      ),
    );

    print('Transcription: ${transcription.text}\n');

    // Transcription with verbose output
    print('=== Verbose Transcription ===\n');

    final verboseTranscription = await client.audio.transcriptions
        .createVerbose(
          TranscriptionRequest(
            file: audioBytes,
            filename: 'speech.mp3',
            model: 'gpt-4o-mini-transcribe',
          ),
        );

    print('Text: ${verboseTranscription.text}');
    print('Language: ${verboseTranscription.language}');
    print('Duration: ${verboseTranscription.duration} seconds');

    if (verboseTranscription.segments case final segments?) {
      print('Segments:');
      for (final segment in segments) {
        print('  [${segment.start}s - ${segment.end}s] ${segment.text}');
      }
    }
    print('');

    // Different audio formats
    print('=== Different Output Formats ===\n');

    final opusBytes = await client.audio.speech.create(
      const SpeechRequest(
        model: 'gpt-4o-mini-tts',
        input: 'Testing opus format.',
        voice: SpeechVoice.alloy,
        responseFormat: SpeechResponseFormat.opus,
      ),
    );

    final opusFile = File('output_format.opus');
    await opusFile.writeAsBytes(opusBytes);
    print('Saved opus audio to ${opusFile.path}\n');

    print('Done! Generated audio files in current directory.');
  } on OpenAIException catch (e) {
    print('OpenAI error: ${e.message}');
    if (e is ApiException) {
      print('Status: ${e.statusCode}');
    }
    exit(1);
  } finally {
    client.close();
  }
}
