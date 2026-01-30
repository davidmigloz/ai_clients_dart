import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('EvalRun', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'run-abc123',
        'eval_id': 'eval-xyz789',
        'created_at': 1614807352,
        'name': 'Test Run',
        'status': 'completed',
        'model': 'gpt-4o-mini',
        'object': 'eval.run',
        'data_source': {
          'type': 'jsonl',
          'source': {'type': 'file_id', 'file_id': 'file-123'},
        },
        'result_counts': {
          'total': 100,
          'passed': 90,
          'failed': 8,
          'errored': 2,
        },
        'per_model_usage': [
          {
            'model_name': 'gpt-4o-mini',
            'prompt_tokens': 1000,
            'completion_tokens': 500,
            'total_tokens': 1500,
          },
        ],
        'per_testing_criteria_results': [
          {'testing_criteria': 'check', 'passed': 90, 'failed': 10},
        ],
        'report_url': 'https://platform.openai.com/evals/run-abc123',
        'metadata': {'env': 'test'},
      };

      final run = EvalRun.fromJson(json);

      expect(run.id, 'run-abc123');
      expect(run.evalId, 'eval-xyz789');
      expect(run.status, EvalRunStatus.completed);
      expect(run.model, 'gpt-4o-mini');
      expect(run.dataSource, isA<JsonlRunDataSource>());
      expect(run.resultCounts?.total, 100);
      expect(run.resultCounts?.passed, 90);
      expect(run.perModelUsage, hasLength(1));
      expect(run.perTestingCriteriaResults, hasLength(1));
      expect(run.reportUrl, isNotNull);
      expect(run.isCompleted, isTrue);
      expect(run.passRate, closeTo(0.9, 0.01));
    });

    test('status helpers work correctly', () {
      const queuedRun = EvalRun(
        id: 'run-1',
        evalId: 'eval-1',
        createdAt: 1614807352,
        name: 'Test',
        status: EvalRunStatus.queued,
        model: 'gpt-4o',
        object: 'eval.run',
        dataSource: JsonlRunDataSource(
          source: JsonlFileSource(fileId: 'file-1'),
        ),
      );

      expect(queuedRun.isRunning, isTrue);
      expect(queuedRun.isCompleted, isFalse);
      expect(queuedRun.isFailed, isFalse);
      expect(queuedRun.isCanceled, isFalse);

      const failedRun = EvalRun(
        id: 'run-2',
        evalId: 'eval-1',
        createdAt: 1614807352,
        name: 'Test',
        status: EvalRunStatus.failed,
        model: 'gpt-4o',
        object: 'eval.run',
        dataSource: JsonlRunDataSource(
          source: JsonlFileSource(fileId: 'file-1'),
        ),
      );

      expect(failedRun.isRunning, isFalse);
      expect(failedRun.isFailed, isTrue);
    });
  });

  group('EvalRunStatus', () {
    test('fromJson parses all values', () {
      expect(EvalRunStatus.fromJson('queued'), EvalRunStatus.queued);
      expect(EvalRunStatus.fromJson('in_progress'), EvalRunStatus.inProgress);
      expect(EvalRunStatus.fromJson('completed'), EvalRunStatus.completed);
      expect(EvalRunStatus.fromJson('canceled'), EvalRunStatus.canceled);
      expect(EvalRunStatus.fromJson('failed'), EvalRunStatus.failed);
    });

    test('toJson returns correct strings', () {
      expect(EvalRunStatus.queued.toJson(), 'queued');
      expect(EvalRunStatus.inProgress.toJson(), 'in_progress');
      expect(EvalRunStatus.completed.toJson(), 'completed');
    });

    test('fromJson throws on unknown value', () {
      expect(
        () => EvalRunStatus.fromJson('unknown'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('EvalRunResultCounts', () {
    test('fromJson parses correctly', () {
      final json = {'total': 100, 'passed': 80, 'failed': 15, 'errored': 5};

      final counts = EvalRunResultCounts.fromJson(json);

      expect(counts.total, 100);
      expect(counts.passed, 80);
      expect(counts.failed, 15);
      expect(counts.errored, 5);
    });

    test('toJson serializes correctly', () {
      const counts = EvalRunResultCounts(
        total: 50,
        passed: 45,
        failed: 3,
        errored: 2,
      );

      final json = counts.toJson();

      expect(json['total'], 50);
      expect(json['passed'], 45);
      expect(json['failed'], 3);
      expect(json['errored'], 2);
    });
  });

  group('EvalRunPerModelUsage', () {
    test('fromJson parses correctly', () {
      final json = {
        'model_name': 'gpt-4o-mini',
        'prompt_tokens': 1000,
        'completion_tokens': 500,
        'total_tokens': 1500,
        'cached_tokens': 100,
        'invocation_count': 50,
      };

      final usage = EvalRunPerModelUsage.fromJson(json);

      expect(usage.modelName, 'gpt-4o-mini');
      expect(usage.promptTokens, 1000);
      expect(usage.completionTokens, 500);
      expect(usage.totalTokens, 1500);
      expect(usage.cachedTokens, 100);
      expect(usage.invocationCount, 50);
    });
  });

  group('EvalRunPerTestingCriteriaResult', () {
    test('fromJson parses correctly', () {
      final json = {
        'testing_criteria': 'sentiment_check',
        'passed': 85,
        'failed': 15,
      };

      final result = EvalRunPerTestingCriteriaResult.fromJson(json);

      expect(result.testingCriteria, 'sentiment_check');
      expect(result.passed, 85);
      expect(result.failed, 15);
      expect(result.total, 100);
      expect(result.passRate, closeTo(0.85, 0.01));
    });
  });

  group('CreateEvalRunRequest', () {
    test('toJson serializes correctly', () {
      final request = CreateEvalRunRequest(
        name: 'Test Run',
        dataSource: EvalRunDataSource.jsonlFile('file-abc123'),
        metadata: const {'version': '1'},
      );

      final json = request.toJson();

      expect(json['name'], 'Test Run');
      expect((json['data_source'] as Map<String, dynamic>)['type'], 'jsonl');
      expect(json['metadata'], {'version': '1'});
    });
  });

  group('DeleteEvalRunResponse', () {
    test('fromJson parses correctly', () {
      final json = {
        'run_id': 'run-abc123',
        'object': 'eval.run.deleted',
        'deleted': true,
      };

      final response = DeleteEvalRunResponse.fromJson(json);

      expect(response.runId, 'run-abc123');
      expect(response.object, 'eval.run.deleted');
      expect(response.deleted, isTrue);
    });
  });

  group('EvalApiError', () {
    test('fromJson parses correctly', () {
      final json = {
        'code': 'invalid_request',
        'message': 'The request was invalid',
      };

      final error = EvalApiError.fromJson(json);

      expect(error.code, 'invalid_request');
      expect(error.message, 'The request was invalid');
    });
  });
}
