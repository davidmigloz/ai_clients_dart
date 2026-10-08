// ignore_for_file: avoid_print
/// Creates a consent and custom voice using synthetic offline responses.
///
/// Run: dart run example/voices_example.dart
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final recording = Uint8List.fromList([0, 1, 255, 128]);
  final sample = Uint8List.fromList([3, 2, 254, 129]);
  const consentId = 'cons_synthetic';
  const voiceId = 'voice_synthetic';
  var calls = 0;
  final transport = MockClient.streaming((request, body) async {
    calls++;
    final multipart = latin1.decode(await body.toBytes());
    if (request.method != 'POST' || calls > 2) {
      throw StateError('Only two explicit uploads are expected');
    }
    final isConsent = request.url.path.endsWith('/audio/voice_consents');
    final isVoice = request.url.path.endsWith('/audio/voices');
    if ((!isConsent && !isVoice) || (isConsent != (calls == 1))) {
      throw StateError('Consent must precede the selected sample upload');
    }
    final field = isConsent ? 'recording' : 'audio_sample';
    final filename = isConsent ? 'consent.webm' : 'sample.webm';
    final bytes = isConsent ? recording : sample;
    final filePart =
        'content-type: audio/webm\r\n'
        'content-disposition: form-data; name="$field"; filename="$filename"'
        '\r\n\r\n${latin1.decode(bytes)}\r\n';
    if (!multipart.contains(filePart) || multipart.contains('codecs=opus')) {
      throw StateError('Original bytes, filename or normalized MIME changed');
    }
    if (isVoice &&
        (!multipart.contains('name="consent"\r\n\r\n$consentId\r\n') ||
            multipart.contains('name="type"'))) {
      throw StateError('Selected consent and omitted type must be preserved');
    }
    final response = isConsent
        ? {
            'object': 'audio.voice_consent',
            'id': consentId,
            'name': 'Synthetic actor consent',
            'language': 'en-US',
            'created_at': 0,
          }
        : {
            'object': 'audio.voice',
            'id': voiceId,
            'name': 'Synthetic actor voice',
            'type': 'audio_sample',
            'created_at': 0,
            'provider_metadata': {'source': 'synthetic'},
          };
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(response))),
      200,
      headers: const {'content-type': 'application/json; charset=utf-8'},
      request: request,
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
    httpClient: transport,
  );
  try {
    // These synthetic bytes are not real audio. Production requires approved
    // project access, api.voices.write, and the actor's current consent phrase.
    final consent = await client.audio.voiceConsents.create(
      VoiceConsentCreateRequest(
        name: 'Synthetic actor consent',
        recording: recording,
        filename: 'consent.webm',
        language: 'en-US',
        recordingContentType: 'audio/webm;codecs=opus',
      ),
    );
    // The sample must come from the same person/project, with at least five
    // seconds of actual speech and 15 transcribed tokens, at most 30 seconds.
    // The service validates speech content; the client preserves the bytes.
    final voice = await client.audio.voices.create(
      CustomVoiceCreateRequest(
        name: 'Synthetic actor voice',
        audioSample: sample,
        filename: 'sample.webm',
        consent: consent.id,
        audioSampleContentType: 'audio/webm;codecs=opus',
        // Omitted type lets the service apply its audio_sample default.
      ),
    );
    // The application selects a reference. This does not invoke speech or Live;
    // production use of the voice requires api.voices.read in the same project.
    final reference = AudioVoice.custom(voice.id).toJson();
    if (calls != 2 ||
        voice.object != 'audio.voice' ||
        voice.type != 'audio_sample' ||
        reference is! Map<String, dynamic> ||
        reference.length != 1 ||
        reference['id'] != voiceId ||
        voice.rawJson['provider_metadata'] == null) {
      throw StateError('Offline custom voice workflow lost its contract');
    }
    print('Created synthetic consent and voice; custom reference is ready.');
    print('$calls mock requests; API cost \$0');
  } finally {
    client.close();
    transport.close();
  }
}
