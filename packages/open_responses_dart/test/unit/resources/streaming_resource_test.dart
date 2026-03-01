import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:open_responses_dart/open_responses_dart.dart';
import 'package:open_responses_dart/src/client/interceptor_chain.dart';
import 'package:open_responses_dart/src/client/request_builder.dart';
import 'package:open_responses_dart/src/resources/base_resource.dart';
import 'package:open_responses_dart/src/resources/streaming_resource.dart';
import 'package:test/test.dart';

/// Concrete implementation of ResourceBase + StreamingResource for testing.
class _TestStreamingResource extends ResourceBase with StreamingResource {
  _TestStreamingResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });
}

/// A mock HTTP client that returns queued responses.
class _MockHttpClient extends http.BaseClient {
  final List<http.StreamedResponse> _responses = [];

  void queueResponse(
    int statusCode,
    String body, {
    Map<String, String> headers = const {},
  }) {
    _responses.add(
      http.StreamedResponse(
        Stream.value(utf8.encode(body)),
        statusCode,
        headers: headers,
      ),
    );
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_responses.isEmpty) {
      throw StateError('No queued response');
    }
    return _responses.removeAt(0);
  }
}

void main() {
  group('StreamingResource', () {
    late _MockHttpClient mockClient;
    late _TestStreamingResource resource;

    _TestStreamingResource createResource({AuthProvider? authProvider}) {
      final config = OpenResponsesConfig(
        baseUrl: 'https://api.example.com/v1',
        authProvider: authProvider,
      );
      return _TestStreamingResource(
        config: config,
        httpClient: mockClient,
        interceptorChain: InterceptorChain(
          interceptors: [],
          httpClient: mockClient,
        ),
        requestBuilder: RequestBuilder(config: config),
      );
    }

    setUp(() {
      mockClient = _MockHttpClient();
      resource = createResource(
        authProvider: const BearerTokenProvider('test-key'),
      );
    });

    group('prepareStreamingRequest', () {
      test('applies BearerToken auth', () async {
        final request = http.Request(
          'POST',
          Uri.parse('https://api.example.com/v1/test'),
        );

        final prepared = await resource.prepareStreamingRequest(request);

        expect(prepared.headers['Authorization'], 'Bearer test-key');
      });

      test('applies no auth when NoAuthCredentials', () async {
        resource = createResource(authProvider: const NoAuthProvider());
        final request = http.Request(
          'POST',
          Uri.parse('https://api.example.com/v1/test'),
        );

        final prepared = await resource.prepareStreamingRequest(request);

        expect(prepared.headers.containsKey('Authorization'), isFalse);
      });

      test('applies no auth when authProvider is null', () async {
        resource = createResource();
        final request = http.Request(
          'POST',
          Uri.parse('https://api.example.com/v1/test'),
        );

        final prepared = await resource.prepareStreamingRequest(request);

        expect(prepared.headers.containsKey('Authorization'), isFalse);
      });

      test('does not overwrite existing Authorization header', () async {
        final request = http.Request(
          'POST',
          Uri.parse('https://api.example.com/v1/test'),
        )..headers['Authorization'] = 'Bearer existing-key';

        final prepared = await resource.prepareStreamingRequest(request);

        expect(prepared.headers['Authorization'], 'Bearer existing-key');
      });
    });

    group('sendStreamingRequest', () {
      test('returns StreamedResponse for success', () async {
        mockClient.queueResponse(200, '{"ok": true}');
        final request = http.Request(
          'POST',
          Uri.parse('https://api.example.com/v1/test'),
        );

        final response = await resource.sendStreamingRequest(request);

        expect(response.statusCode, 200);
      });

      test('throws AuthenticationException for 401', () async {
        mockClient.queueResponse(
          401,
          jsonEncode({
            'error': {'message': 'Invalid API key'},
          }),
        );
        final request = http.Request(
          'POST',
          Uri.parse('https://api.example.com/v1/test'),
        );

        await expectLater(
          () => resource.sendStreamingRequest(request),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('throws RateLimitException for 429', () async {
        mockClient.queueResponse(
          429,
          jsonEncode({
            'error': {'message': 'Rate limit exceeded'},
          }),
        );
        final request = http.Request(
          'POST',
          Uri.parse('https://api.example.com/v1/test'),
        );

        await expectLater(
          () => resource.sendStreamingRequest(request),
          throwsA(isA<RateLimitException>()),
        );
      });

      test('throws ValidationException for 400', () async {
        mockClient.queueResponse(
          400,
          jsonEncode({
            'error': {'message': 'Invalid model', 'param': 'model'},
          }),
        );
        final request = http.Request(
          'POST',
          Uri.parse('https://api.example.com/v1/test'),
        );

        await expectLater(
          () => resource.sendStreamingRequest(request),
          throwsA(isA<ValidationException>()),
        );
      });

      test('throws ApiException for 500', () async {
        mockClient.queueResponse(
          500,
          jsonEncode({
            'error': {'message': 'Internal server error'},
          }),
        );
        final request = http.Request(
          'POST',
          Uri.parse('https://api.example.com/v1/test'),
        );

        await expectLater(
          () => resource.sendStreamingRequest(request),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('mapHttpErrorForStreaming', () {
      test('parses error JSON correctly', () {
        final body = jsonEncode({
          'error': {'message': 'Something went wrong'},
        });

        final exception = resource.mapHttpErrorForStreaming(500, body);

        expect(exception, isA<ApiException>());
        expect(exception.message, 'Something went wrong');
      });

      test('handles empty body', () {
        final exception = resource.mapHttpErrorForStreaming(500, '');

        expect(exception, isA<ApiException>());
        expect(exception.message, 'Unknown error');
      });

      test('handles non-JSON body', () {
        final exception = resource.mapHttpErrorForStreaming(
          500,
          'plain text error',
        );

        expect(exception, isA<ApiException>());
        expect(exception.message, 'plain text error');
      });

      test('parses field errors for 400', () {
        final body = jsonEncode({
          'error': {'message': 'Invalid param', 'param': 'temperature'},
        });

        final exception = resource.mapHttpErrorForStreaming(400, body);

        expect(exception, isA<ValidationException>());
        final validation = exception as ValidationException;
        expect(validation.fieldErrors, {
          'temperature': ['Invalid param'],
        });
      });
    });
  });
}
