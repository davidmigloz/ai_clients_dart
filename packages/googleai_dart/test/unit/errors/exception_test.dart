import 'package:googleai_dart/src/errors/exceptions.dart';
import 'package:test/test.dart';

void main() {
  group('ApiException', () {
    test('creates with required fields', () {
      const exception = ApiException(statusCode: 404, message: 'Not found');

      expect(exception.statusCode, 404);
      expect(exception.message, 'Not found');
      expect(exception.details, isEmpty);
      expect(exception.stackTrace, isNull);
    });

    test('toString includes code and message', () {
      const exception = ApiException(
        statusCode: 500,
        message: 'Internal error',
      );

      expect(exception.toString(), 'ApiException(500): Internal error');
    });
  });

  group('AuthenticationException', () {
    test('has status code 401', () {
      const exception = AuthenticationException(message: 'Invalid API key');

      expect(exception.statusCode, 401);
    });

    test('is an ApiException', () {
      const exception = AuthenticationException(message: 'Unauthorized');

      expect(exception, isA<ApiException>());
    });

    test('is a GoogleAIException', () {
      const exception = AuthenticationException(message: 'Error');

      expect(exception, isA<GoogleAIException>());
    });

    test('toString includes message', () {
      const exception = AuthenticationException(message: 'Invalid API key');

      expect(exception.toString(), 'AuthenticationException: Invalid API key');
    });
  });

  group('ValidationException', () {
    test('creates with field errors', () {
      const exception = ValidationException(
        message: 'Validation failed',
        fieldErrors: {
          'email': ['Invalid format'],
          'age': ['Must be positive'],
        },
      );

      expect(exception.message, 'Validation failed');
      expect(exception.fieldErrors, hasLength(2));
    });
  });

  group('AbortedException', () {
    test('creates with all required fields', () {
      final exception = AbortedException(
        message: 'Request aborted by user',
        correlationId: 'req_123',
        timestamp: DateTime(2025, 1, 1),
        stage: AbortionStage.duringRequest,
      );

      expect(exception.message, 'Request aborted by user');
      expect(exception.correlationId, 'req_123');
      expect(exception.stage, AbortionStage.duringRequest);
      expect(exception.reason, isNull);
    });

    test('creates with optional reason', () {
      final exception = AbortedException(
        message: 'Request aborted',
        correlationId: 'req_456',
        timestamp: DateTime.now(),
        stage: AbortionStage.duringStream,
        reason: 'User navigated away',
      );

      expect(exception.reason, 'User navigated away');
    });

    test('toString includes stage and correlation ID', () {
      final exception = AbortedException(
        message: 'Canceled',
        correlationId: 'req_789',
        timestamp: DateTime.now(),
        stage: AbortionStage.beforeRequest,
      );

      expect(
        exception.toString(),
        contains('AbortedException(AbortionStage.beforeRequest)'),
      );
      expect(exception.toString(), contains('req_789'));
    });

    test('fromHttpException converts correctly', () {
      final httpException = Exception('Network canceled');
      final exception = AbortedException.fromHttpException(
        httpException,
        correlationId: 'req_999',
        stage: AbortionStage.duringResponse,
      );

      expect(exception.correlationId, 'req_999');
      expect(exception.stage, AbortionStage.duringResponse);
      expect(exception.reason, httpException);
    });
  });
}
