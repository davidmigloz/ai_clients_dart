import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('WorkflowListResponse', () {
    Map<String, dynamic> workflowJson(String id) => {
      'id': id,
      'name': 'wf-$id',
      'display_name': 'Workflow $id',
      'archived': false,
    };

    test('fromJson parses workflows and next_cursor', () {
      final response = WorkflowListResponse.fromJson({
        'workflows': [workflowJson('a'), workflowJson('b')],
        'next_cursor': 'cursor-1',
      });

      expect(response.workflows, hasLength(2));
      expect(response.workflows.first.id, 'a');
      expect(response.nextCursor, 'cursor-1');
    });

    test('fromJson handles null next_cursor', () {
      final response = WorkflowListResponse.fromJson({
        'workflows': [workflowJson('a')],
        'next_cursor': null,
      });

      expect(response.nextCursor, isNull);
    });

    test('toJson always emits next_cursor', () {
      final response = WorkflowListResponse(
        workflows: const [],
        nextCursor: null,
      );

      expect(response.toJson(), {
        'workflows': <dynamic>[],
        'next_cursor': null,
      });
    });

    test('toJson round-trips', () {
      final response = WorkflowListResponse(
        workflows: [WorkflowBasicDefinition.fromJson(workflowJson('a'))],
        nextCursor: 'cursor-1',
      );

      expect(
        WorkflowListResponse.fromJson(response.toJson()),
        equals(response),
      );
    });

    test('copyWith replaces and clears values', () {
      final response = WorkflowListResponse(
        workflows: const [],
        nextCursor: 'cursor-1',
      );

      expect(response.copyWith(nextCursor: null).nextCursor, isNull);
      expect(response.copyWith().nextCursor, 'cursor-1');
    });

    test('equality and hashCode', () {
      final a = WorkflowListResponse(
        workflows: [WorkflowBasicDefinition.fromJson(workflowJson('a'))],
        nextCursor: 'c',
      );
      final b = WorkflowListResponse(
        workflows: [WorkflowBasicDefinition.fromJson(workflowJson('a'))],
        nextCursor: 'c',
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toString contains counts', () {
      final response = WorkflowListResponse(
        workflows: const [],
        nextCursor: 'c',
      );

      expect(response.toString(), contains('workflows: 0'));
      expect(response.toString(), contains('nextCursor: c'));
    });
  });
}
