import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('FileObject', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'file-abc123',
        'object': 'file',
        'bytes': 1024,
        'created_at': 1699472000,
        'filename': 'training_data.jsonl',
        'purpose': 'fine-tune',
        'status': 'processed',
      };

      final file = FileObject.fromJson(json);

      expect(file.id, 'file-abc123');
      expect(file.object, 'file');
      expect(file.bytes, 1024);
      expect(file.createdAt, 1699472000);
      expect(file.filename, 'training_data.jsonl');
      expect(file.purpose, FilePurpose.fineTune);
      expect(file.status, FileStatus.processed);
    });

    test('fromJson parses all purposes', () {
      for (final purpose in FilePurpose.values) {
        final json = {
          'id': 'file-abc123',
          'object': 'file',
          'bytes': 1024,
          'created_at': 1699472000,
          'filename': 'test.jsonl',
          'purpose': purpose.toJson(),
        };

        final file = FileObject.fromJson(json);
        expect(file.purpose, purpose);
      }
    });

    test('fromJson parses all statuses', () {
      for (final status in FileStatus.values) {
        final json = {
          'id': 'file-abc123',
          'object': 'file',
          'bytes': 1024,
          'created_at': 1699472000,
          'filename': 'test.jsonl',
          'purpose': 'assistants',
          'status': status.toJson(),
        };

        final file = FileObject.fromJson(json);
        expect(file.status, status);
      }
    });

    test('toJson serializes correctly', () {
      const file = FileObject(
        id: 'file-abc123',
        object: 'file',
        bytes: 2048,
        createdAt: 1699472000,
        filename: 'data.jsonl',
        purpose: FilePurpose.assistants,
        status: FileStatus.uploaded,
      );

      final json = file.toJson();

      expect(json['id'], 'file-abc123');
      expect(json['bytes'], 2048);
      expect(json['filename'], 'data.jsonl');
      expect(json['purpose'], 'assistants');
      expect(json['status'], 'uploaded');
    });

    test('createdAtDateTime getter works correctly', () {
      const file = FileObject(
        id: 'file-abc123',
        object: 'file',
        bytes: 1024,
        createdAt: 1699472000,
        filename: 'test.jsonl',
        purpose: FilePurpose.fineTune,
      );

      final dateTime = file.createdAtDateTime;

      expect(dateTime, isA<DateTime>());
      expect(dateTime.millisecondsSinceEpoch, 1699472000 * 1000);
    });
  });

  group('FileList', () {
    test('fromJson parses correctly', () {
      final json = {
        'object': 'list',
        'data': [
          {
            'id': 'file-1',
            'object': 'file',
            'bytes': 1024,
            'created_at': 1699472000,
            'filename': 'file1.jsonl',
            'purpose': 'fine-tune',
          },
          {
            'id': 'file-2',
            'object': 'file',
            'bytes': 2048,
            'created_at': 1699472001,
            'filename': 'file2.jsonl',
            'purpose': 'assistants',
          },
        ],
      };

      final list = FileList.fromJson(json);

      expect(list.object, 'list');
      expect(list.data.length, 2);
      expect(list.data[0].id, 'file-1');
      expect(list.data[1].id, 'file-2');
    });

    test('toJson serializes correctly', () {
      const list = FileList(
        object: 'list',
        data: [
          FileObject(
            id: 'file-1',
            object: 'file',
            bytes: 1024,
            createdAt: 1699472000,
            filename: 'test.jsonl',
            purpose: FilePurpose.fineTune,
          ),
        ],
      );

      final json = list.toJson();

      expect(json['object'], 'list');
      expect((json['data'] as List).length, 1);
    });

    test('helper getters work correctly', () {
      const emptyList = FileList(object: 'list', data: []);

      const nonEmptyList = FileList(
        object: 'list',
        data: [
          FileObject(
            id: 'file-1',
            object: 'file',
            bytes: 1024,
            createdAt: 1699472000,
            filename: 'test.jsonl',
            purpose: FilePurpose.fineTune,
          ),
        ],
      );

      expect(emptyList.isEmpty, isTrue);
      expect(emptyList.isNotEmpty, isFalse);
      expect(emptyList.length, 0);

      expect(nonEmptyList.isEmpty, isFalse);
      expect(nonEmptyList.isNotEmpty, isTrue);
      expect(nonEmptyList.length, 1);
    });
  });

  group('DeleteFileResponse', () {
    test('fromJson parses correctly', () {
      final json = {'id': 'file-abc123', 'object': 'file', 'deleted': true};

      final response = DeleteFileResponse.fromJson(json);

      expect(response.id, 'file-abc123');
      expect(response.object, 'file');
      expect(response.deleted, isTrue);
    });

    test('toJson serializes correctly', () {
      const response = DeleteFileResponse(
        id: 'file-abc123',
        object: 'file',
        deleted: true,
      );

      final json = response.toJson();

      expect(json['id'], 'file-abc123');
      expect(json['deleted'], isTrue);
    });
  });

  group('FilePurpose', () {
    test('fromJson parses all values', () {
      expect(FilePurpose.fromJson('fine-tune'), FilePurpose.fineTune);
      expect(
        FilePurpose.fromJson('fine-tune-results'),
        FilePurpose.fineTuneResults,
      );
      expect(FilePurpose.fromJson('assistants'), FilePurpose.assistants);
      expect(
        FilePurpose.fromJson('assistants_output'),
        FilePurpose.assistantsOutput,
      );
      expect(FilePurpose.fromJson('batch'), FilePurpose.batch);
      expect(FilePurpose.fromJson('batch_output'), FilePurpose.batchOutput);
      expect(FilePurpose.fromJson('vision'), FilePurpose.vision);
    });

    test('toJson returns correct string', () {
      expect(FilePurpose.fineTune.toJson(), 'fine-tune');
      expect(FilePurpose.assistants.toJson(), 'assistants');
    });
  });

  group('FileStatus', () {
    test('fromJson parses all values', () {
      expect(FileStatus.fromJson('uploaded'), FileStatus.uploaded);
      expect(FileStatus.fromJson('processed'), FileStatus.processed);
      expect(FileStatus.fromJson('error'), FileStatus.error);
    });

    test('toJson returns correct string', () {
      expect(FileStatus.uploaded.toJson(), 'uploaded');
      expect(FileStatus.processed.toJson(), 'processed');
    });
  });
}
