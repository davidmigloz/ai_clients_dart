import 'dart:async';
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

final _request = MessageCreateRequest(
  model: 'claude-sonnet-5-5',
  maxTokens: 32,
  messages: [InputMessage.user('fixture')],
);
const _short = Duration(milliseconds: 500);
const Map<String, Object> _knownError = {
  'type': 'error',
  'request_id': 'req_failed',
  'error': {'type': 'overloaded_error', 'message': 'Fixture failure'},
};

void main() {
  test('legacy flat generic error remains decodable from JSONL', () async {
    const legacy = BatchError(type: 'error', message: 'Legacy failure');
    final transport = MockHttpClient()
      ..queueResponse(
        MockResponse(
          body: jsonEncode({
            'custom_id': 'fixture',
            'result': {'type': 'errored', 'error': legacy.toJson()},
          }),
          statusCode: 200,
          headers: {'content-type': 'application/x-jsonl'},
          isStreaming: true,
        ),
      );
    final client = AnthropicClient(httpClient: transport);
    addTearDown(client.close);
    final item = await client.messages.batches
        .results('msgbatch_fixture')
        .single;
    expect((item.result as BatchResultErrored).error, legacy);
  });

  for (final body in [
    {'message': 'Gateway error', 'request_id': 'req_gateway'},
    {
      'type': 'gateway_error',
      'message': 'Gateway error',
      'request_id': 'req_gateway',
    },
    {'type': 'error', 'error': 'Gateway error', 'request_id': 'req_gateway'},
    {
      'type': 'error',
      'error': {'type': 42, 'message': 'Gateway error'},
      'request_id': 'req_gateway',
    },
  ]) {
    test('named SSE error preserves ID and terminates ($body)', () async {
      final transport = _Stalled(jsonEncode(body));
      addTearDown(transport.dispose);
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      final event = await client.messages
          .createStream(_request)
          .single
          .timeout(_short);
      expect(event, isA<ErrorEvent>());
      final error = event as ErrorEvent;
      expect(error.requestId, 'req_gateway');
      expect(error.message, 'Gateway error');
      expect(error.toJson(), body);
      await transport.canceled.future.timeout(_short);
    });
  }

  for (final wire in ['', '[DONE]']) {
    test('named SSE error with "$wire" is terminal', () async {
      final transport = _Stalled(wire, requestId: 'req_header');
      addTearDown(transport.dispose);
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      final error =
          await client.messages.createStream(_request).single.timeout(_short)
              as ErrorEvent;
      expect(error.requestId, 'req_header');
      expect(error.errorType, 'stream_error');
      await transport.canceled.future.timeout(_short);
    });
  }

  for (final (name, complete)
      in <(String, Future<Object?> Function(Stream<MessageStreamEvent>))>[
        ('finalMessage', (stream) => stream.finalMessage()),
        ('collectText', (stream) => stream.collectText()),
        ('textDeltas', (stream) => stream.textDeltas().toList()),
        ('thinkingDeltas', (stream) => stream.thinkingDeltas().toList()),
        ('inputJsonDeltas', (stream) => stream.inputJsonDeltas().toList()),
        ('stopReason', (stream) => stream.stopReason),
      ]) {
    test('$name rejects a provider error after partial text', () async {
      final events =
          MockResponses.streamingEvents(
              text: 'partial',
            ).takeWhile((event) => event['type'] != 'message_stop').toList()
            ..add(_knownError);
      final transport = MockHttpClient()..queueStreamingResponse(events);
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      await expectLater(
        complete(client.messages.createStream(_request)),
        throwsA(
          isA<MessageStreamFailure>().having(
            (e) => e.requestId,
            'request ID',
            'req_failed',
          ),
        ),
      );
    });
  }

  test(
    'malformed named delta cannot be hidden by a later message_stop',
    () async {
      final events = MockResponses.streamingEvents(text: 'partial');
      final wire = StringBuffer();
      for (final event in events) {
        if (event['type'] == 'content_block_stop') {
          wire.write(
            'event: content_block_delta\n'
            'data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":\n\n',
          );
        }
        wire
          ..write('event: ${event['type'] as String}\n')
          ..write('data: ${jsonEncode(event)}\n\n');
      }
      final transport = MockClient(
        (_) async => http.Response(
          wire.toString(),
          200,
          headers: {'content-type': 'text/event-stream'},
        ),
      );
      addTearDown(transport.close);
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      await expectLater(
        client.messages.createStream(_request).finalMessage(),
        throwsA(isA<FormatException>()),
      );
    },
  );

  for (final prefix in [
    [
      {'type': 'message_stop'},
    ],
    MockResponses.streamingEvents(text: 'previous'),
  ]) {
    test(
      'an earlier message_stop cannot complete a later message (${prefix.length})',
      () async {
        final events = [
          ...prefix,
          ...MockResponses.streamingEvents(
            text: 'partial',
          ).takeWhile((event) => event['type'] != 'message_stop'),
        ];
        final transport = MockHttpClient()..queueStreamingResponse(events);
        final client = AnthropicClient(httpClient: transport);
        addTearDown(client.close);
        await expectLater(
          client.messages.createStream(_request).finalMessage(),
          throwsStateError,
        );
      },
    );
  }

  test(
    'raw terminal event releases body while caller pauses on the event',
    () async {
      final transport = _Stalled(jsonEncode(_knownError));
      addTearDown(transport.dispose);
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      final seen = Completer<void>();
      late final StreamSubscription<MessageStreamEvent> listener;
      listener = client.messages.createStream(_request).listen((event) {
        expect(event, isA<ErrorEvent>());
        listener.pause();
        seen.complete();
      });
      addTearDown(listener.cancel);
      await seen.future.timeout(_short);
      await transport.canceled.future.timeout(_short);
    },
  );
}

class _Stalled extends http.BaseClient {
  _Stalled(this.body, {this.requestId});
  final String body;
  final String? requestId;
  final canceled = Completer<void>();
  late final stream = StreamController<List<int>>(onCancel: canceled.complete);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    stream.add(utf8.encode('event: error\ndata: $body\n\n'));
    return http.StreamedResponse(
      stream.stream,
      200,
      headers: {'request-id': ?requestId},
    );
  }

  void dispose() => unawaited(stream.close());
}
