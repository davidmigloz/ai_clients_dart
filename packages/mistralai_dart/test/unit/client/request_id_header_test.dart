@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('X-Request-ID header on streaming requests', () {
    late http.BaseRequest captured;

    MistralClient createClient({
      bool sendRequestIdHeader = false,
      Map<String, String> defaultHeaders = const {},
      int responseStatus = 200,
      http.ClientException? transportError,
    }) {
      final mockClient = MockClient.streaming((request, _) async {
        captured = request;
        if (transportError != null) {
          throw transportError;
        }
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              responseStatus >= 400
                  ? '{"message":"service unavailable"}'
                  : 'data: [DONE]\n\n',
            ),
          ),
          responseStatus,
          headers: {'content-type': 'text/event-stream'},
        );
      });
      addTearDown(mockClient.close);
      final client = MistralClient(
        config: MistralConfig(
          authProvider: const ApiKeyProvider('test-key'),
          defaultHeaders: defaultHeaders,
          sendRequestIdHeader: sendRequestIdHeader,
        ),
        httpClient: mockClient,
      );
      addTearDown(client.close);
      return client;
    }

    List<LogRecord> captureStreamingLogs() {
      final previousLevel = Logger.root.level;
      Logger.root.level = Level.ALL;
      final records = <LogRecord>[];
      final subscription = Logger.root.onRecord
          .where((record) => record.loggerName == 'Mistral.HTTP')
          .listen(records.add);
      addTearDown(() async {
        await subscription.cancel();
        Logger.root.level = previousLevel;
      });
      return records;
    }

    final streams = <String, Future<void> Function(MistralClient)>{
      'chat.createStream': (client) async {
        await client.chat
            .createStream(
              request: ChatCompletionRequest(
                model: 'mistral-small-latest',
                messages: [ChatMessage.user('Hello')],
              ),
            )
            .drain<void>();
      },
      'audio.transcriptions.createStream (multipart)': (client) async {
        await client.audio.transcriptions
            .createStream(
              request: const TranscriptionRequest(
                model: 'voxtral-mini-latest',
                fileBytes: [1, 2, 3],
                fileName: 'clip.wav',
              ),
            )
            .drain<void>();
      },
    };

    for (final MapEntry(key: name, value: stream) in streams.entries) {
      group(name, () {
        test('does not send X-Request-ID by default', () async {
          await stream(createClient());

          expect(captured.headers['Authorization'], 'Bearer test-key');
          expect(captured.headers.containsKey('X-Request-ID'), isFalse);
        });

        test('sends X-Request-ID when sendRequestIdHeader is true', () async {
          await stream(createClient(sendRequestIdHeader: true));

          expect(captured.headers['X-Request-ID'], isNotEmpty);
        });

        for (final sendRequestIdHeader in [false, true]) {
          test('preserves caller-supplied X-Request-ID '
              '(sendRequestIdHeader: $sendRequestIdHeader)', () async {
            await stream(
              createClient(
                sendRequestIdHeader: sendRequestIdHeader,
                defaultHeaders: const {'X-Request-ID': 'caller-id'},
              ),
            );

            expect(captured.headers['X-Request-ID'], 'caller-id');
          });
        }

        for (final transportFailure in [false, true]) {
          final failureName = transportFailure ? 'transport' : 'HTTP';
          for (final callerSuppliedId in [false, true]) {
            final idName = callerSuppliedId ? 'caller-supplied' : 'generated';
            test('correlates $failureName failures with the $idName log ID '
                'when sendRequestIdHeader is false', () async {
              final records = captureStreamingLogs();
              final transportError = transportFailure
                  ? http.ClientException('connection failed')
                  : null;
              final errorMatcher = transportFailure
                  ? same(transportError)
                  : isA<ApiException>().having(
                      (error) => error.statusCode,
                      'statusCode',
                      503,
                    );
              final client = createClient(
                responseStatus: 503,
                transportError: transportError,
                defaultHeaders: callerSuppliedId
                    ? const {'x-request-id': 'caller-id'}
                    : const {},
              );

              await expectLater(stream(client), throwsA(errorMatcher));

              if (callerSuppliedId) {
                expect(captured.headers['x-request-id'], 'caller-id');
              } else {
                expect(captured.headers.containsKey('X-Request-ID'), isFalse);
              }
              expect(records, hasLength(2));
              final requestLog = records.singleWhere(
                (record) => record.message.startsWith('REQUEST ['),
              );
              final errorLog = records.singleWhere(
                (record) => record.message.startsWith('STREAM ERROR ['),
              );
              final requestId = RegExp(
                r'^REQUEST \[([^\]]+)\]',
              ).firstMatch(requestLog.message)!.group(1)!;
              expect(requestId, isNotEmpty);
              if (callerSuppliedId) {
                expect(requestId, 'caller-id');
              }
              expect(requestLog.level, Level.INFO);
              expect(errorLog.level, Level.SEVERE);
              expect(
                errorLog.message,
                startsWith('STREAM ERROR [$requestId] '),
              );
              expect(errorLog.error, errorMatcher);
            });
          }
        }
      });
    }
  });
}
