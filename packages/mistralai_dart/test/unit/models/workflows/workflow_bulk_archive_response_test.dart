import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('WorkflowBulkArchiveResponse', () {
    Map<String, dynamic> workflowJson(String id) => {
      'id': id,
      'name': 'wf-$id',
      'display_name': 'Workflow $id',
    };

    test('fromJson parses archived and errored', () {
      final response = WorkflowBulkArchiveResponse.fromJson({
        'archived': [workflowJson('a')],
        'errored': const [
          {'workflow_id': 'b', 'message': 'failed'},
        ],
      });

      expect(response.archived, hasLength(1));
      expect(response.archived.first.id, 'a');
      expect(response.errored, hasLength(1));
      expect(response.errored?.first.workflowId, 'b');
    });

    test('fromJson handles missing errored', () {
      final response = WorkflowBulkArchiveResponse.fromJson({
        'archived': [workflowJson('a')],
      });

      expect(response.errored, isNull);
    });

    test('toJson round-trips', () {
      final response = WorkflowBulkArchiveResponse(
        archived: [Workflow.fromJson(workflowJson('a'))],
        errored: const [WorkflowBulkError(workflowId: 'b', message: 'failed')],
      );

      expect(
        WorkflowBulkArchiveResponse.fromJson(response.toJson()),
        equals(response),
      );
    });

    test('toJson omits null errored', () {
      final response = WorkflowBulkArchiveResponse(archived: const []);

      expect(response.toJson().containsKey('errored'), isFalse);
    });

    test('copyWith clears errored', () {
      final response = WorkflowBulkArchiveResponse(
        archived: const [],
        errored: const [WorkflowBulkError(workflowId: 'b', message: 'failed')],
      );

      expect(response.copyWith(errored: null).errored, isNull);
      expect(response.copyWith().errored, hasLength(1));
    });

    test('equality and hashCode', () {
      final a = WorkflowBulkArchiveResponse(
        archived: [Workflow.fromJson(workflowJson('a'))],
      );
      final b = WorkflowBulkArchiveResponse(
        archived: [Workflow.fromJson(workflowJson('a'))],
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toString contains counts', () {
      final response = WorkflowBulkArchiveResponse(
        archived: [Workflow.fromJson(workflowJson('a'))],
      );

      expect(response.toString(), contains('archived: 1'));
      expect(response.toString(), contains('errored: null'));
    });
  });
}
