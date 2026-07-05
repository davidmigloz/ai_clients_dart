import 'package:googleai_dart/src/auth/auth_provider.dart';
import 'package:googleai_dart/src/client/config.dart';
import 'package:googleai_dart/src/client/interceptor_chain.dart';
import 'package:googleai_dart/src/client/request_builder.dart';
import 'package:googleai_dart/src/interceptors/auth_interceptor.dart';
import 'package:googleai_dart/src/interceptors/interceptor.dart';
import 'package:googleai_dart/src/resources/base_resource.dart';
import 'package:googleai_dart/src/resources/streaming_resource.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

/// Minimal resource to exercise [StreamingResource.prepareStreamingRequest].
class _TestStreamingResource extends ResourceBase with StreamingResource {
  _TestStreamingResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });
}

_TestStreamingResource _buildStreamingResource(GoogleAIConfig config) {
  final httpClient = http.Client();
  addTearDown(httpClient.close);
  return _TestStreamingResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: InterceptorChain(
      interceptors: const [],
      httpClient: httpClient,
    ),
    requestBuilder: RequestBuilder(config: config),
  );
}

void main() {
  // Repeated query keys (e.g. carried by a proxy base URL) must survive the
  // auth param being appended - regression tests for the four sites that
  // used to rebuild the query from the collapsing `uri.queryParameters`.
  final requestUrl = Uri.parse('https://example.com/api?k=a&k=b');

  group('AuthInterceptor preserves repeated query keys', () {
    Future<http.BaseRequest> intercept(GoogleAIConfig config) async {
      final interceptor = AuthInterceptor(config: config);
      http.BaseRequest? captured;
      Future<http.Response> mockNext(RequestContext context) async {
        captured = context.request;
        return http.Response('{}', 200);
      }

      final context = RequestContext(
        request: http.Request('POST', requestUrl),
        metadata: {},
      );
      await interceptor.intercept(context, mockNext);
      return captured!;
    }

    test('when adding the key query param', () async {
      const config = GoogleAIConfig(authProvider: ApiKeyProvider('test-key'));

      final request = await intercept(config);

      expect(request.url.queryParameters['key'], equals('test-key'));
      expect(request.url.queryParametersAll['k'], equals(['a', 'b']));
    });

    test('when adding the access_token query param', () async {
      const config = GoogleAIConfig(
        authProvider: EphemeralTokenProvider('test-token'),
      );

      final request = await intercept(config);

      expect(request.url.queryParameters['access_token'], equals('test-token'));
      expect(request.url.queryParametersAll['k'], equals(['a', 'b']));
    });
  });

  group(
    'StreamingResource.prepareStreamingRequest preserves repeated keys',
    () {
      test('when adding the key query param', () async {
        const config = GoogleAIConfig(authProvider: ApiKeyProvider('test-key'));
        final resource = _buildStreamingResource(config);

        final prepared = await resource.prepareStreamingRequest(
          http.Request('POST', requestUrl),
        );

        expect(prepared.url.queryParameters['key'], equals('test-key'));
        expect(prepared.url.queryParametersAll['k'], equals(['a', 'b']));
      });

      test('when adding the access_token query param', () async {
        const config = GoogleAIConfig(
          authProvider: EphemeralTokenProvider('test-token'),
        );
        final resource = _buildStreamingResource(config);

        final prepared = await resource.prepareStreamingRequest(
          http.Request('POST', requestUrl),
        );

        expect(
          prepared.url.queryParameters['access_token'],
          equals('test-token'),
        );
        expect(prepared.url.queryParametersAll['k'], equals(['a', 'b']));
      });
    },
  );
}
