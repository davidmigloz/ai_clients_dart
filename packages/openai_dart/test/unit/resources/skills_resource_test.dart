import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SkillsResource', () {
    test('list sends GET /skills and parses response', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return http.Response(
          jsonEncode({
            'object': 'list',
            'data': [
              {
                'id': 'skill_123',
                'object': 'skill',
                'name': 'Spreadsheet Helper',
                'description': 'Handles spreadsheet operations',
                'created_at': 1234567890,
                'default_version': 'latest',
                'latest_version': '42',
              },
            ],
            'first_id': 'skill_123',
            'last_id': 'skill_123',
            'has_more': false,
          }),
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      final result = await client.skills.list(limit: 10, order: 'desc');
      final request = await requestCompleter.future;

      expect(request.method, equals('GET'));
      expect(request.url.path, endsWith('/skills'));
      expect(request.url.queryParameters['limit'], equals('10'));
      expect(request.url.queryParameters['order'], equals('desc'));
      expect(result.data.first.id, equals('skill_123'));
    });

    test('create sends multipart request with files', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return http.Response(
          jsonEncode({
            'id': 'skill_123',
            'object': 'skill',
            'name': 'Spreadsheet Helper',
            'description': 'Handles spreadsheet operations',
            'created_at': 1234567890,
            'default_version': 'latest',
            'latest_version': '42',
          }),
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.skills.create([
        const SkillUploadFile(bytes: [1, 2, 3], filename: 'README.md'),
      ]);

      final request = await requestCompleter.future as http.Request;
      expect(request.method, equals('POST'));
      expect(request.url.path, endsWith('/skills'));
      expect(request.headers['content-type'], contains('multipart/form-data'));
      expect(request.body, contains('name="files"'));
      expect(request.body, contains('filename="README.md"'));
    });

    test('updateDefaultVersion sends POST /skills/{id}', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return http.Response(
          jsonEncode({
            'id': 'skill_123',
            'object': 'skill',
            'name': 'Spreadsheet Helper',
            'description': 'Handles spreadsheet operations',
            'created_at': 1234567890,
            'default_version': '42',
            'latest_version': '42',
          }),
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      final skill = await client.skills.updateDefaultVersion(
        'skill_123',
        const SetDefaultSkillVersionRequest(defaultVersion: '42'),
      );

      final request = await requestCompleter.future as http.Request;
      final body = jsonDecode(request.body) as Map<String, dynamic>;

      expect(request.method, equals('POST'));
      expect(request.url.path, endsWith('/skills/skill_123'));
      expect(body['default_version'], equals('42'));
      expect(skill.defaultVersion, equals('42'));
    });

    test(
      'versions.retrieve sends GET /skills/{id}/versions/{version}',
      () async {
        final requestCompleter = Completer<http.BaseRequest>();

        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response(
            jsonEncode({
              'object': 'skill.version',
              'id': 'skillver_123',
              'skill_id': 'skill_123',
              'version': '42',
              'created_at': 1234567890,
              'name': 'Spreadsheet Helper',
              'description': 'Handles spreadsheet operations',
            }),
            200,
          );
        });

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          httpClient: mockClient,
        );

        final version = await client.skills.versions.retrieve(
          'skill_123',
          '42',
        );
        final request = await requestCompleter.future;

        expect(request.method, equals('GET'));
        expect(request.url.path, endsWith('/skills/skill_123/versions/42'));
        expect(version.id, equals('skillver_123'));
      },
    );

    test('retrieveContent returns response bytes', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return http.Response.bytes([80, 75, 3, 4], 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      final bytes = await client.skills.retrieveContent('skill_123');
      final request = await requestCompleter.future;

      expect(request.method, equals('GET'));
      expect(request.url.path, endsWith('/skills/skill_123/content'));
      expect(bytes, equals([80, 75, 3, 4]));
    });
  });
}
