// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Files API example (Beta).
///
/// This example demonstrates:
/// - Uploading files to the API
/// - Listing uploaded files
/// - Retrieving file metadata
/// - Downloading files
/// - Deleting files
///
/// Note: The Files API is a beta feature and requires the anthropic-beta header.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Upload a file from path
    print('=== Upload File ===');
    const filePath = 'example/sample_image.jpg';
    final file = File(filePath);

    if (file.existsSync()) {
      final uploadedFile = await client.files.upload(
        filePath: filePath,
        mimeType: 'image/jpeg',
      );

      print('File uploaded:');
      print('  ID: ${uploadedFile.id}');
      print('  Filename: ${uploadedFile.filename}');
      print('  MIME type: ${uploadedFile.mimeType}');
      print('  Size: ${uploadedFile.sizeBytes} bytes');
      print('  Created at: ${uploadedFile.createdAt}');

      // Example 2: List files
      print('\n=== List Files ===');
      final fileList = await client.files.list(limit: 10);

      print('Files (${fileList.data.length} total):');
      for (final f in fileList.data) {
        print('  - ${f.id}: ${f.filename} (${f.sizeBytes} bytes)');
      }
      print('Has more: ${fileList.hasMore}');

      // Example 3: Retrieve file metadata
      print('\n=== Retrieve File ===');
      final retrievedFile = await client.files.retrieve(
        fileId: uploadedFile.id,
      );

      print('File details:');
      print('  ID: ${retrievedFile.id}');
      print('  Filename: ${retrievedFile.filename}');
      print('  MIME type: ${retrievedFile.mimeType}');
      print('  Size: ${retrievedFile.sizeBytes} bytes');
      print('  Downloadable: ${retrievedFile.downloadable}');

      // Example 4: Download file content
      print('\n=== Download File ===');
      if (retrievedFile.downloadable) {
        final bytes = await client.files.download(fileId: uploadedFile.id);
        print('Downloaded ${bytes.length} bytes');

        // You could save the file:
        // await File('downloaded_file.jpg').writeAsBytes(bytes);
      } else {
        print('File is not downloadable');
      }

      // Example 5: Delete file
      print('\n=== Delete File ===');
      final deleteResponse = await client.files.deleteFile(
        fileId: uploadedFile.id,
      );
      print('Deleted file: ${deleteResponse.id}');
    } else {
      print('No sample file found at $filePath');
      print('To test file upload:');
      print('1. Place an image file at $filePath');
      print('2. Run this example again');

      print('\nDemonstrating upload from bytes instead...');

      // Upload from bytes
      final bytes = Uint8List.fromList(List.generate(100, (i) => i % 256));
      final uploadedFromBytes = await client.files.uploadBytes(
        bytes: bytes,
        fileName: 'test_file.bin',
        mimeType: 'application/octet-stream',
      );

      print('Uploaded from bytes:');
      print('  ID: ${uploadedFromBytes.id}');
      print('  Size: ${uploadedFromBytes.sizeBytes} bytes');

      // Clean up
      await client.files.deleteFile(fileId: uploadedFromBytes.id);
      print('Cleaned up test file');
    }
  } finally {
    client.close();
  }
}
