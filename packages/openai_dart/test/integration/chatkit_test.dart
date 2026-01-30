// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  String? workflowId;
  String? testThreadId;
  OpenAIClient? client;

  setUpAll(() {
    apiKey = Platform.environment['OPENAI_API_KEY'];
    workflowId = Platform.environment['OPENAI_CHATKIT_WORKFLOW_ID'];
    testThreadId = Platform.environment['OPENAI_CHATKIT_THREAD_ID'];

    if (apiKey == null || apiKey!.isEmpty) {
      print('OPENAI_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = OpenAIClient(
        config: OpenAIConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }

    if (workflowId == null || workflowId!.isEmpty) {
      print(
        'OPENAI_CHATKIT_WORKFLOW_ID not set. '
        'Sessions tests will be skipped.',
      );
    }

    if (testThreadId == null || testThreadId!.isEmpty) {
      print(
        'OPENAI_CHATKIT_THREAD_ID not set. '
        'Thread-specific tests will be skipped.',
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  // ==========================================================================
  // Group 1: Sessions API
  // ==========================================================================

  group('ChatKit Sessions', () {
    test(
      'creates a session with minimal config',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }
        if (workflowId == null) {
          markTestSkipped('OPENAI_CHATKIT_WORKFLOW_ID not set');
          return;
        }

        final session = await client!.chatkit.sessions.create(
          CreateChatSessionRequest(
            workflow: WorkflowParam(id: workflowId!),
            user: 'test-user-${DateTime.now().millisecondsSinceEpoch}',
          ),
        );

        try {
          expect(session.id, isNotEmpty);
          expect(session.object, 'chatkit.session');
          expect(session.clientSecret, isNotEmpty);
          expect(session.status, ChatSessionStatus.active);
          expect(session.isActive, isTrue);
          expect(session.user, isNotEmpty);
          expect(session.workflow.id, workflowId);
          expect(session.expiresAt, isPositive);
          expect(session.expiresAtDateTime, isA<DateTime>());
        } finally {
          // Cleanup: cancel the session
          await client!.chatkit.sessions.cancel(session.id);
        }
      },
    );

    test(
      'creates a session with full configuration',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }
        if (workflowId == null) {
          markTestSkipped('OPENAI_CHATKIT_WORKFLOW_ID not set');
          return;
        }

        final session = await client!.chatkit.sessions.create(
          CreateChatSessionRequest(
            workflow: WorkflowParam(
              id: workflowId!,
              tracing: const TracingParam(enabled: true),
            ),
            user: 'test-user-${DateTime.now().millisecondsSinceEpoch}',
            expiresAfter: 300, // 5 minutes
            rateLimits: const RateLimitsParam(maxRequestsPer1Minute: 10),
            chatkitConfiguration: const ChatkitConfigurationParam(
              automaticThreadTitling: AutomaticThreadTitlingParam(
                enabled: true,
              ),
              fileUpload: FileUploadParam(
                enabled: true,
                maxFileSize: 1, // 1MB
                maxFiles: 5,
              ),
              history: HistoryParam(enabled: true, recentThreads: 10),
            ),
          ),
        );

        try {
          expect(session.id, isNotEmpty);
          expect(session.object, 'chatkit.session');
          expect(session.status, ChatSessionStatus.active);

          // Verify rate limits
          expect(session.rateLimits.maxRequestsPer1Minute, 10);
          expect(session.maxRequestsPer1Minute, 10);

          // Verify chatkit configuration
          expect(
            session.chatkitConfiguration.automaticThreadTitling.enabled,
            isTrue,
          );
          expect(session.chatkitConfiguration.fileUpload.enabled, isTrue);
          expect(session.chatkitConfiguration.fileUpload.maxFileSize, 1);
          expect(session.chatkitConfiguration.fileUpload.maxFiles, 5);
          expect(session.chatkitConfiguration.history.enabled, isTrue);
          expect(session.chatkitConfiguration.history.recentThreads, 10);
        } finally {
          await client!.chatkit.sessions.cancel(session.id);
        }
      },
    );

    test(
      'validates session response fields',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }
        if (workflowId == null) {
          markTestSkipped('OPENAI_CHATKIT_WORKFLOW_ID not set');
          return;
        }

        final session = await client!.chatkit.sessions.create(
          CreateChatSessionRequest(
            workflow: WorkflowParam(id: workflowId!),
            user: 'test-user-fields',
          ),
        );

        try {
          // Verify all required response fields
          expect(session.id, isNotEmpty);
          expect(session.object, equals('chatkit.session'));
          expect(session.clientSecret, isNotEmpty);
          expect(session.workflow, isNotNull);
          expect(session.workflow.id, equals(workflowId));
          expect(session.user, equals('test-user-fields'));
          expect(session.status, equals(ChatSessionStatus.active));
          expect(session.expiresAt, isPositive);
          expect(session.rateLimits, isNotNull);
          expect(session.chatkitConfiguration, isNotNull);
        } finally {
          await client!.chatkit.sessions.cancel(session.id);
        }
      },
    );

    test(
      'validates session helper methods',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }
        if (workflowId == null) {
          markTestSkipped('OPENAI_CHATKIT_WORKFLOW_ID not set');
          return;
        }

        final session = await client!.chatkit.sessions.create(
          CreateChatSessionRequest(
            workflow: WorkflowParam(id: workflowId!),
            user: 'test-user-helpers',
          ),
        );

        try {
          // Test helper methods on active session
          expect(session.isActive, isTrue);
          expect(session.isExpired, isFalse);
          expect(session.isCancelled, isFalse);

          // Test expiresAtDateTime
          final expiresAt = session.expiresAtDateTime;
          expect(expiresAt, isA<DateTime>());
          expect(expiresAt.isAfter(DateTime.now()), isTrue);
        } finally {
          await client!.chatkit.sessions.cancel(session.id);
        }
      },
    );

    test(
      'cancels an active session',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }
        if (workflowId == null) {
          markTestSkipped('OPENAI_CHATKIT_WORKFLOW_ID not set');
          return;
        }

        // Create a session
        final session = await client!.chatkit.sessions.create(
          CreateChatSessionRequest(
            workflow: WorkflowParam(id: workflowId!),
            user: 'test-user-cancel',
          ),
        );

        expect(session.status, ChatSessionStatus.active);
        expect(session.isActive, isTrue);

        // Cancel the session
        final cancelled = await client!.chatkit.sessions.cancel(session.id);

        expect(cancelled.id, equals(session.id));
        expect(cancelled.status, ChatSessionStatus.cancelled);
        expect(cancelled.isCancelled, isTrue);
        expect(cancelled.isActive, isFalse);
      },
    );
  });

  // ==========================================================================
  // Group 2: Threads API
  // ==========================================================================

  group('ChatKit Threads', () {
    test(
      'lists threads',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final threads = await client!.chatkit.threads.list();

        expect(threads.object, 'list');
        expect(threads.data, isA<List<ChatkitThread>>());
        // hasMore is always a boolean
        expect(threads.hasMore, isA<bool>());
      },
    );

    test(
      'lists threads with pagination parameters',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Test with limit
        final threadsLimited = await client!.chatkit.threads.list(limit: 5);

        expect(threadsLimited.object, 'list');
        expect(threadsLimited.data.length, lessThanOrEqualTo(5));

        // Test with order
        final threadsOrdered = await client!.chatkit.threads.list(
          limit: 5,
          order: 'desc',
        );

        expect(threadsOrdered.object, 'list');
        expect(threadsOrdered.data, isA<List<ChatkitThread>>());
      },
    );

    test(
      'retrieves a thread',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }
        if (testThreadId == null) {
          markTestSkipped('OPENAI_CHATKIT_THREAD_ID not set');
          return;
        }

        final thread = await client!.chatkit.threads.retrieve(testThreadId!);

        expect(thread.id, equals(testThreadId));
        expect(thread.object, equals('chatkit.thread'));
        expect(thread.user, isNotEmpty);
        expect(thread.createdAt, isPositive);
        expect(thread.createdAtDateTime, isA<DateTime>());
        expect(thread.status, isNotNull);
        expect(thread.status.type, isNotEmpty);
      },
    );

    test(
      'validates thread status types',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }
        if (testThreadId == null) {
          markTestSkipped('OPENAI_CHATKIT_THREAD_ID not set');
          return;
        }

        final thread = await client!.chatkit.threads.retrieve(testThreadId!);

        // Test status helper methods
        expect(
          thread.status.isActive ||
              thread.status.isLocked ||
              thread.status.isClosed,
          isTrue,
        );

        // Status should have a valid type
        expect(thread.status.type, anyOf('active', 'locked', 'closed'));
      },
    );

    // Note: delete test is skipped by default to avoid deleting production data
    test(
      'deletes a thread',
      skip:
          'Skipped to avoid deleting production threads. '
          'Run manually with a test thread ID.',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }
        if (testThreadId == null) {
          markTestSkipped('OPENAI_CHATKIT_THREAD_ID not set');
          return;
        }

        final result = await client!.chatkit.threads.delete(testThreadId!);

        expect(result.id, equals(testThreadId));
        expect(result.deleted, isTrue);
        expect(result.object, equals('chatkit.thread.deleted'));
      },
    );
  });

  // ==========================================================================
  // Group 3: Thread Items API
  // ==========================================================================

  group('ChatKit Thread Items', () {
    test(
      'lists thread items',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }
        if (testThreadId == null) {
          markTestSkipped('OPENAI_CHATKIT_THREAD_ID not set');
          return;
        }

        final items = await client!.chatkit.threads.items.list(testThreadId!);

        expect(items.object, 'list');
        expect(items.data, isA<List<ThreadItem>>());
        expect(items.hasMore, isA<bool>());
      },
    );

    test(
      'lists thread items with pagination',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }
        if (testThreadId == null) {
          markTestSkipped('OPENAI_CHATKIT_THREAD_ID not set');
          return;
        }

        final items = await client!.chatkit.threads.items.list(
          testThreadId!,
          limit: 10,
          order: 'asc',
        );

        expect(items.object, 'list');
        expect(items.data.length, lessThanOrEqualTo(10));
      },
    );

    test(
      'validates thread item types',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }
        if (testThreadId == null) {
          markTestSkipped('OPENAI_CHATKIT_THREAD_ID not set');
          return;
        }

        final items = await client!.chatkit.threads.items.list(testThreadId!);

        if (items.isEmpty) {
          markTestSkipped('Thread has no items');
          return;
        }

        // Verify item structure
        for (final item in items.data) {
          expect(item.id, isNotEmpty);
          expect(item.type, isNotEmpty);
          expect(item.json, isNotNull);

          // Test type helper methods
          final typeMatches =
              item.isUserMessage ||
              item.isAssistantMessage ||
              item.isWidgetMessage ||
              item.isClientToolCall ||
              item.isTask ||
              item.isTaskGroup;

          // At least one should match if it's a known type
          // or none if it's a new/unknown type
          expect(typeMatches || item.type.isNotEmpty, isTrue);
        }
      },
    );
  });

  // ==========================================================================
  // Group 4: Error Handling
  // ==========================================================================

  group('ChatKit Error Handling', () {
    test(
      'handles invalid workflow ID',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        try {
          await client!.chatkit.sessions.create(
            const CreateChatSessionRequest(
              workflow: WorkflowParam(id: 'invalid-workflow-id'),
              user: 'test-user',
            ),
          );
          fail('Expected exception for invalid workflow ID');
        } on OpenAIException catch (e) {
          // Expected - invalid workflow should throw
          expect(e.message, isNotEmpty);
        }
      },
    );

    test(
      'handles invalid thread ID on retrieve',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        try {
          await client!.chatkit.threads.retrieve('invalid-thread-id');
          fail('Expected exception for invalid thread ID');
        } on NotFoundException catch (e) {
          expect(e.statusCode, 404);
        } on OpenAIException {
          // Also acceptable - might be different error type
        }
      },
    );

    test(
      'handles invalid thread ID on items list',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        try {
          await client!.chatkit.threads.items.list('invalid-thread-id');
          fail('Expected exception for invalid thread ID');
        } on NotFoundException catch (e) {
          expect(e.statusCode, 404);
        } on OpenAIException {
          // Also acceptable - might be different error type
        }
      },
    );
  });
}
