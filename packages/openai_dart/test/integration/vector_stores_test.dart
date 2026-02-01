// ignore_for_file: avoid_print, deprecated_member_use_from_same_package
@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
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

  group('Vector Stores API - Integration', () {
    test(
      'creates, retrieves, updates, and deletes a vector store',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a vector store
        final store = await client!.beta.vectorStores.create(
          const CreateVectorStoreRequest(
            name: 'Test Vector Store',
            metadata: {'test': 'true', 'purpose': 'integration-test'},
          ),
        );

        expect(store.id, isNotEmpty);
        expect(store.object, 'vector_store');
        expect(store.createdAt, greaterThan(0));
        expect(store.name, 'Test Vector Store');
        expect(store.usageBytes, greaterThanOrEqualTo(0));
        expect(store.fileCounts.total, 0);
        expect(store.fileCounts.inProgress, 0);
        expect(store.fileCounts.completed, 0);
        expect(store.fileCounts.failed, 0);
        expect(store.fileCounts.cancelled, 0);
        expect(
          store.status == VectorStoreStatus.completed ||
              store.status == VectorStoreStatus.inProgress,
          isTrue,
        );
        expect(store.metadata['test'], 'true');
        expect(store.metadata['purpose'], 'integration-test');

        // Verify isReady helper
        if (store.status == VectorStoreStatus.completed) {
          expect(store.isReady, isTrue);
        }

        final storeId = store.id;

        try {
          // Retrieve the store
          final retrieved = await client!.beta.vectorStores.retrieve(storeId);

          expect(retrieved.id, storeId);
          expect(retrieved.name, 'Test Vector Store');
          expect(retrieved.metadata['test'], 'true');

          // Update the store
          final updated = await client!.beta.vectorStores.update(
            storeId,
            const ModifyVectorStoreRequest(
              name: 'Updated Test Vector Store',
              metadata: {'test': 'true', 'updated': 'yes'},
            ),
          );

          expect(updated.id, storeId);
          expect(updated.name, 'Updated Test Vector Store');
          expect(updated.metadata['updated'], 'yes');

          // List and confirm store appears (with retry for eventual consistency)
          var storeFound = false;
          VectorStoreList? stores;
          for (var attempt = 0; attempt < 10 && !storeFound; attempt++) {
            if (attempt > 0) {
              await Future<void>.delayed(const Duration(seconds: 1));
            }
            stores = await client!.beta.vectorStores.list(limit: 20);
            storeFound = stores.data.any((s) => s.id == storeId);
          }

          expect(stores, isNotNull);
          expect(stores!.object, 'list');
          expect(stores.data, isNotEmpty);
          expect(storeFound, isTrue, reason: 'Created store should be in list');

          // Verify pagination fields exist
          if (stores.data.isNotEmpty) {
            expect(stores.firstId, isNotNull);
            expect(stores.lastId, isNotNull);
          }
        } finally {
          // Delete the store
          final deleted = await client!.beta.vectorStores.delete(storeId);

          expect(deleted.id, storeId);
          expect(deleted.object, 'vector_store.deleted');
          expect(deleted.deleted, isTrue);
        }
      },
    );

    test(
      'creates vector store with expiration policy',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final store = await client!.beta.vectorStores.create(
          const CreateVectorStoreRequest(
            name: 'Expiring Store',
            expiresAfter: ExpirationPolicy(anchor: 'last_active_at', days: 7),
          ),
        );

        try {
          expect(store.id, isNotEmpty);
          expect(store.expiresAfter, isNotNull);
          expect(store.expiresAfter!.anchor, 'last_active_at');
          expect(store.expiresAfter!.days, 7);
          // OpenAI should set expiresAt based on the policy
          expect(store.expiresAt, isNotNull);
          expect(store.expiresAt, greaterThan(0));
        } finally {
          await client!.beta.vectorStores.delete(store.id);
        }
      },
    );

    test(
      'lists vector stores with pagination parameters',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create multiple stores for pagination testing
        final store1 = await client!.beta.vectorStores.create(
          const CreateVectorStoreRequest(name: 'Pagination Test 1'),
        );
        final store2 = await client!.beta.vectorStores.create(
          const CreateVectorStoreRequest(name: 'Pagination Test 2'),
        );

        try {
          // Wait for stores to appear in list (API eventual consistency)
          var attempts = 0;
          VectorStoreList page1;
          do {
            await Future<void>.delayed(const Duration(seconds: 1));
            page1 = await client!.beta.vectorStores.list(limit: 1);
            attempts++;
          } while (page1.data.isEmpty && attempts < 30);

          expect(page1.data.length, 1);
          // hasMore should be true if there are more stores
          if (page1.hasMore) {
            expect(page1.lastId, isNotNull);

            // Paginate using after
            final page2 = await client!.beta.vectorStores.list(
              limit: 1,
              after: page1.lastId,
            );

            expect(page2.data.length, lessThanOrEqualTo(1));
            // The IDs should be different
            if (page2.data.isNotEmpty) {
              expect(page2.data.first.id, isNot(page1.data.first.id));
            }
          }

          // Test ascending order
          final ascList = await client!.beta.vectorStores.list(
            limit: 10,
            order: 'asc',
          );

          expect(ascList.data, isNotEmpty);

          // Test descending order
          final descList = await client!.beta.vectorStores.list(
            limit: 10,
            order: 'desc',
          );

          expect(descList.data, isNotEmpty);

          // Verify ordering is different if we have multiple stores
          if (ascList.data.length > 1 && descList.data.length > 1) {
            expect(ascList.data.first.id, isNot(descList.data.first.id));
          }
        } finally {
          await client!.beta.vectorStores.delete(store1.id);
          await client!.beta.vectorStores.delete(store2.id);
        }
      },
    );

    test(
      'verifies empty vector store file counts',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final store = await client!.beta.vectorStores.create(
          const CreateVectorStoreRequest(name: 'Empty Store Test'),
        );

        try {
          // Verify file counts are all zero
          expect(store.fileCounts.total, 0);
          expect(store.fileCounts.inProgress, 0);
          expect(store.fileCounts.completed, 0);
          expect(store.fileCounts.failed, 0);
          expect(store.fileCounts.cancelled, 0);

          // List files in empty store
          final files = await client!.beta.vectorStores.files.list(store.id);

          expect(files.object, 'list');
          expect(files.data, isEmpty);
          expect(files.hasMore, isFalse);
        } finally {
          await client!.beta.vectorStores.delete(store.id);
        }
      },
    );
  });

  group('Vector Store Files API - Integration', () {
    test(
      'adds file to vector store and waits for processing',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Upload a file first
        const fileContent = '''
Vector stores are a powerful feature for semantic search.
They allow you to index documents and search them efficiently.
This is a test document for vector store integration testing.
The Assistants API uses vector stores for file_search functionality.
''';

        final file = await client!.files.upload(
          bytes: utf8.encode(fileContent),
          filename: 'test_vector_document.txt',
          purpose: FilePurpose.assistants,
        );

        try {
          // Create vector store
          final store = await client!.beta.vectorStores.create(
            const CreateVectorStoreRequest(name: 'File Test Store'),
          );

          try {
            // Add file to vector store
            var vsFile = await client!.beta.vectorStores.files.create(
              store.id,
              CreateVectorStoreFileRequest(fileId: file.id),
            );

            expect(vsFile.id, file.id);
            expect(vsFile.object, 'vector_store.file');
            expect(vsFile.vectorStoreId, store.id);
            expect(vsFile.createdAt, greaterThan(0));

            // Poll until file is processed using isReady/isFailed helpers
            var attempts = 0;
            while (!vsFile.isReady && !vsFile.isFailed && attempts < 60) {
              await Future<void>.delayed(const Duration(seconds: 1));
              vsFile = await client!.beta.vectorStores.files.retrieve(
                store.id,
                vsFile.id,
              );
              attempts++;
            }

            expect(
              vsFile.isReady,
              isTrue,
              reason: 'File should have processed successfully',
            );
            expect(vsFile.isFailed, isFalse);
            expect(vsFile.status, VectorStoreFileStatus.completed);
            expect(vsFile.usageBytes, greaterThan(0));

            // Verify chunking strategy is populated after processing
            expect(vsFile.chunkingStrategy, isNotNull);

            // List files and verify file appears (poll for eventual consistency)
            var listAttempts = 0;
            VectorStoreFileList fileList;
            do {
              await Future<void>.delayed(const Duration(seconds: 1));
              fileList = await client!.beta.vectorStores.files.list(store.id);
              listAttempts++;
            } while (fileList.data.isEmpty && listAttempts < 30);

            expect(fileList.data, isNotEmpty);
            expect(
              fileList.data.any((f) => f.id == file.id),
              isTrue,
              reason: 'Added file should be in list',
            );
          } finally {
            await client!.beta.vectorStores.delete(store.id);
          }
        } finally {
          await client!.files.delete(file.id);
        }
      },
    );

    test(
      'adds file with static chunking strategy',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Upload a file
        const fileContent = '''
This is a document for testing static chunking strategy.
The static chunking strategy allows you to specify exact chunk sizes.
You can control the maximum chunk size and the overlap between chunks.
This is useful when you need precise control over document segmentation.
Additional content to ensure the file has enough content for chunking.
More text here to make the document large enough for meaningful chunking.
''';

        final file = await client!.files.upload(
          bytes: utf8.encode(fileContent),
          filename: 'test_static_chunking.txt',
          purpose: FilePurpose.assistants,
        );

        try {
          final store = await client!.beta.vectorStores.create(
            const CreateVectorStoreRequest(name: 'Static Chunking Test'),
          );

          try {
            // Add file with static chunking strategy
            var vsFile = await client!.beta.vectorStores.files.create(
              store.id,
              CreateVectorStoreFileRequest(
                fileId: file.id,
                chunkingStrategy: const StaticChunkingStrategy(
                  maxChunkSizeTokens: 800,
                  chunkOverlapTokens: 400,
                ),
              ),
            );

            // Poll until processed
            var attempts = 0;
            while (!vsFile.isReady && !vsFile.isFailed && attempts < 60) {
              await Future<void>.delayed(const Duration(seconds: 1));
              vsFile = await client!.beta.vectorStores.files.retrieve(
                store.id,
                vsFile.id,
              );
              attempts++;
            }

            expect(vsFile.isReady, isTrue);

            // Verify the chunking strategy in the response
            expect(vsFile.chunkingStrategy, isNotNull);
            if (vsFile.chunkingStrategy is StaticChunkingStrategy) {
              final strategy =
                  vsFile.chunkingStrategy! as StaticChunkingStrategy;
              expect(strategy.maxChunkSizeTokens, 800);
              expect(strategy.chunkOverlapTokens, 400);
            }
          } finally {
            await client!.beta.vectorStores.delete(store.id);
          }
        } finally {
          await client!.files.delete(file.id);
        }
      },
    );

    test(
      'lists files with filter parameter',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final file = await client!.files.upload(
          bytes: utf8.encode('Content for filter test document.'),
          filename: 'test_filter.txt',
          purpose: FilePurpose.assistants,
        );

        try {
          final store = await client!.beta.vectorStores.create(
            const CreateVectorStoreRequest(name: 'Filter Test Store'),
          );

          try {
            var vsFile = await client!.beta.vectorStores.files.create(
              store.id,
              CreateVectorStoreFileRequest(fileId: file.id),
            );

            // During processing, try to list with in_progress filter
            if (vsFile.status == VectorStoreFileStatus.inProgress) {
              final inProgressFiles = await client!.beta.vectorStores.files
                  .list(store.id, filter: 'in_progress');
              // The file might be in progress, or might have already completed
              expect(inProgressFiles.data, isA<List<VectorStoreFile>>());
            }

            // Poll until processed
            var attempts = 0;
            while (!vsFile.isReady && !vsFile.isFailed && attempts < 60) {
              await Future<void>.delayed(const Duration(seconds: 1));
              vsFile = await client!.beta.vectorStores.files.retrieve(
                store.id,
                vsFile.id,
              );
              attempts++;
            }

            // List with completed filter (poll for eventual consistency)
            if (vsFile.isReady) {
              var filterAttempts = 0;
              VectorStoreFileList completedFiles;
              bool fileFound;
              do {
                await Future<void>.delayed(const Duration(seconds: 1));
                completedFiles = await client!.beta.vectorStores.files.list(
                  store.id,
                  filter: 'completed',
                );
                fileFound = completedFiles.data.any((f) => f.id == file.id);
                filterAttempts++;
              } while (!fileFound && filterAttempts < 30);

              expect(
                fileFound,
                isTrue,
                reason: 'Completed file should appear in completed filter',
              );
            }
          } finally {
            await client!.beta.vectorStores.delete(store.id);
          }
        } finally {
          await client!.files.delete(file.id);
        }
      },
    );

    test(
      'deletes file from vector store',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final file = await client!.files.upload(
          bytes: utf8.encode('Content for delete test.'),
          filename: 'test_delete.txt',
          purpose: FilePurpose.assistants,
        );

        try {
          final store = await client!.beta.vectorStores.create(
            const CreateVectorStoreRequest(name: 'Delete File Test Store'),
          );

          try {
            // Add file
            var vsFile = await client!.beta.vectorStores.files.create(
              store.id,
              CreateVectorStoreFileRequest(fileId: file.id),
            );

            // Wait for processing
            var attempts = 0;
            while (!vsFile.isReady && !vsFile.isFailed && attempts < 60) {
              await Future<void>.delayed(const Duration(seconds: 1));
              vsFile = await client!.beta.vectorStores.files.retrieve(
                store.id,
                vsFile.id,
              );
              attempts++;
            }

            // Delete file from vector store
            final deleted = await client!.beta.vectorStores.files.delete(
              store.id,
              file.id,
            );

            expect(deleted.id, file.id);
            expect(deleted.deleted, isTrue);

            // Verify file is no longer in the store (with retry for eventual consistency)
            var fileRemoved = false;
            for (var attempt = 0; attempt < 10 && !fileRemoved; attempt++) {
              if (attempt > 0) {
                await Future<void>.delayed(const Duration(seconds: 1));
              }
              final fileList = await client!.beta.vectorStores.files.list(
                store.id,
              );
              fileRemoved = !fileList.data.any((f) => f.id == file.id);
            }

            expect(
              fileRemoved,
              isTrue,
              reason: 'Deleted file should not be in list',
            );
          } finally {
            await client!.beta.vectorStores.delete(store.id);
          }
        } finally {
          await client!.files.delete(file.id);
        }
      },
    );
  });

  group('Full Vector Store Workflow - Integration', () {
    test(
      'complete workflow: upload → add to store → verify counts → cleanup',
      timeout: const Timeout(Duration(minutes: 5)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Upload a document with meaningful content
        const documentContent = '''
# Vector Store Integration Guide

Vector stores are a key component of the OpenAI Assistants API.
They enable semantic search over your documents using embeddings.

## Key Features

1. **Automatic Chunking**: Documents are split into manageable chunks.
2. **Embedding Generation**: Each chunk is converted to an embedding.
3. **Semantic Search**: Find relevant content based on meaning.
4. **File Management**: Add or remove files from stores.

## Use Cases

- Document Q&A systems
- Knowledge base search
- Research assistant applications
- Customer support automation

This document serves as test content for vector store integration testing.
''';

        final file = await client!.files.upload(
          bytes: utf8.encode(documentContent),
          filename: 'integration_guide.txt',
          purpose: FilePurpose.assistants,
        );

        try {
          // Create vector store with the file
          var store = await client!.beta.vectorStores.create(
            CreateVectorStoreRequest(
              name: 'Integration Workflow Store',
              fileIds: [file.id],
              metadata: const {'workflow': 'integration-test'},
            ),
          );

          try {
            expect(store.id, isNotEmpty);

            // Initial status may be in_progress while file is being processed
            expect(
              store.status == VectorStoreStatus.inProgress ||
                  store.status == VectorStoreStatus.completed,
              isTrue,
            );

            // Poll until the store is ready
            var attempts = 0;
            while (!store.isReady &&
                store.status != VectorStoreStatus.expired &&
                attempts < 90) {
              await Future<void>.delayed(const Duration(seconds: 1));
              store = await client!.beta.vectorStores.retrieve(store.id);
              attempts++;
            }

            expect(
              store.isReady,
              isTrue,
              reason: 'Store should be ready after processing',
            );
            expect(store.status, VectorStoreStatus.completed);

            // Verify file counts
            expect(store.fileCounts.inProgress, 0);
            expect(store.fileCounts.completed, 1);
            expect(store.fileCounts.failed, 0);
            expect(store.fileCounts.cancelled, 0);
            expect(store.fileCounts.total, 1);

            // Verify the file in the store
            final files = await client!.beta.vectorStores.files.list(store.id);

            expect(files.data.length, 1);
            expect(files.data.first.id, file.id);
            expect(files.data.first.isReady, isTrue);
            expect(files.data.first.vectorStoreId, store.id);

            // Verify usage bytes is populated
            expect(store.usageBytes, greaterThan(0));
          } finally {
            await client!.beta.vectorStores.delete(store.id);
          }
        } finally {
          await client!.files.delete(file.id);
        }
      },
    );
  });
}
