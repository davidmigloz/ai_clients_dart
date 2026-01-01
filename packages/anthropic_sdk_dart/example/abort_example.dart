// ignore_for_file: avoid_print
import 'dart:async';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Abort/cancellation example.
///
/// This example demonstrates:
/// - Cancelling requests using abortTrigger
/// - Handling AbortedException
/// - Timing out long-running requests
///
/// Note: The abortTrigger is a `Future<void>` that, when completed,
/// signals the request should be cancelled.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Manual cancellation using Completer
    print('=== Manual Cancellation ===');
    final abortCompleter = Completer<void>();

    // Start a request that would take some time
    final requestFuture = client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 4096,
        messages: [
          InputMessage.user(
            'Write a very long detailed essay about the history of computing.',
          ),
        ],
      ),
      abortTrigger: abortCompleter.future,
    );

    // Cancel after 100ms
    await Future<void>.delayed(const Duration(milliseconds: 100));
    print('Aborting request...');
    abortCompleter.complete();

    try {
      await requestFuture;
      print('Request completed (not aborted)');
    } on AbortedException catch (e) {
      print('Request was aborted: ${e.message}');
      print('Abortion stage: ${e.stage}');
    }

    // Example 2: Timeout using abort
    print('\n=== Request Timeout ===');
    final timeoutCompleter = Completer<void>();

    // Set a timeout
    final timer = Timer(const Duration(milliseconds: 500), () {
      print('Timeout reached, aborting...');
      if (!timeoutCompleter.isCompleted) {
        timeoutCompleter.complete();
      }
    });

    try {
      final response = await client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 100,
          messages: [InputMessage.user('Say hello in 5 different languages.')],
        ),
        abortTrigger: timeoutCompleter.future,
      );
      timer.cancel();
      print('Response: ${response.text}');
    } on AbortedException catch (e) {
      print('Request timed out: ${e.message}');
    }

    // Example 3: Cancel streaming request
    print('\n=== Cancel Streaming ===');
    final streamCompleter = Completer<void>();

    final stream = client.messages.createStream(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        messages: [InputMessage.user('Write a poem about the ocean.')],
      ),
      abortTrigger: streamCompleter.future,
    );

    var eventCount = 0;
    try {
      await for (final event in stream) {
        eventCount++;
        if (event case ContentBlockDeltaEvent(:final delta)) {
          if (delta is TextDelta) {
            print(delta.text);
          }
        }

        // Cancel after receiving 10 events
        if (eventCount >= 10) {
          print('\n[Cancelling stream after 10 events]');
          streamCompleter.complete();
        }
      }
    } on AbortedException catch (e) {
      print('Stream aborted: ${e.message}');
    }

    // Example 4: Graceful handling with fallback
    print('\n=== Graceful Fallback ===');
    // Complete immediately to simulate already-cancelled request
    final fallbackCompleter = Completer<void>()..complete();

    try {
      await client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 100,
          messages: [InputMessage.user('Hello')],
        ),
        abortTrigger: fallbackCompleter.future,
      );
    } on AbortedException {
      print('Request was cancelled, using fallback response.');
      print('Fallback: The request was cancelled before completion.');
    }
  } finally {
    client.close();
  }
}
