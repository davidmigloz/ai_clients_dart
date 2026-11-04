@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final sendHeaders in [false, true]) {
    test(
      'native NDJSON abort closes the request socket (headers=$sendHeaders)',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final connected = Completer<void>();
        final disconnected = Completer<void>();
        Socket? socket;
        final serverSubscription = server.listen((request) async {
          await request.drain<void>();
          socket = await request.response.detachSocket(writeHeaders: false);
          socket!.listen((_) {}, onDone: disconnected.complete);
          if (sendHeaders) {
            const frame = '{}\n';
            socket!.write(
              'HTTP/1.1 200 OK\r\nContent-Type: application/x-ndjson\r\nTransfer-Encoding: chunked\r\n\r\n',
            );
            socket!.write(
              '${utf8.encode(frame).length.toRadixString(16)}\r\n$frame\r\n',
            );
            await socket!.flush();
          }
          connected.complete();
        });
        final client = OllamaClient(
          config: OllamaConfig(baseUrl: 'http://127.0.0.1:${server.port}'),
        );
        addTearDown(() async {
          client.close();
          socket?.destroy();
          await serverSubscription.cancel();
          await server.close(force: true);
        });
        final abort = Completer<void>();
        final firstEvent = Completer<void>();
        final result = client.chat
            .createStream(
              request: const ChatRequest(
                model: 'test',
                messages: [ChatMessage.user('Hi')],
              ),
              abortTrigger: abort.future,
            )
            .map((event) {
              if (!firstEvent.isCompleted) firstEvent.complete();
              return event;
            })
            .toList();
        final aborted = expectLater(result, throwsA(isA<AbortedException>()));
        await connected.future.timeout(const Duration(seconds: 2));
        if (sendHeaders) {
          await firstEvent.future.timeout(const Duration(seconds: 2));
        }
        abort.complete();
        await aborted.timeout(const Duration(seconds: 2));
        // Observe the peer disconnect before closing the shared client in teardown.
        await disconnected.future.timeout(const Duration(seconds: 2));
      },
    );
  }
  test('normal completion preserves HTTP connection reuse', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final peerPorts = <int>[];
    final serverSubscription = server.listen((request) async {
      peerPorts.add(request.connectionInfo!.remotePort);
      await request.drain<void>();
      request.response.headers.contentType = ContentType(
        'application',
        'x-ndjson',
      );
      request.response.write('{"done":true}\n');
      await request.response.close();
    });
    final client = OllamaClient(
      config: OllamaConfig(baseUrl: 'http://127.0.0.1:${server.port}'),
    );
    addTearDown(() async {
      client.close();
      await serverSubscription.cancel();
      await server.close(force: true);
    });
    for (var i = 0; i < 2; i++) {
      final result = await client.chat
          .createStream(
            request: const ChatRequest(
              model: 'test',
              messages: [ChatMessage.user('Hi')],
            ),
          )
          .toList()
          .timeout(const Duration(seconds: 2));
      expect(result.single.done, isTrue);
    }
    expect(peerPorts, hasLength(2));
    expect(peerPorts[1], peerPorts[0]);
  });
}
