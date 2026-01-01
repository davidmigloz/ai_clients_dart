import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ApiKeyProvider', () {
    test('getCredentials returns ApiKeyCredentials with correct key', () async {
      const provider = ApiKeyProvider('test-api-key');

      final credentials = await provider.getCredentials();

      expect(credentials, isA<ApiKeyCredentials>());
      expect((credentials as ApiKeyCredentials).apiKey, 'test-api-key');
    });

    test('getCredentials returns same key on multiple calls', () async {
      const provider = ApiKeyProvider('my-key');

      final creds1 = await provider.getCredentials();
      final creds2 = await provider.getCredentials();

      expect((creds1 as ApiKeyCredentials).apiKey, 'my-key');
      expect((creds2 as ApiKeyCredentials).apiKey, 'my-key');
    });

    test('handles empty API key', () async {
      const provider = ApiKeyProvider('');

      final credentials = await provider.getCredentials();

      expect(credentials, isA<ApiKeyCredentials>());
      expect((credentials as ApiKeyCredentials).apiKey, '');
    });
  });

  group('NoAuthProvider', () {
    test('getCredentials returns NoAuthCredentials', () async {
      const provider = NoAuthProvider();

      final credentials = await provider.getCredentials();

      expect(credentials, isA<NoAuthCredentials>());
    });

    test('getCredentials returns same type on multiple calls', () async {
      const provider = NoAuthProvider();

      final creds1 = await provider.getCredentials();
      final creds2 = await provider.getCredentials();

      expect(creds1, isA<NoAuthCredentials>());
      expect(creds2, isA<NoAuthCredentials>());
    });
  });

  group('AuthCredentials', () {
    test('ApiKeyCredentials stores api key', () {
      const credentials = ApiKeyCredentials('secret-key');

      expect(credentials.apiKey, 'secret-key');
    });

    test('NoAuthCredentials can be created', () {
      const credentials = NoAuthCredentials();

      expect(credentials, isA<AuthCredentials>());
    });

    test('credentials are AuthCredentials subtype', () {
      const apiKey = ApiKeyCredentials('key');
      const noAuth = NoAuthCredentials();

      expect(apiKey, isA<AuthCredentials>());
      expect(noAuth, isA<AuthCredentials>());
    });
  });
}
