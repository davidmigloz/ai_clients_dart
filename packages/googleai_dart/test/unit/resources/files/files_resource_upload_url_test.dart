import 'dart:convert';

import 'package:googleai_dart/src/auth/auth_provider.dart';
import 'package:googleai_dart/src/client/config.dart';
import 'package:googleai_dart/src/client/interceptor_chain.dart';
import 'package:googleai_dart/src/client/request_builder.dart';
import 'package:googleai_dart/src/resources/files/files_resource.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockHttpClient extends Mock implements http.Client {}

http.StreamedResponse _jsonResponse(
  Map<String, dynamic> body, {
  int status = 200,
  Map<String, String> headers = const {},
}) {
  return http.StreamedResponse(
    Stream.value(utf8.encode(jsonEncode(body))),
    status,
    headers: {'content-type': 'application/json', ...headers},
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      http.Request('GET', Uri.parse('https://example.com')),
    );
  });

  group('FilesResource.upload URL construction', () {
    late _MockHttpClient mockHttpClient;
    final capturedRequests = <http.BaseRequest>[];

    FilesResource buildResource(GoogleAIConfig config) {
      mockHttpClient = _MockHttpClient();
      capturedRequests.clear();

      when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
        final request =
            invocation.positionalArguments.first as http.BaseRequest;
        capturedRequests.add(request);
        if (capturedRequests.length == 1) {
          // Initiation response carries the resumable upload URL.
          return _jsonResponse(
            {},
            headers: {'x-goog-upload-url': 'https://upload.example.com/next'},
          );
        }
        return _jsonResponse({
          'file': {
            'name': 'files/abc123',
            'mimeType': 'text/plain',
            'createTime': '2026-01-01T00:00:00Z',
            'updateTime': '2026-01-01T00:00:00Z',
            'expirationTime': '2026-01-03T00:00:00Z',
            'uri': 'https://generativelanguage.googleapis.com/files/abc123',
          },
        });
      });

      return FilesResource(
        config: config,
        httpClient: mockHttpClient,
        interceptorChain: InterceptorChain(
          interceptors: const [],
          httpClient: mockHttpClient,
        ),
        requestBuilder: RequestBuilder(config: config),
      );
    }

    test('trailing-slash base URL yields no double slash and merges '
        'defaultQueryParams and query-placement auth', () async {
      const config = GoogleAIConfig(
        baseUrl: 'https://generativelanguage.googleapis.com/',
        authProvider: ApiKeyProvider('test-key'),
        defaultQueryParams: {'proxy': 'p'},
      );
      final resource = buildResource(config);

      await resource.upload(
        bytes: [1, 2, 3],
        fileName: 'test.txt',
        mimeType: 'text/plain',
      );

      expect(capturedRequests.length, greaterThanOrEqualTo(1));
      final initiation = capturedRequests.first;
      expect(initiation.url.host, 'generativelanguage.googleapis.com');
      expect(initiation.url.path, '/upload/v1beta/files');
      expect(initiation.url.queryParameters['key'], 'test-key');
      expect(initiation.url.queryParameters['proxy'], 'p');
    });

    test(
      'header-placement auth sets X-Goog-Api-Key and no key param',
      () async {
        const config = GoogleAIConfig(
          baseUrl: 'https://generativelanguage.googleapis.com/',
          authProvider: ApiKeyProvider(
            'test-key',
            placement: AuthPlacement.header,
          ),
        );
        final resource = buildResource(config);

        await resource.upload(
          bytes: [1, 2, 3],
          fileName: 'test.txt',
          mimeType: 'text/plain',
        );

        final initiation = capturedRequests.first;
        expect(initiation.url.path, '/upload/v1beta/files');
        expect(initiation.headers['X-Goog-Api-Key'], 'test-key');
        expect(initiation.url.queryParameters.containsKey('key'), isFalse);
      },
    );
  });
}
