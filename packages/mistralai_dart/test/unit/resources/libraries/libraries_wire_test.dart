import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const Map<String, Object?> _library = {
  'id': 'library-1',
  'name': 'Manuals',
  'created_at': '2026-11-27T08:00:00.123456Z',
  'updated_at': '2026-11-27T08:15:00Z',
  'owner_id': null,
  'owner_type': 'Workspace',
  'total_size': 2,
  'nb_documents': 1,
  'chunk_size': 512,
  'explicit_workspace_members_count': 1,
};

const Map<String, Object?> _document = {
  'id': 'doc-1',
  'library_id': 'library-1',
  'name': 'manual.txt',
  'created_at': '2026-11-27T08:00:00.123456Z',
  'hash': 'sample-hash',
  'extension': 'txt',
  'mime_type': 'text/plain',
  'size': 2,
  'process_status': 'done',
  'processing_status': 'Extraction complete',
  'uploaded_by_id': null,
  'uploaded_by_type': 'User',
  'tokens_processing_total': 3,
  'tokens_processing_main_content': 2,
  'tokens_processing_summary': 1,
  'attributes': {
    'revision': 1,
    'topics': ['manual'],
  },
  'expires_at': '2026-12-01T00:00:00Z',
};

const Map<String, Object> _pagination = {
  'total_items': 3,
  'total_pages': 2,
  'current_page': 1,
  'page_size': 2,
  'has_more': true,
};

const _share = {
  'library_id': 'library-1',
  'org_id': 'org-1',
  'role': 'Viewer',
  'share_with_type': 'Workspace',
  'share_with_uuid': 'workspace-2',
};

void main() {
  final requests = <http.Request>[];

  MistralClient clientReturning(Object? Function(http.Request) response) {
    requests.clear();
    final transport = MockClient((request) async {
      requests.add(request);
      final data = response(request);
      if (data == null) return http.Response('', 204);
      if (data is List<int>) return http.Response.bytes(data, 200);
      return http.Response(
        jsonEncode(data),
        request.method == 'POST' ? 201 : 200,
      );
    });
    addTearDown(transport.close);
    final client = MistralClient(
      config: const MistralConfig(authProvider: ApiKeyProvider('fake-key')),
      httpClient: transport,
    );
    addTearDown(client.close);
    return client;
  }

  test('keeps status changes coherent across a document round-trip', () {
    final runningPayload = Map<String, dynamic>.of(_document)
      ..['process_status'] = 'in_progress'
      ..['processing_status'] = 'Extraction in progress';
    final running = LibraryDocument.fromJson(runningPayload);
    expect(running.status, LibraryDocumentStatus.running);

    final legacyUpdate = running.copyWith(
      status: LibraryDocumentStatus.completed,
    );
    expect(legacyUpdate.toJson()['process_status'], 'done');
    expect(legacyUpdate.toJson()['processing_status'], 'Completed');
    final restored = LibraryDocument.fromJson(legacyUpdate.toJson());
    expect(restored, legacyUpdate);
    expect(restored.status, LibraryDocumentStatus.completed);

    final wireUpdate = running.copyWith(processStatus: 'done');
    expect(wireUpdate, legacyUpdate);
    expect(wireUpdate.isCompleted, isTrue);
    expect(wireUpdate.copyWith(name: 'other.txt').isCompleted, isTrue);
  });

  test(
    'creates, lists, retrieves and updates libraries using the pinned shape',
    () async {
      final client = clientReturning((request) {
        return switch ((request.method, request.url.path)) {
          ('GET', '/v1/libraries') => {
            'data': [_library],
            'pagination': _pagination,
            'next_page_token': 'cursor-2',
          },
          ('DELETE', _) => null,
          _ => _library,
        };
      });

      final library = await client.libraries.create(
        name: 'Manuals',
        description: 'Product documentation',
        chunkSize: 512,
        ownerType: EntityType.workspace,
      );
      expect(requests.single.method, 'POST');
      expect(jsonDecode(requests.single.body), {
        'name': 'Manuals',
        'description': 'Product documentation',
        'chunk_size': 512,
        'owner_type': 'Workspace',
      });
      expect(library.chunkSize, 512);
      expect(library.createdAt, 1795766400);
      expect(library.createdAtDateTime?.microsecond, 456);
      expect(
        library.copyWith(name: 'renamed').toJson()['created_at'],
        '2026-11-27T08:00:00.123456Z',
      );
      expect(library.explicitWorkspaceMembersCount, 1);

      final list = await client.libraries.list(
        pageToken: 'cursor-1',
        pageSize: 2,
        search: 'Manual',
      );
      expect(requests.last.url.queryParameters, {
        'page_token': 'cursor-1',
        'page_size': '2',
        'search': 'Manual',
      });
      expect(list.nextPageToken, 'cursor-2');
      expect(list.total, 3);
      expect(list.hasMore, isTrue);
      expect(list.pagination?.currentPage, 1);
      expect(list.toJson()['pagination'], _pagination);
      expect(list.data.single, library);

      final result = await client.libraries.retrieve(libraryId: library.id);
      expect(requests.last.url.path, '/v1/libraries/library-1');
      expect(result, library);

      await client.libraries.updatePartial(
        libraryId: library.id,
        request: const UpdateLibraryRequest(name: 'Current name'),
      );
      expect(requests.last.method, 'PATCH');
      expect(jsonDecode(requests.last.body), {'name': 'Current name'});

      await client.libraries.update(libraryId: library.id, name: 'Legacy name');
      expect(requests.last.method, 'PUT');
      expect(jsonDecode(requests.last.body), {'name': 'Legacy name'});

      await client.libraries.delete(libraryId: library.id);
      expect(requests.last.method, 'DELETE');
      expect(requests.last.url.path, '/v1/libraries/library-1');
    },
  );

  test(
    'uploads multipart documents and copies previously uploaded files',
    () async {
      final client = clientReturning(
        (request) => switch (request.url.path) {
          '/v1/files/file-1' => {
            'id': 'file-1',
            'filename': 'source.txt',
            'mimetype': 'text/plain',
          },
          '/v1/files/file-1/content' => [72, 105],
          _ => _document,
        },
      );

      final document = await client.libraries.documents.upload(
        libraryId: 'library-1',
        bytes: [72, 105],
        fileName: 'manual.txt',
        mimeType: 'text/plain',
      );
      final directUpload = requests.single;
      expect(directUpload.method, 'POST');
      expect(directUpload.url.path, '/v1/libraries/library-1/documents');
      expect(
        directUpload.headers['content-type'],
        startsWith('multipart/form-data; boundary='),
      );
      expect(directUpload.headers['authorization'], 'Bearer fake-key');
      expect(directUpload.body, contains('name="file"; filename="manual.txt"'));
      expect(directUpload.body, contains('content-type: text/plain'));
      expect(directUpload.body, contains('\r\nHi\r\n'));
      expect(document.libraryId, 'library-1');
      expect(document.createdAt, 1795766400);
      expect(document.createdAtDateTime?.microsecond, 456);
      expect(
        document.copyWith(name: 'renamed').toJson()['created_at'],
        '2026-11-27T08:00:00.123456Z',
      );
      expect(document.processingStatus, 'Extraction complete');
      expect(document.processStatus, 'done');
      expect(document.isCompleted, isTrue);
      expect(document.attributes, {
        'revision': 1,
        'topics': ['manual'],
      });
      expect(document.tokensProcessingMainContent, 2);

      await client.libraries.documents.create(
        libraryId: 'library-1',
        fileId: 'file-1',
        documentName: 'copy.txt',
      );
      expect(requests.map((r) => (r.method, r.url.path)), [
        ('POST', '/v1/libraries/library-1/documents'),
        ('GET', '/v1/files/file-1'),
        ('GET', '/v1/files/file-1/content'),
        ('POST', '/v1/libraries/library-1/documents'),
      ]);
      expect(requests.last.body, contains('name="file"; filename="copy.txt"'));
      expect(requests.last.body, contains('\r\nHi\r\n'));
    },
  );

  test(
    'reads paginated library documents, text, status and signed URLs',
    () async {
      final client = clientReturning((request) {
        return switch (request.url.pathSegments.last) {
          'documents' => {
            'pagination': _pagination,
            'data': [_document],
          },
          'text_content' => {'text': 'Hello'},
          'status' => {
            'document_id': 'doc-1',
            'process_status': 'done',
            'processing_status': 'Extraction complete',
          },
          'signed-url' => 'https://example.test/original',
          'extracted-text-signed-url' => 'https://example.test/extracted',
          _ => _document,
        };
      });

      final docs = client.libraries.documents;
      final page = await docs.list(
        libraryId: 'library-1',
        page: 1,
        pageSize: 2,
        search: 'manual',
        filtersAttributes: '{"revision":1}',
        sortBy: 'name',
        sortOrder: 'asc',
      );
      expect(requests.last.url.queryParameters, {
        'page': '1',
        'page_size': '2',
        'search': 'manual',
        'filters_attributes': '{"revision":1}',
        'sort_by': 'name',
        'sort_order': 'asc',
      });
      expect(page.pagination?.pageSize, 2);
      expect(page.total, 3);
      expect(page.hasMore, isTrue);
      expect(page.toJson()['pagination'], _pagination);
      final document = await docs.retrieve(
        libraryId: 'library-1',
        documentId: 'doc-1',
      );
      expect(document, page.data.single);
      expect(document.copyWith(expiresAt: null).expiresAt, isNull);

      final text = await docs.getContent(
        libraryId: 'library-1',
        documentId: 'doc-1',
        pageStart: 0,
        pageEnd: 1,
      );
      expect(
        requests.last.url.path,
        '/v1/libraries/library-1/documents/doc-1/text_content',
      );
      expect(requests.last.url.queryParameters, {
        'page_start': '0',
        'page_end': '1',
      });
      expect(text.text, 'Hello');

      final status = await docs.getStatus(
        libraryId: 'library-1',
        documentId: 'doc-1',
      );
      expect(status.processStatus, 'done');
      expect(
        await docs.getSignedUrl(libraryId: 'library-1', documentId: 'doc-1'),
        'https://example.test/original',
      );
      expect(
        await docs.getExtractedTextSignedUrl(
          libraryId: 'library-1',
          documentId: 'doc-1',
        ),
        'https://example.test/extracted',
      );
    },
  );

  test('preserves legacy PUT alongside canonical document PATCH', () async {
    final client = clientReturning((request) {
      if (request.method == 'DELETE' || request.method == 'POST') return null;
      return _document;
    });
    final docs = client.libraries.documents;

    await docs.updatePartial(
      libraryId: 'library-1',
      documentId: 'doc-1',
      request: const UpdateDocumentRequest(
        name: 'New name',
        attributes: {'revision': 2},
        clearExpiresAt: true,
      ),
    );
    expect(requests.last.method, 'PATCH');
    expect(requests.last.url.path, '/v1/libraries/library-1/documents/doc-1');
    expect(jsonDecode(requests.last.body), {
      'name': 'New name',
      'attributes': {'revision': 2},
      'expires_at': null,
    });

    await docs.update(
      libraryId: 'library-1',
      documentId: 'doc-1',
      documentName: 'Old caller',
    );
    expect(requests.last.method, 'PUT');
    expect(jsonDecode(requests.last.body), {'name': 'Old caller'});

    await docs.reprocess(libraryId: 'library-1', documentId: 'doc-1');
    expect(requests.last.method, 'POST');
    expect(
      requests.last.url.path,
      '/v1/libraries/library-1/documents/doc-1/reprocess',
    );
    await docs.delete(libraryId: 'library-1', documentId: 'doc-1');
    expect(requests.last.method, 'DELETE');
    expect(requests.last.url.path, '/v1/libraries/library-1/documents/doc-1');
  });

  test(
    'sends access grants and revocations with their distinct bodies',
    () async {
      final client = clientReturning(
        (request) => request.method == 'GET'
            ? {
                'data': [_share],
              }
            : _share,
      );

      final grants = await client.libraries.listSharing(libraryId: 'library-1');
      expect(grants.data.single.shareWithType, 'Workspace');
      final grant = await client.libraries.share(
        libraryId: 'library-1',
        request: const SharingRequest(
          level: ShareLevel.viewer,
          shareWithUuid: 'workspace-2',
          shareWithType: EntityType.workspace,
        ),
      );
      expect(grant.shareWithUuid, 'workspace-2');
      expect(requests.last.method, 'PUT');
      expect(requests.last.url.path, '/v1/libraries/library-1/share');
      expect(jsonDecode(requests.last.body), {
        'level': 'Viewer',
        'share_with_uuid': 'workspace-2',
        'share_with_type': 'Workspace',
      });

      final revoked = await client.libraries.deleteSharing(
        libraryId: 'library-1',
        shareWithUuid: 'workspace-2',
        shareWithType: EntityType.workspace,
      );
      expect(revoked?.toJson(), _share);
      expect(requests.last.method, 'DELETE');
      expect(jsonDecode(requests.last.body), {
        'share_with_uuid': 'workspace-2',
        'share_with_type': 'Workspace',
      });
    },
  );

  test('revokes library access when the service returns HTTP 204', () async {
    final client = clientReturning((_) => null);

    final revoked = await client.libraries.deleteSharing(
      libraryId: 'library-1',
      shareWithUuid: 'workspace-2',
      shareWithType: EntityType.workspace,
    );

    expect(revoked, isNull);
    final request = requests.single;
    expect(request.method, 'DELETE');
    expect(request.url.path, '/v1/libraries/library-1/share');
    expect(jsonDecode(request.body), {
      'share_with_uuid': 'workspace-2',
      'share_with_type': 'Workspace',
    });
  });
}
