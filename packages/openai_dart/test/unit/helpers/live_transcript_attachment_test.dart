import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart';

Future<void> _pump() => Future<void>.delayed(Duration.zero);

Map<String, dynamic> _text(String id, String delta, [int start = 0]) => {
  'type': 'session.input_transcript.delta',
  'event_id': id,
  'delta': delta,
  'start_ms': start,
  'end_ms': start + 200,
  'private_future': {
    'raw': ['original-private', null],
  },
};

Map<String, dynamic> _final() => {
  'type': 'session.closed',
  'event_id': 'final',
  'reason': 'close_requested',
  'session': {
    'model': 'synthetic-live',
    'id': 'private-session-id',
    'expires_at': -1,
    'status': 'active',
  },
  'usage': {'seconds': 1.5},
};

void main() {
  test('two groupers and application observe independent raw taps', () async {
    final socket = _Socket();
    final connection = LivePrimaryConnection(
      socket,
      ownsSocket: false,
      sessionAlreadyStarted: true,
    );
    final raw = <LiveServerEvent>[];
    final app = connection.events.listen(raw.add);
    final first = LiveTranscriptGrouper();
    final second = LiveTranscriptGrouper();
    final firstTap = first.attach(connection);
    final secondTap = second.attach(connection);
    final firstUpdates = <LiveTranscriptUpdate>[];
    final secondUpdates = <LiveTranscriptUpdate>[];
    final firstSubscription = first.updates.listen(firstUpdates.add);
    final secondSubscription = second.updates.listen(secondUpdates.add);
    try {
      final original = _text('a', 'hello');
      socket.text(original);
      await _pump();
      first.flush();
      second.flush();
      await _pump();
      expect(first.segments.single.text, 'hello');
      expect(second.segments.single.text, 'hello');
      expect(raw.single.toJson(), original);
      expect(raw.single.toJson()['private_future'], original['private_future']);
      await firstTap.detach();
      await firstTap.detach();
      expect(firstTap.isDetached, isTrue);
      expect(first.completionReason, LiveTranscriptCloseReason.manual);
      expect(secondTap.isDetached, isFalse);
      expect(connection.isClosed, isFalse);
      expect(socket.closeCount, 0);
      expect(socket.sendCount, 0);
      socket.text(_text('b', ' again', 200));
      await _pump();
      second.flush();
      await _pump();
      expect(second.segments.single.text, 'hello again');
      expect(first.segments.single.text, 'hello');
      expect(raw, hasLength(2));
      expect(firstUpdates.where((event) => event.isClosed), hasLength(1));
      expect(secondUpdates.where((event) => event.isClosed), isEmpty);
      expect(() => second.segments.clear(), throwsUnsupportedError);
    } finally {
      await firstTap.detach();
      await secondTap.detach();
      await app.cancel();
      await firstSubscription.cancel();
      await secondSubscription.cancel();
      await connection.close();
      await socket.dispose();
    }
    expect(socket.closeCount, 0);
    expect(socket.cancelCount, 1);
  });

  for (final finalized in [false, true]) {
    test(
      '${finalized ? 'session' : 'transport'} close has distinct finality',
      () async {
        final socket = _Socket();
        final connection = LivePrimaryConnection(
          socket,
          ownsSocket: false,
          sessionAlreadyStarted: true,
        );
        final grouper = LiveTranscriptGrouper();
        final attachment = grouper.attach(connection);
        final updates = <LiveTranscriptUpdate>[];
        final subscription = grouper.updates.listen(updates.add);
        final appRaw = <LiveServerEvent>[];
        final app = connection.events.listen(appRaw.add);
        socket.text(_text('a', 'last'));
        if (finalized) {
          socket.text(_final());
        } else {
          socket.controller.add(CloseReceived(1006, 'private-close'));
        }
        await _pump();
        await _pump();
        expect(grouper.isClosed, isTrue);
        expect(grouper.isSessionFinalized, finalized);
        expect(
          grouper.completionReason,
          finalized
              ? LiveTranscriptCloseReason.sessionClosed
              : LiveTranscriptCloseReason.transportClosed,
        );
        expect(updates.last.reason, grouper.completionReason);
        expect(attachment.isDetached, isTrue);
        expect(socket.closeCount, 0);
        expect(socket.sendCount, 0);
        expect(appRaw, hasLength(finalized ? 2 : 1));
        if (finalized) expect(connection.isClosed, isFalse);
        await attachment.detach();
        await subscription.cancel();
        await app.cancel();
        await connection.close();
        await socket.dispose();
      },
    );
  }

  test(
    'already attached and closed helpers reject new taps synchronously',
    () async {
      final socket = _Socket();
      final connection = LivePrimaryConnection(
        socket,
        ownsSocket: false,
        sessionAlreadyStarted: true,
      );
      final grouper = LiveTranscriptGrouper();
      final attachment = grouper.attach(connection);
      expect(() => grouper.attach(connection), throwsStateError);
      await attachment.detach();
      expect(() => grouper.attach(connection), throwsStateError);
      expect(socket.closeCount, 0);
      await connection.close();
      await socket.dispose();
    },
  );

  test(
    'malformed transcript interval reports value-safe tap failure and recovers',
    () async {
      final socket = _Socket();
      final connection = LivePrimaryConnection(
        socket,
        ownsSocket: false,
        sessionAlreadyStarted: true,
      );
      final grouper = LiveTranscriptGrouper();
      final attachment = grouper.attach(connection);
      final errors = <Object>[];
      final updates = <LiveTranscriptUpdate>[];
      final subscription = grouper.updates.listen(
        updates.add,
        onError: errors.add,
      );
      socket.text({..._text('bad', 'private-secret'), 'start_ms': -1});
      await _pump();
      expect(errors, hasLength(1));
      expect(errors.single, isA<LiveTranscriptAttachmentException>());
      expect(errors.single.toString(), isNot(contains('private-secret')));
      expect(
        (errors.single as LiveTranscriptAttachmentException).cause,
        isA<ArgumentError>(),
      );
      expect(grouper.segments, isEmpty);
      socket.text(_text('good', 'recovered'));
      await _pump();
      grouper.flush();
      expect(grouper.segments.single.text, 'recovered');
      await attachment.detach();
      await _pump();
      expect(updates.last.isClosed, isTrue);
      await subscription.cancel();
      await connection.close();
      await socket.dispose();
    },
  );

  test(
    'connection parser errors remain raw and value-safe helper errors',
    () async {
      final socket = _Socket();
      final connection = LivePrimaryConnection(
        socket,
        ownsSocket: false,
        sessionAlreadyStarted: true,
      );
      final rawErrors = <Object>[];
      final app = connection.events.listen((_) {}, onError: rawErrors.add);
      final grouper = LiveTranscriptGrouper();
      final attachment = grouper.attach(connection);
      final helperErrors = <Object>[];
      final subscription = grouper.updates.listen(
        (_) {},
        onError: helperErrors.add,
      );
      socket.controller.add(TextDataReceived('private-not-json'));
      await _pump();
      expect(rawErrors.single, isA<LiveProtocolException>());
      expect(helperErrors.single, isA<LiveTranscriptAttachmentException>());
      expect(
        (helperErrors.single as LiveTranscriptAttachmentException).cause,
        same(rawErrors.single),
      );
      expect(helperErrors.single.toString(), isNot(contains('private')));
      expect(grouper.isClosed, isFalse);
      await attachment.detach();
      await subscription.cancel();
      await app.cancel();
      await connection.close();
      await socket.dispose();
    },
  );

  test(
    'default local clock/timer and explicit detach settle without media',
    () async {
      final socket = _Socket();
      final connection = LivePrimaryConnection(
        socket,
        ownsSocket: false,
        sessionAlreadyStarted: true,
      );
      final grouper = LiveTranscriptGrouper();
      final attachment = grouper.attach(connection);
      final next = grouper.updates.first;
      socket.text(_text('a', 'timer'));
      final update = await next.timeout(const Duration(seconds: 5));
      expect(update.segment.text, 'timer');
      expect(update.isClosed, isFalse);
      await attachment.detach();
      expect(grouper.segments.single.text, 'timer');
      expect(socket.closeCount, 0);
      await connection.close();
      await socket.dispose();
    },
  );
}

final class _Socket implements WebSocket {
  _Socket() {
    controller = StreamController<WebSocketEvent>(
      onCancel: () => cancelCount++,
    );
  }
  late final StreamController<WebSocketEvent> controller;
  int cancelCount = 0;
  int closeCount = 0;
  int sendCount = 0;
  void text(Map<String, dynamic> json) =>
      controller.add(TextDataReceived(jsonEncode(json)));
  Future<void> dispose() => controller.close();
  @override
  Stream<WebSocketEvent> get events => controller.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String text) => sendCount++;
  @override
  void sendBytes(Uint8List bytes) => sendCount++;
  @override
  Future<void> close([int? code, String? reason]) async {
    closeCount++;
  }
}
