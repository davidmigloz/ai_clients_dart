@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:openai_dart/src/resources/realtime/websocket_connector_io.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart' as ws;

void main() {
  for (final compression in [false, true]) {
    test(
      'native peer preserves custom options and large frames (compression=$compression)',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final client = HttpClient();
        final requestSeen = Completer<HttpRequest>();
        final peerOpened = Completer<WebSocket>();
        final requests = server.listen((request) async {
          if (request.uri.path == '/health') {
            request.response.write('ready');
            await request.response.close();
            return;
          }
          requestSeen.complete(request);
          final peer = await WebSocketTransformer.upgrade(
            request,
            protocolSelector: (protocols) =>
                protocols.contains('fixture') ? 'fixture' : null,
          );
          peerOpened.complete(peer);
          peer.listen(peer.add, onError: (Object _) {});
        });
        addTearDown(() async {
          client.close(force: true);
          await requests.cancel();
          await server.close(force: true);
        });
        final socket = await connectWebSocket(
          Uri.parse('ws://127.0.0.1:${server.port}/realtime?tenant=local'),
          headers: {'X-Fixture': 'local'},
          protocols: ['fixture'],
          customClient: client,
          compression: compression
              ? CompressionOptions.compressionDefault
              : CompressionOptions.compressionOff,
        );
        final peer = await peerOpened.future;
        addTearDown(() async {
          await peer.close();
        });
        final request = await requestSeen.future;
        expect(request.uri.queryParameters, {'tenant': 'local'});
        expect(request.headers.value('x-fixture'), 'local');
        expect(socket.protocol, 'fixture');
        expect(
          request.headers.value('sec-websocket-extensions'),
          compression ? contains('permessage-deflate') : isNull,
        );
        final frames = <ws.WebSocketEvent>[];
        final tap = socket.events.listen(frames.add);
        final text = List.filled(2 * 1024 * 1024, 'x').join();
        socket
          ..sendText(text)
          ..sendBytes(Uint8List.fromList([0, 1, 128, 255]));
        await _until(() => frames.length == 2);
        expect((frames[0] as ws.TextDataReceived).text, text);
        expect((frames[1] as ws.BinaryDataReceived).data, [0, 1, 128, 255]);
        await socket.close();
        await socket.close();
        await tap.cancel();
        // The connector borrows the caller's custom HttpClient.
        final health = await client.getUrl(
          Uri.parse('http://127.0.0.1:${server.port}/health'),
        );
        final response = await health.close();
        expect(response.statusCode, 200);
        await response.drain<void>();
      },
    );
  }

  test('native default does not negotiate compression', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final seen = Completer<String?>();
    final peers = <WebSocket>[];
    final requests = server.listen((request) async {
      seen.complete(request.headers.value('sec-websocket-extensions'));
      final peer = await WebSocketTransformer.upgrade(request);
      peers.add(peer);
      peer.listen((_) {}, onError: (Object _) {});
    });
    addTearDown(() async {
      for (final peer in peers) {
        await peer.close();
      }
      await requests.cancel();
      await server.close(force: true);
    });
    final socket = await connectWebSocket(
      Uri.parse('ws://127.0.0.1:${server.port}'),
    );
    expect(await seen.future, isNull);
    await socket.close();
  });

  test('close validates UTF8 bytes before changing native state', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    WebSocket? peer;
    final requests = server.listen((request) async {
      peer = await WebSocketTransformer.upgrade(request);
      peer!.listen((_) {}, onError: (Object _) {});
    });
    addTearDown(() async {
      await peer?.close();
      await requests.cancel();
      await server.close(force: true);
    });
    final socket = await connectWebSocket(
      Uri.parse('ws://127.0.0.1:${server.port}'),
    );
    expect(
      () => socket.close(1000, List.filled(42, '界').join()),
      throwsArgumentError,
    );
    expect(() => socket.close(1001), throwsArgumentError);
    await socket.close();
  });
}

Future<void> _until(bool Function() condition) async {
  final deadline = Stopwatch()..start();
  while (!condition()) {
    if (deadline.elapsed > const Duration(seconds: 10)) {
      fail('Local native peer condition did not arrive');
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}
