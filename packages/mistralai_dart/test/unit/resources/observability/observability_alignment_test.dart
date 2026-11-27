import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

import 'observability_alignment_fixtures.dart';

void main() {
  test(
    'POST /v1/observability/datasets/{dataset_id}/imports/from-spans',
    () async {
      final fixture = fixtures['datasets.importFromSpans']!;
      final client = _client(fixture);
      final response = await client.observability.datasets.importFromSpans(
        datasetId: 'fixture-dataset-id',
        request: ImportDatasetFromSpansRequest.fromJson(fixture.request!),
      );
      expect(response.toJson(), fixture.response);
    },
  );

  test('POST /v1/observability/datasets/{dataset_id}/records/bulk', () async {
    final fixture = fixtures['datasets.createRecords']!;
    final client = _client(fixture);
    final response = await client.observability.datasets.createRecords(
      datasetId: 'fixture-dataset-id',
      request: CreateDatasetRecordsRequest.fromJson(fixture.request!),
    );
    expect(response.toJson(), fixture.response);
  });

  test('POST /v1/observability/evaluation-runs_v2/search', () async {
    final fixture = fixtures['evaluations.searchAllRuns']!;
    final client = _client(fixture);
    final response = await client.observability.evaluations.searchAllRuns(
      pageSize: 2,
      page: 2,
      filters: EvaluationRunFilterInput.fromJson(fixture.request!),
    );
    expect(response.toJson(), fixture.response);
  });

  test('GET /v1/observability/evaluation-runs_v2/{run_id}', () async {
    final fixture = fixtures['evaluations.getRun']!;
    final client = _client(fixture);
    final response = await client.observability.evaluations.getRun(
      runId: 'fixture-run-id',
    );
    expect(response.toJson(), fixture.response);
  });

  test(
    'POST /v1/observability/evaluation-runs_v2/{run_id}/records/search',
    () async {
      final fixture = fixtures['evaluations.searchRecords']!;
      final client = _client(fixture);
      final response = await client.observability.evaluations.searchRecords(
        runId: 'fixture-run-id',
        pageSize: 2,
        page: 2,
        filters: EvaluationRunRecordFilterInput.fromJson(fixture.request!),
      );
      expect(response.toJson(), fixture.response);
    },
  );

  test(
    'GET /v1/observability/evaluation-runs_v2/{run_id}/records/{record_id}',
    () async {
      final fixture = fixtures['evaluations.getRecord']!;
      final client = _client(fixture);
      final response = await client.observability.evaluations.getRecord(
        runId: 'fixture-run-id',
        recordId: 'fixture-record-id',
      );
      expect(response.toJson(), fixture.response);
    },
  );

  test(
    'GET /v1/observability/evaluation-runs_v2/{run_id}/statistics',
    () async {
      final fixture = fixtures['evaluations.getStatistics']!;
      final client = _client(fixture);
      final response = await client.observability.evaluations.getStatistics(
        runId: 'fixture-run-id',
      );
      expect(response.toJson(), fixture.response);
    },
  );

  test(
    'POST /v1/observability/evaluation-runs_v2/{run_id}/statistics/compute',
    () async {
      final fixture = fixtures['evaluations.computeStatistics']!;
      final client = _client(fixture);
      final response = await client.observability.evaluations.computeStatistics(
        runId: 'fixture-run-id',
        filters: EvaluationRunRecordFilterInput.fromJson(fixture.request!),
      );
      expect(response.toJson(), fixture.response);
    },
  );

  test('GET /v1/observability/evaluations_v2/{evaluation_slug}', () async {
    final fixture = fixtures['evaluations.get']!;
    final client = _client(fixture);
    final response = await client.observability.evaluations.get(
      evaluationSlug: 'fixture-evaluation-slug',
    );
    expect(response.toJson(), fixture.response);
  });

  test(
    'POST /v1/observability/evaluations_v2/{evaluation_slug}/runs/search',
    () async {
      final fixture = fixtures['evaluations.searchRuns']!;
      final client = _client(fixture);
      final response = await client.observability.evaluations.searchRuns(
        evaluationSlug: 'fixture-evaluation-slug',
        pageSize: 2,
        page: 2,
        filters: EvaluationRunFilterInput.fromJson(fixture.request!),
      );
      expect(response.toJson(), fixture.response);
    },
  );

  test('GET /v1/observability/optimizations', () async {
    final fixture = fixtures['optimizations.list']!;
    final client = _client(fixture);
    final response = await client.observability.optimizations.list(
      project: 'fixture-project',
      evaluation: 'fixture-evaluation',
      status: 'fixture-status',
      algorithm: 'fixture-algorithm',
      tags: ['nightly', 'smoke'],
      pageSize: 2,
      page: 2,
    );
    expect(response.toJson(), fixture.response);
  });

  test('GET /v1/observability/optimizations/{optimization_id}', () async {
    final fixture = fixtures['optimizations.get']!;
    final client = _client(fixture);
    final response = await client.observability.optimizations.get(
      optimizationId: 'fixture-optimization-id',
    );
    expect(response.toJson(), fixture.response);
  });

  test(
    'GET /v1/observability/optimizations/{optimization_id}/trials',
    () async {
      final fixture = fixtures['optimizations.listTrials']!;
      final client = _client(fixture);
      final response = await client.observability.optimizations.listTrials(
        optimizationId: 'fixture-optimization-id',
        pageSize: 2,
        page: 2,
      );
      expect(response.toJson(), fixture.response);
    },
  );

  test('POST /v1/observability/pipeline-results/search', () async {
    final fixture = fixtures['pipelines.searchResults']!;
    final client = _client(fixture);
    final response = await client.observability.pipelines.searchResults(
      from: DateTime.parse('2026-11-27T08:30:00.000Z'),
      to: DateTime.parse('2026-11-27T08:30:00.000Z'),
      pageSize: 2,
      cursor: 'fixture-cursor',
      request: PipelineResultsRequest.fromJson(fixture.request!),
    );
    expect(response.toJson(), fixture.response);
  });

  test('GET /v1/observability/pipelines', () async {
    final fixture = fixtures['pipelines.list']!;
    final client = _client(fixture);
    final response = await client.observability.pipelines.list(
      enabled: true,
      from: DateTime.parse('2026-11-27T08:30:00.000Z'),
      to: DateTime.parse('2026-11-27T08:30:00.000Z'),
      pageSize: 2,
      page: 2,
      q: 'fixture-q',
    );
    expect(response.toJson(), fixture.response);
  });

  test('POST /v1/observability/pipelines', () async {
    final fixture = fixtures['pipelines.create']!;
    final client = _client(fixture);
    final response = await client.observability.pipelines.create(
      request: CreatePipelineRequest.fromJson(fixture.request!),
    );
    expect(response.toJson(), fixture.response);
  });

  test('DELETE /v1/observability/pipelines/{pipeline_id}', () async {
    final fixture = fixtures['pipelines.delete']!;
    final client = _client(fixture);
    await client.observability.pipelines.delete(
      pipelineId: 'fixture-pipeline-id',
    );
  });

  test('GET /v1/observability/pipelines/{pipeline_id}', () async {
    final fixture = fixtures['pipelines.get']!;
    final client = _client(fixture);
    final response = await client.observability.pipelines.get(
      pipelineId: 'fixture-pipeline-id',
    );
    expect(response.toJson(), fixture.response);
  });

  test('PUT /v1/observability/pipelines/{pipeline_id}', () async {
    final fixture = fixtures['pipelines.update']!;
    final client = _client(fixture);
    final response = await client.observability.pipelines.update(
      pipelineId: 'fixture-pipeline-id',
      request: UpdatePipelineRequest.fromJson(fixture.request!),
    );
    expect(response.toJson(), fixture.response);
  });

  test(
    'GET /v1/observability/pipelines/{pipeline_id}/results/fields',
    () async {
      final fixture = fixtures['pipelines.getResultFields']!;
      final client = _client(fixture);
      final response = await client.observability.pipelines.getResultFields(
        pipelineId: 'fixture-pipeline-id',
      );
      expect(response.toJson(), fixture.response);
    },
  );

  test('GET /v1/observability/projects', () async {
    final fixture = fixtures['projects.list']!;
    final client = _client(fixture);
    final response = await client.observability.projects.list(
      q: 'fixture-q',
      pageSize: 2,
      page: 2,
    );
    expect(response.toJson(), fixture.response);
  });

  test('GET /v1/observability/projects/{project_slug}', () async {
    final fixture = fixtures['projects.get']!;
    final client = _client(fixture);
    final response = await client.observability.projects.get(
      projectSlug: 'fixture-project-slug',
    );
    expect(response.toJson(), fixture.response);
  });

  test(
    'GET /v1/observability/projects/{project_slug}/evaluations_v2',
    () async {
      final fixture = fixtures['projects.listEvaluations']!;
      final client = _client(fixture);
      final response = await client.observability.projects.listEvaluations(
        projectSlug: 'fixture-project-slug',
        pageSize: 2,
        page: 2,
      );
      expect(response.toJson(), fixture.response);
    },
  );

  test('GET /v1/observability/scorers', () async {
    final fixture = fixtures['scorers.list']!;
    final client = _client(fixture);
    final response = await client.observability.scorers.list(
      createdByMe: true,
      ootb: true,
      q: 'fixture-q',
      pageSize: 2,
      page: 2,
    );
    expect(response.toJson(), fixture.response);
  });

  test('POST /v1/observability/scorers', () async {
    final fixture = fixtures['scorers.create']!;
    final client = _client(fixture);
    final response = await client.observability.scorers.create(
      request: CreateScorerRequest.fromJson(fixture.request!),
    );
    expect(response.toJson(), fixture.response);
  });

  test('GET /v1/observability/scorers/{scorer_slug}', () async {
    final fixture = fixtures['scorers.get']!;
    final client = _client(fixture);
    final response = await client.observability.scorers.get(
      scorerSlug: 'fixture-scorer-slug',
    );
    expect(response.toJson(), fixture.response);
  });

  test('PATCH /v1/observability/scorers/{scorer_slug}', () async {
    final fixture = fixtures['scorers.update']!;
    final client = _client(fixture);
    final response = await client.observability.scorers.update(
      scorerSlug: 'fixture-scorer-slug',
      request: EditScorerRequest.fromJson(fixture.request!),
    );
    expect(response.toJson(), fixture.response);
  });

  test('POST /v1/observability/spans/aggregate', () async {
    final fixture = fixtures['spans.aggregate']!;
    final client = _client(fixture);
    final response = await client.observability.spans.aggregate(
      from: DateTime.parse('2026-11-27T08:30:00.000Z'),
      to: DateTime.parse('2026-11-27T08:30:00.000Z'),
      request: AggregationRequest.fromJson(fixture.request!),
    );
    expect(response.toJson(), fixture.response);
  });

  test('POST /v1/observability/spans/evaluations/aggregate', () async {
    final fixture = fixtures['spans.aggregateEvaluations']!;
    final client = _client(fixture);
    final response = await client.observability.spans.aggregateEvaluations(
      from: DateTime.parse('2026-11-27T08:30:00.000Z'),
      to: DateTime.parse('2026-11-27T08:30:00.000Z'),
      request: AggregationRequest.fromJson(fixture.request!),
    );
    expect(response.toJson(), fixture.response);
  });

  test('POST /v1/observability/traces/aggregate', () async {
    final fixture = fixtures['traces.aggregate']!;
    final client = _client(fixture);
    final response = await client.observability.traces.aggregate(
      from: DateTime.parse('2026-11-27T08:30:00.000Z'),
      to: DateTime.parse('2026-11-27T08:30:00.000Z'),
      request: AggregationRequest.fromJson(fixture.request!),
    );
    expect(response.toJson(), fixture.response);
  });
  test(
    'existing telemetry reads include service account and cursor fields',
    () async {
      var calls = 0;
      final client = MistralClient.withApiKey(
        'offline-test',
        httpClient: MockClient((request) async {
          calls++;
          final leaf = request.url.pathSegments[2];
          expect(leaf, isIn(['logs', 'spans', 'traces']));
          expect(request.method, 'POST');
          expect(request.url.queryParameters, {
            'cursor': 'p+1/=',
            'page_size': '2',
          });
          final requestData = jsonDecode(request.body) as Map<String, dynamic>;
          expect(requestData['search_expression'], 'service_name = "checkout"');
          if (leaf == 'logs') expect(requestData['order'], 'asc');
          return http.Response(
            jsonEncode({
              leaf: {
                'cursor': 'p+1/=',
                'next': 'p+2/=',
                'results': [
                  {'trace_id': 'trace-1', 'service_account_id': 'service-1'},
                ],
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.close);
      final obs = client.observability;
      const search = 'service_name = "checkout"';
      final logs = await obs.logs.search(
        request: const LogsRequest(order: 'asc', searchExpression: search),
        cursor: 'p+1/=',
        pageSize: 2,
      );
      final spans = await obs.spans.search(
        request: const SpansRequest(searchExpression: search),
        cursor: 'p+1/=',
        pageSize: 2,
      );
      final traces = await obs.traces.search(
        request: const TracesRequest(searchExpression: search),
        cursor: 'p+1/=',
        pageSize: 2,
      );
      expect(logs.logs.results.single.serviceAccountId, 'service-1');
      expect(spans.spans.results.single.serviceAccountId, 'service-1');
      expect(traces.traces.results.single.serviceAccountId, 'service-1');
      expect(logs.logs.next, 'p+2/=');
      expect(spans.spans.next, 'p+2/=');
      expect(traces.traces.next, 'p+2/=');
      expect(calls, 3);
    },
  );

  test('preserves paging for existing dataset record lists', () async {
    final client = _client((
      method: 'GET',
      path: '/v1/observability/datasets/ds-1/records',
      query: const {
        'page': ['2'],
        'page_size': ['1'],
      },
      request: null,
      status: 200,
      response: const {
        'records': {'count': 3, 'next': '?page=3', 'results': <Object>[]},
      },
    ));
    final page = await client.observability.datasets.listRecords(
      datasetId: 'ds-1',
      page: 2,
      pageSize: 1,
    );
    expect(page.records.count, 3);
    expect(page.records.next, '?page=3');
  });

  test('uses shared status and retains nested Observability errors', () async {
    const detail = {
      'detail': {
        'message': 'A scorer with this name exists',
        'error_code': 'SCORER_ALREADY_EXISTS',
      },
    };
    final client = _client((
      method: 'PATCH',
      path: '/v1/observability/scorers/eval-1',
      query: const {},
      request: const {'name': 'Already used'},
      status: 409,
      response: detail,
    ));
    await expectLater(
      client.observability.scorers.update(
        scorerSlug: 'eval-1',
        request: const EditScorerRequest(name: 'Already used'),
      ),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'status', 409)
            .having(
              (error) => error.message,
              'message',
              'A scorer with this name exists',
            )
            .having(
              (error) => ObservabilityError.fromJson(
                error.details.single as Map<String, dynamic>,
              ).detail.errorCode,
              'wire error code',
              ObservabilityErrorCode.scorerAlreadyExists,
            ),
      ),
    );
  });

  test('distinguishes an omitted aggregation field from an empty array', () {
    const field = {
      'name': 'duration_ns',
      'label': 'Duration',
      'type': 'FLOAT',
      'supported_operators': ['eq'],
    };
    final historical = OtelFieldDefinition.fromJson(field);
    final current = historical.copyWith(supportedAggregations: []);
    expect(historical.supportedAggregations, isEmpty);
    expect(historical.copyWith().toJson(), field);
    expect(current.toJson(), {...field, 'supported_aggregations': <String>[]});
    expect(current, OtelFieldDefinition.fromJson(current.toJson()));
  });

  test('leaves an optional run search body absent', () async {
    final client = _client((
      method: 'POST',
      path: '/v1/observability/evaluation-runs_v2/search',
      query: const {},
      request: null,
      status: 200,
      response: const {
        'runs': {'count': 0, 'results': <Object>[]},
      },
    ));
    final response = await client.observability.evaluations.searchAllRuns();
    expect(response.runs.results, isEmpty);
  });
}

MistralClient _client(WireFixture fixture) {
  final client = MistralClient.withApiKey(
    'offline-test',
    httpClient: MockClient((request) async {
      expect(request.method, fixture.method);
      expect(request.url.path, fixture.path);
      expect(request.url.queryParametersAll, fixture.query);
      expect(request.headers['authorization'], 'Bearer offline-test');
      expect(request.headers['accept'], 'application/json');
      if (fixture.request != null) {
        expect(request.headers['content-type'], startsWith('application/json'));
        expect(jsonDecode(request.body), fixture.request);
      } else {
        expect(request.body, isEmpty);
      }
      return http.Response(
        fixture.response == null ? '' : jsonEncode(fixture.response),
        fixture.status,
        headers: {'content-type': 'application/json'},
      );
    }),
  );
  addTearDown(client.close);
  return client;
}
