import 'package:open_responses_dart/open_responses_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AuthenticationException', () {
    test('has status code 401', () {
      const exception = AuthenticationException(message: 'Invalid API key');

      expect(exception.statusCode, 401);
    });

    test('is an ApiException', () {
      const exception = AuthenticationException(message: 'Unauthorized');

      expect(exception, isA<ApiException>());
    });

    test('is an OpenResponsesException', () {
      const exception = AuthenticationException(message: 'Error');

      expect(exception, isA<OpenResponsesException>());
    });

    test('toString includes message', () {
      const exception = AuthenticationException(message: 'Invalid API key');

      expect(exception.toString(), 'AuthenticationException: Invalid API key');
    });
  });
}
