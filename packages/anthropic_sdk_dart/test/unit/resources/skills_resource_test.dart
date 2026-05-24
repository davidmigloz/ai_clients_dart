import 'dart:convert';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

void main() {
  late MockHttpClient mockHttpClient;
  late AnthropicClient client;

  setUp(() {
    mockHttpClient = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('test-api-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: mockHttpClient,
    );
  });

  tearDown(() {
    client.close();
  });

  group('SkillsResource.downloadVersion', () {
    test('sends correct request and returns raw bytes', () async {
      // A small ASCII-safe payload so it round-trips through the harness'
      // utf8 encoding of MockResponse.body unchanged. The expected bytes are
      // therefore the utf8 encoding of the queued body.
      const zipBody = 'PKfake-skill-zip-bytes';
      final expectedBytes = Uint8List.fromList(utf8.encode(zipBody));

      mockHttpClient.queueResponse(
        const MockResponse(
          body: zipBody,
          headers: {'content-type': 'application/zip'},
        ),
      );

      final bytes = await client.skills.downloadVersion(
        skillId: 'skill_abc123',
        version: '1759178010641129',
      );

      // Returned value equals the queued raw bytes.
      expect(bytes, isA<Uint8List>());
      expect(bytes, equals(expectedBytes));

      final request = mockHttpClient.lastRequest! as http.Request;
      expect(
        request.url.path,
        '/v1/skills/skill_abc123/versions/1759178010641129/content',
      );
      expect(request.method, 'GET');
      expect(request.headers['anthropic-beta'], 'skills-2025-10-02');
      // http lowercases header keys for lookup, so this works regardless of
      // the casing used when the header was set.
      expect(request.headers['Accept'], 'application/binary');
      expect(request.headers['accept'], 'application/binary');
      expect(request.headers['x-api-key'], 'test-api-key');
    });

    test('throws ArgumentError when skillId is empty', () {
      expect(
        () => client.skills.downloadVersion(skillId: '', version: 'v1'),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError when version is empty', () {
      expect(
        () =>
            client.skills.downloadVersion(skillId: 'skill_abc123', version: ''),
        throwsArgumentError,
      );
    });
  });
}
