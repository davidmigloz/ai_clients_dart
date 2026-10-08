// ignore_for_file: avoid_print

/// Return developer-owned tool results to a beta multi-agent response locally.
///
/// The application executes each developer function once. Hosted multi-agent
/// actions remain server-owned. It reads completion and every injection
/// acknowledgment, then explicitly continues only uncommitted failed input.
/// Injected sockets make the race observable without an API key or API charges.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:web_socket/web_socket.dart' as ws;

Future<void> main() async {
  final socket = _LocalInjectionSocket();
  final client = OpenAIClient(
    config: const OpenAIConfig(baseUrl: 'https://example.invalid/v1'),
  );
  try {
    final connection = await client.responses.connect(
      beta: true,
      connector: (uri, {headers}) async {
        _require(
          uri.toString() == 'wss://example.invalid/v1/responses' &&
              headers!['openai-beta'] == 'responses_multi_agent=v1',
          'Unexpected local beta handshake.',
        );
        return socket;
      },
    );
    final reader = StreamIterator(connection.events);
    final savedResults = <String, FunctionCallOutputItem>{};
    final owningAgents = <String>{};
    var toolExecutions = 0;
    var hostedActionsObserved = 0;
    var acknowledgments = 0;
    var creates = 0;
    try {
      var nextInput = const ResponseInput.text(
        'Compare two local project plans.',
      );
      String? previousResponseId;
      while (true) {
        connection.create(
          _request(nextInput, previousResponseId: previousResponseId),
          streamId: 'planner',
        );
        creates++;
        String? responseId;
        String? completedId;
        var pending = 0;
        final uncommitted = <Map<String, dynamic>>[];
        var finished = false;
        while (await reader.moveNext()) {
          final event = reader.current;
          if (event case ResponsesStreamEvent(
            event: ResponseCreatedEvent(:final response),
          )) {
            _require(responseId == null, 'Unexpected additional response.');
            _require(event.streamId == 'planner', 'Response changed lanes.');
            responseId = response.id;
          } else if (event case ResponsesStreamEvent(
            event: OutputItemDoneEvent(:final item),
          )) {
            if (item is MultiAgentCallOutputItemResponse ||
                item is MultiAgentCallOutputResultItem) {
              hostedActionsObserved++;
              // Hosted collaboration actions/results are never client tools.
              continue;
            }
            if (item is! FunctionCallOutputItemResponse) continue;
            _require(
              responseId != null,
              'Function arrived before its response.',
            );
            _require(event.streamId == 'planner', 'Function changed lanes.');
            _require(
              item.name == 'get_fixture_status' && item.argumentsMap.isEmpty,
              'Unexpected developer function.',
            );
            // Retain ownership metadata; root and subagents can call this tool.
            owningAgents.add(item.agent!.agentName);
            if (savedResults.containsKey(item.callId)) continue;
            final result = FunctionCallOutputItem.string(
              callId: item.callId,
              output: '{"status":"ready"}',
            );
            savedResults[item.callId] = result;
            toolExecutions++;
            pending++;
            connection.inject(responseId: responseId!, input: [result]);
          } else if (event is ResponseInjectCreatedEvent) {
            _require(
              event.responseId == responseId &&
                  event.streamId == 'planner' &&
                  pending > 0,
              'Unexpected committed acknowledgment.',
            );
            pending--;
            acknowledgments++;
          } else if (event is ResponseInjectFailedEvent) {
            _require(
              event.responseId == responseId &&
                  event.streamId == 'planner' &&
                  pending > 0,
              'Unexpected failed acknowledgment.',
            );
            pending--;
            acknowledgments++;
            if (event.error.code !=
                ResponseInjectErrorCode.responseAlreadyCompleted) {
              throw StateError(
                'Injection was not committed; inspect the failure.',
              );
            }
            // A failure reports uncommitted raw input, rather than typed Items.
            // Validate the caller-owned result before choosing a continuation.
            for (final value in event.input) {
              _require(value is Map<String, dynamic>, 'Unusable failed input.');
              final raw = value! as Map<String, dynamic>;
              final saved = savedResults[raw['call_id']];
              _require(
                raw['type'] == 'function_call_output' &&
                    saved != null &&
                    raw['output'] == saved.toJson()['output'],
                'Failed input does not match a saved result.',
              );
              uncommitted.add(raw);
            }
          } else if (event case ResponsesStreamEvent(
            event: ResponseCompletedEvent(:final response),
          )) {
            _require(response.id == responseId, 'Unexpected completion.');
            completedId = response.id;
          } else if (event is ResponsesErrorEvent) {
            throw StateError(
              'A generic WebSocket error interrupted the response.',
            );
          } else if (event case ResponsesStreamEvent(
            event: ResponseFailedEvent() || ResponseIncompleteEvent(),
          )) {
            throw StateError(
              'Response ended unsuccessfully before all acknowledgments.',
            );
          }
          // An acknowledgment can follow response.completed. Keep reading both.
          if (completedId != null && pending == 0) {
            finished = true;
            break;
          }
        }
        _require(
          finished,
          'Socket ended before completion and every acknowledgment.',
        );
        if (uncommitted.isEmpty) break;
        previousResponseId = completedId;
        // This is an explicit application choice after known failed injection.
        // Preserve raw future metadata; do not reparse through a lossy Item codec.
        nextInput = ResponseInput.fromOutputItems(uncommitted);
      }
      _require(
        creates == 2 &&
            socket.creates.length == 2 &&
            socket.injections.length == 2,
        'Unexpected extra submission or continuation.',
      );
      _require(
        toolExecutions == 2 &&
            savedResults.length == 2 &&
            acknowledgments == 2 &&
            owningAgents.containsAll(['/root', '/root/sub']) &&
            hostedActionsObserved == 1,
        'Tools reran or agent ownership/acknowledgments were lost.',
      );
      final continuation = socket.creates.last;
      _require(
        continuation['previous_response_id'] == 'resp_initial' &&
            continuation['stream_id'] == 'planner' &&
            (continuation['input'] as List).length == 1 &&
            ((continuation['input'] as List).single as Map)['future'] != null,
        'Continuation lost ancestry, lane or raw future metadata.',
      );
      _require(
        socket.injections.every((frame) => !frame.containsKey('stream_id')),
        'Injection must target the response rather than a lane.',
      );
      print(
        'Two developer tools ran once; hosted actions stayed server-owned.',
      );
      print('Two injections, two acknowledgments, one explicit continuation.');
      print('Completion-before-ack race passed locally; no API charges.');
    } finally {
      try {
        await connection.close();
        await connection.done;
      } finally {
        await reader.cancel();
      }
    }
  } finally {
    client.close();
  }
}

CreateResponseRequest _request(
  ResponseInput input, {
  String? previousResponseId,
}) => CreateResponseRequest(
  model: 'gpt-6.1-sol',
  input: input,
  previousResponseId: previousResponseId,
  multiAgent: const MultiAgentConfig(enabled: true),
  tools: [
    ResponseTool.function(
      name: 'get_fixture_status',
      parameters: {'type': 'object', 'properties': <String, dynamic>{}},
    ),
  ],
  store: false,
);

void _require(bool condition, String message) {
  if (!condition) throw StateError(message);
}

class _LocalInjectionSocket implements ws.WebSocket {
  final StreamController<ws.WebSocketEvent> _events = StreamController();
  final List<Map<String, dynamic>> creates = [];
  final List<Map<String, dynamic>> injections = [];
  var _sequence = 0;

  void _emit(Map<String, dynamic> event) => _events.add(
    ws.TextDataReceived(
      jsonEncode({
        ...event,
        'sequence_number': ++_sequence,
        'stream_id': 'planner',
      }),
    ),
  );

  @override
  Stream<ws.WebSocketEvent> get events => _events.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String text) {
    final frame = jsonDecode(text) as Map<String, dynamic>;
    if (frame['type'] == 'response.create') {
      creates.add(frame);
      final id = creates.length == 1 ? 'resp_initial' : 'resp_continuation';
      _emit({
        'type': 'response.created',
        'response': _response(id, 'in_progress'),
      });
      if (creates.length == 1) {
        _emit({
          'type': 'response.output_item.done',
          'output_index': 0,
          'agent': {'agent_name': '/root'},
          'item': {
            'type': 'multi_agent_call',
            'id': 'hosted_item',
            'call_id': 'hosted_call',
            'action': 'spawn_agent',
            'arguments': '{}',
            'agent': {'agent_name': '/root'},
          },
        });
        for (final (index, agent) in ['/root', '/root/sub'].indexed) {
          _emit({
            'type': 'response.output_item.done',
            'output_index': index + 1,
            'agent': {'agent_name': agent},
            'item': {
              'type': 'function_call',
              'id': 'function_$index',
              'call_id': 'call_$index',
              'name': 'get_fixture_status',
              'arguments': '{}',
              'status': 'completed',
              'agent': {'agent_name': agent},
            },
          });
        }
      } else {
        _emit({
          'type': 'response.completed',
          'response': _response(id, 'completed'),
        });
      }
    } else if (frame['type'] == 'response.inject') {
      injections.add(frame);
      if (injections.length == 1) {
        _emit({
          'type': 'response.inject.created',
          'response_id': 'resp_initial',
        });
      } else {
        _emit({
          'type': 'response.completed',
          'response': _response('resp_initial', 'completed'),
        });
        _emit({
          'type': 'response.inject.failed',
          'response_id': 'resp_initial',
          'input': [
            ...[
              for (final item in frame['input'] as List)
                {
                  ...item as Map<String, dynamic>,
                  'future': {
                    'retained': [true, 7],
                  },
                },
            ],
          ],
          'error': {
            'code': 'response_already_completed',
            'message': 'Local response completed.',
          },
        });
      }
    }
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

Map<String, dynamic> _response(String id, String status) => {
  'id': id,
  'object': 'response',
  'created_at': 1,
  'status': status,
  'model': 'gpt-6.1-sol',
  'output': <dynamic>[],
  'access_programs': null,
  'error': null,
  'incomplete_details': null,
  'instructions': null,
  'tools': <dynamic>[],
  'parallel_tool_calls': true,
  'metadata': <String, dynamic>{},
  'tool_choice': 'auto',
  'temperature': 1.0,
  'top_p': 1.0,
};
