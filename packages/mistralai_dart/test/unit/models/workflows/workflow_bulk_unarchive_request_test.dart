import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('WorkflowBulkUnarchiveRequest', () {
    test('fromJson parses workflow_ids', () {
      final request = WorkflowBulkUnarchiveRequest.fromJson(const {
        'workflow_ids': ['a', 'b'],
      });

      expect(request.workflowIds, ['a', 'b']);
    });

    test('toJson round-trips', () {
      final request = WorkflowBulkUnarchiveRequest(
        workflowIds: const ['a', 'b'],
      );

      expect(request.toJson(), {
        'workflow_ids': ['a', 'b'],
      });
      expect(
        WorkflowBulkUnarchiveRequest.fromJson(request.toJson()),
        equals(request),
      );
    });

    test('copyWith replaces values', () {
      final request = WorkflowBulkUnarchiveRequest(workflowIds: const ['a']);

      expect(request.copyWith().workflowIds, ['a']);
      expect(request.copyWith(workflowIds: const ['c']).workflowIds, ['c']);
    });

    test('equality and hashCode', () {
      final a = WorkflowBulkUnarchiveRequest(workflowIds: const ['a']);
      final b = WorkflowBulkUnarchiveRequest(workflowIds: const ['a']);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toString contains count', () {
      final request = WorkflowBulkUnarchiveRequest(
        workflowIds: const ['a', 'b'],
      );

      expect(request.toString(), contains('workflowIds: 2'));
    });
  });
}
