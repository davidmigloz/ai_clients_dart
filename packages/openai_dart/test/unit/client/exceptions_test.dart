import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ApiException', () {
    test('creates with required fields', () {
      const exception = ApiException(
        message: 'Something went wrong',
        statusCode: 500,
      );

      expect(exception.message, 'Something went wrong');
      expect(exception.statusCode, 500);
      expect(exception.type, isNull);
      expect(exception.param, isNull);
      expect(exception.code, isNull);
      expect(exception.requestId, isNull);
    });

    test('creates with all fields', () {
      const exception = ApiException(
        message: 'Invalid request',
        statusCode: 400,
        type: 'invalid_request_error',
        param: 'model',
        code: 'model_not_found',
        requestId: 'req_123',
        body: {'error': 'details'},
      );

      expect(exception.message, 'Invalid request');
      expect(exception.statusCode, 400);
      expect(exception.type, 'invalid_request_error');
      expect(exception.param, 'model');
      expect(exception.code, 'model_not_found');
      expect(exception.requestId, 'req_123');
      expect(exception.body, {'error': 'details'});
    });

    test('toString includes status and type', () {
      const exception = ApiException(
        message: 'Error',
        statusCode: 400,
        type: 'test_error',
        requestId: 'req_456',
      );

      final str = exception.toString();

      expect(str, contains('status: 400'));
      expect(str, contains('type: test_error'));
      expect(str, contains('request_id: req_456'));
    });

    test('toString includes param when present', () {
      const exception = ApiException(
        message: 'Invalid parameter',
        statusCode: 400,
        type: 'invalid_request_error',
        param: 'model',
        code: 'invalid_value',
      );

      final str = exception.toString();

      expect(str, contains('status: 400'));
      expect(str, contains('type: invalid_request_error'));
      expect(str, contains('param: model'));
      expect(str, contains('code: invalid_value'));
    });
  });

  group('AuthenticationException', () {
    test('has status code 401', () {
      const exception = AuthenticationException(message: 'Invalid API key');

      expect(exception.statusCode, 401);
    });

    test('toString shows exception type', () {
      const exception = AuthenticationException(message: 'Invalid API key');

      expect(exception.toString(), 'AuthenticationException: Invalid API key');
    });
  });

  group('PermissionDeniedException', () {
    test('has status code 403', () {
      const exception = PermissionDeniedException(message: 'Access denied');

      expect(exception.statusCode, 403);
    });
  });

  group('NotFoundException', () {
    test('has status code 404', () {
      const exception = NotFoundException(message: 'Model not found');

      expect(exception.statusCode, 404);
    });
  });

  group('RateLimitException', () {
    test('has status code 429', () {
      const exception = RateLimitException(message: 'Rate limit exceeded');

      expect(exception.statusCode, 429);
    });

    test('includes retry after duration', () {
      const exception = RateLimitException(
        message: 'Rate limit exceeded',
        retryAfter: Duration(seconds: 30),
      );

      expect(exception.retryAfter, const Duration(seconds: 30));
      expect(exception.toString(), contains('retry after: 30s'));
    });
  });

  group('BadRequestException', () {
    test('has status code 400', () {
      const exception = BadRequestException(message: 'Bad request');

      expect(exception.statusCode, 400);
    });
  });

  group('InternalServerException', () {
    test('has 5xx status code', () {
      const exception = InternalServerException(
        message: 'Server error',
        statusCode: 503,
      );

      expect(exception.statusCode, 503);
    });
  });

  group('RequestTimeoutException', () {
    test('creates with message', () {
      const exception = RequestTimeoutException(message: 'Request timed out');

      expect(exception.message, 'Request timed out');
      expect(exception.timeout, isNull);
    });

    test('includes timeout duration', () {
      const exception = RequestTimeoutException(
        message: 'Request timed out',
        timeout: Duration(seconds: 30),
      );

      expect(exception.timeout, const Duration(seconds: 30));
      expect(exception.toString(), contains('after 30s'));
    });
  });

  group('ConnectionException', () {
    test('creates with message', () {
      const exception = ConnectionException(message: 'Connection failed');

      expect(exception.message, 'Connection failed');
    });

    test('includes URL when provided', () {
      const exception = ConnectionException(
        message: 'Connection failed',
        url: 'https://api.openai.com',
      );

      expect(exception.url, 'https://api.openai.com');
      expect(exception.toString(), contains('url: https://api.openai.com'));
    });
  });

  group('ParseException', () {
    test('creates with message', () {
      const exception = ParseException(message: 'Failed to parse response');

      expect(exception.message, 'Failed to parse response');
    });

    test('includes response body when provided', () {
      const exception = ParseException(
        message: 'Failed to parse response',
        responseBody: '{"invalid": json}',
      );

      expect(exception.responseBody, '{"invalid": json}');
    });
  });

  group('StreamException', () {
    test('creates with message', () {
      const exception = StreamException(message: 'Stream interrupted');

      expect(exception.message, 'Stream interrupted');
    });

    test('includes partial data when provided', () {
      const exception = StreamException(
        message: 'Stream interrupted',
        partialData: 'partial response...',
      );

      expect(exception.partialData, 'partial response...');
    });
  });

  group('createApiException', () {
    test('creates BadRequestException for 400', () {
      final exception = createApiException(
        statusCode: 400,
        message: 'Bad request',
      );

      expect(exception, isA<BadRequestException>());
      expect(exception.statusCode, 400);
    });

    test('creates AuthenticationException for 401', () {
      final exception = createApiException(
        statusCode: 401,
        message: 'Unauthorized',
      );

      expect(exception, isA<AuthenticationException>());
      expect(exception.statusCode, 401);
    });

    test('creates PermissionDeniedException for 403', () {
      final exception = createApiException(
        statusCode: 403,
        message: 'Forbidden',
      );

      expect(exception, isA<PermissionDeniedException>());
      expect(exception.statusCode, 403);
    });

    test('creates NotFoundException for 404', () {
      final exception = createApiException(
        statusCode: 404,
        message: 'Not found',
      );

      expect(exception, isA<NotFoundException>());
      expect(exception.statusCode, 404);
    });

    test('creates ConflictException for 409', () {
      final exception = createApiException(
        statusCode: 409,
        message: 'Conflict',
      );

      expect(exception, isA<ConflictException>());
      expect(exception.statusCode, 409);
    });

    test('creates UnprocessableEntityException for 422', () {
      final exception = createApiException(
        statusCode: 422,
        message: 'Unprocessable',
      );

      expect(exception, isA<UnprocessableEntityException>());
      expect(exception.statusCode, 422);
    });

    test('creates RateLimitException for 429', () {
      final exception = createApiException(
        statusCode: 429,
        message: 'Rate limited',
        retryAfter: const Duration(seconds: 60),
      );

      expect(exception, isA<RateLimitException>());
      expect(exception.statusCode, 429);
      expect(
        (exception as RateLimitException).retryAfter,
        const Duration(seconds: 60),
      );
    });

    test('creates InternalServerException for 5xx', () {
      final exception500 = createApiException(
        statusCode: 500,
        message: 'Internal error',
      );
      final exception502 = createApiException(
        statusCode: 502,
        message: 'Bad gateway',
      );
      final exception503 = createApiException(
        statusCode: 503,
        message: 'Service unavailable',
      );

      expect(exception500, isA<InternalServerException>());
      expect(exception502, isA<InternalServerException>());
      expect(exception503, isA<InternalServerException>());
    });

    test('creates generic ApiException for unknown status', () {
      final exception = createApiException(
        statusCode: 418,
        message: "I'm a teapot",
      );

      expect(exception, isA<ApiException>());
      expect(exception.runtimeType.toString(), 'ApiException');
      expect(exception.statusCode, 418);
    });

    test('passes through all optional parameters', () {
      final exception = createApiException(
        statusCode: 400,
        message: 'Error',
        type: 'error_type',
        code: 'error_code',
        param: 'param_name',
        requestId: 'req_123',
        body: {'key': 'value'},
      );

      expect(exception.type, 'error_type');
      expect(exception.code, 'error_code');
      expect(exception.param, 'param_name');
      expect(exception.requestId, 'req_123');
      expect(exception.body, {'key': 'value'});
    });
  });
}
