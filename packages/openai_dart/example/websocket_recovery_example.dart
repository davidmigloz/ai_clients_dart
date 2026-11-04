/// Runs entirely against a local peer: no API key, network service or charges.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final peers = <WebSocket>[];
  final received = <String>[];
  var upgrades = 0;
  final serverReader = server.listen((request) async {
    final socket = await WebSocketTransformer.upgrade(request);
    peers.add(socket);
    final generation = ++upgrades;
    socket.listen((dynamic data) {
      final event = jsonDecode(data as String) as Map<String, dynamic>;
      if (generation == 1) {
        unawaited(socket.close(1001, 'local fixture restart'));
      } else {
        received.add(event['type'] as String);
      }
    });
  });

  final client = OpenAIClient(
    config: OpenAIConfig(baseUrl: 'http://127.0.0.1:${server.port}/v1'),
  );
  final interrupted = Completer<void>();
  final reconcile = Completer<WebSocketReconnectDecision>();
  final connection = await client.realtime.connect(
    model: 'gpt-realtime-2',
    reconnect: RealtimeReconnectOptions(
      maxQueueBytes: 4096, // Default zero rejects sends during recovery.
      initialDelay: Duration.zero,
      maxDelay: Duration.zero,
      onReconnecting: (context) {
        interrupted.complete();
        return reconcile.future;
      },
    ),
  );
  final recovery = connection.recovery!;
  final reopened = recovery.events.firstWhere(
    (event) => event is WebSocketRecoveryReconnected,
  );
  try {
    connection.send({'type': 'local_fixture.disconnect'});
    await interrupted.future;

    // Only this new, never-attempted message enters the pending queue.
    connection.sendUserMessage('Continue after I restore the session.');
    reconcile.complete(const WebSocketReconnectDecision.continueWith());
    await reopened;

    // A new physical socket has a fresh session. Configuration/history/audio
    // are never restored automatically. Restore only the state your app needs.
    connection
      ..updateSession(
        const realtime.RealtimeSessionCreateRequest(
          model: 'gpt-realtime-2',
          instructions: 'Keep answers brief.',
        ),
      )
      ..flushPending();

    // Wait only for this local fixture to observe the three ordered frames.
    final deadline = DateTime.now().add(const Duration(seconds: 2));
    while (received.length < 3 && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    if (received.join(',') !=
        'session.update,conversation.item.create,response.create') {
      throw StateError('Unexpected local fixture delivery order.');
    }
    stdout.writeln(
      'Restored configuration before explicitly flushing pending work.',
    );
  } finally {
    await connection.close();
    final report = await recovery.done;
    stdout.writeln(
      'Never-attempted frames remaining: ${report.unsentMessages.length}',
    );
    client.close();
    for (final peer in peers) {
      await peer.close();
    }
    await serverReader.cancel();
    await server.close(force: true);
  }
}
