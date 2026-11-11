import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _beta = 'managed-agents-2026-04-01';
const _date = '2026-11-11T00:00:00.000Z';
const _id = 'env_fixture';
const _encoded = 'env_/a?b#';
const _fixture = <String, Object?>{
  'type': 'environment',
  'id': _id,
  'archived_at': null,
  'config': {
    'type': 'cloud',
    'networking': {
      'type': 'limited',
      'allow_mcp_servers': false,
      'allow_package_managers': true,
      'allowed_hosts': ['example.test'],
    },
    'packages': {
      'type': 'packages',
      'apt': <String>[],
      'cargo': <String>[],
      'gem': <String>[],
      'go': <String>[],
      'npm': <String>[],
      'pip': ['example==1.0'],
    },
  },
  'created_at': _date,
  'description': null,
  'metadata': <String, String>{},
  'name': 'Fixture',
  'scope': 'organization',
  'updated_at': _date,
};

void main() {
  test(
    'every environment lifecycle route uses the selected workspace',
    () async {
      final requests = <http.Request>[];
      final client = AnthropicClient(
        config: const AnthropicConfig(
          authProvider: ApiKeyProvider('key_fixture'),
          baseUrl: 'https://fixture.invalid/proxy/?keep=a&keep=b',
          workspaceId: 'wrkspc_default',
        ),
        httpClient: MockClient((request) async {
          requests.add(request);
          final Object body;
          final path = request.url.pathSegments;
          if (request.method == 'DELETE') {
            body = {'type': 'environment_deleted', 'id': _id};
          } else if (path.last == 'archive') {
            body = {..._fixture, 'archived_at': _date};
          } else if (request.method == 'GET' && path.last == 'environments') {
            body = {
              'data': [_fixture],
              'next_page': request.url.queryParameters.containsKey('page')
                  ? null
                  : 'next/+ cursor',
            };
          } else {
            body = _fixture;
          }
          return http.Response(
            jsonEncode(body),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.close);
      final resource = client.environments;
      final created = await resource.create(
        const CreateEnvironmentParams(
          name: 'Fixture',
          description: null,
          config: CloudEnvironmentConfigParams(
            networking: LimitedEnvironmentNetworkParams(
              allowPackageManagers: true,
              allowedHosts: ['example.test'],
            ),
            packages: EnvironmentPackagesParams(pip: ['example==1.0']),
          ),
        ),
        workspaceId: 'wrkspc_override',
        betas: const ['fixture-beta', _beta],
      );
      expect(created.toJson(), _fixture);
      final cloud = created.config as CloudEnvironmentConfig;
      expect((cloud.networking as LimitedEnvironmentNetwork).allowedHosts, [
        'example.test',
      ]);
      expect(cloud.packages.pip, ['example==1.0']);

      await resource.retrieve(_encoded);
      await resource.update(
        _id,
        const UpdateEnvironmentParams(
          description: null,
          config: CloudEnvironmentConfigParams(packages: null),
          metadata: {'remove': null, 'empty': '', 'keep': 'value'},
        ),
      );
      final first = await resource.list(limit: 1, includeArchived: true);
      final second = await resource.list(
        limit: 1,
        page: first.nextPage,
        includeArchived: true,
      );
      expect(first.data.single.id, _id);
      expect(second.nextPage, isNull);
      expect(second.toJson(), {
        'data': [_fixture],
        'next_page': null,
      });
      expect((await resource.archive(_id)).archivedAt, DateTime.parse(_date));
      expect((await resource.delete(_id)).toJson(), {
        'id': _id,
        'type': 'environment_deleted',
      });

      expect(requests.map((r) => r.method), [
        'POST',
        'GET',
        'POST',
        'GET',
        'GET',
        'POST',
        'DELETE',
      ]);
      expect(requests.map((r) => r.url.pathSegments), [
        ['proxy', 'v1', 'environments'],
        ['proxy', 'v1', 'environments', _encoded],
        ['proxy', 'v1', 'environments', _id],
        ['proxy', 'v1', 'environments'],
        ['proxy', 'v1', 'environments'],
        ['proxy', 'v1', 'environments', _id, 'archive'],
        ['proxy', 'v1', 'environments', _id],
      ]);
      for (final (i, request) in requests.indexed) {
        expect(
          request.headers['anthropic-beta'],
          i == 0 ? 'fixture-beta,$_beta' : _beta,
        );
        expect(
          request.headers['anthropic-workspace-id'],
          i == 0 ? 'wrkspc_override' : 'wrkspc_default',
        );
        expect(request.headers['anthropic-version'], '2026-10-21');
        expect(request.headers['x-api-key'], 'key_fixture');
        expect(request.url.queryParametersAll['keep'], ['a', 'b']);
      }
      expect(jsonDecode(requests[0].body), {
        'name': 'Fixture',
        'description': null,
        'config': {
          'type': 'cloud',
          'networking': {
            'type': 'limited',
            'allow_package_managers': true,
            'allowed_hosts': ['example.test'],
          },
          'packages': {
            'type': 'packages',
            'pip': ['example==1.0'],
          },
        },
      });
      expect(jsonDecode(requests[2].body), {
        'description': null,
        'config': {'type': 'cloud', 'packages': null},
        'metadata': {'remove': null, 'empty': '', 'keep': 'value'},
      });
      expect(
        requests[3].url.queryParameters,
        containsPair('include_archived', 'true'),
      );
      expect(
        requests[4].url.queryParameters,
        containsPair('page', 'next/+ cursor'),
      );
      expect(requests[4].url.queryParameters, containsPair('limit', '1'));
      expect(requests[5].body, isEmpty);
      expect(requests[6].body, isEmpty);
    },
  );

  test('self-hosted and future response configuration variants round-trip', () {
    const known = {'type': 'self_hosted'};
    final selfHosted = AgentEnvironment.fromJson(
      Map.of(_fixture)..['config'] = known,
    );
    expect(selfHosted.config, isA<SelfHostedEnvironmentConfig>());
    expect(selfHosted.toJson()['config'], known);
    expect(
      const CreateEnvironmentParams(
        name: 'Self-hosted',
        config: SelfHostedEnvironmentConfigParams(),
      ).toJson()['config'],
      known,
    );
    final raw = {
      'type': 'future_environment',
      'payload': {
        'nested': [1, 2],
      },
    };
    final unknown = AgentEnvironment.fromJson({..._fixture, 'config': raw});
    final copy = AgentEnvironment.fromJson(unknown.toJson());
    expect(unknown.config, isA<UnknownEnvironmentConfig>());
    expect(copy.config.toJson(), raw);
    expect(copy, unknown);
    expect(copy.hashCode, unknown.hashCode);
  });

  test('request copy retains absent, null and empty collections', () {
    const params = UpdateEnvironmentParams(
      description: 'existing',
      config: CloudEnvironmentConfigParams(
        networking: LimitedEnvironmentNetworkParams(allowedHosts: ['old']),
      ),
    );
    final cleared = params.copyWith(description: null, metadata: {});
    expect(cleared.toJson(), {
      'description': null,
      'config': {
        'type': 'cloud',
        'networking': {
          'type': 'limited',
          'allowed_hosts': ['old'],
        },
      },
      'metadata': <String, String?>{},
    });
    expect(
      cleared.copyWith(metadata: null).toJson(),
      isNot(contains('metadata')),
    );
    expect(
      const LimitedEnvironmentNetworkParams()
          .copyWith(allowedHosts: [])
          .toJson(),
      {'type': 'limited', 'allowed_hosts': <String>[]},
    );
    expect(UpdateEnvironmentParams.fromJson(cleared.toJson()), cleared);
    expect(const UpdateEnvironmentParams().copyWith(config: null).toJson(), {
      'config': null,
    });
  });
}
