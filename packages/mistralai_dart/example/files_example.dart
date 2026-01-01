// ignore_for_file: avoid_print, unreachable_from_main
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating file upload and management.
///
/// Files can be uploaded for use in fine-tuning, batch processing,
/// OCR, and audio transcription tasks.
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    exit(1);
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    await listFiles(client);
    // Uncomment to test file upload (requires a valid JSONL file)
    // await uploadFile(client);
  } finally {
    client.close();
  }
}

/// List all uploaded files.
Future<void> listFiles(MistralClient client) async {
  print('=== List Files ===\n');

  final files = await client.files.list();

  print('Total files: ${files.total ?? files.data.length}');
  print('');

  if (files.data.isEmpty) {
    print('No files found.');
  } else {
    for (final file in files.data) {
      print('- ${file.filename}');
      print('  ID: ${file.id}');
      print('  Purpose: ${filePurposeToString(file.purpose)}');
      print('  Size: ${file.bytes} bytes');
      print(
        '  Created: ${DateTime.fromMillisecondsSinceEpoch(file.createdAt * 1000)}',
      );
      if (file.numLines != null) {
        print('  Lines: ${file.numLines}');
      }
      print('');
    }
  }
}

/// Upload a file for fine-tuning.
Future<void> uploadFile(MistralClient client) async {
  print('=== Upload File ===\n');

  // Example: Upload a JSONL file for fine-tuning
  const filePath = 'training_data.jsonl';

  if (!File(filePath).existsSync()) {
    print('File not found: $filePath');
    print('Create a JSONL file with training data to test upload.');
    return;
  }

  final file = await client.files.upload(
    filePath: filePath,
    purpose: FilePurpose.fineTune,
  );

  print('File uploaded successfully!');
  print('ID: ${file.id}');
  print('Filename: ${file.filename}');
  print('Size: ${file.bytes} bytes');
  print('');
}

/// Retrieve file details.
Future<void> retrieveFile(MistralClient client, String fileId) async {
  print('=== Retrieve File ===\n');

  final file = await client.files.retrieve(fileId: fileId);

  print('File: ${file.filename}');
  print('ID: ${file.id}');
  print('Purpose: ${filePurposeToString(file.purpose)}');
  print('Size: ${file.bytes} bytes');
  print('');
}

/// Download file content.
Future<void> downloadFile(MistralClient client, String fileId) async {
  print('=== Download File ===\n');

  final bytes = await client.files.download(fileId: fileId);

  print('Downloaded ${bytes.length} bytes');
  print('');
}

/// Get a signed URL for downloading.
Future<void> getSignedUrl(MistralClient client, String fileId) async {
  print('=== Get Signed URL ===\n');

  final signedUrl = await client.files.getSignedUrl(
    fileId: fileId,
    expiresIn: 3600, // 1 hour
  );

  print('Signed URL: ${signedUrl.url}');
  if (signedUrl.expiresAt != null) {
    print(
      'Expires: ${DateTime.fromMillisecondsSinceEpoch(signedUrl.expiresAt! * 1000)}',
    );
  }
  print('');
}

/// Delete a file.
Future<void> deleteFile(MistralClient client, String fileId) async {
  print('=== Delete File ===\n');

  final file = await client.files.delete(fileId: fileId);

  print('File deleted: ${file.filename}');
  print('');
}
