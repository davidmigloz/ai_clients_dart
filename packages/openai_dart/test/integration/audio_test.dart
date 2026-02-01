// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  OpenAIClient? client;

  setUpAll(() {
    apiKey = Platform.environment['OPENAI_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('OPENAI_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = OpenAIClient(
        config: OpenAIConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Audio TTS - Integration', () {
    test(
      'creates speech from text',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final audioBytes = await client!.audio.speech.create(
          const SpeechRequest(
            model: 'tts-1',
            input: 'Hello, this is a test.',
            voice: SpeechVoice.alloy,
          ),
        );

        expect(audioBytes, isNotEmpty);
        // MP3 files typically start with ID3 or 0xFF
        expect(audioBytes.length, greaterThan(1000));
      },
    );

    test(
      'creates speech with different voices',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Test with nova voice
        final audioBytes = await client!.audio.speech.create(
          const SpeechRequest(
            model: 'tts-1',
            input: 'Testing voice options.',
            voice: SpeechVoice.nova,
          ),
        );

        expect(audioBytes, isNotEmpty);
      },
    );

    test(
      'creates speech with different formats',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Test with opus format
        final opusBytes = await client!.audio.speech.create(
          const SpeechRequest(
            model: 'tts-1',
            input: 'Testing audio format.',
            voice: SpeechVoice.alloy,
            responseFormat: SpeechResponseFormat.opus,
          ),
        );

        expect(opusBytes, isNotEmpty);
      },
    );

    test(
      'creates speech with speed adjustment',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Normal speed
        final normalBytes = await client!.audio.speech.create(
          const SpeechRequest(
            model: 'tts-1',
            input: 'Speed test.',
            voice: SpeechVoice.alloy,
            speed: 1.0,
          ),
        );

        // Faster speed
        final fastBytes = await client!.audio.speech.create(
          const SpeechRequest(
            model: 'tts-1',
            input: 'Speed test.',
            voice: SpeechVoice.alloy,
            speed: 1.5,
          ),
        );

        // Both should produce audio
        expect(normalBytes, isNotEmpty);
        expect(fastBytes, isNotEmpty);

        // Faster audio might be smaller (not guaranteed but typical)
        // Just verify both work
      },
    );

    test(
      'creates speech with HD model',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final audioBytes = await client!.audio.speech.create(
          const SpeechRequest(
            model: 'tts-1-hd',
            input: 'Testing high definition audio.',
            voice: SpeechVoice.shimmer,
          ),
        );

        expect(audioBytes, isNotEmpty);
        expect(audioBytes.length, greaterThan(1000));
      },
    );
  });

  group('Audio Transcription - Integration', () {
    test(
      'transcribes audio from TTS',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // First, generate audio with TTS
        final audioBytes = await client!.audio.speech.create(
          const SpeechRequest(
            model: 'tts-1',
            input: 'Hello world.',
            voice: SpeechVoice.alloy,
            responseFormat: SpeechResponseFormat.mp3,
          ),
        );

        // Then transcribe it
        final transcription = await client!.audio.transcriptions.create(
          TranscriptionRequest(
            file: audioBytes,
            filename: 'speech.mp3',
            model: 'whisper-1',
          ),
        );

        expect(transcription.text.toLowerCase(), contains('hello'));
        expect(transcription.text.toLowerCase(), contains('world'));
      },
    );

    test(
      'transcribes with language hint',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Generate English audio
        final audioBytes = await client!.audio.speech.create(
          const SpeechRequest(
            model: 'tts-1',
            input: 'Testing transcription.',
            voice: SpeechVoice.nova,
            responseFormat: SpeechResponseFormat.mp3,
          ),
        );

        // Transcribe with English hint
        final transcription = await client!.audio.transcriptions.create(
          TranscriptionRequest(
            file: audioBytes,
            filename: 'english.mp3',
            model: 'whisper-1',
            language: 'en',
          ),
        );

        expect(transcription.text.toLowerCase(), contains('testing'));
        expect(transcription.text.toLowerCase(), contains('transcription'));
      },
    );

    test(
      'transcribes with verbose output',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Generate audio
        final audioBytes = await client!.audio.speech.create(
          const SpeechRequest(
            model: 'tts-1',
            input: 'This is a verbose transcription test.',
            voice: SpeechVoice.alloy,
            responseFormat: SpeechResponseFormat.mp3,
          ),
        );

        // Transcribe with verbose output
        final transcription = await client!.audio.transcriptions.createVerbose(
          TranscriptionRequest(
            file: audioBytes,
            filename: 'verbose.mp3',
            model: 'whisper-1',
          ),
        );

        expect(transcription.text.toLowerCase(), contains('verbose'));
        expect(transcription.language, isNotNull);
        expect(transcription.duration, isNotNull);
        expect(transcription.duration, greaterThan(0));
      },
    );
  });

  group('Audio Translation - Integration', () {
    test(
      'translates non-English audio to English',
      timeout: const Timeout(Duration(minutes: 3)),
      skip:
          'Requires non-English audio file - TTS only supports English-like output',
      () {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Note: OpenAI TTS generates English-sounding audio even for non-English text
        // So this test would need a pre-recorded non-English audio file

        // For demonstration, we'll skip this test
        // In a real scenario, you would use:
        // final translation = await client!.audio.translations.create(
        //   TranslationRequest(
        //     file: spanishAudioBytes,
        //     filename: 'spanish.mp3',
        //     model: 'whisper-1',
        //   ),
        // );
        // expect(translation.text, isNotEmpty);
      },
    );
  });
}
