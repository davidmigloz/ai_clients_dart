typedef WireFixture = ({
  String method,
  String path,
  Map<String, List<String>> query,
  Map<String, dynamic>? request,
  int status,
  Map<String, dynamic>? response,
});

/// Offline fixtures for the November public Observability routes.
const fixtures = <String, WireFixture>{
  'datasets.importFromSpans': (
    method: 'POST',
    path: '/v1/observability/datasets/fixture-dataset-id/imports/from-spans',
    query: {},
    request: {
      'mapping_contract': {
        'mappings': [
          {
            'source_field': {
              'namespace': 'span_attributes',
              'key': 'gen_ai.input.messages',
            },
            'target_field': 'input',
          },
        ],
        'version': 1,
      },
      'span_references': [
        {
          'span_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
          'trace_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
        },
      ],
    },
    status: 202,
    response: {
      'created_at': '2026-11-27T08:30:00.000Z',
      'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'creator_type': 'api_key',
      'dataset_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'deleted_at': null,
      'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'result': {
        'imported_record_count': 2,
        'requested_record_count': 2,
        'skipped_record_count': 2,
      },
      'status': 'RUNNING',
      'updated_at': '2026-11-27T08:30:00.000Z',
      'workspace_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
    },
  ),
  'datasets.createRecords': (
    method: 'POST',
    path: '/v1/observability/datasets/fixture-dataset-id/records/bulk',
    query: {},
    request: {
      'records': [
        {
          'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f180',
          'payload': {
            'question': 'Who called?',
            'expected': ['example'],
          },
          'source': 'DIRECT_INPUT',
        },
      ],
    },
    status: 201,
    response: {
      'records': [
        {
          'updated_at': '2026-11-27T08:30:00.000Z',
          'properties': {'score': 2},
          'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
          'created_at': '2026-11-27T08:30:00.000Z',
          'payload': {'question': 'Who called?'},
          'deleted_at': null,
          'dataset_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
          'source': 'TELEMETRY_SPAN',
        },
      ],
    },
  ),
  'evaluations.searchAllRuns': (
    method: 'POST',
    path: '/v1/observability/evaluation-runs_v2/search',
    query: {
      'page_size': ['2'],
      'page': ['2'],
    },
    request: {
      'creator_ids': ['test-user'],
      'metadata': {
        'combinator': 'and',
        'filters': [
          {'key': 'version', 'operator': 'eq', 'value': 2},
        ],
      },
      'tags': {
        'combinator': 'or',
        'values': ['nightly'],
      },
    },
    status: 200,
    response: {
      'runs': {
        'count': 2,
        'next': 'https://example.com/next',
        'previous': 'https://example.com/next',
        'results': [
          {
            'created_at': '2026-11-27T08:30:00.000Z',
            'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'deleted_at': null,
            'description': null,
            'evaluation': {
              'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
              'name': 'fixture-name',
              'slug': 'fixture-slug',
            },
            'evaluation_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'evaluators': [
              {
                'created_at': '2026-11-27T08:30:00.000Z',
                'deleted_at': null,
                'description': null,
                'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
                'name': 'fixture-name',
                'num_scores': 2,
                'tags': ['fixture-tags'],
                'updated_at': '2026-11-27T08:30:00.000Z',
              },
            ],
            'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'metadata_': {
              'demo': {
                'nested': [true, 2, null],
              },
            },
            'name': 'fixture-name',
            'num_generations': 2,
            'project': {
              'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
              'name': 'fixture-name',
              'slug': 'fixture-slug',
            },
            'run_scores': {
              'demo': {
                'created_at': '2026-11-27T08:30:00.000Z',
                'deleted_at': null,
                'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
                'metadata_': {
                  'demo': {
                    'nested': [true, 2, null],
                  },
                },
                'status': 'fixture-status',
                'updated_at': '2026-11-27T08:30:00.000Z',
                'value': {
                  'nested': [true, 2, null],
                },
              },
            },
            'statistics': {'demo': <String, dynamic>{}},
            'status': 'fixture-status',
            'system': {
              'created_at': '2026-11-27T08:30:00.000Z',
              'deleted_at': null,
              'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
              'name': 'fixture-name',
              'params': {'demo': 'fixture-params'},
              'updated_at': '2026-11-27T08:30:00.000Z',
            },
            'tags': ['fixture-tags'],
            'updated_at': '2026-11-27T08:30:00.000Z',
          },
        ],
      },
    },
  ),
  'evaluations.getRun': (
    method: 'GET',
    path: '/v1/observability/evaluation-runs_v2/fixture-run-id',
    query: {},
    request: null,
    status: 200,
    response: {
      'created_at': '2026-11-27T08:30:00.000Z',
      'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'deleted_at': null,
      'description': null,
      'evaluation_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'evaluators': [
        {
          'created_at': '2026-11-27T08:30:00.000Z',
          'deleted_at': null,
          'description': null,
          'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
          'name': 'fixture-name',
          'num_scores': 2,
          'tags': ['fixture-tags'],
          'updated_at': '2026-11-27T08:30:00.000Z',
        },
      ],
      'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'metadata_': {
        'demo': {
          'nested': [true, 2, null],
        },
      },
      'name': 'fixture-name',
      'num_generations': 2,
      'run_scores': {
        'demo': {
          'created_at': '2026-11-27T08:30:00.000Z',
          'deleted_at': null,
          'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
          'metadata_': {
            'demo': {
              'nested': [true, 2, null],
            },
          },
          'status': 'fixture-status',
          'updated_at': '2026-11-27T08:30:00.000Z',
          'value': {
            'nested': [true, 2, null],
          },
        },
      },
      'statistics': {'demo': <String, dynamic>{}},
      'status': 'fixture-status',
      'system': {
        'created_at': '2026-11-27T08:30:00.000Z',
        'deleted_at': null,
        'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
        'name': 'fixture-name',
        'params': {'demo': 'fixture-params'},
        'updated_at': '2026-11-27T08:30:00.000Z',
      },
      'tags': ['fixture-tags'],
      'updated_at': '2026-11-27T08:30:00.000Z',
    },
  ),
  'evaluations.searchRecords': (
    method: 'POST',
    path: '/v1/observability/evaluation-runs_v2/fixture-run-id/records/search',
    query: {
      'page_size': ['2'],
      'page': ['2'],
    },
    request: {
      'input_filters': {
        'filters': [
          {'operator': 'contains', 'path': 'messages', 'value': 'invoice'},
        ],
      },
      'sort': {
        'kind': 'score',
        'evaluator_name': 'quality',
        'direction': 'desc',
        'metric': 'avg',
      },
    },
    status: 200,
    response: {
      'records': {
        'count': 2,
        'next': 'https://example.com/next',
        'previous': 'https://example.com/next',
        'results': [
          {
            'created_at': '2026-11-27T08:30:00.000Z',
            'deleted_at': null,
            'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'input': {
              'nested': [true, 2, null],
            },
            'output_record': {
              'created_at': '2026-11-27T08:30:00.000Z',
              'deleted_at': null,
              'generations': [
                {
                  'created_at': '2026-11-27T08:30:00.000Z',
                  'deleted_at': null,
                  'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
                  'metadata_': <String, dynamic>{},
                  'output': {
                    'nested': [true, 2, null],
                  },
                  'status': 'fixture-status',
                  'updated_at': '2026-11-27T08:30:00.000Z',
                },
              ],
              'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
              'metadata_': {
                'demo': {
                  'nested': [true, 2, null],
                },
              },
              'updated_at': '2026-11-27T08:30:00.000Z',
            },
            'updated_at': '2026-11-27T08:30:00.000Z',
          },
        ],
      },
    },
  ),
  'evaluations.getRecord': (
    method: 'GET',
    path:
        '/v1/observability/evaluation-runs_v2/fixture-run-id/records/fixture-record-id',
    query: {},
    request: null,
    status: 200,
    response: {
      'created_at': '2026-11-27T08:30:00.000Z',
      'deleted_at': null,
      'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'input': {
        'nested': [true, 2, null],
      },
      'output_record': {
        'created_at': '2026-11-27T08:30:00.000Z',
        'deleted_at': null,
        'generations': [
          {
            'created_at': '2026-11-27T08:30:00.000Z',
            'deleted_at': null,
            'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'metadata_': {
              'demo': {
                'nested': [true, 2, null],
              },
            },
            'output': {
              'nested': [true, 2, null],
            },
            'status': 'fixture-status',
            'updated_at': '2026-11-27T08:30:00.000Z',
          },
        ],
        'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
        'metadata_': {
          'demo': {
            'nested': [true, 2, null],
          },
        },
        'updated_at': '2026-11-27T08:30:00.000Z',
      },
      'updated_at': '2026-11-27T08:30:00.000Z',
    },
  ),
  'evaluations.getStatistics': (
    method: 'GET',
    path: '/v1/observability/evaluation-runs_v2/fixture-run-id/statistics',
    query: {},
    request: null,
    status: 200,
    response: {
      'run_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'statistics': {'demo': <String, dynamic>{}},
    },
  ),
  'evaluations.computeStatistics': (
    method: 'POST',
    path:
        '/v1/observability/evaluation-runs_v2/fixture-run-id/statistics/compute',
    query: {},
    request: {
      'input_filters': {
        'filters': [
          {'operator': 'contains', 'path': 'messages', 'value': 'invoice'},
        ],
      },
      'sort': {
        'kind': 'score',
        'evaluator_name': 'quality',
        'direction': 'desc',
        'metric': 'avg',
      },
    },
    status: 200,
    response: {
      'run_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'statistics': {'demo': <String, dynamic>{}},
    },
  ),
  'evaluations.get': (
    method: 'GET',
    path: '/v1/observability/evaluations_v2/fixture-evaluation-slug',
    query: {},
    request: null,
    status: 200,
    response: {
      'created_at': '2026-11-27T08:30:00.000Z',
      'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'deleted_at': null,
      'description': null,
      'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'metadata_': {
        'demo': {
          'nested': [true, 2, null],
        },
      },
      'name': 'fixture-name',
      'project_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'slug': 'fixture-slug',
      'tags': ['fixture-tags'],
      'updated_at': '2026-11-27T08:30:00.000Z',
      'workspace_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
    },
  ),
  'evaluations.searchRuns': (
    method: 'POST',
    path:
        '/v1/observability/evaluations_v2/fixture-evaluation-slug/runs/search',
    query: {
      'page_size': ['2'],
      'page': ['2'],
    },
    request: {
      'creator_ids': ['test-user'],
      'metadata': {
        'combinator': 'and',
        'filters': [
          {'key': 'version', 'operator': 'eq', 'value': 2},
        ],
      },
      'tags': {
        'combinator': 'or',
        'values': ['nightly'],
      },
    },
    status: 200,
    response: {
      'runs': {
        'count': 2,
        'next': 'https://example.com/next',
        'previous': 'https://example.com/next',
        'results': [
          {
            'created_at': '2026-11-27T08:30:00.000Z',
            'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'deleted_at': null,
            'description': null,
            'evaluation_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'evaluators': [
              {
                'created_at': '2026-11-27T08:30:00.000Z',
                'deleted_at': null,
                'description': null,
                'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
                'name': 'fixture-name',
                'num_scores': 2,
                'tags': ['fixture-tags'],
                'updated_at': '2026-11-27T08:30:00.000Z',
              },
            ],
            'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'metadata_': {
              'demo': {
                'nested': [true, 2, null],
              },
            },
            'name': 'fixture-name',
            'num_generations': 2,
            'run_scores': {
              'demo': {
                'created_at': '2026-11-27T08:30:00.000Z',
                'deleted_at': null,
                'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
                'metadata_': {
                  'demo': {
                    'nested': [true, 2, null],
                  },
                },
                'status': 'fixture-status',
                'updated_at': '2026-11-27T08:30:00.000Z',
                'value': {
                  'nested': [true, 2, null],
                },
              },
            },
            'statistics': {'demo': <String, dynamic>{}},
            'status': 'fixture-status',
            'system': {
              'created_at': '2026-11-27T08:30:00.000Z',
              'deleted_at': null,
              'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
              'name': 'fixture-name',
              'params': {'demo': 'fixture-params'},
              'updated_at': '2026-11-27T08:30:00.000Z',
            },
            'tags': ['fixture-tags'],
            'updated_at': '2026-11-27T08:30:00.000Z',
          },
        ],
      },
    },
  ),
  'optimizations.list': (
    method: 'GET',
    path: '/v1/observability/optimizations',
    query: {
      'project': ['fixture-project'],
      'evaluation': ['fixture-evaluation'],
      'status': ['fixture-status'],
      'algorithm': ['fixture-algorithm'],
      'tags': ['nightly', 'smoke'],
      'page_size': ['2'],
      'page': ['2'],
    },
    request: null,
    status: 200,
    response: {
      'optimizations': {
        'count': 2,
        'next': 'https://example.com/next',
        'previous': 'https://example.com/next',
        'results': [
          {
            'algorithm': 'fixture-algorithm',
            'created_at': '2026-11-27T08:30:00.000Z',
            'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'deleted_at': null,
            'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'name': 'fixture-name',
            'project_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'source': 'fixture-source',
            'status': 'fixture-status',
            'updated_at': '2026-11-27T08:30:00.000Z',
          },
        ],
      },
    },
  ),
  'optimizations.get': (
    method: 'GET',
    path: '/v1/observability/optimizations/fixture-optimization-id',
    query: {},
    request: null,
    status: 200,
    response: {
      'algorithm': 'fixture-algorithm',
      'created_at': '2026-11-27T08:30:00.000Z',
      'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'deleted_at': null,
      'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'name': 'fixture-name',
      'project_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'source': 'fixture-source',
      'status': 'fixture-status',
      'updated_at': '2026-11-27T08:30:00.000Z',
    },
  ),
  'optimizations.listTrials': (
    method: 'GET',
    path: '/v1/observability/optimizations/fixture-optimization-id/trials',
    query: {
      'page_size': ['2'],
      'page': ['2'],
    },
    request: null,
    status: 200,
    response: {
      'trials': {
        'count': 2,
        'next': 'https://example.com/next',
        'previous': 'https://example.com/next',
        'results': [
          {
            'algorithm_trial_key': 'fixture-algorithm-trial-key',
            'created_at': '2026-11-27T08:30:00.000Z',
            'deleted_at': null,
            'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'metadata_': {
              'demo': {
                'nested': [true, 2, null],
              },
            },
            'optimization_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'status': 'fixture-status',
            'updated_at': '2026-11-27T08:30:00.000Z',
          },
        ],
      },
    },
  ),
  'pipelines.searchResults': (
    method: 'POST',
    path: '/v1/observability/pipeline-results/search',
    query: {
      'from': ['2026-11-27T08:30:00.000Z'],
      'to': ['2026-11-27T08:30:00.000Z'],
      'page_size': ['2'],
      'cursor': ['fixture-cursor'],
    },
    request: {
      'pipeline_config_slugs': ['cfg-1', 'cfg-2'],
      'search_expression': 'span_name = "completion"',
    },
    status: 200,
    response: {
      'pipeline_results': {
        'cursor': 'fixture-cursor',
        'next': 'https://example.com/next',
        'results': [
          {
            'duration_ns': 2,
            'evaluated_at': '2026-11-27T08:30:00.000Z',
            'judge_explanations': {'demo': 'fixture-judge-explanations'},
            'judge_labels': {'demo': 'fixture-judge-labels'},
            'judge_scores': {'demo': 0.5},
            'operation_name': 'fixture-operation-name',
            'span_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'span_name': 'fixture-span-name',
            'tool_name': 'fixture-tool-name',
            'trace_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
          },
        ],
      },
    },
  ),
  'pipelines.list': (
    method: 'GET',
    path: '/v1/observability/pipelines',
    query: {
      'enabled': ['true'],
      'from': ['2026-11-27T08:30:00.000Z'],
      'to': ['2026-11-27T08:30:00.000Z'],
      'page_size': ['2'],
      'page': ['2'],
      'q': ['fixture-q'],
    },
    request: null,
    status: 200,
    response: {
      'pipelines': {
        'count': 2,
        'next': 'https://example.com/next',
        'previous': 'https://example.com/next',
        'results': [
          {
            'created_at': '2026-11-27T08:30:00.000Z',
            'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'description': null,
            'enabled': true,
            'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'name': 'fixture-name',
            'pipeline_configs': [
              {
                'updated_at': '2026-11-27T08:30:00.000Z',
                'selectors': [
                  {'source_kind': 'span'},
                ],
                'pipeline_kind': 'judge-v1',
                'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
                'created_at': '2026-11-27T08:30:00.000Z',
                'slug': 'fixture-slug',
                'enabled': true,
                'deleted_at': null,
                'name': 'fixture-name',
                'scope': 'workspace',
                'workspace_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
                'definition': {
                  'model': 'fixture-model',
                  'prompt': 'fixture-prompt',
                  'result_spec': <String, dynamic>{},
                },
                'sampling': {'type': 'probabilistic', 'percentage': 25},
                'scorer_slug': 'fixture-scorer',
                'scorer_version': 3,
              },
            ],
            'selectors': [
              {'source_kind': 'span'},
            ],
            'slug': 'fixture-slug',
            'updated_at': '2026-11-27T08:30:00.000Z',
            'workspace_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
          },
        ],
      },
    },
  ),
  'pipelines.create': (
    method: 'POST',
    path: '/v1/observability/pipelines',
    query: {},
    request: {
      'name': 'Fixture Live Eval',
      'selectors': [
        {'source_kind': 'span', 'filter': 'span_name = "completion"'},
      ],
      'definitions': [
        {
          'slug': 'scorer-a',
          'sampling': {
            'type': 'attribute_hash',
            'attribute': 'user.id',
            'percentage': 50,
          },
        },
      ],
    },
    status: 201,
    response: {
      'created_at': '2026-11-27T08:30:00.000Z',
      'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'description': null,
      'enabled': true,
      'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'name': 'fixture-name',
      'pipeline_configs': [
        {
          'updated_at': '2026-11-27T08:30:00.000Z',
          'selectors': [
            {'source_kind': 'span'},
          ],
          'pipeline_kind': 'judge-v1',
          'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
          'created_at': '2026-11-27T08:30:00.000Z',
          'slug': 'fixture-slug',
          'enabled': true,
          'deleted_at': null,
          'name': 'fixture-name',
          'scope': 'workspace',
          'workspace_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
          'definition': {
            'model': 'fixture-model',
            'prompt': 'fixture-prompt',
            'result_spec': <String, dynamic>{},
          },
          'sampling': {'type': 'probabilistic', 'percentage': 25},
          'scorer_slug': 'fixture-scorer',
          'scorer_version': 3,
        },
      ],
      'selectors': [
        {'source_kind': 'span'},
      ],
      'slug': 'fixture-slug',
      'updated_at': '2026-11-27T08:30:00.000Z',
      'workspace_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
    },
  ),
  'pipelines.delete': (
    method: 'DELETE',
    path: '/v1/observability/pipelines/fixture-pipeline-id',
    query: {},
    request: null,
    status: 204,
    response: null,
  ),
  'pipelines.get': (
    method: 'GET',
    path: '/v1/observability/pipelines/fixture-pipeline-id',
    query: {},
    request: null,
    status: 200,
    response: {
      'created_at': '2026-11-27T08:30:00.000Z',
      'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'description': null,
      'enabled': true,
      'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'name': 'fixture-name',
      'pipeline_configs': [
        {
          'updated_at': '2026-11-27T08:30:00.000Z',
          'selectors': [
            {'source_kind': 'span'},
          ],
          'pipeline_kind': 'judge-v1',
          'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
          'created_at': '2026-11-27T08:30:00.000Z',
          'slug': 'fixture-slug',
          'enabled': true,
          'deleted_at': null,
          'name': 'fixture-name',
          'scope': 'workspace',
          'workspace_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
          'definition': {
            'model': 'fixture-model',
            'prompt': 'fixture-prompt',
            'result_spec': <String, dynamic>{},
          },
          'sampling': {'type': 'probabilistic', 'percentage': 25},
          'scorer_slug': 'fixture-scorer',
          'scorer_version': 3,
        },
      ],
      'selectors': [
        {'source_kind': 'span'},
      ],
      'slug': 'fixture-slug',
      'updated_at': '2026-11-27T08:30:00.000Z',
      'workspace_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
    },
  ),
  'pipelines.update': (
    method: 'PUT',
    path: '/v1/observability/pipelines/fixture-pipeline-id',
    query: {},
    request: {'description': null, 'enabled': false},
    status: 200,
    response: {
      'created_at': '2026-11-27T08:30:00.000Z',
      'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'description': null,
      'enabled': true,
      'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'name': 'fixture-name',
      'pipeline_configs': [
        {
          'updated_at': '2026-11-27T08:30:00.000Z',
          'selectors': [
            {'source_kind': 'span'},
          ],
          'pipeline_kind': 'judge-v1',
          'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
          'created_at': '2026-11-27T08:30:00.000Z',
          'slug': 'fixture-slug',
          'enabled': true,
          'deleted_at': null,
          'name': 'fixture-name',
          'scope': 'workspace',
          'workspace_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
          'definition': {
            'model': 'fixture-model',
            'prompt': 'fixture-prompt',
            'result_spec': <String, dynamic>{},
          },
          'sampling': {'type': 'probabilistic', 'percentage': 25},
          'scorer_slug': 'fixture-scorer',
          'scorer_version': 3,
        },
      ],
      'selectors': [
        {'source_kind': 'span'},
      ],
      'slug': 'fixture-slug',
      'updated_at': '2026-11-27T08:30:00.000Z',
      'workspace_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
    },
  ),
  'pipelines.getResultFields': (
    method: 'GET',
    path: '/v1/observability/pipelines/fixture-pipeline-id/results/fields',
    query: {},
    request: null,
    status: 200,
    response: {
      'field_definitions': [
        {
          'label': 'fixture-label',
          'name': 'fixture-name',
          'supported_aggregations': ['count'],
          'supported_operators': ['eq'],
        },
      ],
    },
  ),
  'projects.list': (
    method: 'GET',
    path: '/v1/observability/projects',
    query: {
      'q': ['fixture-q'],
      'page_size': ['2'],
      'page': ['2'],
    },
    request: null,
    status: 200,
    response: {
      'projects': {
        'count': 2,
        'next': 'https://example.com/next',
        'previous': 'https://example.com/next',
        'results': [
          {
            'created_at': '2026-11-27T08:30:00.000Z',
            'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'deleted_at': null,
            'description': null,
            'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'name': 'fixture-name',
            'slug': 'fixture-slug',
            'updated_at': '2026-11-27T08:30:00.000Z',
            'workspace_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
          },
        ],
      },
    },
  ),
  'projects.get': (
    method: 'GET',
    path: '/v1/observability/projects/fixture-project-slug',
    query: {},
    request: null,
    status: 200,
    response: {
      'created_at': '2026-11-27T08:30:00.000Z',
      'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'deleted_at': null,
      'description': null,
      'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
      'name': 'fixture-name',
      'slug': 'fixture-slug',
      'updated_at': '2026-11-27T08:30:00.000Z',
      'workspace_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
    },
  ),
  'projects.listEvaluations': (
    method: 'GET',
    path: '/v1/observability/projects/fixture-project-slug/evaluations_v2',
    query: {
      'page_size': ['2'],
      'page': ['2'],
    },
    request: null,
    status: 200,
    response: {
      'evaluations': {
        'count': 2,
        'next': 'https://example.com/next',
        'previous': 'https://example.com/next',
        'results': [
          {
            'created_at': '2026-11-27T08:30:00.000Z',
            'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'deleted_at': null,
            'description': null,
            'id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'metadata_': {
              'demo': {
                'nested': [true, 2, null],
              },
            },
            'name': 'fixture-name',
            'project_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'slug': 'fixture-slug',
            'tags': ['fixture-tags'],
            'updated_at': '2026-11-27T08:30:00.000Z',
            'workspace_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
          },
        ],
      },
    },
  ),
  'scorers.list': (
    method: 'GET',
    path: '/v1/observability/scorers',
    query: {
      'created_by_me': ['true'],
      'ootb': ['true'],
      'q': ['fixture-q'],
      'page_size': ['2'],
      'page': ['2'],
    },
    request: null,
    status: 200,
    response: {
      'scorers': {
        'count': 2,
        'next': 'https://example.com/next',
        'previous': 'https://example.com/next',
        'results': [
          {
            'created_at': '2026-11-27T08:30:00.000Z',
            'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
            'description': null,
            'is_ootb': true,
            'kind': 'llm_judge',
            'name': 'fixture-name',
            'slug': 'fixture-slug',
            'updated_at': '2026-11-27T08:30:00.000Z',
          },
        ],
      },
    },
  ),
  'scorers.create': (
    method: 'POST',
    path: '/v1/observability/scorers',
    query: {},
    request: {
      'config': {
        'model': 'fixture-model',
        'output_spec': <String, dynamic>{},
        'params': <String, dynamic>{},
        'prompt_template': 'fixture-prompt-template',
      },
      'kind': 'llm_judge',
      'name': 'fixture-name',
    },
    status: 201,
    response: {
      'created_at': '2026-11-27T08:30:00.000Z',
      'description': null,
      'kind': 'llm_judge',
      'latest_version': {
        'config': {
          'model': 'fixture-model',
          'output_spec': <String, dynamic>{},
          'params': <String, dynamic>{},
          'prompt_template': 'fixture-prompt-template',
        },
        'created_at': '2026-11-27T08:30:00.000Z',
        'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
        'variables': ['fixture-variables'],
        'version': 2,
      },
      'name': 'fixture-name',
      'slug': 'fixture-slug',
      'updated_at': '2026-11-27T08:30:00.000Z',
    },
  ),
  'scorers.get': (
    method: 'GET',
    path: '/v1/observability/scorers/fixture-scorer-slug',
    query: {},
    request: null,
    status: 200,
    response: {
      'created_at': '2026-11-27T08:30:00.000Z',
      'description': null,
      'kind': 'llm_judge',
      'latest_version': {
        'config': {
          'model': 'fixture-model',
          'output_spec': <String, dynamic>{},
          'params': <String, dynamic>{},
          'prompt_template': 'fixture-prompt-template',
        },
        'created_at': '2026-11-27T08:30:00.000Z',
        'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
        'variables': ['fixture-variables'],
        'version': 2,
      },
      'name': 'fixture-name',
      'slug': 'fixture-slug',
      'updated_at': '2026-11-27T08:30:00.000Z',
    },
  ),
  'scorers.update': (
    method: 'PATCH',
    path: '/v1/observability/scorers/fixture-scorer-slug',
    query: {},
    request: {'description': null, 'name': 'Updated scorer'},
    status: 200,
    response: {
      'created_at': '2026-11-27T08:30:00.000Z',
      'description': null,
      'kind': 'llm_judge',
      'latest_version': {
        'config': {
          'model': 'fixture-model',
          'output_spec': <String, dynamic>{},
          'params': <String, dynamic>{},
          'prompt_template': 'fixture-prompt-template',
        },
        'created_at': '2026-11-27T08:30:00.000Z',
        'creator_id': '018f879d-20cd-7e9f-a1bc-2f4f08b6f182',
        'variables': ['fixture-variables'],
        'version': 2,
      },
      'name': 'fixture-name',
      'slug': 'fixture-slug',
      'updated_at': '2026-11-27T08:30:00.000Z',
    },
  ),
  'spans.aggregate': (
    method: 'POST',
    path: '/v1/observability/spans/aggregate',
    query: {
      'from': ['2026-11-27T08:30:00.000Z'],
      'to': ['2026-11-27T08:30:00.000Z'],
    },
    request: {
      'metric': {'aggregation': 'avg', 'measure': 'duration_ns'},
      'dimensions': ['span_name'],
      'limit': 12,
      'search_expression': 'operation_name = "chat"',
    },
    status: 200,
    response: {
      'data': [
        {'metric_name': 'fixture-metric-name'},
      ],
      'meta': {
        'from_timestamp': '2026-11-27T08:30:00.000Z',
        'to_timestamp': '2026-11-27T08:30:00.000Z',
      },
    },
  ),
  'spans.aggregateEvaluations': (
    method: 'POST',
    path: '/v1/observability/spans/evaluations/aggregate',
    query: {
      'from': ['2026-11-27T08:30:00.000Z'],
      'to': ['2026-11-27T08:30:00.000Z'],
    },
    request: {
      'metric': {'aggregation': 'avg', 'measure': 'duration_ns'},
      'dimensions': ['span_name'],
      'limit': 12,
      'search_expression': 'operation_name = "chat"',
    },
    status: 200,
    response: {
      'data': [
        {'metric_name': 'fixture-metric-name'},
      ],
      'meta': {
        'from_timestamp': '2026-11-27T08:30:00.000Z',
        'to_timestamp': '2026-11-27T08:30:00.000Z',
      },
    },
  ),
  'traces.aggregate': (
    method: 'POST',
    path: '/v1/observability/traces/aggregate',
    query: {
      'from': ['2026-11-27T08:30:00.000Z'],
      'to': ['2026-11-27T08:30:00.000Z'],
    },
    request: {
      'metric': {'aggregation': 'avg', 'measure': 'duration_ns'},
      'dimensions': ['span_name'],
      'limit': 12,
      'search_expression': 'operation_name = "chat"',
    },
    status: 200,
    response: {
      'data': [
        {'metric_name': 'fixture-metric-name'},
      ],
      'meta': {
        'from_timestamp': '2026-11-27T08:30:00.000Z',
        'to_timestamp': '2026-11-27T08:30:00.000Z',
      },
    },
  ),
};
