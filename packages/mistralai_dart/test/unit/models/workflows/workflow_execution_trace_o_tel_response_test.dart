import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('WorkflowExecutionTraceOTelResponse', () {
    Map<String, dynamic> responseJson() => {
      'workflow_name': 'my-workflow',
      'execution_id': 'exec-1',
      'root_execution_id': 'root-1',
      'status': 'COMPLETED',
      'start_time': '2030-01-01T00:00:00Z',
      'end_time': '2030-01-01T00:01:00Z',
      'result': {'ok': true},
      'data_source': 'tempo',
      'otel_trace_id': 'trace-1',
      'parent_execution_id': 'parent-1',
      'total_duration_ms': 1000,
      'run_id': 'run-1',
      'deployment_name': 'deployment-1',
      'user_id': 'user-1',
      'workflow_id': 'workflow-1',
    };

    test('fromJson parses all fields', () {
      final response = WorkflowExecutionTraceOTelResponse.fromJson(
        responseJson(),
      );

      expect(response.workflowName, 'my-workflow');
      expect(response.dataSource, 'tempo');
      expect(response.otelTraceId, 'trace-1');
      expect(response.deploymentName, 'deployment-1');
      expect(response.userId, 'user-1');
      expect(response.workflowId, 'workflow-1');
    });

    test('toJson round-trips', () {
      final response = WorkflowExecutionTraceOTelResponse.fromJson(
        responseJson(),
      );

      expect(response.toJson(), responseJson());
      expect(
        WorkflowExecutionTraceOTelResponse.fromJson(response.toJson()),
        equals(response),
      );
    });

    test('copyWith replaces new fields', () {
      final response = WorkflowExecutionTraceOTelResponse.fromJson(
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
    });

    test('copyWith clears new nullable fields to null via sentinel', () {
      final response = WorkflowExecutionTraceOTelResponse.fromJson(
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
      final a = WorkflowExecutionTraceOTelResponse.fromJson(responseJson());
      final b = WorkflowExecutionTraceOTelResponse.fromJson(responseJson());
      final c = WorkflowExecutionTraceOTelResponse.fromJson({
        ...responseJson(),
        'deployment_name': 'different',
      });

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('toString contains new fields', () {
      final response = WorkflowExecutionTraceOTelResponse.fromJson(
        responseJson(),
      );

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
        'data_source',
        'status',
        'end_time',
        'result',
      ]) {
        final json = responseJson()..remove(key);
        expect(
          () => WorkflowExecutionTraceOTelResponse.fromJson(json),
          throwsFormatException,
          reason: 'missing $key',
        );
      }
    });

    test(
      'accepts explicit null for required-nullable status/end_time/result',
      () {
        final json = responseJson()
          ..['status'] = null
          ..['end_time'] = null
          ..['result'] = null;

        final response = WorkflowExecutionTraceOTelResponse.fromJson(json);
        expect(response.status, isNull);
        expect(response.endTime, isNull);
        expect(response.result, isNull);
      },
    );
  });
}
