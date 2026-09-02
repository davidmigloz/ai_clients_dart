import 'dart:convert';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

Map<String, dynamic> _fileJson({
  String id = 'file_abc123',
  String filename = 'document.pdf',
  String? expiresAt,
}) {
  return {
    'id': id,
    'type': 'file',
    'filename': filename,
    'mime_type': 'application/pdf',
    'size_bytes': 1024,
    'created_at': '2025-01-01T00:00:00Z',
    'downloadable': true,
    'expires_at': ?expiresAt,
  };
}

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

  group('FilesResource', () {
    test('uploadBytes sends no anthropic-beta header', () async {
      mockHttpClient.queueJsonResponse(_fileJson());

      await client.files.uploadBytes(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'document.pdf',
        mimeType: 'application/pdf',
      );

      final request = mockHttpClient.lastRequest!;
      expect(request.headers.containsKey('anthropic-beta'), isFalse);
    });

    test('uploadBytes sends expires_in_seconds field when set', () async {
      mockHttpClient.queueJsonResponse(
        _fileJson(expiresAt: '2025-01-01T01:00:00Z'),
      );

      final file = await client.files.uploadBytes(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'document.pdf',
        expiresInSeconds: 3600,
      );

      expect(file.expiresAt, DateTime.utc(2025, 1, 1, 1, 0, 0));

      final request = mockHttpClient.lastRequest! as http.MultipartRequest;
      expect(request.fields['expires_in_seconds'], '3600');
    });

    test('uploadBytes omits expires_in_seconds field when unset', () async {
      mockHttpClient.queueJsonResponse(_fileJson());

      await client.files.uploadBytes(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'document.pdf',
      );

      final request = mockHttpClient.lastRequest! as http.MultipartRequest;
      expect(request.fields.containsKey('expires_in_seconds'), isFalse);
    });

    test('uploadBytes rejects expiresInSeconds below the minimum', () {
      expect(
        () => client.files.uploadBytes(
          bytes: Uint8List.fromList([1]),
          fileName: 'x.txt',
          expiresInSeconds: 3599,
        ),
        throwsArgumentError,
      );
    });

    test('uploadBytes rejects expiresInSeconds above the maximum', () {
      expect(
        () => client.files.uploadBytes(
          bytes: Uint8List.fromList([1]),
          fileName: 'x.txt',
          expiresInSeconds: 7776001,
        ),
        throwsArgumentError,
      );
    });

    test('list sends ids[] as repeated query params', () async {
      mockHttpClient.queueJsonResponse({
        'data': [_fileJson()],
        'next_page': null,
      });

      await client.files.list(ids: ['file_1', 'file_2']);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.queryParametersAll['ids[]'], ['file_1', 'file_2']);
      expect(request.headers.containsKey('anthropic-beta'), isFalse);
    });

    test('list sends page cursor and parses next_page', () async {
      mockHttpClient.queueJsonResponse({
        'data': <Map<String, dynamic>>[],
        'next_page': 'page_xyz',
      });

      final response = await client.files.list(page: 'page_abc', limit: 5);

      expect(response.nextPage, 'page_xyz');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.queryParameters['page'], 'page_abc');
      expect(request.url.queryParameters['limit'], '5');
    });

    test('retrieve sends no anthropic-beta header', () async {
      mockHttpClient.queueJsonResponse(_fileJson());

      await client.files.retrieve(fileId: 'file_abc123');

      final request = mockHttpClient.lastRequest!;
      expect(request.headers.containsKey('anthropic-beta'), isFalse);
    });

    test('deleteFile sends no anthropic-beta header', () async {
      mockHttpClient.queueJsonResponse({
        'id': 'file_abc123',
        'type': 'file_deleted',
      });

      final response = await client.files.deleteFile(fileId: 'file_abc123');

      expect(response.id, 'file_abc123');
      final request = mockHttpClient.lastRequest!;
      expect(request.headers.containsKey('anthropic-beta'), isFalse);
    });

    test('download sends no anthropic-beta header', () async {
      mockHttpClient.queueResponse(
        const MockResponse(
          body: 'raw-bytes',
          headers: {'content-type': 'application/octet-stream'},
        ),
      );

      final bytes = await client.files.download(fileId: 'file_abc123');

      expect(utf8.decode(bytes), 'raw-bytes');
      final request = mockHttpClient.lastRequest!;
      expect(request.headers.containsKey('anthropic-beta'), isFalse);
    });
  });
}
