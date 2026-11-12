import 'dart:convert';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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

    test(
      'scoped list selects the Managed Agents beta and keeps both cursors',
      () async {
        mockHttpClient.queueJsonResponse({
          'data': [
            {
              ..._fileJson(id: 'file_scoped'),
              'scope': {'type': 'session', 'id': 'sesn_test'},
            },
          ],
          'next_page': 'page_following',
          'has_more': true,
          'first_id': 'file_scoped',
          'last_id': 'file_scoped',
        });

        final page = await client.files.list(
          scopeId: 'sesn_test',
          betas: ['other-beta'],
          workspaceId: 'wrkspc_test',
          afterId: 'file_previous',
        );

        expect(page.nextPage, 'page_following');
        expect(page.hasMore, isTrue);
        expect(page.firstId, 'file_scoped');
        expect(page.lastId, 'file_scoped');
        expect(page.data.single.scope?.id, 'sesn_test');
        expect(page.toJson()['last_id'], 'file_scoped');
        expect(page.copyWith(lastId: null).lastId, isNull);
        final request = mockHttpClient.lastRequest!;
        expect(request.url.queryParameters, {
          'scope_id': 'sesn_test',
          'after_id': 'file_previous',
        });
        expect(
          request.headers['anthropic-beta'],
          'other-beta,managed-agents-2026-04-01',
        );
        expect(request.headers['anthropic-workspace-id'], 'wrkspc_test');
      },
    );

    test(
      'historical Files beta retains ID pagination and no expiration',
      () async {
        mockHttpClient.queueJsonResponse({
          'data': [_fileJson(id: 'file_legacy')],
          'has_more': false,
          'first_id': 'file_legacy',
          'last_id': 'file_legacy',
        });

        final page = await client.files.list(
          betas: ['files-api-2025-04-14'],
          beforeId: 'file_previous',
        );
        expect(page.nextPage, isNull);
        expect(page.hasMore, isFalse);
        expect(page.data.single.expiresAt, isNull);
        expect(mockHttpClient.lastRequest?.url.queryParameters, {
          'before_id': 'file_previous',
        });
        expect(
          mockHttpClient.lastRequest?.headers['anthropic-beta'],
          'files-api-2025-04-14',
        );
      },
    );

    test(
      'sends file bytes and media type in the finalized multipart body',
      () async {
        final transport = MockClient((request) async {
          expect(request.url.path, '/proxy/v1/files');
          expect(request.headers['anthropic-version'], '2026-10-21');
          expect(request.headers['anthropic-workspace-id'], 'wrkspc_override');
          expect(request.headers['anthropic-beta'], 'file-opt-in');
          expect(request.headers['x-api-key'], 'test-api-key');
          final contentType = request.headers['content-type']!;
          expect(contentType, startsWith('multipart/form-data; boundary='));
          final boundary = contentType.split('boundary=').last;
          final body = latin1.decode(request.bodyBytes);
          expect(
            body,
            contains(
              '--$boundary\r\ncontent-disposition: form-data; '
              'name="expires_in_seconds"\r\n\r\n3600\r\n',
            ),
          );
          expect(body, contains('name="file"; filename="payload.bin"\r\n'));
          expect(body, contains('content-type: application/x-test\r\n'));
          expect(body, contains('\r\n\r\n\u0000\u0080\u00ff\r\n--$boundary--'));
          return http.Response(
            jsonEncode(_fileJson(expiresAt: '2026-11-11T01:00:00Z')),
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        final sdk = AnthropicClient(
          config: const AnthropicConfig(
            baseUrl: 'https://proxy.invalid/proxy',
            authProvider: ApiKeyProvider('test-api-key'),
            workspaceId: 'wrkspc_default',
            defaultHeaders: {
              'Anthropic-Beta': 'default',
              'Content-Type': 'text/plain',
            },
          ),
          httpClient: transport,
        );
        addTearDown(sdk.close);

        final file = await sdk.files.uploadBytes(
          bytes: Uint8List.fromList([0, 128, 255]),
          fileName: 'payload.bin',
          mimeType: 'application/x-test',
          expiresInSeconds: 3600,
          betas: ['file-opt-in'],
          workspaceId: 'wrkspc_override',
        );
        expect(file.expiresAt, DateTime.utc(2026, 11, 11, 1));
      },
    );

    test('downloads binary bytes and exposes expiration diagnostics', () async {
      var requests = 0;
      final transport = MockClient((request) async {
        expect(request.url.pathSegments, [
          'v1',
          'files',
          'file/opaque',
          'content',
        ]);
        expect(request.headers['accept'], 'application/binary');
        expect(request.headers, isNot(contains('content-type')));
        expect(request.headers, isNot(contains('anthropic-beta')));
        if (requests++ == 0) {
          return http.Response.bytes(
            [0, 128, 255],
            200,
            headers: {'content-type': 'application/octet-stream'},
          );
        }
        return http.Response(
          jsonEncode({
            'type': 'error',
            'request_id': 'req_expired',
            'error': {
              'type': 'not_found_error',
              'message': 'The file expired.',
              'details': {'error_code': 'file_expired'},
            },
          }),
          404,
          headers: {'content-type': 'application/json'},
        );
      });
      final sdk = AnthropicClient(
        config: const AnthropicConfig(
          defaultHeaders: {'Content-Type': 'application/json'},
        ),
        httpClient: transport,
      );
      addTearDown(sdk.close);

      expect(await sdk.files.download(fileId: 'file/opaque'), [0, 128, 255]);
      await expectLater(
        sdk.files.download(fileId: 'file/opaque'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'status', 404)
              .having((error) => error.requestId, 'request ID', 'req_expired')
              .having((error) => error.errorCode, 'error code', 'file_expired'),
        ),
      );
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
