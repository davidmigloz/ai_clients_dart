import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CredentialNetworkingParams', () {
    test('unrestricted round-trips', () {
      const json = {'type': 'unrestricted'};
      final n = CredentialNetworkingParams.fromJson(json);
      expect(n, isA<UnrestrictedCredentialNetworkingParams>());
      expect(
        (n as UnrestrictedCredentialNetworkingParams).type,
        'unrestricted',
      );
      expect(n.toJson(), json);
    });

    test('limited round-trips with allowed_hosts', () {
      const json = {
        'type': 'limited',
        'allowed_hosts': ['api.example.com', '*.example.com'],
      };
      final n = CredentialNetworkingParams.fromJson(json);
      expect(n, isA<LimitedCredentialNetworkingParams>());
      final limited = n as LimitedCredentialNetworkingParams;
      expect(limited.type, 'limited');
      expect(limited.allowedHosts, ['api.example.com', '*.example.com']);
      expect(n.toJson(), json);
    });

    test('allowedHosts is unmodifiable', () {
      final n = LimitedCredentialNetworkingParams(
        allowedHosts: const ['a.com'],
      );
      expect(() => n.allowedHosts.add('b.com'), throwsUnsupportedError);
    });

    test('unknown type falls back to Unknown and round-trips', () {
      const json = {
        'type': 'future_mode',
        'nested': {
          'a': 1,
          'b': [2, 3],
        },
      };
      final n = CredentialNetworkingParams.fromJson(json);
      expect(n, isA<UnknownCredentialNetworkingParams>());
      expect((n as UnknownCredentialNetworkingParams).rawJson, json);
      expect(n.toJson(), json);
    });

    test('Unknown variant uses deep equality on raw JSON', () {
      const a = UnknownCredentialNetworkingParams(
        rawJson: {
          'type': 'future_mode',
          'nested': {'a': 1},
        },
      );
      const b = UnknownCredentialNetworkingParams(
        rawJson: {
          'type': 'future_mode',
          'nested': {'a': 1},
        },
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('fromJson validates the discriminator on the concrete variant', () {
      expect(
        () => UnrestrictedCredentialNetworkingParams.fromJson(const {
          'type': 'limited',
        }),
        throwsFormatException,
      );
      expect(
        () => LimitedCredentialNetworkingParams.fromJson(const {
          'type': 'unrestricted',
          'allowed_hosts': <String>[],
        }),
        throwsFormatException,
      );
    });
  });

  group('CredentialNetworkingResponse', () {
    test('unrestricted round-trips', () {
      const json = {'type': 'unrestricted'};
      final n = CredentialNetworkingResponse.fromJson(json);
      expect(n, isA<UnrestrictedCredentialNetworkingResponse>());
      expect(n.toJson(), json);
    });

    test('limited round-trips with allowed_hosts', () {
      const json = {
        'type': 'limited',
        'allowed_hosts': ['api.example.com'],
      };
      final n = CredentialNetworkingResponse.fromJson(json);
      expect(n, isA<LimitedCredentialNetworkingResponse>());
      expect((n as LimitedCredentialNetworkingResponse).allowedHosts, [
        'api.example.com',
      ]);
      expect(n.toJson(), json);
    });

    test('unknown type falls back to Unknown and round-trips', () {
      const json = {
        'type': 'future_mode',
        'nested': {'a': 1},
      };
      final n = CredentialNetworkingResponse.fromJson(json);
      expect(n, isA<UnknownCredentialNetworkingResponse>());
      expect(n.toJson(), json);
    });

    test('fromJson validates the discriminator on the concrete variant', () {
      expect(
        () => UnrestrictedCredentialNetworkingResponse.fromJson(const {
          'type': 'limited',
        }),
        throwsFormatException,
      );
      expect(
        () => LimitedCredentialNetworkingResponse.fromJson(const {
          'type': 'unrestricted',
          'allowed_hosts': <String>[],
        }),
        throwsFormatException,
      );
    });
  });

  group('EnvironmentVariableAuthResponse', () {
    const json = {
      'type': 'environment_variable',
      'secret_name': 'API_KEY',
      'networking': {
        'type': 'limited',
        'allowed_hosts': ['api.example.com'],
      },
    };

    test('CredentialAuth.fromJson dispatches and round-trips', () {
      final a = CredentialAuth.fromJson(json);
      expect(a, isA<EnvironmentVariableAuthResponse>());
      final env = a as EnvironmentVariableAuthResponse;
      expect(env.type, 'environment_variable');
      expect(env.secretName, 'API_KEY');
      expect(env.networking, isA<LimitedCredentialNetworkingResponse>());
      expect(a.toJson(), json);
    });

    test('round-trips with unrestricted networking', () {
      const j = {
        'type': 'environment_variable',
        'secret_name': 'TOKEN',
        'networking': {'type': 'unrestricted'},
      };
      final a = CredentialAuth.fromJson(j);
      expect(
        (a as EnvironmentVariableAuthResponse).networking,
        isA<UnrestrictedCredentialNetworkingResponse>(),
      );
      expect(a.toJson(), j);
    });

    test('copyWith replaces fields', () {
      final a =
          CredentialAuth.fromJson(json) as EnvironmentVariableAuthResponse;
      final updated = a.copyWith(secretName: 'OTHER');
      expect(updated.secretName, 'OTHER');
      expect(updated.networking, a.networking);
    });
  });

  group('EnvironmentVariableCreateParams', () {
    const json = {
      'type': 'environment_variable',
      'secret_name': 'API_KEY',
      'secret_value': 'sk-super-secret-value',
      'networking': {
        'type': 'limited',
        'allowed_hosts': ['api.example.com'],
      },
    };

    test('CredentialCreateAuth.fromJson dispatches and round-trips', () {
      final a = CredentialCreateAuth.fromJson(json);
      expect(a, isA<EnvironmentVariableCreateParams>());
      final env = a as EnvironmentVariableCreateParams;
      expect(env.secretName, 'API_KEY');
      expect(env.secretValue, 'sk-super-secret-value');
      expect(env.networking, isA<LimitedCredentialNetworkingParams>());
      expect(a.toJson(), json);
    });

    test('secret_value is redacted in toString, never leaked verbatim', () {
      final env =
          CredentialCreateAuth.fromJson(json)
              as EnvironmentVariableCreateParams;
      final str = env.toString();
      expect(str, isNot(contains('sk-super-secret-value')));
      expect(str, contains('[redacted]'));
      // secret_name is not a credential — it stays visible.
      expect(str, contains('API_KEY'));
    });
  });

  group('EnvironmentVariableUpdateParams', () {
    test('CredentialUpdateAuth.fromJson dispatches and round-trips', () {
      const json = {
        'type': 'environment_variable',
        'secret_value': 'new-secret',
        'networking': {'type': 'unrestricted'},
      };
      final a = CredentialUpdateAuth.fromJson(json);
      expect(a, isA<EnvironmentVariableUpdateParams>());
      final env = a as EnvironmentVariableUpdateParams;
      expect(env.secretValue, 'new-secret');
      expect(env.networking, isA<UnrestrictedCredentialNetworkingParams>());
      expect(a.toJson(), json);
    });

    test('optional secret_value and networking are omitted when absent', () {
      const json = {'type': 'environment_variable'};
      final a =
          CredentialUpdateAuth.fromJson(json)
              as EnvironmentVariableUpdateParams;
      expect(a.secretValue, isNull);
      expect(a.networking, isNull);
      final out = a.toJson();
      expect(out.containsKey('secret_value'), isFalse);
      expect(out.containsKey('networking'), isFalse);
      expect(out, json);
    });

    test('secret_value is redacted in toString when present', () {
      final a =
          CredentialUpdateAuth.fromJson(const {
                'type': 'environment_variable',
                'secret_value': 'rotate-me',
              })
              as EnvironmentVariableUpdateParams;
      final str = a.toString();
      expect(str, isNot(contains('rotate-me')));
      expect(str, contains('[redacted]'));
    });

    test('toString preserves null secret_value (not "[redacted]")', () {
      const a = EnvironmentVariableUpdateParams();
      final str = a.toString();
      expect(str, contains('secretValue: null'));
      expect(str, isNot(contains('[redacted]')));
    });

    test('copyWith clears secret_value with explicit null', () {
      final a =
          CredentialUpdateAuth.fromJson(const {
                'type': 'environment_variable',
                'secret_value': 'old',
              })
              as EnvironmentVariableUpdateParams;
      final cleared = a.copyWith(secretValue: null);
      expect(cleared.secretValue, isNull);
      expect(cleared.toJson().containsKey('secret_value'), isFalse);
      // Omitting preserves the value.
      expect(a.copyWith(type: 'environment_variable').secretValue, 'old');
    });
  });
}
