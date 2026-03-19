// ignore_for_file: avoid_print, unused_local_variable
/// Example demonstrating the Uploads API for large file uploads.
///
/// The Uploads API allows uploading files larger than 512 MB by splitting
/// them into parts.
///
/// Run with: dart run example/uploads_example.dart
library;

import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    // Create an upload
    print('=== Create Upload ===\n');

    final data = utf8.encode('{"prompt": "Hello", "completion": "Hi"}\n');

    final upload = await client.uploads.create(
      CreateUploadRequest(
        filename: 'training-data.jsonl',
        purpose: FilePurpose.fineTune,
        bytes: data.length,
        mimeType: 'application/jsonl',
      ),
    );

    print('Upload ID: ${upload.id}');
    print('Status: ${upload.status}\n');

    // Add a part
    print('=== Add Part ===\n');

    final part = await client.uploads.addPart(upload.id, data: data);
    print('Part ID: ${part.id}\n');

    // Complete the upload
    print('=== Complete Upload ===\n');

    final completed = await client.uploads.complete(
      upload.id,
      partIds: [part.id],
    );

    print('Status: ${completed.status}');
    if (completed.file != null) {
      print('File ID: ${completed.file!.id}');
    }
    print('');
  } on OpenAIException catch (e) {
    print('OpenAI error: ${e.message}');
    if (e is ApiException) {
      print('Status: ${e.statusCode}');
    }
  } finally {
    client.close();
    print('Done!');
  }
}
