import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ollama_dart/src/auth/auth_provider.dart';
import 'package:ollama_dart/src/client/config.dart';
import 'package:ollama_dart/src/client/interceptor_chain.dart';
import 'package:ollama_dart/src/client/request_builder.dart';
import 'package:ollama_dart/src/errors/exceptions.dart';
import 'package:ollama_dart/src/resources/base_resource.dart';
import 'package:ollama_dart/src/resources/streaming_resource.dart';
import 'package:test/test.dart';

// Mock classes
class MockHttpClient extends Mock implements http.Client {}

class MockAuthProvider extends Mock implements AuthProvider {}

/// Test implementation to access mixin methods.
class TestStreamingResource extends ResourceBase with StreamingResource {
  TestStreamingResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  // Expose mapHttpError for direct testing
  OllamaException testMapHttpError(http.Response response) =>
      mapHttpError(response);
}

void main() {
  late MockHttpClient mockHttpClient;
  late TestStreamingResource resource;

  setUpAll(() {
    registerFallbackValue(http.Request('GET', Uri.parse('https://example.com')));
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
  });

  TestStreamingResource createResource({
    AuthProvider? authProvider,
    Level logLevel = Level.OFF,
  }) {
    final config = OllamaConfig(
      baseUrl: 'http://localhost:11434',
      authProvider: authProvider,
      logLevel: logLevel,
    );
    return TestStreamingResource(
      config: config,
      httpClient: mockHttpClient,
      interceptorChain: InterceptorChain(
        interceptors: [],
        httpClient: mockHttpClient,
      ),
      requestBuilder: RequestBuilder(config: config),
    );
  }

  group('StreamingResource', () {
    group('mapHttpError', () {
      test('returns ApiException for generic HTTP errors', () {
        resource = createResource();
        final response = http.Response('', 500);

        final exception = resource.testMapHttpError(response);

        expect(exception, isA<ApiException>());
        final apiException = exception as ApiException;
        expect(apiException.code, 500);
        expect(apiException.message, contains('500'));
      });

      test('extracts error message from JSON body', () {
        resource = createResource();
        final response = http.Response(
          '{"error": "Model not found"}',
          404,
        );

        final exception = resource.testMapHttpError(response);

        expect(exception, isA<ApiException>());
        final apiException = exception as ApiException;
        expect(apiException.code, 404);
        expect(apiException.message, 'Model not found');
      });

      test('uses body as message for short non-JSON responses', () {
        resource = createResource();
        final response = http.Response('Bad Request', 400);

        final exception = resource.testMapHttpError(response);

        expect(exception, isA<ApiException>());
        expect(exception.message, 'Bad Request');
      });

      test('returns RateLimitException for 429 status', () {
        resource = createResource();
        final response = http.Response('{"error": "rate limited"}', 429);

        final exception = resource.testMapHttpError(response);

        expect(exception, isA<RateLimitException>());
        final rateLimitException = exception as RateLimitException;
        expect(rateLimitException.code, 429);
      });

      test('parses retry-after header into DateTime', () {
        resource = createResource();
        final response = http.Response(
          '{"error": "rate limited"}',
          429,
          headers: {'retry-after': '60'},
        );

        final exception = resource.testMapHttpError(response);

        expect(exception, isA<RateLimitException>());
        final rateLimitException = exception as RateLimitException;
        expect(rateLimitException.retryAfter, isNotNull);
        // Should be approximately 60 seconds from now
        final diff = rateLimitException.retryAfter!.difference(DateTime.now());
        expect(diff.inSeconds, closeTo(60, 2));
      });

      test('handles missing retry-after header', () {
        resource = createResource();
        final response = http.Response('{"error": "rate limited"}', 429);

        final exception = resource.testMapHttpError(response);

        expect(exception, isA<RateLimitException>());
        final rateLimitException = exception as RateLimitException;
        expect(rateLimitException.retryAfter, isNull);
      });
    });

    group('prepareStreamingRequest', () {
      test('applies BearerTokenCredentials to request header', () async {
        final authProvider = MockAuthProvider();
        when(authProvider.getCredentials).thenAnswer(
          (_) async => const BearerTokenCredentials('test-token'),
        );

        resource = createResource(authProvider: authProvider);
        final request = http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        );

        final prepared = await resource.prepareStreamingRequest(request);

        expect(prepared.headers['Authorization'], 'Bearer test-token');
      });

      test('passes through request unchanged with NoAuthCredentials', () async {
        final authProvider = MockAuthProvider();
        when(authProvider.getCredentials).thenAnswer(
          (_) async => const NoAuthCredentials(),
        );

        resource = createResource(authProvider: authProvider);
        final request = http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        );

        final prepared = await resource.prepareStreamingRequest(request);

        expect(prepared.headers.containsKey('Authorization'), isFalse);
      });

      test('passes through request unchanged with null credentials', () async {
        resource = createResource();
        final request = http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        );

        final prepared = await resource.prepareStreamingRequest(request);

        expect(prepared.headers.containsKey('Authorization'), isFalse);
      });

      test('adds X-Request-ID header when not present', () async {
        resource = createResource();
        final request = http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        );

        final prepared = await resource.prepareStreamingRequest(request);

        expect(prepared.headers['X-Request-ID'], isNotNull);
        expect(prepared.headers['X-Request-ID'], isNotEmpty);
      });

      test('preserves existing X-Request-ID header', () async {
        resource = createResource();
        final request = http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        )..headers['X-Request-ID'] = 'existing-id';

        final prepared = await resource.prepareStreamingRequest(request);

        expect(prepared.headers['X-Request-ID'], 'existing-id');
      });
    });

    group('sendStreamingRequest', () {
      test('returns StreamedResponse for success status', () async {
        resource = createResource();
        final request = http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        )..headers['X-Request-ID'] = 'test-id';

        final mockStreamedResponse = http.StreamedResponse(
          Stream.value([]),
          200,
        );
        when(() => mockHttpClient.send(any()))
            .thenAnswer((_) async => mockStreamedResponse);

        final response = await resource.sendStreamingRequest(request);

        expect(response.statusCode, 200);
      });

      test('throws ApiException for 400+ status codes', () {
        resource = createResource();
        final request = http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        )..headers['X-Request-ID'] = 'test-id';

        final mockStreamedResponse = http.StreamedResponse(
          Stream.value('{"error": "Bad request"}'.codeUnits),
          400,
        );
        when(() => mockHttpClient.send(any()))
            .thenAnswer((_) async => mockStreamedResponse);

        expect(
          () => resource.sendStreamingRequest(request),
          throwsA(isA<ApiException>()),
        );
      });

      test('throws RateLimitException for 429 status', () {
        resource = createResource();
        final request = http.Request(
          'POST',
          Uri.parse('http://localhost:11434/api/chat'),
        )..headers['X-Request-ID'] = 'test-id';

        final mockStreamedResponse = http.StreamedResponse(
          Stream.value('{"error": "rate limited"}'.codeUnits),
          429,
          headers: {'retry-after': '30'},
        );
        when(() => mockHttpClient.send(any()))
            .thenAnswer((_) async => mockStreamedResponse);

        expect(
          () => resource.sendStreamingRequest(request),
          throwsA(isA<RateLimitException>()),
        );
      });
    });
  });
}
