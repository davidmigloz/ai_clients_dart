import 'package:ollama_dart/ollama_dart.dart';
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

    test('is an OllamaException', () {
      const exception = AuthenticationException(message: 'Error');

      expect(exception, isA<OllamaException>());
    });

    test('toString includes message', () {
      const exception = AuthenticationException(message: 'Invalid API key');

      expect(exception.toString(), 'AuthenticationException: Invalid API key');
    });
  });
}
