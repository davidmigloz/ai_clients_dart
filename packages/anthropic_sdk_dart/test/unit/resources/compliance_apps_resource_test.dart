import 'dart:async';
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

const _date = '2026-11-11T00:00:00Z';
const _chat = <String, dynamic>{
  'id': 'chat-1',
  'name': 'A chat',
  'created_at': _date,
  'updated_at': _date,
  'organization_uuid': 'org-1',
  'project_id': 'project-1',
  'model': null,
};
const _file = <String, dynamic>{
  'id': 'file-1',
  'filename': 'café.txt',
  'size_bytes': 3,
  'mime_type': 'text/plain',
  'created_at': _date,
  'md5': null,
};
const _project = <String, dynamic>{
  'id': 'project-1',
  'name': 'A project',
  'organization_uuid': 'org-1',
  'is_private': true,
  'created_at': _date,
  'updated_at': _date,
};
const _session = <String, dynamic>{
  'id': 'session-1',
  'organization_uuid': 'org-1',
  'created_at': _date,
  'updated_at': _date,
  'product_surface': 'future_application',
};
const _sessionMessage = <String, dynamic>{
  'id': 'message-1',
  'role': 'assistant',
  'created_at': _date,
  'content': [
    {'type': 'future_block', 'text': 'data'},
  ],
  'content_unavailable': true,
};

Map<String, dynamic> _cursor(
  Map<String, dynamic> item, {
  bool cursorOnly = false,
}) => {
  'data': [item],
  if (!cursorOnly) 'has_more': true,
  'next_page': 'next/+',
};

void main() {
  late _Transport transport;
  late AnthropicClient client;
  late ComplianceAppsResource apps;

  setUp(() {
    transport = _Transport();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('scoped-compliance-key'),
        apiVersion: '2026-10-21',
        workspaceId: 'workspace-config',
        defaultHeaders: {'Anthropic-Workspace-ID': 'unused-workspace'},
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    apps = client.compliance.apps;
  });
  tearDown(() => client.close());

  void expectRequest(
    String route, {
    String method = 'GET',
    Map<String, List<String>> query = const {},
    bool binary = false,
  }) {
    final request = transport.requests.single;
    expect(request.method, method);
    expect(request.url.path, '/v1/compliance/apps/$route');
    expect(request.url.queryParametersAll, query);
    expect(request.headers['x-api-key'], 'scoped-compliance-key');
    expect(request.headers['anthropic-version'], '2026-10-21');
    expect(request.headers['anthropic-workspace-id'], isNull);
    expect(request.headers['authorization'], isNull);
    expect(request.headers['anthropic-beta'], isNull);
    expect(request.headers['accept'], binary ? '*/*' : 'application/json');
    expect(request.headers['content-type'], isNull);
    expect(request.followRedirects, isFalse);
    expect((request as http.Request).bodyBytes, isEmpty);
  }

  void jsonEndpoint<T>(
    String label,
    String route,
    Future<T> Function(ComplianceAppsResource) run,
    Map<String, dynamic> response,
    void Function(T) verify, {
    String method = 'GET',
    Map<String, List<String>> query = const {},
  }) {
    test(label, () async {
      transport.queueJson(response);
      verify(await run(apps));
      expectRequest(route, method: method, query: query);
    });
  }

  void downloadEndpoint(
    String label,
    String route,
    Stream<List<int>> Function(
      ComplianceAppsResource,
      void Function(ComplianceDownloadHeaders),
    )
    run, {
    Map<String, List<String>> query = const {},
  }) {
    test(label, () async {
      transport.queue(
        Stream<List<int>>.fromIterable([
          [0, 255],
          [193, 36],
        ]),
        headers: {
          'Content-Type': 'application/zip',
          'Content-Disposition': 'attachment; filename=fixture.zip',
          'Content-MD5': 'opaque-checksum',
          'Request-ID': 'download-id',
          'Content-Length': '4',
        },
      );
      ComplianceDownloadHeaders? headers;
      final body = run(apps, (value) => headers = value);
      expect(transport.requests, isEmpty);
      expect(await body.expand((bytes) => bytes).toList(), [0, 255, 193, 36]);
      expectRequest(route, query: query, binary: true);
      expect(headers?.contentType, 'application/zip');
      expect(headers?.contentDisposition, 'attachment; filename=fixture.zip');
      expect(headers?.contentMd5, 'opaque-checksum');
      expect(headers?.requestId, 'download-id');
    });
  }

  jsonEndpoint(
    'lists chats with ID cursor, typed order and dotted time filter',
    'chats',
    (apps) => apps.listChats(
      afterId: 'after/+',
      limit: 2,
      orderBy: ComplianceChatOrderBy.updatedAt,
      organizationIds: ['org-1', 'org-2'],
      updatedAt: ComplianceTimeRange(gte: DateTime.utc(2026, 11, 11)),
    ),
    {
      'data': [_chat],
      'first_id': 'first',
      'last_id': 'last',
      'has_more': true,
    },
    (page) {
      expect(page.lastId, 'last');
      expect(page.data.single.id, 'chat-1');
      expect(page.data.single.projectId, 'project-1');
    },
    query: {
      'after_id': ['after/+'],
      'limit': ['2'],
      'order_by': ['updated_at'],
      'organization_ids[]': ['org-1', 'org-2'],
      'updated_at.gte': ['2026-11-11T00:00:00.000Z'],
    },
  );
  jsonEndpoint(
    'deletes a chat and returns the JSON receipt',
    'chats/chat-1',
    (apps) => apps.deleteChat('chat-1'),
    {'type': 'claude_chat_deleted', 'id': 'chat-1'},
    (receipt) => expect(receipt?.type, 'claude_chat_deleted'),
    method: 'DELETE',
  );
  jsonEndpoint(
    'lists chat messages and preserves the enclosing chat and unknown blocks',
    'chats/chat-1/messages',
    (apps) => apps.listChatMessages(
      'chat-1',
      beforeId: 'previous',
      order: ComplianceOrder.desc,
      toolResultMaxChars: 0,
      toolUseInputMaxChars: 1024,
    ),
    {
      ..._chat,
      'first_id': 'first',
      'last_id': 'last',
      'has_more': true,
      'chat_messages': [_sessionMessage],
    },
    (result) {
      expect(result.id, 'chat-1');
      expect(result.lastId, 'last');
      expect(result.messages.single.id, 'message-1');
      expect(result.messages.single.content, _sessionMessage['content']);
    },
    query: {
      'before_id': ['previous'],
      'order': ['desc'],
      'tool_result_max_chars': ['0'],
      'tool_use_input_max_chars': ['1024'],
    },
  );
  jsonEndpoint(
    'retrieves uploaded chat file metadata',
    'chats/files/file-1',
    (apps) => apps.retrieveChatFile('file-1'),
    _file,
    (file) {
      expect(file.filename, 'café.txt');
      expect(file.sizeBytes, 3);
    },
  );
  jsonEndpoint(
    'deletes uploaded chat files using DELETE without a body',
    'chats/files/file-1',
    (apps) => apps.deleteChatFile('file-1'),
    {'type': 'claude_file_deleted', 'id': 'file-1'},
    (receipt) => expect(receipt?.id, 'file-1'),
    method: 'DELETE',
  );
  downloadEndpoint(
    'downloads uploaded file bytes and media headers',
    'chats/files/file-1/content',
    (apps, receive) => apps.downloadChatFile('file-1', onResponse: receive),
  );
  jsonEndpoint(
    'retrieves generated chat file metadata from its separate route',
    'chats/generated-files/generated-1',
    (apps) => apps.retrieveGeneratedChatFile('generated-1'),
    {..._file, 'id': 'generated-1', 'claude_chat_id': 'chat-1'},
    (file) {
      expect(file.id, 'generated-1');
      expect(file.raw['claude_chat_id'], 'chat-1');
    },
  );
  downloadEndpoint(
    'downloads Claude-generated file bytes',
    'chats/generated-files/generated-1/content',
    (apps, receive) =>
        apps.downloadGeneratedChatFile('generated-1', onResponse: receive),
  );
  jsonEndpoint(
    'lists projects with repeatable user and organization filters',
    'projects',
    (apps) => apps.listProjects(
      page: 'page/+',
      limit: 4,
      organizationIds: ['org-1', 'org-2'],
      userIds: ['user-1', 'user-2'],
      createdAt: ComplianceTimeRange(lte: DateTime.utc(2026, 11, 11)),
      updatedAt: ComplianceTimeRange(gt: DateTime.utc(2026, 11, 9)),
    ),
    _cursor(_project),
    (page) {
      expect(page.data.single.isPrivate, isTrue);
      expect(page.nextPage, 'next/+');
    },
    query: {
      'page': ['page/+'],
      'limit': ['4'],
      'organization_ids[]': ['org-1', 'org-2'],
      'user_ids[]': ['user-1', 'user-2'],
      'created_at.lte': ['2026-11-11T00:00:00.000Z'],
      'updated_at.gt': ['2026-11-09T00:00:00.000Z'],
    },
  );
  jsonEndpoint(
    'retrieves project details including instructions',
    'projects/project-1',
    (apps) => apps.retrieveProject('project-1'),
    {..._project, 'instructions': 'Synthetic instructions'},
    (project) => expect(project.instructions, 'Synthetic instructions'),
  );
  jsonEndpoint(
    'deletes projects and decodes the receipt',
    'projects/project-1',
    (apps) => apps.deleteProject('project-1'),
    {'type': 'claude_project_deleted', 'id': 'project-1'},
    (receipt) => expect(receipt?.id, 'project-1'),
    method: 'DELETE',
  );
  jsonEndpoint(
    'lists project attachments and retains future variants',
    'projects/project-1/attachments',
    (apps) => apps.listProjectAttachments('project-1', page: 'cursor'),
    _cursor({
      'id': 'document-1',
      'type': 'new_attachment',
      'filename': 'fixture.txt',
      'future_field': {'active': true},
    }),
    (page) {
      expect(page.data.single.type, 'new_attachment');
      expect(page.data.single.raw['future_field'], {'active': true});
    },
    query: {
      'page': ['cursor'],
    },
  );
  jsonEndpoint(
    'lists project collaborators and retains their specific identities',
    'projects/project-1/collaborators',
    (apps) => apps.listProjectCollaborators('project-1', limit: 1),
    _cursor({'type': 'group', 'role': 'editor', 'group_id': 'group-1'}),
    (page) {
      expect(page.data.single.role, 'editor');
      expect(page.data.single.raw['group_id'], 'group-1');
    },
    query: {
      'limit': ['1'],
    },
  );
  jsonEndpoint(
    'retrieves project document text as JSON',
    'projects/documents/document-1',
    (apps) => apps.retrieveProjectDocument('document-1'),
    {
      'id': 'document-1',
      'filename': 'fixture.txt',
      'content': 'Document data',
      'created_at': _date,
    },
    (document) => expect(document.content, 'Document data'),
  );
  jsonEndpoint(
    'retrieves project document metadata using its specific path',
    'projects/documents/document-1/metadata',
    (apps) => apps.retrieveProjectDocumentMetadata('document-1'),
    {..._file, 'id': 'document-1'},
    (metadata) => expect(metadata.id, 'document-1'),
  );
  jsonEndpoint(
    'deletes project documents without encoding the action in the body',
    'projects/documents/document-1',
    (apps) => apps.deleteProjectDocument('document-1'),
    {'type': 'claude_project_document_deleted', 'id': 'document-1'},
    (receipt) => expect(receipt?.id, 'document-1'),
    method: 'DELETE',
  );
  jsonEndpoint(
    'retrieves versioned chat artifact metadata',
    'artifacts/version-1',
    (apps) => apps.retrieveArtifactVersion('version-1'),
    {
      'id': 'version-1',
      'version_id': 'v1',
      'claude_chat_id': 'chat-1',
      'size_bytes': 123,
    },
    (artifact) {
      expect(artifact.versionId, 'v1');
      expect(artifact.chatId, 'chat-1');
    },
  );
  jsonEndpoint(
    'retrieves chat artifact version text inside a JSON response',
    'artifacts/version-1/content',
    (apps) => apps.retrieveArtifactVersionContent('version-1'),
    {'content': 'Résumé', 'title': 'Report', 'artifact_type': 'text/markdown'},
    (artifact) {
      expect(artifact.content, 'Résumé');
      expect(artifact.title, 'Report');
      expect(artifact.artifactType, 'text/markdown');
    },
  );
  jsonEndpoint(
    'lists local sessions with the supported updated_at.gte filter',
    'sessions/local',
    (apps) => apps.listLocalSessions(
      page: 'local-page',
      updatedAtOrAfter: DateTime.utc(2026, 11, 11),
    ),
    _cursor(_session, cursorOnly: true),
    (page) {
      expect(page.data.single.productSurface, 'future_application');
      expect(page.hasMore, isTrue);
    },
    query: {
      'page': ['local-page'],
      'updated_at.gte': ['2026-11-11T00:00:00.000Z'],
    },
  );
  jsonEndpoint(
    'retrieves local session metadata',
    'sessions/local/session-1',
    (apps) => apps.retrieveLocalSession('session-1'),
    {..._session, 'truncated': true},
    (session) {
      expect(session.id, 'session-1');
      expect(session.truncated, isTrue);
    },
  );
  jsonEndpoint(
    'retrieves a local transcript page with byte limits and session metadata',
    'sessions/local/session-1/messages',
    (apps) => apps.listLocalSessionMessages(
      'session-1',
      page: 'transcript-page',
      limit: 3,
      order: ComplianceOrder.asc,
      toolResultMaxBytes: 0,
      toolUseInputMaxBytes: 5000,
    ),
    {..._cursor(_sessionMessage, cursorOnly: true), 'session': _session},
    (transcript) {
      expect(transcript.session.id, 'session-1');
      expect(transcript.data.single.content, _sessionMessage['content']);
      expect(transcript.nextPage, 'next/+');
    },
    query: {
      'page': ['transcript-page'],
      'limit': ['3'],
      'order': ['asc'],
      'tool_result_max_bytes': ['0'],
      'tool_use_input_max_bytes': ['5000'],
    },
  );
  jsonEndpoint(
    'lists remote sessions with query filters and a cursor',
    'sessions/remote',
    (apps) => apps.listRemoteSessions(
      organizationIds: ['org-1', 'org-2'],
      userIds: ['user-1'],
      createdAt: ComplianceTimeRange(lt: DateTime.utc(2026, 11, 11)),
    ),
    _cursor({..._session, 'status': 'running'}, cursorOnly: true),
    (page) => expect(page.data.single.status, 'running'),
    query: {
      'organization_ids[]': ['org-1', 'org-2'],
      'user_ids[]': ['user-1'],
      'created_at.lt': ['2026-11-11T00:00:00.000Z'],
    },
  );
  jsonEndpoint(
    'retrieves a remote transcript and preserves unavailable content state',
    'sessions/remote/session-1/messages',
    (apps) => apps.listRemoteSessionMessages('session-1', page: 'remote-page'),
    {..._cursor(_sessionMessage, cursorOnly: true), 'session': _session},
    (transcript) {
      expect(transcript.session.id, 'session-1');
      expect(transcript.data.single.contentUnavailable, isTrue);
    },
    query: {
      'page': ['remote-page'],
    },
  );
  jsonEndpoint(
    'lists Code Artifacts and decodes retained version metadata',
    'code/artifacts',
    (apps) => apps.listCodeArtifacts(
      organizationIds: ['org-1', 'org-2'],
      userIds: ['user-1'],
      page: 'code-page',
      updatedAt: ComplianceTimeRange(gte: DateTime.utc(2026, 11, 11)),
    ),
    _cursor({
      'id': 'artifact-1',
      'artifact_type': 'code',
      'organization_uuid': 'org-1',
      'read_mode': 'org',
      'versions': [
        {'id': 'v1', 'name': 'Title'},
      ],
    }),
    (page) {
      expect(page.data.single.id, 'artifact-1');
      expect(page.data.single.versions.single.name, 'Title');
    },
    query: {
      'organization_ids[]': ['org-1', 'org-2'],
      'user_ids[]': ['user-1'],
      'page': ['code-page'],
      'updated_at.gte': ['2026-11-11T00:00:00.000Z'],
    },
  );
  downloadEndpoint(
    'downloads versioned Code Artifacts with ZIP requested',
    'code/artifacts/artifact-1/versions/v%2F1',
    (apps, receive) => apps.downloadCodeArtifactVersion(
      'artifact-1',
      'v/1',
      allowZip: true,
      onResponse: receive,
    ),
    query: {
      'multi_file_format': ['zip'],
    },
  );
  downloadEndpoint(
    'downloads current Code Artifacts without forcing ZIP',
    'code/artifacts/artifact-1/content',
    (apps, receive) =>
        apps.downloadCodeArtifact('artifact-1', onResponse: receive),
  );
  jsonEndpoint(
    'deletes a Code Artifact and parses the accepted deletion receipt',
    'code/artifacts/artifact-1',
    (apps) => apps.deleteCodeArtifact('artifact-1'),
    {'type': 'code_artifact_deleted', 'id': 'artifact-1'},
    (receipt) => expect(receipt?.id, 'artifact-1'),
    method: 'DELETE',
  );

  test('rejects conflicting chat cursors before transport', () async {
    await expectLater(
      apps.listChats(beforeId: 'one', afterId: 'two'),
      throwsArgumentError,
    );
    await expectLater(
      apps.listChatMessages('chat-1', beforeId: 'one', afterId: 'two'),
      throwsArgumentError,
    );
    expect(transport.requests, isEmpty);
  });

  test('checks each pagination envelope before returning the page', () async {
    transport
      ..queueJson({'data': <Object>[], 'next_page': null})
      ..queueJson({'data': <Object>[], 'has_more': false})
      ..queueJson({
        'data': <Object>[],
        'first_id': null,
        'last_id': null,
        'has_more': true,
      });
    await expectLater(apps.listCodeArtifacts(), throwsFormatException);
    await expectLater(apps.listLocalSessions(), throwsFormatException);
    await expectLater(apps.listChats(), throwsFormatException);
  });

  test('binary HTTP errors use the documented body request ID', () async {
    transport.queueJson({
      'type': 'error',
      'request_id': 'provider-body',
      'error': {'type': 'permission_error', 'message': 'Scope missing'},
    }, statusCode: 403);
    await expectLater(
      apps.downloadChatFile('file-1'),
      emitsInOrder([
        emitsError(
          isA<ApiException>()
              .having((e) => e.statusCode, 'status', 403)
              .having((e) => e.requestId, 'provider ID', 'provider-body'),
        ),
        emitsDone,
      ]),
    );
  });

  test('binary HTTP errors keep diagnostics on malformed UTF-8', () async {
    transport.queue(
      Stream.value([0xf0, 0x9f]),
      statusCode: 503,
      headers: {
        'content-type': 'application/json',
        'request-id': 'provider-malformed',
      },
    );
    await expectLater(
      apps.downloadGeneratedChatFile('file-1'),
      emitsInOrder([
        emitsError(
          isA<ApiException>()
              .having((e) => e.statusCode, 'status', 503)
              .having((e) => e.requestId, 'provider ID', 'provider-malformed'),
        ),
        emitsDone,
      ]),
    );
  });

  test('deletion validates the receipt discriminator and ID eagerly', () async {
    transport
      ..queueJson(<String, dynamic>{})
      ..queueJson({'id': 'artifact-1', 'type': 'unrelated'})
      ..queueJson({'id': 'artifact-1'})
      ..queueJson({'id': 'chat-1'});
    for (var i = 0; i < 3; i++) {
      await expectLater(
        apps.deleteCodeArtifact('artifact-1'),
        throwsFormatException,
      );
    }
    final receipt = await apps.deleteChat('chat-1');
    expect(receipt?.id, 'chat-1');
    expect(receipt?.type, isNull);
  });

  test('a transcript must carry session metadata before returning', () async {
    transport.queueJson({'data': <Object>[], 'next_page': null});
    await expectLater(
      apps.listRemoteSessionMessages('session-1'),
      throwsFormatException,
    );
  });

  for (final useAbortTrigger in [false, true]) {
    test(
      'header callback releases the stalled body (abort=$useAbortTrigger)',
      () async {
        final canceled = Completer<void>();
        final body = StreamController<List<int>>(onCancel: canceled.complete);
        addTearDown(body.close);
        transport.queue(body.stream);
        final abort = Completer<void>.sync();
        final headers = Completer<void>();
        final errors = <Object>[];
        final done = Completer<void>();
        late StreamSubscription<List<int>> subscription;
        subscription = apps
            .downloadChatFile(
              'file-1',
              abortTrigger: useAbortTrigger ? abort.future : null,
              onResponse: (_) {
                if (useAbortTrigger) {
                  abort.complete();
                } else {
                  unawaited(subscription.cancel());
                }
                headers.complete();
              },
            )
            .listen(
              (_) => fail('Unexpected download bytes'),
              onError: errors.add,
              onDone: done.complete,
            );
        addTearDown(subscription.cancel);
        await headers.future.timeout(const Duration(seconds: 1));
        await canceled.future.timeout(const Duration(seconds: 1));
        expect(body.hasListener, isFalse);
        if (useAbortTrigger) {
          await done.future.timeout(const Duration(seconds: 1));
          expect(errors.single, isA<AbortedException>());
        } else {
          expect(errors, isEmpty);
        }
      },
    );
  }

  for (final statusCode in [200, 403]) {
    test(
      'sync abort during body subscription releases HTTP $statusCode',
      () async {
        final abort = Completer<void>.sync();
        final canceled = Completer<void>();
        var cancels = 0;
        final body = StreamController<List<int>>(
          onListen: abort.complete,
          onCancel: () {
            cancels++;
            canceled.complete();
          },
        );
        addTearDown(body.close);
        transport.queue(body.stream, statusCode: statusCode);
        await expectLater(
          apps
              .downloadChatFile('file-1', abortTrigger: abort.future)
              .toList()
              .timeout(const Duration(seconds: 1)),
          throwsA(isA<AbortedException>()),
        );
        await canceled.future.timeout(const Duration(seconds: 1));
        expect(body.hasListener, isFalse);
        expect(cancels, 1);
      },
    );
  }

  test('an empty successful deletion does not try to decode JSON', () async {
    transport.queue(const Stream<List<int>>.empty(), statusCode: 204);
    expect(await apps.deleteChat('chat-1'), isNull);
    expectRequest('chats/chat-1', method: 'DELETE');
  });

  test('an HTTP error is terminal before download headers or bytes', () async {
    transport.queueJson(
      {
        'type': 'error',
        'error': {'type': 'invalid_request_error', 'message': 'ZIP required'},
      },
      statusCode: 422,
      headers: {'request-id': 'download-failure'},
    );
    var headerCallbacks = 0;
    await expectLater(
      apps.downloadCodeArtifact(
        'artifact-1',
        onResponse: (_) => headerCallbacks++,
      ),
      emitsInOrder([
        emitsError(
          isA<ApiException>()
              .having((error) => error.statusCode, 'status', 422)
              .having(
                (error) => error.requestId,
                'requestId',
                'download-failure',
              ),
        ),
        emitsDone,
      ]),
    );
    expect(headerCallbacks, 0);
    expectRequest('code/artifacts/artifact-1/content', binary: true);
  });

  test(
    'a redirect fails without forwarding credentials or returning data',
    () async {
      transport.queue(
        Stream<List<int>>.value([1, 2]),
        statusCode: 302,
        headers: {
          'location': 'https://elsewhere.invalid/private',
          'request-id': 'provider-redirect',
        },
      );
      await expectLater(
        apps.downloadChatFile('file-1'),
        emitsInOrder([
          emitsError(
            isA<ApiException>()
                .having((error) => error.statusCode, 'status', 302)
                .having(
                  (error) => error.requestId,
                  'requestId',
                  'provider-redirect',
                )
                .having(
                  (error) => error.responseMetadata?.headers,
                  'headers',
                  isNot(contains('location')),
                ),
          ),
          emitsDone,
        ]),
      );
      expectRequest('chats/files/file-1/content', binary: true);
    },
  );

  test(
    'download stream propagates failure after a partial binary body',
    () async {
      final failure = StateError('Fixture stream interrupted');
      Stream<List<int>> chunks() async* {
        yield [0, 255];
        throw failure;
      }

      transport.queue(chunks());
      await expectLater(
        apps.downloadCodeArtifact('artifact-1'),
        emitsInOrder([
          [0, 255],
          emitsError(same(failure)),
          emitsDone,
        ]),
      );
    },
  );

  test(
    'download metadata checks escaped credentials and keeps safe filenames',
    () async {
      const safeDisposition =
          "attachment; filename=100%25; filename*=UTF-8''caf%C3%A9.txt";
      for (final (disposition, expected) in [
        ("attachment; filename*=UTF-8''scoped%2dcompliance%2Dkey", null),
        ("attachment; filename*=UTF-8''%FFscoped%2Dcompliance%2Dkey", null),
        (safeDisposition, safeDisposition),
      ]) {
        transport.queue(
          Stream.value([0, 255]),
          headers: {
            'Request-Id': 'req_clean',
            'Content-Disposition': disposition,
            'Content-Type': 'application/octet-stream',
          },
        );
        late ComplianceDownloadHeaders observed;
        expect(
          await apps
              .downloadChatFile(
                'file-1',
                onResponse: (value) => observed = value,
              )
              .expand((chunk) => chunk)
              .toList(),
          [0, 255],
        );
        expect(observed.requestId, 'req_clean');
        expect(observed.contentDisposition, expected);
        expect(observed.contentType, 'application/octet-stream');
      }
    },
  );

  test('download metadata omits headers that echo the effective key', () async {
    transport.queue(
      Stream.value([0, 255, 1]),
      headers: {
        'Request-Id': 'reflected-scoped-compliance-key',
        'Content-Disposition': 'attachment; filename="scoped-compliance-key"',
        'Content-Type': 'application/octet-stream',
        'Content-Md5': 'fixture-checksum',
      },
    );
    late ComplianceDownloadHeaders observed;
    final bytes = await apps
        .downloadChatFile('file-1', onResponse: (value) => observed = value)
        .expand((chunk) => chunk)
        .toList();
    expect(bytes, [0, 255, 1]);
    expect(observed.requestId, isNull);
    expect(observed.contentDisposition, isNull);
    expect(observed.contentType, 'application/octet-stream');
    expect(observed.contentMd5, 'fixture-checksum');
    expectRequest('chats/files/file-1/content', binary: true);
  });

  test('a failed header callback releases the binary body', () async {
    final canceled = Completer<void>();
    final body = StreamController<List<int>>(onCancel: canceled.complete);
    addTearDown(body.close);
    transport.queue(body.stream);
    final failure = StateError('Fixture header callback failed');
    await expectLater(
      apps.downloadChatFile('file-1', onResponse: (_) => throw failure),
      emitsInOrder([emitsError(same(failure)), emitsDone]),
    );
    await canceled.future.timeout(const Duration(seconds: 1));
  });

  test('aborting a stalled body cancels only that download', () async {
    final abort = Completer<void>();
    final canceled = Completer<void>();
    final body = StreamController<List<int>>(onCancel: canceled.complete);
    addTearDown(body.close);
    transport
      ..queue(body.stream)
      ..queueJson(_file);
    final firstChunk = Completer<void>();
    final stream = apps
        .downloadChatFile('file-1', abortTrigger: abort.future)
        .map((bytes) {
          firstChunk.complete();
          return bytes;
        });
    final expected = expectLater(
      stream,
      emitsInOrder([
        [255],
        emitsError(isA<AbortedException>()),
        emitsDone,
      ]),
    );
    body.add([255]);
    await firstChunk.future;
    abort.complete();
    await expected;
    await canceled.future.timeout(const Duration(seconds: 1));
    expect((await apps.retrieveChatFile('file-1')).id, 'file-1');
    expect(transport.requests, hasLength(2));
  });
}

final class _Transport extends http.BaseClient {
  final requests = <http.BaseRequest>[];
  final _responses = <http.StreamedResponse>[];

  void queue(
    Stream<List<int>> bytes, {
    int statusCode = 200,
    Map<String, String> headers = const {},
  }) => _responses.add(
    http.StreamedResponse(bytes, statusCode, headers: headers),
  );

  void queueJson(
    Map<String, dynamic> json, {
    int statusCode = 200,
    Map<String, String> headers = const {},
  }) => queue(
    Stream<List<int>>.value(utf8.encode(jsonEncode(json))),
    statusCode: statusCode,
    headers: {'content-type': 'application/json', ...headers},
  );

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    return _responses.removeAt(0);
  }
}
