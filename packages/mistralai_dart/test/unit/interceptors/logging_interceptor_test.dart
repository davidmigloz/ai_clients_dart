import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:mistralai_dart/src/interceptors/interceptor.dart';
import 'package:mistralai_dart/src/interceptors/logging_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('LoggingInterceptor', () {
    final url = Uri.parse('https://api.mistral.ai/v1/chat/completions');

    LoggingInterceptor createInterceptor({bool sendRequestIdHeader = false}) {
      return LoggingInterceptor(
        logLevel: Level.OFF,
        redactionList: const [],
        sendRequestIdHeader: sendRequestIdHeader,
      );
    }

    /// Runs the interceptor and returns the context forwarded to `next`.
    Future<RequestContext> run(
      LoggingInterceptor interceptor,
      http.BaseRequest request,
    ) async {
      late RequestContext forwarded;
      await interceptor.intercept(RequestContext(request: request), (
        context,
      ) async {
        forwarded = context;
        return http.Response('', 200);
      });
      return forwarded;
    }

    test('does not send X-Request-ID header by default', () async {
      final forwarded = await run(
        createInterceptor(),
        http.Request('POST', url),
      );

      // No header on the wire (browser/CORS-safe default)...
      expect(forwarded.request.headers.containsKey('X-Request-ID'), isFalse);
      // ...but correlation is still tracked internally.
      expect(forwarded.metadata['correlationId'], isA<String>());
      expect(forwarded.metadata['correlationId'], isNotEmpty);
    });

    test(
      'sends X-Request-ID header when sendRequestIdHeader is true',
      () async {
        final forwarded = await run(
          createInterceptor(sendRequestIdHeader: true),
          http.Request('POST', url),
        );

        final header = forwarded.request.headers['X-Request-ID'];
        expect(header, isNotEmpty);
        // The wire header and the correlation ID match.
        expect(forwarded.metadata['correlationId'], header);
      },
    );

    test(
      'sends X-Request-ID header on multipart requests when enabled',
      () async {
        final forwarded = await run(
          createInterceptor(sendRequestIdHeader: true),
          http.MultipartRequest('POST', url),
        );

        final header = forwarded.request.headers['X-Request-ID'];
        expect(header, isNotEmpty);
        expect(forwarded.metadata['correlationId'], header);
      },
    );

    test(
      'does not send X-Request-ID header on multipart requests by default',
      () async {
        final forwarded = await run(
          createInterceptor(),
          http.MultipartRequest('POST', url),
        );

        expect(forwarded.request.headers.containsKey('X-Request-ID'), isFalse);
        expect(forwarded.metadata['correlationId'], isNotEmpty);
      },
    );

    for (final sendRequestIdHeader in [false, true]) {
      test('preserves caller-supplied X-Request-ID '
          '(sendRequestIdHeader: $sendRequestIdHeader)', () async {
        final request = http.Request('POST', url)
          ..headers['X-Request-ID'] = 'caller-id';

        final forwarded = await run(
          createInterceptor(sendRequestIdHeader: sendRequestIdHeader),
          request,
        );

        expect(forwarded.request.headers['X-Request-ID'], 'caller-id');
        expect(forwarded.metadata['correlationId'], 'caller-id');
      });
    }
  });
}
