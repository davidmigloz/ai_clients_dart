import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart_admin.dart';
import 'package:test/test.dart';

void main() {
  test(
    'project tier retrieval and each partial update use the Admin route',
    () async {
      final requests = <http.Request>[];
      final client = _adminClient((request) async {
        requests.add(request);
        expect(request.url.pathSegments, [
          'proxy',
          'v1',
          'organization',
          'projects',
          'project/with % ?',
          'service_tier_settings',
        ]);
        expect(
          request.headers['authorization'],
          'Bearer test-admin-authorization',
        );
        expect(request.followRedirects, isFalse);
        return _ok({
          'object': 'project.service_tier_settings',
          'default': 'fast',
          'enabled_tiers': requests.length == 1 ? 'all' : ['flex', 'ultrafast'],
        });
      });
      final tiers = client.organization.projects.serviceTierSettings;
      expect(tiers, same(client.organization.projects.serviceTierSettings));
      final before = await tiers.retrieve('project/with % ?');
      expect(before.defaultTier, ProjectDefaultServiceTier.fast);
      expect(before.enabledTiers, const ProjectEnabledServiceTiers.all());
      expect(requests.single.method, 'GET');
      expect(requests.single.body, isEmpty);

      await tiers.update(
        'project/with % ?',
        UpdateProjectServiceTierSettingsRequest(
          defaultTier: ProjectDefaultServiceTier.standard,
        ),
        additionalHeaders: const {'X-Caller': 'fixture'},
      );
      expect(requests[1].method, 'POST');
      expect(requests[1].headers['x-caller'], 'fixture');
      expect(jsonDecode(requests[1].body), {'default': 'standard'});

      final after = await tiers.update(
        'project/with % ?',
        UpdateProjectServiceTierSettingsRequest(
          enabledTiers: ProjectEnabledServiceTiers.selected(const []),
        ),
      );
      expect(jsonDecode(requests[2].body), {'enabled_tiers': <Object>[]});
      expect((after.enabledTiers as SelectedProjectServiceTiers).tiers, [
        ProjectOptionalServiceTier.flex,
        ProjectOptionalServiceTier.ultrafast,
      ]);
      expect(ProjectServiceTierSettings.fromJson(after.toJson()), after);
      expect(
        ProjectServiceTierSettings.fromJson(after.toJson()).hashCode,
        after.hashCode,
      );
      client.close();
      expect(() => tiers.retrieve('project/with % ?'), throwsStateError);
    },
  );

  test(
    'project tiers preserve unknown response values and reject invalid writes',
    () {
      final response = ProjectServiceTierSettings.fromJson(const {
        'object': 'project.service_tier_settings',
        'default': 'future_default',
        'enabled_tiers': ['future_optional'],
      });
      expect(response.defaultTier.value, 'future_default');
      expect(response.enabledTiers.toJson(), ['future_optional']);
      expect(
        () => UpdateProjectServiceTierSettingsRequest(
          defaultTier: response.defaultTier,
        ),
        throwsFormatException,
      );
      expect(
        () => UpdateProjectServiceTierSettingsRequest(
          enabledTiers: response.enabledTiers,
        ),
        throwsFormatException,
      );
      expect(
        UpdateProjectServiceTierSettingsRequest.new,
        throwsFormatException,
      );
      expect(
        () => UpdateProjectServiceTierSettingsRequest.fromJson(const {
          'default': null,
          'enabled_tiers': 'all',
        }),
        throwsFormatException,
      );
      final update = UpdateProjectServiceTierSettingsRequest(
        defaultTier: ProjectDefaultServiceTier.scale,
        enabledTiers: const ProjectEnabledServiceTiers.all(),
      );
      expect(update.copyWith(defaultTier: null).toJson(), {
        'enabled_tiers': 'all',
      });
      expect(
        UpdateProjectServiceTierSettingsRequest.fromJson(update.toJson()),
        update,
      );
    },
  );

  test('OCI key creation, hydration and bodyless validation', () async {
    final calls = <http.Request>[];
    final client = _adminClient((request) async {
      calls.add(request);
      if (request.url.path.endsWith('/validate')) {
        return _ok(const {'status': 'valid'});
      }
      return _ok(const {
        'object': 'organization.external_key',
        'id': 'key_fixture',
        'type': 'oci',
        'name': 'Oracle key',
        'purposes': 'future_extra',
        'api_project_ids': <String>[],
        'workspace_id': 'ws_fixture',
        'created_at': 1,
        'region': 'us-fixture-1',
        'vault_ocid': 'vault-fixture',
        'key_ocid': 'key-fixture',
        'key_version_ocid': 'version-fixture',
      });
    });
    final keys = client.organization.externalKeys;
    final registration =
        ExternalKeyParams.fromJson(const {
              'type': 'oci',
              'name': 'Oracle key',
              'region': 'us-fixture-1',
              'vault_ocid': 'vault-fixture',
              'key_ocid': 'key-fixture',
              'purpose': 'psp_decryption',
              'key_version_ocid': 'version-fixture',
            })
            as OciExternalKeyParams;
    final key = await keys.create(registration);
    expect(calls.single.url.path, '/proxy/v1/organization/external_keys');
    expect(jsonDecode(calls.single.body), registration.toJson());
    expect(key.vaultOcid, 'vault-fixture');
    expect(key.keyVersionOcid, 'version-fixture');
    expect(key.rawJson, {'purposes': 'future_extra'});
    expect(ExternalKey.fromJson(key.toJson()), key);
    expect(
      key.copyWith(keyVersionOcid: null).toJson(),
      isNot(contains('key_version_ocid')),
    );
    expect(key.toString(), isNot(contains('version-fixture')));
    expect(
      registration.copyWith(keyVersionOcid: null).toJson(),
      isNot(contains('key_version_ocid')),
    );

    expect((await keys.validate(key.id)).status, 'valid');
    expect(
      calls.last.url.path,
      '/proxy/v1/organization/external_keys/key_fixture/validate',
    );
    expect(calls.last.method, 'POST');
    expect(calls.last.body, isEmpty);
    expect(() => registration.copyWith(region: ''), throwsFormatException);
    expect(
      () => registration.copyWith(vaultOcid: 'x' * 513),
      throwsFormatException,
    );
    expect(
      () => ExternalKeyParams.fromJson(const {'type': 'oci'}),
      throwsFormatException,
    );
  });

  test(
    'Admin permission failure preserves status and redacts diagnostics',
    () async {
      final client = _adminClient(
        (_) async => http.Response(
          jsonEncode(const {
            'error': {
              'message': 'restricted-fixture-id',
              'code': 'permission_denied',
            },
          }),
          403,
        ),
      );
      await expectLater(
        client.organization.projects.serviceTierSettings.retrieve(
          'project-fixture',
        ),
        throwsA(
          isA<PermissionDeniedException>()
              .having((error) => error.statusCode, 'statusCode', 403)
              .having((error) => error.code, 'code', 'permission_denied')
              .having(
                (error) => error.toString(),
                'diagnostics',
                isNot(contains('restricted-fixture-id')),
              ),
        ),
      );
    },
  );
}

OpenAIAdminClient _adminClient(
  Future<http.Response> Function(http.Request) handler,
) {
  final transport = MockClient(handler);
  final client = OpenAIAdminClient(
    config: OpenAIAdminConfig(
      authProvider: const ApiKeyProvider('test-admin-authorization'),
      baseUrl: 'https://fixture.invalid/proxy/v1',
    ),
    httpClient: transport,
  );
  addTearDown(transport.close);
  addTearDown(client.close);
  return client;
}

http.Response _ok(Map<String, dynamic> json) => http.Response(
  jsonEncode(json),
  200,
  headers: const {'content-type': 'application/json'},
);
