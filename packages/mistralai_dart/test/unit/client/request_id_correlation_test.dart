import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Request ID correlation without a wire header', () {
    List<LogRecord> captureLogs() {
      final previousLevel = Logger.root.level;
      Logger.root.level = Level.ALL;
      final records = <LogRecord>[];
      final subscription = Logger.root.onRecord
          .where((record) => record.loggerName == 'mistralai_dart')
          .listen(records.add);
      addTearDown(() async {
        await subscription.cancel();
        Logger.root.level = previousLevel;
      });
      return records;
    }

    String expectCorrelatedErrorLogs(List<LogRecord> records) {
      final requestLogs = records
          .where((record) => record.message.contains(' --> '))
          .toList();
      expect(requestLogs, hasLength(1));
      final match = RegExp(
        r'^\[([^\]]+)\] --> ',
      ).firstMatch(requestLogs.single.message);
      expect(match, isNotNull);
      final requestId = match!.group(1)!;
      expect(requestId, isNotEmpty);

      final errorLogs = records
          .where((record) => record.message.contains(' <-- ERROR '))
          .toList();
      expect(errorLogs, hasLength(1));
      expect(errorLogs.single.message, startsWith('[$requestId] <-- ERROR '));
      return requestId;
    }

    MistralClient createClient(http.Client httpClient) {
      addTearDown(httpClient.close);
      final client = MistralClient(
        config: const MistralConfig(
          authProvider: ApiKeyProvider('test-key'),
          retryPolicy: RetryPolicy(
            maxRetries: 1,
            initialDelay: Duration.zero,
            maxDelay: Duration.zero,
            jitter: 0,
          ),
        ),
        httpClient: httpClient,
      );
      addTearDown(client.close);
      return client;
    }

    final requests = <String, Future<void> Function(MistralClient)>{
      'chat.create (JSON)': (client) async {
        await client.chat.create(
          request: ChatCompletionRequest(
            model: 'mistral-small-latest',
            messages: [ChatMessage.user('Hello')],
          ),
        );
      },
      'files.upload (replayable multipart)': (client) async {
        await client.files.upload(
          bytes: [0, 128, 255],
          fileName: 'clip.wav',
          purpose: FilePurpose.audio,
        );
      },
    };

    for (final MapEntry(key: name, value: request) in requests.entries) {
      test(
        '$name preserves the logged ID in an HTTP error after retry',
        () async {
          final records = captureLogs();
          var attempts = 0;
          final client = createClient(
            MockClient((request) async {
              attempts++;
              expect(request.headers.containsKey('X-Request-ID'), isFalse);
              return http.Response('{"message":"rate limited"}', 429);
            }),
          );

          try {
            await request(client);
            fail('Expected a rate-limit exception after exhausting retries');
          } on RateLimitException catch (error) {
            expect(error.statusCode, 429);
            expect(
              error.requestMetadata?.correlationId,
              expectCorrelatedErrorLogs(records),
            );
          }
          expect(attempts, 2);
        },
      );
    }

    test('cancellation before a retry preserves the logged ID', () async {
      final records = captureLogs();
      final abort = Completer<void>();
      var attempts = 0;
      final client = createClient(
        MockClient((request) async {
          attempts++;
          expect(request.headers.containsKey('X-Request-ID'), isFalse);
          // The completed trigger wins over the zero-duration retry timer,
          // exercising cancellation in the retry delay without a sleep.
          abort.complete();
          return http.Response('{"message":"rate limited"}', 429);
        }),
      );

      // Endpoint methods do not expose abortTrigger; use the client's actual
      // configured chain through its resource to exercise cancellation.
      try {
        await client.models.interceptorChain.execute(
          http.Request('GET', Uri.parse('https://api.mistral.ai/v1/models')),
          abortTrigger: abort.future,
        );
        fail('Expected cancellation to prevent the rate-limit retry');
      } on AbortedException catch (error) {
        expect(error.stage, AbortionStage.beforeRequest);
        expect(error.correlationId, expectCorrelatedErrorLogs(records));
      }
      expect(attempts, 1);
    });
  });
}
