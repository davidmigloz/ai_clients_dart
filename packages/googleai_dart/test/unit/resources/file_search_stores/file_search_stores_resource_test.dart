import 'dart:async';

import 'package:googleai_dart/src/auth/auth_provider.dart';
import 'package:googleai_dart/src/client/config.dart';
import 'package:googleai_dart/src/client/interceptor_chain.dart';
import 'package:googleai_dart/src/client/request_builder.dart';
import 'package:googleai_dart/src/resources/file_search_stores/file_search_stores_resource.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockHttpClient extends Mock implements http.Client {}

http.StreamedResponse _bytesResponse(List<int> bytes, {int status = 200}) {
  return http.StreamedResponse(
    Stream.value(bytes),
    status,
    headers: {
      'content-type': 'application/octet-stream',
      'content-length': '${bytes.length}',
    },
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      http.Request('GET', Uri.parse('https://example.com')),
    );
  });

  group('FileSearchStoresResource.downloadMedia', () {
    late _MockHttpClient mockHttpClient;
    late FileSearchStoresResource resource;
    final capturedRequests = <http.BaseRequest>[];

    setUp(() {
      mockHttpClient = _MockHttpClient();
      capturedRequests.clear();

      const config = GoogleAIConfig(
        baseUrl: 'https://generativelanguage.googleapis.com',
        authProvider: ApiKeyProvider('test-key'),
      );
      resource = FileSearchStoresResource(
        config: config,
        httpClient: mockHttpClient,
        interceptorChain: InterceptorChain(
          interceptors: const [],
          httpClient: mockHttpClient,
        ),
        requestBuilder: const RequestBuilder(config: config),
      );
    });

    test(
      'issues GET to /v1beta/{store}/media/{mediaId} and returns bytes',
      () async {
        final payload = List<int>.generate(64, (i) => i % 256);

        when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
          capturedRequests.add(
            invocation.positionalArguments.first as http.BaseRequest,
          );
          return _bytesResponse(payload);
        });

        final bytes = await resource.downloadMedia(
          fileSearchStoreName: 'fileSearchStores/my-store-123',
          mediaId: 'media-abc-456',
        );

        expect(bytes, equals(payload));

        expect(capturedRequests, hasLength(1));
        final req = capturedRequests.single;
        expect(req.method, 'GET');
        expect(req.url.host, 'generativelanguage.googleapis.com');
        expect(
          req.url.path,
          '/v1beta/fileSearchStores/my-store-123/media/media-abc-456',
        );
        // alt=media is required so the server returns raw bytes rather than
        // a JSON DownloadMediaResponse envelope.
        expect(req.url.queryParameters['alt'], 'media');
      },
    );

    test('throws UnsupportedError when configured for Vertex AI', () async {
      const config = GoogleAIConfig(
        baseUrl: 'https://us-central1-aiplatform.googleapis.com',
        apiMode: ApiMode.vertexAI,
        authProvider: ApiKeyProvider('test-key'),
      );
      final vertexResource = FileSearchStoresResource(
        config: config,
        httpClient: mockHttpClient,
        interceptorChain: InterceptorChain(
          interceptors: const [],
          httpClient: mockHttpClient,
        ),
        requestBuilder: const RequestBuilder(config: config),
      );

      await expectLater(
        vertexResource.downloadMedia(
          fileSearchStoreName: 'fileSearchStores/x',
          mediaId: 'm',
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
