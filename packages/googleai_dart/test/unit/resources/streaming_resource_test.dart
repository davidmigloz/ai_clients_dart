import 'dart:async';

import 'package:googleai_dart/src/auth/auth_provider.dart';
import 'package:googleai_dart/src/client/config.dart';
import 'package:googleai_dart/src/client/interceptor_chain.dart';
import 'package:googleai_dart/src/client/request_builder.dart';
import 'package:googleai_dart/src/errors/exceptions.dart';
import 'package:googleai_dart/src/resources/base_resource.dart';
import 'package:googleai_dart/src/resources/streaming_resource.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';
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

  // Expose mapHttpErrorForStreaming for direct testing
  GoogleAIException testMapHttpErrorForStreaming(http.Response response) =>
      mapHttpErrorForStreaming(response);
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
    final config = GoogleAIConfig(
      baseUrl: 'https://generativelanguage.googleapis.com',
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
    group('mapHttpErrorForStreaming', () {
      test('returns ApiException for generic HTTP errors', () {
        resource = createResource();
        final response = http.Response('', 500);

        final exception = resource.testMapHttpErrorForStreaming(response);

        expect(exception, isA<ApiException>());
        final apiException = exception as ApiException;
        expect(apiException.code, 500);
        expect(apiException.message, contains('500'));
      });

      test('extracts error message from nested JSON structure', () {
        resource = createResource();
        final response = http.Response(
          '{"error": {"message": "Model not found", "details": []}}',
          404,
        );

        final exception = resource.testMapHttpErrorForStreaming(response);

        expect(exception, isA<ApiException>());
        final apiException = exception as ApiException;
        expect(apiException.code, 404);
        expect(apiException.message, 'Model not found');
      });

      test('extracts details array from error response', () {
        resource = createResource();
        final response = http.Response(
          '{"error": {"message": "Invalid request", "details": [{"type": "BadRequest"}]}}',
          400,
        );

        final exception = resource.testMapHttpErrorForStreaming(response);

        expect(exception, isA<ApiException>());
        final apiException = exception as ApiException;
        expect(apiException.details, isNotEmpty);
      });

      test('uses body as message for short non-JSON responses', () {
        resource = createResource();
        final response = http.Response('Bad Request', 400);

        final exception = resource.testMapHttpErrorForStreaming(response);

        expect(exception, isA<ApiException>());
        expect(exception.message, 'Bad Request');
      });

      test('returns RateLimitException for 429 status', () {
        resource = createResource();
        final response = http.Response(
          '{"error": {"message": "rate limited"}}',
          429,
        );

        final exception = resource.testMapHttpErrorForStreaming(response);

        expect(exception, isA<RateLimitException>());
        final rateLimitException = exception as RateLimitException;
        expect(rateLimitException.code, 429);
      });

      test('parses retry-after header into DateTime', () {
        resource = createResource();
        final response = http.Response(
          '{"error": {"message": "rate limited"}}',
          429,
          headers: {'retry-after': '60'},
        );

        final exception = resource.testMapHttpErrorForStreaming(response);

        expect(exception, isA<RateLimitException>());
        final rateLimitException = exception as RateLimitException;
        expect(rateLimitException.retryAfter, isNotNull);
        // Should be approximately 60 seconds from now
        final diff = rateLimitException.retryAfter!.difference(DateTime.now());
        expect(diff.inSeconds, closeTo(60, 2));
      });

      test('handles missing retry-after header', () {
        resource = createResource();
        final response = http.Response(
          '{"error": {"message": "rate limited"}}',
          429,
        );

        final exception = resource.testMapHttpErrorForStreaming(response);

        expect(exception, isA<RateLimitException>());
        final rateLimitException = exception as RateLimitException;
        expect(rateLimitException.retryAfter, isNull);
      });
    });

    group('prepareStreamingRequest', () {
      test('applies ApiKeyCredentials via header (default placement)', () async {
        final authProvider = MockAuthProvider();
        when(authProvider.getCredentials).thenAnswer(
          (_) async => const ApiKeyCredentials(
            'test-api-key',
            placement: AuthPlacement.header,
          ),
        );

        resource = createResource(authProvider: authProvider);
        final request = http.Request(
          'POST',
          Uri.parse('https://generativelanguage.googleapis.com/v1/models'),
        );

        final prepared = await resource.prepareStreamingRequest(request);

        expect(prepared.headers['X-Goog-Api-Key'], 'test-api-key');
      });

      test('applies ApiKeyCredentials via query param when specified', () async {
        final authProvider = MockAuthProvider();
        when(authProvider.getCredentials).thenAnswer(
          (_) async => const ApiKeyCredentials(
            'test-api-key',
            placement: AuthPlacement.queryParam,
          ),
        );

        resource = createResource(authProvider: authProvider);
        final request = http.Request(
          'POST',
          Uri.parse('https://generativelanguage.googleapis.com/v1/models'),
        );

        final prepared = await resource.prepareStreamingRequest(request);

        expect(prepared.url.queryParameters['key'], 'test-api-key');
      });

      test('applies BearerTokenCredentials to Authorization header', () async {
        final authProvider = MockAuthProvider();
        when(authProvider.getCredentials).thenAnswer(
          (_) async => const BearerTokenCredentials('test-bearer-token'),
        );

        resource = createResource(authProvider: authProvider);
        final request = http.Request(
          'POST',
          Uri.parse('https://generativelanguage.googleapis.com/v1/models'),
        );

        final prepared = await resource.prepareStreamingRequest(request);

        expect(prepared.headers['Authorization'], 'Bearer test-bearer-token');
      });

      test('applies EphemeralTokenCredentials as query param', () async {
        final authProvider = MockAuthProvider();
        when(authProvider.getCredentials).thenAnswer(
          (_) async => const EphemeralTokenCredentials('ephemeral-token-123'),
        );

        resource = createResource(authProvider: authProvider);
        final request = http.Request(
          'POST',
          Uri.parse('https://generativelanguage.googleapis.com/v1/models'),
        );

        final prepared = await resource.prepareStreamingRequest(request);

        expect(prepared.url.queryParameters['access_token'], 'ephemeral-token-123');
      });

      test('passes through request unchanged with NoAuthCredentials', () async {
        final authProvider = MockAuthProvider();
        when(authProvider.getCredentials).thenAnswer(
          (_) async => const NoAuthCredentials(),
        );

        resource = createResource(authProvider: authProvider);
        final request = http.Request(
          'POST',
          Uri.parse('https://generativelanguage.googleapis.com/v1/models'),
        );

        final prepared = await resource.prepareStreamingRequest(request);

        expect(prepared.headers.containsKey('Authorization'), isFalse);
        expect(prepared.headers.containsKey('X-Goog-Api-Key'), isFalse);
        expect(prepared.url.queryParameters.containsKey('key'), isFalse);
      });

      test('adds X-Request-ID header when not present', () async {
        resource = createResource();
        final request = http.Request(
          'POST',
          Uri.parse('https://generativelanguage.googleapis.com/v1/models'),
        );

        final prepared = await resource.prepareStreamingRequest(request);

        expect(prepared.headers['X-Request-ID'], isNotNull);
        expect(prepared.headers['X-Request-ID'], isNotEmpty);
      });

      test('preserves existing X-Request-ID header', () async {
        resource = createResource();
        final request = http.Request(
          'POST',
          Uri.parse('https://generativelanguage.googleapis.com/v1/models'),
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
          Uri.parse('https://generativelanguage.googleapis.com/v1/models'),
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
          Uri.parse('https://generativelanguage.googleapis.com/v1/models'),
        )..headers['X-Request-ID'] = 'test-id';

        final mockStreamedResponse = http.StreamedResponse(
          Stream.value('{"error": {"message": "Bad request"}}'.codeUnits),
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
          Uri.parse('https://generativelanguage.googleapis.com/v1/models'),
        )..headers['X-Request-ID'] = 'test-id';

        final mockStreamedResponse = http.StreamedResponse(
          Stream.value('{"error": {"message": "rate limited"}}'.codeUnits),
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

    group('streamWithAbortMonitoring', () {
      test('yields all items when no abort', () async {
        resource = createResource();
        final abortCompleter = Completer<void>();
        final sourceItems = [
          {'id': '1', 'value': 'first'},
          {'id': '2', 'value': 'second'},
          {'id': '3', 'value': 'third'},
        ];
        final source = Stream.fromIterable(sourceItems);

        final results = await resource.streamWithAbortMonitoring<Map<String, dynamic>>(
          source: source,
          abortTrigger: abortCompleter.future,
          requestId: 'test-123',
          fromJson: (json) => json,
        ).toList();

        expect(results, hasLength(3));
        expect(results[0]['value'], 'first');
        expect(results[1]['value'], 'second');
        expect(results[2]['value'], 'third');
      });

      test('stops yielding and throws AbortedException when triggered', () async {
        resource = createResource();
        final abortCompleter = Completer<void>();

        // Create a slow stream that we can abort mid-way
        final controller = StreamController<Map<String, dynamic>>();

        final results = <Map<String, dynamic>>[];
        Object? caughtError;

        // Start consuming the stream
        final subscription = resource.streamWithAbortMonitoring<Map<String, dynamic>>(
          source: controller.stream,
          abortTrigger: abortCompleter.future,
          requestId: 'test-456',
          fromJson: (json) => json,
        ).listen(
          results.add,
          onError: (Object error) {
            caughtError = error;
          },
        );

        // Add first item
        controller.add({'id': '1'});
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Abort before more items
        abortCompleter.complete();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Try to add more (should be ignored)
        controller.add({'id': '2'});

        await subscription.cancel();
        await controller.close();

        expect(results, hasLength(1));
        expect(caughtError, isA<AbortedException>());
      });

      test('emits AbortedException with duringStream stage', () async {
        resource = createResource();
        final abortCompleter = Completer<void>();
        final controller = StreamController<Map<String, dynamic>>();

        Object? caughtError;

        final subscription = resource.streamWithAbortMonitoring<Map<String, dynamic>>(
          source: controller.stream,
          abortTrigger: abortCompleter.future,
          requestId: 'test-789',
          fromJson: (json) => json,
        ).listen(
          (_) {},
          onError: (Object error) {
            caughtError = error;
          },
        );

        // Trigger abort
        abortCompleter.complete();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        await subscription.cancel();
        await controller.close();

        expect(caughtError, isA<AbortedException>());
        final abortedException = caughtError! as AbortedException;
        expect(abortedException.stage, AbortionStage.duringStream);
      });

      test('includes requestId in AbortedException', () async {
        resource = createResource();
        final abortCompleter = Completer<void>();
        final controller = StreamController<Map<String, dynamic>>();

        Object? caughtError;

        final subscription = resource.streamWithAbortMonitoring<Map<String, dynamic>>(
          source: controller.stream,
          abortTrigger: abortCompleter.future,
          requestId: 'unique-request-id',
          fromJson: (json) => json,
        ).listen(
          (_) {},
          onError: (Object error) {
            caughtError = error;
          },
        );

        abortCompleter.complete();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        await subscription.cancel();
        await controller.close();

        expect(caughtError, isA<AbortedException>());
        final abortedException = caughtError! as AbortedException;
        expect(abortedException.correlationId, 'unique-request-id');
      });

      test('propagates source stream errors', () async {
        resource = createResource();
        final abortCompleter = Completer<void>();
        final controller = StreamController<Map<String, dynamic>>();

        Object? caughtError;

        final subscription = resource.streamWithAbortMonitoring<Map<String, dynamic>>(
          source: controller.stream,
          abortTrigger: abortCompleter.future,
          requestId: 'test-error',
          fromJson: (json) => json,
        ).listen(
          (_) {},
          onError: (Object error) {
            caughtError = error;
          },
        );

        // Add an error to the source stream
        controller.addError(Exception('Source stream error'));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        await subscription.cancel();
        await controller.close();

        expect(caughtError, isA<Exception>());
        expect(caughtError.toString(), contains('Source stream error'));
      });

      test('applies fromJson converter to each item', () async {
        resource = createResource();
        final abortCompleter = Completer<void>();
        final sourceItems = [
          {'name': 'Alice'},
          {'name': 'Bob'},
        ];
        final source = Stream.fromIterable(sourceItems);

        final results = await resource.streamWithAbortMonitoring<String>(
          source: source,
          abortTrigger: abortCompleter.future,
          requestId: 'test-converter',
          fromJson: (json) => json['name'] as String,
        ).toList();

        expect(results, ['Alice', 'Bob']);
      });
    });
  });
}
