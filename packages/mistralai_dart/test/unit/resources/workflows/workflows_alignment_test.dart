import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const _timestamp = '2026-11-27T17:00:00Z';
const Map<String, Object?> _executionWire = {
  'workflow_name': 'my-workflow',
  'execution_id': 'exec-1',
  'root_execution_id': 'exec-1',
  'status': 'RUNNING',
  'start_time': _timestamp,
  'end_time': null,
  'result': null,
  'search_keys': {'case_id': 'case-1', 'optional': null},
};

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  test(
    'creates and retrieves signed archive metadata on the Mistral API',
    () async {
      var requests = 0;
      final client = MistralClient.withApiKey(
        'mistral-test-key',
        httpClient: MockClient((request) async {
          requests++;
          expect(request.url.host, 'api.mistral.ai');
          expect(request.headers['authorization'], 'Bearer mistral-test-key');
          if (request.method == 'POST') {
            expect(request.url.path, '/v1/workflows/deployments/archives');
            expect(jsonDecode(request.body), {'size': 128});
            return _json({
              'archive_id': 'archive-1',
              'upload_url': 'https://storage.example/signed?signature=private',
              'upload_headers': {
                'Content-Type': 'application/gzip',
                'x-test': 'private',
              },
            }, 201);
          }
          expect(request.method, 'GET');
          expect(request.url.pathSegments, [
            'v1',
            'workflows',
            'deployments',
            'workspace/deployment',
            'archive',
          ]);
          return _json({'archive_id': 'archive-1', 'download_url': null});
        }),
      );
      addTearDown(client.close);

      final slot = await client.workflows.deployments.createArchive(
        request: const CreateDeploymentArchiveRequest(size: 128),
      );
      expect(slot.uploadHeaders['Content-Type'], 'application/gzip');
      expect(Uri.parse(slot.uploadUrl).host, 'storage.example');
      expect(slot.toString(), isNot(contains('private')));

      final archive = await client.workflows.deployments.getArchive(
        name: 'workspace/deployment',
      );
      expect(archive.archiveId, slot.archiveId);
      expect(archive.downloadUrl, isNull);
      expect(requests, 2);

      await expectLater(
        client.workflows.deployments.createArchive(
          request: const CreateDeploymentArchiveRequest(size: 0),
        ),
        throwsArgumentError,
      );
      expect(requests, 2);
    },
  );

  test(
    'decodes archive-backed deployment and only sends supported settings',
    () async {
      final client = MistralClient.withApiKey(
        'test-key',
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/v1/workflows/deployments');
          expect(jsonDecode(request.body), {
            'hardened': true,
            'name': 'managed',
            'spec': {
              'archive_id': 'archive-1',
              'backend_spec': {
                'type': 'mistral_cloud',
                'dockerfile_path': 'Dockerfile',
                'secrets': [
                  {
                    'env_var_name': 'TOKEN',
                    'reference': 'secret:workspace:MY_SECRET',
                  },
                ],
              },
              'requested_roles': ['workflow_reader'],
            },
            'resources': {'replicas': 2},
          });
          return _json({
            'service_id': 'svc-1',
            'name': 'managed',
            'created_at': _timestamp,
            'updated_at': _timestamp,
            'is_hardened': true,
            'runtime_credential_id': 'credential-1',
            'runtime_principal_type': 'service_account',
            'status': {'last_phase_changed_at': _timestamp},
            'resources': {'replicas': 2},
            'spec': {
              'github_url': '',
              'archive_id': 'archive-1',
              'backend_spec': {
                'type': 'mistral_cloud',
                'dockerfile_path': 'Dockerfile',
              },
              'requested_roles': ['workflow_reader'],
            },
          }, 202);
        }),
      );
      addTearDown(client.close);
      final deployment = await client.workflows.deployments.create(
        request: const CreateDeploymentRequest(
          name: 'managed',
          hardened: true,
          spec: DeploymentWorkerSpecInput(
            archiveId: 'archive-1',
            backendSpec: DeploymentMistralCloudBackendSpec(
              dockerfilePath: 'Dockerfile',
              secrets: [
                DeploymentSecretBinding(
                  envVarName: 'TOKEN',
                  reference: 'secret:workspace:MY_SECRET',
                ),
              ],
            ),
            requestedRoles: ['workflow_reader'],
          ),
          resources: DeploymentResourceConfig(cpuLimit: '500m', replicas: 2),
        ),
      );
      expect(deployment.isHardened, isTrue);
      expect(deployment.runtimeCredentialId, 'credential-1');
      expect(deployment.runtimePrincipalType, PrincipalType.serviceAccount);
      expect(deployment.status.lastPhaseChangedAt, _timestamp);
      expect(deployment.spec.archiveId, 'archive-1');
      expect(
        deployment.spec.backendSpec,
        isA<DeploymentMistralCloudBackendSpec>(),
      );
      final rebuilt = ManagedDeploymentResponse.fromJson(deployment.toJson());
      expect(rebuilt, deployment);
      expect(rebuilt.hashCode, deployment.hashCode);
    },
  );

  test(
    'paginates workers and sends empty-response control operations',
    () async {
      final client = MistralClient.withApiKey(
        'test-key',
        httpClient: MockClient((request) async {
          switch (request.url.pathSegments.last) {
            case 'workers':
              expect(request.method, 'GET');
              expect(request.url.queryParameters['worker_status'], 'active');
              expect(request.url.queryParameters['limit'], '1');
              final cursor = request.url.queryParameters['cursor'];
              expect(cursor, anyOf(isNull, 'next'));
              return _json({
                'workers': [
                  {
                    'name': cursor == null ? 'first' : 'second',
                    'created_at': _timestamp,
                    'updated_at': _timestamp,
                    'last_heartbeat': '2026-11-27T18:00:00Z',
                    'is_active': true,
                  },
                ],
                'next_cursor': cursor == null ? 'next' : null,
              });
            case 'unharden':
              expect(request.method, 'POST');
              expect(request.url.pathSegments, [
                'v1',
                'workflows',
                'deployments',
                'deployment-id',
                'unharden',
              ]);
              expect(
                request.url.queryParameters['workspace_id'],
                'workspace-id',
              );
              expect(request.body, isEmpty);
              return http.Response('', 204);
            case 'tags':
              expect(request.method, 'POST');
              expect(request.url.pathSegments, [
                'v1',
                'workflows',
                'workflow-id',
                'tags',
              ]);
              expect(jsonDecode(request.body), {
                'tags': ['first'],
              });
              return http.Response('', 204);
            default:
              fail('Unexpected Workflows request');
          }
        }),
      );
      addTearDown(client.close);

      final deployments = client.workflows.deployments;
      final first = await deployments.listWorkers(
        name: 'managed',
        workerStatus: 'active',
        limit: 1,
      );
      expect(first.workers.single.name, 'first');
      expect(first.workers.single.lastHeartbeat, '2026-11-27T18:00:00Z');
      final second = await deployments.listWorkers(
        name: 'managed',
        workerStatus: 'active',
        limit: 1,
        cursor: first.nextCursor,
      );
      expect(second.workers.single.name, 'second');
      expect(second.nextCursor, isNull);
      expect(second.toJson()['next_cursor'], isNull);

      await deployments.unharden(
        deploymentId: 'deployment-id',
        workspaceId: 'workspace-id',
      );
      await client.workflows.core.addTags(
        workflowIdentifier: 'workflow-id',
        request: const WorkflowTagsAddRequest(tags: ['first']),
      );
    },
  );

  test('preserves repeated filters and execution tracing fields', () async {
    final client = MistralClient.withApiKey(
      'test-key',
      httpClient: MockClient((request) async {
        final query = request.url.queryParametersAll;
        switch (request.url.path) {
          case '/v1/workflows/deployments':
            expect(query, {
              'location_types': ['managed', 'k8s'],
              'created_by': ['creator'],
              'owner': ['owner'],
              'order_by': ['created_at'],
              'order': ['desc'],
              'repository_url': ['https://git.example/repo'],
              'dockerfile_path': ['Dockerfile'],
            });
            return _json({
              'deployments': [
                {
                  'id': 'deployment-1',
                  'name': 'managed',
                  'is_active': true,
                  'created_at': _timestamp,
                  'last_heartbeat': _timestamp,
                  'updated_at': _timestamp,
                  'owner': 'owner',
                },
              ],
              'next_cursor': null,
              'workspace_id': 'workspace',
            });
          case '/v1/workflows/runs':
            expect(query, {
              'exclude_workflow_tags': ['blocked', 'paused'],
              'status': ['RUNNING', 'FAILED'],
              'search_key': ['case_id', 'optional==', 'name==:test'],
            });
            return _json({
              'executions': [_executionWire],
              'next_page_token': null,
            });
          case '/v1/workflows/my-workflow/execute':
            expect(request.method, 'POST');
            expect(jsonDecode(request.body), {
              'call_context': {'case_id': 'case-1', 'attempt': 2, 'test': true},
              'traceparent': '00-abc-def-01',
              'force_new_trace': false,
              'wait_for_result': false,
            });
            return _json(_executionWire);
          case '/v1/workflows/executions/exec-1':
            expect(query, {
              'include_search_keys': ['true'],
            });
            return _json(_executionWire);
          default:
            fail('Unexpected Workflows request');
        }
      }),
    );
    addTearDown(client.close);
    final deployments = await client.workflows.deployments.list(
      locationTypes: const [LocationType.managed, LocationType.k8s],
      createdBy: 'creator',
      owner: 'owner',
      orderBy: 'created_at',
      order: 'desc',
      repositoryUrl: 'https://git.example/repo',
      dockerfilePath: 'Dockerfile',
    );
    expect(deployments.deployments.single.owner, 'owner');
    final runs = await client.workflows.runs.list(
      excludeWorkflowTags: ['blocked', 'paused'],
      statuses: ['RUNNING', 'FAILED'],
      searchKey: ['case_id', 'optional==', 'name==:test'],
    );
    expect(runs.executions.single.executionId, 'exec-1');
    await client.workflows.core.executeAsync(
      workflowIdentifier: 'my-workflow',
      request: const WorkflowExecutionRequest(
        callContext: {'case_id': 'case-1', 'attempt': 2, 'test': true},
        traceparent: '00-abc-def-01',
        forceNewTrace: false,
      ),
    );
    final execution = await client.workflows.executions.get(
      executionId: 'exec-1',
      includeSearchKeys: true,
    );
    expect(execution.searchKeys, {'case_id': 'case-1', 'optional': null});
    expect(execution.toJson()['search_keys'], _executionWire['search_keys']);
  });

  test('resumes deployment logs from the SSE cursor', () async {
    const Map<String, Object?> log = {
      'timestamp': _timestamp,
      'trace_id': 'trace-1',
      'span_id': 'span-1',
      'severity_text': 'INFO',
      'body': 'build output',
      'log_attributes': <String, String>{},
    };
    final client = MistralClient.withApiKey(
      'test-key',
      httpClient: MockClient.streaming((request, _) async {
        if (request.url.path.endsWith('/logs')) {
          expect(request.url.queryParameters['log_type'], 'build');
          return http.StreamedResponse(
            Stream.value(
              utf8.encode(
                jsonEncode({
                  'results': [log],
                  'next_cursor': null,
                }),
              ),
            ),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        expect(request.url.queryParameters['last_event_id'], 'previous');
        expect(request.headers['last-event-id'], 'previous');
        expect(request.headers['accept'], 'text/event-stream');
        final data = jsonEncode(log);
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode('id: next\nevent: log\ndata: $data\n\n'),
            utf8.encode('event: log\ndata: $data\n\n'),
            utf8.encode('id:\nevent: log\ndata: $data\n\n'),
          ]),
          200,
        );
      }),
    );
    addTearDown(client.close);
    final deployments = client.workflows.deployments;
    final result = await deployments.getLogs(
      name: 'managed',
      logType: DeploymentLogType.build,
    );
    expect(result.results.single.eventId, isNull);
    final events = await deployments
        .streamLogs(name: 'managed', lastEventId: 'previous')
        .toList();
    expect(events.map((event) => event.eventId), ['next', 'next', null]);
    expect(events.first.toJson(), log);
  });

  test('decodes run context on workflow events and Tempo double values', () {
    final event = WorkflowExecutionCompletedResponse.fromJson(const {
      'event_id': 'event-1',
      'event_timestamp': 123,
      'event_type': 'WORKFLOW_EXECUTION_COMPLETED',
      'root_workflow_exec_id': 'exec-1',
      'parent_workflow_exec_id': null,
      'workflow_exec_id': 'exec-1',
      'workflow_run_id': 'run-1',
      'workflow_name': 'my-workflow',
      'chain_run_id': 'chain-1',
      'continued_run_id': 'previous-1',
      'first_execution_run_id': 'first-1',
      'schedule_id': 'schedule-1',
      'attributes': {
        'attempt': 3,
        'task_id': 'task-1',
        'result': {
          'type': 'json',
          'value': {'ok': true},
        },
      },
    });
    expect(event.chainRunId, 'chain-1');
    expect(event.continuedRunId, 'previous-1');
    expect(event.firstExecutionRunId, 'first-1');
    expect(event.scheduleId, 'schedule-1');
    expect(event.attributes.attempt, 3);
    final rebuilt = WorkflowExecutionCompletedResponse.fromJson(event.toJson());
    expect(rebuilt, event);
    expect(rebuilt.hashCode, event.hashCode);

    final attribute = TempoTraceAttribute.fromJson(const {
      'key': 'duration',
      'value': {
        'arrayValue': {
          'values': [
            {'doubleValue': 1.25},
            {'intValue': '2'},
          ],
        },
      },
    });
    expect(attribute.arrayElements?.first.doubleValue, 1.25);
    expect(attribute.arrayElements?.last.intValue, '2');
  });

  test('validates workflow call context in all request models', () {
    const context = {'flag': true, 'attempt': 7, 'job': 'test/job'};
    final signal = SignalInvocationBody.fromJson(const {
      'name': 'signal',
      'call_context': context,
    });
    final update = UpdateInvocationBody.fromJson(const {
      'name': 'update',
      'call_context': context,
    });
    expect(signal.toJson()['call_context'], context);
    expect(update.toJson()['call_context'], context);
    expect(
      signal.copyWith(callContext: null).toJson(),
      isNot(contains('call_context')),
    );
    expect(
      () => WorkflowExecutionRequest.fromJson(const {
        'call_context': {
          'invalid': ['not', 'scalar'],
        },
      }),
      throwsFormatException,
    );
    expect(
      () => const WorkflowExecutionRequest(
        callContext: {'invalid_key': 9007199254740992},
      ).toJson(),
      throwsArgumentError,
    );
  });
}
