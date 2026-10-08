// ignore_for_file: avoid_print

/// Recover a socket and report unsent frames locally, without an API key.
///
/// Reopening does not restore connection-local response state or accepted
/// steering. This application supplies retained context for new chains and never
/// resends previously submitted input. An injected socket makes every write and
/// interruption observable without generating output or calling an external API.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:web_socket/web_socket.dart' as ws;

Future<void> main() async {
  final first = _LocalSocket('resp_original');
  final reopened = _LocalSocket('resp_reopened');
  final prepareStarted = [Completer<void>(), Completer<void>()];
  final prepareDecisions = [
    Completer<ResponsesReconnectDecision>(),
    Completer<ResponsesReconnectDecision>(),
  ];
  var preparations = 0;
  var dials = 0;
  final client = OpenAIClient(
    config: const OpenAIConfig(baseUrl: 'https://example.invalid/v1'),
  );
  try {
    final connection = await client.responses.connect(
      reconnect: ResponsesReconnectOptions(
        initialDelay: Duration.zero,
        maxDelay: Duration.zero,
        // A small strict budget makes rejection visible in this offline demo.
        maxQueueBytes: 512,
        onReconnecting: (context) {
          _require(context.closeCode == 1006, 'Unexpected interruption.');
          final index = preparations++;
          _require(index < 2, 'Unexpected extra preparation.');
          prepareStarted[index].complete();
          // Reconcile application history here. This fixture uses full saved
          // input for new chains; it does not assume an old response ID survives.
          return prepareDecisions[index].future;
        },
      ),
      connector: (uri, {headers}) async {
        dials++;
        if (dials == 1) {
          _require(headers!.isEmpty, 'Unexpected initial headers.');
          return first;
        }
        _require(dials == 2, 'A cancelled preparation reopened the socket.');
        _require(
          uri.queryParameters['offline_attempt'] == 'prepared',
          'Query preparation was not applied.',
        );
        _require(
          headers!['x-local'] == 'prepared',
          'Header preparation was not applied.',
        );
        return reopened;
      },
    );
    final recovery = connection.recovery!;
    final reader = StreamIterator(connection.events);
    final connected = Completer<void>();
    final lifecycle = recovery.events.listen((event) {
      if (event is ResponsesRecoveryReconnected && !connected.isCompleted) {
        connected.complete();
      }
    });
    try {
      connection.create(_request('Draft a project plan.'));
      _require(await reader.moveNext(), 'Original response did not arrive.');
      final created = reader.current as ResponsesStreamEvent;
      final parent = (created.event as ResponseCreatedEvent).response.id;
      connection.steer(
        previousResponseId: parent,
        input: const ResponsesSteerInput.text('Keep the scope small.'),
      );
      _require(
        await reader.moveNext(),
        'Steering acknowledgement did not arrive.',
      );
      _require(
        reader.current is ResponsesSteerAcceptedEvent,
        'Unexpected steering acknowledgement.',
      );

      first.interrupt();
      await prepareStarted.first.future;
      final callerMetadata = {'revision': 'captured'};
      connection
        ..create(
          _request('Saved full context for plan A.', metadata: callerMetadata),
          streamId: 'plan-a',
        )
        ..create(
          _request('Saved full context for plan B.'),
          streamId: 'plan-b',
        );
      callerMetadata['revision'] = 'mutated after enqueue';
      var rejected = false;
      try {
        connection.create(_request('é' * 1000));
      } on ResponsesSendQueueOverflowException {
        rejected =
            true; // Only this new frame is rejected; the queue stays usable.
      }
      _require(rejected && !connection.isClosed, 'Overflow ended recovery.');
      prepareDecisions.first.complete(
        const ResponsesReconnectDecision.continueWith(
          queryParameters: {'offline_attempt': 'prepared'},
          headers: {'x-local': 'prepared'},
        ),
      );
      await connected.future;
      _require(
        first.frames.length == 2 && reopened.frames.length == 2,
        'Submitted work replayed or new work was dropped.',
      );
      _require(
        reopened.frames[0]['stream_id'] == 'plan-a' &&
            reopened.frames[1]['stream_id'] == 'plan-b',
        'FIFO order changed.',
      );
      _require(
        (reopened.frames.first['metadata']
                as Map<String, dynamic>)['revision'] ==
            'captured',
        'Queued bytes changed after caller mutation.',
      );
      _require(
        reopened.frames.every(
          (frame) =>
              frame['type'] == 'response.create' &&
              !frame.containsKey('previous_response_id'),
        ),
        'Recovery assumed a previous cache or replayed steering.',
      );

      reopened.interrupt();
      await prepareStarted[1].future;
      connection.create(_request('Saved full context, not yet submitted.'));
      await connection.close(1000, 'offline cleanup');
      final report = await recovery.done;
      _require(
        report.cause == 'explicit_close' &&
            report.code == 1000 &&
            report.unsentMessages.length == 1,
        'Final never-attempted report changed.',
      );
      final unsent = report.unsentMessages.single;
      _require(
        unsent.message['input'] == 'Saved full context, not yet submitted.',
        'Final report lost the original snapshot.',
      );
      var immutable = false;
      try {
        report.unsentMessages.clear();
      } on UnsupportedError {
        immutable = true;
      }
      _require(immutable && dials == 2, 'Report mutated or close reconnected.');
      prepareDecisions[1].complete(const ResponsesReconnectDecision.abort());
      print('Four writes; sent create/steer were never replayed.');
      print(
        'Two new FIFO frames, one rejected frame, one final unsent snapshot.',
      );
      print('Socket recovery completed locally; no API charges.');
    } finally {
      try {
        await connection.close();
        await connection.done;
      } finally {
        await reader.cancel();
        await lifecycle.cancel();
        for (final decision in prepareDecisions) {
          if (!decision.isCompleted) {
            decision.complete(const ResponsesReconnectDecision.abort());
          }
        }
      }
    }
  } finally {
    client.close();
  }
}

CreateResponseRequest _request(String input, {Map<String, String>? metadata}) =>
    CreateResponseRequest(
      model: 'gpt-6-sol',
      input: ResponseInput.text(input),
      store: false,
      metadata: metadata,
    );

void _require(bool condition, String message) {
  if (!condition) throw StateError(message);
}

class _LocalSocket implements ws.WebSocket {
  _LocalSocket(this.responseId);
  final String responseId;
  final frames = <Map<String, dynamic>>[];
  final _events = StreamController<ws.WebSocketEvent>();
  var _sequence = 0;

  @override
  Stream<ws.WebSocketEvent> get events => _events.stream;
  @override
  String get protocol => '';

  @override
  void sendText(String text) {
    final frame = jsonDecode(text) as Map<String, dynamic>;
    frames.add(frame);
    if (responseId == 'resp_original') {
      _events.add(
        ws.TextDataReceived(
          jsonEncode({
            'sequence_number': ++_sequence,
            if (frame['type'] == 'response.steer') ...{
              'type': 'response.steer.accepted',
              'steer': {
                'id': 'steer_saved',
                'previous_response_id': responseId,
              },
            } else ...{
              'type': 'response.created',
              'response': {
                'id': responseId,
                'object': 'response',
                'created_at': 1,
                'status': 'in_progress',
                'model': 'gpt-6-sol',
                'output': <dynamic>[],
                'access_programs': null,
                'error': null,
                'incomplete_details': null,
                'instructions': null,
                'tools': <dynamic>[],
                'parallel_tool_calls': false,
                'metadata': <String, dynamic>{},
                'tool_choice': 'auto',
                'temperature': 1.0,
                'top_p': 1.0,
              },
            },
          }),
        ),
      );
    }
  }

  void interrupt() {
    _events.add(ws.CloseReceived(1006, 'local interruption'));
    unawaited(_events.close());
  }

  @override
  void sendBytes(Uint8List bytes) =>
      throw UnsupportedError('Text frames only.');
  @override
  Future<void> close([int? code, String? reason]) async {
    if (_events.isClosed) return;
    _events.add(ws.CloseReceived(code ?? 1000, reason ?? ''));
    unawaited(_events.close());
  }
}
