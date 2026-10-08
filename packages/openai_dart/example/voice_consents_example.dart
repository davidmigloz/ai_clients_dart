// ignore_for_file: avoid_print
/// Runs the complete voice consent lifecycle with synthetic offline responses.
///
/// Run: dart run example/voice_consents_example.dart [--delete]
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main(List<String> arguments) async {
  final deleteRequested = arguments.contains('--delete');
  var calls = 0;
  var name = 'Synthetic actor consent';
  final recording = Uint8List.fromList([0, 1, 255, 128]);
  const firstId = 'cons_mock_first';
  Map<String, Object> consent(String id) => {
    'object': 'audio.voice_consent',
    'id': id,
    'name': name,
    'language': 'en-US',
    'created_at': 0,
    'provider_metadata': {'source': 'synthetic'},
  };
  final transport = MockClient.streaming((request, body) async {
    calls++;
    final bytes = await body.toBytes();
    Map<String, Object?> response;
    final collection = request.url.path.endsWith('/voice_consents');
    if (collection && request.method == 'POST') {
      final multipart = latin1.decode(bytes);
      if (!multipart.contains('name="recording"; filename="mock.webm"') ||
          !multipart.toLowerCase().contains('content-type: audio/webm\r\n') ||
          multipart.contains('codecs=opus') ||
          !multipart.contains(latin1.decode(recording))) {
        throw StateError('Upload bytes or normalized MIME metadata changed');
      }
      response = consent(firstId);
    } else if (collection && request.method == 'GET') {
      final nextPage = request.url.queryParameters['after'] != null;
      if (nextPage && request.url.queryParameters['after'] != firstId) {
        throw StateError(
          'Cursor was not selected explicitly from the first page',
        );
      }
      final id = nextPage ? 'cons_mock_second' : firstId;
      response = {
        'object': 'list',
        'data': [consent(id)],
        'has_more': !nextPage,
        'first_id': nextPage ? id : null,
        'last_id': id,
      };
    } else if (request.url.pathSegments.last == firstId &&
        request.method == 'GET') {
      response = consent(firstId);
    } else if (request.url.pathSegments.last == firstId &&
        request.method == 'POST') {
      final wire = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      if (wire.length != 1 || wire['name'] is! String) {
        throw StateError('Rename must contain only the required name');
      }
      name = wire['name'] as String;
      response = consent(firstId);
    } else if (request.url.pathSegments.last == firstId &&
        request.method == 'DELETE') {
      response = {
        'object': 'audio.voice_consent',
        'id': firstId,
        'deleted': true,
      };
    } else {
      throw StateError('Unexpected consent operation');
    }
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
    // Synthetic bytes only. Production recordings must use the current consent
    // phrase and the same person/project as the later custom voice sample.
    // Custom voice access and api.voices.write permission are service requirements.
    final created = await client.audio.voiceConsents.create(
      VoiceConsentCreateRequest(
        name: name,
        recording: recording,
        filename: 'mock.webm',
        language: 'en-US',
        recordingContentType: 'audio/webm;codecs=opus',
      ),
    );
    final firstPage = await client.audio.voiceConsents.list(limit: 1);
    final retrieved = await client.audio.voiceConsents.retrieve(created.id);
    final renamed = await client.audio.voiceConsents.update(
      created.id,
      const VoiceConsentUpdateRequest(name: 'Renamed synthetic consent'),
    );
    // Pagination is explicit; no request is made merely by reading hasMore.
    final nextPage = await client.audio.voiceConsents.list(
      after: firstPage.lastId,
      limit: 1,
    );
    // The application explicitly selects deletion; create/list never delete.
    final deleted = deleteRequested
        ? await client.audio.voiceConsents.delete(created.id)
        : null;
    if (calls != (deleteRequested ? 6 : 5) ||
        retrieved.id != created.id ||
        !firstPage.hasMore ||
        !firstPage.hasFirstId ||
        firstPage.firstId != null ||
        nextPage.hasMore ||
        renamed.name != 'Renamed synthetic consent' ||
        (deleteRequested && deleted?.deleted != true) ||
        created.rawJson['provider_metadata'] == null) {
      throw StateError('Offline consent lifecycle lost its contract');
    }
    print(
      'Uploaded unchanged synthetic bytes; normalized browser MIME metadata.',
    );
    print(
      deleteRequested
          ? 'Listed two explicit pages, retrieved, renamed and explicitly deleted.'
          : 'Listed two explicit pages, retrieved, renamed and retained consent.',
    );
    print('$calls mock requests; API cost \$0');
  } finally {
    client.close();
    transport.close();
  }
}
