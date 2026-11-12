import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _arn = 'arn:aws:kms:us-east-1:111122223333:key/key-id';
const _roleArn = 'arn:aws:iam::111122223333:role/legacy';
const _gcpKey = 'projects/fixture/locations/us/keyRings/ring/cryptoKeys/key';
const _vault = 'https://fixture.vault.azure.net';
const _date = '2026-11-11T09:00:00.000Z';
const Map<String, Object?> _key = {
  'type': 'external_key',
  'id': _arn,
  'display_name': null,
  'geo': 'us',
  'provider_config': {
    'type': 'aws',
    'kms_arn': _arn,
    'region': 'us-east-1',
    'role_arn': _roleArn,
  },
  'attachment': {'type': 'unattached'},
  'user_profile_id': null,
  'created_at': _date,
  'updated_at': _date,
};
const _cursor = 'cursor + / =';

void main() {
  for (final betas in [
    <String>[],
    ['caller-beta'],
  ]) {
    group(betas.isEmpty ? 'stable external keys' : 'beta external keys', () {
      late AnthropicClient client;
      late OrganizationExternalKeysResource keys;
      late List<http.Request> requests;
      late Object? reply;

      setUp(() {
        requests = [];
        reply = _key;
        client = AnthropicClient(
          config: const AnthropicConfig(
            authProvider: ApiKeyProvider('admin-fixture'),
            workspaceId: 'workspace-fixture',
            defaultHeaders: {'Anthropic-Workspace-ID': 'header-workspace'},
            retryPolicy: RetryPolicy(maxRetries: 0),
          ),
          httpClient: MockClient((request) async {
            requests.add(request);
            return _json(reply);
          }),
        );
        keys = client.organization.externalKeys;
      });
      tearDown(() {
        client.close();
        for (final request in requests) {
          expect(request.headers['x-api-key'], 'admin-fixture');
          expect(request.headers['anthropic-version'], '2026-10-21');
          expect(request.headers['anthropic-workspace-id'], isNull);
          expect(
            request.headers['anthropic-beta'],
            betas.isEmpty ? null : 'caller-beta',
          );
          expect(request.url.queryParameters['beta'], isNull);
          expect(request.followRedirects, isFalse);
        }
      });

      test(
        'create sends AWS coordinates and immutable profile binding',
        () async {
          final created = await keys.create(
            providerConfig: const ExternalKeyProviderConfig.aws(
              kmsArn: _arn,
              region: 'us-east-1',
              roleArn: _roleArn,
            ),
            displayName: 'fixture key',
            geo: ExternalKeyGeo.us,
            userProfileId: 'uprof_fixture',
            betas: betas,
          );
          expect(requests.single.method, 'POST');
          expect(requests.single.url.path, '/v1/organizations/external_keys');
          expect(jsonDecode(requests.single.body), {
            'provider_config': {
              'type': 'aws',
              'kms_arn': _arn,
              'region': 'us-east-1',
            },
            'display_name': 'fixture key',
            'geo': 'us',
            'user_profile_id': 'uprof_fixture',
          });
          expect(created.id, _arn);
          expect(
            (created.providerConfig as AwsExternalKeyConfig).roleArn,
            _roleArn,
          );
          expect(created.attachment, const ExternalKeyAttachment.unattached());
        },
      );

      test(
        'list uses an opaque cursor and has an explicit terminal page',
        () async {
          reply = {
            'data': [_key],
            'next_page': _cursor,
          };
          final first = await keys.list(limit: 1, betas: betas);
          reply = {'data': <Object>[], 'next_page': null};
          final second = await keys.list(page: first.nextPage, betas: betas);
          expect(first.data.single, ExternalKey.fromJson(_key));
          expect(second.data, isEmpty);
          expect(second.nextPage, isNull);
          expect(requests.map((request) => request.method), ['GET', 'GET']);
          expect(requests.map((request) => request.url.path), [
            '/v1/organizations/external_keys',
            '/v1/organizations/external_keys',
          ]);
          expect(requests.first.url.queryParameters, {'limit': '1'});
          expect(requests.last.url.queryParameters, {'page': _cursor});
        },
      );

      test('retrieve uses a single escaped ARN segment', () async {
        expect((await keys.retrieve(_arn, betas: betas)).id, _arn);
        expect(requests.single.method, 'GET');
        expect(requests.single.url.pathSegments, [
          'v1',
          'organizations',
          'external_keys',
          _arn,
        ]);
        expect(requests.single.body, isEmpty);
      });

      test('unsafe external key identifiers fail before dispatch', () {
        for (final id in ['', '.', '..', '..;metadata']) {
          expect(() => keys.retrieve(id, betas: betas), throwsArgumentError);
          expect(() => keys.delete(id, betas: betas), throwsArgumentError);
          expect(() => keys.validate(id, betas: betas), throwsArgumentError);
        }
        expect(requests, isEmpty);
      });

      test(
        'update distinguishes omitted and null values and accepts GCP and Azure',
        () async {
          await keys.update(_arn, betas: betas);
          await keys.update(
            _arn,
            displayName: null,
            geo: ExternalKeyGeo.us,
            providerConfig: const ExternalKeyProviderConfig.gcp(
              keyName: _gcpKey,
            ),
            betas: betas,
          );
          reply = {
            ..._key,
            'provider_config': {
              'type': 'azure',
              'tenant_id': 'tenant',
              'vault_uri': _vault,
              'key_name': 'key',
              'client_id': 'client',
            },
            'attachment': {'type': 'attached'},
          };
          final updated = await keys.update(
            _arn,
            providerConfig: const ExternalKeyProviderConfig.azure(
              vaultUri: _vault,
              tenantId: 'tenant',
              keyName: 'key',
              clientId: 'client',
            ),
            betas: betas,
          );
          expect(updated.providerConfig, isA<AzureExternalKeyConfig>());
          expect(updated.attachment, const ExternalKeyAttachment.attached());
          await keys.update(
            _arn,
            geo: null,
            providerConfig: null,
            betas: betas,
          );
          expect(
            requests.map((request) => request.method),
            everyElement('POST'),
          );
          expect(
            requests.map((request) => request.url.pathSegments.last),
            everyElement(_arn),
          );
          expect(requests.map((request) => jsonDecode(request.body)), [
            <String, Object>{},
            {
              'display_name': null,
              'geo': 'us',
              'provider_config': {'type': 'gcp', 'key_name': _gcpKey},
            },
            {
              'provider_config': {
                'type': 'azure',
                'tenant_id': 'tenant',
                'vault_uri': _vault,
                'key_name': 'key',
                'client_id': 'client',
              },
            },
            {'geo': null, 'provider_config': null},
          ]);
        },
      );

      test('delete decodes the deletion receipt', () async {
        reply = {'type': 'external_key_deleted', 'id': _arn};
        expect(
          await keys.delete(_arn, betas: betas),
          const DeletedExternalKey(id: _arn),
        );
        expect(requests.single.method, 'DELETE');
        expect(requests.single.url.pathSegments.last, _arn);
        expect(requests.single.body, isEmpty);
      });

      test(
        'validate keeps HTTP 200 failure separate from HTTP errors',
        () async {
          reply = {
            'type': 'external_key_validation',
            'status': 'success',
            'error': null,
          };
          expect((await keys.validate(_arn, betas: betas)).succeeded, isTrue);
          reply = {
            'type': 'external_key_validation',
            'status': 'failure',
            'error': 'key provider private diagnostic',
          };
          final failed = await keys.validate(_arn, betas: betas);
          expect(failed.succeeded, isFalse);
          expect(failed.error, 'key provider private diagnostic');
          expect(failed.toString(), isNot(contains(failed.error)));
          for (final request in requests) {
            expect(request.method, 'POST');
            expect(request.url.pathSegments.skip(3), [_arn, 'validate']);
            expect(request.body, isEmpty);
          }
        },
      );
    });
  }

  test('Admin errors keep provider details, code and request ID', () async {
    final client = AnthropicClient.withApiKey(
      'admin-fixture',
      httpClient: MockClient(
        (_) async => _json({
          'request_id': 'req_cmek',
          'error': {
            'type': 'invalid_request_error',
            'message': 'An active policy still references this key.',
            'details': {'error_code': 'external_key_in_workspace_policy'},
          },
        }, status: 409),
      ),
    );
    addTearDown(client.close);
    await expectLater(
      client.organization.externalKeys.delete(_arn),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 409)
            .having((error) => error.requestId, 'requestId', 'req_cmek')
            .having(
              (error) => error.errorCode,
              'errorCode',
              'external_key_in_workspace_policy',
            )
            .having((error) => error.errorDetails, 'errorDetails', {
              'error_code': 'external_key_in_workspace_policy',
            }),
      ),
    );
  });

  test(
    'known fields are typed and future provider and attachment variants round-trip',
    () {
      final raw = {
        ..._key,
        'provider_config': {
          'type': 'new-provider',
          'opaque': [
            1,
            {'nested': true},
          ],
        },
        'attachment': {
          'type': 'new-status',
          'opaque': {'state': true},
        },
        'geo': 'new-geo',
      };
      final future = ExternalKey.fromJson(raw);
      expect(future.providerConfig, isA<UnknownExternalKeyProviderConfig>());
      expect(future.attachment, isA<UnknownExternalKeyAttachment>());
      expect(future.toJson(), raw);
      expect(future.copyWith(), future);
      expect(ExternalKey.fromJson(future.toJson()).hashCode, future.hashCode);
      expect(future.toString(), isNot(contains(_arn)));
      expect(
        () => ExternalKey.fromJson(
          Map.of(_key)..['provider_config'] = const {'type': 'gcp'},
        ),
        throwsFormatException,
      );
      expect(
        () => ExternalKey.fromJson(Map.of(_key)..remove('display_name')),
        throwsFormatException,
      );
    },
  );
}

http.Response _json(Object? reply, {int status = 200}) => http.Response(
  jsonEncode(reply),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
