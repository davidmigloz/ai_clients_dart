@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

class _ObservedClient extends http.BaseClient {
  final _inner = http.Client();
  final failure = Completer<Object>();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      return await _inner.send(request);
    } catch (error) {
      failure.complete(error);
      rethrow;
    }
  }

  @override
  void close() => _inner.close();
}

void main() {
  test('native request aborts before headers without closing the client', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final received = Completer<HttpRequest>();
    final serverSubscription = server.listen(received.complete);
    final transport = _ObservedClient();
    final client = OpenResponsesClient(
      config: OpenResponsesConfig(baseUrl: 'http://127.0.0.1:${server.port}'),
      httpClient: transport,
    );
    addTearDown(() async {
      client.close();
      transport.close();
      await serverSubscription.cancel();
      await server.close(force: true);
    });
    final abort = Completer<void>();
    final result = client.responses
        .createStream(
          const CreateResponseRequest(
            model: 'test',
            input: ResponseTextInput('Hi'),
          ),
          abortTrigger: abort.future,
        )
        .toList();
    await received.future.timeout(const Duration(seconds: 2));
    abort.complete();
    await expectLater(result, throwsA(isA<AbortedException>()));
    // This checks the real HTTP send, independently of the local stream error.
    // Replacing AbortableRequest with Request must make this assertion fail.
    expect(
      await transport.failure.future.timeout(const Duration(seconds: 2)),
      isA<http.RequestAbortedException>(),
    );
  });
}
