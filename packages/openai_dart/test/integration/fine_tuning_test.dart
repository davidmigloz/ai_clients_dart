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

  group('Fine-Tuning Jobs - Integration', () {
    test(
      'lists fine-tuning jobs',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final jobs = await client!.fineTuning.jobs.list(limit: 10);

        expect(jobs.object, 'list');
        expect(jobs.data, isA<List<FineTuningJob>>());
        expect(jobs.hasMore, isA<bool>());
      },
    );

    test(
      'lists jobs with pagination',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final jobs = await client!.fineTuning.jobs.list(limit: 5);

        expect(jobs.data.length, lessThanOrEqualTo(5));
        expect(jobs.hasMore, isA<bool>());

        // If there are jobs, verify the structure
        if (jobs.data.isNotEmpty) {
          final job = jobs.data.first;
          expect(job.id, isNotEmpty);
          expect(job.object, 'fine_tuning.job');
          expect(job.model, isNotEmpty);
          expect(job.status, isA<FineTuningStatus>());
        }
      },
    );

    test(
      'creates, retrieves, lists events, and cancels a job',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create training data with 10 examples (minimum required by OpenAI)
        // Using JSONL chat format for fine-tuning
        final trainingData = List.generate(10, (i) {
          return {
            'messages': [
              {
                'role': 'system',
                'content': 'You are a helpful customer service assistant.',
              },
              {
                'role': 'user',
                'content': 'Customer question $i: How do I do X?',
              },
              {
                'role': 'assistant',
                'content':
                    'Thank you for your question! Here is how to do X: Step $i.',
              },
            ],
          };
        });

        final jsonlContent = trainingData.map(jsonEncode).join('\n');
        final bytes = utf8.encode(jsonlContent);

        // Upload the training file
        final uploadedFile = await client!.files.upload(
          bytes: bytes,
          filename: 'fine_tuning_test_data.jsonl',
          purpose: FilePurpose.fineTune,
        );

        expect(uploadedFile.id, isNotEmpty);
        expect(uploadedFile.purpose, FilePurpose.fineTune);

        final fileId = uploadedFile.id;
        String? jobId;

        try {
          // Create a fine-tuning job
          final job = await client!.fineTuning.jobs.create(
            CreateFineTuningJobRequest(
              model: 'gpt-4o-mini-2024-07-18',
              trainingFile: fileId,
            ),
          );

          jobId = job.id;

          // Verify created job
          expect(job.id, isNotEmpty);
          expect(job.object, 'fine_tuning.job');
          expect(job.model, 'gpt-4o-mini-2024-07-18');
          expect(job.trainingFile, fileId);
          expect(
            job.status,
            anyOf(
              FineTuningStatus.validatingFiles,
              FineTuningStatus.queued,
              FineTuningStatus.running,
            ),
          );
          expect(job.createdAt, greaterThan(0));

          // Retrieve the job
          final retrieved = await client!.fineTuning.jobs.retrieve(jobId);

          expect(retrieved.id, jobId);
          expect(retrieved.object, 'fine_tuning.job');
          expect(retrieved.trainingFile, fileId);
          expect(retrieved.model, 'gpt-4o-mini-2024-07-18');

          // List events for the job
          final events = await client!.fineTuning.jobs.listEvents(jobId);

          expect(events.object, 'list');
          expect(events.data, isA<List<FineTuningEvent>>());
          expect(events.hasMore, isA<bool>());

          // If there are events, verify structure
          if (events.data.isNotEmpty) {
            final event = events.data.first;
            expect(event.id, isNotEmpty);
            expect(event.object, 'fine_tuning.job.event');
            expect(event.level, isNotEmpty);
            expect(event.message, isNotEmpty);
          }

          // Cancel the job immediately to minimize costs
          final cancelled = await client!.fineTuning.jobs.cancel(jobId);

          // Status should be cancelling or cancelled
          expect(cancelled.status, anyOf(FineTuningStatus.cancelled));

          // List checkpoints (likely empty for a newly created/cancelled job)
          final checkpoints = await client!.fineTuning.jobs.listCheckpoints(
            jobId,
          );

          expect(checkpoints.object, 'list');
          expect(checkpoints.data, isA<List<FineTuningCheckpoint>>());
          expect(checkpoints.hasMore, isA<bool>());
        } finally {
          // Clean up: delete the training file
          try {
            await client!.files.delete(fileId);
          } on OpenAIException catch (e) {
            print('Warning: Failed to delete training file: ${e.message}');
          }
        }
      },
    );
  });
}
