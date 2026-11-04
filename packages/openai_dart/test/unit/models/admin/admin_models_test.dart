// Generic contract table intentionally invokes each concrete copyWith shape.
// ignore_for_file: avoid_dynamic_calls

import 'package:openai_dart/openai_dart_admin.dart';
import 'package:test/test.dart';
import 'admin_fixtures.dart';

void main() {
  final parsers = <String, dynamic Function(Map<String, dynamic>)>{
    'AwsExternalKeyParams': AwsExternalKeyParams.fromJson,
    'AzureExternalKeyParams': AzureExternalKeyParams.fromJson,
    'GcpExternalKeyParams': GcpExternalKeyParams.fromJson,
    'ExternalKeyResource': ExternalKey.fromJson,
    'ListExternalKeysResource': ExternalKeyList.fromJson,
    'ValidateExternalKeyResource': ExternalKeyValidation.fromJson,
    'AwsExternalStorageProviderParams':
        AwsExternalStorageProviderParams.fromJson,
    'AzureExternalStorageProviderParams':
        AzureExternalStorageProviderParams.fromJson,
    'GcpExternalStorageProviderParams':
        GcpExternalStorageProviderParams.fromJson,
    'OciExternalStorageProviderParams':
        OciExternalStorageProviderParams.fromJson,
    'AwsExternalStorageProviderResponse':
        AwsExternalStorageProviderResponse.fromJson,
    'AzureExternalStorageProviderResponse':
        AzureExternalStorageProviderResponse.fromJson,
    'GcpExternalStorageProviderResponse':
        GcpExternalStorageProviderResponse.fromJson,
    'OciExternalStorageProviderResponse':
        OciExternalStorageProviderResponse.fromJson,
    'CreateExternalStorageBody': CreateExternalStorageRequest.fromJson,
    'ExternalStorageResponse': ExternalStorage.fromJson,
    'ExternalStorageListResource': ExternalStorageList.fromJson,
    'ExternalStorageDeletedResource': DeletedExternalStorage.fromJson,
    'UpdateProjectApiKeyBody': UpdateProjectApiKeyRequest.fromJson,
    'ProjectApiKeyOwnerUser': ProjectApiKeyOwnerUser.fromJson,
    'ProjectApiKeyOwnerServiceAccount':
        ProjectApiKeyOwnerServiceAccount.fromJson,
    'ProjectApiKeyOwner': ProjectApiKeyOwner.fromJson,
    'ProjectApiKey': ProjectApiKey.fromJson,
    'DecisionsUsageResult': DecisionsUsageResult.fromJson,
    'DecisionsUsageBucket': DecisionsUsageBucket.fromJson,
    'PublicDecisionsUsageResponseResource': DecisionsUsagePage.fromJson,
  };
  final required = <String, List<String>>{
    'AwsExternalKeyParams': [
      'name',
      'type',
      'role_arn',
      'kms_arn',
      'external_id',
    ],
    'AzureExternalKeyParams': [
      'name',
      'type',
      'tenant_id',
      'vault_uri',
      'key_name',
    ],
    'GcpExternalKeyParams': [
      'name',
      'type',
      'workload_identity_project_number',
      'workload_identity_pool_id',
      'workload_identity_provider_id',
      'kms_project_id',
      'kms_key_ring_name',
      'kms_key_name',
      'kms_key_location',
      'audience',
    ],
    'ExternalKeyResource': [
      'object',
      'id',
      'type',
      'name',
      'api_project_ids',
      'workspace_id',
      'created_at',
    ],
    'ListExternalKeysResource': [
      'object',
      'data',
      'first_id',
      'last_id',
      'has_more',
    ],
    'ValidateExternalKeyResource': ['status'],
    'AwsExternalStorageProviderParams': ['type', 'bucket', 'role_arn'],
    'AzureExternalStorageProviderParams': [
      'type',
      'tenant_id',
      'subscription_id',
      'resource_group',
      'account_name',
      'container',
    ],
    'GcpExternalStorageProviderParams': [
      'type',
      'bucket',
      'workload_identity_project_number',
      'workload_identity_pool_id',
      'workload_identity_provider_id',
    ],
    'OciExternalStorageProviderParams': [
      'type',
      'tenancy_ocid',
      'region',
      'bucket',
    ],
    'AwsExternalStorageProviderResponse': [
      'type',
      'account_id',
      'region',
      'bucket',
      'role_arn',
      'external_id',
    ],
    'AzureExternalStorageProviderResponse': [
      'type',
      'tenant_id',
      'subscription_id',
      'resource_group',
      'account_name',
      'container',
      'region',
    ],
    'GcpExternalStorageProviderResponse': [
      'type',
      'bucket',
      'workload_identity_project_number',
      'workload_identity_pool_id',
      'workload_identity_provider_id',
      'region',
      'audience',
    ],
    'OciExternalStorageProviderResponse': [
      'type',
      'tenancy_ocid',
      'region',
      'bucket',
    ],
    'CreateExternalStorageBody': ['project_id', 'provider'],
    'ExternalStorageResponse': [
      'object',
      'id',
      'project_id',
      'provider',
      'geography',
      'status',
      'created_at',
    ],
    'ExternalStorageListResource': [
      'object',
      'data',
      'first_id',
      'last_id',
      'has_more',
    ],
    'ExternalStorageDeletedResource': ['object', 'id', 'deleted'],
    'UpdateProjectApiKeyBody': [],
    'ProjectApiKeyOwnerUser': ['id', 'email', 'name', 'created_at', 'role'],
    'ProjectApiKeyOwnerServiceAccount': ['id', 'name', 'created_at', 'role'],
    'ProjectApiKeyOwner': [],
    'ProjectApiKey': [
      'object',
      'redacted_value',
      'name',
      'created_at',
      'last_used_at',
      'id',
      'owner_project_access',
      'owner',
    ],
    'DecisionsUsageResult': [
      'object',
      'input_tokens',
      'output_tokens',
      'num_model_requests',
    ],
    'DecisionsUsageBucket': ['object', 'start_time', 'end_time', 'results'],
    'PublicDecisionsUsageResponseResource': [
      'object',
      'has_more',
      'next_page',
      'data',
    ],
  };
  for (final entry in parsers.entries) {
    test('${entry.key} full value/copy/privacy and required fields', () {
      final json = adminFixture(entry.key);
      final dynamic value = entry.value(json);
      expect(value.toJson(), json);
      expect(value.copyWith(), value);
      expect(value.copyWith().hashCode, value.hashCode);
      expect(value.toString(), isNot(contains('synthetic-private')));
      for (final field in required[entry.key]!) {
        final missing = Map<String, dynamic>.of(json)..remove(field);
        expect(
          () => entry.value(missing),
          throwsFormatException,
          reason: field,
        );
      }
      for (final field in json.keys) {
        expect(
          () => entry.value({...json, field: Object()}),
          throwsFormatException,
          reason: field,
        );
      }
      final extra = <String, dynamic>{
        ...json,
        'future_secret': {
          'nested': ['private-extra'],
        },
      };
      final dynamic extended = entry.value(extra);
      (extra['future_secret'] as Map)['nested'] = ['changed'];
      expect(extended.toJson()['future_secret'], {
        'nested': ['private-extra'],
      });
      expect(extended, isNot(value));
      expect(extended.hashCode, isNot(value.hashCode));
      expect(
        () => (extended.rawJson as Map)['future_secret'] = null,
        throwsUnsupportedError,
      );
    });
  }
  test('optional null presence and full copy semantics remain distinct', () {
    final base = DecisionsUsageResult(
      inputTokens: 1,
      outputTokens: 2,
      numModelRequests: 3,
    );
    final explicit = base.copyWith(
      inputCacheWrite30mTokens: null,
      apiSource: null,
      model: null,
    );
    expect(base.toJson().containsKey('input_cache_write_30m_tokens'), isFalse);
    expect(explicit.toJson()['input_cache_write_30m_tokens'], isNull);
    expect(
      explicit.toJson().containsKey('input_cache_write_30m_tokens'),
      isTrue,
    );
    expect(explicit, isNot(base));
    expect(
      explicit.copyWith(
        clearInputCacheWrite30mTokens: true,
        clearApiSource: true,
        clearModel: true,
      ),
      base,
    );
    expect(
      base.copyWith(model: 'future-model', serviceTier: 'future-tier').model,
      'future-model',
    );
    final future = DecisionsUsageApiSource.fromJson('future_source');
    expect(future.toJson(), 'future_source');
    expect(future.isKnown, isFalse);
  });
  test('required nullable cursors and key timestamps stay required', () {
    final page = ExternalKeyList(
      data: const [],
      firstId: null,
      lastId: null,
      hasMore: false,
    );
    expect(page.toJson(), {
      'object': 'list',
      'data': <Object?>[],
      'first_id': null,
      'last_id': null,
      'has_more': false,
    });
    final key = ProjectApiKey.fromJson({
      ...adminFixture('ProjectApiKey'),
      'last_used_at': null,
      'owner': const <String, dynamic>{},
    });
    expect(key.owner.toJson(), isEmpty);
    expect(key.toJson()['last_used_at'], isNull);
    expect(
      key.copyWith(expiresAt: null).toJson().containsKey('expires_at'),
      isTrue,
    );
  });
  test(
    'provider variants reject wrong tags and preserve future receive variants',
    () {
      for (final name in [
        'AwsExternalKeyParams',
        'AzureExternalKeyParams',
        'GcpExternalKeyParams',
      ]) {
        final value = ExternalKeyParams.fromJson(adminFixture(name));
        expect(value.toJson(), adminFixture(name));
      }
      for (final name in [
        'AwsExternalStorageProviderParams',
        'AzureExternalStorageProviderParams',
        'GcpExternalStorageProviderParams',
        'OciExternalStorageProviderParams',
      ]) {
        expect(
          ExternalStorageProviderParams.fromJson(adminFixture(name)).toJson(),
          adminFixture(name),
        );
      }
      final future = ExternalStorageProvider.fromJson(const {
        'type': 'future',
        'secret': ['hidden'],
      });
      expect(future.toJson(), {
        'type': 'future',
        'secret': ['hidden'],
      });
      expect((future as UnknownExternalStorageProvider).copyWith(), future);
      expect(
        () => ExternalStorageProviderParams.fromJson(const {
          'type': 'future',
        }).validate(),
        throwsFormatException,
      );
      expect(
        () => AwsExternalKeyParams.fromJson({
          ...adminFixture('AwsExternalKeyParams'),
          'type': 'gcp',
        }),
        throwsFormatException,
      );
      expect(
        () => ExternalStorage.fromJson({
          ...adminFixture('ExternalStorageResponse'),
          'object': 'wrong',
        }),
        throwsFormatException,
      );
    },
  );
  test(
    'provider conditional versions, format and request enums are enforced',
    () {
      final azure = adminFixture('AzureExternalKeyParams');
      expect(
        () => AzureExternalKeyParams.fromJson({...azure, 'purpose': 'ekm'}),
        throwsFormatException,
      );
      expect(
        () =>
            AzureExternalKeyParams.fromJson({...azure}..remove('key_version')),
        throwsFormatException,
      );
      expect(
        () => AzureExternalKeyParams.fromJson({
          ...azure,
          'tenant_id': 'bad-private',
        }),
        throwsFormatException,
      );
      expect(
        () =>
            AzureExternalKeyParams.fromJson({...azure, 'key_name': 'x' * 128}),
        throwsFormatException,
      );
      final gcp = adminFixture('GcpExternalKeyParams');
      expect(
        () => GcpExternalKeyParams.fromJson({...gcp, 'kms_key_version': '0'}),
        throwsFormatException,
      );
      expect(
        () => GcpExternalKeyParams.fromJson({
          ...gcp,
          'workload_identity_project_number': 123,
        }),
        throwsFormatException,
      );
      expect(
        () => AwsExternalKeyParams.fromJson({
          ...adminFixture('AwsExternalKeyParams'),
          'role_arn': 'bad-private',
        }),
        throwsFormatException,
      );
      expect(
        () => AwsExternalKeyParams.fromJson({
          ...adminFixture('AwsExternalKeyParams'),
          'purpose': 'future',
        }),
        throwsFormatException,
      );
      expect(
        () => ExternalKey.fromJson({
          ...adminFixture('ExternalKeyResource'),
          'purpose': null,
        }),
        throwsFormatException,
      );
    },
  );
  test(
    'project key patch has no fabricated default and empty scopes remains All',
    () {
      expect(UpdateProjectApiKeyRequest.new, throwsFormatException);
      expect(
        () => UpdateProjectApiKeyRequest(expiresInSeconds: 0),
        throwsFormatException,
      );
      expect(
        () => UpdateProjectApiKeyRequest(expiresInSeconds: 31536001),
        throwsFormatException,
      );
      final scopes = <String>['future:scope'];
      final patch = UpdateProjectApiKeyRequest(scopes: scopes);
      scopes.clear();
      expect(patch.scopes, ['future:scope']);
      expect(patch.copyWith(scopes: []).toJson(), {'scopes': <String>[]});
      expect(
        patch.copyWith(scopes: null, expiresInSeconds: 31536000).toJson(),
        {'expires_in_seconds': 31536000},
      );
      expect(
        () => UpdateProjectApiKeyRequest.fromJson(const {'scopes': null}),
        throwsFormatException,
      );
    },
  );
  test(
    'overflow accepts finite JSON only without disclosing keys or values',
    () {
      final invalid = <String, dynamic>{'private-key': double.infinity};
      expect(
        () => ExternalKeyValidation(status: 'future', rawJson: invalid),
        throwsFormatException,
      );
      final cyclic = <String, dynamic>{};
      cyclic['private-key'] = cyclic;
      expect(
        () => ExternalKeyValidation(status: 'future', rawJson: cyclic),
        throwsFormatException,
      );
      expect(ExternalStorageStatus.fromJson('future').toJson(), 'future');
      expect(ExternalKeyValidation(status: 'future').status, 'future');
    },
  );
}
