// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

const _transcriptionModel = 'voxtral-mini-transcribe-3-0';
const _speechModel = 'voxtral-mini-tts-3-0';

/// Run an audio example against the API with your own credentials.
Future<void> main(List<String> args) async {
  if (args.isEmpty || args.contains('--help')) {
    print('''
Usage
  dart run example/audio_example.dart transcribe recording.wav
  dart run example/audio_example.dart stream recording.wav
  dart run example/audio_example.dart voices
  dart run example/audio_example.dart sample VOICE_ID sample.wav
  dart run example/audio_example.dart speech VOICE_ID output.wav

Set MISTRAL_API_KEY before calling the API.
Transcription and speech use Voxtral 3 Public Preview models.
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
      case ['transcribe', final path]:
        await _transcribe(client, path);
      case ['stream', final path]:
        await _streamTranscription(client, path);
      case ['voices']:
        await _listVoices(client);
      case ['sample', final voiceId, final output]:
        final bytes = await client.audio.voices.getSampleAudio(
          voiceId: voiceId,
        );
        await File(output).writeAsBytes(bytes);
        print('Saved the voice sample to $output.');
      case ['speech', final voiceId, final output]:
        await _generateSpeech(client, voiceId, output);
      default:
        stderr.writeln('Unknown command. Run with --help for usage.');
        exitCode = 1;
    }
  } finally {
    client.close();
  }
}

Future<TranscriptionRequest> _transcriptionRequest(String path) async =>
    TranscriptionRequest(
      model: _transcriptionModel,
      fileName: File(path).uri.pathSegments.last,
      fileBytes: await File(path).readAsBytes(),
      diarize: true,
      timestampGranularityOptions: const [
        TranscriptionTimestampGranularity.segment,
      ],
      contextBias: const ['Mistral', 'Voxtral'],
    );

Future<void> _transcribe(MistralClient client, String path) async {
  final response = await client.audio.transcriptions.create(
    request: await _transcriptionRequest(path),
  );
  print(response.text);
  for (final segment in response.segments ?? const <TranscriptionSegment>[]) {
    print(
      '  ${segment.start ?? '?'}–${segment.end ?? '?'}s '
      '${segment.speakerId ?? 'speaker'}: ${segment.text}',
    );
  }
}

Future<void> _streamTranscription(MistralClient client, String path) async {
  final stream = client.audio.transcriptions.createStream(
    request: await _transcriptionRequest(path),
  );
  await for (final event in stream) {
    if (event.type == 'transcription.text.delta') {
      stdout.write(event.text ?? '');
    } else if (event.isDone) {
      stdout.writeln();
    }
  }
}

Future<void> _listVoices(MistralClient client) async {
  final page = await client.audio.voices.search(pageSize: 10, type: 'preset');
  for (final voice in page.data) {
    print('${voice.name}: ${voice.id} (${voice.kind?.value ?? 'unknown'})');
  }

  if (page.nextPageToken case final cursor?) {
    final next = await client.audio.voices.search(
      pageSize: 10,
      pageToken: cursor,
      type: 'preset',
    );
    for (final voice in next.data) {
      print('${voice.name}: ${voice.id} (${voice.kind?.value ?? 'unknown'})');
    }
  }
}

Future<void> _generateSpeech(
  MistralClient client,
  String voiceId,
  String output,
) async {
  final response = await client.audio.speech.create(
    request: SpeechRequest(
      model: _speechModel,
      voiceId: voiceId,
      input: 'Hello from the Dart Mistral client.',
      responseFormat: SpeechOutputFormat.wav,
      expressiveness: 1.5,
    ),
  );
  await File(output).writeAsBytes(base64Decode(response.audioData));
  print('Saved speech to $output.');
}
