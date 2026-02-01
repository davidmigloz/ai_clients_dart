// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  OpenAIClient? client;

  setUpAll(() {
    apiKey = Platform.environment['OPENAI_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('OPENAI_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = OpenAIClient(
        config: OpenAIConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Batches API - Integration', () {
    test(
      'lists batches',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final batches = await client!.batches.list();

        expect(batches.object, 'list');
        expect(batches.data, isA<List<Batch>>());
        // hasMore is always present (may be true or false)
        expect(batches.hasMore, isA<bool>());
      },
    );

    test(
      'creates and retrieves a batch',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a JSONL input file for batch processing
        // Each line is a request object with custom_id, method, url, body
        final requests = [
          {
            'custom_id': 'req-1',
            'method': 'POST',
            'url': '/v1/chat/completions',
            'body': {
              'model': 'gpt-4o-mini',
              'messages': [
                {'role': 'user', 'content': 'Say hello'},
              ],
              'max_tokens': 10,
            },
          },
          {
            'custom_id': 'req-2',
            'method': 'POST',
            'url': '/v1/chat/completions',
            'body': {
              'model': 'gpt-4o-mini',
              'messages': [
                {'role': 'user', 'content': 'Say goodbye'},
              ],
              'max_tokens': 10,
            },
          },
        ];

        final jsonlContent = requests.map(jsonEncode).join('\n');
        final bytes = utf8.encode(jsonlContent);

        // Upload the input file
        final uploadedFile = await client!.files.upload(
          bytes: bytes,
          filename: 'batch_test_input.jsonl',
          purpose: FilePurpose.batch,
        );

        expect(uploadedFile.id, isNotEmpty);
        expect(uploadedFile.purpose, FilePurpose.batch);

        final fileId = uploadedFile.id;
        String? batchId;

        try {
          // Create a batch
          final batch = await client!.batches.create(
            CreateBatchRequest(
              inputFileId: fileId,
              endpoint: BatchEndpoint.chatCompletions,
              completionWindow: CompletionWindow.hours24,
              metadata: const {'test': 'integration'},
            ),
          );

          batchId = batch.id;

          expect(batch.id, isNotEmpty);
          expect(batch.object, 'batch');
          expect(batch.inputFileId, fileId);
          expect(batch.endpoint, '/v1/chat/completions');
          expect(batch.completionWindow, '24h');
          // Initial status should be validating or in_progress
          expect(
            batch.status,
            anyOf(BatchStatus.validating, BatchStatus.inProgress),
          );
          expect(batch.createdAt, greaterThan(0));

          // Retrieve the batch
          final retrieved = await client!.batches.retrieve(batchId);

          expect(retrieved.id, batchId);
          expect(retrieved.object, 'batch');
          expect(retrieved.inputFileId, fileId);
          expect(retrieved.endpoint, '/v1/chat/completions');
        } finally {
          // Clean up: cancel batch if still processing (ignore errors)
          if (batchId != null) {
            try {
              await client!.batches.cancel(batchId);
            } on OpenAIException {
              // Batch may already be in terminal state
            }
          }

          // Delete the input file
          await client!.files.delete(fileId);
        }
      },
    );

    test(
      'lists batches with pagination',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // List with limit
        final batches = await client!.batches.list(limit: 5);

        expect(batches.data.length, lessThanOrEqualTo(5));
        expect(batches.hasMore, isA<bool>());

        // If there are batches, verify the structure
        if (batches.data.isNotEmpty) {
          final batch = batches.data.first;
          expect(batch.id, isNotEmpty);
          expect(batch.object, 'batch');
        }
      },
    );

    test(
      'cancels a batch',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a JSONL input file
        final requests = [
          {
            'custom_id': 'cancel-test-1',
            'method': 'POST',
            'url': '/v1/chat/completions',
            'body': {
              'model': 'gpt-4o-mini',
              'messages': [
                {'role': 'user', 'content': 'Test message'},
              ],
              'max_tokens': 10,
            },
          },
        ];

        final jsonlContent = requests.map(jsonEncode).join('\n');
        final bytes = utf8.encode(jsonlContent);

        // Upload the input file
        final uploadedFile = await client!.files.upload(
          bytes: bytes,
          filename: 'batch_cancel_test.jsonl',
          purpose: FilePurpose.batch,
        );

        final fileId = uploadedFile.id;

        try {
          // Create a batch
          final batch = await client!.batches.create(
            CreateBatchRequest(
              inputFileId: fileId,
              endpoint: BatchEndpoint.chatCompletions,
              completionWindow: CompletionWindow.hours24,
            ),
          );

          final batchId = batch.id;

          // Cancel the batch immediately
          final cancelled = await client!.batches.cancel(batchId);

          // Status should be cancelling or cancelled (may transition quickly)
          expect(
            cancelled.status,
            anyOf(BatchStatus.cancelling, BatchStatus.cancelled),
          );
        } finally {
          // Delete the input file
          await client!.files.delete(fileId);
        }
      },
    );
  });
}
