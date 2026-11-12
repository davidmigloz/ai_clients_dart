import 'dart:async';
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

final _request = MessageCreateRequest(
  model: 'claude-sonnet-5-5',
  maxTokens: 64,
  messages: [InputMessage.user('Hello')],
);
const Map<String, Object> _error = {
  'type': 'invalid_request_error',
  'message': 'Fixture failure',
  'details': {'error_code': 'fixture_code', 'future': true},
};
const _timeout = Duration(seconds: 2);

void main() {
  for (final (header, body, expected) in <(String?, String?, String?)>[
    ('req_header', 'req_body', 'req_header'),
    (null, 'req_body', 'req_body'),
    (null, null, null),
  ]) {
    test(
      'in-band error retains provider ID and cancels its body ($expected)',
      () async {
        final transport = _StalledStream(header: header, body: body);
        final client = AnthropicClient(
          config: const AnthropicConfig(
            defaultHeaders: {'X-Request-ID': 'client-only'},
          ),
          httpClient: transport,
        );
        addTearDown(client.close);
        addTearDown(transport.dispose);

        final events = await client.messages
            .createStream(_request)
            .toList()
            .timeout(_timeout);
        final error = events.single as ErrorEvent;
        expect(error.requestId, expected);
        expect(error.errorCode, 'fixture_code');
        expect(error.details?['future'], isTrue);
        expect(error.toJson(), {
          'type': 'error',
          'error': _error,
          'request_id': body,
        });
        expect(error.responseMetadata?.statusCode, 200);
        expect(error.responseMetadata?.bodyRequestId, body);
        expect(error.responseMetadata?.requestId, expected);
        expect(error.responseMetadata?.headers, isNot(contains('set-cookie')));
        expect(error.responseMetadata?.bodyExcerpt, isEmpty);
        expect(transport.request?.headers['X-Request-ID'], 'client-only');
        await transport.canceled.future.timeout(_timeout);
        expect(transport.cancelCount, 1);
        expect(transport.closeCount, 0);
      },
    );
  }

  test(
    'finalMessage retains the provider error and cannot return partial output',
    () async {
      final transport = _StalledStream(body: 'req_failed');
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      addTearDown(transport.dispose);
      await expectLater(
        client.messages.createStream(_request).finalMessage().timeout(_timeout),
        throwsA(
          isA<MessageStreamFailure>()
              .having((e) => e.requestId, 'provider ID', 'req_failed')
              .having((e) => e.event.errorCode, 'error code', 'fixture_code'),
        ),
      );
      await transport.canceled.future.timeout(_timeout);
    },
  );

  test(
    'future SSE events round-trip without disrupting a completed message',
    () async {
      const future = {
        'type': 'new_event',
        'unknown': {
          'list': [1, 2],
        },
      };
      final transport = MockHttpClient()
        ..queueStreamingResponse(
          MockResponses.streamingEvents(text: 'Done')..insert(1, future),
        )
        ..queueStreamingResponse(
          MockResponses.streamingEvents(text: 'Done')..insert(1, future),
        );
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      final events = await client.messages.createStream(_request).toList();
      final event = events[1] as UnknownMessageStreamEvent;
      expect(event.type, 'new_event');
      expect(event.toJson(), future);
      expect(event, MessageStreamEvent.fromJson(future));
      expect(event.hashCode, MessageStreamEvent.fromJson(future).hashCode);
      expect(
        (await client.messages.createStream(_request).finalMessage()).text,
        'Done',
      );
    },
  );

  test(
    'batch JSONL retains unknown results and nested error envelopes',
    () async {
      const error = {
        'type': 'error',
        'request_id': 'req_batch_item',
        'error': _error,
      };
      const unknown = {
        'type': 'future_result',
        'extra': {
          'values': [true],
        },
      };
      const entries = [
        {'custom_id': 'first', 'result': unknown},
        {
          'custom_id': 'second',
          'result': {'type': 'errored', 'error': error},
        },
        {
          'custom_id': 'third',
          'result': {
            'type': 'errored',
            'error': {'type': 'api_error', 'message': 'Legacy'},
          },
        },
      ];
      final transport = MockHttpClient()
        ..queueResponse(
          MockResponse(
            body: entries.map(jsonEncode).join('\n'),
            statusCode: 200,
            headers: {'content-type': 'application/x-jsonl'},
            isStreaming: true,
          ),
        );
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      final records = await client.messages.batches.results('batch-1').toList();
      expect(records.map((r) => r.toJson()), entries);
      final future = records[0].result as UnknownBatchResult;
      expect(future.type, 'future_result');
      expect(future, BatchResult.fromJson(unknown));
      expect(future.hashCode, BatchResult.fromJson(unknown).hashCode);
      final failed = (records[1].result as BatchResultErrored).error;
      expect(failed.type, 'invalid_request_error');
      expect(failed.requestId, 'req_batch_item');
      expect(failed.errorCode, 'fixture_code');
      expect(failed, BatchError.fromJson(error));
      expect(failed.hashCode, BatchError.fromJson(error).hashCode);
      final legacy = (records[2].result as BatchResultErrored).error;
      expect(legacy, const BatchError(type: 'api_error', message: 'Legacy'));
    },
  );
}

class _StalledStream extends http.BaseClient {
  _StalledStream({this.header, this.body});

  final String? header;
  final String? body;
  final canceled = Completer<void>();
  int cancelCount = 0;
  int closeCount = 0;
  http.BaseRequest? request;

  late final controller = StreamController<List<int>>(
    onCancel: () {
      cancelCount++;
      if (!canceled.isCompleted) canceled.complete();
    },
  );

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    this.request = request;
    final event = jsonEncode({
      'type': 'error',
      'error': _error,
      'request_id': body,
    });
    controller.add(utf8.encode('event: error\ndata: $event\n\n'));
    return http.StreamedResponse(
      controller.stream,
      200,
      headers: {
        'content-type': 'text/event-stream',
        'Request-Id': ?header,
        'set-cookie': 'fixture-sensitive-cookie',
      },
    );
  }

  @override
  void close() => closeCount++;

  void dispose() => unawaited(controller.close());
}
