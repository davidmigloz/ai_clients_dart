// ignore_for_file: avoid_print, deprecated_member_use_from_same_package
@Tags(['integration'])
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart'
    hide CodeInterpreterTool, FileSearchTool, FunctionTool;
import 'package:openai_dart/openai_dart_assistants.dart';
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

  group('Assistants API - Integration', () {
    test(
      'creates, retrieves, updates, and deletes an assistant',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create
        final assistant = await client!.beta.assistants.create(
          const CreateAssistantRequest(
            model: 'gpt-4o-mini',
            name: 'Test Assistant',
            instructions: 'You are a helpful test assistant.',
            metadata: {'test': 'true'},
          ),
        );

        expect(assistant.id, isNotEmpty);
        expect(assistant.name, 'Test Assistant');
        expect(assistant.model, contains('gpt-4o-mini'));
        expect(assistant.instructions, 'You are a helpful test assistant.');
        expect(assistant.metadata['test'], 'true');

        final assistantId = assistant.id;

        try {
          // Retrieve
          final retrieved = await client!.beta.assistants.retrieve(assistantId);

          expect(retrieved.id, assistantId);
          expect(retrieved.name, 'Test Assistant');

          // Update
          final updated = await client!.beta.assistants.update(
            assistantId,
            const ModifyAssistantRequest(
              name: 'Updated Test Assistant',
              instructions: 'Updated instructions.',
            ),
          );

          expect(updated.name, 'Updated Test Assistant');
          expect(updated.instructions, 'Updated instructions.');

          // List
          final assistants = await client!.beta.assistants.list(limit: 10);

          expect(assistants.data, isNotEmpty);
          expect(
            assistants.data.any((a) => a.id == assistantId),
            isTrue,
            reason: 'Created assistant should be in list',
          );
        } finally {
          // Delete
          final deleted = await client!.beta.assistants.delete(assistantId);

          expect(deleted.id, assistantId);
          expect(deleted.deleted, isTrue);
        }
      },
    );

    test(
      'creates assistant with tools',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final assistant = await client!.beta.assistants.create(
          const CreateAssistantRequest(
            model: 'gpt-4o-mini',
            name: 'Tool Assistant',
            tools: [
              CodeInterpreterTool(),
              FunctionTool(
                name: 'get_weather',
                description: 'Get weather for a location',
                parameters: {
                  'type': 'object',
                  'properties': {
                    'location': {'type': 'string', 'description': 'City name'},
                  },
                  'required': ['location'],
                },
              ),
            ],
          ),
        );

        try {
          expect(assistant.tools.length, 2);
          expect(assistant.tools[0], isA<CodeInterpreterTool>());
          expect(assistant.tools[1], isA<FunctionTool>());
          expect((assistant.tools[1] as FunctionTool).name, 'get_weather');
        } finally {
          await client!.beta.assistants.delete(assistant.id);
        }
      },
    );
  });

  group('Threads API - Integration', () {
    test(
      'creates, retrieves, updates, and deletes a thread',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create empty thread
        final thread = await client!.beta.threads.create();

        expect(thread.id, isNotEmpty);
        expect(thread.object, 'thread');
        expect(thread.createdAt, greaterThan(0));

        final threadId = thread.id;

        try {
          // Retrieve
          final retrieved = await client!.beta.threads.retrieve(threadId);

          expect(retrieved.id, threadId);

          // Update
          final updated = await client!.beta.threads.update(
            threadId,
            const ModifyThreadRequest(metadata: {'status': 'active'}),
          );

          expect(updated.metadata['status'], 'active');
        } finally {
          // Delete
          final deleted = await client!.beta.threads.delete(threadId);

          expect(deleted.id, threadId);
          expect(deleted.deleted, isTrue);
        }
      },
    );

    test(
      'creates thread with initial messages',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final thread = await client!.beta.threads.create(
          CreateThreadRequest(
            messages: [ThreadMessage.user('Hello, I need help with math.')],
            metadata: const {'topic': 'math'},
          ),
        );

        try {
          expect(thread.id, isNotEmpty);
          expect(thread.metadata['topic'], 'math');

          // Verify message was created
          final messages = await client!.beta.threads.messages.list(thread.id);

          expect(messages.data, isNotEmpty);
          expect(messages.data.first.role, 'user');
        } finally {
          await client!.beta.threads.delete(thread.id);
        }
      },
    );
  });

  group('Messages API - Integration', () {
    late String threadId;

    setUp(() async {
      if (apiKey != null) {
        final thread = await client!.beta.threads.create();
        threadId = thread.id;
      }
    });

    tearDown(() async {
      if (apiKey != null) {
        await client!.beta.threads.delete(threadId);
      }
    });

    test(
      'creates, retrieves, and lists messages',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create message
        final message = await client!.beta.threads.messages.create(
          threadId,
          CreateMessageRequest.user('What is 2 + 2?'),
        );

        expect(message.id, isNotEmpty);
        expect(message.role, 'user');
        expect(message.threadId, threadId);

        // Retrieve
        final retrieved = await client!.beta.threads.messages.retrieve(
          threadId,
          message.id,
        );

        expect(retrieved.id, message.id);

        // List
        final messages = await client!.beta.threads.messages.list(threadId);

        expect(messages.data, isNotEmpty);
        expect(messages.data.first.id, message.id);
      },
    );

    test(
      'message text getter works',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final message = await client!.beta.threads.messages.create(
          threadId,
          CreateMessageRequest.user('Test message content'),
        );

        expect(message.text, contains('Test message content'));
      },
    );
  });

  group('Runs API - Integration', () {
    late String assistantId;
    late String threadId;

    setUp(() async {
      if (apiKey != null) {
        final assistant = await client!.beta.assistants.create(
          const CreateAssistantRequest(
            model: 'gpt-4o-mini',
            name: 'Run Test Assistant',
            instructions: 'Reply briefly.',
          ),
        );
        assistantId = assistant.id;

        final thread = await client!.beta.threads.create(
          CreateThreadRequest(messages: [ThreadMessage.user('Say hello')]),
        );
        threadId = thread.id;
      }
    });

    tearDown(() async {
      if (apiKey != null) {
        await client!.beta.threads.delete(threadId);
        await client!.beta.assistants.delete(assistantId);
      }
    });

    test(
      'creates run and polls until completion',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create run
        var run = await client!.beta.threads.runs.create(
          threadId,
          CreateRunRequest(assistantId: assistantId),
        );

        expect(run.id, isNotEmpty);
        expect(run.assistantId, assistantId);
        expect(run.threadId, threadId);

        // Poll until complete (terminal states: completed, failed, cancelled, expired, incomplete)
        var attempts = 0;
        while (!_isTerminalStatus(run.status) && attempts < 30) {
          await Future<void>.delayed(const Duration(seconds: 1));
          run = await client!.beta.threads.runs.retrieve(threadId, run.id);
          attempts++;
        }

        expect(run.status, RunStatus.completed);

        // Verify assistant message was created
        final messages = await client!.beta.threads.messages.list(threadId);

        expect(messages.data.length, greaterThanOrEqualTo(2));
        expect(
          messages.data.any((m) => m.role == 'assistant'),
          isTrue,
          reason: 'Should have assistant response',
        );
      },
    );

    test(
      'lists runs in thread',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a run
        final run = await client!.beta.threads.runs.create(
          threadId,
          CreateRunRequest(assistantId: assistantId),
        );

        // List runs
        final runs = await client!.beta.threads.runs.list(threadId);

        expect(runs.data, isNotEmpty);
        expect(runs.data.any((r) => r.id == run.id), isTrue);
      },
    );

    test(
      'can cancel a run',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a run
        final run = await client!.beta.threads.runs.create(
          threadId,
          CreateRunRequest(assistantId: assistantId),
        );

        // Try to cancel (may already be complete if fast)
        try {
          final cancelled = await client!.beta.threads.runs.cancel(
            threadId,
            run.id,
          );

          expect(
            cancelled.status == RunStatus.cancelling ||
                cancelled.status == RunStatus.cancelled ||
                _isTerminalStatus(cancelled.status),
            isTrue,
          );
        } on OpenAIException catch (e) {
          // Run may have completed before we could cancel
          print('Cancel note: ${e.message}');
        }
      },
    );
  });

  group('Full Assistants Workflow - Integration', () {
    test(
      'complete conversation flow',
      timeout: const Timeout(Duration(minutes: 5)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // 1. Create assistant
        final assistant = await client!.beta.assistants.create(
          const CreateAssistantRequest(
            model: 'gpt-4o-mini',
            name: 'Math Helper',
            instructions:
                'You are a helpful math assistant. Give brief answers.',
          ),
        );

        try {
          // 2. Create thread
          final thread = await client!.beta.threads.create();

          try {
            // 3. Add message
            await client!.beta.threads.messages.create(
              thread.id,
              CreateMessageRequest.user('What is 7 * 8?'),
            );

            // 4. Run assistant
            var run = await client!.beta.threads.runs.create(
              thread.id,
              CreateRunRequest(assistantId: assistant.id),
            );

            // 5. Wait for completion
            var attempts = 0;
            while (!_isTerminalStatus(run.status) && attempts < 30) {
              await Future<void>.delayed(const Duration(seconds: 1));
              run = await client!.beta.threads.runs.retrieve(thread.id, run.id);
              attempts++;
            }

            expect(run.status, RunStatus.completed);

            // 6. Get messages
            final messages = await client!.beta.threads.messages.list(
              thread.id,
              order: 'asc',
            );

            expect(messages.data.length, 2);

            // User message
            expect(messages.data[0].role, 'user');
            expect(messages.data[0].text, contains('7'));

            // Assistant message - should contain 56
            expect(messages.data[1].role, 'assistant');
            expect(messages.data[1].text, contains('56'));

            // 7. Continue conversation
            await client!.beta.threads.messages.create(
              thread.id,
              CreateMessageRequest.user('And what is that divided by 7?'),
            );

            run = await client!.beta.threads.runs.create(
              thread.id,
              CreateRunRequest(assistantId: assistant.id),
            );

            attempts = 0;
            while (!_isTerminalStatus(run.status) && attempts < 30) {
              await Future<void>.delayed(const Duration(seconds: 1));
              run = await client!.beta.threads.runs.retrieve(thread.id, run.id);
              attempts++;
            }

            // 8. Verify follow-up response
            final finalMessages = await client!.beta.threads.messages.list(
              thread.id,
              order: 'asc',
            );

            expect(finalMessages.data.length, 4);

            // Final answer should reference 8
            final lastMessage = finalMessages.data.last;
            expect(lastMessage.role, 'assistant');
            expect(lastMessage.text, contains('8'));
          } finally {
            await client!.beta.threads.delete(thread.id);
          }
        } finally {
          await client!.beta.assistants.delete(assistant.id);
        }
      },
    );
  });
}

/// Helper to check if a run status is terminal.
bool _isTerminalStatus(RunStatus status) {
  return status == RunStatus.completed ||
      status == RunStatus.failed ||
      status == RunStatus.cancelled ||
      status == RunStatus.expired ||
      status == RunStatus.incomplete;
}
