@TestOn('browser')
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('public Files operations send and receive bytes on Web', () async {
    final bytes = Uint8List.fromList([0, 1, 255, 3]);
    final output = Uint8List.fromList([7, 0, 200]);
    const outputId = 'file_output_fixture';
    final requests = <http.Request>[];
    final transport = MockClient((request) async {
      requests.add(request);
      final segments = request.url.pathSegments;
      if (segments.last == 'content') {
        expect(segments[segments.length - 2], outputId);
        return http.Response.bytes(
          output,
          200,
          headers: {'content-type': 'application/octet-stream'},
        );
      }
      if (request.method == 'DELETE') {
        return _json({'type': 'file_deleted', 'id': 'file_fixture'});
      }
      if (request.method == 'GET' && segments.last == 'files') {
        return _json({
          'data': [
            {..._file, 'id': outputId, 'downloadable': true, 'size_bytes': 3},
          ],
          'next_page': null,
        });
      }
      return _json(_file);
    });
    addTearDown(transport.close);
    final client = AnthropicClient(
      config: const AnthropicConfig(
        baseUrl: 'https://fixture.invalid/proxy/?keep=a&keep=b',
        authProvider: ApiKeyProvider('fixture-key'),
        defaultHeaders: {'Anthropic-Beta': 'proxy-beta'},
        workspaceId: 'workspace-default',
      ),
      httpClient: transport,
    );
    addTearDown(client.close);

    await expectLater(
      Future<FileMetadata>.sync(
        () => client.files.upload(filePath: 'unavailable-local-file'),
      ),
      throwsUnsupportedError,
    );
    await expectLater(client.files.retrieve(fileId: '..'), throwsArgumentError);
    expect(requests, isEmpty);

    final uploaded = await client.files.uploadBytes(
      bytes: bytes,
      fileName: 'fixture.bin',
      mimeType: 'application/octet-stream',
      expiresInSeconds: 3600,
      betas: const ['files-beta'],
      workspaceId: 'workspace-override',
    );
    expect(uploaded.id, 'file_fixture');
    expect(uploaded.downloadable, isFalse);
    final page = await client.files.list(scopeId: 'sesn_fixture');
    final generated = page.data.single;
    expect(generated.id, outputId);
    expect(generated.downloadable, isTrue);
    expect((await client.files.retrieve(fileId: uploaded.id)).id, uploaded.id);
    expect(await client.files.download(fileId: generated.id), output);
    expect(
      (await client.files.deleteFile(fileId: uploaded.id)).id,
      uploaded.id,
    );

    expect(requests.map((request) => request.method), [
      'POST',
      'GET',
      'GET',
      'GET',
      'DELETE',
    ]);
    expect(requests.map((request) => request.url.path), [
      '/proxy/v1/files',
      '/proxy/v1/files',
      '/proxy/v1/files/file_fixture',
      '/proxy/v1/files/file_output_fixture/content',
      '/proxy/v1/files/file_fixture',
    ]);
    for (final (index, request) in requests.indexed) {
      expect(request.headers['x-api-key'], 'fixture-key');
      expect(request.headers['anthropic-version'], '2026-10-21');
      expect(request.headers['anthropic-beta'], switch (index) {
        0 => 'files-beta',
        1 => 'proxy-beta,managed-agents-2026-04-01',
        _ => 'proxy-beta',
      });
      expect(
        request.headers['anthropic-workspace-id'],
        index == 0 ? 'workspace-override' : 'workspace-default',
      );
      expect(request.url.queryParametersAll['keep'], ['a', 'b']);
    }
    final upload = requests.first;
    expect(
      upload.headers['content-type'],
      startsWith('multipart/form-data; boundary='),
    );
    final body = latin1.decode(upload.bodyBytes);
    expect(body, contains('filename="fixture.bin"'));
    expect(body, contains('name="expires_in_seconds"'));
    expect(body, contains(latin1.decode(bytes)));
    expect(requests[1].url.queryParameters['scope_id'], 'sesn_fixture');
    expect(requests[3].headers['accept'], 'application/binary');
  });
}

const Map<String, Object> _file = {
  'id': 'file_fixture',
  'type': 'file',
  'created_at': '2026-11-12T00:00:00.000Z',
  'filename': 'fixture.bin',
  'mime_type': 'application/octet-stream',
  'size_bytes': 4,
  'downloadable': false,
};

http.Response _json(Object data) => http.Response(
  jsonEncode(data),
  200,
  headers: {'content-type': 'application/json'},
);
