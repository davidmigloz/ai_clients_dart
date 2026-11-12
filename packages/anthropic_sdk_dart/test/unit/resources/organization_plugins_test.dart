import 'dart:async';
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

const _org = '846567bf-e42d-4f2c-9b94-a381e6e354aa';
const _plugin = 'plugin_fixture';
const _version = 'pluginver_fixture';
const _marketplace = 'marketplace_fixture';
const _group = 'rbac_group_fixture';
const _timestamp = '2026-11-10T20:00:00.000Z';
const _fileBytes = [0, 128, 255, 65];
const _zip = [0x50, 0x4b, 3, 4, 0, 128, 255];
const Map<String, Object?> _payload = {
  'components': [
    {'type': 'skill', 'name': 'example', 'description': null},
  ],
  'content_scan': {'status': 'completed', 'assessment': 'pass', 'reason': null},
  'created_at': _timestamp,
  'created_by': {
    'type': 'user_actor',
    'user_id': 'user_fixture',
    'email_address': null,
  },
  'description': null,
  'display_name': 'Fixture',
  'manifest_version': '1.2.3',
  'reach': 'contained',
};
const Map<String, Object?> _pluginJson = {
  ..._payload,
  'type': 'plugin',
  'id': _plugin,
  'name': 'fixture',
  'latest_version_id': _version,
  'served_version_id': _version,
  'served_version_pinned': false,
  'marketplace_id': _marketplace,
  'owner': {'type': 'organization'},
  'organization_installation_preference': null,
  'organization_installation_preference_inherited': null,
  'updated_at': _timestamp,
};
const Map<String, Object?> _versionJson = {
  ..._payload,
  'type': 'plugin_version',
  'id': _version,
  'plugin_id': _plugin,
  'release_notes': 'Fixture release',
};
const Map<String, Object?> _marketplaceJson = {
  'type': 'plugin_marketplace',
  'id': _marketplace,
  'name': 'Fixture marketplace',
  'owner': {'type': 'organization'},
  'source': 'github',
  'default_installation_preference': null,
  'last_sync_ended_at': null,
  'last_sync_read_sha': null,
  'sync_status': 'in_progress',
  'created_at': _timestamp,
};
const Map<String, Object?> _validation = {
  'type': 'plugin_marketplace_validation_report',
  'valid': false,
  'total_plugin_count': 1,
  'commit_sha': null,
  'ref': 'main',
  'manifest_error': null,
  'manifest_error_code': null,
  'plugin_errors': [
    {
      'name': 'example',
      'error': 'Missing plugin manifest',
      'error_code': 'manifest_missing',
    },
  ],
  'plugin_warnings': [
    {
      'name': 'example',
      'warnings': [
        {'error_code': 'notice', 'message': 'Fixture warning'},
      ],
    },
  ],
};

void main() {
  late AnthropicClient client;
  late _CaptureTransport transport;
  late OrganizationPluginsResource plugins;
  late OrganizationPluginMarketplacesResource marketplaces;

  setUp(() {
    transport = _CaptureTransport();
    client = AnthropicClient(
      config: const AnthropicConfig(
        baseUrl: 'https://proxy.example.test/admin',
        authProvider: ApiKeyProvider('fixture-admin-key'),
        defaultHeaders: {
          'anthropic-beta': 'caller-beta',
          'Anthropic-Workspace-Id': 'wrkspc_ignored',
        },
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    plugins = client.organization.plugins;
    marketplaces = client.organization.pluginMarketplaces;
    addTearDown(client.close);
  });

  test(
    'sends caller betas on JSON, multipart and binary plugin requests',
    () async {
      transport
        ..json(_pluginJson)
        ..json(_validation)
        ..enqueue(_zip, headers: {'content-type': 'application/binary'});
      const betas = ['explicit-beta', 'ce-plugins-2026-09-01'];
      await plugins.retrieve(_plugin, betas: betas);
      await marketplaces.validateArchive(
        PluginUploadFile(path: 'fixture.zip', bytes: _zip),
        betas: betas,
      );
      final bytes = await plugins.versions.download(
        _plugin,
        _version,
        betas: betas,
      );
      expect(bytes, _zip);
      expect(
        transport.requests.map((request) => request.headers['anthropic-beta']),
        everyElement('explicit-beta,ce-plugins-2026-09-01'),
      );
      expect(
        transport.requests[1].headers['content-type'],
        contains('boundary='),
      );
      expect(transport.requests[2].headers['accept'], 'application/binary');
    },
  );

  void sent(
    String method,
    String path, {
    Map<String, String> query = const {},
    Map<String, Object?>? body,
  }) {
    final request = transport.lastRequest;
    expect(request.method, method);
    expect(request.url.path, '/admin/v1/organizations$path');
    expect(request.url.queryParameters, query);
    expect(request.headers['x-api-key'], 'fixture-admin-key');
    expect(request.headers['anthropic-version'], '2026-10-21');
    expect(
      request.headers['anthropic-beta'],
      'caller-beta,ce-plugins-2026-09-01',
    );
    expect(request.headers['anthropic-workspace-id'], isNull);
    expect(request.followRedirects, isFalse);
    if (body != null) {
      expect(jsonDecode(utf8.decode(transport.lastBytes)), body);
    }
  }

  String multipartBody() {
    final request = transport.lastRequest;
    final contentType = http.MediaType.parse(request.headers['content-type']!);
    expect(contentType.mimeType, 'multipart/form-data');
    final boundary = contentType.parameters['boundary'];
    expect(boundary, isNotEmpty);
    final body = latin1.decode(transport.lastBytes);
    expect(body, startsWith('--$boundary\r\n'));
    expect(body, endsWith('--$boundary--\r\n'));
    expect(request.contentLength, transport.lastBytes.length);
    return body;
  }

  test(
    'lists, retrieves, pins and deletes a plugin with documented filters',
    () async {
      transport
        ..json({
          'data': [_pluginJson],
          'next_page': 'opaque+/=',
        })
        ..json(_pluginJson)
        ..json({..._pluginJson, 'served_version_pinned': true})
        ..json({'type': 'plugin_deleted', 'id': _plugin});
      final time = DateTime.parse(_timestamp);
      final page = await plugins.list(
        ownerType: 'user',
        ownerUserId: 'user_fixture',
        marketplaceId: _marketplace,
        createdAtGte: time,
        createdAtLt: time.add(const Duration(days: 1)),
        organizationId: _org,
        limit: 5,
        page: 'previous',
      );
      expect(page.nextPage, 'opaque+/=');
      expect(page.data.single.toJson(), _pluginJson);
      expect(page.data.single.createdBy?.emailAddress, isNull);
      expect(page.data.single.components?.single.name, 'example');
      expect(page.data.single.contentScan?.assessment, 'pass');
      sent(
        'GET',
        '/plugins',
        query: {
          'owner_type': 'user',
          'owner_user_id': 'user_fixture',
          'marketplace_id': _marketplace,
          'created_at[gte]': _timestamp,
          'created_at[lt]': '2026-11-11T20:00:00.000Z',
          'organization_id': _org,
          'limit': '5',
          'page': 'previous',
        },
      );
      expect(
        (await plugins.retrieve(_plugin, organizationId: _org)).id,
        _plugin,
      );
      sent('GET', '/plugins/$_plugin', query: {'organization_id': _org});
      expect(
        (await plugins.update(
          _plugin,
          servedVersionId: _version,
        )).servedVersionPinned,
        isTrue,
      );
      sent('POST', '/plugins/$_plugin', body: {'served_version_id': _version});
      expect((await plugins.delete(_plugin)).id, _plugin);
      sent('DELETE', '/plugins/$_plugin');
    },
  );

  test(
    'uploads plugin and version as abortable repeated files[] parts',
    () async {
      transport
        ..json(_pluginJson)
        ..json(_versionJson);
      final abort = Completer<void>();
      final files = [
        PluginUploadFile(
          path: '.claude-plugin/plugin.json',
          bytes: utf8.encode('{"name":"fixture"}'),
          mimeType: 'application/json',
        ),
        PluginUploadFile(path: 'assets/data.bin', bytes: _fileBytes),
      ];
      final created = await plugins.create(
        files: files,
        marketplaceId: _marketplace,
        releaseNotes: 'First',
        abortTrigger: abort.future,
      );
      expect(created.id, _plugin);
      sent('POST', '/plugins');
      expect(transport.lastRequest, isA<http.Abortable>());
      final first = multipartBody();
      expect(first, contains('name="marketplace_id"\r\n\r\n$_marketplace'));
      expect(first, contains('name="release_notes"\r\n\r\nFirst'));
      expect(
        first,
        contains('name="files[]"; filename=".claude-plugin/plugin.json"'),
      );
      expect(first, contains('name="files[]"; filename="assets/data.bin"'));
      expect(first, isNot(contains('name="files";')));
      expect(first, contains(latin1.decode(_fileBytes)));
      final version = await plugins.versions.create(
        _plugin,
        files: files,
        releaseNotes: 'Second',
        abortTrigger: abort.future,
      );
      expect(version.releaseNotes, 'Fixture release');
      sent('POST', '/plugins/$_plugin/versions');
      final second = multipartBody();
      expect(second, contains('name="release_notes"\r\n\r\nSecond'));
      expect(second, isNot(contains('marketplace_id')));
      expect(second, contains(latin1.decode(_fileBytes)));
    },
  );

  test(
    'lists and retrieves versions, then downloads exact ZIP bytes',
    () async {
      transport
        ..json({
          'data': [_versionJson],
          'next_page': null,
        })
        ..json(_versionJson)
        ..enqueue(_zip, headers: {'content-type': 'application/zip'});
      final versions = plugins.versions;
      final page = await versions.list(
        _plugin,
        organizationId: _org,
        page: 'previous',
      );
      expect(page.nextPage, isNull);
      expect(page.data.single.pluginId, _plugin);
      sent(
        'GET',
        '/plugins/$_plugin/versions',
        query: {'organization_id': _org, 'page': 'previous'},
      );
      expect(
        (await versions.retrieve(_plugin, 'latest', organizationId: _org)).id,
        _version,
      );
      sent(
        'GET',
        '/plugins/$_plugin/versions/latest',
        query: {'organization_id': _org},
      );
      expect(
        await versions.download(_plugin, _version, organizationId: _org),
        _zip,
      );
      sent(
        'GET',
        '/plugins/$_plugin/versions/$_version/content',
        query: {'organization_id': _org},
      );
      expect(transport.lastRequest.headers['accept'], 'application/binary');
    },
  );

  test('RBAC group target aliases cannot dispatch an installation change', () {
    final settings = plugins.installationSettings;
    for (final id in [
      'organization',
      'organization;scope=group',
      'organization%3Bscope=group',
      'rbac_group_',
      'rbac_group_fixture;scope=organization',
      'rbac_group_fixture%3Bscope=organization',
      'rbac_group_fixture/../organization',
      'rbac_group_fixture\n',
    ]) {
      final target = PluginInstallationTarget.rbacGroup(id);
      expect(target.isOrganization, isFalse);
      expect(
        () => settings.set(
          _plugin,
          target,
          preference: PluginInstallationPreference.required,
        ),
        throwsArgumentError,
      );
      expect(() => settings.remove(_plugin, target), throwsArgumentError);
    }
    expect(transport.requests, isEmpty);
  });

  test(
    'reads shares and lists, sets, and removes installation preferences',
    () async {
      const setting = {
        'type': 'plugin_installation_setting',
        'plugin_id': _plugin,
        'target': {'type': 'rbac_group', 'rbac_group_id': _group},
        'installation_preference': 'required',
        'created_at': _timestamp,
        'updated_at': _timestamp,
      };
      transport
        ..json({
          'data': [
            {
              'type': 'plugin_share',
              'plugin_id': _plugin,
              'target': {
                'type': 'organization_member',
                'user_id': 'user_fixture',
              },
              'granted_at': _timestamp,
            },
          ],
          'next_page': 'share_cursor',
        })
        ..json({
          'data': [setting],
          'next_page': 'setting_cursor',
        })
        ..json(setting)
        ..json({
          'type': 'plugin_installation_setting_deleted',
          'plugin_id': _plugin,
          'target': {'type': 'organization'},
        });
      final shares = await plugins.listShares(
        _plugin,
        targetType: 'organization_member',
        organizationId: _org,
      );
      expect(shares.data.single.target.userId, 'user_fixture');
      expect(shares.nextPage, 'share_cursor');
      sent(
        'GET',
        '/plugins/$_plugin/shares',
        query: {'target_type': 'organization_member', 'organization_id': _org},
      );
      final settings = plugins.installationSettings;
      final list = await settings.list(
        _plugin,
        targetType: 'rbac_group',
        organizationId: _org,
        limit: 1,
        page: 'previous',
      );
      expect(list.data.single.target.rbacGroupId, _group);
      expect(list.nextPage, 'setting_cursor');
      sent(
        'GET',
        '/plugins/$_plugin/installation_settings',
        query: {
          'target_type': 'rbac_group',
          'organization_id': _org,
          'limit': '1',
          'page': 'previous',
        },
      );
      final updated = await settings.set(
        _plugin,
        const PluginInstallationTarget.rbacGroup(_group),
        preference: PluginInstallationPreference.required,
      );
      expect(updated.installationPreference, 'required');
      sent(
        'POST',
        '/plugins/$_plugin/installation_settings/$_group',
        body: {'installation_preference': 'required'},
      );
      final removed = await settings.remove(
        _plugin,
        const PluginInstallationTarget.organization(),
      );
      expect(removed.target.type, 'organization');
      sent('DELETE', '/plugins/$_plugin/installation_settings/organization');
    },
  );

  test(
    'lists, retrieves and updates marketplaces with linked-org reads only',
    () async {
      transport
        ..json({
          'data': [_marketplaceJson],
          'next_page': 'marketplace_cursor',
        })
        ..json(_marketplaceJson)
        ..json({
          ..._marketplaceJson,
          'default_installation_preference': 'available',
        });
      final listed = await marketplaces.list(
        ownerType: 'organization',
        source: 'github',
        organizationId: _org,
        limit: 2,
        page: 'previous',
      );
      expect(listed.data.single.syncStatus, 'in_progress');
      expect(listed.nextPage, 'marketplace_cursor');
      sent(
        'GET',
        '/plugin_marketplaces',
        query: {
          'owner_type': 'organization',
          'source': 'github',
          'organization_id': _org,
          'limit': '2',
          'page': 'previous',
        },
      );
      expect(
        (await marketplaces.retrieve(
          _marketplace,
          organizationId: _org,
        )).lastSyncEndedAt,
        isNull,
      );
      sent(
        'GET',
        '/plugin_marketplaces/$_marketplace',
        query: {'organization_id': _org},
      );
      final updated = await marketplaces.update(
        _marketplace,
        defaultPreference: PluginInstallationPreference.available,
      );
      expect(updated.defaultInstallationPreference, 'available');
      sent(
        'POST',
        '/plugin_marketplaces/$_marketplace',
        body: {'default_installation_preference': 'available'},
      );
    },
  );

  test(
    'validates repository and a single binary archive and reads structured results',
    () async {
      transport
        ..json(_validation)
        ..json(_validation);
      final repository = await marketplaces.validateRepository(
        repositoryUrl: 'https://github.com/example/plugin-marketplace',
        ref: 'main',
      );
      expect(repository.valid, isFalse);
      expect(repository.pluginErrors.single.errorCode, 'manifest_missing');
      expect(
        repository.pluginWarnings.single.warnings.single.message,
        'Fixture warning',
      );
      sent(
        'POST',
        '/plugin_marketplaces/validate_repository',
        body: {
          'repository_url': 'https://github.com/example/plugin-marketplace',
          'ref': 'main',
        },
      );
      final report = await marketplaces.validateArchive(
        PluginUploadFile(
          path: 'marketplace.zip',
          bytes: _zip,
          mimeType: 'application/zip',
        ),
      );
      expect(report.totalPluginCount, 1);
      sent('POST', '/plugin_marketplaces/validate_archive');
      final body = multipartBody();
      expect(body, contains('name="archive"; filename="marketplace.zip"'));
      expect(body, isNot(contains('name="files[]"')));
      expect(body, contains(latin1.decode(_zip)));
    },
  );

  test(
    'rejects empty uploads and latest when a specific version is required',
    () {
      expect(() => plugins.create(files: []), throwsArgumentError);
      expect(
        () => plugins.update(_plugin, servedVersionId: 'latest'),
        throwsArgumentError,
      );
      expect(
        () => plugins.versions.download(_plugin, 'latest'),
        throwsArgumentError,
      );
      expect(transport.requests, isEmpty);
    },
  );
}

final class _CaptureTransport extends http.BaseClient {
  final List<http.StreamedResponse> _responses = [];
  final List<http.BaseRequest> requests = [];
  final List<List<int>> _bodies = [];

  http.BaseRequest get lastRequest => requests.last;
  List<int> get lastBytes => _bodies.last;

  void json(Map<String, Object?> body) => enqueue(
    utf8.encode(jsonEncode(body)),
    headers: {'content-type': 'application/json'},
  );

  void enqueue(List<int> bytes, {required Map<String, String> headers}) {
    _responses.add(
      http.StreamedResponse(Stream.value(bytes), 200, headers: headers),
    );
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    _bodies.add(await request.finalize().toBytes());
    return _responses.removeAt(0);
  }
}
