@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _snapshot(String id) => {
  'model': 'synthetic-live',
  'id': id,
  'expires_at': 0,
  'status': 'active',
};

void main() {
  test(
    'real native peer disables compression, recovers, and admits a large fresh frame',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final peers = <WebSocket>[];
      final wires = <List<Map<String, dynamic>>>[];
      final large = Completer<int>();
      final subscription = server.listen((request) async {
        expect(request.headers.value('sec-websocket-extensions'), isNull);
        expect(request.uri.queryParametersAll['k'], ['a', 'b']);
        expect(request.uri.queryParameters['tenant'], 'retained');
        final peer = await WebSocketTransformer.upgrade(request);
        final index = peers.length;
        peers.add(peer);
        wires.add([]);
        peer.listen((dynamic frame) {
          final data = jsonDecode(frame as String) as Map<String, dynamic>;
          wires[index].add(data);
          if (data['type'] == 'session.start') {
            peer.add(
              jsonEncode({
                'type': 'session.started',
                'event_id': 'started-$index',
                'session': _snapshot('session-$index'),
              }),
            );
          }
          if (index == 1 && data['type'] == 'session.input_audio.append') {
            large.complete((data['audio'] as String).length);
          }
        });
      });
      final client = OpenAIClient(
        config: OpenAIConfig(
          baseUrl: 'http://127.0.0.1:${server.port}/v1?k=a&k=b',
          authProvider: const ApiKeyProvider('synthetic-local-key'),
        ),
        httpClient: MockClient(
          (_) async => throw StateError('Unexpected HTTP'),
        ),
      );
      LivePrimaryConnection? connection;
      try {
        connection = await client.live.connect(
          queryParameters: const {'tenant': 'retained'},
          reconnect: LiveReconnectOptions(
            initialDelay: Duration.zero,
            maxDelay: Duration.zero,
            onReconnecting: (_) =>
                const WebSocketReconnectDecision.continueWith(),
          ),
        );
        LiveSessionStartEvent start() => LiveSessionStartEvent(
          session: LiveSessionCreateParams(model: 'synthetic-live'),
        );
        await connection.start(start());
        final reconnected = connection.recovery!.events.firstWhere(
          (event) => event is WebSocketRecoveryReconnected,
        );
        await peers.single.close(1001, 'local restart');
        await reconnected.timeout(const Duration(seconds: 3));
        expect(wires[1], isEmpty);
        await connection.start(start());
        final content = 'x' * (2 * 1024 * 1024);
        connection.send(LiveInputAudioAppendEvent(audio: content));
        expect(
          await large.future.timeout(const Duration(seconds: 3)),
          content.length,
        );
        expect(wires[0].map((e) => e['type']), ['session.start']);
        expect(wires[1].map((e) => e['type']), [
          'session.start',
          'session.input_audio.append',
        ]);
      } finally {
        await connection?.close();
        client.close();
        for (final peer in peers) {
          await peer.close();
        }
        await subscription.cancel();
        await server.close(force: true);
      }
    },
  );
}
