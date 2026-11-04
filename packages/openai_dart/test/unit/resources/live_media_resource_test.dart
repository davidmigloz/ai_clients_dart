import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart';

Future<void> _tick() => Future<void>.delayed(Duration.zero);
Map<String, dynamic> _session() => {
  'id': 'live_fixture',
  'model': 'gpt-live-1',
  'expires_at': -1,
  'status': 'active',
  'audio': {
    'format': {'type': 'audio/pcma', 'rate': 8000},
  },
};

void main() {
  for (final channel in ['primary', 'sideband', 'fork']) {
    test(
      '$channel fixture uses fixed PCM24k independently of session format',
      () async {
        final h = await _Harness.open(channel);
        addTearDown(h.dispose);
        final command = LiveOutputAudioFixturePlayParam.fromBytes(
          Uint8List.fromList([0, 0, 255, 127]),
          eventId: 'fixture_1',
        );
        h.send(command);
        expect(h.socket.writes.last, {
          'type': 'session.output_audio.fixture.play',
          'audio': 'AAD/fw==',
          'event_id': 'fixture_1',
        });
        expect(h.received.whereType<LiveOutputAudioFixturePlaying>(), isEmpty);
        h.socket.emit({
          'type': 'session.output_audio.fixture.playing',
          'event_id': 'accepted',
          'client_event_id': 'fixture_1',
        });
        await _tick();
        expect(
          h.received
              .whereType<LiveOutputAudioFixturePlaying>()
              .single
              .clientEventId,
          'fixture_1',
        );
        expect(h.received.whereType<LiveOutputAudioFixturePlayed>(), isEmpty);
        h.socket.emit({
          'type': 'session.output_audio.fixture.played',
          'event_id': 'mixer_drained',
          'client_event_id': 'fixture_1',
        });
        await _tick();
        expect(
          h.received
              .whereType<LiveOutputAudioFixturePlayed>()
              .single
              .clientEventId,
          'fixture_1',
        );
        expect(h.errors, isEmpty);
        final finalEvent = await h.connection.closeSession();
        expect(finalEvent.reason, 'close_requested');
        expect(h.socket.closeCalls, 1);
        expect(() => h.send(command), throwsStateError);
      },
    );
  }

  test(
    'fixture does not synthesize mute events; explicit mute survives drain',
    () async {
      final h = await _Harness.open('sideband');
      addTearDown(h.dispose);
      h.send(LiveInputAudioMuteParam(eventId: 'mute'));
      h.socket.emit({
        'type': 'session.input_audio.muted',
        'event_id': 'muted',
        'client_event_id': 'mute',
      });
      h.send(
        LiveOutputAudioFixturePlayParam(audio: 'AAA=', eventId: 'fixture'),
      );
      h.socket.emit({
        'type': 'session.output_audio.fixture.playing',
        'event_id': 'playing',
        'client_event_id': 'fixture',
      });
      // Sideband still reflects raw PCM24k input while independent mute/fixture
      // pauses model input. This is a media reflection, never an append ack.
      h.socket.emit({'type': 'session.input_audio.append', 'audio': 'AAA='});
      h.socket.emit({
        'type': 'session.output_audio.fixture.played',
        'event_id': 'played',
        'client_event_id': 'fixture',
      });
      await _tick();
      expect(h.received.map((event) => event.type), [
        'session.input_audio.muted',
        'session.output_audio.fixture.playing',
        'session.input_audio.append',
        'session.output_audio.fixture.played',
      ]);
      expect(h.received.whereType<LiveInputAudioUnmuted>(), isEmpty);
      h.send(LiveInputAudioUnmuteParam(eventId: 'unmute'));
      h.socket.emit({
        'type': 'session.input_audio.unmuted',
        'event_id': 'unmuted',
        'client_event_id': 'unmute',
      });
      await _tick();
      expect(
        h.received.whereType<LiveInputAudioUnmuted>().single.clientEventId,
        'unmute',
      );
      expect(h.errors, isEmpty);
    },
  );

  test(
    'server rejects appends/overlap with correlation without local playback guesses',
    () async {
      final h = await _Harness.open('primary');
      addTearDown(h.dispose);
      h.send(LiveOutputAudioFixturePlayParam(audio: 'AAA=', eventId: 'first'));
      h.socket.emit({
        'type': 'session.output_audio.fixture.playing',
        'event_id': 'playing',
        'client_event_id': 'first',
      });
      for (final command in <LiveSidebandClientEvent>[
        LiveInstructionsAppendParam(
          content: 'delivered content',
          delegationId: null,
          eventId: 'instructions',
        ),
        LiveThinkingAppendParam(
          content: 'context',
          delegationId: null,
          eventId: 'thinking',
        ),
        LiveCommentaryAppendParam(
          content: 'context',
          delegationId: null,
          eventId: 'commentary',
        ),
        LiveOutputAudioFixturePlayParam(audio: 'AAA=', eventId: 'overlap'),
      ]) {
        h.send(command);
        h.socket.error(command.eventId!, 'fixture_active');
      }
      // Unmute acknowledgment does not invent a played event or resume inference.
      h.send(LiveInputAudioUnmuteParam(eventId: 'unmute'));
      h.socket.emit({
        'type': 'session.input_audio.unmuted',
        'event_id': 'unmuted',
        'client_event_id': 'unmute',
      });
      await _tick();
      expect(
        h.received.whereType<LiveErrorEvent>().map(
          (event) => event.error.clientEventId,
        ),
        ['instructions', 'thinking', 'commentary', 'overlap'],
      );
      expect(h.received.whereType<LiveOutputAudioFixturePlayed>(), isEmpty);
      expect(h.connection.isClosed, isFalse);
      expect(h.errors, isEmpty);
    },
  );

  test(
    'failed fixture and premature peer close never fabricate played',
    () async {
      final h = await _Harness.open('sideband');
      addTearDown(h.dispose);
      h.send(LiveOutputAudioFixturePlayParam(audio: 'AAA=', eventId: 'failed'));
      h.socket.error('failed', 'fixture_failed');
      h.send(
        LiveOutputAudioFixturePlayParam(audio: 'AAA=', eventId: 'canceled'),
      );
      h.socket.emit({
        'type': 'session.output_audio.fixture.playing',
        'event_id': 'playing',
        'client_event_id': 'canceled',
      });
      await _tick();
      h.socket.autoFinalize = false;
      final closing = h.connection.closeSession();
      final assertion = expectLater(
        closing,
        throwsA(isA<LiveUnconfirmedCloseException>()),
      );
      h.socket.peerClose();
      await assertion;
      expect(h.received.whereType<LiveOutputAudioFixturePlayed>(), isEmpty);
      expect(h.socket.closeCalls, lessThanOrEqualTo(1));
    },
  );

  for (final channel in ['primary', 'fork']) {
    test('$channel rejects sideband DTMF command and notifications', () async {
      final h = await _Harness.open(channel);
      addTearDown(h.dispose);
      final before = h.socket.writes.length;
      expect(
        () => h.send(LiveTransportDTMFSendParam(event: '#')),
        throwsA(isA<LiveProtocolException>()),
      );
      expect(h.socket.writes.length, before);
      for (final type in ['transport.dtmf.sent', 'transport.dtmf.received']) {
        h.socket.emit({'type': type, 'event_id': type, 'event': '#'});
      }
      await _tick();
      expect(h.errors, hasLength(2));
      expect(h.received, isEmpty);
      expect(h.connection.isClosed, isFalse);
    });
  }

  test(
    'sideband SIP DTMF separates command, send confirmation, received key and service errors',
    () async {
      final h = await _Harness.open('sideband');
      addTearDown(h.dispose);
      h.send(LiveTransportDTMFSendParam(event: '#', eventId: 'send_key'));
      expect(h.socket.writes.last, {
        'type': 'transport.dtmf.send',
        'event': '#',
        'event_id': 'send_key',
      });
      h.socket.emit({
        'type': 'transport.dtmf.sent',
        'event_id': 'sent',
        'event': '#',
        'client_event_id': 'send_key',
      });
      h.socket.emit({
        'type': 'transport.dtmf.received',
        'event_id': 'received',
        'event': '2',
      });
      h.send(LiveTransportDTMFSendParam(event: 'A', eventId: 'not_sip'));
      h.socket.error('not_sip', 'sip_required');
      h.send(LiveTransportDTMFSendParam(event: '0'));
      h.socket.emit({
        'type': 'error',
        'event_id': 'uncorrelated',
        'error': {
          'type': 'invalid_request_error',
          'code': 'send_failed',
          'message': 'Synthetic send failure',
        },
      });
      final legacy = {
        'type': 'transport.dtmf.send',
        'event_id': 'saved_legacy',
        'event': '3',
        'future': {'retained': true},
      };
      h.socket.emit(legacy);
      await _tick();
      expect(
        h.received.whereType<LiveTransportDTMFSent>().single.clientEventId,
        'send_key',
      );
      expect(
        h.received.whereType<LiveTransportDTMFReceived>().single.event,
        '2',
      );
      expect(
        h.received.whereType<LiveErrorEvent>().first.error.clientEventId,
        'not_sip',
      );
      expect(
        h.received.whereType<LiveErrorEvent>().last.error.clientEventId,
        isNull,
      );
      expect(
        h.received.whereType<UnknownLiveServerEvent>().single.toJson(),
        legacy,
      );
      expect(h.errors, isEmpty);
      expect(h.connection.isClosed, isFalse);
    },
  );

  test(
    'borrowed media channel rejects fixture and DTMF without closing caller media',
    () async {
      final channel = _Channel();
      final caller = <String>[];
      final callerTap = channel.messages.listen(caller.add);
      final connection = LiveConnection.dataChannel(channel);
      expect(
        () => connection.send(LiveOutputAudioFixturePlayParam(audio: 'AAA=')),
        throwsA(isA<LiveProtocolException>()),
      );
      expect(
        () => connection.send(LiveTransportDTMFSendParam(event: '1')),
        throwsA(isA<LiveProtocolException>()),
      );
      expect(channel.sent, isEmpty);
      await connection.close();
      channel.controller.add('caller still owns this channel');
      expect(caller, ['caller still owns this channel']);
      await callerTap.cancel();
      await channel.controller.close();
    },
  );

  test('already-started primary WebSocket still permits fixtures', () async {
    final socket = _Socket();
    final connection = LivePrimaryConnection(
      socket,
      sessionAlreadyStarted: true,
    )..send(LiveOutputAudioFixturePlayParam(audio: 'AAA='));
    expect(socket.writes.single['type'], 'session.output_audio.fixture.play');
    await connection.close();
  });
}

class _Harness {
  _Harness(this.client, this.socket, this.connection);
  final OpenAIClient client;
  final _Socket socket;
  final LiveConnection connection;
  final received = <LiveServerEvent>[];
  final errors = <Object>[];
  late StreamSubscription<LiveServerEvent> tap;

  static Future<_Harness> open(String channel) async {
    final client = OpenAIClient(
      httpClient: MockClient(
        (_) async => throw StateError('No HTTP expected.'),
      ),
    );
    final socket = _Socket();
    final connection = switch (channel) {
      'primary' => await client.live.connect(
        connector: (uri, {headers}) async => socket,
      ),
      'sideband' => await client.live.attach(
        'live_fixture',
        connector: (uri, {headers}) async => socket,
      ),
      _ => await client.live.forkConnection(
        'stored_fixture',
        connector: (uri, {headers}) async => socket,
      ),
    };
    final h = _Harness(client, socket, connection);
    h.tap = connection.events.listen(h.received.add, onError: h.errors.add);
    if (connection is LivePrimaryConnection) {
      await connection.start(
        LiveSessionStartEvent(
          session: LiveSessionCreateParams.fromJson(const {
            'model': 'gpt-live-1',
            'audio': {
              'format': {'type': 'audio/pcma', 'rate': 8000},
            },
          }),
        ),
      );
    } else if (connection is LiveForkConnection) {
      await connection.start(
        LiveForkSessionStartEvent(session: LiveForkSessionConfigParam()),
      );
    }
    await _tick();
    h.received.clear();
    return h;
  }

  void send(LiveSidebandClientEvent command) {
    switch (connection) {
      case LivePrimaryConnection():
        (connection as LivePrimaryConnection).send(command);
      case LiveForkConnection():
        (connection as LiveForkConnection).send(command);
      case LiveSidebandConnection():
        (connection as LiveSidebandConnection).send(command);
    }
  }

  Future<void> dispose() async {
    await tap.cancel();
    await connection.close();
    client.close();
  }
}

class _Socket implements WebSocket {
  final _events = StreamController<WebSocketEvent>(sync: true);
  final List<Map<String, dynamic>> writes = [];
  int closeCalls = 0;
  bool autoFinalize = true;
  void emit(Map<String, dynamic> event) =>
      _events.add(TextDataReceived(jsonEncode(event)));
  void error(String clientId, String code) => emit({
    'type': 'error',
    'event_id': 'error_$clientId',
    'error': {
      'type': 'invalid_request_error',
      'code': code,
      'message': 'Synthetic error',
      'client_event_id': clientId,
    },
  });
  void peerClose() {
    autoFinalize = false;
    _events.add(CloseReceived(1000, ''));
  }

  @override
  Stream<WebSocketEvent> get events => _events.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String text) {
    final wire = jsonDecode(text) as Map<String, dynamic>;
    writes.add(wire);
    if (wire['type'] == 'session.start') {
      emit({
        'type': 'session.started',
        'event_id': 'started',
        'session': _session(),
      });
    } else if (wire['type'] == 'session.close' && autoFinalize) {
      emit({
        'type': 'session.closed',
        'event_id': 'closed',
        'reason': 'close_requested',
        'session': _session(),
        'usage': {'seconds': 0.1},
      });
    }
  }

  @override
  void sendBytes(Uint8List bytes) => throw UnsupportedError('JSON fixture');
  @override
  Future<void> close([int? code, String? reason]) async {
    closeCalls++;
    unawaited(_events.close());
  }
}

class _Channel implements LiveDataChannel {
  final controller = StreamController<String>.broadcast(sync: true);
  final sent = <String>[];
  @override
  Stream<String> get messages => controller.stream;
  @override
  void sendText(String text) => sent.add(text);
}
