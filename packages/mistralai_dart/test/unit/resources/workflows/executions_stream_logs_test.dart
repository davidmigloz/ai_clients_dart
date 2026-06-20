@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ExecutionsResource.streamLogs', () {
    Uri? capturedUrl;

    MistralClient streamingClient(List<String> sseLines) {
      final mockClient = MockClient.streaming((request, _) async {
        capturedUrl = request.url;
        return http.StreamedResponse(
          Stream.fromIterable(sseLines.map(utf8.encode)),
          200,
        );
      });

      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    String logEvent(String body) =>
        'event: log\n'
        'data: ${jsonEncode({
          'timestamp': '2030-01-01T00:00:00Z',
          'trace_id': 'trace-1',
          'span_id': 'span-1',
          'severity_text': 'INFO',
          'body': body,
          'log_attributes': {'k': 'v'},
        })}\n\n';

    test('parses log events into ExecutionLogRecord', () async {
      final client = streamingClient([
        logEvent('first'),
        logEvent('second'),
        'data: [DONE]\n\n',
      ]);
      addTearDown(client.close);

      final records = await client.workflows.executions
          .streamLogs(executionId: 'exec-1', runId: 'run-1', after: 'now')
          .toList();

      expect(records, hasLength(2));
      expect(records.first.body, 'first');
      expect(records.last.body, 'second');
      expect(capturedUrl?.path, '/v1/workflows/executions/exec-1/logs/stream');
      expect(capturedUrl?.queryParameters['run_id'], 'run-1');
      expect(capturedUrl?.queryParameters['after'], 'now');
    });

    test('error event raises StreamException', () async {
      final errorPayload = jsonEncode({'error': 'internal', 'reason': 'boom'});
      final client = streamingClient([
        'event: error\ndata: $errorPayload\n\n',
        'data: [DONE]\n\n',
      ]);
      addTearDown(client.close);

      await expectLater(
        client.workflows.executions.streamLogs(executionId: 'exec-1').toList(),
        throwsA(isA<StreamException>()),
      );
    });

    test('streamLogs guards against a closed client eagerly', () {
      final client = streamingClient(['data: [DONE]\n\n'])..close();

      expect(
        () => client.workflows.executions.streamLogs(executionId: 'exec-1'),
        throwsStateError,
      );
    });
  });
}
