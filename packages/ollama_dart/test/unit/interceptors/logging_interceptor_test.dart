import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:ollama_dart/src/interceptors/interceptor.dart';
import 'package:ollama_dart/src/interceptors/logging_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('LoggingInterceptor', () {
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
        http.Request('POST', Uri.parse('http://localhost:11434/api/chat')),
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
          http.Request('POST', Uri.parse('http://localhost:11434/api/chat')),
        );

        final header = forwarded.request.headers['X-Request-ID'];
        expect(header, isNotEmpty);
        // The wire header and the correlation ID match.
        expect(forwarded.metadata['correlationId'], header);
      },
    );

    test('preserves caller-supplied X-Request-ID when flag is off', () async {
      final request = http.Request(
        'POST',
        Uri.parse('http://localhost:11434/api/chat'),
      )..headers['X-Request-ID'] = 'caller-id';

      final forwarded = await run(createInterceptor(), request);

      expect(forwarded.request.headers['X-Request-ID'], 'caller-id');
      expect(forwarded.metadata['correlationId'], 'caller-id');
    });

    test('preserves caller-supplied X-Request-ID when flag is on', () async {
      final request = http.Request(
        'POST',
        Uri.parse('http://localhost:11434/api/chat'),
      )..headers['X-Request-ID'] = 'caller-id';

      final forwarded = await run(
        createInterceptor(sendRequestIdHeader: true),
        request,
      );

      expect(forwarded.request.headers['X-Request-ID'], 'caller-id');
      expect(forwarded.metadata['correlationId'], 'caller-id');
    });
  });
}
