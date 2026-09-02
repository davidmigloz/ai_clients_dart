// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Files API example.
///
/// This example demonstrates:
/// - Uploading files to the API (optionally with an expiration)
/// - Listing uploaded files (page-cursor pagination)
/// - Retrieving file metadata
/// - Downloading files
/// - Deleting files
///
/// Note: The Files API is generally available and does not require an
/// anthropic-beta header.
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
        expiresInSeconds: 86400, // Expires in 1 day.
      );

      print('File uploaded:');
      print('  ID: ${uploadedFile.id}');
      print('  Filename: ${uploadedFile.filename}');
      print('  MIME type: ${uploadedFile.mimeType}');
      print('  Size: ${uploadedFile.sizeBytes} bytes');
      print('  Created at: ${uploadedFile.createdAt}');
      print('  Expires at: ${uploadedFile.expiresAt}');

      // Example 2: List files, following page cursors.
      print('\n=== List Files ===');
      var fileList = await client.files.list(limit: 10);
      var totalListed = 0;
      while (true) {
        for (final f in fileList.data) {
          print('  - ${f.id}: ${f.filename} (${f.sizeBytes} bytes)');
          totalListed++;
        }
        final nextPage = fileList.nextPage;
        if (nextPage == null) break;
        fileList = await client.files.list(limit: 10, page: nextPage);
      }
      print('Listed $totalListed file(s) total.');

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
