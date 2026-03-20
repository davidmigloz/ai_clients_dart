import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ConnectorAuth', () {
    group('ApiKeyAuth', () {
      test('creates with value', () {
        const auth = ApiKeyAuth(value: 'my-api-key');
        expect(auth.type, 'api-key');
        expect(auth.value, 'my-api-key');
      });

      test('serializes to JSON', () {
        const auth = ApiKeyAuth(value: 'my-api-key');
        final json = auth.toJson();
        expect(json['type'], 'api-key');
        expect(json['value'], 'my-api-key');
      });

      test('deserializes from JSON', () {
        final auth = ConnectorAuth.fromJson(const {
          'type': 'api-key',
          'value': 'my-api-key',
        });
        expect(auth, isA<ApiKeyAuth>());
        expect((auth as ApiKeyAuth).value, 'my-api-key');
      });

      test('deserializes directly from JSON', () {
        final auth = ApiKeyAuth.fromJson(const {
          'type': 'api-key',
          'value': 'my-api-key',
        });
        expect(auth.value, 'my-api-key');
      });

      test('equality works correctly', () {
        const auth1 = ApiKeyAuth(value: 'key-a');
        const auth2 = ApiKeyAuth(value: 'key-a');
        const auth3 = ApiKeyAuth(value: 'key-b');

        expect(auth1, equals(auth2));
        expect(auth1.hashCode, equals(auth2.hashCode));
        expect(auth1, isNot(equals(auth3)));
      });

      test('toString does not expose value', () {
        const auth = ApiKeyAuth(value: 'secret');
        expect(auth.toString(), contains('***'));
        expect(auth.toString(), isNot(contains('secret')));
      });

      test('round-trip serialization', () {
        const original = ApiKeyAuth(value: 'test-key');
        final json = original.toJson();
        final restored = ConnectorAuth.fromJson(json) as ApiKeyAuth;
        expect(restored, equals(original));
      });
    });

    group('OAuth2TokenAuth', () {
      test('creates with value', () {
        const auth = OAuth2TokenAuth(value: 'my-token');
        expect(auth.type, 'oauth2-token');
        expect(auth.value, 'my-token');
      });

      test('serializes to JSON', () {
        const auth = OAuth2TokenAuth(value: 'my-token');
        final json = auth.toJson();
        expect(json['type'], 'oauth2-token');
        expect(json['value'], 'my-token');
      });

      test('deserializes from JSON', () {
        final auth = ConnectorAuth.fromJson(const {
          'type': 'oauth2-token',
          'value': 'my-token',
        });
        expect(auth, isA<OAuth2TokenAuth>());
        expect((auth as OAuth2TokenAuth).value, 'my-token');
      });

      test('equality works correctly', () {
        const auth1 = OAuth2TokenAuth(value: 'token-a');
        const auth2 = OAuth2TokenAuth(value: 'token-a');
        const auth3 = OAuth2TokenAuth(value: 'token-b');

        expect(auth1, equals(auth2));
        expect(auth1.hashCode, equals(auth2.hashCode));
        expect(auth1, isNot(equals(auth3)));
      });

      test('toString does not expose value', () {
        const auth = OAuth2TokenAuth(value: 'secret-token');
        expect(auth.toString(), contains('***'));
        expect(auth.toString(), isNot(contains('secret-token')));
      });

      test('round-trip serialization', () {
        const original = OAuth2TokenAuth(value: 'test-token');
        final json = original.toJson();
        final restored = ConnectorAuth.fromJson(json) as OAuth2TokenAuth;
        expect(restored, equals(original));
      });
    });

    group('fromJson', () {
      test('throws for unknown type', () {
        expect(
          () => ConnectorAuth.fromJson(const {'type': 'unknown'}),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}
