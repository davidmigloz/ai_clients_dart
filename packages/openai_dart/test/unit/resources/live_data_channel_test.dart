import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _secret = 'PRIVATE_MEDIA_MESSAGE';
Map<String, dynamic> _response(int n) => {
  'type': 'response.event',
  'event_id': 'evt_$n',
  'delegation_id': 'del_$n',
  'event': {
    'type': 'response.created',
    'response': {'id': 'resp_$n'},
  },
};
Future<void> _tick() => Future<void>.delayed(Duration.zero);

void main() {
  test(
    'broadcast typed seam attaches only its own tap and retains caller ownership',
    () async {
      final channel = _Channel();
      final application = <String>[];
      final appTap = channel.messages.listen(application.add);
      final first = LiveConnection.dataChannel(channel);
      final second = LiveConnection.dataChannel(channel);
      final one = <LiveServerEvent>[];
      final two = <LiveServerEvent>[];
      final oneTap = first.events.listen(one.add);
      final twoTap = second.events.listen(two.add);
      channel.text(_response(1));
      await _tick();
      expect(one.length, 1);
      expect(two, one);
      expect(application.length, 1);
      await first.close();
      channel.text(_response(2));
      await _tick();
      expect(one.length, 1);
      expect(two.length, 2);
      expect(application.length, 2);
      expect(second.isClosed, isFalse);
      expect(channel.mediaClosed, isFalse);
      expect(channel.sent, isEmpty);
      await oneTap.cancel();
      await twoTap.cancel();
      await second.close();
      channel.text(_response(3));
      await _tick();
      expect(application.length, 3);
      expect(channel.mediaClosed, isFalse);
      await appTap.cancel();
      await channel.dispose();
    },
  );
  test(
    'startup/audio are forbidden and manual writer preserves deliberate IDs',
    () async {
      final channel = _Channel();
      final connection = LiveConnection.dataChannel(
        channel,
        initialSession: LiveSessionResourceParam.fromJson(const {
          'id': 'live_media',
          'model': 'inherited',
          'expires_at': -1,
          'status': 'active',
          'delegation': {
            'type': 'responses',
            'responses': {'model': 'backend'},
          },
        }),
      );
      expect(
        () => connection.send(
          LiveSessionStartEvent(session: LiveSessionCreateParams(model: 'new')),
        ),
        throwsStateError,
      );
      expect(
        () => connection.send(
          LiveForkSessionStartEvent(session: LiveForkSessionConfigParam()),
        ),
        throwsA(isA<LiveProtocolException>()),
      );
      expect(
        () => connection.send(LiveInputAudioAppendEvent(audio: 'AA==')),
        throwsA(isA<LiveProtocolException>()),
      );
      expect(channel.sent, isEmpty);
      final command = LiveResponseItemCreateParam(
        item: LiveInputItem.fromJson(const {
          'type': 'function_call_output',
          'call_id': 'call_owned',
          'output': _secret,
        }),
        eventId: 'event_owned',
      );
      connection
        ..send(command)
        ..send(LiveResponseCreateParam());
      expect(channel.sent, [
        command.toJson(),
        {'type': 'response.create'},
      ]);
      await connection.close();
      expect(channel.mediaClosed, isFalse);
      await channel.dispose();
    },
  );
  test(
    'local facade close never creates peer code/reason or closes media',
    () async {
      final channel = _Channel();
      final facade = LiveDataChannelSocket(channel);
      final frames = <Object>[];
      final tap = facade.events.listen(frames.add);
      await facade.close(1000, _secret);
      channel.text(_response(1));
      await _tick();
      expect(frames.length, 1);
      expect(channel.mediaClosed, isFalse);
      expect(facade.protocol, '');
      expect(facade.toString(), isNot(contains(_secret)));
      expect(() => facade.sendBytes(Uint8List(1)), throwsUnsupportedError);
      await tap.cancel();
      await channel.dispose();
    },
  );
  test(
    'borrowed channel completion is an unconfirmed close with no invented close metadata',
    () async {
      final channel = _Channel();
      final connection = LiveConnection.dataChannel(channel);
      final closing = connection.closeSession();
      final verification = expectLater(
        closing,
        throwsA(isA<LiveUnconfirmedCloseException>()),
      );
      await channel.dispose();
      await verification;
      expect(connection.isFinalized, isFalse);
      expect(connection.closeCode, isNull);
      expect(connection.closeReason, isNull);
    },
  );
  test(
    'server finalization confirms backend session without claiming audible media completion',
    () async {
      final channel = _Channel();
      final connection = LiveConnection.dataChannel(channel);
      final closing = connection.closeSession();
      await _tick();
      channel.text({
        'type': 'session.closed',
        'event_id': 'final',
        'reason': 'close_requested',
        'session': {
          'id': 'live_media',
          'model': 'media',
          'expires_at': -1,
          'status': 'active',
        },
        'usage': {'seconds': 2},
      });
      final finalEvent = await closing;
      expect(finalEvent.usage.seconds, 2);
      expect(connection.isFinalized, isTrue);
      expect(channel.mediaClosed, isFalse);
      expect(connection.closeCode, isNull);
      expect(connection.closeReason, isNull);
      await channel.dispose();
    },
  );
  test(
    'abort detaches one listener while other caller taps/media remain active',
    () async {
      final channel = _Channel();
      final abort = Completer<void>();
      final caller = <String>[];
      final app = channel.messages.listen(caller.add);
      final connection = LiveConnection.dataChannel(
        channel,
        abortTrigger: abort.future,
      );
      final errors = <Object>[];
      final tap = connection.events.listen((_) {}, onError: errors.add);
      abort.complete();
      await connection.done;
      await _tick();
      expect(errors.single, isA<AbortedException>());
      expect(channel.mediaClosed, isFalse);
      channel.text(_response(1));
      await _tick();
      expect(caller.length, 1);
      await tap.cancel();
      await app.cancel();
      await channel.dispose();
    },
  );
  test(
    'channel error is a value-safe transport error and does not close caller media',
    () async {
      final channel = _Channel();
      final connection = LiveConnection.dataChannel(channel);
      final errors = <Object>[];
      final tap = connection.events.listen((_) {}, onError: errors.add);
      channel.controller.addError(StateError(_secret));
      await connection.done;
      await _tick();
      expect(errors.single, isA<LiveTransportException>());
      expect(errors.single.toString(), isNot(contains(_secret)));
      expect(channel.mediaClosed, isFalse);
      await tap.cancel();
      await channel.dispose();
    },
  );
  test(
    'single-subscription channel rejected before any reader consumes it',
    () async {
      final controller = StreamController<String>();
      final channel = _SingleChannel(controller.stream);
      expect(() => LiveConnection.dataChannel(channel), throwsArgumentError);
      expect(controller.hasListener, isFalse);
      final callerTap = controller.stream.listen((_) {});
      await controller.close();
      await callerTap.cancel();
    },
  );
  test(
    'invalid capacity and invalid initial snapshot do not steal another channel tap',
    () async {
      final channel = _Channel();
      expect(
        () => LiveConnection.dataChannel(channel, maxBufferedEvents: 0),
        throwsArgumentError,
      );
      expect(channel.controller.hasListener, isFalse);
      await channel.dispose();
    },
  );
  test(
    'compact dispatch attaches alongside application without changing consumed raw data',
    () async {
      final channel = _Channel();
      final connection = LiveConnection.dataChannel(channel);
      final raw = <LiveServerEvent>[];
      final compact = <LiveResponsesEvent>[];
      final appTap = connection.events.listen(raw.add);
      final viewTap = connection.events
          .where((e) => e is LiveResponseEvent)
          .cast<LiveResponseEvent>()
          .map(LiveResponsesEvent.fromLiveEvent)
          .listen(compact.add);
      channel
        ..text(_response(1))
        ..text(_response(2));
      await _tick();
      expect(raw.map((e) => e.eventId), ['evt_1', 'evt_2']);
      expect(compact.map((e) => e.delegationId), ['del_1', 'del_2']);
      expect(
        (compact.last as LiveResponsesLifecycleEvent).response.id,
        'resp_2',
      );
      await viewTap.cancel();
      channel.text(_response(3));
      await _tick();
      expect(raw.length, 3);
      await appTap.cancel();
      await connection.close();
      await channel.dispose();
    },
  );
}

class _Channel implements LiveDataChannel {
  final StreamController<String> controller =
      StreamController<String>.broadcast(sync: true);
  final List<Map<String, dynamic>> sent = [];
  bool mediaClosed = false;
  @override
  Stream<String> get messages => controller.stream;
  @override
  void sendText(String message) =>
      sent.add(jsonDecode(message) as Map<String, dynamic>);
  void text(Map<String, dynamic> event) => controller.add(jsonEncode(event));
  Future<void> dispose() => controller.close();
}

class _SingleChannel implements LiveDataChannel {
  _SingleChannel(this.messages);
  @override
  final Stream<String> messages;
  @override
  void sendText(String message) {}
}
