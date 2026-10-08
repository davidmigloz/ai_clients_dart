// ignore_for_file: avoid_print

/// Warm a lane, run two lanes and continue using the actual previous response ID.
///
/// The connector injects a local socket. No API key, external server, model
/// generation or API charges are required. The same public API supports native
/// authenticated sockets and explicit headerless browser proxies.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:web_socket/web_socket.dart' as ws;

Future<void> main() async {
  final socket = _LocalSocket();
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
    Future<String> completed(String lane) async {
      while (await reader.moveNext()) {
        final message = reader.current;
        if (message is ResponsesErrorEvent) {
          throw StateError('Unexpected local error message.');
        }
        if (message case ResponsesStreamEvent(
          streamId: final streamId,
          event: ResponseCompletedEvent(:final response),
        )) {
          if (streamId != lane) throw StateError('Unexpected local lane.');
          return response.id;
        }
      }
      throw StateError('Local connection closed before response completion.');
    }

    try {
      connection.create(
        const CreateResponseRequest(
          model: 'gpt-6-sol',
          input: ResponseInput.text('Prepare the planner context.'),
          store: false,
        ),
        streamId: 'planner',
        generate: false,
      );
      final warmId = await completed('planner');
      connection
        ..create(
          CreateResponseRequest(
            model: 'gpt-6-sol',
            input: const ResponseInput.text('Draft the plan.'),
            previousResponseId: warmId,
            store: false,
          ),
          streamId: 'planner',
        )
        ..create(
          const CreateResponseRequest(
            model: 'gpt-6-sol',
            input: ResponseInput.text('Research the risks.'),
            store: false,
          ),
          streamId: 'research',
        );
      final latest = <String, String>{};
      while (latest.length < 2 && await reader.moveNext()) {
        if (reader.current case ResponsesStreamEvent(
          streamId: final lane?,
          event: ResponseCompletedEvent(:final response),
        )) {
          latest[lane] = response.id;
        }
      }
      if (latest.length != 2 || connection.isClosed) {
        throw StateError('Expected two completed lanes on an open connection.');
      }
      connection.create(
        CreateResponseRequest(
          model: 'gpt-6-sol',
          input: const ResponseInput.text('Add rollback steps.'),
          previousResponseId: latest['planner'],
          store: false,
        ),
        streamId: 'planner',
      );
      final continuedId = await completed('planner');
      if (socket.sends != 4 || continuedId != 'resp_planner_next') {
        throw StateError('Unexpected local continuation.');
      }
      print('Warm-up, two lanes and incremental continuation passed.');
      print('Four local create frames; no API charges.');
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

class _LocalSocket implements ws.WebSocket {
  final _controller = StreamController<ws.WebSocketEvent>();
  int sends = 0;

  @override
  Stream<ws.WebSocketEvent> get events => _controller.stream;
  @override
  String get protocol => '';

  @override
  void sendText(String text) {
    final json = jsonDecode(text) as Map<String, dynamic>;
    sends++;
    if (json['type'] != 'response.create' ||
        json.containsKey('stream') ||
        json.containsKey('background')) {
      throw StateError('Unexpected local create frame.');
    }
    switch (sends) {
      case 1:
        if (json['stream_id'] != 'planner' || json['generate'] != false) {
          throw StateError('Expected local warm-up.');
        }
        _complete('planner', 'resp_warm');
      case 2:
        if (json['stream_id'] != 'planner' ||
            json['previous_response_id'] != 'resp_warm') {
          throw StateError('Warm-up ancestry was not preserved.');
        }
      case 3:
        if (json['stream_id'] != 'research' ||
            json.containsKey('previous_response_id')) {
          throw StateError('Expected an independent research lane.');
        }
        // Interleaved lanes can complete in either order.
        _complete('research', 'resp_research');
        _complete('planner', 'resp_planner');
      case 4:
        if (json['stream_id'] != 'planner' ||
            json['previous_response_id'] != 'resp_planner') {
          throw StateError('Continuation ancestry was not preserved.');
        }
        _complete('planner', 'resp_planner_next');
      default:
        throw StateError('Unexpected extra local create.');
    }
  }

  void _complete(String lane, String id) => _controller.add(
    ws.TextDataReceived(
      jsonEncode({
        'type': 'response.completed',
        'stream_id': lane,
        'sequence_number': sends,
        'response': {
          'id': id,
          'object': 'response',
          'created_at': 1,
          'status': 'completed',
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
