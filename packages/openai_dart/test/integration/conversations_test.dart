// ignore_for_file: avoid_print
@Tags(['integration'])
library;

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

  group('Conversations - Integration', () {
    test(
      'creates and retrieves a conversation',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a conversation
        final conversation = await client!.conversations.create(
          const ConversationCreateRequest(metadata: {'test': 'value'}),
        );

        expect(conversation.id, isNotEmpty);
        expect(conversation.id, startsWith('conv_'));
        expect(conversation.object, equals('conversation'));
        expect(conversation.createdAt, isPositive);
        expect(conversation.metadata, equals({'test': 'value'}));

        try {
          // Retrieve the conversation
          final retrieved = await client!.conversations.retrieve(
            conversation.id,
          );

          expect(retrieved.id, equals(conversation.id));
          expect(retrieved.createdAt, equals(conversation.createdAt));
          expect(retrieved.metadata, equals(conversation.metadata));
        } finally {
          // Clean up
          await client!.conversations.delete(conversation.id);
        }
      },
    );

    test(
      'updates conversation metadata',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a conversation
        final conversation = await client!.conversations.create(
          const ConversationCreateRequest(metadata: {'status': 'open'}),
        );

        try {
          // Update metadata
          final updated = await client!.conversations.update(
            conversation.id,
            const ConversationUpdateRequest(metadata: {'status': 'closed'}),
          );

          expect(updated.id, equals(conversation.id));
          expect(updated.metadata, equals({'status': 'closed'}));

          // Verify the update persisted
          final retrieved = await client!.conversations.retrieve(
            conversation.id,
          );
          expect(retrieved.metadata, equals({'status': 'closed'}));
        } finally {
          await client!.conversations.delete(conversation.id);
        }
      },
    );

    test(
      'deletes a conversation',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a conversation
        final conversation = await client!.conversations.create(
          const ConversationCreateRequest(),
        );

        // Delete it
        final deleted = await client!.conversations.delete(conversation.id);

        expect(deleted.id, equals(conversation.id));
        expect(deleted.deleted, isTrue);
        expect(deleted.object, equals('conversation.deleted'));

        // Verify it's gone (should throw)
        try {
          await client!.conversations.retrieve(conversation.id);
          fail('Expected an exception when retrieving deleted conversation');
        } on OpenAIException {
          // Expected
        }
      },
    );

    test(
      'lists items from empty conversation',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create an empty conversation
        final conversation = await client!.conversations.create(
          const ConversationCreateRequest(),
        );

        try {
          // List items - should be empty
          final items = await client!.conversations.items.list(conversation.id);

          expect(items.data, isEmpty);
          expect(items.hasMore, isFalse);
          expect(items.object, equals('list'));
        } finally {
          await client!.conversations.delete(conversation.id);
        }
      },
    );

    // Note: Tests for adding items and using conversations with the Responses API
    // are skipped until the SDK implements the 'conversation' parameter
    // in CreateResponseRequest. See API docs for conversation integration.
  });
}
