import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('WorkflowExecutionWithoutResultResponse', () {
    Map<String, dynamic> responseJson() => {
      'workflow_name': 'my-workflow',
      'execution_id': 'exec-1',
      'root_execution_id': 'root-1',
      'status': 'COMPLETED',
      'start_time': '2030-01-01T00:00:00Z',
      'end_time': '2030-01-01T00:01:00Z',
      'parent_execution_id': 'parent-1',
      'total_duration_ms': 1000,
      'run_id': 'run-1',
      'deployment_name': 'deployment-1',
      'user_id': 'user-1',
      'workflow_id': 'workflow-1',
    };

    test('fromJson parses all fields', () {
      final response = WorkflowExecutionWithoutResultResponse.fromJson(
        responseJson(),
      );

      expect(response.workflowName, 'my-workflow');
      expect(response.executionId, 'exec-1');
      expect(response.rootExecutionId, 'root-1');
      expect(response.status, WorkflowExecutionStatus.completed);
      expect(response.startTime, '2030-01-01T00:00:00Z');
      expect(response.endTime, '2030-01-01T00:01:00Z');
      expect(response.parentExecutionId, 'parent-1');
      expect(response.totalDurationMs, 1000);
      expect(response.runId, 'run-1');
      expect(response.deploymentName, 'deployment-1');
      expect(response.userId, 'user-1');
      expect(response.workflowId, 'workflow-1');
    });

    test('toJson round-trips', () {
      final response = WorkflowExecutionWithoutResultResponse.fromJson(
        responseJson(),
      );

      expect(response.toJson(), responseJson());
      expect(
        WorkflowExecutionWithoutResultResponse.fromJson(response.toJson()),
        equals(response),
      );
    });

    test('copyWith replaces new fields', () {
      final response = WorkflowExecutionWithoutResultResponse.fromJson(
        responseJson(),
      );

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

    test('copyWith clears new nullable fields to null via sentinel', () {
      final response = WorkflowExecutionWithoutResultResponse.fromJson(
        responseJson(),
      );

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
      final a = WorkflowExecutionWithoutResultResponse.fromJson(responseJson());
      final b = WorkflowExecutionWithoutResultResponse.fromJson(responseJson());
      final c = WorkflowExecutionWithoutResultResponse.fromJson({
        ...responseJson(),
        'workflow_id': 'different',
      });

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('toString contains new fields', () {
      final response = WorkflowExecutionWithoutResultResponse.fromJson(
        responseJson(),
      );

      expect(response.toString(), contains('deploymentName: deployment-1'));
      expect(response.toString(), contains('userId: user-1'));
      expect(response.toString(), contains('workflowId: workflow-1'));
    });
  });
}
