// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  AnthropicClient? client;

  setUpAll(() {
    apiKey = Platform.environment['ANTHROPIC_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('ANTHROPIC_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = AnthropicClient(
        config: AnthropicConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Message Batches API - Integration', () {
    test(
      'creates and retrieves a batch',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a batch with a simple request
        final batch = await client!.messages.batches.create(
          MessageBatchCreateRequest(
            requests: [
              BatchRequestItem(
                customId: 'test-request-1',
                params: MessageCreateRequest(
                  model: 'claude-3-5-haiku-20241022',
                  maxTokens: 50,
                  messages: [InputMessage.user('What is 1+1?')],
                ),
              ),
            ],
          ),
        );

        expect(batch.id, isNotEmpty);
        expect(batch.id, startsWith('msgbatch_'));
        expect(batch.processingStatus, ProcessingStatus.inProgress);
        expect(batch.requestCounts.processing, greaterThanOrEqualTo(0));

        // Retrieve the same batch
        final retrieved = await client!.messages.batches.retrieve(batch.id);
        expect(retrieved.id, batch.id);
        expect(retrieved.createdAt, isNotNull);
        expect(retrieved.expiresAt, isNotNull);

        // Clean up - cancel the batch
        try {
          await client!.messages.batches.cancel(batch.id);
        } catch (_) {
          // Batch may have already completed
        }
      },
    );

    test(
      'lists batches',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.messages.batches.list(limit: 5);

        // Should have pagination info
        expect(response.hasMore, isA<bool>());

        // Each batch should have required fields
        for (final batch in response.data) {
          expect(batch.id, isNotEmpty);
          expect(batch.processingStatus, isA<ProcessingStatus>());
          expect(batch.requestCounts, isNotNull);
          expect(batch.createdAt, isNotNull);
        }
      },
    );

    test(
      'handles batch not found error',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        await expectLater(
          client!.messages.batches.retrieve('msgbatch_nonexistent'),
          throwsA(isA<ApiException>()),
        );
      },
    );

    test(
      'creates batch with multiple requests',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final batch = await client!.messages.batches.create(
          MessageBatchCreateRequest(
            requests: [
              BatchRequestItem(
                customId: 'math-1',
                params: MessageCreateRequest(
                  model: 'claude-3-5-haiku-20241022',
                  maxTokens: 50,
                  messages: [InputMessage.user('What is 2+2?')],
                ),
              ),
              BatchRequestItem(
                customId: 'math-2',
                params: MessageCreateRequest(
                  model: 'claude-3-5-haiku-20241022',
                  maxTokens: 50,
                  messages: [InputMessage.user('What is 3+3?')],
                ),
              ),
              BatchRequestItem(
                customId: 'math-3',
                params: MessageCreateRequest(
                  model: 'claude-3-5-haiku-20241022',
                  maxTokens: 50,
                  messages: [InputMessage.user('What is 4+4?')],
                ),
              ),
            ],
          ),
        );

        expect(batch.id, isNotEmpty);
        // Total requests should be 3
        final total =
            batch.requestCounts.processing +
            batch.requestCounts.succeeded +
            batch.requestCounts.errored +
            batch.requestCounts.canceled +
            batch.requestCounts.expired;
        expect(total, 3);

        // Clean up
        try {
          await client!.messages.batches.cancel(batch.id);
        } catch (_) {
          // Batch may have already completed
        }
      },
    );
  });
}
