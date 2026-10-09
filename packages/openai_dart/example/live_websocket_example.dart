// ignore_for_file: avoid_print
/// Offline primary and sideband Live conversations with manual action ownership.
///
/// Run: dart run example/live_websocket_example.dart
/// Injected peers generate synthetic events. No API key, external socket, media
/// capture, real function execution or API charges are required.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:web_socket/web_socket.dart' as ws;

Future<void> main() async {
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://example.invalid/proxy/v1',
      authProvider: ApiKeyProvider('synthetic-live-websocket-key'),
    ),
    httpClient: MockClient(
      (_) async => throw StateError('No HTTP is expected.'),
    ),
  );
  try {
    await _primary(client);
    await _sideband(client);
    print(r'Primary and sideband workflows passed; API cost $0.');
  } finally {
    client.close();
  }
}

Future<void> _primary(OpenAIClient client) async {
  final peer = _Peer(sideband: false);
  final connection = await client.live.connect(connector: peer.connect);
  final reader = StreamIterator(connection.events);
  var transcriptDeltas = 0;
  // A second tap observes captions; only the application reader owns actions.
  final captions = connection.events.listen((event) {
    if (event is LiveInputTranscriptDelta ||
        event is LiveOutputTranscriptDelta) {
      transcriptDeltas++;
    }
  });
  try {
    await connection.start(
      LiveSessionStartEvent(
        session: LiveSessionCreateParams(
          model: 'gpt-live-1',
          audio: LiveInitialSessionAudioParam(
            format: LiveAudioFormat.pcm(rate: 24000),
          ),
        ),
        eventId: 'synthetic_start',
      ),
    );
    // Production packets come from caller-owned capture at the configured
    // format and cadence. Live appends raw Base64, with no data URL or commit.
    connection.send(LiveInputAudioAppendEvent(audio: 'AAA='));
    LiveDelegationCreated? delegated;
    while (await reader.moveNext()) {
      if (reader.current case final LiveDelegationCreated event) {
        delegated = event;
        break;
      }
    }
    if (delegated == null || delegated.delegation.target != 'client') {
      throw StateError('Expected client-owned delegated work.');
    }
    // The delegation contains metadata, not a task utterance. In production,
    // use collected transcripts and application state to decide what to do.
    connection
      ..send(
        LiveThinkingAppendParam(
          delegationId: delegated.delegation.id,
          content: 'Checking the synthetic appointment fixture.',
        ),
      )
      ..send(
        LiveCommentaryAppendParam(
          delegationId: delegated.delegation.id,
          content: 'The fixture has an appointment available.',
        ),
      );
    final finalEvent = await connection.closeSession();
    if (!connection.isFinalized ||
        finalEvent.usage.seconds != 3.5 ||
        connection.latestUsageSeconds != 3.5 ||
        transcriptDeltas != 2 ||
        peer.sent.length != 5 ||
        peer.closes != 1) {
      throw StateError('Primary finalization or concurrent taps failed.');
    }
    print('Primary: five commands, two caption deltas, confirmed final usage.');
  } finally {
    await reader.cancel();
    await captions.cancel();
    await connection.close();
  }
}

Future<void> _sideband(OpenAIClient client) async {
  final peer = _Peer(sideband: true);
  final connection = await client.live.attach(
    'live_synthetic_media',
    gracefulClose: true,
    connector: peer.connect,
  );
  final reader = StreamIterator(connection.events);
  var observedResponses = 0;
  final observer = connection.events.listen((event) {
    if (event is LiveResponseEvent) observedResponses++;
  });
  try {
    final pending = <Map<String, dynamic>>[];
    String? delegationId;
    String? responseId;
    while (pending.length < 2 && await reader.moveNext()) {
      final event = reader.current;
      if (event is LiveDelegationCreated) {
        delegationId = event.delegation.id;
        responseId = event.delegation.responseId;
      } else if (event is LiveResponseEvent &&
          event.event['type'] == 'response.output_item.done') {
        if (event.delegationId != delegationId) {
          throw StateError('Unexpected delegation correlation.');
        }
        final item = event.event['item'];
        if (item is Map<String, dynamic> && item['type'] == 'function_call') {
          pending.add(item);
        }
      }
    }
    if (pending.length != 2 || responseId != 'resp_synthetic_backend') {
      throw StateError('Expected both backend function requests.');
    }
    // This application is the sole action owner. The observer/frontend must
    // not also execute these calls. Production authorization and execution are
    // application decisions; an interruption does not cancel external work.
    final submitted = <String>{};
    for (final item in pending) {
      final callId = item['call_id'] as String;
      if (item['name'] != 'synthetic_lookup' || !submitted.add(callId)) {
        throw StateError('Unexpected or duplicate synthetic function request.');
      }
      connection.send(
        LiveResponseItemCreateParam(
          item: LiveInputItem.fromJson({
            'type': 'function_call_output',
            'call_id': callId,
            'output': jsonEncode({'available': true}),
          }),
        ),
      );
    }
    // Submit EVERY pending result before ONE continuation. There is no
    // response.item.create success acknowledgment to await.
    connection.send(LiveResponseCreateParam());
    final finalEvent = await connection.closeSession();
    if (!connection.isFinalized ||
        finalEvent.usage.seconds != 3.5 ||
        observedResponses != 2 ||
        peer.sent.length != 4 ||
        peer.closes != 1) {
      throw StateError('Sideband finalization or action ownership failed.');
    }
    print('Sideband: two results, one continuation, no startup/audio sends.');
  } finally {
    await reader.cancel();
    await observer.cancel();
    await connection.close();
  }
}

class _Peer implements ws.WebSocket {
  _Peer({required this.sideband});

  final bool sideband;
  final _events = StreamController<ws.WebSocketEvent>();
  final sent = <Map<String, dynamic>>[];
  int closes = 0;
  late Map<String, dynamic> _session;

  Future<ws.WebSocket> connect(Uri uri, {Map<String, String>? headers}) async {
    final path = sideband
        ? '/proxy/v1/live/sessions/live_synthetic_media/attach'
        : '/proxy/v1/live/sessions';
    if (uri.scheme != 'wss' ||
        uri.host != 'example.invalid' ||
        uri.path != path ||
        uri.query != (sideband ? 'graceful_close=true' : '') ||
        headers?['authorization'] != 'Bearer synthetic-live-websocket-key') {
      throw StateError('Unexpected synthetic connection scope.');
    }
    if (sideband) {
      _session = {
        'model': 'gpt-live-1',
        'id': 'live_synthetic_media',
        'expires_at': 1788555600,
        'status': 'active',
        'delegation': {
          'type': 'responses',
          'responses': {'model': 'gpt-6-luna'},
        },
      };
      _emit({
        'type': 'session.started',
        'event_id': 'side_started',
        'session': _session,
      });
      _emit({
        'type': 'session.delegation.created',
        'event_id': 'side_delegated',
        'offset_ms': 10,
        'delegation': {
          'type': 'delegation',
          'id': 'del_synthetic_backend',
          'target': 'responses',
          'response_id': 'resp_synthetic_backend',
        },
      });
      for (var i = 0; i < 2; i++) {
        _emit({
          'type': 'response.event',
          'event_id': 'side_function_$i',
          'delegation_id': 'del_synthetic_backend',
          'event': {
            'type': 'response.output_item.done',
            'output_index': i,
            'sequence_number': i,
            'item': {
              'type': 'function_call',
              'id': 'fc_synthetic_$i',
              'call_id': 'call_synthetic_$i',
              'name': 'synthetic_lookup',
              'arguments': '{}',
              'status': 'completed',
            },
          },
        });
      }
    }
    return this;
  }

  @override
  Stream<ws.WebSocketEvent> get events => _events.stream;

  @override
  String get protocol => '';

  void _emit(Map<String, dynamic> event) =>
      _events.add(ws.TextDataReceived(jsonEncode(event)));

  @override
  void sendText(String text) {
    final event = jsonDecode(text) as Map<String, dynamic>;
    sent.add(event);
    switch (event['type']) {
      case 'session.start':
        if (sideband) throw StateError('Sideband must not restart media.');
        _session = {
          ...event['session'] as Map<String, dynamic>,
          'id': 'live_synthetic_primary',
          'expires_at': 1788555600,
          'status': 'active',
        };
        _emit({
          'type': 'session.started',
          'event_id': 'primary_started',
          'session': _session,
        });
      case 'session.input_audio.append':
        if (sideband || event['audio'] != 'AAA=') {
          throw StateError('Unexpected audio.');
        }
        _emit({
          'type': 'session.input_transcript.delta',
          'event_id': 'primary_input',
          'start_ms': 0,
          'end_ms': 10,
          'delta': 'Synthetic question.',
        });
        _emit({
          'type': 'session.delegation.created',
          'event_id': 'primary_delegated',
          'offset_ms': 10,
          'delegation': {
            'type': 'delegation',
            'id': 'del_synthetic_client',
            'target': 'client',
          },
        });
      case 'session.commentary.append':
        _emit({
          'type': 'session.output_transcript.delta',
          'event_id': 'primary_output',
          'start_ms': 20,
          'end_ms': 30,
          'delta': 'Synthetic answer.',
        });
        for (final seconds in [1.25, 2.75]) {
          _emit({
            'type': 'session.usage.updated',
            'event_id': 'usage_$seconds',
            'usage': {'seconds': seconds},
          });
        }
      case 'response.create':
        if (sent.where((e) => e['type'] == 'response.item.create').length !=
            2) {
          throw StateError('Every function result must precede continuation.');
        }
      case 'session.close':
        _emit({
          'type': 'session.closed',
          'event_id': 'final',
          'reason': 'close_requested',
          'session': _session,
          'usage': {'seconds': 3.5},
        });
      case 'session.thinking.append':
      case 'response.item.create':
        break;
      default:
        throw StateError('Unexpected synthetic command.');
    }
  }

  @override
  void sendBytes(Uint8List bytes) =>
      throw StateError('Live uses JSON audio events.');

  @override
  Future<void> close([int? code, String? reason]) async {
    closes++;
    if (closes != 1) throw StateError('Socket released more than once.');
    await _events.close();
  }
}
