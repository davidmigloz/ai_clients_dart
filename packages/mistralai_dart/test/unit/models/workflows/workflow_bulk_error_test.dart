import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('WorkflowBulkError', () {
    Map<String, dynamic> workflowJson(String id) => {
      'id': id,
      'name': 'wf-$id',
      'display_name': 'Workflow $id',
    };

    test('fromJson parses fields with workflow', () {
      final error = WorkflowBulkError.fromJson({
        'workflow_id': 'wf-1',
        'message': 'failed',
        'workflow': workflowJson('wf-1'),
      });

      expect(error.workflowId, 'wf-1');
      expect(error.message, 'failed');
      expect(error.workflow?.id, 'wf-1');
    });

    test('fromJson handles null workflow', () {
      final error = WorkflowBulkError.fromJson(const {
        'workflow_id': 'wf-1',
        'message': 'failed',
      });

      expect(error.workflow, isNull);
    });

    test('toJson round-trips with workflow', () {
      final error = WorkflowBulkError(
        workflowId: 'wf-1',
        message: 'failed',
        workflow: Workflow.fromJson(workflowJson('wf-1')),
      );

      expect(WorkflowBulkError.fromJson(error.toJson()), equals(error));
    });

    test('toJson omits null workflow', () {
      const error = WorkflowBulkError(workflowId: 'wf-1', message: 'failed');

      expect(error.toJson().containsKey('workflow'), isFalse);
    });

    test('copyWith clears workflow', () {
      final error = WorkflowBulkError(
        workflowId: 'wf-1',
        message: 'failed',
        workflow: Workflow.fromJson(workflowJson('wf-1')),
      );

      expect(error.copyWith(workflow: null).workflow, isNull);
      expect(error.copyWith().workflow, isNotNull);
      expect(error.copyWith(message: 'other').message, 'other');
    });

    test('equality and hashCode', () {
      const a = WorkflowBulkError(workflowId: 'wf-1', message: 'failed');
      const b = WorkflowBulkError(workflowId: 'wf-1', message: 'failed');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toString contains fields', () {
      const error = WorkflowBulkError(workflowId: 'wf-1', message: 'failed');

      expect(error.toString(), contains('workflowId: wf-1'));
      expect(error.toString(), contains('message: failed'));
    });
  });
}
