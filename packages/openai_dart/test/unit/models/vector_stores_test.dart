// ignore_for_file: deprecated_member_use_from_same_package
import 'package:openai_dart/openai_dart_assistants.dart';
import 'package:test/test.dart';

void main() {
  group('VectorStore', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'vs_abc123',
        'object': 'vector_store',
        'created_at': 1699472000,
        'name': 'Test Store',
        'usage_bytes': 1024000,
        'file_counts': {
          'in_progress': 2,
          'completed': 10,
          'failed': 1,
          'cancelled': 0,
          'total': 13,
        },
        'status': 'completed',
        'metadata': {'key': 'value'},
      };

      final store = VectorStore.fromJson(json);

      expect(store.id, 'vs_abc123');
      expect(store.object, 'vector_store');
      expect(store.createdAt, 1699472000);
      expect(store.name, 'Test Store');
      expect(store.usageBytes, 1024000);
      expect(store.fileCounts.total, 13);
      expect(store.fileCounts.completed, 10);
      expect(store.status, VectorStoreStatus.completed);
      expect(store.metadata['key'], 'value');
    });

    test('fromJson handles expiration policy', () {
      final json = {
        'id': 'vs_abc123',
        'object': 'vector_store',
        'created_at': 1699472000,
        'name': 'Expiring Store',
        'usage_bytes': 512000,
        'file_counts': {
          'in_progress': 0,
          'completed': 5,
          'failed': 0,
          'cancelled': 0,
          'total': 5,
        },
        'status': 'completed',
        'expires_after': {'anchor': 'last_active_at', 'days': 7},
        'expires_at': 1700076800,
        'metadata': <String, dynamic>{},
      };

      final store = VectorStore.fromJson(json);

      expect(store.expiresAfter?.anchor, 'last_active_at');
      expect(store.expiresAfter?.days, 7);
      expect(store.expiresAt, 1700076800);
    });

    test('toJson serializes correctly', () {
      const store = VectorStore(
        id: 'vs_abc123',
        object: 'vector_store',
        createdAt: 1699472000,
        name: 'Test Store',
        usageBytes: 2048000,
        fileCounts: VectorStoreFileCounts(
          inProgress: 1,
          completed: 9,
          failed: 0,
          cancelled: 0,
          total: 10,
        ),
        status: VectorStoreStatus.inProgress,
        metadata: {},
      );

      final json = store.toJson();

      expect(json['id'], 'vs_abc123');
      expect(json['name'], 'Test Store');
      expect(json['status'], 'in_progress');
      expect((json['file_counts'] as Map)['total'], 10);
    });

    test('isReady helper works correctly', () {
      const completedStore = VectorStore(
        id: 'vs_1',
        object: 'vector_store',
        createdAt: 1699472000,
        name: 'Done',
        usageBytes: 1024,
        fileCounts: VectorStoreFileCounts(
          inProgress: 0,
          completed: 5,
          failed: 0,
          cancelled: 0,
          total: 5,
        ),
        status: VectorStoreStatus.completed,
        metadata: {},
      );

      const inProgressStore = VectorStore(
        id: 'vs_2',
        object: 'vector_store',
        createdAt: 1699472000,
        name: 'Processing',
        usageBytes: 1024,
        fileCounts: VectorStoreFileCounts(
          inProgress: 3,
          completed: 2,
          failed: 0,
          cancelled: 0,
          total: 5,
        ),
        status: VectorStoreStatus.inProgress,
        metadata: {},
      );

      expect(completedStore.isReady, isTrue);
      expect(inProgressStore.isReady, isFalse);
    });
  });

  group('VectorStoreList', () {
    test('fromJson parses correctly', () {
      final json = {
        'object': 'list',
        'data': [
          {
            'id': 'vs_1',
            'object': 'vector_store',
            'created_at': 1699472000,
            'name': 'Store 1',
            'usage_bytes': 1024,
            'file_counts': {
              'in_progress': 0,
              'completed': 1,
              'failed': 0,
              'cancelled': 0,
              'total': 1,
            },
            'status': 'completed',
            'metadata': <String, dynamic>{},
          },
        ],
        'first_id': 'vs_1',
        'last_id': 'vs_1',
        'has_more': false,
      };

      final list = VectorStoreList.fromJson(json);

      expect(list.object, 'list');
      expect(list.data.length, 1);
      expect(list.data[0].id, 'vs_1');
      expect(list.hasMore, isFalse);
    });
  });

  group('CreateVectorStoreRequest', () {
    test('fromJson parses correctly', () {
      final json = {
        'name': 'My Store',
        'file_ids': ['file-1', 'file-2'],
        'expires_after': {'anchor': 'last_active_at', 'days': 30},
        'metadata': {'project': 'test'},
      };

      final request = CreateVectorStoreRequest.fromJson(json);

      expect(request.name, 'My Store');
      expect(request.fileIds, ['file-1', 'file-2']);
      expect(request.expiresAfter?.days, 30);
      expect(request.metadata?['project'], 'test');
    });

    test('toJson serializes correctly', () {
      const request = CreateVectorStoreRequest(
        name: 'Test Store',
        fileIds: ['file-abc'],
        metadata: {'key': 'value'},
      );

      final json = request.toJson();

      expect(json['name'], 'Test Store');
      expect(json['file_ids'], ['file-abc']);
      expect((json['metadata'] as Map)['key'], 'value');
    });

    test('toJson omits null fields', () {
      const request = CreateVectorStoreRequest();

      final json = request.toJson();

      expect(json.containsKey('name'), isFalse);
      expect(json.containsKey('file_ids'), isFalse);
    });
  });

  group('ModifyVectorStoreRequest', () {
    test('fromJson parses correctly', () {
      final json = {
        'name': 'Updated Name',
        'expires_after': {'anchor': 'last_active_at', 'days': 14},
      };

      final request = ModifyVectorStoreRequest.fromJson(json);

      expect(request.name, 'Updated Name');
      expect(request.expiresAfter?.days, 14);
    });

    test('toJson serializes correctly', () {
      const request = ModifyVectorStoreRequest(name: 'New Name');

      final json = request.toJson();

      expect(json['name'], 'New Name');
    });
  });

  group('DeleteVectorStoreResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'vs_abc123',
        'object': 'vector_store.deleted',
        'deleted': true,
      };

      final response = DeleteVectorStoreResponse.fromJson(json);

      expect(response.id, 'vs_abc123');
      expect(response.deleted, isTrue);
    });
  });

  group('VectorStoreFileCounts', () {
    test('fromJson parses correctly', () {
      final json = {
        'in_progress': 5,
        'completed': 20,
        'failed': 2,
        'cancelled': 1,
        'total': 28,
      };

      final counts = VectorStoreFileCounts.fromJson(json);

      expect(counts.inProgress, 5);
      expect(counts.completed, 20);
      expect(counts.failed, 2);
      expect(counts.cancelled, 1);
      expect(counts.total, 28);
    });

    test('toJson serializes correctly', () {
      const counts = VectorStoreFileCounts(
        inProgress: 3,
        completed: 7,
        failed: 0,
        cancelled: 0,
        total: 10,
      );

      final json = counts.toJson();

      expect(json['in_progress'], 3);
      expect(json['completed'], 7);
      expect(json['total'], 10);
    });
  });

  group('VectorStoreStatus', () {
    test('fromJson parses all values', () {
      expect(
        VectorStoreStatus.fromJson('in_progress'),
        VectorStoreStatus.inProgress,
      );
      expect(
        VectorStoreStatus.fromJson('completed'),
        VectorStoreStatus.completed,
      );
      expect(VectorStoreStatus.fromJson('expired'), VectorStoreStatus.expired);
    });

    test('toJson returns correct string', () {
      expect(VectorStoreStatus.inProgress.toJson(), 'in_progress');
      expect(VectorStoreStatus.completed.toJson(), 'completed');
      expect(VectorStoreStatus.expired.toJson(), 'expired');
    });
  });

  group('ExpirationPolicy', () {
    test('fromJson parses correctly', () {
      final json = {'anchor': 'last_active_at', 'days': 30};

      final policy = ExpirationPolicy.fromJson(json);

      expect(policy.anchor, 'last_active_at');
      expect(policy.days, 30);
    });

    test('toJson serializes correctly', () {
      const policy = ExpirationPolicy(anchor: 'last_active_at', days: 7);

      final json = policy.toJson();

      expect(json['anchor'], 'last_active_at');
      expect(json['days'], 7);
    });
  });

  group('VectorStoreFile', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'file-abc123',
        'object': 'vector_store.file',
        'usage_bytes': 512000,
        'created_at': 1699472000,
        'vector_store_id': 'vs_xyz789',
        'status': 'completed',
      };

      final file = VectorStoreFile.fromJson(json);

      expect(file.id, 'file-abc123');
      expect(file.object, 'vector_store.file');
      expect(file.usageBytes, 512000);
      expect(file.createdAt, 1699472000);
      expect(file.vectorStoreId, 'vs_xyz789');
      expect(file.status, VectorStoreFileStatus.completed);
    });

    test('fromJson handles error', () {
      final json = {
        'id': 'file-abc123',
        'object': 'vector_store.file',
        'usage_bytes': 0,
        'created_at': 1699472000,
        'vector_store_id': 'vs_xyz789',
        'status': 'failed',
        'last_error': {
          'code': 'file_not_found',
          'message': 'The file could not be found.',
        },
      };

      final file = VectorStoreFile.fromJson(json);

      expect(file.status, VectorStoreFileStatus.failed);
      expect(file.lastError?.code, 'file_not_found');
      expect(file.lastError?.message, 'The file could not be found.');
    });

    test('toJson serializes correctly', () {
      const file = VectorStoreFile(
        id: 'file-abc123',
        object: 'vector_store.file',
        usageBytes: 1024,
        createdAt: 1699472000,
        vectorStoreId: 'vs_xyz789',
        status: VectorStoreFileStatus.inProgress,
      );

      final json = file.toJson();

      expect(json['id'], 'file-abc123');
      expect(json['status'], 'in_progress');
    });

    test('helper getters work correctly', () {
      const completedFile = VectorStoreFile(
        id: 'file-1',
        object: 'vector_store.file',
        usageBytes: 1024,
        createdAt: 1699472000,
        vectorStoreId: 'vs_1',
        status: VectorStoreFileStatus.completed,
      );

      const failedFile = VectorStoreFile(
        id: 'file-2',
        object: 'vector_store.file',
        usageBytes: 0,
        createdAt: 1699472000,
        vectorStoreId: 'vs_1',
        status: VectorStoreFileStatus.failed,
      );

      expect(completedFile.isReady, isTrue);
      expect(completedFile.isFailed, isFalse);
      expect(failedFile.isReady, isFalse);
      expect(failedFile.isFailed, isTrue);
    });
  });

  group('VectorStoreFileList', () {
    test('fromJson parses correctly', () {
      final json = {
        'object': 'list',
        'data': [
          {
            'id': 'file-1',
            'object': 'vector_store.file',
            'usage_bytes': 1024,
            'created_at': 1699472000,
            'vector_store_id': 'vs_1',
            'status': 'completed',
          },
        ],
        'first_id': 'file-1',
        'last_id': 'file-1',
        'has_more': false,
      };

      final list = VectorStoreFileList.fromJson(json);

      expect(list.object, 'list');
      expect(list.data.length, 1);
      expect(list.data[0].id, 'file-1');
      expect(list.hasMore, isFalse);
    });
  });

  group('CreateVectorStoreFileRequest', () {
    test('fromJson parses correctly', () {
      final json = {'file_id': 'file-abc123'};

      final request = CreateVectorStoreFileRequest.fromJson(json);

      expect(request.fileId, 'file-abc123');
    });

    test('toJson serializes correctly', () {
      const request = CreateVectorStoreFileRequest(fileId: 'file-xyz789');

      final json = request.toJson();

      expect(json['file_id'], 'file-xyz789');
    });
  });

  group('DeleteVectorStoreFileResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'file-abc123',
        'object': 'vector_store.file.deleted',
        'deleted': true,
      };

      final response = DeleteVectorStoreFileResponse.fromJson(json);

      expect(response.id, 'file-abc123');
      expect(response.deleted, isTrue);
    });
  });

  group('VectorStoreFileStatus', () {
    test('fromJson parses all values', () {
      expect(
        VectorStoreFileStatus.fromJson('in_progress'),
        VectorStoreFileStatus.inProgress,
      );
      expect(
        VectorStoreFileStatus.fromJson('completed'),
        VectorStoreFileStatus.completed,
      );
      expect(
        VectorStoreFileStatus.fromJson('cancelled'),
        VectorStoreFileStatus.cancelled,
      );
      expect(
        VectorStoreFileStatus.fromJson('failed'),
        VectorStoreFileStatus.failed,
      );
    });

    test('toJson returns correct string', () {
      expect(VectorStoreFileStatus.inProgress.toJson(), 'in_progress');
      expect(VectorStoreFileStatus.completed.toJson(), 'completed');
    });
  });

  group('VectorStoreFileError', () {
    test('fromJson parses correctly', () {
      final json = {
        'code': 'invalid_file',
        'message': 'The file format is not supported.',
      };

      final error = VectorStoreFileError.fromJson(json);

      expect(error.code, 'invalid_file');
      expect(error.message, 'The file format is not supported.');
    });

    test('toJson serializes correctly', () {
      const error = VectorStoreFileError(
        code: 'processing_error',
        message: 'Failed to process file.',
      );

      final json = error.toJson();

      expect(json['code'], 'processing_error');
      expect(json['message'], 'Failed to process file.');
    });
  });
}
