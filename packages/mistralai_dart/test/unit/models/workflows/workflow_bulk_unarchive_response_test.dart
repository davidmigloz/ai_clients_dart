import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('WorkflowBulkUnarchiveResponse', () {
    Map<String, dynamic> workflowJson(String id) => {
      'id': id,
      'name': 'wf-$id',
      'display_name': 'Workflow $id',
    };

    test('fromJson parses unarchived and errored', () {
      final response = WorkflowBulkUnarchiveResponse.fromJson({
        'unarchived': [workflowJson('a')],
        'errored': const [
          {'workflow_id': 'b', 'message': 'failed'},
        ],
      });

      expect(response.unarchived, hasLength(1));
      expect(response.unarchived.first.id, 'a');
      expect(response.errored, hasLength(1));
      expect(response.errored?.first.workflowId, 'b');
    });

    test('fromJson handles missing errored', () {
      final response = WorkflowBulkUnarchiveResponse.fromJson({
        'unarchived': [workflowJson('a')],
      });

      expect(response.errored, isNull);
    });

    test('toJson round-trips', () {
      final response = WorkflowBulkUnarchiveResponse(
        unarchived: [Workflow.fromJson(workflowJson('a'))],
        errored: const [WorkflowBulkError(workflowId: 'b', message: 'failed')],
      );

      expect(
        WorkflowBulkUnarchiveResponse.fromJson(response.toJson()),
        equals(response),
      );
    });

    test('toJson omits null errored', () {
      final response = WorkflowBulkUnarchiveResponse(unarchived: const []);

      expect(response.toJson().containsKey('errored'), isFalse);
    });

    test('copyWith clears errored', () {
      final response = WorkflowBulkUnarchiveResponse(
        unarchived: const [],
        errored: const [WorkflowBulkError(workflowId: 'b', message: 'failed')],
      );

      expect(response.copyWith(errored: null).errored, isNull);
      expect(response.copyWith().errored, hasLength(1));
    });

    test('equality and hashCode', () {
      final a = WorkflowBulkUnarchiveResponse(
        unarchived: [Workflow.fromJson(workflowJson('a'))],
      );
      final b = WorkflowBulkUnarchiveResponse(
        unarchived: [Workflow.fromJson(workflowJson('a'))],
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toString contains counts', () {
      final response = WorkflowBulkUnarchiveResponse(
        unarchived: [Workflow.fromJson(workflowJson('a'))],
      );

      expect(response.toString(), contains('unarchived: 1'));
      expect(response.toString(), contains('errored: null'));
    });
  });
}
