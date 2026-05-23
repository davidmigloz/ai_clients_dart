import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  const httpResponseJson = {
    'status_code': 401,
    'content_type': 'application/json',
    'body': '{"error":"invalid_token"}',
    'body_truncated': false,
  };

  group('RefreshHttpResponse', () {
    test('round-trips', () {
      final r = RefreshHttpResponse.fromJson(httpResponseJson);
      expect(r.statusCode, 401);
      expect(r.contentType, 'application/json');
      expect(r.bodyTruncated, isFalse);
      expect(r.toJson(), httpResponseJson);
    });
  });

  group('RefreshObject', () {
    test('round-trips with httpResponse set', () {
      final json = {'status': 'failed', 'http_response': httpResponseJson};
      final r = RefreshObject.fromJson(json);
      expect(r.status, CredentialRefreshStatus.failed);
      expect(r.httpResponse, isNotNull);
      expect(r.toJson(), json);
    });

    test('emits http_response key as null when unset', () {
      const r = RefreshObject(status: CredentialRefreshStatus.succeeded);
      expect(r.httpResponse, isNull);
      expect(r.toJson().containsKey('http_response'), isTrue);
      expect(r.toJson()['http_response'], isNull);
    });

    test('copyWith clears httpResponse with explicit null', () {
      final r = RefreshObject.fromJson(const {
        'status': 'failed',
        'http_response': httpResponseJson,
      });
      expect(r.copyWith(httpResponse: null).httpResponse, isNull);
      // Omitting preserves it.
      expect(
        r.copyWith(status: CredentialRefreshStatus.succeeded).httpResponse,
        isNotNull,
      );
    });
  });

  group('McpProbe', () {
    test('round-trips with httpResponse set', () {
      final json = {'method': 'initialize', 'http_response': httpResponseJson};
      final p = McpProbe.fromJson(json);
      expect(p.method, 'initialize');
      expect(p.httpResponse, isNotNull);
      expect(p.toJson(), json);
    });

    test('emits http_response key as null when unset', () {
      const p = McpProbe(method: 'tools/list');
      expect(p.toJson().containsKey('http_response'), isTrue);
      expect(p.toJson()['http_response'], isNull);
    });
  });

  group('CredentialValidationStatus', () {
    test('round-trips known values', () {
      for (final s in CredentialValidationStatus.values) {
        expect(CredentialValidationStatus.fromJson(s.value), s);
      }
    });

    test('unknown value falls back to unknown', () {
      expect(
        CredentialValidationStatus.fromJson('something_new'),
        CredentialValidationStatus.unknown,
      );
    });
  });

  group('CredentialRefreshStatus', () {
    test('round-trips known values', () {
      for (final s in CredentialRefreshStatus.values) {
        expect(CredentialRefreshStatus.fromJson(s.value), s);
      }
    });

    test('maps snake_case spec values', () {
      expect(
        CredentialRefreshStatus.fromJson('connect_error'),
        CredentialRefreshStatus.connectError,
      );
      expect(
        CredentialRefreshStatus.fromJson('no_refresh_token'),
        CredentialRefreshStatus.noRefreshToken,
      );
    });

    test('unknown value falls back to unknown', () {
      expect(
        CredentialRefreshStatus.fromJson('something_new'),
        CredentialRefreshStatus.unknown,
      );
    });
  });

  group('CredentialValidation', () {
    Map<String, dynamic> json({Object? mcpProbe, Object? refresh}) {
      return {
        'type': 'vault_credential_validation',
        'credential_id': 'vcrd_011CZkZEMt8gZan2iYOQfSkw',
        'vault_id': 'vlt_011CZkZDLs7fYzm1hXNPeRjv',
        'status': 'valid',
        'validated_at': '2026-03-15T10:02:31.000Z',
        'has_refresh_token': true,
        'mcp_probe': mcpProbe,
        'refresh': refresh,
      };
    }

    test('round-trips with mcpProbe and refresh set', () {
      final j = json(
        mcpProbe: {'method': 'initialize', 'http_response': null},
        refresh: {'status': 'succeeded', 'http_response': null},
      );
      final v = CredentialValidation.fromJson(j);
      expect(v.credentialId, 'vcrd_011CZkZEMt8gZan2iYOQfSkw');
      expect(v.vaultId, 'vlt_011CZkZDLs7fYzm1hXNPeRjv');
      expect(v.status, CredentialValidationStatus.valid);
      expect(v.hasRefreshToken, isTrue);
      expect(v.mcpProbe, isA<McpProbe>());
      expect(v.refresh, isA<RefreshObject>());
      expect(v.toJson(), j);
    });

    test('round-trips with mcpProbe and refresh null', () {
      final j = json();
      final v = CredentialValidation.fromJson(j);
      expect(v.mcpProbe, isNull);
      expect(v.refresh, isNull);
      expect(v.toJson(), j);
    });

    test('emits mcp_probe and refresh keys as null when unset', () {
      final v = CredentialValidation(
        credentialId: 'vcrd_1',
        vaultId: 'vlt_1',
        status: CredentialValidationStatus.invalid,
        validatedAt: DateTime.utc(2026, 3, 15),
        hasRefreshToken: false,
      );
      final out = v.toJson();
      expect(out.containsKey('mcp_probe'), isTrue);
      expect(out['mcp_probe'], isNull);
      expect(out.containsKey('refresh'), isTrue);
      expect(out['refresh'], isNull);
    });

    test('copyWith clears nullable fields with explicit null', () {
      final v = CredentialValidation.fromJson(
        json(
          mcpProbe: {'method': 'initialize', 'http_response': null},
          refresh: {'status': 'succeeded', 'http_response': null},
        ),
      );
      final cleared = v.copyWith(mcpProbe: null, refresh: null);
      expect(cleared.mcpProbe, isNull);
      expect(cleared.refresh, isNull);
      // Omitting preserves them.
      expect(v.copyWith(vaultId: 'vlt_x').mcpProbe, isNotNull);
    });
  });
}
