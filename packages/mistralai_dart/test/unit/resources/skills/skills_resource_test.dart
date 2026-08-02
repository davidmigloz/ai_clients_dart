@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SkillsResource', () {
    late http.Request captured;

    MistralClient clientReturning(Map<String, dynamic> body) {
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode(body),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    test('list issues GET with camelCase query params', () async {
      final client = clientReturning({'data': <dynamic>[]});
      addTearDown(client.close);

      await client.skills.list(
        pageSize: 10,
        pageToken: 'cursor-1',
        alias: 'prod',
        fields: ['id', 'name'],
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v2/skills');
      expect(captured.url.queryParameters['pageSize'], '10');
      expect(captured.url.queryParameters['pageToken'], 'cursor-1');
      expect(captured.url.queryParameters['alias'], 'prod');
      expect(captured.url.queryParametersAll['fields'], ['id', 'name']);
    });

    test('create issues POST with request body', () async {
      final client = clientReturning({'id': 'skill-1', 'name': 'summarizer'});
      addTearDown(client.close);

      final result = await client.skills.create(
        request: const CreateSkillRequest(
          name: 'summarizer',
          definition: SkillDefinition(body: 'Summarize.'),
        ),
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/v2/skills');
      expect(jsonDecode(captured.body), {
        'name': 'summarizer',
        'definition': {'body': 'Summarize.'},
      });
      expect(result.id, 'skill-1');
      expect(result.name, 'summarizer');
    });

    test(
      'retrieve issues GET with version/alias/fields query params',
      () async {
        final client = clientReturning({'id': 'skill-1'});
        addTearDown(client.close);

        await client.skills.retrieve(
          skillId: 'skill-1',
          version: 2,
          alias: 'prod',
          fields: ['id'],
        );

        expect(captured.method, 'GET');
        expect(captured.url.path, '/v2/skills/skill-1');
        expect(captured.url.queryParameters['version'], '2');
        expect(captured.url.queryParameters['alias'], 'prod');
        expect(captured.url.queryParametersAll['fields'], ['id']);
      },
    );

    test('update issues PATCH with request body', () async {
      final client = clientReturning({
        'id': 'skill-1',
        'sharingScope': 'workspace',
      });
      addTearDown(client.close);

      final result = await client.skills.update(
        skillId: 'skill-1',
        request: const UpdateSkillRequest(
          sharingScope: RegistrySharingScope.workspace,
        ),
      );

      expect(captured.method, 'PATCH');
      expect(captured.url.path, '/v2/skills/skill-1');
      expect(jsonDecode(captured.body), {'sharingScope': 'workspace'});
      expect(result.sharingScope, RegistrySharingScope.workspace);
    });

    test('delete issues DELETE and returns void', () async {
      final client = clientReturning(<String, dynamic>{});
      addTearDown(client.close);

      await client.skills.delete(skillId: 'skill-1');

      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/v2/skills/skill-1');
    });

    test('listVersions issues GET on the versions sub-path', () async {
      final client = clientReturning({
        'data': [
          {'version': 1},
        ],
      });
      addTearDown(client.close);

      final result = await client.skills.listVersions(skillId: 'skill-1');

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v2/skills/skill-1/versions');
      expect(result.data, [const SkillVersion(version: 1)]);
    });

    test('createVersion issues POST with request body', () async {
      final client = clientReturning({'version': 2, 'deduplicated': false});
      addTearDown(client.close);

      final result = await client.skills.createVersion(
        skillId: 'skill-1',
        request: const CreateSkillVersionRequest(
          definition: SkillDefinition(body: 'v2'),
          notes: 'update',
        ),
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/v2/skills/skill-1/versions');
      expect(jsonDecode(captured.body), {
        'definition': {'body': 'v2'},
        'notes': 'update',
      });
      expect(result.version, 2);
      expect(result.deduplicated, false);
    });

    test('retrieveVersion issues GET on the specific version', () async {
      final client = clientReturning({'id': 'skill-1', 'version': 2});
      addTearDown(client.close);

      await client.skills.retrieveVersion(
        skillId: 'skill-1',
        version: 2,
        fields: ['id'],
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v2/skills/skill-1/versions/2');
      expect(captured.url.queryParametersAll['fields'], ['id']);
    });

    test('updateVersion issues PATCH with request body', () async {
      final client = clientReturning({'id': 'skill-1', 'version': 2});
      addTearDown(client.close);

      await client.skills.updateVersion(
        skillId: 'skill-1',
        version: 2,
        request: const UpdateSkillVersionRequest(
          aliases: AliasList(values: ['prod']),
        ),
      );

      expect(captured.method, 'PATCH');
      expect(captured.url.path, '/v2/skills/skill-1/versions/2');
      expect(jsonDecode(captured.body), {
        'aliases': {
          'values': ['prod'],
        },
      });
    });
  });
}
