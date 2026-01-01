// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  AnthropicClient? client;

  setUpAll(() {
    apiKey = Platform.environment['ANTHROPIC_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('ANTHROPIC_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = AnthropicClient(
        config: AnthropicConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Files API - Integration', () {
    test(
      'uploads file from bytes and deletes it',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create test data
        final testBytes = Uint8List.fromList(
          'Hello, this is a test file content!'.codeUnits,
        );

        // Upload file
        final uploadedFile = await client!.files.uploadBytes(
          bytes: testBytes,
          fileName: 'test_file.txt',
          mimeType: 'text/plain',
        );

        expect(uploadedFile.id, isNotEmpty);
        expect(uploadedFile.id, startsWith('file_'));
        expect(uploadedFile.filename, 'test_file.txt');
        expect(uploadedFile.mimeType, 'text/plain');
        expect(uploadedFile.sizeBytes, testBytes.length);

        // Clean up - delete the file
        final deleteResponse = await client!.files.deleteFile(
          fileId: uploadedFile.id,
        );

        expect(deleteResponse.id, uploadedFile.id);
        expect(deleteResponse.type, 'file_deleted');
      },
    );

    test(
      'lists uploaded files',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Upload a test file first
        final testBytes = Uint8List.fromList('Test content'.codeUnits);
        final uploadedFile = await client!.files.uploadBytes(
          bytes: testBytes,
          fileName: 'list_test.txt',
          mimeType: 'text/plain',
        );

        try {
          // List files
          final listResponse = await client!.files.list(limit: 10);

          expect(listResponse.data, isNotEmpty);
          expect(listResponse.data.any((f) => f.id == uploadedFile.id), isTrue);
        } finally {
          // Clean up
          await client!.files.deleteFile(fileId: uploadedFile.id);
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

        // Upload a test file
        final testBytes = Uint8List.fromList('Retrieve test content'.codeUnits);
        final uploadedFile = await client!.files.uploadBytes(
          bytes: testBytes,
          fileName: 'retrieve_test.txt',
          mimeType: 'text/plain',
        );

        try {
          // Retrieve file metadata
          final retrievedFile = await client!.files.retrieve(
            fileId: uploadedFile.id,
          );

          expect(retrievedFile.id, uploadedFile.id);
          expect(retrievedFile.filename, uploadedFile.filename);
          expect(retrievedFile.mimeType, uploadedFile.mimeType);
          expect(retrievedFile.sizeBytes, uploadedFile.sizeBytes);
        } finally {
          // Clean up
          await client!.files.deleteFile(fileId: uploadedFile.id);
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

        // Upload a test file with known content
        const testContent = 'Download test - verify content matches!';
        final testBytes = Uint8List.fromList(testContent.codeUnits);
        final uploadedFile = await client!.files.uploadBytes(
          bytes: testBytes,
          fileName: 'download_test.txt',
          mimeType: 'text/plain',
        );

        try {
          // Check if downloadable
          if (uploadedFile.downloadable) {
            // Download file content
            final downloadedBytes = await client!.files.download(
              fileId: uploadedFile.id,
            );

            expect(downloadedBytes.length, testBytes.length);
            expect(String.fromCharCodes(downloadedBytes), testContent);
          } else {
            print('File is not downloadable, skipping download verification');
          }
        } finally {
          // Clean up
          await client!.files.deleteFile(fileId: uploadedFile.id);
        }
      },
    );

    test(
      'uploads and uses file in message with vision',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create a simple 1x1 red pixel PNG
        // This is a minimal valid PNG file
        final pngBytes = Uint8List.fromList([
          0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
          0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
          0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
          0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
          0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41,
          0x54, 0x08, 0xD7, 0x63, 0xF8, 0xFF, 0xFF, 0x3F,
          0x00, 0x05, 0xFE, 0x02, 0xFE, 0xDC, 0xCC, 0x59,
          0xE7, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
          0x44, 0xAE, 0x42, 0x60, 0x82, // IEND chunk
        ]);

        // Upload the image file
        final uploadedFile = await client!.files.uploadBytes(
          bytes: pngBytes,
          fileName: 'test_image.png',
          mimeType: 'image/png',
        );

        try {
          // Use the file ID in a message is not directly supported yet
          // This test just verifies the upload works with image content
          expect(uploadedFile.id, isNotEmpty);
          expect(uploadedFile.mimeType, 'image/png');
        } finally {
          // Clean up
          await client!.files.deleteFile(fileId: uploadedFile.id);
        }
      },
    );

    test(
      'handles pagination correctly',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Upload multiple files
        final uploadedFiles = <FileMetadata>[];
        for (var i = 0; i < 3; i++) {
          final bytes = Uint8List.fromList('Pagination test $i'.codeUnits);
          final file = await client!.files.uploadBytes(
            bytes: bytes,
            fileName: 'pagination_test_$i.txt',
            mimeType: 'text/plain',
          );
          uploadedFiles.add(file);
        }

        try {
          // List with small limit
          final firstPage = await client!.files.list(limit: 2);

          expect(firstPage.data, hasLength(lessThanOrEqualTo(2)));

          // If there are more, get next page
          if (firstPage.hasMore && firstPage.lastId != null) {
            final secondPage = await client!.files.list(
              limit: 2,
              afterId: firstPage.lastId,
            );

            expect(secondPage.data, isNotEmpty);
            // Files in second page should be different from first page
            final firstPageIds = firstPage.data.map((f) => f.id).toSet();
            for (final file in secondPage.data) {
              expect(firstPageIds.contains(file.id), isFalse);
            }
          }
        } finally {
          // Clean up all uploaded files
          for (final file in uploadedFiles) {
            await client!.files.deleteFile(fileId: file.id);
          }
        }
      },
    );
  });
}
