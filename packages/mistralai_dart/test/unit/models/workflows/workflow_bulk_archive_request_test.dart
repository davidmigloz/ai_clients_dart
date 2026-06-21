import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('WorkflowBulkArchiveRequest', () {
    test('fromJson parses workflow_ids', () {
      final request = WorkflowBulkArchiveRequest.fromJson(const {
        'workflow_ids': ['a', 'b'],
      });

      expect(request.workflowIds, ['a', 'b']);
    });

    test('toJson round-trips', () {
      final request = WorkflowBulkArchiveRequest(workflowIds: const ['a', 'b']);

      expect(request.toJson(), {
        'workflow_ids': ['a', 'b'],
      });
      expect(
        WorkflowBulkArchiveRequest.fromJson(request.toJson()),
        equals(request),
      );
    });

    test('copyWith replaces values', () {
      final request = WorkflowBulkArchiveRequest(workflowIds: const ['a']);

      expect(request.copyWith().workflowIds, ['a']);
      expect(request.copyWith(workflowIds: const ['c']).workflowIds, ['c']);
    });

    test('equality and hashCode', () {
      final a = WorkflowBulkArchiveRequest(workflowIds: const ['a']);
      final b = WorkflowBulkArchiveRequest(workflowIds: const ['a']);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toString contains count', () {
      final request = WorkflowBulkArchiveRequest(workflowIds: const ['a', 'b']);

      expect(request.toString(), contains('workflowIds: 2'));
    });
  });
}
