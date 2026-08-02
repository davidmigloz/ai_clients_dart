import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('WorkflowExecutionResponse', () {
    Map<String, dynamic> responseJson() => {
      'workflow_name': 'my-workflow',
      'execution_id': 'exec-1',
      'root_execution_id': 'root-1',
      'status': 'COMPLETED',
      'start_time': '2030-01-01T00:00:00Z',
      'end_time': '2030-01-01T00:01:00Z',
      'result': {'ok': true},
      'parent_execution_id': 'parent-1',
      'total_duration_ms': 1000,
      'run_id': 'run-1',
      'deployment_name': 'deployment-1',
      'user_id': 'user-1',
      'workflow_id': 'workflow-1',
    };

    test('fromJson parses all fields', () {
      final response = WorkflowExecutionResponse.fromJson(responseJson());

      expect(response.workflowName, 'my-workflow');
      expect(response.executionId, 'exec-1');
      expect(response.rootExecutionId, 'root-1');
      expect(response.status, WorkflowExecutionStatus.completed);
      expect(response.startTime, '2030-01-01T00:00:00Z');
      expect(response.endTime, '2030-01-01T00:01:00Z');
      expect(response.result, {'ok': true});
      expect(response.parentExecutionId, 'parent-1');
      expect(response.totalDurationMs, 1000);
      expect(response.runId, 'run-1');
      expect(response.deploymentName, 'deployment-1');
      expect(response.userId, 'user-1');
      expect(response.workflowId, 'workflow-1');
    });

    test('toJson round-trips', () {
      final response = WorkflowExecutionResponse.fromJson(responseJson());

      expect(response.toJson(), responseJson());
      expect(
        WorkflowExecutionResponse.fromJson(response.toJson()),
        equals(response),
      );
    });

    test('copyWith replaces new fields', () {
      final response = WorkflowExecutionResponse.fromJson(responseJson());

      final copy = response.copyWith(
        deploymentName: 'other-deployment',
        userId: 'other-user',
        workflowId: 'other-workflow',
      );
      expect(copy.deploymentName, 'other-deployment');
      expect(copy.userId, 'other-user');
      expect(copy.workflowId, 'other-workflow');
      expect(copy.executionId, response.executionId);
    });

    test('copyWith preserves values when no arguments given', () {
      final response = WorkflowExecutionResponse.fromJson(responseJson());

      expect(response.copyWith(), equals(response));
    });

    test('copyWith clears new nullable fields to null via sentinel', () {
      final response = WorkflowExecutionResponse.fromJson(responseJson());

      final copy = response.copyWith(
        deploymentName: null,
        userId: null,
        workflowId: null,
      );
      expect(copy.deploymentName, isNull);
      expect(copy.userId, isNull);
      expect(copy.workflowId, isNull);
    });

    test('equality and hashCode', () {
      final a = WorkflowExecutionResponse.fromJson(responseJson());
      final b = WorkflowExecutionResponse.fromJson(responseJson());
      final c = WorkflowExecutionResponse.fromJson({
        ...responseJson(),
        'deployment_name': 'different',
      });

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('toString contains new fields', () {
      final response = WorkflowExecutionResponse.fromJson(responseJson());

      expect(response.toString(), contains('deploymentName: deployment-1'));
      expect(response.toString(), contains('userId: user-1'));
      expect(response.toString(), contains('workflowId: workflow-1'));
    });

    test('throws FormatException when a required field is missing', () {
      for (final key in [
        'workflow_name',
        'execution_id',
        'root_execution_id',
        'start_time',
      ]) {
        final json = responseJson()..remove(key);
        expect(
          () => WorkflowExecutionResponse.fromJson(json),
          throwsFormatException,
          reason: 'missing $key',
        );
      }
    });
  });
}
