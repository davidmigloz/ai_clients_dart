import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ApiException', () {
    test('stores code and message', () {
      const exception = ApiException(code: 400, message: 'Bad request');

      expect(exception.code, 400);
      expect(exception.message, 'Bad request');
    });

    test('toString includes code and message', () {
      const exception = ApiException(code: 500, message: 'Internal error');

      final str = exception.toString();

      expect(str, contains('500'));
      expect(str, contains('Internal error'));
    });

    test('can include details', () {
      const exception = ApiException(
        code: 400,
        message: 'Error',
        details: ['detail1', 'detail2'],
      );

      expect(exception.details, hasLength(2));
    });

    test('can include request/response metadata', () {
      final exception = ApiException(
        code: 400,
        message: 'Error',
        requestMetadata: RequestMetadata(
          method: 'POST',
          url: Uri.parse('https://api.anthropic.com'),
          headers: {},
          correlationId: 'req_123',
          timestamp: DateTime.now(),
        ),
        responseMetadata: const ResponseMetadata(
          statusCode: 400,
          headers: {},
          bodyExcerpt: '{"error": "bad request"}',
          latency: Duration(milliseconds: 100),
        ),
      );

      expect(exception.requestMetadata, isNotNull);
      expect(exception.responseMetadata, isNotNull);
    });
  });

  group('AuthenticationException', () {
    test('stores message', () {
      const exception = AuthenticationException(message: 'Invalid API key');

      expect(exception.message, 'Invalid API key');
    });

    test('toString includes message', () {
      const exception = AuthenticationException(message: 'Unauthorized');

      expect(exception.toString(), contains('Unauthorized'));
    });

    test('is an AnthropicException', () {
      const exception = AuthenticationException(message: 'Error');

      expect(exception, isA<AnthropicException>());
    });
  });

  group('RateLimitException', () {
    test('stores code, message, and optional retryAfter', () {
      final retryTime = DateTime.now().add(const Duration(seconds: 60));
      final exception = RateLimitException(
        code: 429,
        message: 'Too many requests',
        retryAfter: retryTime,
      );

      expect(exception.code, 429);
      expect(exception.message, 'Too many requests');
      expect(exception.retryAfter, retryTime);
    });

    test('is an ApiException', () {
      const exception = RateLimitException(code: 429, message: 'Rate limited');

      expect(exception, isA<ApiException>());
    });

    test('toString includes retry info when present', () {
      final exception = RateLimitException(
        code: 429,
        message: 'Too many requests',
        retryAfter: DateTime(2025, 1, 1, 12, 0, 0),
      );

      final str = exception.toString();

      expect(str, contains('429'));
      expect(str, contains('retry after'));
    });
  });

  group('ValidationException', () {
    test('stores message and field errors', () {
      const exception = ValidationException(
        message: 'Validation failed',
        fieldErrors: {
          'model': ['Model is required'],
          'messages': ['Messages cannot be empty'],
        },
      );

      expect(exception.message, 'Validation failed');
      expect(exception.fieldErrors, hasLength(2));
      expect(exception.fieldErrors['model'], contains('Model is required'));
    });

    test('toString includes message and fields', () {
      const exception = ValidationException(
        message: 'Invalid input',
        fieldErrors: {
          'field': ['error'],
        },
      );

      final str = exception.toString();

      expect(str, contains('Invalid input'));
      expect(str, contains('field'));
    });
  });

  group('TimeoutException', () {
    test('stores message, timeout and elapsed', () {
      const exception = TimeoutException(
        message: 'Request timed out',
        timeout: Duration(seconds: 30),
        elapsed: Duration(seconds: 30),
      );

      expect(exception.message, 'Request timed out');
      expect(exception.timeout, const Duration(seconds: 30));
      expect(exception.elapsed, const Duration(seconds: 30));
    });
  });

  group('AbortedException', () {
    test('stores message', () {
      final exception = AbortedException(
        message: 'Request was aborted',
        correlationId: 'req_123',
        timestamp: DateTime.now(),
        stage: AbortionStage.duringRequest,
      );

      expect(exception.message, 'Request was aborted');
    });

    test('is an AnthropicException', () {
      final exception = AbortedException(
        message: 'Aborted',
        correlationId: 'req_456',
        timestamp: DateTime.now(),
        stage: AbortionStage.beforeRequest,
      );

      expect(exception, isA<AnthropicException>());
    });
  });

  group('RequestMetadata', () {
    test('stores all fields', () {
      final timestamp = DateTime.now();
      final metadata = RequestMetadata(
        method: 'POST',
        url: Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {'Content-Type': 'application/json'},
        correlationId: 'req_abc123',
        timestamp: timestamp,
        attemptNumber: 2,
      );

      expect(metadata.method, 'POST');
      expect(metadata.url.toString(), contains('anthropic.com'));
      expect(metadata.headers['Content-Type'], 'application/json');
      expect(metadata.correlationId, 'req_abc123');
      expect(metadata.timestamp, timestamp);
      expect(metadata.attemptNumber, 2);
    });

    test('attemptNumber defaults to 0', () {
      final metadata = RequestMetadata(
        method: 'GET',
        url: Uri.parse('https://api.test.com'),
        headers: {},
        correlationId: 'id',
        timestamp: DateTime.now(),
      );

      expect(metadata.attemptNumber, 0);
    });
  });

  group('ResponseMetadata', () {
    test('stores all fields', () {
      const metadata = ResponseMetadata(
        statusCode: 200,
        headers: {'x-request-id': 'resp_123'},
        bodyExcerpt: '{"id": "msg_123"}',
        latency: Duration(milliseconds: 250),
      );

      expect(metadata.statusCode, 200);
      expect(metadata.headers['x-request-id'], 'resp_123');
      expect(metadata.bodyExcerpt, contains('msg_123'));
      expect(metadata.latency, const Duration(milliseconds: 250));
    });
  });
}
