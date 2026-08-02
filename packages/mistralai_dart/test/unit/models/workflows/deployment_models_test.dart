@TestOn('vm')
library;

import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DeploymentWorkerSpecInput', () {
    test('applies defaults and round-trips', () {
      const spec = DeploymentWorkerSpecInput(
        githubUrl: 'https://github.com/org/repo',
      );
      expect(spec.entrypoint, 'worker:main');
      expect(spec.revision, 'main');

      final json = spec.toJson();
      expect(json['github_url'], 'https://github.com/org/repo');
      expect(json['entrypoint'], 'worker:main');
      expect(json['revision'], 'main');

      expect(DeploymentWorkerSpecInput.fromJson(json), spec);
    });

    test('throws FormatException when github_url is missing', () {
      expect(
        () => DeploymentWorkerSpecInput.fromJson(const {}),
        throwsFormatException,
      );
    });
  });

  group('DeploymentWorkerSpecResponse', () {
    test('round-trips through JSON with default type', () {
      const spec = DeploymentWorkerSpecResponse(
        githubUrl: 'https://github.com/org/repo',
        commitSha: 'abc123',
      );
      final json = spec.toJson();
      expect(json['type'], 'workflows_worker');
      expect(DeploymentWorkerSpecResponse.fromJson(json), spec);
    });
  });

  group('WorkflowsWorkerSpecUpdate', () {
    test('round-trips through JSON with all-optional fields', () {
      const update = WorkflowsWorkerSpecUpdate(revision: 'v2');
      final json = update.toJson();
      expect(json, {'revision': 'v2'});
      expect(WorkflowsWorkerSpecUpdate.fromJson(json), update);
    });
  });

  group('DeploymentResourceConfig / DeploymentResourceConfigUpdate', () {
    test('round-trip through JSON', () {
      const config = DeploymentResourceConfig(
        cpuLimit: '1',
        memoryLimit: '1Gi',
        replicas: 2,
      );
      expect(DeploymentResourceConfig.fromJson(config.toJson()), config);

      const update = DeploymentResourceConfigUpdate(replicas: 3);
      expect(DeploymentResourceConfigUpdate.fromJson(update.toJson()), update);
    });
  });

  group('CreateDeploymentRequest', () {
    test('serializes required fields and optional resources', () {
      const request = CreateDeploymentRequest(
        name: 'my-deployment',
        spec: DeploymentWorkerSpecInput(
          githubUrl: 'https://github.com/org/repo',
        ),
        resources: DeploymentResourceConfig(replicas: 1),
      );
      final json = request.toJson();
      expect(json['name'], 'my-deployment');
      expect(json['spec'], isA<Map<String, dynamic>>());
      expect(json['resources'], {'replicas': 1});
      expect(CreateDeploymentRequest.fromJson(json), request);
    });

    test('throws FormatException when required fields are missing', () {
      expect(
        () => CreateDeploymentRequest.fromJson(const {}),
        throwsFormatException,
      );
    });
  });

  group('UpdateDeploymentRequest', () {
    test('round-trips partial updates', () {
      const request = UpdateDeploymentRequest(
        spec: WorkflowsWorkerSpecUpdate(revision: 'v2'),
      );
      final json = request.toJson();
      expect(json, {
        'spec': {'revision': 'v2'},
      });
      expect(UpdateDeploymentRequest.fromJson(json), request);
    });

    test('copyWith clears fields with explicit null', () {
      const request = UpdateDeploymentRequest(
        resources: DeploymentResourceConfigUpdate(replicas: 5),
      );
      final cleared = request.copyWith(resources: null);
      expect(cleared.resources, isNull);
    });

    test('emits explicit null when clearResources/clearSpec are set', () {
      const request = UpdateDeploymentRequest(
        clearResources: true,
        clearSpec: true,
      );
      expect(request.toJson(), {'resources': null, 'spec': null});
    });

    test('fromJson distinguishes absent key from explicit null', () {
      final cleared = UpdateDeploymentRequest.fromJson(const {
        'resources': null,
      });
      expect(cleared.resources, isNull);
      expect(cleared.clearResources, isTrue);

      final omitted = UpdateDeploymentRequest.fromJson(const {});
      expect(omitted.resources, isNull);
      expect(omitted.clearResources, isFalse);
    });

    test('asserts when a value and its clearX flag are both set', () {
      expect(
        () => UpdateDeploymentRequest(
          resources: const DeploymentResourceConfigUpdate(replicas: 1),
          clearResources: true,
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => UpdateDeploymentRequest(
          spec: const WorkflowsWorkerSpecUpdate(revision: 'v2'),
          clearSpec: true,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('copyWith clearX: true resets the value', () {
      const request = UpdateDeploymentRequest(
        resources: DeploymentResourceConfigUpdate(replicas: 5),
      );
      final cleared = request.copyWith(clearResources: true);
      expect(cleared.resources, isNull);
      expect(cleared.clearResources, isTrue);
    });
  });

  group('DeploymentBuildState / DeploymentObservedState', () {
    test('round-trip with nested build state', () {
      final json = {
        'available_replicas': 2,
        'ready_replicas': 1,
        'phase': 'running',
        'build_state': {'phase': 'succeeded', 'commit_sha': 'abc'},
      };
      final state = DeploymentObservedState.fromJson(json);
      expect(state.availableReplicas, 2);
      expect(state.readyReplicas, 1);
      expect(state.buildState!.phase, 'succeeded');
      expect(DeploymentObservedState.fromJson(state.toJson()), state);
    });

    test('defaults replicas to 0 when absent', () {
      final state = DeploymentObservedState.fromJson(const {});
      expect(state.availableReplicas, 0);
      expect(state.readyReplicas, 0);
      expect(state.buildState, isNull);
    });
  });

  group('ManagedDeploymentResponse', () {
    Map<String, dynamic> json() => {
      'service_id': 'svc-1',
      'name': 'my-deployment',
      'spec': {'github_url': 'https://github.com/org/repo'},
      'resources': {'replicas': 1},
      'status': {'available_replicas': 1, 'ready_replicas': 1},
      'created_at': '2030-01-01T00:00:00Z',
      'updated_at': '2030-01-02T00:00:00Z',
      'stopped': false,
    };

    test('round-trips through JSON', () {
      final response = ManagedDeploymentResponse.fromJson(json());
      expect(response.serviceId, 'svc-1');
      expect(response.spec.githubUrl, 'https://github.com/org/repo');
      expect(response.resources.replicas, 1);
      expect(response.status.availableReplicas, 1);
      expect(response.stopped, isFalse);
      expect(ManagedDeploymentResponse.fromJson(response.toJson()), response);
    });

    test('throws FormatException when required fields are missing', () {
      expect(
        () => ManagedDeploymentResponse.fromJson(const {}),
        throwsFormatException,
      );
    });

    test('throws FormatException when created_at/updated_at are missing', () {
      final withoutCreatedAt = json()..remove('created_at');
      expect(
        () => ManagedDeploymentResponse.fromJson(withoutCreatedAt),
        throwsFormatException,
      );

      final withoutUpdatedAt = json()..remove('updated_at');
      expect(
        () => ManagedDeploymentResponse.fromJson(withoutUpdatedAt),
        throwsFormatException,
      );
    });

    test('equality and copyWith clear optional fields', () {
      final response = ManagedDeploymentResponse.fromJson(json());
      final other = ManagedDeploymentResponse.fromJson(json());
      expect(response, other);
      expect(response.hashCode, other.hashCode);

      final cleared = response.copyWith(createdBy: null, rolloutStatus: null);
      expect(cleared.createdBy, isNull);
      expect(cleared.rolloutStatus, isNull);
    });
  });

  group('DeploymentLogRecord / DeploymentLogSearchResponse', () {
    test('round-trip through JSON', () {
      final record = DeploymentLogRecord.fromJson(const {
        'timestamp': '2030-01-01T00:00:00Z',
        'trace_id': 'trace-1',
        'span_id': 'span-1',
        'severity_text': 'INFO',
        'body': 'hello',
        'log_attributes': {'k': 'v'},
      });
      expect(record.body, 'hello');
      expect(record.logAttributes, {'k': 'v'});
      expect(DeploymentLogRecord.fromJson(record.toJson()), record);

      final response = DeploymentLogSearchResponse.fromJson({
        'results': [record.toJson()],
        'next_cursor': 'cursor-1',
      });
      expect(response.results, hasLength(1));
      expect(response.nextCursor, 'cursor-1');
      expect(DeploymentLogSearchResponse.fromJson(response.toJson()), response);
    });

    test('throws FormatException when a required field is missing', () {
      expect(
        () => DeploymentLogRecord.fromJson(const {
          'timestamp': '2030-01-01T00:00:00Z',
          'trace_id': 'trace-1',
          'span_id': 'span-1',
          'severity_text': 'INFO',
          // 'body' missing
          'log_attributes': <String, dynamic>{},
        }),
        throwsFormatException,
      );
      expect(
        () => DeploymentLogRecord.fromJson(const {
          'timestamp': '2030-01-01T00:00:00Z',
          'trace_id': 'trace-1',
          'span_id': 'span-1',
          'severity_text': 'INFO',
          'body': 'hello',
          // 'log_attributes' missing
        }),
        throwsFormatException,
      );
    });
  });

  group('ExecutionTraceInfoResponse', () {
    test('round-trips and defaults hasTraceData to false', () {
      final response = ExecutionTraceInfoResponse.fromJson(const {});
      expect(response.hasTraceData, isFalse);
      expect(response.otelTraceId, isNull);

      final withTrace = ExecutionTraceInfoResponse.fromJson(const {
        'has_trace_data': true,
        'otel_trace_id': 'otel-1',
      });
      expect(withTrace.hasTraceData, isTrue);
      expect(withTrace.otelTraceId, 'otel-1');
      expect(
        ExecutionTraceInfoResponse.fromJson(withTrace.toJson()),
        withTrace,
      );
    });
  });

  group('DeploymentResponse field additions', () {
    test('round-trips managed/locations/worker counts', () {
      final json = {
        'id': 'dep-1',
        'name': 'my-deployment',
        'is_active': true,
        'created_at': '2030-01-01T00:00:00Z',
        'updated_at': '2030-01-02T00:00:00Z',
        'active_worker_count': 2,
        'worker_count': 3,
        'locations': ['k8s', 'managed'],
        'managed': {
          'service_id': 'svc-1',
          'name': 'my-deployment',
          'spec': {'github_url': 'https://github.com/org/repo'},
          'resources': <String, dynamic>{},
          'status': <String, dynamic>{},
          'created_at': '2030-01-01T00:00:00Z',
          'updated_at': '2030-01-01T00:00:00Z',
        },
      };
      final response = DeploymentResponse.fromJson(json);
      expect(response.activeWorkerCount, 2);
      expect(response.workerCount, 3);
      expect(response.locations, [LocationType.k8s, LocationType.managed]);
      expect(response.managed!.serviceId, 'svc-1');

      final back = DeploymentResponse.fromJson(response.toJson());
      expect(back, response);
    });

    test('defaults new fields when absent', () {
      final response = DeploymentResponse.fromJson(const {
        'id': 'dep-1',
        'name': 'my-deployment',
        'is_active': true,
        'created_at': '2030-01-01T00:00:00Z',
        'updated_at': '2030-01-02T00:00:00Z',
      });
      expect(response.activeWorkerCount, 0);
      expect(response.workerCount, 0);
      expect(response.locations, isEmpty);
      expect(response.managed, isNull);
    });

    test('throws FormatException when a required field is missing', () {
      expect(
        () => DeploymentResponse.fromJson(const {}),
        throwsFormatException,
      );
    });
  });

  group('DeploymentDetailResponse field additions', () {
    test('round-trips managed/locations/worker counts', () {
      final json = {
        'id': 'dep-1',
        'name': 'my-deployment',
        'is_active': true,
        'created_at': '2030-01-01T00:00:00Z',
        'updated_at': '2030-01-02T00:00:00Z',
        'workers': <Map<String, dynamic>>[],
        'active_worker_count': 1,
        'worker_count': 1,
        'locations': ['local'],
      };
      final response = DeploymentDetailResponse.fromJson(json);
      expect(response.activeWorkerCount, 1);
      expect(response.workerCount, 1);
      expect(response.locations, [LocationType.local]);
      expect(DeploymentDetailResponse.fromJson(response.toJson()), response);
    });

    test('throws FormatException when a required field is missing', () {
      expect(
        () => DeploymentDetailResponse.fromJson(const {}),
        throwsFormatException,
      );
    });
  });

  group('DeploymentWorkerResponse location field', () {
    test('round-trips the optional location', () {
      final json = {
        'name': 'worker-1',
        'is_active': true,
        'created_at': '2030-01-01T00:00:00Z',
        'updated_at': '2030-01-02T00:00:00Z',
        'location': {'location_type': 'k8s', 'k8s_cluster': 'prod'},
      };
      final worker = DeploymentWorkerResponse.fromJson(json);
      expect(worker.location!.locationType, LocationType.k8s);
      expect(worker.location!.k8sCluster, 'prod');
      expect(DeploymentWorkerResponse.fromJson(worker.toJson()), worker);
    });

    test('location defaults to null when absent', () {
      final worker = DeploymentWorkerResponse.fromJson(const {
        'name': 'worker-1',
        'is_active': true,
        'created_at': '2030-01-01T00:00:00Z',
        'updated_at': '2030-01-02T00:00:00Z',
      });
      expect(worker.location, isNull);
    });

    test('throws FormatException when a required field is missing', () {
      expect(
        () => DeploymentWorkerResponse.fromJson(const {}),
        throwsFormatException,
      );
    });
  });
}
