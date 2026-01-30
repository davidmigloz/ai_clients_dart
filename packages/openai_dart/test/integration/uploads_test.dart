// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';
import 'dart:math';

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

  group('Uploads - Integration', () {
    // Minimum part size is 5MB (except for last part)
    const minPartSize = 5 * 1024 * 1024; // 5 MB

    /// Generates random test data of the specified size.
    List<int> generateTestData(int sizeInBytes) {
      final random = Random();
      return List.generate(sizeInBytes, (_) => random.nextInt(256));
    }

    test(
      'complete upload workflow with multiple parts',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Total file size: 10MB (2 parts of 5MB each)
        const totalBytes = minPartSize * 2;
        const partSize = minPartSize;

        // Create upload session
        final upload = await client!.uploads.create(
          const CreateUploadRequest(
            filename: 'test_upload.jsonl',
            purpose: FilePurpose.fineTune,
            bytes: totalBytes,
            mimeType: 'application/jsonl',
          ),
        );

        expect(upload.id, isNotEmpty);
        expect(upload.object, 'upload');
        expect(upload.filename, 'test_upload.jsonl');
        expect(upload.purpose, FilePurpose.fineTune);
        expect(upload.bytes, totalBytes);
        expect(upload.status, UploadStatus.pending);
        expect(upload.isPending, isTrue);

        print('Created upload: ${upload.id}');

        String? createdFileId;
        try {
          // Add part 1
          final part1Data = generateTestData(partSize);
          final part1 = await client!.uploads.addPart(
            upload.id,
            data: part1Data,
          );

          expect(part1.id, isNotEmpty);
          expect(part1.object, 'upload.part');
          expect(part1.uploadId, upload.id);
          expect(part1.createdAt, greaterThan(0));

          print('Added part 1: ${part1.id}');

          // Add part 2
          final part2Data = generateTestData(partSize);
          final part2 = await client!.uploads.addPart(
            upload.id,
            data: part2Data,
          );

          expect(part2.id, isNotEmpty);
          expect(part2.object, 'upload.part');
          expect(part2.uploadId, upload.id);

          print('Added part 2: ${part2.id}');

          // Complete the upload with ordered part IDs
          final completed = await client!.uploads.complete(
            upload.id,
            partIds: [part1.id, part2.id],
          );

          expect(completed.id, upload.id);
          expect(completed.status, UploadStatus.completed);
          expect(completed.isCompleted, isTrue);
          expect(completed.file, isNotNull);
          expect(completed.file!.id, isNotEmpty);

          createdFileId = completed.file!.id;
          print('Upload completed. File ID: $createdFileId');

          // Verify the file object
          expect(completed.file!.object, 'file');
          expect(completed.file!.purpose, FilePurpose.fineTune);
        } finally {
          // Clean up: delete the created file if it exists
          if (createdFileId != null) {
            try {
              await client!.files.delete(createdFileId);
              print('Cleaned up file: $createdFileId');
            } catch (e) {
              print('Cleanup note: Could not delete file $createdFileId: $e');
            }
          }
        }
      },
    );

    test(
      'single part upload',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Single part can be any size as it's both first and last
        // Using minimum size for the test
        const totalBytes = minPartSize;

        // Create upload session
        final upload = await client!.uploads.create(
          const CreateUploadRequest(
            filename: 'test_single_part.jsonl',
            purpose: FilePurpose.fineTune,
            bytes: totalBytes,
            mimeType: 'application/jsonl',
          ),
        );

        expect(upload.status, UploadStatus.pending);
        print('Created single-part upload: ${upload.id}');

        String? createdFileId;
        try {
          // Add single part
          final partData = generateTestData(totalBytes);
          final part = await client!.uploads.addPart(upload.id, data: partData);

          expect(part.id, isNotEmpty);
          expect(part.uploadId, upload.id);
          print('Added single part: ${part.id}');

          // Complete the upload
          final completed = await client!.uploads.complete(
            upload.id,
            partIds: [part.id],
          );

          expect(completed.status, UploadStatus.completed);
          expect(completed.isCompleted, isTrue);
          expect(completed.file, isNotNull);

          createdFileId = completed.file!.id;
          print('Single-part upload completed. File ID: $createdFileId');
        } finally {
          // Clean up
          if (createdFileId != null) {
            try {
              await client!.files.delete(createdFileId);
              print('Cleaned up file: $createdFileId');
            } catch (e) {
              print('Cleanup note: Could not delete file $createdFileId: $e');
            }
          }
        }
      },
    );

    test(
      'cancel upload',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create upload session
        final upload = await client!.uploads.create(
          const CreateUploadRequest(
            filename: 'test_cancel.jsonl',
            purpose: FilePurpose.fineTune,
            bytes: minPartSize * 2,
            mimeType: 'application/jsonl',
          ),
        );

        expect(upload.status, UploadStatus.pending);
        expect(upload.isPending, isTrue);
        print('Created upload to cancel: ${upload.id}');

        // Optionally add a part before cancelling
        final partData = generateTestData(minPartSize);
        final part = await client!.uploads.addPart(upload.id, data: partData);
        print('Added part before cancel: ${part.id}');

        // Cancel the upload
        final cancelled = await client!.uploads.cancel(upload.id);

        expect(cancelled.id, upload.id);
        expect(cancelled.status, UploadStatus.cancelled);
        expect(cancelled.isCancelled, isTrue);
        expect(cancelled.isCompleted, isFalse);
        expect(cancelled.isPending, isFalse);

        print('Upload cancelled successfully');
      },
    );

    test(
      'cancel upload without adding parts',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Create upload session
        final upload = await client!.uploads.create(
          const CreateUploadRequest(
            filename: 'test_cancel_immediate.jsonl',
            purpose: FilePurpose.fineTune,
            bytes: minPartSize,
            mimeType: 'application/jsonl',
          ),
        );

        expect(upload.status, UploadStatus.pending);
        print('Created upload: ${upload.id}');

        // Cancel immediately without adding any parts
        final cancelled = await client!.uploads.cancel(upload.id);

        expect(cancelled.id, upload.id);
        expect(cancelled.status, UploadStatus.cancelled);
        expect(cancelled.isCancelled, isTrue);

        print('Upload cancelled without adding parts');
      },
    );

    test(
      'upload status getters',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Test pending status
        final pendingUpload = await client!.uploads.create(
          const CreateUploadRequest(
            filename: 'test_status.jsonl',
            purpose: FilePurpose.fineTune,
            bytes: minPartSize,
            mimeType: 'application/jsonl',
          ),
        );

        expect(pendingUpload.status, UploadStatus.pending);
        expect(pendingUpload.isPending, isTrue);
        expect(pendingUpload.isCompleted, isFalse);
        expect(pendingUpload.isCancelled, isFalse);
        expect(pendingUpload.isExpired, isFalse);
        print('Verified pending status getters');

        String? createdFileId;
        try {
          // Add part and complete to test completed status
          final partData = generateTestData(minPartSize);
          final part = await client!.uploads.addPart(
            pendingUpload.id,
            data: partData,
          );

          final completedUpload = await client!.uploads.complete(
            pendingUpload.id,
            partIds: [part.id],
          );

          expect(completedUpload.status, UploadStatus.completed);
          expect(completedUpload.isCompleted, isTrue);
          expect(completedUpload.isPending, isFalse);
          expect(completedUpload.isCancelled, isFalse);
          expect(completedUpload.isExpired, isFalse);
          print('Verified completed status getters');

          createdFileId = completedUpload.file?.id;
        } finally {
          // Clean up
          if (createdFileId != null) {
            try {
              await client!.files.delete(createdFileId);
              print('Cleaned up file: $createdFileId');
            } catch (e) {
              print('Cleanup note: Could not delete file $createdFileId: $e');
            }
          }
        }

        // Test cancelled status with a new upload
        final uploadToCancel = await client!.uploads.create(
          const CreateUploadRequest(
            filename: 'test_cancel_status.jsonl',
            purpose: FilePurpose.fineTune,
            bytes: minPartSize,
            mimeType: 'application/jsonl',
          ),
        );

        final cancelledUpload = await client!.uploads.cancel(uploadToCancel.id);

        expect(cancelledUpload.status, UploadStatus.cancelled);
        expect(cancelledUpload.isCancelled, isTrue);
        expect(cancelledUpload.isPending, isFalse);
        expect(cancelledUpload.isCompleted, isFalse);
        expect(cancelledUpload.isExpired, isFalse);
        print('Verified cancelled status getters');
      },
    );
  });
}
