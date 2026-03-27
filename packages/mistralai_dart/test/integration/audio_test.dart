// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io' as io;

import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

import 'test_config.dart';

/// Resolves the test samples directory.
///
/// Tests may run from the workspace root or the package directory,
/// so we check both known locations.
String _resolveSamplesDir() {
  const candidates = [
    'packages/mistralai_dart/test/samples', // workspace root
    'test/samples', // package root
  ];
  for (final path in candidates) {
    if (io.Directory(path).existsSync()) return path;
  }
  throw StateError(
    'Cannot find test/samples directory. '
    'Run tests from the workspace root or the package directory.',
  );
}

/// Integration tests for TTS (Text-to-Speech) and voice management.
///
/// These tests require a real API key set in the MISTRAL_API_KEY
/// environment variable. If the key is not present, all tests are skipped.
void main() {
  late String samplesDir;
  MistralClient? client;

  setUpAll(() {
    samplesDir = _resolveSamplesDir();

    final apiKey = io.Platform.environment[apiKeyEnvVar];
    if (apiKey == null || apiKey.isEmpty) {
      print(
        '⚠️  $apiKeyEnvVar not set. Integration tests will be skipped.\n'
        '   To run these tests, export $apiKeyEnvVar=your_api_key',
      );
    } else {
      client = MistralClient.withApiKey(apiKey);
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('TTS - Text-to-Speech', () {
    late String refAudioB64;

    setUpAll(() {
      final wavBytes = io.File('$samplesDir/harvard.wav').readAsBytesSync();
      refAudioB64 = base64Encode(wavBytes);
    });

    test(
      'generates speech from text',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (client == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.audio.speech.create(
          request: SpeechRequest(
            model: defaultTtsModel,
            input: 'Hello, this is a test of Voxtral text-to-speech.',
            refAudio: refAudioB64,
          ),
        );

        expect(response.audioData, isNotEmpty);
      },
    );

    test(
      'generates speech in WAV format',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (client == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.audio.speech.create(
          request: SpeechRequest(
            model: defaultTtsModel,
            input: 'The quick brown fox jumps over the lazy dog.',
            refAudio: refAudioB64,
            responseFormat: SpeechOutputFormat.wav,
          ),
        );

        expect(response.audioData, isNotEmpty);

        // Decode and validate WAV header.
        final audioBytes = base64Decode(response.audioData);
        expect(audioBytes.length, greaterThan(12));
        final riffHeader = String.fromCharCodes(audioBytes.sublist(0, 4));
        expect(riffHeader, equals('RIFF'));
        final waveHeader = String.fromCharCodes(audioBytes.sublist(8, 12));
        expect(waveHeader, equals('WAVE'));
      },
    );

    test(
      'streams speech from text',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (client == null) {
          markTestSkipped('API key not available');
          return;
        }

        final stream = client!.audio.speech.createStream(
          request: SpeechRequest(
            model: defaultTtsModel,
            input: 'Streaming makes voice agents feel more responsive.',
            refAudio: refAudioB64,
            responseFormat: SpeechOutputFormat.pcm,
          ),
        );

        final events = await stream.toList();

        final deltas = events.whereType<SpeechStreamAudioDelta>().toList();
        expect(deltas, isNotEmpty, reason: 'Expected audio delta events');
        for (final delta in deltas) {
          expect(delta.audioData, isNotEmpty);
        }

        final doneEvents = events.whereType<SpeechStreamDone>().toList();
        expect(doneEvents, hasLength(1), reason: 'Expected one done event');
      },
    );
  });

  group('Voices', () {
    test(
      'lists available voices',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (client == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.audio.voices.list();

        expect(response, isA<VoiceListResponse>());
        expect(response.total, greaterThanOrEqualTo(0));
        expect(response.total, greaterThanOrEqualTo(response.items.length));

        // Validate key fields on any returned voices.
        for (final voice in response.items) {
          expect(voice.id, isNotEmpty);
          expect(voice.name, isNotEmpty);
        }
      },
    );
  });
}
