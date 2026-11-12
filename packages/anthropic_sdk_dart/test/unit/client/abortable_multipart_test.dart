import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:anthropic_sdk_dart/src/client/interceptor_chain.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  test('configured timeout retains a native multipart boundary', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final wire = Completer<(String?, int, String)>();
    server.listen((request) async {
      final contentType = request.headers.value(HttpHeaders.contentTypeHeader);
      final body = await utf8.decoder.bind(request).join();
      wire.complete((contentType, request.contentLength, body));
      await request.response.close();
    });
    final client = AnthropicClient(
      config: const AnthropicConfig(timeout: Duration(seconds: 5)),
    );
    addTearDown(client.close);
    final url = Uri.http('127.0.0.1:${server.port}', '/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['fixture'] = 'yes'
      ..files.add(http.MultipartFile.fromString('file', 'multipart payload'));
    final response = await client.interceptorChain.execute(request);
    final (contentType, contentLength, body) = await wire.future;
    expect(response.statusCode, 200);
    expect(contentType, startsWith('multipart/form-data; boundary='));
    final boundary = http.MediaType.parse(contentType!).parameters['boundary'];
    expect(body, startsWith('--$boundary\r\n'));
    expect(body, contains('multipart payload'));
    expect(body, endsWith('--$boundary--\r\n'));
    expect(contentLength, body.length);
  });

  test(
    'abortable multipart keeps its finalized content type and length',
    () async {
      final transport = _FinalizeTransport();
      final chain = InterceptorChain(
        interceptors: const [],
        httpClient: transport,
      );
      final abort = Completer<void>();
      final request =
          http.MultipartRequest('POST', Uri.https('fixture.test', '/upload'))
            ..headers['x-api-key'] = 'fixture'
            ..files.add(
              http.MultipartFile.fromBytes('files[]', [
                0,
                128,
                255,
              ], filename: 'fixture.bin'),
            );

      await chain.execute(request, abortTrigger: abort.future);

      expect(transport.request, isA<http.Abortable>());
      expect(transport.request.headers['x-api-key'], 'fixture');
      final mime = http.MediaType.parse(
        transport.request.headers['content-type'] ?? 'text/plain',
      );
      expect(mime.mimeType, 'multipart/form-data');
      final boundary = mime.parameters['boundary'];
      expect(boundary, isNotEmpty);
      final body = latin1.decode(transport.bytes);
      expect(body, startsWith('--$boundary\r\n'));
      expect(body, contains('name="files[]"; filename="fixture.bin"'));
      expect(body, contains(latin1.decode([0, 128, 255])));
      expect(body, endsWith('--$boundary--\r\n'));
      expect(transport.request.contentLength, transport.bytes.length);
    },
  );

  test(
    'abortable custom request keeps a length assigned during finalization',
    () async {
      final transport = _FinalizeTransport();
      final chain = InterceptorChain(
        interceptors: const [],
        httpClient: transport,
      );
      final abort = Completer<void>();
      final request = _LateLengthRequest();

      await chain.execute(request, abortTrigger: abort.future);

      expect(transport.request.contentLength, 3);
      expect(transport.bytes, [0, 128, 255]);
    },
  );
}

final class _FinalizeTransport extends http.BaseClient {
  late http.BaseRequest request;
  late List<int> bytes;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    this.request = request;
    bytes = await request.finalize().toBytes();
    return http.StreamedResponse(Stream.value(const []), 200);
  }
}

final class _LateLengthRequest extends http.BaseRequest {
  _LateLengthRequest() : super('POST', Uri.https('fixture.test', '/upload'));

  @override
  http.ByteStream finalize() {
    contentLength = 3;
    super.finalize();
    return http.ByteStream.fromBytes(const [0, 128, 255]);
  }
}
