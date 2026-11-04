/// Plays raw fixture audio and sends one SIP DTMF key through synthetic peers.
/// No API key, audio device, SIP call or paid API request is used.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:web_socket/web_socket.dart';

Future<void> main() async {
  final peer = _Peer();
  final client = OpenAIClient(
    httpClient: MockClient((_) async => throw StateError('No HTTP expected.')),
  );
  // In production, attach to an authorized, already-running SIP session.
  // A generic sideband connection alone does not prove SIP eligibility.
  final connection = await client.live.attach(
    'live_synthetic_sip',
    connector: (uri, {headers}) async => peer,
  );
  final events = <LiveServerEvent>[];
  final errors = <Object>[];
  final tap = connection.events.listen(events.add, onError: errors.add);
  try {
    final muted = connection.events.firstWhere((e) => e is LiveInputAudioMuted);
    connection.send(LiveInputAudioMuteParam(eventId: 'mute_input'));
    await muted;

    // Headerless mono PCM16 little-endian at 24 kHz, independently of the
    // session's media format. Here 480 zero bytes represent 10 ms of silence.
    // Production fixtures may contain at most 30 seconds; never pass WAV data.
    final playing = connection.events.firstWhere(
      (e) => e is LiveOutputAudioFixturePlaying && e.clientEventId == 'fixture',
    );
    final played = connection.events.firstWhere(
      (e) => e is LiveOutputAudioFixturePlayed && e.clientEventId == 'fixture',
    );
    connection.send(
      LiveOutputAudioFixturePlayParam.fromBytes(
        Uint8List(480),
        eventId: 'fixture',
      ),
    );
    await playing; // Validated fixture accepted, not listener's first sample.
    peer.drainFixture(); // Synthetic server only; no production playback helper.
    await played; // Server mixer drained; transport audio may remain buffered.

    // Fixture playback does not clear independent input mute. Explicitly unmute.
    // During playback input is dropped and instruction/thinking/commentary
    // appends are rejected. Afterward, describe only content already delivered.
    final unmuted = connection.events.firstWhere(
      (e) => e is LiveInputAudioUnmuted,
    );
    connection.send(LiveInputAudioUnmuteParam(eventId: 'unmute_input'));
    await unmuted;
    connection.send(
      LiveInstructionsAppendParam(
        delegationId: null,
        content: 'The application delivered its short cue.',
      ),
    );

    final sent = connection.events.firstWhere(
      (e) => e is LiveTransportDTMFSent && e.clientEventId == 'send_key',
    );
    connection.send(
      LiveTransportDTMFSendParam(event: '#', eventId: 'send_key'),
    );
    await sent; // Sent to SIP trunk, not confirmation of a remote IVR action.
    peer.callerKey('2');
    await connection.closeSession();
    if (errors.isNotEmpty || events.whereType<LiveErrorEvent>().isNotEmpty) {
      throw StateError('Unexpected synthetic protocol error.');
    }
    stdout
      ..writeln('Observed fixture acceptance, mixer drain and explicit unmute.')
      ..writeln('Sent one SIP DTMF key and received a distinct caller key.')
      ..writeln('Zero API requests, audio devices or telephony charges.');
  } finally {
    await tap.cancel();
    await connection.close();
    client.close();
  }
}

class _Peer implements WebSocket {
  final _events = StreamController<WebSocketEvent>(sync: true);
  void _emit(Map<String, dynamic> event) =>
      _events.add(TextDataReceived(jsonEncode(event)));
  void drainFixture() => _emit({
    'type': 'session.output_audio.fixture.played',
    'event_id': 'mixer_drained',
    'client_event_id': 'fixture',
  });
  void callerKey(String key) => _emit({
    'type': 'transport.dtmf.received',
    'event_id': 'caller_key',
    'event': key,
  });
  @override
  void sendText(String text) {
    final command = jsonDecode(text) as Map<String, dynamic>;
    final correlation = command['event_id'];
    switch (command['type']) {
      case 'session.input_audio.mute':
        _emit({
          'type': 'session.input_audio.muted',
          'event_id': 'muted',
          'client_event_id': correlation,
        });
      case 'session.input_audio.unmute':
        _emit({
          'type': 'session.input_audio.unmuted',
          'event_id': 'unmuted',
          'client_event_id': correlation,
        });
      case 'session.output_audio.fixture.play':
        _emit({
          'type': 'session.output_audio.fixture.playing',
          'event_id': 'accepted',
          'client_event_id': correlation,
        });
      case 'session.instructions.append':
        break;
      case 'transport.dtmf.send':
        _emit({
          'type': 'transport.dtmf.sent',
          'event_id': 'sent',
          'event': command['event'],
          'client_event_id': correlation,
        });
      case 'session.close':
        _emit({
          'type': 'session.closed',
          'event_id': 'closed',
          'reason': 'close_requested',
          'session': {
            'id': 'live_synthetic_sip',
            'model': 'gpt-live-1',
            'expires_at': -1,
            'status': 'active',
          },
          'usage': {'seconds': 0.01},
        });
      default:
        throw StateError('Unexpected synthetic command.');
    }
  }

  @override
  Stream<WebSocketEvent> get events => _events.stream;
  @override
  String get protocol => '';
  @override
  void sendBytes(Uint8List bytes) => throw UnsupportedError('JSON only');
  @override
  Future<void> close([int? code, String? reason]) async {
    unawaited(_events.close());
  }
}
