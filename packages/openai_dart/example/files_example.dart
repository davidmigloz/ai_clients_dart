// ignore_for_file: avoid_print
/// Example demonstrating file operations with OpenAI.
///
/// This example shows how to upload, list, and manage files.
/// Run with: dart run example/files_example.dart
library;

import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  // Create client from environment variable
  final client = OpenAIClient.fromEnvironment();

  String? uploadedFileId;

  try {
    // List existing files
    print('=== List Existing Files ===\n');

    final existingFiles = await client.files.list();
    print('Found ${existingFiles.data.length} file(s):');
    for (final file in existingFiles.data) {
      print('  - ${file.filename} (${file.id})');
      print('    Purpose: ${file.purpose}, Size: ${file.bytes} bytes');
    }
    print('');

    // Create a sample JSONL file for fine-tuning
    print('=== Upload File ===\n');

    final trainingData = [
      {
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant.'},
          {'role': 'user', 'content': 'What is 2+2?'},
          {'role': 'assistant', 'content': 'The answer is 4.'},
        ],
      },
      {
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant.'},
          {'role': 'user', 'content': 'What is the capital of France?'},
          {'role': 'assistant', 'content': 'Paris is the capital of France.'},
        ],
      },
      {
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant.'},
          {'role': 'user', 'content': 'What color is the sky?'},
          {
            'role': 'assistant',
            'content': 'The sky is typically blue during the day.',
          },
        ],
      },
    ];

    // Convert to JSONL format
    final jsonlContent = trainingData.map(jsonEncode).join('\n');
    final fileBytes = utf8.encode(jsonlContent);

    print('Uploading training data (${fileBytes.length} bytes)...');

    final uploaded = await client.files.upload(
      bytes: fileBytes,
      filename: 'training_data.jsonl',
      purpose: FilePurpose.fineTune,
    );

    uploadedFileId = uploaded.id;
    print('Uploaded file: ${uploaded.filename}');
    print('  ID: ${uploaded.id}');
    print('  Purpose: ${uploaded.purpose}');
    print('  Size: ${uploaded.bytes} bytes');
    print('  Status: ${uploaded.status}');
    print('  Created: ${uploaded.createdAtDateTime}\n');

    // Retrieve file info
    print('=== Retrieve File ===\n');

    final retrieved = await client.files.retrieve(uploaded.id);
    print('Retrieved file: ${retrieved.filename}');
    print('  ID: ${retrieved.id}');
    print('  Object: ${retrieved.object}\n');

    // List files with filter
    print('=== List Files by Purpose ===\n');

    final fineTuneFiles = await client.files.list(
      purpose: FilePurpose.fineTune,
    );

    print('Fine-tune files: ${fineTuneFiles.data.length}');
    for (final file in fineTuneFiles.data) {
      print('  - ${file.filename}');
    }
    print('');

    // List with pagination
    print('=== List with Pagination ===\n');

    final paginatedFiles = await client.files.list(limit: 3, order: 'desc');

    print('Most recent ${paginatedFiles.data.length} files:');
    for (final file in paginatedFiles.data) {
      print('  - ${file.filename} (${file.createdAtDateTime})');
    }
    print('');

    // Upload for assistants
    print('=== Upload for Assistants ===\n');

    const assistantsContent =
        'This is a sample document for assistants.\n'
        'It contains some text that can be used for testing.\n'
        'The assistants API can use this file for retrieval.';

    final assistantsFile = await client.files.upload(
      bytes: utf8.encode(assistantsContent),
      filename: 'sample_document.txt',
      purpose: FilePurpose.assistants,
    );

    print('Uploaded assistants file: ${assistantsFile.filename}');
    print('  ID: ${assistantsFile.id}\n');

    // Clean up assistants file
    final deletedAssistants = await client.files.delete(assistantsFile.id);
    print('Deleted assistants file: ${deletedAssistants.deleted}\n');
  } on OpenAIException catch (e) {
    print('OpenAI error: ${e.message}');
    if (e is ApiException) {
      print('Status: ${e.statusCode}');
    }
  } finally {
    // Clean up
    print('=== Cleanup ===\n');

    if (uploadedFileId != null) {
      final deleted = await client.files.delete(uploadedFileId);
      print('Deleted file: ${deleted.id}');
      print('  Deleted: ${deleted.deleted}');
    }

    client.close();
    print('\nDone!');
  }
}
