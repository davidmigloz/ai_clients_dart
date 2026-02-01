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

  group('Files - Integration', () {
    test('lists files', timeout: const Timeout(Duration(minutes: 2)), () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final files = await client!.files.list();

      expect(files.object, 'list');
      expect(files.data, isA<List<FileObject>>());
      // May be empty if no files uploaded
    });

    test(
      'uploads, retrieves, and deletes a file',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a simple JSONL file for fine-tuning
        final content = [
          {
            'messages': [
              {'role': 'user', 'content': 'Hello'},
              {'role': 'assistant', 'content': 'Hi there!'},
            ],
          },
          {
            'messages': [
              {'role': 'user', 'content': 'How are you?'},
              {'role': 'assistant', 'content': 'I am doing well!'},
            ],
          },
          // ignore: unnecessary_lambdas
        ].map((e) => jsonEncode(e)).join('\n');

        final bytes = utf8.encode(content);

        // Upload
        final uploaded = await client!.files.upload(
          bytes: bytes,
          filename: 'test_training.jsonl',
          purpose: FilePurpose.fineTune,
        );

        expect(uploaded.id, isNotEmpty);
        expect(uploaded.filename, 'test_training.jsonl');
        expect(uploaded.purpose, FilePurpose.fineTune);
        expect(uploaded.bytes, greaterThan(0));

        final fileId = uploaded.id;

        try {
          // Retrieve
          final retrieved = await client!.files.retrieve(fileId);

          expect(retrieved.id, fileId);
          expect(retrieved.filename, 'test_training.jsonl');
          expect(retrieved.object, 'file');

          // List with filter
          final filtered = await client!.files.list(
            purpose: FilePurpose.fineTune,
          );

          expect(
            filtered.data.any((f) => f.id == fileId),
            isTrue,
            reason: 'Uploaded file should be in filtered list',
          );
        } finally {
          // Clean up - delete the file
          final deleted = await client!.files.delete(fileId);

          expect(deleted.id, fileId);
          expect(deleted.deleted, isTrue);
        }
      },
    );

    test(
      'retrieves file content',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create and upload a file
        const originalContent = 'Test file content for retrieval';
        final bytes = utf8.encode(originalContent);

        final uploaded = await client!.files.upload(
          bytes: bytes,
          filename: 'test_content.txt',
          purpose: FilePurpose.assistants,
        );

        final fileId = uploaded.id;

        try {
          // Wait a bit for processing
          await Future<void>.delayed(const Duration(seconds: 2));

          // Try to retrieve content (may fail if file is still processing)
          try {
            final content = await client!.files.retrieveContent(fileId);
            expect(content, isNotEmpty);
          } on OpenAIException catch (e) {
            // Content retrieval may not be available for all file types
            print('Content retrieval note: ${e.message}');
          }
        } finally {
          // Clean up
          await client!.files.delete(fileId);
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

        // List with limit
        final files = await client!.files.list(limit: 5);

        expect(files.data.length, lessThanOrEqualTo(5));
      },
    );
  });
}
