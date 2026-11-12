import 'dart:async';
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _key = 'synthetic-stream-fixture-credential+/=';

void main() {
  test('typed JSONL message error does not echo the API key', () async {
    final transport = MockClient((request) async {
      expect(request.headers['x-api-key'], _key);
      return http.Response(
        jsonEncode({
          'custom_id': 'fixture',
          'result': {
            'type': 'succeeded',
            'message': {'id': 'msg_fixture', 'type': 'message', 'role': _key},
          },
        }),
        200,
        headers: {'content-type': 'application/x-jsonl'},
      );
    });
    final client = AnthropicClient.withApiKey(_key, httpClient: transport);
    addTearDown(client.close);
    await expectLater(
      client.batches.results('batch_fixture').drain<void>(),
      throwsA(
        isA<FormatException>().having(
          (error) => error.toString(),
          'safe batch diagnostic',
          isNot(contains(_key)),
        ),
      ),
    );
  });

  test(
    'typed JSONL cast terminates stalled body and preserves valid content',
    () async {
      final canceled = Completer<void>();
      final body = StreamController<List<int>>(onCancel: canceled.complete);
      addTearDown(body.close);
      final client = AnthropicClient.withApiKey(
        _key,
        httpClient: _BatchTransport(body.stream),
      );
      addTearDown(client.close);
      final items = <BatchIndividualResponse>[];
      final errors = <Object>[];
      final done = Completer<void>();
      final subscription = client.batches
          .results('batch_fixture')
          .listen(items.add, onError: errors.add, onDone: done.complete);
      addTearDown(subscription.cancel);
      String record(Object content) => jsonEncode({
        'custom_id': 'fixture',
        'result': {
          'type': 'succeeded',
          'message': {
            'id': 'msg_fixture',
            'role': 'assistant',
            'content': content,
            'model': 'claude-fixture',
            'usage': {'input_tokens': 1, 'output_tokens': 1},
          },
        },
      });
      final valid = record([
        {'type': 'text', 'text': _key},
      ]);
      body.add(utf8.encode('$valid\n${record(_key)}\n$valid\n'));

      await done.future.timeout(const Duration(seconds: 5));
      await canceled.future.timeout(const Duration(seconds: 5));
      expect((items.single.result as BatchResultSucceeded).message.text, _key);
      expect(errors.single, anyOf(isA<TypeError>(), isA<FormatException>()));
      expect(errors.single.toString(), isNot(contains(_key)));
    },
  );

  for (final thread in [false, true]) {
    test('typed Managed Agent stream error is safe (thread=$thread)', () async {
      final encoded = Uri.encodeComponent(_key);
      final transport = MockClient((request) async {
        expect(request.headers['x-api-key'], _key);
        final event = jsonEncode({
          'type': 'agent.message',
          'id': 'evt_fixture',
          'content': <Object>[],
          'processed_at': encoded,
        });
        return http.Response(
          'event: agent.message\ndata: $event\n\n',
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      });
      final client = AnthropicClient.withApiKey(_key, httpClient: transport);
      addTearDown(client.close);
      final stream = thread
          ? client.sessions
                .threads('session_fixture')
                .events('thread_fixture')
                .stream()
          : client.sessions.events('session_fixture').stream();
      await expectLater(
        stream.drain<void>(),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'safe event diagnostic',
            isNot(contains(encoded)),
          ),
        ),
      );
    });
  }
}

final class _BatchTransport extends http.BaseClient {
  _BatchTransport(this.body);

  final Stream<List<int>> body;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    expect(request.headers['x-api-key'], _key);
    return http.StreamedResponse(
      body,
      200,
      headers: {'content-type': 'application/x-jsonl'},
    );
  }
}
