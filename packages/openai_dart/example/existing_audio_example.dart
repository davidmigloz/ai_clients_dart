// ignore_for_file: avoid_print
/// Runs file transcription, translation and Chat voice selection offline.
///
/// Run: dart run example/existing_audio_example.dart
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  var calls = 0;
  const subtitles = 'WEBVTT\n\n00:00.000 --> 00:01.000\nHello.\n\n';
  final transport = MockClient.streaming((request, body) async {
    calls++;
    final bytes = await body.toBytes();
    Object response;
    var media = 'application/json';
    switch (request.url.path) {
      case '/v1/audio/transcriptions':
        final multipart = latin1.decode(bytes);
        if (!multipart.contains('name="keywords[]"') ||
            !multipart.contains('name="languages[]"') ||
            !multipart.toLowerCase().contains('content-type: audio/wav') ||
            !multipart.contains('gpt-transcribe')) {
          throw StateError('Modern file options were not forwarded');
        }
        response = {
          'text': 'Hello.',
          'future_metadata': {'source': 'mock'},
        };
      case '/v1/audio/translations':
        final multipart = latin1.decode(bytes);
        if (multipart.contains('\r\nvtt\r\n')) {
          response = subtitles;
          media = 'text/plain';
        } else {
          // Canonical verbose translations need no legacy task property.
          response = {'language': 'english', 'duration': 1, 'text': 'Hello.'};
        }
      case '/v1/chat/completions':
        final wire = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
        final audio = wire['audio'] as Map<String, dynamic>;
        if (audio['format'] != 'aac' ||
            (audio['voice'] != 'provider-voice-name' &&
                jsonEncode(audio['voice']) != '{"id":"voice_mock_existing"}')) {
          throw StateError('Chat voice/AAC configuration was not forwarded');
        }
        response = {
          'id': 'mock',
          'object': 'chat.completion',
          'created': 0,
          'model': 'gpt-audio-1.5',
          'choices': [
            {
              'index': 0,
              'message': {'role': 'assistant', 'content': 'Hello.'},
              'finish_reason': 'stop',
            },
          ],
        };
      default:
        throw StateError('Unexpected offline request');
    }
    return http.StreamedResponse(
      Stream.value(
        utf8.encode(response is String ? response : jsonEncode(response)),
      ),
      200,
      headers: {'content-type': media},
      request: request,
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
    httpClient: transport,
  );
  try {
    // Synthetic bytes only; real uploads must contain a supported audio clip.
    final audioBytes = Uint8List.fromList([0, 1, 255, 128]);
    final transcript = await client.audio.transcriptions.create(
      TranscriptionRequest(
        file: audioBytes,
        filename: 'mock.wav',
        fileContentType: 'audio/wav',
        model: 'gpt-transcribe',
        keywords: const ['OpenAI'],
        languages: const ['en'],
        prompt: 'A short greeting.',
        temperature: 0,
      ),
    );
    final translation = TranslationRequest(
      file: audioBytes,
      filename: 'mock.wav',
      fileContentType: 'audio/wav',
      model: 'whisper-1',
      prompt: 'A short greeting in English.',
      temperature: 0,
    );
    final verbose = await client.audio.translations.createVerbose(translation);
    final raw = await client.audio.translations.createRaw(
      translation.copyWith(responseFormat: TranslationResponseFormat.vtt),
    );
    for (final voice in const <AudioVoice>[
      AudioVoice.named('provider-voice-name'),
      AudioVoice.custom('voice_mock_existing'),
    ]) {
      // Names/IDs are mock fixtures; production choices require model access.
      await client.chat.completions.create(
        ChatCompletionCreateRequest(
          model: 'gpt-audio-1.5',
          messages: [ChatMessage.user('Say hello.')],
          modalities: const [ChatModality.text, ChatModality.audio],
          audio: ChatAudioConfig(voice: voice, format: ChatAudioFormat.aac),
          store: false,
        ),
      );
    }
    if (calls != 5 ||
        transcript.text != 'Hello.' ||
        transcript.rawJson['future_metadata'] == null ||
        verbose.task != null ||
        verbose.language != 'english' ||
        raw != subtitles) {
      throw StateError('Offline audio workflow lost its output');
    }
    print(
      'Transcription retained future metadata; verbose translation has no task.',
    );
    print(
      'Raw subtitles preserve whitespace; open/custom Chat voices use AAC.',
    );
    print('$calls mock requests; API cost \$0');
  } finally {
    client.close();
    transport.close();
  }
}
