@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('PromptsResource', () {
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

      await client.prompts.list(
        pageSize: 10,
        pageToken: 'cursor-1',
        alias: 'prod',
        fields: ['id', 'name'],
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v2/prompts');
      expect(captured.url.queryParameters['pageSize'], '10');
      expect(captured.url.queryParameters['pageToken'], 'cursor-1');
      expect(captured.url.queryParameters['alias'], 'prod');
      expect(captured.url.queryParametersAll['fields'], ['id', 'name']);
    });

    test('create issues POST with request body', () async {
      final client = clientReturning({'id': 'prompt-1', 'name': 'greeting'});
      addTearDown(client.close);

      final result = await client.prompts.create(
        request: const CreatePromptRequest(
          name: 'greeting',
          definition: PromptDefinition(content: 'Hi'),
        ),
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/v2/prompts');
      expect(jsonDecode(captured.body), {
        'name': 'greeting',
        'definition': {'content': 'Hi'},
      });
      expect(result.id, 'prompt-1');
      expect(result.name, 'greeting');
    });

    test(
      'retrieve issues GET with version/alias/fields query params',
      () async {
        final client = clientReturning({'id': 'prompt-1'});
        addTearDown(client.close);

        await client.prompts.retrieve(
          promptId: 'prompt-1',
          version: 2,
          alias: 'prod',
          fields: ['id'],
        );

        expect(captured.method, 'GET');
        expect(captured.url.path, '/v2/prompts/prompt-1');
        expect(captured.url.queryParameters['version'], '2');
        expect(captured.url.queryParameters['alias'], 'prod');
        expect(captured.url.queryParametersAll['fields'], ['id']);
      },
    );

    test('update issues PATCH with request body', () async {
      final client = clientReturning({'id': 'prompt-1', 'title': 'New title'});
      addTearDown(client.close);

      final result = await client.prompts.update(
        promptId: 'prompt-1',
        request: const UpdatePromptRequest(title: 'New title'),
      );

      expect(captured.method, 'PATCH');
      expect(captured.url.path, '/v2/prompts/prompt-1');
      expect(jsonDecode(captured.body), {'title': 'New title'});
      expect(result.title, 'New title');
    });

    test('delete issues DELETE and returns void', () async {
      final client = clientReturning(<String, dynamic>{});
      addTearDown(client.close);

      await client.prompts.delete(promptId: 'prompt-1');

      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/v2/prompts/prompt-1');
    });

    test('listVersions issues GET on the versions sub-path', () async {
      final client = clientReturning({
        'data': [
          {'version': 1},
        ],
      });
      addTearDown(client.close);

      final result = await client.prompts.listVersions(promptId: 'prompt-1');

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v2/prompts/prompt-1/versions');
      expect(result.data, [const PromptVersion(version: 1)]);
    });

    test('createVersion issues POST with request body', () async {
      final client = clientReturning({'version': 2, 'deduplicated': false});
      addTearDown(client.close);

      final result = await client.prompts.createVersion(
        promptId: 'prompt-1',
        request: const CreatePromptVersionRequest(
          definition: PromptDefinition(content: 'v2'),
          notes: 'update',
        ),
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/v2/prompts/prompt-1/versions');
      expect(jsonDecode(captured.body), {
        'definition': {'content': 'v2'},
        'notes': 'update',
      });
      expect(result.version, 2);
      expect(result.deduplicated, false);
    });

    test('retrieveVersion issues GET on the specific version', () async {
      final client = clientReturning({'id': 'prompt-1', 'version': 2});
      addTearDown(client.close);

      await client.prompts.retrieveVersion(
        promptId: 'prompt-1',
        version: 2,
        fields: ['id'],
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v2/prompts/prompt-1/versions/2');
      expect(captured.url.queryParametersAll['fields'], ['id']);
    });

    test('updateVersion issues PATCH with request body', () async {
      final client = clientReturning({'id': 'prompt-1', 'version': 2});
      addTearDown(client.close);

      await client.prompts.updateVersion(
        promptId: 'prompt-1',
        version: 2,
        request: const UpdatePromptVersionRequest(
          aliases: AliasList(values: ['prod']),
        ),
      );

      expect(captured.method, 'PATCH');
      expect(captured.url.path, '/v2/prompts/prompt-1/versions/2');
      expect(jsonDecode(captured.body), {
        'aliases': {
          'values': ['prod'],
        },
      });
    });
  });
}
