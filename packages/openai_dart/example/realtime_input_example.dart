/// Selects an acknowledged item reference plus new typed Realtime input.
/// Uses an in-memory peer; no API key or external API request is needed.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;
import 'package:web_socket/web_socket.dart';

Future<void> main() async {
  final client = OpenAIClient(
    httpClient: MockClient((_) async => throw StateError('No HTTP expected.')),
  );
  RealtimeConnection? connection;
  StreamSubscription<realtime.RealtimeEvent>? tap;
  try {
    final peer = _Peer();
    connection = await client.realtime.connect(
      model: 'gpt-realtime-2.1',
      connector: (uri, {headers}) async => peer,
    );
    final text = StringBuffer();
    final errors = <Object>[];
    tap = connection.events.listen((event) {
      if (event is realtime.ResponseTextDeltaEvent) text.write(event.delta);
      if (event is realtime.ErrorEvent) errors.add(event);
    }, onError: errors.add);

    // Wait for an actual server-assigned item ID before referencing history.
    final added = connection.events.firstWhere(
      (event) => event is realtime.ConversationItemAddedEvent,
    );
    connection.createItem({
      'type': 'message',
      'role': 'user',
      'content': [
        {'type': 'input_text', 'text': 'I prefer Spanish.'},
      ],
    });
    final stored = (await added) as realtime.ConversationItemAddedEvent;
    final done = connection.events.firstWhere(
      (event) => event is realtime.ResponseDoneEvent,
    );
    connection.createResponse(
      conversation: 'none',
      outputModalities: ['text'],
      input: [
        realtime.RealtimeResponseInputItem.fromJson({
          'type': 'item_reference',
          'id': stored.item['id'],
        }),
        realtime.RealtimeResponseInputItem.fromJson(const {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': 'Greet me briefly.'},
          ],
        }),
      ],
    );
    await done;
    if (text.toString() != 'Hola.' || errors.isNotEmpty) {
      throw StateError('Unexpected synthetic response.');
    }
    stdout
      ..writeln('Selected acknowledged history and new typed input: $text')
      ..writeln('Zero external API requests.');
  } finally {
    await tap?.cancel();
    await connection?.close();
    client.close();
  }
}

class _Peer implements WebSocket {
  final _events = StreamController<WebSocketEvent>(sync: true);
  void _emit(Map<String, dynamic> event) =>
      _events.add(TextDataReceived(jsonEncode(event)));
  @override
  void sendText(String text) {
    final command = jsonDecode(text) as Map<String, dynamic>;
    switch (command['type']) {
      case 'conversation.item.create':
        _emit({
          'type': 'conversation.item.added',
          'event_id': 'added',
          'previous_item_id': null,
          'item': {
            ...command['item'] as Map<String, dynamic>,
            'id': 'item_previous',
            'status': 'completed',
          },
        });
      case 'response.create':
        final response = command['response'] as Map<String, dynamic>;
        final input = response['input'] as List<dynamic>;
        if ((input.first as Map<String, dynamic>)['id'] != 'item_previous' ||
            response['conversation'] != 'none') {
          throw StateError('Unexpected synthetic input context.');
        }
        _emit({
          'type': 'response.output_text.delta',
          'event_id': 'delta',
          'response_id': 'response_fixture',
          'item_id': 'output_fixture',
          'output_index': 0,
          'content_index': 0,
          'delta': 'Hola.',
        });
        _emit({
          'type': 'response.done',
          'event_id': 'done',
          'response': {
            'object': 'realtime.response',
            'id': 'response_fixture',
            'status': 'completed',
            'output': <Map<String, dynamic>>[],
            'conversation_id': null,
            'output_modalities': ['text'],
            'usage': null,
          },
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
