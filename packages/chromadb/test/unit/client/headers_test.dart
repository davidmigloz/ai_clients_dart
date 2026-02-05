import 'dart:async';

import 'package:chromadb/chromadb.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeBaseRequest extends Fake implements http.BaseRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBaseRequest());
  });

  group('Header merge behavior', () {
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
    });

    tearDown(() {
      reset(mockHttpClient);
    });

    test('defaultHeaders override built-in User-Agent', () async {
      // Capture the request to verify headers
      http.Request? capturedRequest;
      when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
        capturedRequest = invocation.positionalArguments[0] as http.Request;
        // Return a mock response for heartbeat endpoint
        return http.StreamedResponse(
          Stream.value('{"nanosecond heartbeat": 123456}'.codeUnits),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = ChromaClient(
        config: const ChromaConfig(
          defaultHeaders: {'User-Agent': 'custom-agent'},
        ),
        httpClient: mockHttpClient,
      );
      addTearDown(client.close);

      await client.health.heartbeat();

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.headers['User-Agent'], 'custom-agent');
    });

    test('defaultHeaders are included in requests', () async {
      http.Request? capturedRequest;
      when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
        capturedRequest = invocation.positionalArguments[0] as http.Request;
        return http.StreamedResponse(
          Stream.value('{"nanosecond heartbeat": 123456}'.codeUnits),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = ChromaClient(
        config: const ChromaConfig(
          defaultHeaders: {
            'X-Custom-Header': 'custom-value',
            'X-Correlation-ID': 'test-123',
          },
        ),
        httpClient: mockHttpClient,
      );
      addTearDown(client.close);

      await client.health.heartbeat();

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.headers['X-Custom-Header'], 'custom-value');
      expect(capturedRequest!.headers['X-Correlation-ID'], 'test-123');
    });

    test('auth interceptor adds x-chroma-token header', () async {
      http.Request? capturedRequest;
      when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
        capturedRequest = invocation.positionalArguments[0] as http.Request;
        return http.StreamedResponse(
          Stream.value('{"nanosecond heartbeat": 123456}'.codeUnits),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = ChromaClient(
        config: const ChromaConfig(
          authProvider: ApiKeyProvider('test-api-key'),
        ),
        httpClient: mockHttpClient,
      );
      addTearDown(client.close);

      await client.health.heartbeat();

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.headers['x-chroma-token'], 'test-api-key');
    });

    test(
      'auth interceptor overrides x-chroma-token from defaultHeaders',
      () async {
        http.Request? capturedRequest;
        when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
          capturedRequest = invocation.positionalArguments[0] as http.Request;
          return http.StreamedResponse(
            Stream.value('{"nanosecond heartbeat": 123456}'.codeUnits),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final client = ChromaClient(
          config: const ChromaConfig(
            authProvider: ApiKeyProvider('auth-key'),
            // This should be overridden by the auth interceptor
            defaultHeaders: {'x-chroma-token': 'default-key'},
          ),
          httpClient: mockHttpClient,
        );
        addTearDown(client.close);

        await client.health.heartbeat();

        expect(capturedRequest, isNotNull);
        // Auth interceptor should win
        expect(capturedRequest!.headers['x-chroma-token'], 'auth-key');
      },
    );

    test('built-in headers are present by default', () async {
      http.Request? capturedRequest;
      when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
        capturedRequest = invocation.positionalArguments[0] as http.Request;
        return http.StreamedResponse(
          Stream.value('{"nanosecond heartbeat": 123456}'.codeUnits),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = ChromaClient(httpClient: mockHttpClient);
      addTearDown(client.close);

      await client.health.heartbeat();

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.headers['Accept'], 'application/json');
      expect(capturedRequest!.headers['User-Agent'], 'chromadb-dart');
    });
  });
}
