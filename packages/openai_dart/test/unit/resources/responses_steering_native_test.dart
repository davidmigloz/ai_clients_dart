import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/responses_websocket_events.dart';

void main() {
  test(
    'public native upgrade sends steer once and reads original plus automatic successor',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final frames = <Map<String, dynamic>>[];
      final peers = <WebSocket>[];
      final serverReader = server.listen((request) async {
        expect(request.uri.path, '/v1/responses');
        final peer = await WebSocketTransformer.upgrade(request);
        peers.add(peer);
        peer.listen((Object? data) {
          final frame = jsonDecode(data! as String) as Map<String, dynamic>;
          frames.add(frame);
          if (frame['type'] == 'response.create') {
            peer.add(
              jsonEncode(
                _responseEvent(
                  'response.created',
                  'resp_parent',
                  lane: 'planner',
                ),
              ),
            );
          } else {
            peer
              ..add(jsonEncode(_accepted('steer_saved', lane: 'planner')))
              ..add(
                jsonEncode(
                  _responseEvent(
                    'response.incomplete',
                    'resp_parent',
                    lane: 'planner',
                  ),
                ),
              )
              ..add(
                jsonEncode(
                  _responseEvent(
                    'response.created',
                    'resp_successor',
                    lane: 'planner',
                  ),
                ),
              )
              ..add(
                jsonEncode(
                  _responseEvent(
                    'response.completed',
                    'resp_successor',
                    lane: 'planner',
                  ),
                ),
              );
          }
        });
      });
      final client = OpenAIClient(
        config: OpenAIConfig(baseUrl: 'http://127.0.0.1:${server.port}/v1'),
      );
      ResponsesConnection? connection;
      StreamIterator<ResponsesServerEvent>? reader;
      try {
        connection = await client.responses.connect();
        reader = StreamIterator(connection.events);
        connection.create(_initialRequest, streamId: 'planner');
        expect(await reader.moveNext(), isTrue);
        expect(reader.current.type, 'response.created');
        connection.steer(
          previousResponseId: 'resp_parent',
          input: const ResponsesSteerInput.text('Keep it small.'),
        );
        final types = <String>[];
        while (await reader.moveNext().timeout(const Duration(seconds: 2))) {
          types.add(reader.current.type);
          if (reader.current case ResponsesStreamEvent(
            event: ResponseCompletedEvent(:final response),
          )) {
            if (response.id == 'resp_successor') break;
          }
        }
        expect(types, [
          'response.steer.accepted',
          'response.incomplete',
          'response.created',
          'response.completed',
        ]);
        expect(frames.length, 2);
        expect(frames.last, {
          'type': 'response.steer',
          'previous_response_id': 'resp_parent',
          'input': 'Keep it small.',
        });
      } finally {
        await connection?.close();
        await reader?.cancel();
        client.close();
        for (final peer in peers) {
          await peer.close();
        }
        await serverReader.cancel();
        await server.close(force: true);
      }
    },
  );
}

const _initialRequest = CreateResponseRequest(
  model: 'gpt-6-sol',
  input: ResponseInput.text('Local initial input'),
);

Map<String, dynamic> _accepted(String id, {String? lane}) => {
  'type': 'response.steer.accepted',
  'sequence_number': 2,
  'steer': {'id': id, 'previous_response_id': 'resp_parent'},
  'stream_id': ?lane,
};

Map<String, dynamic> _responseEvent(
  String type,
  String id, {
  String? lane = 'planner',
}) {
  final fixture = responsesWebSocketEventFixtures().firstWhere(
    (item) => item['type'] == type,
  );
  return {
    ...fixture,
    'stream_id': ?lane,
    'response': {
      ...(fixture['response'] as Map<String, dynamic>),
      'id': id,
      if (type == 'response.incomplete')
        'incomplete_details': {'reason': 'steered'},
    },
  };
}
