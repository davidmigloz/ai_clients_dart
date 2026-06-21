@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('VoicesResource', () {
    late http.Request captured;

    MistralClient clientReturning(Map<String, dynamic> body) {
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode(body),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    test('list plumbs type query param', () async {
      final client = clientReturning({'items': <dynamic>[]});
      addTearDown(client.close);

      await client.audio.voices.list(limit: 10, type: 'custom');

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/audio/voices');
      expect(captured.url.queryParameters['limit'], '10');
      expect(captured.url.queryParameters['type'], 'custom');
    });
  });
}
