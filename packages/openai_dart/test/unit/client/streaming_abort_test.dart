import 'dart:async'
    show
        Completer,
        Stream,
        StreamController,
        TimeoutException,
        runZonedGuarded,
        unawaited;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Streaming Abort', () {
    test('stream without abortTrigger uses shared client', () async {
      // Create a controller that we can use to control when data arrives
      final streamController = StreamController<List<int>>();
      var requestReceived = false;

      final mockClient = MockClient.streaming((request, _) async {
        requestReceived = true;
        return http.StreamedResponse(streamController.stream, 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      final events = <dynamic>[];

      // Start streaming (no abort trigger - uses shared mock client)
      final stream = client.chat.completions.createStream(
        ChatCompletionCreateRequest(
          model: 'gpt-4',
          messages: [ChatMessage.user('Hello')],
        ),
      );

      // Subscribe to the stream
      final subscription = stream.listen(events.add, onError: (_) {});

      // Wait for request to be sent
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(requestReceived, isTrue);

      // Send some data and close
      streamController
        ..add(utf8.encode('data: {"choices":[]}\n\n'))
        ..add(utf8.encode('data: [DONE]\n\n'));
      await streamController.close();

      // Wait for stream to process
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();
      client.close();
    });

    test('abortTrigger parameter is accepted by streaming methods', () async {
      // This test verifies that the abortTrigger parameter is accepted by
      // all streaming methods. Each method gets its own mock client with
      // appropriate response format.

      // Chat completions mock
      final chatMockClient = MockClient.streaming((request, _) async {
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode('data: {"choices":[]}\n\n'),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          200,
        );
      });

      final chatClient = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: chatMockClient,
      );

      await chatClient.chat.completions
          .createStream(
            ChatCompletionCreateRequest(
              model: 'gpt-4',
              messages: [ChatMessage.user('Hello')],
            ),
          )
          .drain<void>();

      chatClient.close();

      // Responses mock (different format)
      final responsesMockClient = MockClient.streaming((request, _) async {
        const responseData =
            'data: {"type":"response.completed","response": '
            '{"id":"resp_123","object":"response","created_at":1234567890,"model":"gpt-4",'
            '"status":"completed","output":[],"parallel_tool_calls":true,"tool_choice":"auto"}}\n\n';
        return http.StreamedResponse(
          Stream.fromIterable([utf8.encode(responseData)]),
          200,
        );
      });

      final responsesClient = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: responsesMockClient,
      );

      await responsesClient.responses
          .createStream(
            const CreateResponseRequest(
              model: 'gpt-4',
              input: ResponseInput.text('Hello'),
            ),
          )
          .drain<void>();

      responsesClient.close();

      // Completions mock
      final completionsMockClient = MockClient.streaming((request, _) async {
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode(
              'data: {"id":"cmpl-test","object":"text_completion","created":1234567890,"model":"gpt-3.5-turbo-instruct","choices":[{"text":"Hello","index":0,"logprobs":null,"finish_reason":"stop"}]}\n\n',
            ),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          200,
        );
      });

      final completionsClient = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: completionsMockClient,
      );

      await completionsClient.completions
          .createStream(
            const CompletionRequest(
              model: 'gpt-3.5-turbo-instruct',
              prompt: CompletionPrompt.text('Hello'),
            ),
          )
          .drain<void>();

      completionsClient.close();

      // Verify the type signature accepts abortTrigger (compile-time check)
      final abortTrigger = Completer<void>().future;

      // These would be compile errors if abortTrigger parameter didn't exist
      // The functions aren't called, just referenced to verify they compile
      void verifyApiAcceptsAbortTrigger(OpenAIClient c) {
        c.chat.completions.createStream(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
          abortTrigger: abortTrigger,
        );

        c.responses.createStream(
          const CreateResponseRequest(
            model: 'gpt-4',
            input: ResponseInput.text('Hello'),
          ),
          abortTrigger: abortTrigger,
        );

        c.completions.createStream(
          const CompletionRequest(
            model: 'gpt-3.5-turbo-instruct',
            prompt: CompletionPrompt.text('Hello'),
          ),
          abortTrigger: abortTrigger,
        );
      }

      // Not called, just here for compile-time verification
      // ignore: unused_local_variable
      final _ = verifyApiAcceptsAbortTrigger;
    });

    test('stream continues normally without abort', () async {
      final mockClient = MockClient.streaming((request, _) async {
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode(
              'data: {"choices":[{"delta":{"content":"Hello"}}]}\n\n',
            ),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      final events = <ChatStreamEvent>[];

      // Stream without abort trigger - should complete normally
      await client.chat.completions
          .createStream(
            ChatCompletionCreateRequest(
              model: 'gpt-4',
              messages: [ChatMessage.user('Hello')],
            ),
          )
          .forEach(events.add);

      expect(events, isNotEmpty);
      client.close();
    });

    group('with streamClientFactory', () {
      test('uses injected factory for streaming with abortTrigger', () async {
        var factoryCalled = false;
        var clientClosed = false;

        final streamController = StreamController<List<int>>();

        final mockStreamClient = MockClient.streaming((request, _) async {
          return http.StreamedResponse(streamController.stream, 200);
        });

        // Create a wrapper that tracks close() calls
        final trackingClient = _TrackingClient(
          mockStreamClient,
          onClose: () => clientClosed = true,
        );

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          streamClientFactory: () {
            factoryCalled = true;
            return trackingClient;
          },
        );

        final neverAbort = Completer<void>().future;

        // Use chat.completions.createStream with abortTrigger to exercise
        // the streaming resource path that uses streamClientFactory
        final stream = client.chat.completions.createStream(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
          abortTrigger: neverAbort,
        );

        // Subscribe to the stream to trigger the request
        final events = <ChatStreamEvent>[];
        final subscription = stream.listen(events.add, onError: (_) {});

        // Wait for request to be sent
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(factoryCalled, isTrue, reason: 'Factory should be called');

        // Send data and close the source stream
        streamController
          ..add(utf8.encode('data: {"choices":[]}\n\n'))
          ..add(utf8.encode('data: [DONE]\n\n'));
        await streamController.close();

        // Wait for stream to process
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await subscription.cancel();

        // Client should be closed after stream completes
        expect(clientClosed, isTrue, reason: 'Client should close on done');

        client.close();
      });

      test('streaming client closes on normal stream completion', () async {
        // Verifies that the dedicated streaming client is properly closed
        // when the stream completes normally (all data consumed).
        var clientClosed = false;

        final mockStreamClient = MockClient.streaming((request, _) async {
          return http.StreamedResponse(
            Stream.fromIterable([
              utf8.encode('data: {"choices":[]}\n\n'),
              utf8.encode('data: [DONE]\n\n'),
            ]),
            200,
          );
        });

        final trackingClient = _TrackingClient(
          mockStreamClient,
          onClose: () => clientClosed = true,
        );

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          streamClientFactory: () => trackingClient,
        );

        final neverAbort = Completer<void>().future;

        // Consume the entire stream
        await client.chat.completions
            .createStream(
              ChatCompletionCreateRequest(
                model: 'gpt-4',
                messages: [ChatMessage.user('Hello')],
              ),
              abortTrigger: neverAbort,
            )
            .drain<void>();

        // Client should be closed after stream completes
        expect(
          clientClosed,
          isTrue,
          reason: 'Client should close on normal completion',
        );

        client.close();
      });

      test('streaming client closes on stream error', () async {
        var clientClosed = false;

        final streamController = StreamController<List<int>>();

        final mockStreamClient = MockClient.streaming((request, _) async {
          return http.StreamedResponse(streamController.stream, 200);
        });

        final trackingClient = _TrackingClient(
          mockStreamClient,
          onClose: () => clientClosed = true,
        );

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          streamClientFactory: () => trackingClient,
        );

        final neverAbort = Completer<void>().future;

        final stream = client.chat.completions.createStream(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
          abortTrigger: neverAbort,
        );

        // Collect events
        final events = <ChatStreamEvent>[];
        Object? caughtError;
        final completer = Completer<void>();

        // Subscribe and wait for request to be sent
        stream.listen(
          events.add,
          onError: (Object e) {
            caughtError = e;
          },
          onDone: completer.complete,
          cancelOnError: false,
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Send some data then error
        streamController
          ..add(utf8.encode('data: {"choices":[]}\n\n'))
          ..addError(Exception('Stream error'));

        // Wait for stream to process the error and complete
        await streamController.close();
        await completer.future;

        // Client should be closed after error
        expect(clientClosed, isTrue, reason: 'Client should close on error');
        expect(caughtError, isA<Exception>());

        client.close();
      });

      test('wrapped stream closes on source error without onDone', () async {
        // This test verifies that when the source stream errors without
        // subsequently calling onDone, the wrapped stream controller is
        // still properly closed (which fires onDone on the wrapped stream).
        var clientClosed = false;
        var wrappedStreamReceivedDone = false;

        final streamController = StreamController<List<int>>();

        final mockStreamClient = MockClient.streaming((request, _) async {
          return http.StreamedResponse(streamController.stream, 200);
        });

        final trackingClient = _TrackingClient(
          mockStreamClient,
          onClose: () => clientClosed = true,
        );

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          streamClientFactory: () => trackingClient,
        );

        final neverAbort = Completer<void>().future;

        final stream = client.chat.completions.createStream(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
          abortTrigger: neverAbort,
        );

        Object? caughtError;
        final doneCompleter = Completer<void>();

        // Subscribe to the stream and wait for request
        stream.listen(
          (_) {},
          onError: (Object e) {
            caughtError = e;
          },
          onDone: () {
            wrappedStreamReceivedDone = true;
            doneCompleter.complete();
          },
          cancelOnError: false,
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Send an error WITHOUT closing the source stream afterward
        // This simulates a network error that doesn't properly clean up
        streamController.addError(Exception('Network error'));

        // The wrapped stream should still receive onDone because
        // our onError handler closes the controller
        await doneCompleter.future.timeout(
          const Duration(seconds: 2),
          onTimeout: () => throw TimeoutException(
            'Wrapped stream did not receive onDone after source error',
          ),
        );

        expect(caughtError, isA<Exception>());
        expect(
          wrappedStreamReceivedDone,
          isTrue,
          reason: 'Wrapped stream should receive onDone after error',
        );
        expect(
          clientClosed,
          isTrue,
          reason: 'Client should be closed after error',
        );

        // Clean up source controller
        await streamController.close();
        client.close();
      });

      test(
        'onError cancels subscription to prevent post-error data delivery',
        () async {
          // This test verifies that when the source stream emits an error and
          // then continues emitting data (allowed with cancelOnError: false),
          // our onError handler cancels the subscription to prevent data from
          // being pushed into a closed controller.
          var clientClosed = false;
          var subscriptionCancelled = false;

          // Create a source stream that will emit error then more data
          final sourceController = StreamController<List<int>>(
            onCancel: () {
              subscriptionCancelled = true;
            },
          );

          final mockStreamClient = MockClient.streaming((request, _) async {
            return http.StreamedResponse(sourceController.stream, 200);
          });

          final trackingClient = _TrackingClient(
            mockStreamClient,
            onClose: () => clientClosed = true,
          );

          final client = OpenAIClient(
            config: const OpenAIConfig(
              authProvider: ApiKeyProvider('sk-test-key'),
            ),
            streamClientFactory: () => trackingClient,
          );

          final neverAbort = Completer<void>().future;

          final stream = client.chat.completions.createStream(
            ChatCompletionCreateRequest(
              model: 'gpt-4',
              messages: [ChatMessage.user('Hello')],
            ),
            abortTrigger: neverAbort,
          );

          Object? caughtError;
          final doneCompleter = Completer<void>();

          // Track any data received after the error
          var errorReceived = false;
          final dataAfterError = <ChatStreamEvent>[];
          stream.listen(
            (data) {
              if (errorReceived) {
                dataAfterError.add(data);
              }
            },
            onError: (Object e) {
              errorReceived = true;
              caughtError = e;
            },
            onDone: doneCompleter.complete,
            cancelOnError: false,
          );

          await Future<void>.delayed(const Duration(milliseconds: 50));

          // Emit some data, then error, then more data
          sourceController.add(utf8.encode('data: {"choices":[]}\n\n'));
          await Future<void>.delayed(const Duration(milliseconds: 10));

          sourceController.addError(Exception('Stream error'));
          await Future<void>.delayed(const Duration(milliseconds: 10));

          // Try to emit more data after the error
          // This should NOT reach the wrapped stream because the subscription
          // should have been cancelled in onError
          sourceController
            ..add(utf8.encode('data: {"choices":[]}\n\n'))
            ..add(utf8.encode('data: [DONE]\n\n'));

          // Close the source to complete the test
          await sourceController.close();

          // Wait for wrapped stream to complete
          await doneCompleter.future.timeout(
            const Duration(seconds: 2),
            onTimeout: () =>
                throw TimeoutException('Wrapped stream did not complete'),
          );

          // Verify expected behavior
          expect(caughtError, isA<Exception>());
          expect(
            subscriptionCancelled,
            isTrue,
            reason: 'Subscription should be cancelled in onError',
          );
          expect(
            dataAfterError,
            isEmpty,
            reason: 'No data should be received after error',
          );
          expect(clientClosed, isTrue);

          client.close();
        },
      );

      test('withApiKey factory accepts streamClientFactory', () async {
        var factoryCalled = false;

        final streamController = StreamController<List<int>>();

        final mockStreamClient = MockClient.streaming((request, _) async {
          return http.StreamedResponse(streamController.stream, 200);
        });

        final client = OpenAIClient.withApiKey(
          'sk-test-key',
          streamClientFactory: () {
            factoryCalled = true;
            return mockStreamClient;
          },
        );

        final neverAbort = Completer<void>().future;

        final stream = client.chat.completions.createStream(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
          abortTrigger: neverAbort,
        );

        // Subscribe to trigger the request
        final events = <ChatStreamEvent>[];
        final subscription = stream.listen(events.add, onError: (_) {});

        // Wait for request to be sent
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(factoryCalled, isTrue, reason: 'Factory should be called');

        // Complete stream
        streamController
          ..add(utf8.encode('data: {"choices":[]}\n\n'))
          ..add(utf8.encode('data: [DONE]\n\n'));
        await streamController.close();

        await Future<void>.delayed(const Duration(milliseconds: 50));
        await subscription.cancel();

        client.close();
      });

      test('abortTrigger completion closes dedicated client', () async {
        // When abortTrigger fires, the dedicated streaming client is closed.
        // This terminates the underlying connection. The stream will end
        // (possibly with an error) and the dedicated client is cleaned up.
        var clientClosed = false;

        // Use a source stream controller that simulates a real connection
        // by sending an error when the client is closed
        final sourceController = StreamController<List<int>>();

        final mockStreamClient = MockClient.streaming((request, _) async {
          return http.StreamedResponse(sourceController.stream, 200);
        });

        final trackingClient = _TrackingClient(
          mockStreamClient,
          onClose: () {
            clientClosed = true;
            // Simulate connection reset when client is closed
            if (!sourceController.isClosed) {
              sourceController.addError(
                Exception('Connection closed by client'),
              );
              unawaited(sourceController.close());
            }
          },
        );

        final abortCompleter = Completer<void>();

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          streamClientFactory: () => trackingClient,
        );

        final doneCompleter = Completer<void>();

        // Subscribe to trigger the request
        client.chat.completions
            .createStream(
              ChatCompletionCreateRequest(
                model: 'gpt-4',
                messages: [ChatMessage.user('Hello')],
              ),
              abortTrigger: abortCompleter.future,
            )
            .listen(
              (_) {},
              onError: (_) {},
              onDone: () {
                if (!doneCompleter.isCompleted) doneCompleter.complete();
              },
            );

        // Wait for request to be sent
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Trigger abort
        abortCompleter.complete();

        // Wait for stream to complete after abort
        await doneCompleter.future.timeout(
          const Duration(seconds: 2),
          onTimeout: () =>
              throw TimeoutException('Stream did not complete after abort'),
        );

        // Client should be closed due to abort trigger
        expect(
          clientClosed,
          isTrue,
          reason: 'Client should close when abort is triggered',
        );

        client.close();
      });
    });

    test(
      'abortTrigger error is handled gracefully without unhandled exception',
      () async {
        // When abortTrigger completes with an error, it should be treated as
        // an abort signal without surfacing as an unhandled async exception.

        var unhandledError = false;

        await runZonedGuarded(
          () async {
            final abortCompleter = Completer<void>();

            // Use a source stream controller that errors when client closes
            final sourceController = StreamController<List<int>>();

            final mockStreamClient = MockClient.streaming((request, _) async {
              return http.StreamedResponse(sourceController.stream, 200);
            });

            // Close the source when the mock client is closed
            final closingClient = _TrackingClient(
              mockStreamClient,
              onClose: () {
                if (!sourceController.isClosed) {
                  sourceController.addError(Exception('Connection closed'));
                  unawaited(sourceController.close());
                }
              },
            );

            final client = OpenAIClient(
              config: const OpenAIConfig(
                authProvider: ApiKeyProvider('sk-test-key'),
              ),
              streamClientFactory: () => closingClient,
            );

            final doneCompleter = Completer<void>();

            // Subscribe
            client.chat.completions
                .createStream(
                  ChatCompletionCreateRequest(
                    model: 'gpt-4',
                    messages: [ChatMessage.user('Hello')],
                  ),
                  abortTrigger: abortCompleter.future,
                )
                .listen(
                  (_) {},
                  onError: (_) {},
                  onDone: () {
                    if (!doneCompleter.isCompleted) doneCompleter.complete();
                  },
                );
            await Future<void>.delayed(const Duration(milliseconds: 50));

            // Complete abort with error
            abortCompleter.completeError(StateError('Abort trigger errored'));

            // Wait for stream to complete
            await doneCompleter.future.timeout(
              const Duration(seconds: 2),
              onTimeout: () => throw TimeoutException(
                'Stream did not complete after abort error',
              ),
            );

            // Clean up
            client.close();

            // Give time for any async errors to surface
            await Future<void>.delayed(const Duration(milliseconds: 100));
          },
          (error, stack) {
            // This handler catches unhandled async errors in the zone
            unhandledError = true;
          },
        );

        expect(
          unhandledError,
          isFalse,
          reason: 'No unhandled errors should occur',
        );
      },
    );
  });
}

/// A wrapper around an HTTP client that tracks close() calls.
class _TrackingClient extends http.BaseClient {
  _TrackingClient(this._inner, {required this.onClose});

  final http.Client _inner;
  final void Function() onClose;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request);
  }

  @override
  void close() {
    onClose();
    _inner.close();
  }
}
