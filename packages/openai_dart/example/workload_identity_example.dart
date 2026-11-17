// ignore_for_file: avoid_print

/// Manages a synthetic workload identity provider and rule over a mock
/// transport. Running this example makes no live calls.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart_admin.dart';

Future<void> main() async {
  const providerId = 'wip_fixture';
  const ruleId = 'wifr_fixture';
  const providerInput = {
    'type': 'oidc',
    'name': 'Example workload',
    'issuer': 'https://issuer.example',
    'audience': 'example-audience',
    'verification': {'type': 'discovery', 'discovery_url': null},
  };
  const ruleInput = {
    'project_id': 'proj_fixture',
    'service_account_id': 'sa_fixture',
    'attribute_matchers': {'subject': 'example-job'},
  };
  const rule = {
    ...ruleInput,
    'object': 'organization.workload_identity_federation_rule',
    'id': ruleId,
    'workload_identity_provider_id': providerId,
    'name': null,
    'description': null,
    'permissions': {'type': 'service_account_default'},
    'enabled': true,
    'created_at': 1,
    'updated_at': 1,
  };
  final transport = MockClient((request) async {
    final resource = request.url.pathSegments.last;
    final Object result = switch ((request.method, resource)) {
      ('POST', 'workload_identity_providers') => const {
        ...providerInput,
        'object': 'organization.workload_identity_provider',
        'id': providerId,
        'description': null,
        'attribute_transformations': <Object>[],
        'enabled': true,
        'created_at': 1,
        'updated_at': 1,
      },
      ('POST', 'federation_rules') => rule,
      ('GET', 'federation_rules') => const {
        'object': 'list',
        'data': [rule],
        'first_id': ruleId,
        'last_id': ruleId,
        'has_more': false,
      },
      _ => throw StateError('Unexpected offline request'),
    };
    return http.Response(jsonEncode(result), 200);
  });
  final client = OpenAIAdminClient.withApiKey(
    'test-admin-fixture',
    httpClient: transport,
  );
  try {
    final providers = client.organization.workloadIdentityProviders;
    final provider = await providers.create(
      CreateWorkloadIdentityProviderRequest(
        name: 'Example workload',
        issuer: 'https://issuer.example',
        audience: 'example-audience',
        verification: const WorkloadIdentityVerification.discovery(),
      ),
    );
    final mapping = await providers.federationRules.create(
      provider.id,
      CreateWorkloadIdentityFederationRuleRequest(
        projectId: 'proj_fixture',
        serviceAccountId: 'sa_fixture',
        attributeMatchers: const {'subject': 'example-job'},
      ),
    );
    final rules = await providers.federationRules.list(
      provider.id,
      serviceAccountId: mapping.serviceAccountId,
    );
    print('Returned rules: ${rules.data.length}');
  } finally {
    client.close();
    transport.close();
  }
}
