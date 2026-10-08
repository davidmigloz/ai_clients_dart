@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _secret = 'PRIVATE_NATIVE_LIVE';
Map<String, dynamic> _snapshot() => {
  'model': 'synthetic-live',
  'id': _secret,
  'expires_at': 0,
  'status': 'active',
};
Map<String, dynamic> _closed() => {
  'type': 'session.closed',
  'event_id': 'final',
  'reason': 'close_requested',
  'session': _snapshot(),
  'usage': {'seconds': 1.75},
};
OpenAIClient _client(HttpServer server, {AuthProvider? auth}) => OpenAIClient(
  config: OpenAIConfig(
    baseUrl: 'http://127.0.0.1:${server.port}/custom/v1/?k=a&k=b',
    authProvider: auth ?? const ApiKeyProvider(_secret),
    organization: 'org-private',
    project: 'project-private',
  ),
  httpClient: MockClient((_) async => throw StateError('No HTTP')),
);

void main() {
  test(
    'native primary headers/custom prefix/start/finalization exact once',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final wires = <Map<String, dynamic>>[];
      final upgraded = Completer<WebSocket>();
      final subscription = server.listen((request) async {
        expect(request.uri.path, '/custom/v1/live/sessions');
        expect(request.uri.queryParametersAll['k'], ['a', 'b']);
        expect(request.uri.queryParameters.containsKey('model'), isFalse);
        expect(request.headers.value('authorization'), 'Bearer $_secret');
        expect(request.headers.value('openai-organization'), 'org-private');
        expect(request.headers.value('openai-project'), 'project-private');
        expect(request.headers.value('x-client-request-id'), _secret);
        final socket = await WebSocketTransformer.upgrade(request);
        upgraded.complete(socket);
        socket.listen((dynamic frame) {
          final wire = jsonDecode(frame as String) as Map<String, dynamic>;
          wires.add(wire);
          if (wire['type'] == 'session.start') {
            socket.add(
              jsonEncode({
                'type': 'session.started',
                'event_id': 'started',
                'session': _snapshot(),
              }),
            );
          }
          if (wire['type'] == 'session.close') {
            socket.add(jsonEncode(_closed()));
          }
        });
      });
      final client = _client(server);
      try {
        final connection = await client.live.connect(
          additionalHeaders: {'X-Client-Request-ID': _secret},
        );
        expect(wires, isEmpty);
        final session = await connection.start(
          LiveSessionStartEvent(
            session: LiveSessionCreateParams(model: 'synthetic-live'),
            eventId: 'client-start',
          ),
        );
        expect(session.session.id, _secret);
        connection.send(LiveInputAudioMuteParam(eventId: 'mute'));
        final finalEvent = await connection.closeSession(
          event: LiveSessionCloseParam(eventId: 'close'),
        );
        expect(finalEvent.usage.seconds, 1.75);
        expect(connection.isFinalized, isTrue);
        await connection.done;
        expect(wires.map((w) => w['type']), [
          'session.start',
          'session.input_audio.mute',
          'session.close',
        ]);
        expect(wires.first['session'], {'model': 'synthetic-live'});
        expect(connection.closeCode, 1000);
      } finally {
        client.close();
        if (upgraded.isCompleted) {
          await (await upgraded.future).close();
        }
        await subscription.cancel();
        await server.close(force: true);
      }
    },
  );
  test(
    'native sideband encoded ID/graceful query/reflected audio without startup',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final upgraded = Completer<WebSocket>();
      final wires = <Map<String, dynamic>>[];
      final subscription = server.listen((request) async {
        expect(request.uri.pathSegments, [
          'custom',
          'v1',
          'live',
          'sessions',
          'id/百分%2F?',
          'attach',
        ]);
        expect(request.uri.queryParameters['graceful_close'], 'true');
        expect(request.headers.value('authorization'), 'Bearer $_secret');
        final socket = await WebSocketTransformer.upgrade(request);
        upgraded.complete(socket);
        socket
          ..add(
            jsonEncode({'type': 'session.input_audio.append', 'audio': 'AQID'}),
          )
          ..add(
            jsonEncode({
              'type': 'session.output_audio.delta',
              'delta': 'BAUG',
              'start_ms': 10,
              'end_ms': 20,
            }),
          )
          ..listen((dynamic frame) {
            final wire = jsonDecode(frame as String) as Map<String, dynamic>;
            wires.add(wire);
            if (wire['type'] == 'session.close') {
              socket.add(jsonEncode(_closed()));
            }
          });
      });
      final client = _client(server);
      try {
        final connection = await client.live.attach(
          'id/百分%2F?',
          gracefulClose: true,
        );
        final received = <LiveServerEvent>[];
        final tap = connection.events.listen(received.add);
        await Future<void>.delayed(const Duration(milliseconds: 5));
        final closed = await connection.closeSession();
        await connection.done;
        await Future<void>.delayed(Duration.zero);
        expect(received.take(2).map((e) => e.type), [
          'session.input_audio.append',
          'session.output_audio.delta',
        ]);
        expect(received.first.toJson()['audio'], 'AQID');
        expect(received[1].toJson()['delta'], 'BAUG');
        expect(received[1].toJson()['start_ms'], 10);
        expect(closed.session.status, 'active');
        expect(wires.single, {'type': 'session.close'});
        await tap.cancel();
      } finally {
        client.close();
        if (upgraded.isCompleted) {
          await (await upgraded.future).close();
        }
        await subscription.cancel();
        await server.close(force: true);
      }
    },
  );
  test(
    'native rejected handshake retains private raw cause without retries',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var attempts = 0;
      final subscription = server.listen((request) async {
        attempts++;
        request.response.statusCode = 403;
        request.response.write(_secret);
        await request.response.close();
      });
      final client = _client(server);
      try {
        await expectLater(
          client.live.attach(_secret),
          throwsA(
            isA<ConnectionException>()
                .having((e) => e.toString(), 'safe', isNot(contains(_secret)))
                .having((e) => e.url, 'caller URL', contains(_secret))
                .having(
                  (e) => e.cause,
                  'native context',
                  isA<ConnectionException>().having(
                    (e) => e.cause,
                    'raw cause',
                    isA<WebSocketException>(),
                  ),
                ),
          ),
        );
        expect(attempts, 1);
      } finally {
        client.close();
        await subscription.cancel();
        await server.close(force: true);
      }
    },
  );
  test('native cancelled handshake closes a late upgraded peer once', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final requestSeen = Completer<HttpRequest>();
    final subscription = server.listen(requestSeen.complete);
    final client = _client(server, auth: _TraceAuth());
    final abort = Completer<void>();
    WebSocket? peer;
    try {
      final opening = client.live.attach(
        'private/id',
        abortTrigger: abort.future,
      );
      final request = await requestSeen.future;
      abort.complete();
      await expectLater(
        opening,
        throwsA(
          isA<AbortedException>()
              .having((e) => e.correlationId, 'native trace', _secret)
              .having((e) => e.toString(), 'safe', isNot(contains(_secret))),
        ),
      );
      peer = await WebSocketTransformer.upgrade(request);
      final ended = Completer<void>();
      peer.listen((_) {}, onDone: ended.complete);
      await ended.future.timeout(const Duration(seconds: 2));
      expect(peer.closeCode, 1000);
    } finally {
      client.close();
      await peer?.close();
      await subscription.cancel();
      await server.close(force: true);
    }
  });
  test(
    'native peer close without final event is unconfirmed and raw reason retained',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final subscription = server.listen((request) async {
        final peer = await WebSocketTransformer.upgrade(request);
        await peer.close(4001, _secret);
      });
      final client = _client(server);
      try {
        final connection = await client.live.attach('id');
        await connection.done;
        expect(connection.isFinalized, isFalse);
        expect(connection.closeCode, 4001);
        expect(connection.closeReason, _secret);
        await expectLater(
          connection.closeSession(),
          throwsA(isA<LiveUnconfirmedCloseException>()),
        );
        expect(connection.toString(), isNot(contains(_secret)));
      } finally {
        client.close();
        await subscription.cancel();
        await server.close(force: true);
      }
    },
  );
}

class _TraceAuth implements AuthProvider {
  @override
  Map<String, String> getHeaders() => {
    'Authorization': 'Bearer $_secret',
    'X-Request-ID': _secret,
  };
}
