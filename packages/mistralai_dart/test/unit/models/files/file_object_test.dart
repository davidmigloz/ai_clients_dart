import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('FileObject', () {
    test('creates with required fields', () {
      const file = FileObject(
        id: 'file-123',
        object: 'file',
        bytes: 1024,
        createdAt: 1699000000,
        filename: 'training.jsonl',
        purpose: FilePurpose.fineTune,
      );

      expect(file.id, 'file-123');
      expect(file.object, 'file');
      expect(file.bytes, 1024);
      expect(file.createdAt, 1699000000);
      expect(file.filename, 'training.jsonl');
      expect(file.purpose, FilePurpose.fineTune);
      expect(file.sampleType, isNull);
      expect(file.numLines, isNull);
      expect(file.source, isNull);
      expect(file.deleted, isNull);
    });

    test('creates with all fields', () {
      const file = FileObject(
        id: 'file-456',
        object: 'file',
        bytes: 2048,
        createdAt: 1699000001,
        filename: 'batch.jsonl',
        purpose: FilePurpose.batch,
        sampleType: 'instruct',
        numLines: 100,
        source: 'upload',
        deleted: false,
      );

      expect(file.sampleType, 'instruct');
      expect(file.numLines, 100);
      expect(file.source, 'upload');
      expect(file.deleted, false);
    });

    test('fromJson parses correctly', () {
      final json = {
        'id': 'file-789',
        'object': 'file',
        'bytes': 4096,
        'created_at': 1699000002,
        'filename': 'document.pdf',
        'purpose': 'ocr',
        'sample_type': 'pretrain',
        'num_lines': 50,
        'source': 'repository',
        'deleted': true,
      };

      final file = FileObject.fromJson(json);

      expect(file.id, 'file-789');
      expect(file.object, 'file');
      expect(file.bytes, 4096);
      expect(file.createdAt, 1699000002);
      expect(file.filename, 'document.pdf');
      expect(file.purpose, FilePurpose.ocr);
      expect(file.sampleType, 'pretrain');
      expect(file.numLines, 50);
      expect(file.source, 'repository');
      expect(file.deleted, true);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'file-minimal',
        'object': 'file',
        'bytes': 512,
        'created_at': 1699000003,
        'filename': 'audio.mp3',
        'purpose': 'audio',
      };

      final file = FileObject.fromJson(json);

      expect(file.purpose, FilePurpose.audio);
      expect(file.sampleType, isNull);
      expect(file.numLines, isNull);
    });

    test('fromJson provides defaults for missing required fields', () {
      final json = <String, dynamic>{};

      final file = FileObject.fromJson(json);

      expect(file.id, '');
      expect(file.object, 'file');
      expect(file.bytes, 0);
      expect(file.createdAt, 0);
      expect(file.filename, '');
      expect(file.purpose, FilePurpose.unknown);
    });

    test('toJson serializes correctly', () {
      const file = FileObject(
        id: 'file-json',
        object: 'file',
        bytes: 8192,
        createdAt: 1699000004,
        filename: 'test.jsonl',
        purpose: FilePurpose.fineTune,
        numLines: 200,
      );

      final json = file.toJson();

      expect(json['id'], 'file-json');
      expect(json['object'], 'file');
      expect(json['bytes'], 8192);
      expect(json['created_at'], 1699000004);
      expect(json['filename'], 'test.jsonl');
      expect(json['purpose'], 'fine-tune');
      expect(json['num_lines'], 200);
      expect(json.containsKey('sample_type'), isFalse);
    });

    test('equality works correctly', () {
      const file1 = FileObject(
        id: 'file-eq',
        object: 'file',
        bytes: 1024,
        createdAt: 1699000005,
        filename: 'test.jsonl',
        purpose: FilePurpose.fineTune,
      );
      const file2 = FileObject(
        id: 'file-eq',
        object: 'file',
        bytes: 1024,
        createdAt: 1699000005,
        filename: 'test.jsonl',
        purpose: FilePurpose.fineTune,
      );
      const file3 = FileObject(
        id: 'file-different',
        object: 'file',
        bytes: 1024,
        createdAt: 1699000005,
        filename: 'test.jsonl',
        purpose: FilePurpose.fineTune,
      );

      expect(file1, equals(file2));
      expect(file1, isNot(equals(file3)));
      expect(file1.hashCode, file2.hashCode);
    });

    test('toString provides useful representation', () {
      const file = FileObject(
        id: 'file-str',
        object: 'file',
        bytes: 1024,
        createdAt: 1699000006,
        filename: 'example.jsonl',
        purpose: FilePurpose.batch,
      );

      expect(file.toString(), contains('FileObject'));
      expect(file.toString(), contains('file-str'));
      expect(file.toString(), contains('example.jsonl'));
    });
  });

  group('FilePurpose', () {
    test('filePurposeToString converts correctly', () {
      expect(filePurposeToString(FilePurpose.fineTune), 'fine-tune');
      expect(filePurposeToString(FilePurpose.batch), 'batch');
      expect(filePurposeToString(FilePurpose.ocr), 'ocr');
      expect(filePurposeToString(FilePurpose.audio), 'audio');
      expect(filePurposeToString(FilePurpose.unknown), 'unknown');
    });

    test('filePurposeFromString parses correctly', () {
      expect(filePurposeFromString('fine-tune'), FilePurpose.fineTune);
      expect(filePurposeFromString('batch'), FilePurpose.batch);
      expect(filePurposeFromString('ocr'), FilePurpose.ocr);
      expect(filePurposeFromString('audio'), FilePurpose.audio);
      expect(filePurposeFromString('unknown'), FilePurpose.unknown);
      expect(filePurposeFromString('invalid'), FilePurpose.unknown);
      expect(filePurposeFromString(null), FilePurpose.unknown);
    });
  });

  group('FileList', () {
    test('creates with required fields', () {
      const list = FileList(object: 'list', data: []);

      expect(list.object, 'list');
      expect(list.data, isEmpty);
      expect(list.total, isNull);
    });

    test('creates with all fields', () {
      const list = FileList(
        object: 'list',
        data: [
          FileObject(
            id: 'file-1',
            object: 'file',
            bytes: 1024,
            createdAt: 1699000000,
            filename: 'file1.jsonl',
            purpose: FilePurpose.fineTune,
          ),
        ],
        total: 10,
      );

      expect(list.data.length, 1);
      expect(list.data.first.id, 'file-1');
      expect(list.total, 10);
    });

    test('fromJson parses correctly', () {
      final json = {
        'object': 'list',
        'data': [
          {
            'id': 'file-json',
            'object': 'file',
            'bytes': 2048,
            'created_at': 1699000001,
            'filename': 'parsed.jsonl',
            'purpose': 'batch',
          },
        ],
        'total': 5,
      };

      final list = FileList.fromJson(json);

      expect(list.object, 'list');
      expect(list.data.length, 1);
      expect(list.data.first.id, 'file-json');
      expect(list.total, 5);
    });

    test('toJson serializes correctly', () {
      const list = FileList(
        object: 'list',
        data: [
          FileObject(
            id: 'file-ser',
            object: 'file',
            bytes: 512,
            createdAt: 1699000002,
            filename: 'serial.jsonl',
            purpose: FilePurpose.ocr,
          ),
        ],
        total: 1,
      );

      final json = list.toJson();

      expect(json['object'], 'list');
      expect(json['data'], isA<List<dynamic>>());
      expect((json['data'] as List).length, 1);
      expect(json['total'], 1);
    });

    test('toString provides useful representation', () {
      const list = FileList(object: 'list', data: [], total: 25);

      expect(list.toString(), contains('FileList'));
      expect(list.toString(), contains('count: 0'));
      expect(list.toString(), contains('total: 25'));
    });
  });

  group('SignedUrl', () {
    test('creates with required fields', () {
      const signedUrl = SignedUrl(url: 'https://example.com/download/file');

      expect(signedUrl.url, 'https://example.com/download/file');
      expect(signedUrl.expiresAt, isNull);
    });

    test('creates with all fields', () {
      const signedUrl = SignedUrl(
        url: 'https://example.com/download/file',
        expiresAt: 1699100000,
      );

      expect(signedUrl.url, 'https://example.com/download/file');
      expect(signedUrl.expiresAt, 1699100000);
    });

    test('fromJson parses correctly', () {
      final json = {
        'url': 'https://api.mistral.ai/files/download/abc123',
        'expires_at': 1699200000,
      };

      final signedUrl = SignedUrl.fromJson(json);

      expect(signedUrl.url, 'https://api.mistral.ai/files/download/abc123');
      expect(signedUrl.expiresAt, 1699200000);
    });

    test('toJson serializes correctly', () {
      const signedUrl = SignedUrl(
        url: 'https://example.com/file',
        expiresAt: 1699300000,
      );

      final json = signedUrl.toJson();

      expect(json['url'], 'https://example.com/file');
      expect(json['expires_at'], 1699300000);
    });

    test('toJson excludes null expiresAt', () {
      const signedUrl = SignedUrl(url: 'https://example.com/file');

      final json = signedUrl.toJson();

      expect(json.containsKey('expires_at'), isFalse);
    });

    test('equality works correctly', () {
      const url1 = SignedUrl(url: 'https://example.com/a', expiresAt: 100);
      const url2 = SignedUrl(url: 'https://example.com/a', expiresAt: 100);
      const url3 = SignedUrl(url: 'https://example.com/b', expiresAt: 100);

      expect(url1, equals(url2));
      expect(url1, isNot(equals(url3)));
      expect(url1.hashCode, url2.hashCode);
    });

    test('toString provides useful representation', () {
      const signedUrl = SignedUrl(
        url: 'https://example.com/file',
        expiresAt: 1699400000,
      );

      expect(signedUrl.toString(), contains('SignedUrl'));
      expect(signedUrl.toString(), contains('https://example.com/file'));
    });
  });
}
