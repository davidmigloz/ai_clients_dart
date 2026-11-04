// ignore_for_file: avoid_print

/// Offline warmup, explicit tool continuation, fork barrier and compact replay.
/// Synthetic HTTP and WebSocket peers require no API key and incur no charges.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:web_socket/web_socket.dart' as ws;

Future<void> main() async {
  final socket = _LocalSocket();
  final httpClient = MockClient((request) async {
    if (request.method != 'POST' ||
        request.url.path != '/v1/responses/compact') {
      throw StateError('Unexpected local HTTP request');
    }
    return http.Response(
      jsonEncode({
        'id': 'compact_fixture',
        'object': 'response.compaction',
        'created_at': 1,
        'output': [
          {
            'type': 'compaction',
            'id': 'cmp_fixture',
            'encrypted_content': 'synthetic',
          },
        ],
        'usage': {'input_tokens': 1, 'output_tokens': 1, 'total_tokens': 2},
      }),
      200,
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(baseUrl: 'https://example.invalid/v1'),
    httpClient: httpClient,
  );
  try {
    final connection = await client.responses.connect(
      connector: (uri, {headers}) async => socket,
    );
    final session = ResponsesWebSocketSession(
      connection,
      limits: const ResponsesWebSocketLimits(
        maxLanes: 3,
        maxEventsPerLane: 32,
        maxEvents: 64,
        maxBytesPerLane: 64 * 1024,
        maxBytes: 128 * 1024,
        maxResponseBytes: 64 * 1024,
      ),
    );
    try {
      final planner = session.lane('planner')
        ..create(_request('Prepare planner context'), generate: false);
      final warmup = await planner.getFinalResponse();
      planner.create(_request('Check status', previous: warmup.id));
      final toolTurn = await planner.getFinalResponse();

      // The application validates and executes tools explicitly. This synthetic
      // fixture allows only one known, harmless function and empty arguments.
      final call = toolTurn.functionCalls.single;
      if (call.name != 'status' || call.argumentsMap.isNotEmpty) {
        throw StateError('Unexpected synthetic tool call');
      }
      planner.create(
        CreateResponseRequest(
          model: 'gpt-6-sol',
          previousResponseId: toolTurn.id,
          store: false,
          input: ResponseInput.items([
            FunctionCallOutputItem.string(
              callId: call.callId,
              output: 'healthy',
            ),
            ConfigurationUpdateItem(
              text: ConfigurationUpdateText(
                format: const JsonSchemaFormat(
                  name: 'status',
                  schema: {
                    'type': 'object',
                    'properties': {
                      'status': {'type': 'string'},
                    },
                    'required': ['status'],
                    'additionalProperties': false,
                  },
                  strict: true,
                ),
              ),
            ),
          ]),
        ),
      );
      final parent = await planner.getFinalResponse();

      final critic = session.lane('critic')
        ..create(_request('Review status', previous: parent.id));
      // With store:false, let the fork load its cached parent before advancing
      // the source lane. A stream ID routes events; it does not select ancestry.
      while (true) {
        final event = await critic.receive();
        if (event.type == 'response.in_progress') break;
        if (event.type == 'response.failed' ||
            event.type == 'response.incomplete' ||
            event.type == 'response.completed') {
          throw StateError('Fork ended before its in-progress barrier');
        }
      }
      planner.create(_request('Add next steps', previous: parent.id));
      await Future.wait([
        critic.getFinalResponse(),
        planner.getFinalResponse(),
      ]);

      // Standalone compaction returns a window, not a continuation response ID.
      // Replay every returned item intact, append the next input, and start a
      // new chain. Server-side context_management instead continues normally.
      final compacted = await client.responses.compact(
        const CompactResponseRequest(
          model: 'gpt-6-sol',
          input: ResponseInput.text('Synthetic complete conversation history'),
        ),
      );
      planner.create(
        CreateResponseRequest(
          model: 'gpt-6-sol',
          store: false,
          input: ResponseInput.fromOutputItems([
            ...compacted.output.map((item) => item.toJson()),
            MessageItem.userText('Continue').toJson(),
          ]),
        ),
      );
      final replayed = await planner.getFinalResponse();
      if (socket.sends != 6 || replayed.id != 'resp_replayed') {
        throw StateError('Unexpected local replay result');
      }
      print(
        'Warmup, tool continuation, fork barrier and compact replay passed.',
      );
      print(
        'Six local create frames and one synthetic compact request; API cost: 0.',
      );
    } finally {
      await session.close();
      await connection.close();
      await connection.done;
    }
  } finally {
    client.close();
    httpClient.close();
  }
}

CreateResponseRequest _request(String input, {String? previous}) =>
    CreateResponseRequest(
      model: 'gpt-6-sol',
      input: ResponseInput.text(input),
      previousResponseId: previous,
      store: false,
    );

class _LocalSocket implements ws.WebSocket {
  final _controller = StreamController<ws.WebSocketEvent>();
  int sends = 0;
  @override
  Stream<ws.WebSocketEvent> get events => _controller.stream;
  @override
  String get protocol => '';

  @override
  void sendText(String text) {
    final frame = jsonDecode(text) as Map<String, dynamic>;
    if (frame['type'] != 'response.create' ||
        frame.containsKey('stream') ||
        frame.containsKey('background')) {
      throw StateError('Unexpected frame');
    }
    sends++;
    final lane = frame['stream_id'] as String;
    switch (sends) {
      case 1:
        if (frame['generate'] != false) throw StateError('Expected warmup');
        _terminal(lane, 'resp_warm');
      case 2:
        _checkParent(frame, 'resp_warm');
        _emit({
          'type': 'response.output_item.done',
          'stream_id': lane,
          'output_index': 0,
          'item': {
            'type': 'function_call',
            'id': 'fc_fixture',
            'call_id': 'call_fixture',
            'name': 'status',
            'arguments': '{}',
            'status': 'completed',
          },
        });
        // Omitting output exercises fallback to the finalized function call.
        _terminal(lane, 'resp_tool', omitOutput: true);
      case 3:
        _checkParent(frame, 'resp_tool');
        final input = frame['input'] as List;
        if ((input.first as Map)['call_id'] != 'call_fixture' ||
            (input.last as Map)['text'] == null) {
          throw StateError('Lost tool/config input');
        }
        _terminal(lane, 'resp_parent');
      case 4:
        _checkParent(frame, 'resp_parent');
        if (lane != 'critic') throw StateError('Expected fork lane');
        _emit({
          'type': 'response.in_progress',
          'stream_id': lane,
          'response': _response('resp_fork', status: 'in_progress'),
        });
      case 5:
        _checkParent(frame, 'resp_parent');
        _terminal('planner', 'resp_next');
        _terminal('critic', 'resp_fork');
      case 6:
        final input = frame['input'] as List;
        if (frame.containsKey('previous_response_id') ||
            input.length != 2 ||
            (input.first as Map)['encrypted_content'] != 'synthetic') {
          throw StateError(
            'Compacted history must be replayed intact on a new chain',
          );
        }
        _terminal(lane, 'resp_replayed');
      default:
        throw StateError('Unexpected extra create');
    }
  }

  void _checkParent(Map<String, dynamic> frame, String id) {
    if (frame['previous_response_id'] != id) throw StateError('Wrong ancestry');
  }

  void _terminal(String lane, String id, {bool omitOutput = false}) => _emit({
    'type': 'response.completed',
    'stream_id': lane,
    'response': _response(id)
      ..removeWhere((key, _) => omitOutput && key == 'output'),
  });
  Map<String, dynamic> _response(String id, {String status = 'completed'}) => {
    'id': id,
    'object': 'response',
    'created_at': 1,
    'status': status,
    'output': <dynamic>[],
  };
  void _emit(Map<String, dynamic> json) =>
      _controller.add(ws.TextDataReceived(jsonEncode(json)));
  @override
  void sendBytes(Uint8List bytes) => throw UnsupportedError('Text only');
  @override
  Future<void> close([int? code, String? reason]) async {
    if (_controller.isClosed) return;
    _controller.add(ws.CloseReceived(code ?? 1000, reason ?? ''));
    unawaited(_controller.close());
  }
}
