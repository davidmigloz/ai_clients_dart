// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

const _transcriptionModel = 'voxtral-mini-transcribe-realtime-3-0';
const _speechModel = 'voxtral-mini-tts-3-0';

/// Streams audio using Voxtral 3 realtime WebSockets.
Future<void> main(List<String> args) async {
  if (args.isEmpty || args.contains('--help')) {
    print('''
Usage
  dart run example/realtime_audio_example.dart transcribe input.pcm
  dart run example/realtime_audio_example.dart speak VOICE_ID output.pcm
  dart run example/realtime_audio_example.dart session

Set MISTRAL_API_KEY before calling the API.
Input PCM is raw 16 kHz signed 16-bit little-endian mono.
Speech output is raw float32 little-endian mono.
Voxtral 3 realtime models are in Public Preview.
''');
    return;
  }

  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('Set MISTRAL_API_KEY before calling the API.');
    exitCode = 1;
    return;
  }

  final client = MistralClient.withApiKey(apiKey);
  try {
    switch (args) {
      case ['transcribe', final input]:
        await _transcribe(client, input);
      case ['speak', final voiceId, final output]:
        await _speak(client, voiceId, output);
      case ['session']:
        final session = await client.realtime.sessions.create(
          request: const CreateRealtimeClientSessionRequest(
            model: _transcriptionModel,
          ),
        );
        // Return session.clientSecret.value from your authenticated backend.
        print('The credential expires at ${session.clientSecret.expiresAt}.');
      default:
        stderr.writeln('Unknown command. Run with --help for usage.');
        exitCode = 1;
    }
  } finally {
    client.close();
  }
}

Future<void> _transcribe(MistralClient client, String input) async {
  final events = client.audio.realtime.transcribeStream(
    model: _transcriptionModel,
    audio: _pcmFrames(File(input)),
    options: const RealtimeTranscriptionOptions(
      audioFormat: RealtimeAudioFormat(
        encoding: RealtimeAudioEncoding.pcmS16le,
        sampleRate: 16000,
      ),
      contextBias: ['Voxtral'],
    ),
  );
  await for (final event in events) {
    if (event.type == 'transcription.text.delta') {
      stdout.write(event.text ?? '');
    } else if (event.isDone) {
      stdout.writeln();
    }
  }
}

Stream<List<int>> _pcmFrames(File file) async* {
  final input = await file.open();
  try {
    while (true) {
      // 100ms of 16 kHz mono audio, at two bytes per sample.
      final frame = await input.read(3200);
      if (frame.isEmpty) break;
      yield frame;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  } finally {
    await input.close();
  }
}

Future<void> _speak(MistralClient client, String voiceId, String path) async {
  final output = File(path).openWrite();
  try {
    final events = client.audio.realtimeSpeech.speakStream(
      model: _speechModel,
      text: Stream.fromIterable([
        'Hello from Voxtral. ',
        'This is live audio.',
      ]),
      options: RealtimeSpeechOptions(
        voiceId: voiceId,
        responseFormat: SpeechOutputFormat.pcm,
        streamingMode: RealtimeSpeechMode.responsive,
      ),
    );
    await for (final event in events) {
      if (event case SpeechStreamAudioDelta(:final audioData)) {
        output.add(base64Decode(audioData));
      }
    }
  } finally {
    await output.close();
  }
}
