import 'dart:async';
import 'dart:io' as io;

import 'package:openai_dart/src/errors/exceptions.dart';
import 'package:openai_dart/src/resources/responses/websocket_connector_io.dart'
    as native;
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart';

void main() {
  group('Responses native WebSocket connector', () {
    test(
      'supports custom headers and preserves native text/binary/close facts',
      () async {
        final server = await io.HttpServer.bind(
          io.InternetAddress.loopbackIPv4,
          0,
        );
        final upgraded = Completer<io.WebSocket>();
        final requests = <io.HttpRequest>[];
        final requestSubscription = server.listen((request) async {
          requests.add(request);
          upgraded.complete(await io.WebSocketTransformer.upgrade(request));
        });
        final socket = await native.connectResponsesWebSocket(
          Uri.parse(
            'ws://127.0.0.1:${server.port}/proxy/responses?route=one&route=two',
          ),
          headers: {
            'authorization': 'Bearer synthetic',
            'OpenAI-Project': 'project_synthetic',
          },
        );
        final peer = await upgraded.future;
        final peerSubscription = peer.listen((_) {});
        final frames = <WebSocketEvent>[];
        final subscription = socket.events.listen(frames.add);
        expect(requests.single.uri.path, '/proxy/responses');
        expect(requests.single.uri.queryParametersAll['route'], ['one', 'two']);
        expect(
          requests.single.headers.value('authorization'),
          'Bearer synthetic',
        );
        expect(
          requests.single.headers.value('openai-project'),
          'project_synthetic',
        );
        peer
          ..add('synthetic text')
          ..add([1, 2, 3]);
        await peer.close(4001, 'synthetic peer close');
        await _waitUntil(() => frames.whereType<CloseReceived>().isNotEmpty);
        expect(frames[0], TextDataReceived('synthetic text'));
        expect(frames[1], isA<BinaryDataReceived>());
        expect(frames.whereType<CloseReceived>().single.code, 4001);
        expect(
          frames.whereType<CloseReceived>().single.reason,
          'synthetic peer close',
        );
        expect(
          () => socket.sendText('closed'),
          throwsA(isA<WebSocketConnectionClosed>()),
        );
        await socket.close();
        await subscription.cancel();
        await peerSubscription.cancel();
        await requestSubscription.cancel();
        await server.close(force: true);
      },
    );

    for (final (code, reason) in <(int?, String)>[
      (3000, '${'😀' * 30}abc'),
      (null, 'synthetic reason-only close'),
    ]) {
      test(
        'awaited close retains observed metadata and is idempotent ($code)',
        () async {
          final server = await io.HttpServer.bind(
            io.InternetAddress.loopbackIPv4,
            0,
          );
          final upgraded = Completer<io.WebSocket>();
          final requestSubscription = server.listen((request) async {
            upgraded.complete(await io.WebSocketTransformer.upgrade(request));
          });
          final socket = await native.connectResponsesWebSocket(
            Uri.parse('ws://127.0.0.1:${server.port}/responses'),
          );
          final peer = await upgraded.future;
          final peerSubscription = peer.listen((_) {});
          final frames = <WebSocketEvent>[];
          final streamDone = Completer<void>();
          final subscription = socket.events.listen(
            frames.add,
            onDone: streamDone.complete,
          );
          final first = socket.close(code, reason);
          final second = socket.close(3001, 'second');
          expect(identical(first, second), isTrue);
          await first.timeout(const Duration(seconds: 2));
          await streamDone.future.timeout(const Duration(seconds: 2));
          expect(frames.whereType<CloseReceived>().single.code, code ?? 1000);
          expect(frames.whereType<CloseReceived>().single.reason, reason);
          await socket.close();
          await peer.close();
          await subscription.cancel();
          await peerSubscription.cancel();
          await requestSubscription.cancel();
          await server.close(force: true);
        },
      );
    }

    test(
      'rejects invalid UTF-8 reason without closing an open native socket',
      () async {
        final server = await io.HttpServer.bind(
          io.InternetAddress.loopbackIPv4,
          0,
        );
        final upgraded = Completer<io.WebSocket>();
        final requestSubscription = server.listen((request) async {
          upgraded.complete(await io.WebSocketTransformer.upgrade(request));
        });
        final socket = await native.connectResponsesWebSocket(
          Uri.parse('ws://127.0.0.1:${server.port}/responses'),
        );
        final peer = await upgraded.future;
        final received = peer.first;
        expect(() => socket.close(1000, '😀' * 31), throwsArgumentError);
        expect(() => socket.close(1006), throwsArgumentError);
        socket.sendText('still open');
        expect(await received, 'still open');
        await socket.close(1000);
        await peer.close();
        await requestSubscription.cancel();
        await server.close(force: true);
      },
    );

    test(
      'handshake failure hides URL credentials, query values, and headers',
      () async {
        final server = await io.HttpServer.bind(
          io.InternetAddress.loopbackIPv4,
          0,
        );
        final requestSubscription = server.listen((request) async {
          request.response.statusCode = 401;
          request.response.write('secret response body');
          await request.response.close();
        });
        try {
          await native.connectResponsesWebSocket(
            Uri.parse(
              'ws://user:secret-user@127.0.0.1:${server.port}/responses?token=secret-query#secret-fragment',
            ),
            headers: {'Authorization': 'Bearer secret-header'},
          );
          fail('expected handshake failure');
        } on ConnectionException catch (error) {
          expect(error.message, 'Responses WebSocket handshake failed.');
          expect(error.toString(), isNot(contains('secret')));
          expect(error.url, 'ws://127.0.0.1:${server.port}/responses');
          expect(error.cause, isNull);
        }
        await requestSubscription.cancel();
        await server.close(force: true);
      },
    );

    test('invalid scheme diagnostic omits credential-bearing URL', () async {
      await expectLater(
        native.connectResponsesWebSocket(
          Uri.parse('https://secret.example/responses?token=secret'),
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.toString(),
            'safe diagnostic',
            isNot(contains('secret')),
          ),
        ),
      );
    });
  });
}

Future<void> _waitUntil(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('timed out waiting for local socket');
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}
