/// Offline organization Admin APIs: synthetic metadata and MockClient only.
/// No environment keys, cloud registrations, billing queries or API charges.
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart_admin.dart';

Future<void> main() async {
  var requests = 0;
  final transport = MockClient((request) async {
    requests++;
    assert(
      request.headers['authorization'] == 'Bearer synthetic_admin_example',
    );
    assert(!request.followRedirects);
    final path = request.url.path;
    final Object result;
    if (path.endsWith('/usage/decisions')) {
      result = {
        'object': 'page',
        'has_more': false,
        'next_page': null,
        'data': [
          {
            'object': 'bucket',
            'start_time': 0,
            'end_time': 60,
            'results': [
              {
                'object': 'organization.usage.decisions.result',
                'input_tokens': 10,
                'output_tokens': 2,
                'num_model_requests': 1,
                'input_cache_write_30m_tokens': 5,
                'api_source': 'unlabeled',
                'model': 'synthetic-model',
                'service_tier': null,
              },
            ],
          },
        ],
      };
    } else if (path.contains('/api_keys/')) {
      result = {
        'object': 'organization.project.api_key',
        'id': 'key_fixture',
        'redacted_value': '[synthetic]',
        'name': 'Example key',
        'created_at': 0,
        'last_used_at': null,
        'owner_project_access': 'active',
        'owner': {
          'type': 'service_account',
          'service_account': {
            'id': 'sa_fixture',
            'name': 'Example service account',
            'created_at': 0,
            'role': 'member',
          },
        },
        'expires_at': 300,
      };
    } else if (path.contains('/external_storage')) {
      result = {
        'object': 'organization.external_storage',
        'id': 'storage_fixture',
        'project_id': 'project_fixture',
        'provider': {
          'type': 'oci',
          'tenancy_ocid': 'synthetic-tenancy',
          'region': 'synthetic-region',
          'bucket': 'synthetic-bucket',
        },
        'geography': 'synthetic',
        'status': 'degraded',
        'created_at': 0,
      };
    } else if (path.endsWith('/validate')) {
      assert(request.body.isEmpty);
      result = {'status': 'synthetic_validated'};
    } else {
      result = {
        'object': 'organization.external_key',
        'id': 'key_fixture',
        'type': 'aws',
        'name': 'Synthetic key',
        'api_project_ids': <String>[],
        'workspace_id': 'organization_fixture',
        'created_at': 0,
      };
    }
    return http.Response(
      jsonEncode(result),
      200,
      headers: {'content-type': 'application/json'},
    );
  });

  // Admin credentials have their own client/configuration. They are never used
  // for Responses or inherited from an ordinary OpenAIClient.
  final admin = OpenAIAdminClient(
    config: OpenAIAdminConfig(
      authProvider: const ApiKeyProvider('synthetic_admin_example'),
    ),
    httpClient: transport,
  );
  try {
    final key = await admin.organization.externalKeys.create(
      AwsExternalKeyParams(
        name: 'Synthetic key',
        roleArn: 'arn:aws:iam::123456789012:role/synthetic',
        kmsArn: 'synthetic-kms-arn',
        externalId: 'synthetic-external-id',
        purpose: ExternalKeyPurpose.ekm,
      ),
    );
    final validation = await admin.organization.externalKeys.validate(key.id);
    stdout.writeln('Key validation: ${validation.status}');

    final storage = await admin.organization.externalStorage.create(
      CreateExternalStorageRequest(
        projectId: 'project_fixture',
        provider: OciExternalStorageProviderParams(
          tenancyOcid: 'synthetic-tenancy',
          region: 'synthetic-region',
          bucket: 'synthetic-bucket',
        ),
      ),
    );
    stdout.writeln(
      'Storage status: ${storage.status.value}',
    ); // Service-owned, not a local transition.

    // [] is All permissions within the owner's effective access. An expiry is
    // relative to each request, including an eligible ordinary HTTP retry.
    await admin.organization.projects.apiKeys.update(
      'project_fixture',
      'key_fixture',
      UpdateProjectApiKeyRequest(scopes: const [], expiresInSeconds: 300),
    );

    final usage = await admin.organization.usage.decisions(
      startTime: 0,
      endTime: 60,
      bucketWidth: DecisionsUsageBucketWidth.minute,
      groupBy: [DecisionsUsageGroupBy.model, DecisionsUsageGroupBy.apiSource],
    );
    final result = usage.data.single.results.single;
    stdout.writeln(
      '30-minute cache-write tokens: ${result.inputCacheWrite30mTokens}',
    );
    // "unlabeled" can include historical/unknown origins, not just direct calls.
    assert(!usage.hasMore && usage.nextPage == null);
    stdout.writeln('Completed $requests offline mock requests.');
  } finally {
    admin.close(); // Injected transport is borrowed.
    transport.close();
  }
}
