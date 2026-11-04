/// Creates, selects for Live, and deletes a prompt voice using two mock calls.
/// No API key, real voice creation, media connection or billed playback is used.
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  const prompt =
      'An adult narrator with a warm tone, clear diction, and a relaxed pace.';
  const id = 'voice_synthetic_prompt';
  var calls = 0;
  final transport = MockClient((request) async {
    calls++;
    if (request.method == 'POST' &&
        request.url.path.endsWith('/audio/voices')) {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['type'] != 'prompt' ||
          body['prompt'] != prompt ||
          body.containsKey('script_hint') ||
          body.containsKey('model') ||
          request.headers['content-type'] != 'application/json') {
        throw StateError('Prompt creation encoding or omission changed.');
      }
      return http.Response(
        jsonEncode({
          'object': 'audio.voice',
          'id': id,
          'name': 'Synthetic narrator',
          'created_at': 0,
          'type': 'prompt',
          'prompt': prompt,
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (request.method == 'DELETE' &&
        request.url.path.endsWith('/audio/voices/$id')) {
      return http.Response(
        jsonEncode({
          'object': 'audio.voice.deleted',
          'id': id,
          'deleted': true,
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    throw StateError('Unexpected fixture request.');
  });
  final client = OpenAIClient(httpClient: transport);
  String? createdId;
  try {
    final voice = await client.audio.voices.create(
      PromptVoiceCreateRequest(name: 'Synthetic narrator', prompt: prompt),
    );
    createdId = voice.id;

    // Select the saved voice at Live startup and retain its original description.
    // Prompt-generated voices are supported only in Live. This example constructs
    // configuration locally; it does not start a connection or generate speech.
    final session = LiveSessionCreateParams(
      model: 'gpt-live-1',
      instructions: 'You are a helpful assistant. ${voice.prompt ?? prompt}',
      audio: LiveInitialSessionAudioParam(
        output: LiveInitialSessionAudioOutputParam(
          voice: LiveVoice.custom(id: voice.id),
        ),
      ),
    );
    final audio = session.toJson()['audio'] as Map<String, dynamic>;
    final output = audio['output'] as Map<String, dynamic>;
    if ((output['voice'] as Map<String, dynamic>)['id'] != id) {
      throw StateError('Live startup lost the saved voice reference.');
    }
    stdout.writeln('Prepared Live startup with the saved prompt voice.');
  } finally {
    try {
      if (createdId != null) {
        final deleted = await client.audio.voices.delete(createdId);
        if (!deleted.deleted || deleted.id != createdId) {
          throw StateError('Voice deletion was not confirmed.');
        }
      }
    } finally {
      client.close();
      transport.close();
    }
  }
  if (calls != 2) throw StateError('Expected create and explicit delete only.');
  stdout.writeln(
    r'Deleted the synthetic voice. Two mock requests; API cost $0.',
  );
}
