import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('FileMetadata', () {
    test('fromJson parses file metadata correctly', () {
      final json = {
        'id': 'file_abc123',
        'type': 'file',
        'filename': 'document.pdf',
        'mime_type': 'application/pdf',
        'size_bytes': 1024,
        'created_at': '2025-01-01T00:00:00Z',
        'downloadable': true,
      };

      final file = FileMetadata.fromJson(json);

      expect(file.id, 'file_abc123');
      expect(file.type, 'file');
      expect(file.filename, 'document.pdf');
      expect(file.mimeType, 'application/pdf');
      expect(file.sizeBytes, 1024);
      expect(file.createdAt, DateTime.utc(2025, 1, 1));
      expect(file.downloadable, isTrue);
      expect(file.expiresAt, isNull);
    });

    test('fromJson parses expires_at when present', () {
      final json = {
        'id': 'file_exp123',
        'type': 'file',
        'filename': 'temp.txt',
        'mime_type': 'text/plain',
        'size_bytes': 10,
        'created_at': '2025-01-01T00:00:00Z',
        'expires_at': '2025-01-01T01:00:00Z',
      };

      final file = FileMetadata.fromJson(json);

      expect(file.expiresAt, DateTime.utc(2025, 1, 1, 1, 0, 0));
    });

    test('fromJson treats null expires_at as never-expiring', () {
      final json = {
        'id': 'file_noexp',
        'type': 'file',
        'filename': 'permanent.txt',
        'mime_type': 'text/plain',
        'size_bytes': 10,
        'created_at': '2025-01-01T00:00:00Z',
        'expires_at': null,
      };

      final file = FileMetadata.fromJson(json);

      expect(file.expiresAt, isNull);
    });

    test('fromJson handles image files', () {
      final json = {
        'id': 'file_img456',
        'type': 'file',
        'filename': 'photo.jpg',
        'mime_type': 'image/jpeg',
        'size_bytes': 2048000,
        'created_at': '2025-06-15T10:30:00Z',
        'downloadable': true,
      };

      final file = FileMetadata.fromJson(json);

      expect(file.id, 'file_img456');
      expect(file.filename, 'photo.jpg');
      expect(file.mimeType, 'image/jpeg');
      expect(file.sizeBytes, 2048000);
    });

    test('fromJson handles non-downloadable files', () {
      final json = {
        'id': 'file_xyz789',
        'type': 'file',
        'filename': 'restricted.bin',
        'mime_type': 'application/octet-stream',
        'size_bytes': 512,
        'created_at': '2025-03-20T15:45:00Z',
        'downloadable': false,
      };

      final file = FileMetadata.fromJson(json);

      expect(file.downloadable, isFalse);
    });

    test('toJson produces valid JSON', () {
      final file = FileMetadata(
        id: 'file_test',
        filename: 'test.txt',
        mimeType: 'text/plain',
        sizeBytes: 100,
        createdAt: DateTime.utc(2025, 5, 1, 12, 0, 0),
        downloadable: true,
      );

      final json = file.toJson();

      expect(json['id'], 'file_test');
      expect(json['type'], 'file');
      expect(json['filename'], 'test.txt');
      expect(json['mime_type'], 'text/plain');
      expect(json['size_bytes'], 100);
      expect(json['created_at'], '2025-05-01T12:00:00.000Z');
      expect(json['downloadable'], isTrue);
    });

    test('toJson includes expires_at when present', () {
      final file = FileMetadata(
        id: 'file_test',
        filename: 'test.txt',
        mimeType: 'text/plain',
        sizeBytes: 100,
        createdAt: DateTime.utc(2025, 1, 1),
        expiresAt: DateTime.utc(2025, 1, 2),
      );

      final json = file.toJson();
      expect(json['expires_at'], '2025-01-02T00:00:00.000Z');
    });

    test('toJson omits expires_at when null', () {
      final file = FileMetadata(
        id: 'file_test',
        filename: 'test.txt',
        mimeType: 'text/plain',
        sizeBytes: 100,
        createdAt: DateTime.utc(2025, 1, 1),
      );

      final json = file.toJson();
      expect(json.containsKey('expires_at'), isFalse);
    });

    test('fromJson parses file with scope', () {
      final json = {
        'id': 'file_scoped',
        'type': 'file',
        'filename': 'output.txt',
        'mime_type': 'text/plain',
        'size_bytes': 256,
        'created_at': '2025-06-01T00:00:00Z',
        'downloadable': true,
        'scope': {'id': 'sess_abc123', 'type': 'session'},
      };

      final file = FileMetadata.fromJson(json);

      expect(file.scope, isNotNull);
      expect(file.scope!.id, 'sess_abc123');
      expect(file.scope!.type, 'session');
    });

    test('fromJson handles missing scope', () {
      final json = {
        'id': 'file_noscope',
        'type': 'file',
        'filename': 'test.txt',
        'mime_type': 'text/plain',
        'size_bytes': 100,
        'created_at': '2025-01-01T00:00:00Z',
      };

      final file = FileMetadata.fromJson(json);
      expect(file.scope, isNull);
    });

    test('toJson omits scope when null', () {
      final file = FileMetadata(
        id: 'file_test',
        filename: 'test.txt',
        mimeType: 'text/plain',
        sizeBytes: 100,
        createdAt: DateTime.utc(2025, 1, 1),
      );

      final json = file.toJson();
      expect(json.containsKey('scope'), isFalse);
    });

    test('toJson includes scope when present', () {
      final file = FileMetadata(
        id: 'file_test',
        filename: 'test.txt',
        mimeType: 'text/plain',
        sizeBytes: 100,
        createdAt: DateTime.utc(2025, 1, 1),
        scope: const FileScope(id: 'sess_xyz'),
      );

      final json = file.toJson();
      expect(json['scope'], {'id': 'sess_xyz', 'type': 'session'});
    });

    test('equality works correctly', () {
      final file1 = FileMetadata(
        id: 'file_1',
        filename: 'test.txt',
        mimeType: 'text/plain',
        sizeBytes: 100,
        createdAt: DateTime.utc(2025, 1, 1),
        downloadable: true,
      );

      final file2 = FileMetadata(
        id: 'file_1',
        filename: 'test.txt',
        mimeType: 'text/plain',
        sizeBytes: 100,
        createdAt: DateTime.utc(2025, 1, 1),
        downloadable: true,
      );

      final file3 = FileMetadata(
        id: 'file_2',
        filename: 'other.txt',
        mimeType: 'text/plain',
        sizeBytes: 200,
        createdAt: DateTime.utc(2025, 1, 2),
        downloadable: false,
      );

      expect(file1, equals(file2));
      expect(file1, isNot(equals(file3)));
    });

    test('hashCode is consistent', () {
      final file = FileMetadata(
        id: 'file_hash',
        filename: 'hash.txt',
        mimeType: 'text/plain',
        sizeBytes: 50,
        createdAt: DateTime.utc(2025, 1, 1),
        downloadable: true,
      );

      expect(file.hashCode, equals(file.hashCode));
    });
  });

  group('FileListResponse', () {
    test('fromJson parses list response correctly', () {
      final json = {
        'data': [
          {
            'id': 'file_1',
            'type': 'file',
            'filename': 'file1.pdf',
            'mime_type': 'application/pdf',
            'size_bytes': 1000,
            'created_at': '2025-01-01T00:00:00Z',
            'downloadable': true,
          },
          {
            'id': 'file_2',
            'type': 'file',
            'filename': 'file2.jpg',
            'mime_type': 'image/jpeg',
            'size_bytes': 2000,
            'created_at': '2025-01-02T00:00:00Z',
            'downloadable': true,
          },
        ],
        'next_page': 'page_xyz',
      };

      final response = FileListResponse.fromJson(json);

      expect(response.data, hasLength(2));
      expect(response.data[0].id, 'file_1');
      expect(response.data[1].id, 'file_2');
      expect(response.nextPage, 'page_xyz');
    });

    test('fromJson handles empty list', () {
      final json = {'data': <Map<String, dynamic>>[], 'next_page': null};

      final response = FileListResponse.fromJson(json);

      expect(response.data, isEmpty);
      expect(response.nextPage, isNull);
    });

    test('toJson produces valid JSON', () {
      final response = FileListResponse(
        data: [
          FileMetadata(
            id: 'file_test',
            filename: 'test.txt',
            mimeType: 'text/plain',
            sizeBytes: 100,
            createdAt: DateTime.utc(2025, 1, 1),
            downloadable: true,
          ),
        ],
        nextPage: 'page_next',
      );

      final json = response.toJson();

      expect(json['data'], hasLength(1));
      expect(json['next_page'], 'page_next');
    });

    test('toJson omits next_page when null', () {
      final response = FileListResponse(
        data: [
          FileMetadata(
            id: 'file_test',
            filename: 'test.txt',
            mimeType: 'text/plain',
            sizeBytes: 100,
            createdAt: DateTime.utc(2025, 1, 1),
          ),
        ],
      );

      final json = response.toJson();
      expect(json.containsKey('next_page'), isFalse);
    });
  });

  group('FileDeleteResponse', () {
    test('fromJson parses delete response correctly', () {
      final json = {'id': 'file_deleted123', 'type': 'file_deleted'};

      final response = FileDeleteResponse.fromJson(json);

      expect(response.id, 'file_deleted123');
      expect(response.type, 'file_deleted');
    });

    test('toJson produces valid JSON', () {
      const response = FileDeleteResponse(id: 'file_xyz', type: 'file_deleted');

      final json = response.toJson();

      expect(json['id'], 'file_xyz');
      expect(json['type'], 'file_deleted');
    });

    test('equality works correctly', () {
      const response1 = FileDeleteResponse(id: 'file_1', type: 'file_deleted');
      const response2 = FileDeleteResponse(id: 'file_1', type: 'file_deleted');
      const response3 = FileDeleteResponse(id: 'file_2', type: 'file_deleted');

      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
    });
  });

  group('FileScope', () {
    test('fromJson parses correctly', () {
      final json = {'id': 'sess_123', 'type': 'session'};

      final scope = FileScope.fromJson(json);

      expect(scope.id, 'sess_123');
      expect(scope.type, 'session');
    });

    test('toJson round-trip', () {
      const scope = FileScope(id: 'sess_abc');

      final roundTripped = FileScope.fromJson(scope.toJson());

      expect(roundTripped, scope);
    });

    test('equality', () {
      const a = FileScope(id: 'sess_1');
      const b = FileScope(id: 'sess_1');
      const c = FileScope(id: 'sess_2');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });

    test('defaults type to session', () {
      const scope = FileScope(id: 'sess_x');
      expect(scope.type, 'session');
    });
  });
}
