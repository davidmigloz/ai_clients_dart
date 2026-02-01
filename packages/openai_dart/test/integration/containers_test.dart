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

  group('Containers API - Integration', () {
    test(
      'lists containers',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final containers = await client!.containers.list();

        expect(containers.object, 'list');
        expect(containers.data, isA<List<Container>>());
        // May be empty if no containers exist
      },
    );

    test(
      'lists containers with pagination parameters',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // List with limit
        final containers = await client!.containers.list(limit: 5);

        expect(containers.data.length, lessThanOrEqualTo(5));

        // Test order parameter
        final ascList = await client!.containers.list(limit: 10, order: 'asc');
        expect(ascList.data, isA<List<Container>>());

        final descList = await client!.containers.list(
          limit: 10,
          order: 'desc',
        );
        expect(descList.data, isA<List<Container>>());
      },
    );

    test(
      'creates container with minimal config',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final container = await client!.containers.create(
          CreateContainerRequest(name: 'test-container-$timestamp'),
        );

        try {
          expect(container.id, isNotEmpty);
          expect(container.object, 'container');
          expect(container.name, 'test-container-$timestamp');
          expect(container.createdAt, greaterThan(0));
          expect(container.status, isNotEmpty);
        } finally {
          await client!.containers.delete(container.id);
        }
      },
    );

    test(
      'creates container with full config',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final container = await client!.containers.create(
          CreateContainerRequest(
            name: 'test-full-container-$timestamp',
            expiresAfter: const ContainerExpiration(
              anchor: 'last_active_at',
              minutes: 20, // Maximum allowed is 20
            ),
          ),
        );

        try {
          expect(container.id, isNotEmpty);
          expect(container.name, 'test-full-container-$timestamp');
          expect(container.expiresAfter, isNotNull);
          expect(container.expiresAfter!.anchor, 'last_active_at');
          expect(container.expiresAfter!.minutes, 20);
        } finally {
          await client!.containers.delete(container.id);
        }
      },
    );

    test(
      'retrieves container by ID',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final created = await client!.containers.create(
          CreateContainerRequest(name: 'test-retrieve-$timestamp'),
        );

        try {
          final retrieved = await client!.containers.retrieve(created.id);

          expect(retrieved.id, created.id);
          expect(retrieved.name, created.name);
          expect(retrieved.object, 'container');
          expect(retrieved.createdAt, created.createdAt);
          expect(retrieved.status, created.status);
        } finally {
          await client!.containers.delete(created.id);
        }
      },
    );

    test(
      'validates container helper methods',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final container = await client!.containers.create(
          CreateContainerRequest(name: 'test-helpers-$timestamp'),
        );

        try {
          // Test status - may be 'running' or 'active' depending on state
          expect(container.status, isNotEmpty);

          // Test createdAtDateTime helper
          expect(container.createdAtDateTime, isA<DateTime>());
          expect(
            container.createdAtDateTime.millisecondsSinceEpoch,
            container.createdAt * 1000,
          );

          // lastActiveAtDateTime may be null for new containers
          if (container.lastActiveAt != null) {
            expect(container.lastActiveAtDateTime, isA<DateTime>());
          }
        } finally {
          await client!.containers.delete(container.id);
        }
      },
    );

    test(
      'deletes container',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final container = await client!.containers.create(
          CreateContainerRequest(name: 'test-delete-$timestamp'),
        );

        final deleted = await client!.containers.delete(container.id);

        expect(deleted.id, container.id);
        expect(deleted.object, 'container.deleted');
        expect(deleted.deleted, isTrue);
      },
    );
  });

  group('Container Files API - Integration', () {
    late Container testContainer;

    setUpAll(() async {
      if (apiKey != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        testContainer = await client!.containers.create(
          CreateContainerRequest(name: 'files-test-container-$timestamp'),
        );
      }
    });

    tearDownAll(() async {
      if (apiKey != null) {
        await client!.containers.delete(testContainer.id);
      }
    });

    test(
      'uploads file with bytes and filename',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final content = utf8.encode('Hello, Container!');

        final file = await client!.containers.files.create(
          testContainer.id,
          bytes: content,
          filename: '/test/hello.txt',
        );

        try {
          expect(file.id, isNotEmpty);
          expect(file.object, 'container.file');
          // API returns path with /mnt/data/ prefix and hashed name
          expect(file.path, contains('hello.txt'));
          expect(file.bytes, content.length);
          expect(file.containerId, testContainer.id);
          expect(file.createdAt, greaterThan(0));
        } finally {
          await client!.containers.files.delete(testContainer.id, file.id);
        }
      },
    );

    test(
      'lists files in container',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a file first
        final content = utf8.encode('Test file for listing');
        final file = await client!.containers.files.create(
          testContainer.id,
          bytes: content,
          filename: '/list-test/file.txt',
        );

        try {
          final files = await client!.containers.files.list(testContainer.id);

          expect(files.object, 'list');
          expect(files.data, isA<List<ContainerFile>>());
          expect(
            files.data.any((f) => f.id == file.id),
            isTrue,
            reason: 'Created file should be in list',
          );
        } finally {
          await client!.containers.files.delete(testContainer.id, file.id);
        }
      },
    );

    test(
      'lists files with pagination',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create multiple files
        final file1 = await client!.containers.files.create(
          testContainer.id,
          bytes: utf8.encode('File 1'),
          filename: '/pagination/file1.txt',
        );
        final file2 = await client!.containers.files.create(
          testContainer.id,
          bytes: utf8.encode('File 2'),
          filename: '/pagination/file2.txt',
        );

        try {
          // List with limit 1
          final page1 = await client!.containers.files.list(
            testContainer.id,
            limit: 1,
          );

          expect(page1.data.length, 1);

          if (page1.hasMore) {
            // Paginate using after
            final page2 = await client!.containers.files.list(
              testContainer.id,
              limit: 1,
              after: page1.lastId,
            );

            expect(page2.data, isNotEmpty);
            expect(page2.data.first.id, isNot(page1.data.first.id));
          }

          // Test order parameter
          final ascList = await client!.containers.files.list(
            testContainer.id,
            order: 'asc',
          );
          expect(ascList.data, isNotEmpty);

          final descList = await client!.containers.files.list(
            testContainer.id,
            order: 'desc',
          );
          expect(descList.data, isNotEmpty);
        } finally {
          await client!.containers.files.delete(testContainer.id, file1.id);
          await client!.containers.files.delete(testContainer.id, file2.id);
        }
      },
    );

    test(
      'retrieves file metadata',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final content = utf8.encode('Content for retrieval test');
        final created = await client!.containers.files.create(
          testContainer.id,
          bytes: content,
          filename: '/retrieve-test/data.txt',
        );

        try {
          final retrieved = await client!.containers.files.retrieve(
            testContainer.id,
            created.id,
          );

          expect(retrieved.id, created.id);
          expect(retrieved.object, 'container.file');
          // API returns path with /mnt/data/ prefix and hashed name
          expect(retrieved.path, contains('data.txt'));
          expect(retrieved.bytes, content.length);
          expect(retrieved.containerId, testContainer.id);
          expect(retrieved.createdAt, created.createdAt);
        } finally {
          await client!.containers.files.delete(testContainer.id, created.id);
        }
      },
    );

    test(
      'validates file fields and helpers',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final content = utf8.encode('Validation test content');
        final file = await client!.containers.files.create(
          testContainer.id,
          bytes: content,
          filename: '/validation/test.txt',
        );

        try {
          // Validate all expected fields
          expect(file.id, isNotEmpty);
          expect(file.object, 'container.file');
          expect(file.containerId, testContainer.id);
          expect(file.createdAt, greaterThan(0));
          expect(file.bytes, content.length);
          // API returns path with /mnt/data/ prefix and hashed name
          expect(file.path, contains('test.txt'));

          // Test createdAtDateTime helper
          expect(file.createdAtDateTime, isA<DateTime>());
          expect(
            file.createdAtDateTime.millisecondsSinceEpoch,
            file.createdAt * 1000,
          );
        } finally {
          await client!.containers.files.delete(testContainer.id, file.id);
        }
      },
    );

    test(
      'downloads file content',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        const originalContent = 'Hello, World! This is test content.';
        final contentBytes = utf8.encode(originalContent);

        final file = await client!.containers.files.create(
          testContainer.id,
          bytes: contentBytes,
          filename: '/download-test/content.txt',
        );

        try {
          final downloaded = await client!.containers.files.retrieveContent(
            testContainer.id,
            file.id,
          );

          expect(downloaded, contentBytes);
          expect(utf8.decode(downloaded), originalContent);
        } finally {
          await client!.containers.files.delete(testContainer.id, file.id);
        }
      },
    );

    test(
      'deletes file from container',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final content = utf8.encode('File to be deleted');
        final file = await client!.containers.files.create(
          testContainer.id,
          bytes: content,
          filename: '/delete-test/file.txt',
        );

        final deleted = await client!.containers.files.delete(
          testContainer.id,
          file.id,
        );

        expect(deleted.id, file.id);
        expect(deleted.object, 'container.file.deleted');
        expect(deleted.deleted, isTrue);

        // Verify file is no longer in the list
        final files = await client!.containers.files.list(testContainer.id);
        expect(
          files.data.any((f) => f.id == file.id),
          isFalse,
          reason: 'Deleted file should not be in list',
        );
      },
    );
  });

  group('Full Container Workflow - Integration', () {
    test(
      'complete workflow: create → upload → verify → download → cleanup',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Step 1: Create a container
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final container = await client!.containers.create(
          CreateContainerRequest(
            name: 'workflow-test-$timestamp',
            expiresAfter: const ContainerExpiration(
              anchor: 'last_active_at',
              minutes: 20, // Maximum allowed is 20
            ),
          ),
        );

        expect(container.id, isNotEmpty);
        expect(container.status, isNotEmpty);

        try {
          // Step 2: Upload multiple files
          final file1Content = utf8.encode('print("Hello from Python!")');
          final file1 = await client!.containers.files.create(
            container.id,
            bytes: file1Content,
            filename: '/app/script.py',
          );

          final file2Content = utf8.encode(
            '{"name": "test", "version": "1.0"}',
          );
          final file2 = await client!.containers.files.create(
            container.id,
            bytes: file2Content,
            filename: '/app/config.json',
          );

          expect(file1.id, isNotEmpty);
          expect(file2.id, isNotEmpty);
          expect(file1.containerId, container.id);
          expect(file2.containerId, container.id);

          // Step 3: Verify files are in the container
          final files = await client!.containers.files.list(container.id);

          expect(files.data.length, 2);
          // API returns paths with /mnt/data/ prefix and hashed names
          expect(files.data.any((f) => f.path.contains('script.py')), isTrue);
          expect(files.data.any((f) => f.path.contains('config.json')), isTrue);

          // Step 4: Download and verify content
          final downloaded1 = await client!.containers.files.retrieveContent(
            container.id,
            file1.id,
          );
          expect(utf8.decode(downloaded1), 'print("Hello from Python!")');

          final downloaded2 = await client!.containers.files.retrieveContent(
            container.id,
            file2.id,
          );
          expect(
            utf8.decode(downloaded2),
            '{"name": "test", "version": "1.0"}',
          );

          // Step 5: Clean up files
          await client!.containers.files.delete(container.id, file1.id);
          await client!.containers.files.delete(container.id, file2.id);

          // Verify files are deleted
          final remainingFiles = await client!.containers.files.list(
            container.id,
          );
          expect(remainingFiles.data, isEmpty);
        } finally {
          // Step 6: Delete container
          final deleted = await client!.containers.delete(container.id);
          expect(deleted.deleted, isTrue);
        }
      },
    );
  });

  group('Error Handling - Integration', () {
    test(
      'throws on invalid container ID',
      timeout: const Timeout(Duration(minutes: 1)),
      () {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        expect(
          () => client!.containers.retrieve('invalid-container-id-12345'),
          throwsA(isA<OpenAIException>()),
        );
      },
    );

    test(
      'throws on invalid file ID',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a container first
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final container = await client!.containers.create(
          CreateContainerRequest(name: 'error-test-$timestamp'),
        );

        try {
          expect(
            () => client!.containers.files.retrieve(
              container.id,
              'invalid-file-id-12345',
            ),
            throwsA(isA<OpenAIException>()),
          );
        } finally {
          await client!.containers.delete(container.id);
        }
      },
    );
  });
}
