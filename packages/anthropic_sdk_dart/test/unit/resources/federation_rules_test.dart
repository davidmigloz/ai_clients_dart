import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _ruleId = 'fdrl_fixture';
const _issuerId = 'fdis_fixture';
const _accountId = 'svac_fixture';
const _workspaceId = 'wrkspc_fixture';
const _base = '/proxy/v1/organizations/federation_rules';
const _rulePath = '$_base/$_ruleId';
const _workspacePath = '$_rulePath/workspaces';
const _time = '2026-11-11T00:00:00.000Z';
const _target = FederationServiceAccountTarget(
  serviceAccountId: _accountId,
  serviceAccountName: 'server-managed',
);

void main() {
  for (final betas in [
    <String>[],
    ['future-beta'],
  ]) {
    group(betas.isEmpty ? 'GA' : 'caller beta', () {
      late List<http.Request> requests;
      late Map<String, dynamic> response;
      late OrganizationFederationRulesResource rules;

      setUp(() {
        requests = [];
        response = _rule();
        final transport = MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode(response),
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        addTearDown(transport.close);
        final client = AnthropicClient.withAuthToken(
          'fixture-org-token',
          config: const AnthropicConfig(
            baseUrl: 'https://fixture.invalid/proxy',
            workspaceId: 'ignored-workspace',
          ),
          httpClient: transport,
        );
        addTearDown(client.close);
        rules = client.organization.federation.rules;
      });

      void expectRequest(
        String method,
        String path, {
        Map<String, String> query = const {},
        Map<String, dynamic>? body,
      }) {
        final request = requests.last;
        expect(request.method, method);
        expect(request.url.path, path);
        expect(request.url.queryParameters, query);
        expect(request.headers['authorization'], 'Bearer fixture-org-token');
        expect(request.headers['x-api-key'], isNull);
        expect(
          request.headers['anthropic-beta'],
          [...betas, 'oauth-2025-04-20'].join(','),
        );
        expect(request.headers['anthropic-version'], '2026-10-21');
        expect(request.headers['anthropic-workspace-id'], isNull);
        expect(request.followRedirects, isFalse);
        if (body == null) {
          expect(request.bodyBytes, isEmpty);
        } else {
          expect(jsonDecode(request.body), body);
        }
      }

      test(
        'create encodes scoped match and strips target read metadata',
        () async {
          final match = FederationRuleMatch(
            subjectPrefix: 'repo:example/repo:*',
            audience: 'fixture-audience',
            claims: const {'repository_owner': 'example'},
          );
          final rule = await rules.create(
            issuerId: _issuerId,
            name: 'fixture',
            match: match,
            target: _target,
            oauthScope: 'workspace:developer',
            workspaceId: _workspaceId,
            tokenLifetimeSeconds: 600,
            attributes: {},
            betas: betas,
          );
          expect(rule.id, _ruleId);
          expect(rule.workspaceIds, [_workspaceId]);
          expectRequest(
            'POST',
            _base,
            body: {
              'issuer_id': _issuerId,
              'name': 'fixture',
              'match': match.toJson(),
              'target': {
                'type': 'service_account',
                'service_account_id': _accountId,
              },
              'oauth_scope': 'workspace:developer',
              'workspace_id': _workspaceId,
              'token_lifetime_seconds': 600,
              'attributes': <String, String>{},
            },
          );
        },
      );

      test(
        'list preserves issuer, archival filter, and opaque page token',
        () async {
          response = {
            'data': [_rule()],
            'next_page': 'b/+=?',
          };
          final page = await rules.list(
            issuerId: _issuerId,
            includeArchived: false,
            page: 'a/+=?',
            limit: 5,
            betas: betas,
          );
          expect(page.nextPage, 'b/+=?');
          expect(page.data.single.issuerId, _issuerId);
          expectRequest(
            'GET',
            _base,
            query: {
              'issuer_id': _issuerId,
              'include_archived': 'false',
              'page': 'a/+=?',
              'limit': '5',
            },
          );
        },
      );

      test('retrieve escapes the rule ID', () async {
        final rule = await rules.retrieve('fdrl/a ?', betas: betas);
        expect(rule.target.serviceAccountName, 'server-managed');
        expectRequest('GET', '$_base/fdrl%2Fa%20%3F');
        expect(requests.last.url.pathSegments.last, 'fdrl/a ?');
      });

      test('update sends false, empty maps, and explicit null clear', () async {
        final rule = await rules.update(
          _ruleId,
          appliesToAllWorkspaces: false,
          description: null,
          attributes: {},
          betas: betas,
        );
        expect(rule.name, 'fixture');
        expectRequest(
          'POST',
          _rulePath,
          body: {
            'applies_to_all_workspaces': false,
            'description': null,
            'attributes': <String, String>{},
          },
        );
        await rules.update(_ruleId, attributes: null, betas: betas);
        expectRequest('POST', _rulePath, body: {'attributes': null});
      });

      test(
        'archive returns the archived rule without a request body',
        () async {
          response['archived_at'] = _time;
          final rule = await rules.archive(_ruleId, betas: betas);
          expect(rule.archivedAt, DateTime.parse(_time));
          expectRequest('POST', '$_rulePath/archive');
        },
      );

      test('list workspace bindings carries opaque pagination', () async {
        response = {
          'data': [_workspace()],
          'next_page': null,
        };
        final page = await rules.workspaces.list(
          _ruleId,
          page: 'a/+=?',
          limit: 1,
          betas: betas,
        );
        expect(page.nextPage, isNull);
        expect(page.data.single.workspaceName, isNull);
        expectRequest(
          'GET',
          _workspacePath,
          query: {'page': 'a/+=?', 'limit': '1'},
        );
      });

      test('add workspace binding sends workspace ID', () async {
        response = _workspace();
        final added = await rules.workspaces.add(
          _ruleId,
          workspaceId: _workspaceId,
          betas: betas,
        );
        expect(added.workspaceId, _workspaceId);
        expectRequest(
          'POST',
          _workspacePath,
          body: {'workspace_id': _workspaceId},
        );
      });

      test('remove workspace binding returns typed receipt', () async {
        response = {
          'type': 'federation_rule_workspace_deleted',
          'federation_rule_id': _ruleId,
          'workspace_id': _workspaceId,
        };
        final removed = await rules.workspaces.remove(
          _ruleId,
          _workspaceId,
          betas: betas,
        );
        expect(removed.federationRuleId, _ruleId);
        expectRequest('DELETE', '$_workspacePath/$_workspaceId');
      });

      test(
        'rejects unsafe or unsupported rule configurations before transport',
        () {
          Future<FederationRule> create({
            FederationRuleMatch? match,
            String? workspace,
            int? lifetime,
            Map<String, String>? attributes,
          }) => rules.create(
            issuerId: _issuerId,
            name: 'fixture',
            match:
                match ?? FederationRuleMatch(subjectPrefix: 'repo:fixture:*'),
            target: _target,
            oauthScope: 'workspace:developer',
            workspaceId: workspace,
            tokenLifetimeSeconds: lifetime,
            attributes: attributes,
            betas: betas,
          );

          expect(create, throwsArgumentError);
          expect(
            () => create(
              workspace: _workspaceId,
              match: FederationRuleMatch(audience: 'aud', subjectPrefix: '*'),
            ),
            throwsArgumentError,
          );
          expect(
            () => create(workspace: _workspaceId, lifetime: 59),
            throwsRangeError,
          );
          expect(
            () => create(
              workspace: _workspaceId,
              attributes: {'identity': 'claims.sub'},
            ),
            throwsArgumentError,
          );
          expect(requests, isEmpty);
        },
      );
    });
  }

  test(
    'rule fields round-trip and collection copyWith handles empty values',
    () {
      final source = _rule();
      final rule = FederationRule.fromJson(source);
      expect(rule.toJson(), source);
      expect(FederationRule.fromJson(rule.toJson()), rule);
      expect(FederationRule.fromJson(rule.toJson()).hashCode, rule.hashCode);
      expect(rule.copyWith(attributes: {}).attributes, isEmpty);
      expect(rule.copyWith(attributes: {}).copyWith(attributes: null), rule);
      expect(rule.match.copyWith(claims: {}).claims, isEmpty);
      expect(() => rule.workspaceIds.add('mutation'), throwsUnsupportedError);
      expect(
        () => rule.match.claims!['other'] = 'mutation',
        throwsUnsupportedError,
      );
      expect(rule.toString(), isNot(contains('private-claim')));
      expect(
        () => FederationRule.fromJson(source..remove('workspace_id')),
        throwsFormatException,
      );
    },
  );
}

Map<String, dynamic> _rule() => {
  'type': 'federation_rule',
  'id': _ruleId,
  'name': 'fixture',
  'description': null,
  'issuer_id': _issuerId,
  'issuer_name': 'issuer',
  'match': {
    'claims': {'sub': 'private-claim'},
    'subject_prefix': 'repo:example/repo:*',
  },
  'target': {
    'type': 'service_account',
    'service_account_id': _accountId,
    'service_account_name': 'server-managed',
  },
  'oauth_scope': 'workspace:developer',
  'token_lifetime_seconds': 600,
  'workspace_id': null,
  'workspace_ids': [_workspaceId],
  'applies_to_all_workspaces': false,
  'attributes': null,
  'created_at': _time,
  'created_by_actor_id': 'user_fixture',
  'updated_at': _time,
  'updated_by_actor_id': null,
  'archived_at': null,
  'archived_by_actor_id': null,
};

Map<String, dynamic> _workspace() => {
  'type': 'federation_rule_workspace',
  'federation_rule_id': _ruleId,
  'workspace_id': _workspaceId,
  'workspace_name': null,
  'created_at': _time,
  'created_by_actor_id': null,
};
