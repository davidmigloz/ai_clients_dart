import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _compaction = <String, dynamic>{
  'type': 'compaction',
  'content': 'fixture',
  'encrypted_content': null,
  'signature': 'fixture-signature',
  'tool_changes': <Object?>[],
};

void main() {
  test(
    'empty fallback trigger copy preserves explicitly empty request JSON',
    () async {
      final original = FallbackInputBlock(
        from: const FallbackHopInfo(model: 'claude-opus-5-5'),
        to: const FallbackHopInfo(model: 'claude-sonnet-5-5'),
      );
      expect(original.toJson(), isNot(contains('trigger')));
      expect(
        original.copyWith(trigger: null).toJson(),
        containsPair('trigger', null),
      );
      final copied = original.copyWith(trigger: {});
      expect(copied.toJson(), containsPair('trigger', <String, dynamic>{}));
      final transport = MockHttpClient()
        ..queueJsonResponse(MockResponses.message());
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      await client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-5-5',
          maxTokens: 16,
          messages: [
            InputMessage.user('First'),
            InputMessage.assistantBlocks([copied]),
            InputMessage.user('Continue'),
          ],
        ),
        betas: ['server-side-fallback-2026-07-01'],
      );
      final request = transport.lastRequest! as http.Request;
      final payload = jsonDecode(request.body) as Map<String, dynamic>;
      final messages = payload['messages'] as List<dynamic>;
      final assistant = messages[1] as Map<String, dynamic>;
      final content = assistant['content'] as List<dynamic>;
      expect(content.single, containsPair('trigger', <String, dynamic>{}));
    },
  );

  test('no-argument tool examples accept a nested empty object', () {
    const tool = Tool(name: 'zero_argument', inputSchema: InputSchema());
    final copied = tool.copyWith(inputExamples: [<dynamic, dynamic>{}]);
    expect(copied.toJson()['input_examples'], [<String, dynamic>{}]);
    final typedExamples = <Map<String, dynamic>>[{}];
    expect(
      tool.copyWith(inputExamples: typedExamples).inputExamples,
      same(typedExamples),
    );
    expect(
      () => tool.copyWith(
        inputExamples: [
          {1: true},
        ],
      ),
      throwsA(isA<TypeError>()),
    );
    expect(
      () => tool.copyWith(inputExamples: [null]),
      throwsA(isA<TypeError>()),
    );
  });

  test('legacy profile metadata copy accepts an empty patch', () {
    const original = UpdateUserProfileRequest(metadata: {'tier': 'old'});
    expect(original.copyWith().metadata, {'tier': 'old'});
    expect(original.copyWith(metadata: {}).toJson(), {
      'metadata': <String, String>{},
    });
    expect(
      () => original.copyWith(metadata: {'tier': 1}),
      throwsA(isA<TypeError>()),
    );
    expect(
      () => original.copyWith(metadata: null),
      throwsA(isA<AssertionError>()),
    );
  });

  test('legacy tool schema copies preserve empty and typed collections', () {
    const schema = InputSchema(
      required: ['value'],
      properties: {
        'value': {'type': 'string'},
      },
    );
    expect(schema.copyWith(required: [], properties: {}).toJson(), {
      'type': 'object',
      'required': <String>[],
      'properties': <String, dynamic>{},
    });
    expect(schema.copyWith(required: null, properties: null).toJson(), {
      'type': 'object',
    });
    final required = <String>['next'];
    final properties = <String, dynamic>{'next': true};
    final typed = schema.copyWith(required: required, properties: properties);
    expect(typed.required, same(required));
    expect(typed.properties, same(properties));
    expect(
      () => schema.copyWith(required: <String>{}),
      throwsA(isA<TypeError>()),
    );
    expect(
      () => schema.copyWith(properties: {1: true}),
      throwsA(isA<TypeError>()),
    );
  });

  test('empty compaction tool changes survive a response copy and replay', () {
    final block = CompactionBlock.fromJson(
      _compaction,
    ).copyWith(toolChanges: []);
    expect(block.toJson(), _compaction);
    expect(block.toInputBlock().toJson(), _compaction);
    expect(() => block.copyWith(toolChanges: [1]), throwsA(isA<TypeError>()));
  });

  test('empty input compaction tool changes reach the Messages wire', () async {
    final transport = MockHttpClient()
      ..queueJsonResponse(MockResponses.message());
    final client = AnthropicClient(httpClient: transport);
    addTearDown(client.close);
    final block = CompactionInputBlock.fromJson(_compaction);
    await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 32,
        messages: [
          InputMessage.assistantBlocks([block.copyWith(toolChanges: [])]),
          InputMessage.user('Continue'),
        ],
      ),
      betas: ['compact-2026-09-04', 'task-budgets-2026-03-13'],
    );
    final sent = transport.lastRequest! as http.Request;
    final messages = (jsonDecode(sent.body) as Map)['messages'] as List;
    expect((messages.first as Map)['content'], [_compaction]);
    expect(
      block.copyWith(toolChanges: null).toJson(),
      isNot(contains('tool_changes')),
    );
    expect(() => block.copyWith(toolChanges: [1]), throwsA(isA<TypeError>()));
  });

  test('empty GA profile metadata survives create and update copies', () async {
    final transport = MockHttpClient()..queueJsonResponse(_profile);
    final client = AnthropicClient(httpClient: transport);
    addTearDown(client.close);
    final profiles = client.userProfiles.current;
    const request = CreateCurrentUserProfileRequest(metadata: {'tier': 'dev'});
    await profiles.create(request.copyWith(metadata: {}));
    expect(jsonDecode((transport.lastRequest! as http.Request).body), {
      'metadata': <String, String>{},
    });
    expect(request.copyWith(metadata: {'tier': 'prod'}).toJson(), {
      'metadata': {'tier': 'prod'},
    });
    expect(
      () => request.copyWith(metadata: {'tier': 1}),
      throwsA(isA<TypeError>()),
    );
  });

  test('empty GA profile metadata reaches the update wire', () async {
    final transport = MockHttpClient()..queueJsonResponse(_profile);
    final client = AnthropicClient(httpClient: transport);
    addTearDown(client.close);
    const request = UpdateCurrentUserProfileRequest(metadata: {'tier': 'dev'});
    await client.userProfiles.current.update(
      'uprof_fixture',
      request.copyWith(metadata: {}),
    );
    expect(jsonDecode((transport.lastRequest! as http.Request).body), {
      'metadata': <String, String>{},
    });
    expect(
      request.copyWith(metadata: null).toJson(),
      isNot(contains('metadata')),
    );
    expect(
      () => request.copyWith(metadata: {'tier': 1}),
      throwsA(isA<TypeError>()),
    );
  });

  test('empty GA profile enforcement action copies preserve list shape', () {
    final profile = CurrentUserProfile.fromJson(_profile);
    expect(
      profile.copyWith(enforcementActions: []).toJson()['enforcement_actions'],
      isEmpty,
    );
    expect(
      profile.copyWith(enforcementActions: null).toJson(),
      isNot(contains('enforcement_actions')),
    );
    expect(
      () => profile.copyWith(enforcementActions: [1]),
      throwsA(isA<TypeError>()),
    );
  });

  test(
    'Managed web fetch copies accept list literals with the same types as the constructors',
    () {
      const response = WebFetchToolConfig(
        enabled: true,
        permissionPolicy: AlwaysAllowPolicy(),
      );
      const request = WebFetchToolConfigParams();
      expect(response.copyWith(allowedDomains: []).allowedDomains, isEmpty);
      expect(response.copyWith(blockedDomains: []).blockedDomains, isEmpty);
      expect(request.copyWith(allowedDomains: []).allowedDomains, isEmpty);
      expect(request.copyWith(blockedDomains: []).blockedDomains, isEmpty);
      expect(
        request.copyWith(allowedDomains: ['example.invalid']).allowedDomains,
        ['example.invalid'],
      );
      expect(
        request.copyWith(allowedDomains: null).toJson(),
        isNot(contains('allowed_domains')),
      );
      expect(
        () => response.copyWith(allowedDomains: [1]),
        throwsA(isA<TypeError>()),
      );
      expect(
        () => request.copyWith(blockedDomains: [1]),
        throwsA(isA<TypeError>()),
      );
    },
  );
}

const Map<String, dynamic> _profile = {
  'type': 'user_profile',
  'id': 'uprof_fixture',
  'name': null,
  'access_type': 'application',
  'external_user_details': <String, dynamic>{},
  'enforcement_actions': <Object?>[],
  'programs': <String, dynamic>{},
  'metadata': <String, String>{},
  'created_at': '2026-11-11T00:00:00Z',
  'updated_at': '2026-11-11T00:00:00Z',
};
