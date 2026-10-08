// ignore_for_file: avoid_print

/// Follow automatic and saved-tool-result steering continuations locally.
///
/// Uses the public Responses connection with an injected socket. No API key,
/// external service or model generation is needed. Accepted steering is queued;
/// successor creation commits it. The application supplies saved results once
/// per parent, without resending accepted input or running a tool again.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:web_socket/web_socket.dart' as ws;

Future<void> main() async {
  await _run(toolsRequired: false);
  await _run(toolsRequired: true);
  print('Automatic and saved-result steering continuations passed.');
  print('Three create frames and three steer frames; no API charges.');
}

Future<void> _run({required bool toolsRequired}) async {
  final socket = _LocalSteeringSocket(toolsRequired: toolsRequired);
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://example.invalid/v1',
      retryPolicy: RetryPolicy(maxRetries: 0),
    ),
  );
  try {
    final connection = await client.responses.connect(
      connector: (uri, {headers}) async {
        if (uri.toString() != 'wss://example.invalid/v1/responses' ||
            headers == null ||
            headers.isNotEmpty) {
          throw StateError('Unexpected local handshake.');
        }
        return socket;
      },
    );
    final reader = StreamIterator(connection.events);
    final acceptedIds = <String>{};
    final continuedParents = <String>{};
    // These results were already obtained by the application's normal tool flow.
    const savedResults = {
      'call_saved': 'Design complete; development pending.',
    };
    String? initialId;
    String? successorId;
    var finished = false;
    try {
      connection.create(
        const CreateResponseRequest(
          model: 'gpt-6-sol',
          input: ResponseInput.text('Draft a project plan.'),
          store: false,
        ),
        streamId: toolsRequired ? 'planner' : null,
      );
      while (await reader.moveNext()) {
        final message = reader.current;
        if (message case ResponsesStreamEvent(
          event: ResponseCreatedEvent(:final response),
        )) {
          if (initialId == null) {
            initialId = response.id;
            connection.steer(
              previousResponseId: initialId,
              input: const ResponsesSteerInput.text('Keep the scope small.'),
            );
            if (toolsRequired) {
              connection.steer(
                previousResponseId: initialId,
                input: const ResponsesSteerInput.text(
                  'Include rollback steps.',
                ),
              );
            }
          } else {
            // This is the commit point; acceptance alone did not commit input.
            successorId = response.id;
          }
        } else if (message is ResponsesSteerAcceptedEvent) {
          if (message.steer.previousResponseId != initialId) {
            throw StateError('Unexpected accepted parent.');
          }
          acceptedIds.add(message.steer.id);
          // Keep reading. Never create or resend accepted input here.
        } else if (message is ResponsesSteerPendingEvent) {
          if (!toolsRequired ||
              !acceptedIds.contains(message.steer.id) ||
              message.reason != 'waiting_for_required_input' ||
              message.steer.previousResponseId != initialId ||
              message.streamId != 'planner' ||
              message.requiredInput.length != 1 ||
              message.requiredInput.single
                  is! ResponsesSteerFunctionCallOutput) {
            throw StateError('Unexpected local pending input.');
          }
          // Multiple pending submissions can identify the same required result.
          final parent = message.steer.previousResponseId;
          if (continuedParents.add(parent)) {
            final stub =
                message.requiredInput.single
                    as ResponsesSteerFunctionCallOutput;
            final saved = savedResults[stub.callId];
            if (saved == null || stub.name != 'get_project_status') {
              throw StateError('A saved tool result is unavailable.');
            }
            connection.create(
              CreateResponseRequest(
                model: 'gpt-6-sol',
                previousResponseId: parent,
                instructions: 'Use the saved result to finish the plan.',
                input: ResponseInput.items([
                  FunctionCallOutputItem.string(
                    callId: stub.callId,
                    output: saved,
                  ),
                ]),
                store: false,
              ),
              streamId: message.streamId,
            );
            // Explicit creates use their own settings. Accepted steering is
            // prepended by the server; the application does not repeat it.
          }
        } else if (message is ResponsesSteerFailedEvent ||
            message is ResponsesErrorEvent) {
          throw StateError('Unexpected local steering failure.');
        } else if (message case ResponsesStreamEvent(
          event: ResponseFailedEvent(),
        )) {
          throw StateError('A response failed before successor completion.');
        } else if (message case ResponsesStreamEvent(
          event: ResponseIncompleteEvent(:final response),
        )) {
          if (response.id != initialId ||
              response.incompleteDetails?.reason != 'steered') {
            throw StateError('Unexpected incomplete response.');
          }
          // The original stopped; its successor still has to arrive.
        } else if (message case ResponsesStreamEvent(
          event: ResponseCompletedEvent(:final response),
        )) {
          if (successorId != null && response.id == successorId) {
            finished = true;
            break;
          }
          // Normal original completion can precede pending or automatic work.
        }
      }
      if (!finished ||
          acceptedIds.length != (toolsRequired ? 2 : 1) ||
          continuedParents.length != (toolsRequired ? 1 : 0) ||
          socket.createCount != (toolsRequired ? 2 : 1) ||
          socket.steerCount != (toolsRequired ? 2 : 1) ||
          connection.isClosed) {
        // A disconnect or missing acknowledgment is an unknown outcome. This
        // example surfaces it and never automatically replays a sent frame.
        throw StateError('Local steering did not reach successor completion.');
      }
    } finally {
      try {
        await connection.close(1000, 'local cleanup');
        await connection.done;
      } finally {
        await reader.cancel();
      }
    }
  } finally {
    client.close();
  }
}

class _LocalSteeringSocket implements ws.WebSocket {
  _LocalSteeringSocket({required this.toolsRequired});

  final bool toolsRequired;
  final _controller = StreamController<ws.WebSocketEvent>();
  int createCount = 0;
  int steerCount = 0;
  int _sequence = 0;

  @override
  Stream<ws.WebSocketEvent> get events => _controller.stream;
  @override
  String get protocol => '';

  @override
  void sendText(String text) {
    final frame = jsonDecode(text) as Map<String, dynamic>;
    if (frame['type'] == 'response.create') {
      createCount++;
      if (frame.containsKey('stream') || frame.containsKey('background')) {
        throw StateError('Unexpected create transport settings.');
      }
      if (createCount == 1) {
        if (frame.containsKey('previous_response_id') ||
            frame['stream_id'] != (toolsRequired ? 'planner' : null)) {
          throw StateError('Unexpected initial create.');
        }
        _response('response.created', 'resp_original', 'in_progress');
      } else if (toolsRequired && createCount == 2) {
        final input = frame['input'] as List<dynamic>;
        final result = input.single as Map<String, dynamic>;
        if (frame['previous_response_id'] != 'resp_original' ||
            frame['stream_id'] != 'planner' ||
            frame['instructions'] !=
                'Use the saved result to finish the plan.' ||
            result['type'] != 'function_call_output' ||
            result['call_id'] != 'call_saved' ||
            result['output'] != 'Design complete; development pending.') {
          throw StateError('Unexpected saved-result continuation.');
        }
        _successor();
      } else {
        throw StateError('Unexpected extra create.');
      }
    } else if (frame['type'] == 'response.steer') {
      steerCount++;
      if (frame.length != 3 ||
          frame['previous_response_id'] != 'resp_original' ||
          frame['input'] !=
              (steerCount == 1
                  ? 'Keep the scope small.'
                  : 'Include rollback steps.')) {
        throw StateError('Unexpected steering fields or repeated input.');
      }
      _emit({
        'type': 'response.steer.accepted',
        'steer': {
          'id': 'steer_$steerCount',
          'previous_response_id': 'resp_original',
        },
      });
      if (!toolsRequired) {
        _response('response.incomplete', 'resp_original', 'incomplete');
        _successor();
      } else if (steerCount == 2) {
        _response('response.completed', 'resp_original', 'completed');
        for (var i = 1; i <= 2; i++) {
          _emit({
            'type': 'response.steer.pending',
            'steer': {
              'id': 'steer_$i',
              'previous_response_id': 'resp_original',
            },
            'reason': 'waiting_for_required_input',
            'required_input': [
              {
                'type': 'function_call_output',
                'call_id': 'call_saved',
                'name': 'get_project_status',
              },
            ],
          });
        }
      } else if (steerCount > 2) {
        throw StateError('Unexpected extra steering submission.');
      }
    } else {
      throw StateError('Unexpected local frame type.');
    }
  }

  void _successor() {
    _response('response.created', 'resp_successor', 'in_progress');
    _response('response.completed', 'resp_successor', 'completed');
  }

  void _response(String type, String id, String status) => _emit({
    'type': type,
    'response': {
      'id': id,
      'object': 'response',
      'created_at': 1,
      'status': status,
      'model': 'gpt-6-sol',
      'output': toolsRequired && id == 'resp_original' && status == 'completed'
          ? [
              {
                'type': 'function_call',
                'id': 'fc_saved',
                'call_id': 'call_saved',
                'name': 'get_project_status',
                'arguments': '{}',
                'status': 'completed',
              },
            ]
          : <dynamic>[],
      'access_programs': null,
      'error': null,
      'incomplete_details': status == 'incomplete'
          ? {'reason': 'steered'}
          : null,
      'instructions': null,
      'tools': <dynamic>[],
      'parallel_tool_calls': false,
      'metadata': <String, dynamic>{},
      'tool_choice': 'auto',
      'temperature': 1.0,
      'top_p': 1.0,
    },
  });

  void _emit(Map<String, dynamic> frame) => _controller.add(
    ws.TextDataReceived(
      jsonEncode({
        ...frame,
        'sequence_number': ++_sequence,
        if (toolsRequired) 'stream_id': 'planner',
      }),
    ),
  );

  @override
  void sendBytes(Uint8List bytes) =>
      throw UnsupportedError('Text frames only.');

  @override
  Future<void> close([int? code, String? reason]) async {
    if (_controller.isClosed) return;
    _controller.add(ws.CloseReceived(code ?? 1000, reason ?? ''));
    unawaited(_controller.close());
  }
}
