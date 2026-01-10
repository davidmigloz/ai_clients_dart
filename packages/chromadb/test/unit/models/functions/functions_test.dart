import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

void main() {
  group('AttachFunctionRequest', () {
    test('toJson converts request with all fields', () {
      const request = AttachFunctionRequest(
        name: 'my-function',
        functionId: 'func-123',
        outputCollection: 'output-coll',
        params: {'key': 'value'},
      );

      final json = request.toJson();

      expect(json['name'], 'my-function');
      expect(json['function_id'], 'func-123');
      expect(json['output_collection'], 'output-coll');
      expect(json['params'], '{"key":"value"}'); // JSON encoded
    });

    test('toJson excludes null params', () {
      const request = AttachFunctionRequest(
        name: 'my-function',
        functionId: 'func-123',
        outputCollection: 'output-coll',
      );

      final json = request.toJson();

      expect(json.containsKey('params'), isFalse);
    });

    test('copyWith preserves values when not specified', () {
      const original = AttachFunctionRequest(
        name: 'my-function',
        functionId: 'func-123',
        outputCollection: 'output-coll',
        params: {'key': 'value'},
      );

      final copy = original.copyWith();

      expect(copy.name, 'my-function');
      expect(copy.functionId, 'func-123');
      expect(copy.outputCollection, 'output-coll');
      expect(copy.params, {'key': 'value'});
    });

    test('copyWith can set params to null', () {
      const original = AttachFunctionRequest(
        name: 'my-function',
        functionId: 'func-123',
        outputCollection: 'output-coll',
        params: {'key': 'value'},
      );

      final copy = original.copyWith(params: null);

      expect(copy.params, isNull);
    });

    test('equality works correctly', () {
      const request1 = AttachFunctionRequest(
        name: 'func',
        functionId: 'id',
        outputCollection: 'out',
      );
      const request2 = AttachFunctionRequest(
        name: 'func',
        functionId: 'id',
        outputCollection: 'out',
      );
      const request3 = AttachFunctionRequest(
        name: 'other',
        functionId: 'id',
        outputCollection: 'out',
      );

      expect(request1, equals(request2));
      expect(request1, isNot(equals(request3)));
    });
  });

  group('AttachedFunctionInfo', () {
    test('fromJson creates info correctly', () {
      final json = {
        'id': 'info-123',
        'name': 'my-func',
        'function_name': 'embed_processor',
      };

      final info = AttachedFunctionInfo.fromJson(json);

      expect(info.id, 'info-123');
      expect(info.name, 'my-func');
      expect(info.functionName, 'embed_processor');
    });

    test('toJson converts info correctly', () {
      const info = AttachedFunctionInfo(
        id: 'info-456',
        name: 'another-func',
        functionName: 'summarizer',
      );

      final json = info.toJson();

      expect(json['id'], 'info-456');
      expect(json['name'], 'another-func');
      expect(json['function_name'], 'summarizer');
    });

    test('copyWith preserves values when not specified', () {
      const original = AttachedFunctionInfo(
        id: 'info-789',
        name: 'test-func',
        functionName: 'analyzer',
      );

      final copy = original.copyWith();

      expect(copy.id, 'info-789');
      expect(copy.name, 'test-func');
      expect(copy.functionName, 'analyzer');
    });

    test('copyWith updates specified values', () {
      const original = AttachedFunctionInfo(
        id: 'info-789',
        name: 'test-func',
        functionName: 'analyzer',
      );

      final copy = original.copyWith(name: 'new-name');

      expect(copy.id, 'info-789');
      expect(copy.name, 'new-name');
      expect(copy.functionName, 'analyzer');
    });

    test('equality works correctly', () {
      const info1 = AttachedFunctionInfo(
        id: 'id1',
        name: 'name',
        functionName: 'func',
      );
      const info2 = AttachedFunctionInfo(
        id: 'id1',
        name: 'name',
        functionName: 'func',
      );
      const info3 = AttachedFunctionInfo(
        id: 'id2',
        name: 'name',
        functionName: 'func',
      );

      expect(info1, equals(info2));
      expect(info1, isNot(equals(info3)));
    });
  });

  group('AttachFunctionResponse', () {
    test('fromJson creates response correctly', () {
      final json = {
        'attached_function': {
          'id': 'func-id',
          'name': 'func-name',
          'function_name': 'processor',
        },
        'created': true,
      };

      final response = AttachFunctionResponse.fromJson(json);

      expect(response.attachedFunction.id, 'func-id');
      expect(response.attachedFunction.name, 'func-name');
      expect(response.attachedFunction.functionName, 'processor');
      expect(response.created, true);
    });

    test('toJson converts response correctly', () {
      const response = AttachFunctionResponse(
        attachedFunction: AttachedFunctionInfo(
          id: 'id',
          name: 'name',
          functionName: 'func',
        ),
        created: false,
      );

      final json = response.toJson();

      expect((json['attached_function'] as Map<String, dynamic>)['id'], 'id');
      expect(json['created'], false);
    });

    test('equality works correctly', () {
      const response1 = AttachFunctionResponse(
        attachedFunction: AttachedFunctionInfo(
          id: 'id',
          name: 'name',
          functionName: 'func',
        ),
        created: true,
      );
      const response2 = AttachFunctionResponse(
        attachedFunction: AttachedFunctionInfo(
          id: 'id',
          name: 'name',
          functionName: 'func',
        ),
        created: true,
      );
      const response3 = AttachFunctionResponse(
        attachedFunction: AttachedFunctionInfo(
          id: 'id',
          name: 'name',
          functionName: 'func',
        ),
        created: false,
      );

      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
    });
  });

  group('AttachedFunction', () {
    test('fromJson creates function with all fields', () {
      final json = {
        'id': 'attached-123',
        'name': 'my-attached-func',
        'function_name': 'embed_processor',
        'input_collection_id': 'input-coll-id',
        'output_collection': 'output-coll-name',
        'output_collection_id': 'output-coll-id',
        'tenant_id': 'tenant-123',
        'database_id': 'db-456',
        'completion_offset': 42,
        'min_records_for_invocation': 10,
        'params': '{"key":"value"}',
      };

      final func = AttachedFunction.fromJson(json);

      expect(func.id, 'attached-123');
      expect(func.name, 'my-attached-func');
      expect(func.functionName, 'embed_processor');
      expect(func.inputCollectionId, 'input-coll-id');
      expect(func.outputCollection, 'output-coll-name');
      expect(func.outputCollectionId, 'output-coll-id');
      expect(func.tenantId, 'tenant-123');
      expect(func.databaseId, 'db-456');
      expect(func.completionOffset, 42);
      expect(func.minRecordsForInvocation, 10);
      expect(func.params, '{"key":"value"}');
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'attached-456',
        'name': 'minimal-func',
        'function_name': 'processor',
        'input_collection_id': 'input-id',
        'output_collection': 'output-name',
        'tenant_id': 'tenant',
        'database_id': 'db',
        'completion_offset': 0,
        'min_records_for_invocation': 1,
      };

      final func = AttachedFunction.fromJson(json);

      expect(func.outputCollectionId, isNull);
      expect(func.params, isNull);
    });

    test('toJson converts function correctly', () {
      const func = AttachedFunction(
        id: 'id',
        name: 'name',
        functionName: 'func',
        inputCollectionId: 'input',
        outputCollection: 'output',
        outputCollectionId: 'output-id',
        tenantId: 'tenant',
        databaseId: 'db',
        completionOffset: 100,
        minRecordsForInvocation: 5,
        params: '{}',
      );

      final json = func.toJson();

      expect(json['id'], 'id');
      expect(json['function_name'], 'func');
      expect(json['output_collection_id'], 'output-id');
      expect(json['params'], '{}');
    });

    test('toJson excludes null optional fields', () {
      const func = AttachedFunction(
        id: 'id',
        name: 'name',
        functionName: 'func',
        inputCollectionId: 'input',
        outputCollection: 'output',
        tenantId: 'tenant',
        databaseId: 'db',
        completionOffset: 0,
        minRecordsForInvocation: 1,
      );

      final json = func.toJson();

      expect(json.containsKey('output_collection_id'), isFalse);
      expect(json.containsKey('params'), isFalse);
    });

    test('copyWith can set optional fields to null', () {
      const original = AttachedFunction(
        id: 'id',
        name: 'name',
        functionName: 'func',
        inputCollectionId: 'input',
        outputCollection: 'output',
        outputCollectionId: 'out-id',
        tenantId: 'tenant',
        databaseId: 'db',
        completionOffset: 0,
        minRecordsForInvocation: 1,
        params: 'params',
      );

      final copy = original.copyWith(outputCollectionId: null, params: null);

      expect(copy.outputCollectionId, isNull);
      expect(copy.params, isNull);
    });

    test('equality works correctly', () {
      const func1 = AttachedFunction(
        id: 'id',
        name: 'name',
        functionName: 'func',
        inputCollectionId: 'input',
        outputCollection: 'output',
        tenantId: 'tenant',
        databaseId: 'db',
        completionOffset: 0,
        minRecordsForInvocation: 1,
      );
      const func2 = AttachedFunction(
        id: 'id',
        name: 'name',
        functionName: 'func',
        inputCollectionId: 'input',
        outputCollection: 'output',
        tenantId: 'tenant',
        databaseId: 'db',
        completionOffset: 0,
        minRecordsForInvocation: 1,
      );
      const func3 = AttachedFunction(
        id: 'different',
        name: 'name',
        functionName: 'func',
        inputCollectionId: 'input',
        outputCollection: 'output',
        tenantId: 'tenant',
        databaseId: 'db',
        completionOffset: 0,
        minRecordsForInvocation: 1,
      );

      expect(func1, equals(func2));
      expect(func1, isNot(equals(func3)));
    });
  });

  group('GetAttachedFunctionResponse', () {
    test('fromJson creates response correctly', () {
      final json = {
        'attached_function': {
          'id': 'id',
          'name': 'name',
          'function_name': 'func',
          'input_collection_id': 'input',
          'output_collection': 'output',
          'tenant_id': 'tenant',
          'database_id': 'db',
          'completion_offset': 0,
          'min_records_for_invocation': 1,
        },
      };

      final response = GetAttachedFunctionResponse.fromJson(json);

      expect(response.attachedFunction.id, 'id');
      expect(response.attachedFunction.name, 'name');
    });

    test('toJson converts response correctly', () {
      const response = GetAttachedFunctionResponse(
        attachedFunction: AttachedFunction(
          id: 'id',
          name: 'name',
          functionName: 'func',
          inputCollectionId: 'input',
          outputCollection: 'output',
          tenantId: 'tenant',
          databaseId: 'db',
          completionOffset: 0,
          minRecordsForInvocation: 1,
        ),
      );

      final json = response.toJson();

      expect((json['attached_function'] as Map<String, dynamic>)['id'], 'id');
    });

    test('equality works correctly', () {
      const response1 = GetAttachedFunctionResponse(
        attachedFunction: AttachedFunction(
          id: 'id',
          name: 'name',
          functionName: 'func',
          inputCollectionId: 'input',
          outputCollection: 'output',
          tenantId: 'tenant',
          databaseId: 'db',
          completionOffset: 0,
          minRecordsForInvocation: 1,
        ),
      );
      const response2 = GetAttachedFunctionResponse(
        attachedFunction: AttachedFunction(
          id: 'id',
          name: 'name',
          functionName: 'func',
          inputCollectionId: 'input',
          outputCollection: 'output',
          tenantId: 'tenant',
          databaseId: 'db',
          completionOffset: 0,
          minRecordsForInvocation: 1,
        ),
      );

      expect(response1, equals(response2));
    });
  });

  group('DetachFunctionRequest', () {
    test('toJson converts request with deleteOutput', () {
      const request = DetachFunctionRequest(deleteOutput: true);

      final json = request.toJson();

      expect(json['delete_output'], true);
    });

    test('toJson excludes null deleteOutput', () {
      const request = DetachFunctionRequest();

      final json = request.toJson();

      expect(json.containsKey('delete_output'), isFalse);
    });

    test('copyWith preserves values when not specified', () {
      const original = DetachFunctionRequest(deleteOutput: true);

      final copy = original.copyWith();

      expect(copy.deleteOutput, true);
    });

    test('copyWith can set deleteOutput to null', () {
      const original = DetachFunctionRequest(deleteOutput: true);

      final copy = original.copyWith(deleteOutput: null);

      expect(copy.deleteOutput, isNull);
    });

    test('equality works correctly', () {
      const request1 = DetachFunctionRequest(deleteOutput: true);
      const request2 = DetachFunctionRequest(deleteOutput: true);
      const request3 = DetachFunctionRequest(deleteOutput: false);

      expect(request1, equals(request2));
      expect(request1, isNot(equals(request3)));
    });
  });

  group('DetachFunctionResponse', () {
    test('fromJson creates response correctly', () {
      final json = {'success': true};

      final response = DetachFunctionResponse.fromJson(json);

      expect(response.success, true);
    });

    test('toJson converts response correctly', () {
      const response = DetachFunctionResponse(success: true);

      final json = response.toJson();

      expect(json['success'], true);
    });

    test('copyWith updates success', () {
      const original = DetachFunctionResponse(success: true);

      final copy = original.copyWith(success: false);

      expect(copy.success, false);
    });

    test('equality works correctly', () {
      const response1 = DetachFunctionResponse(success: true);
      const response2 = DetachFunctionResponse(success: true);
      const response3 = DetachFunctionResponse(success: false);

      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
    });
  });
}
