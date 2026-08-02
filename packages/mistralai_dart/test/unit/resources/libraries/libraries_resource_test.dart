@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('LibrariesResource', () {
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

    test('updatePartial issues PATCH with request body', () async {
      final client = clientReturning({'id': 'lib-1', 'name': 'Renamed'});
      addTearDown(client.close);

      final result = await client.libraries.updatePartial(
        libraryId: 'lib-1',
        request: const UpdateLibraryRequest(
          name: 'Renamed',
          description: 'New description',
        ),
      );

      expect(captured.method, 'PATCH');
      expect(captured.url.path, '/v1/libraries/lib-1');
      expect(jsonDecode(captured.body), {
        'name': 'Renamed',
        'description': 'New description',
      });
      expect(result.id, 'lib-1');
      expect(result.name, 'Renamed');
    });

    test('list plumbs filter_owned_by_me and page query params', () async {
      final client = clientReturning({'data': <dynamic>[]});
      addTearDown(client.close);

      await client.libraries.list(page: 2, filterOwnedByMe: true);

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/libraries');
      expect(captured.url.queryParameters['page'], '2');
      expect(captured.url.queryParameters['filter_owned_by_me'], 'true');
    });

    test('list plumbs page_token query param', () async {
      final client = clientReturning({'data': <dynamic>[]});
      addTearDown(client.close);

      await client.libraries.list(pageToken: 'token-abc');

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/libraries');
      expect(captured.url.queryParameters['page_token'], 'token-abc');
    });

    test('document updatePartial issues PATCH with request body', () async {
      final client = clientReturning({
        'id': 'doc-1',
        'name': 'renamed.pdf',
        'processing_status': 'Completed',
      });
      addTearDown(client.close);

      final result = await client.libraries.documents.updatePartial(
        libraryId: 'lib-1',
        documentId: 'doc-1',
        request: const UpdateDocumentRequest(
          name: 'renamed.pdf',
          attributes: {'team': 'eng'},
        ),
      );

      expect(captured.method, 'PATCH');
      expect(captured.url.path, '/v1/libraries/lib-1/documents/doc-1');
      expect(jsonDecode(captured.body), {
        'name': 'renamed.pdf',
        'attributes': {'team': 'eng'},
      });
      expect(result.id, 'doc-1');
      expect(result.name, 'renamed.pdf');
    });

    test('getContent plumbs page_start and page_end query params', () async {
      final client = clientReturning({'text': 'extracted text'});
      addTearDown(client.close);

      final content = await client.libraries.documents.getContent(
        libraryId: 'lib-1',
        documentId: 'doc-1',
        pageStart: 0,
        pageEnd: 5,
      );

      expect(captured.method, 'GET');
      expect(
        captured.url.path,
        '/v1/libraries/lib-1/documents/doc-1/text_content',
      );
      expect(captured.url.queryParameters['page_start'], '0');
      expect(captured.url.queryParameters['page_end'], '5');
      expect(content.text, 'extracted text');
    });
  });
}
