// ignore_for_file: avoid_print
/// Offline stored-session forks, transcript grouping and manual delegation.
///
/// Run: dart run example/live_workflows_example.dart
/// Synthetic sockets, a borrowed channel and one recording GET per mode are
/// local fixtures. No API key, network, microphone, playback or paid call is used.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:web_socket/web_socket.dart' as ws;

Future<void> main() async {
  var downloads = 0;
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://example.invalid/proxy/v1',
      authProvider: ApiKeyProvider('synthetic-live-workflow-key'),
    ),
    httpClient: MockClient((request) async {
      if (request.method != 'GET' ||
          !request.url.path.endsWith('/content') ||
          request.headers['accept'] != 'audio/wav') {
        throw StateError('Only the selected mock recording GET is expected.');
      }
      downloads++;
      return http.Response.bytes(
        _stereoWav(),
        200,
        headers: {'content-type': 'audio/wav'},
      );
    }),
  );
  try {
    await _storedFork(client, responses: false);
    await _storedFork(client, responses: true);
    await _borrowedChannel();
    if (downloads != 2) throw StateError('Unexpected mock download count.');
    print(
      r'Two stored forks and borrowed-channel cleanup passed; API cost $0.',
    );
  } finally {
    client.close();
  }
}

Future<void> _storedFork(OpenAIClient client, {required bool responses}) async {
  final mode = responses ? 'responses' : 'client';
  final sourcePeer = _Peer(id: 'live_source_$mode', responses: responses);
  final source = await client.live.connect(connector: sourcePeer.connect);
  String sourceId;
  try {
    final started = await source.start(
      LiveSessionStartEvent(
        session: LiveSessionCreateParams(
          model: 'gpt-live-1',
          store: true,
          instructions: 'Synthetic saved conversation instructions.',
          input: [
            LiveInitialUserMessageItemParam(
              content: [
                LiveInitialInputTextContentPartParam(
                  text: 'The original order is confirmed.',
                ),
              ],
            ),
          ],
          audio: LiveInitialSessionAudioParam(
            format: LiveAudioFormat.pcm(rate: 16000),
            output: LiveInitialSessionAudioOutputParam(
              voice: LiveVoice.fromJson('cedar'),
            ),
          ),
          delegation: responses
              ? LiveResponsesDelegationParam(
                  responses: LiveResponsesDelegationSettingsInputParam(
                    model: 'gpt-6-luna',
                  ),
                )
              : null,
        ),
      ),
    );
    sourceId = started.session.id;
    // Production storage also requires project policy and a non-ZDR account.
    // Await the confirming event; local socket closure alone is insufficient.
    await source.closeSession();
    if (!source.isFinalized) {
      throw StateError('Source recording is unconfirmed.');
    }
  } finally {
    await source.close();
  }
  final recording = await client.live.sessions.downloadRecording(sourceId);
  if (recording.length != 48 ||
      ascii.decode(recording.sublist(0, 4)) != 'RIFF') {
    throw StateError('Expected the unchanged mock stereo WAV.');
  }

  // This state belongs to the application, independently of the saved audio.
  // Confirm a previously submitted operation's outcome before doing it again.
  final completedOperations = <String>{'original_order_already_confirmed'};
  final canceledDelegations = <String>{'del_stale'};
  final childPeer = _Peer(
    id: 'live_child_$mode',
    responses: responses,
    source: sourcePeer,
  );
  final child = await client.live.forkConnection(
    sourceId,
    connector: childPeer.connect,
  );
  final captions = LiveTranscriptGrouper();
  final captionUpdates = <LiveTranscriptUpdate>[];
  final captionTap = captions.updates.listen(captionUpdates.add);
  final attachment = captions.attach(child);
  final reader = StreamIterator(child.events);
  try {
    final started = await child.start(
      LiveForkSessionStartEvent(
        // An empty object inherits the source configuration. The Responses
        // trial explicitly disables child storage; neither changes its model.
        session: LiveForkSessionConfigParam(store: responses ? false : null),
      ),
    );
    final inheritedHistory = started.session.input?.single;
    if (started.session.id == sourceId ||
        started.session.model != sourcePeer.session['model'] ||
        started.session.instructions != sourcePeer.session['instructions'] ||
        inheritedHistory is! LiveInitialUserMessageItemParam ||
        inheritedHistory.content.single.text !=
            'The original order is confirmed.' ||
        started.session.audio?.output?.voice?.toJson() != 'cedar' ||
        (started.session.audio?.format?.toJson()
                as Map<String, dynamic>?)?['rate'] !=
            24000) {
      throw StateError('Fork did not create a new inherited session.');
    }
    if (responses) {
      await _responsesWork(
        child,
        reader,
        completedOperations,
        canceledDelegations,
      );
    } else {
      await _clientWork(
        child,
        reader,
        completedOperations,
        canceledDelegations,
      );
    }
    await child.closeSession();
    await Future<void>.delayed(Duration.zero);
    if (!child.isFinalized ||
        !captions.isSessionFinalized ||
        captions.segments.length != 2 ||
        captionUpdates.isEmpty ||
        childPeer.closes != 1) {
      throw StateError('Finalization, transcript taps or cleanup failed.');
    }
    final playback = projectLiveTranscriptPlayback(
      captions.segments.last,
      sourceAnchorMs: 1000,
      playbackAnchorMs: 5000,
    );
    // This is an explicit clock projection, not proof that audio was audible.
    print(
      '$mode fork: ${captions.segments.length} local caption segments, '
      'projected last start ${playback.startMs} ms.',
    );
  } finally {
    await reader.cancel();
    await attachment.detach();
    captions.close();
    await captionTap.cancel();
    await child.close();
  }
}

Future<void> _clientWork(
  LiveForkConnection connection,
  StreamIterator<LiveServerEvent> reader,
  Set<String> completed,
  Set<String> canceled,
) async {
  while (await reader.moveNext()) {
    if (reader.current case final LiveDelegationCreated event) {
      if (canceled.contains(event.delegation.id)) continue;
      if (event.delegation.target != 'client' ||
          !completed.contains('original_order_already_confirmed')) {
        throw StateError('Unexpected restored client task scope.');
      }
      // One observer owns actions. An old/canceled outcome is ignored; the
      // completed original action is not replayed on the new connection.
      connection
        ..send(
          LiveThinkingAppendParam(
            delegationId: event.delegation.id,
            content: 'Checking the explicitly restored application fixture.',
          ),
        )
        ..send(
          LiveCommentaryAppendParam(
            delegationId: event.delegation.id,
            content: 'The original order was already confirmed.',
          ),
        );
      return;
    }
  }
  throw StateError('Missing synthetic client delegation.');
}

Future<void> _responsesWork(
  LiveForkConnection connection,
  StreamIterator<LiveServerEvent> reader,
  Set<String> completed,
  Set<String> canceled,
) async {
  final responseIds = <String, String>{};
  final pendingCalls = <String>{};
  var ignored = 0;
  var initialGenerationFinished = false;
  while (await reader.moveNext()) {
    final raw = reader.current;
    if (raw is LiveDelegationCreated) {
      responseIds[raw.delegation.id] = raw.delegation.responseId!;
      continue;
    }
    if (raw is! LiveResponseEvent) continue;
    final view = LiveResponsesEvent.fromLiveEvent(raw);
    if (view is LiveResponsesLifecycleEvent) {
      // Compact output/tools can be empty even while function work is pending.
      // They do not reconstruct a complete ordinary Response or call ledger.
      if (view.type == 'response.created' &&
          (!view.response.hasInstructions ||
              view.response.instructions != null)) {
        throw StateError('Compact null/absence context was lost.');
      }
      if (view.isFinal && view.delegationId == 'del_active') {
        initialGenerationFinished = true;
        break;
      }
      continue;
    }
    if (view is! LiveResponsesGranularEvent ||
        view.granularEvent is! OutputItemDoneEvent) {
      continue;
    }
    final item = view.event['item'] as Map<String, dynamic>;
    if (canceled.contains(view.delegationId)) {
      ignored++;
      continue;
    }
    if (responseIds[view.delegationId] != 'resp_active' ||
        item['type'] != 'function_call' ||
        item['name'] != 'synthetic_lookup') {
      throw StateError('Unexpected function/delegation/response scope.');
    }
    pendingCalls.add(item['call_id'] as String);
  }
  if (!initialGenerationFinished ||
      pendingCalls.length != 2 ||
      ignored != 1 ||
      completed.length != 1) {
    throw StateError('Interleaved work was not routed explicitly.');
  }
  // Application authorization and execution are explicit synthetic decisions.
  // Submit EVERY result, then ONE continuation. There is no item-create ack.
  for (final callId in pendingCalls) {
    connection.send(
      LiveResponseItemCreateParam(
        item: LiveInputItem.fromJson({
          'type': 'function_call_output',
          'call_id': callId,
          'output': jsonEncode({'original_order_already_confirmed': true}),
        }),
      ),
    );
  }
  connection.send(LiveResponseCreateParam());
  while (await reader.moveNext()) {
    if (reader.current case final LiveResponseEvent raw) {
      final view = LiveResponsesEvent.fromLiveEvent(raw);
      if (view.isFinal && view.delegationId == 'del_active') return;
    }
  }
  throw StateError('Backend completion is unconfirmed.');
}

Future<void> _borrowedChannel() async {
  final channel = _Channel();
  var observed = 0;
  final appTap = channel.messages.listen((_) => observed++);
  final connection = LiveConnection.dataChannel(channel);
  final captions = LiveTranscriptGrouper();
  final attachment = captions.attach(connection);
  try {
    channel.emit(
      _transcript('channel_input', false, 0, 100, 'Synthetic media.'),
    );
    await Future<void>.delayed(Duration.zero);
    await attachment.detach();
    await connection.close();
    channel.emit({'type': 'caller.future.event'});
    await Future<void>.delayed(Duration.zero);
    if (channel.isClosed || observed != 2) {
      throw StateError(
        'Helper cleanup interfered with caller media/listeners.',
      );
    }
    print('Borrowed channel: application listener survives helper cleanup.');
  } finally {
    captions.close();
    await appTap.cancel();
    await channel.disposeByCaller();
  }
}

class _Channel implements LiveDataChannel {
  final _messages = StreamController<String>.broadcast();
  bool isClosed = false;
  @override
  Stream<String> get messages => _messages.stream;
  @override
  void sendText(String message) =>
      throw StateError('No media command expected.');
  void emit(Map<String, dynamic> event) => _messages.add(jsonEncode(event));
  Future<void> disposeByCaller() async {
    isClosed = true;
    await _messages.close();
  }
}

class _Peer implements ws.WebSocket {
  _Peer({required this.id, required this.responses, this.source});
  final String id;
  final bool responses;
  final _Peer? source;
  final _events = StreamController<ws.WebSocketEvent>();
  final sent = <Map<String, dynamic>>[];
  Map<String, dynamic> session = {};
  int closes = 0;

  Future<ws.WebSocket> connect(Uri url, {Map<String, String>? headers}) async {
    final route = source == null
        ? '/proxy/v1/live/sessions'
        : '/proxy/v1/live/sessions/${source!.id}/fork';
    if (url.scheme != 'wss' ||
        url.path != route ||
        url.query.isNotEmpty ||
        headers?['authorization'] != 'Bearer synthetic-live-workflow-key') {
      throw StateError('Unexpected synthetic route or authentication.');
    }
    return this;
  }

  @override
  Stream<ws.WebSocketEvent> get events => _events.stream;
  @override
  String get protocol => '';
  void emit(Map<String, dynamic> event) =>
      _events.add(ws.TextDataReceived(jsonEncode(event)));

  @override
  void sendText(String text) {
    final event = jsonDecode(text) as Map<String, dynamic>;
    sent.add(event);
    switch (event['type']) {
      case 'session.start':
        final overrides = event['session'] as Map<String, dynamic>;
        if (source != null && overrides.containsKey('model')) {
          throw StateError('Fork must inherit its model.');
        }
        session = {
          ...?source?.session,
          ...overrides,
          'id': id,
          'expires_at': 4102444800,
          'status': 'active',
        };
        if (source != null) {
          // Model, voice, instructions and history are inherited. The new
          // WebSocket format defaults to PCM16 24 kHz, independently of the
          // original source's 16 kHz format.
          session['audio'] = {
            ...source!.session['audio'] as Map<String, dynamic>,
            'format': {'type': 'audio/pcm', 'rate': 24000},
          };
        }
        emit({
          'type': 'session.started',
          'event_id': 'started_$id',
          'session': session,
        });
        if (source != null) {
          emit(
            _transcript(
              'input_$id',
              false,
              0,
              100,
              'Continue the saved order.',
            ),
          );
          emit(
            _transcript(
              'output_$id',
              true,
              1000,
              1800,
              'The saved order is confirmed.',
            ),
          );
          for (final delegation in ['del_stale', 'del_active']) {
            emit({
              'type': 'session.delegation.created',
              'event_id': '${id}_$delegation',
              'offset_ms': 1800,
              'delegation': {
                'type': 'delegation',
                'id': delegation,
                'target': responses ? 'responses' : 'client',
                if (responses)
                  'response_id': delegation == 'del_active'
                      ? 'resp_active'
                      : 'resp_stale',
              },
            });
          }
          if (responses) {
            _backend('del_active', {
              'type': 'response.created',
              'response': {
                'id': 'resp_active',
                'status': 'in_progress',
                'instructions': null,
                'tools': <Object>[],
                'output': <Object>[],
                'future_context': {'trial': true},
              },
            });
            for (var i = 0; i < 3; i++) {
              _backend(i == 1 ? 'del_stale' : 'del_active', {
                'type': 'response.output_item.done',
                'sequence_number': i,
                'output_index': i,
                'item': {
                  'type': 'function_call',
                  'id': 'fc_$i',
                  'call_id': 'call_$i',
                  'name': 'synthetic_lookup',
                  'arguments': '{}',
                  'status': 'completed',
                },
              });
            }
            _backend('del_active', {
              'type': 'response.completed',
              'response': {
                'id': 'resp_active',
                'status': 'completed',
                'tools': <Object>[],
                'output': <Object>[],
              },
            });
          }
        }
      case 'response.create':
        final results = sent
            .where((e) => e['type'] == 'response.item.create')
            .toList();
        if (results.length != 2 ||
            results.any(
              (e) => (e['item'] as Map<String, dynamic>)['call_id'] == 'call_1',
            )) {
          throw StateError(
            'Expected both active results and no canceled result.',
          );
        }
        _backend('del_active', {
          'type': 'response.completed',
          'response': {'id': 'resp_continued', 'status': 'completed'},
        });
      case 'session.close':
        emit({
          'type': 'session.closed',
          'event_id': 'closed_$id',
          'reason': 'close_requested',
          'session': session,
          'usage': {'seconds': 2.5},
        });
      case 'session.thinking.append':
      case 'session.commentary.append':
        if (event['delegation_id'] != 'del_active') {
          throw StateError('A canceled outcome must not be injected.');
        }
      case 'response.item.create':
        break;
      default:
        throw StateError('Unexpected synthetic command.');
    }
  }

  void _backend(String delegation, Map<String, dynamic> event) => emit({
    'type': 'response.event',
    'event_id': 'backend_${id}_${_sequence++}',
    'delegation_id': delegation,
    'event': event,
  });
  int _sequence = 0;
  @override
  void sendBytes(Uint8List bytes) =>
      throw StateError('Only JSON commands expected.');
  @override
  Future<void> close([int? code, String? reason]) async {
    if (++closes != 1) throw StateError('Socket closed more than once.');
    await _events.close();
  }
}

Map<String, dynamic> _transcript(
  String id,
  bool output,
  int start,
  int end,
  String text,
) => {
  'type': output
      ? 'session.output_transcript.delta'
      : 'session.input_transcript.delta',
  'event_id': id,
  'start_ms': start,
  'end_ms': end,
  'delta': text,
};

Uint8List _stereoWav() {
  final bytes = Uint8List(48);
  final header = ByteData.sublistView(bytes);
  for (final (offset, value) in [
    (0, 'RIFF'),
    (8, 'WAVE'),
    (12, 'fmt '),
    (36, 'data'),
  ]) {
    bytes.setRange(offset, offset + value.length, ascii.encode(value));
  }
  header
    ..setUint32(4, 40, Endian.little)
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little)
    ..setUint16(22, 2, Endian.little)
    ..setUint32(24, 24000, Endian.little)
    ..setUint32(28, 96000, Endian.little)
    ..setUint16(32, 4, Endian.little)
    ..setUint16(34, 16, Endian.little)
    ..setUint32(40, 4, Endian.little);
  return bytes;
}
