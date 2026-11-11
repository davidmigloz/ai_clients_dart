import 'dart:convert';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _version = '2026-10-21';
const _workspace = 'wrkspc_default';
const _override = 'wrkspc_override';
const _managedAgentsBeta = 'managed-agents-2026-04-01';

void main() {
  late MockHttpClient transport;
  late AnthropicClient client;
  final message = MessageCreateRequest(
    model: 'claude-sonnet-5-5',
    maxTokens: 64,
    messages: [InputMessage.user('Hello')],
  );

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('workspace-test-key'),
        workspaceId: _workspace,
        defaultHeaders: {'Anthropic-Beta': 'configured-feature'},
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    addTearDown(client.close);
  });

  test('Messages sends default and per-call workspace on all paths', () async {
    transport
      ..queueJsonResponse(MockResponses.message())
      ..queueStreamingResponse(MockResponses.streamingEvents())
      ..queueJsonResponse(MockResponses.tokenCount(inputTokens: 9));

    final sent = await client.messages.create(message);
    expect(sent.id, 'msg_test123');
    final events = await client.messages
        .createStream(
          message,
          workspaceId: _override,
          betas: ['test-feature-a', 'test-feature-b'],
        )
        .toList();
    expect(events.last, isA<MessageStopEvent>());
    final count = await client.messages.countTokens(
      TokenCountRequest.fromMessageCreateRequest(message),
      workspaceId: _override,
      userProfileId: 'uprofile_fixture',
    );
    expect(count.inputTokens, 9);
    expect(transport.requests, hasLength(3));
    _assertRequest(
      transport.requests[0],
      'POST',
      '/v1/messages',
      _workspace,
      beta: 'configured-feature',
    );
    _assertRequest(
      transport.requests[1],
      'POST',
      '/v1/messages',
      _override,
      beta: 'test-feature-a,test-feature-b',
    );
    _assertRequest(
      transport.requests[2],
      'POST',
      '/v1/messages/count_tokens',
      _override,
      beta: 'configured-feature',
    );
    expect(
      transport.lastRequest!.headers['anthropic-user-profile-id'],
      'uprofile_fixture',
    );
  });

  test(
    'all batch operations support workspace and explicit beta features',
    () async {
      const id = 'batch_test123';
      const path = '/v1/messages/batches';
      final batch = MockResponses.messageBatch();
      transport
        ..queueJsonResponse(batch)
        ..queueJsonResponse({
          'data': [batch],
          'has_more': false,
          'first_id': id,
          'last_id': id,
        })
        ..queueJsonResponse(batch)
        ..queueJsonResponse(batch)
        ..queueJsonResponse({'id': id, 'type': 'message_batch_deleted'})
        ..queueResponse(
          MockResponse(
            headers: const {'content-type': 'application/x-jsonl'},
            body: jsonEncode({
              'custom_id': 'fixture',
              'result': {'type': 'expired'},
            }),
          ),
        );

      const betas = ['feature-a', 'message-batches-2024-09-24'];
      final created = await client.messages.batches.create(
        MessageBatchCreateRequest(
          requests: [BatchRequestItem(customId: 'fixture', params: message)],
        ),
        workspaceId: _override,
        betas: betas,
        userProfileId: 'uprofile_fixture',
      );
      final page = await client.messages.batches.list(
        workspaceId: _override,
        betas: betas,
        limit: 1,
      );
      final read = await client.messages.batches.retrieve(
        id,
        workspaceId: _override,
        betas: betas,
      );
      final canceled = await client.messages.batches.cancel(
        id,
        workspaceId: _override,
        betas: betas,
      );
      final deleted = await client.messages.batches.deleteBatch(
        id,
        workspaceId: _override,
        betas: betas,
      );
      final results = await client.messages.batches
          .results(id, workspaceId: _override, betas: betas)
          .toList();

      expect([
        created.id,
        page.data.single.id,
        read.id,
        canceled.id,
        deleted.id,
      ], everyElement(id));
      expect(results.single.customId, 'fixture');
      expect(results.single.result, isA<BatchResultExpired>());
      expect(transport.requests, hasLength(6));
      final expected = [
        ('POST', path),
        ('GET', path),
        ('GET', '$path/$id'),
        ('POST', '$path/$id/cancel'),
        ('DELETE', '$path/$id'),
        ('GET', '$path/$id/results'),
      ];
      for (final (index, (method, expectedPath)) in expected.indexed) {
        _assertRequest(
          transport.requests[index],
          method,
          expectedPath,
          _override,
          beta: 'feature-a,message-batches-2024-09-24',
        );
      }
      expect(
        transport.requests[0].headers['anthropic-user-profile-id'],
        'uprofile_fixture',
      );
      expect(transport.requests[1].url.queryParameters['limit'], '1');
      expect(transport.requests.last.headers['accept'], 'application/x-jsonl');
      expect(transport.requests.last.headers['content-type'], isNull);
    },
  );

  test('JSONL keeps an explicit media header override', () async {
    final custom = AnthropicClient(
      config: const AnthropicConfig(
        defaultHeaders: {
          'Accept': 'application/binary',
          'Content-Type': 'application/octet-stream',
        },
      ),
      httpClient: transport,
    );
    addTearDown(custom.close);
    transport.queueResponse(
      const MockResponse(
        body: '{"custom_id":"fixture","result":{"type":"expired"}}',
      ),
    );

    final result = await custom.messages.batches
        .results('batch_test123')
        .single;

    expect(result.customId, 'fixture');
    expect(transport.lastRequest!.headers['accept'], 'application/binary');
    expect(
      transport.lastRequest!.headers['content-type'],
      'application/octet-stream',
    );
  });

  test(
    'multipart, binary and gated operations share workspace routing',
    () async {
      transport
        ..queueJsonResponse({
          'id': 'file_fixture',
          'type': 'file',
          'filename': 'fixture.txt',
          'mime_type': 'text/plain',
          'size_bytes': 3,
          'created_at': '2026-11-11T00:00:00Z',
          'downloadable': true,
        })
        ..queueResponse(
          const MockResponse(
            body: 'abc',
            headers: {'content-type': 'application/octet-stream'},
          ),
        )
        ..queueJsonResponse({
          'id': 'skill_fixture',
          'type': 'skill',
          'display_name': 'Fixture',
          'created_at': '2026-11-11T00:00:00Z',
          'updated_at': '2026-11-11T00:00:00Z',
          'latest_version_id': 'skver_fixture',
          'source': {'type': 'custom'},
        })
        ..queueJsonResponse({'data': <Object>[], 'next_page': null});

      final bytes = Uint8List.fromList([97, 98, 99]);
      final file = await client.files.uploadBytes(
        bytes: bytes,
        fileName: 'fixture.txt',
      );
      expect(file.id, 'file_fixture');
      expect(await client.files.download(fileId: file.id), bytes);
      final skill = await client.skills.create(
        files: [SkillFile(path: 'fixture/SKILL.md', bytes: bytes)],
      );
      expect(skill.id, 'skill_fixture');
      expect((await client.agents.list()).data, isEmpty);

      expect(transport.requests, hasLength(4));
      _assertRequest(
        transport.requests[0],
        'POST',
        '/v1/files',
        _workspace,
        beta: 'configured-feature',
      );
      _assertRequest(
        transport.requests[1],
        'GET',
        '/v1/files/file_fixture/content',
        _workspace,
        beta: 'configured-feature',
      );
      _assertRequest(
        transport.requests[2],
        'POST',
        '/v1/skills',
        _workspace,
        beta: 'configured-feature',
      );
      _assertRequest(
        transport.requests[3],
        'GET',
        '/v1/agents',
        _workspace,
        beta: _managedAgentsBeta,
      );
      expect(transport.requests[0], isA<http.MultipartRequest>());
      expect(transport.requests[2], isA<http.MultipartRequest>());
    },
  );
}

void _assertRequest(
  http.BaseRequest request,
  String method,
  String path,
  String workspace, {
  required String beta,
}) {
  expect(request.method, method);
  expect(request.url.path, path);
  expect(request.url.queryParameters, isNot(contains('beta')));
  expect(request.headers['anthropic-version'], _version);
  expect(request.headers['anthropic-workspace-id'], workspace);
  expect(request.headers['anthropic-beta'], beta);
  expect(request.headers['x-api-key'], 'workspace-test-key');
}
