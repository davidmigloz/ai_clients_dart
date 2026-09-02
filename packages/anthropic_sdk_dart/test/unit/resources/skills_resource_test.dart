import 'dart:convert';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

Map<String, dynamic> _skillJson({String id = 'skill_abc123'}) {
  return {
    'id': id,
    'type': 'skill',
    'display_name': 'My Custom Skill',
    'created_at': '2025-01-15T10:00:00Z',
    'updated_at': '2025-01-15T10:00:00Z',
    'latest_version_id': 'skillver_1',
    'source': {'type': 'custom'},
  };
}

Map<String, dynamic> _skillVersionJson({String id = 'skillver_1'}) {
  return {
    'id': id,
    'type': 'skill_version',
    'skill_id': 'skill_abc123',
    'name': 'my-custom-skill',
    'description': 'A custom skill',
    'created_at': '2025-01-15T10:00:00Z',
  };
}

void main() {
  late MockHttpClient mockHttpClient;
  late AnthropicClient client;

  setUp(() {
    mockHttpClient = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('test-api-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: mockHttpClient,
    );
  });

  tearDown(() {
    client.close();
  });

  group('SkillsResource.create', () {
    test('sends one multipart file per SkillFile and display_name', () async {
      mockHttpClient.queueJsonResponse(_skillJson());

      final skill = await client.skills.create(
        files: [
          SkillFile(
            path: 'my-skill/SKILL.md',
            bytes: Uint8List.fromList(utf8.encode('# My Skill')),
          ),
          SkillFile(
            path: 'my-skill/scripts/run.py',
            bytes: Uint8List.fromList(utf8.encode('print("hi")')),
            mimeType: 'text/x-python',
          ),
        ],
        displayName: 'My Custom Skill',
      );

      expect(skill.id, 'skill_abc123');
      expect(skill.displayName, 'My Custom Skill');

      final request = mockHttpClient.lastRequest! as http.MultipartRequest;
      expect(request.url.path, '/v1/skills');
      expect(request.method, 'POST');
      expect(request.headers.containsKey('anthropic-beta'), isFalse);
      expect(request.files, hasLength(2));
      expect(request.files.every((f) => f.field == 'files[]'), isTrue);
      expect(request.files.map((f) => f.filename).toList(), [
        'my-skill/SKILL.md',
        'my-skill/scripts/run.py',
      ]);
      expect(request.fields['display_name'], 'My Custom Skill');
    });

    test('omits display_name field when not provided', () async {
      mockHttpClient.queueJsonResponse(_skillJson());

      await client.skills.create(
        files: [
          SkillFile(
            path: 'my-skill/SKILL.md',
            bytes: Uint8List.fromList(utf8.encode('# My Skill')),
          ),
        ],
      );

      final request = mockHttpClient.lastRequest! as http.MultipartRequest;
      expect(request.fields.containsKey('display_name'), isFalse);
    });
  });

  group('SkillsResource.list', () {
    test('sends query params and no anthropic-beta header', () async {
      mockHttpClient.queueJsonResponse({
        'data': [_skillJson()],
        'next_page': 'page_next',
      });

      final response = await client.skills.list(
        limit: 10,
        page: 'page_abc',
        source: SkillSourceType.anthropic,
      );

      expect(response.data, hasLength(1));
      expect(response.nextPage, 'page_next');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/skills');
      expect(request.url.queryParameters['limit'], '10');
      expect(request.url.queryParameters['page'], 'page_abc');
      expect(request.url.queryParameters['source'], 'anthropic');
      expect(request.headers.containsKey('anthropic-beta'), isFalse);
    });
  });

  group('SkillsResource.retrieve', () {
    test('sends no anthropic-beta header', () async {
      mockHttpClient.queueJsonResponse(_skillJson());

      final skill = await client.skills.retrieve(skillId: 'skill_abc123');

      expect(skill.id, 'skill_abc123');
      final request = mockHttpClient.lastRequest!;
      expect(request.headers.containsKey('anthropic-beta'), isFalse);
    });
  });

  group('SkillsResource.deleteSkill', () {
    test('returns a DeletedSkill and sends no anthropic-beta header', () async {
      mockHttpClient.queueJsonResponse({
        'id': 'skill_abc123',
        'type': 'skill_deleted',
      });

      final deleted = await client.skills.deleteSkill(skillId: 'skill_abc123');

      expect(deleted.id, 'skill_abc123');
      expect(deleted.type, 'skill_deleted');

      final request = mockHttpClient.lastRequest!;
      expect(request.method, 'DELETE');
      expect(request.headers.containsKey('anthropic-beta'), isFalse);
    });
  });

  group('SkillsResource.createVersion', () {
    test('sends one multipart file per SkillFile', () async {
      mockHttpClient.queueJsonResponse(_skillVersionJson());

      final version = await client.skills.createVersion(
        skillId: 'skill_abc123',
        files: [
          SkillFile(
            path: 'my-skill/SKILL.md',
            bytes: Uint8List.fromList(utf8.encode('# My Skill v2')),
          ),
        ],
      );

      expect(version.id, 'skillver_1');

      final request = mockHttpClient.lastRequest! as http.MultipartRequest;
      expect(request.url.path, '/v1/skills/skill_abc123/versions');
      expect(request.headers.containsKey('anthropic-beta'), isFalse);
      expect(request.files, hasLength(1));
      expect(request.files.single.field, 'files[]');
    });
  });

  group('SkillsResource.listVersions', () {
    test('sends no anthropic-beta header', () async {
      mockHttpClient.queueJsonResponse({
        'data': [_skillVersionJson()],
        'next_page': null,
      });

      final response = await client.skills.listVersions(
        skillId: 'skill_abc123',
      );

      expect(response.data, hasLength(1));
      final request = mockHttpClient.lastRequest!;
      expect(request.headers.containsKey('anthropic-beta'), isFalse);
    });
  });

  group('SkillsResource.retrieveVersion', () {
    test('sends no anthropic-beta header', () async {
      mockHttpClient.queueJsonResponse(_skillVersionJson());

      final version = await client.skills.retrieveVersion(
        skillId: 'skill_abc123',
        version: 'skillver_1',
      );

      expect(version.id, 'skillver_1');
      final request = mockHttpClient.lastRequest!;
      expect(request.headers.containsKey('anthropic-beta'), isFalse);
    });
  });

  group('SkillsResource.downloadVersion', () {
    test('sends correct request and returns raw bytes', () async {
      // A small ASCII-safe payload so it round-trips through the harness'
      // utf8 encoding of MockResponse.body unchanged. The expected bytes are
      // therefore the utf8 encoding of the queued body.
      const zipBody = 'PKfake-skill-zip-bytes';
      final expectedBytes = Uint8List.fromList(utf8.encode(zipBody));

      mockHttpClient.queueResponse(
        const MockResponse(
          body: zipBody,
          headers: {'content-type': 'application/zip'},
        ),
      );

      final bytes = await client.skills.downloadVersion(
        skillId: 'skill_abc123',
        version: 'skillver_1',
      );

      // Returned value equals the queued raw bytes.
      expect(bytes, isA<Uint8List>());
      expect(bytes, equals(expectedBytes));

      final request = mockHttpClient.lastRequest! as http.Request;
      expect(
        request.url.path,
        '/v1/skills/skill_abc123/versions/skillver_1/content',
      );
      expect(request.method, 'GET');
      // GA resource: no anthropic-beta header sent.
      expect(request.headers.containsKey('anthropic-beta'), isFalse);
      // Binary download: Accept is widened and the default JSON content-type is
      // dropped, matching FilesResource.download.
      expect(request.headers['accept'], '*/*');
      expect(request.headers.containsKey('content-type'), isFalse);
      expect(request.headers['x-api-key'], 'test-api-key');
    });

    test('throws ArgumentError when skillId is empty', () {
      expect(
        () => client.skills.downloadVersion(skillId: '', version: 'v1'),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError when version is empty', () {
      expect(
        () =>
            client.skills.downloadVersion(skillId: 'skill_abc123', version: ''),
        throwsArgumentError,
      );
    });
  });

  group('SkillsResource.deleteVersion', () {
    test(
      'returns a DeletedSkillVersion and sends no anthropic-beta header',
      () async {
        mockHttpClient.queueJsonResponse({
          'id': 'skillver_1',
          'type': 'skill_version_deleted',
        });

        final deleted = await client.skills.deleteVersion(
          skillId: 'skill_abc123',
          version: 'skillver_1',
        );

        expect(deleted.id, 'skillver_1');
        expect(deleted.type, 'skill_version_deleted');

        final request = mockHttpClient.lastRequest!;
        expect(request.method, 'DELETE');
        expect(request.headers.containsKey('anthropic-beta'), isFalse);
      },
    );
  });
}
