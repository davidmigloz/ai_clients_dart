import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

/// A full Deployment JSON payload with all required keys present.
Map<String, dynamic> deploymentJson({
  String? description = 'A test deployment',
  Map<String, dynamic>? schedule = const {
    'type': 'cron',
    'expression': '0 9 * * 1-5',
    'timezone': 'UTC',
    'last_run_at': null,
    'upcoming_runs_at': ['2026-04-02T09:00:00.000Z'],
  },
  Map<String, dynamic>? pausedReason,
  String? archivedAt,
}) {
  return {
    'type': 'deployment',
    'id': 'dpl_test123',
    'name': 'Test Deployment',
    'description': description,
    'agent': {'type': 'agent', 'id': 'agent_test123', 'version': 2},
    'environment_id': 'env_test123',
    'vault_ids': ['vault_abc', 'vault_def'],
    'initial_events': [
      {
        'type': 'user.message',
        'content': [
          {'type': 'text', 'text': 'Hello'},
        ],
      },
    ],
    'resources': [
      {'type': 'file', 'file_id': 'file_abc', 'mount_path': '/mnt/file'},
    ],
    'metadata': {'team': 'eng'},
    'schedule': schedule,
    'status': 'active',
    'paused_reason': pausedReason,
    'created_at': '2026-04-01T00:00:00.000Z',
    'updated_at': '2026-04-01T00:00:00.000Z',
    'archived_at': archivedAt,
  };
}

Map<String, dynamic> deploymentRunJson({
  String? sessionId = 'session_test123',
  Map<String, dynamic>? error,
}) {
  return {
    'type': 'deployment_run',
    'id': 'drun_test123',
    'deployment_id': 'dpl_test123',
    'trigger_context': {
      'type': 'schedule',
      'scheduled_at': '2026-04-01T09:00:00.000Z',
    },
    'session_id': sessionId,
    'error': error,
    'agent': {'type': 'agent', 'id': 'agent_test123', 'version': 2},
    'created_at': '2026-04-01T00:00:00.000Z',
  };
}

void main() {
  group('Deployment', () {
    test('fromJson parses all fields', () {
      final deployment = Deployment.fromJson(deploymentJson());

      expect(deployment.type, 'deployment');
      expect(deployment.id, 'dpl_test123');
      expect(deployment.name, 'Test Deployment');
      expect(deployment.description, 'A test deployment');
      expect(deployment.agent.id, 'agent_test123');
      expect(deployment.agent.version, 2);
      expect(deployment.environmentId, 'env_test123');
      expect(deployment.vaultIds, ['vault_abc', 'vault_def']);
      expect(deployment.initialEvents, hasLength(1));
      expect(deployment.initialEvents.first, isA<DeploymentUserMessageEvent>());
      expect(deployment.resources, hasLength(1));
      expect(deployment.resources.first, isA<FileResourceConfig>());
      expect(deployment.metadata, {'team': 'eng'});
      expect(deployment.schedule, isA<CronSchedule>());
      expect(deployment.status, DeploymentStatus.active);
      expect(deployment.pausedReason, isNull);
      expect(deployment.archivedAt, isNull);
    });

    test('toJson round-trips', () {
      final json = deploymentJson();
      final deployment = Deployment.fromJson(json);
      final reparsed = Deployment.fromJson(deployment.toJson());

      expect(reparsed, deployment);
    });

    test('toJson always emits required-nullable keys when null', () {
      final deployment = Deployment.fromJson(
        deploymentJson(
          description: null,
          schedule: null,
          pausedReason: null,
          archivedAt: null,
        ),
      );

      final out = deployment.toJson();
      // Required + nullable: keys must always be present even when null.
      expect(out.containsKey('description'), isTrue);
      expect(out['description'], isNull);
      expect(out.containsKey('schedule'), isTrue);
      expect(out['schedule'], isNull);
      expect(out.containsKey('paused_reason'), isTrue);
      expect(out['paused_reason'], isNull);
      expect(out.containsKey('archived_at'), isTrue);
      expect(out['archived_at'], isNull);
    });

    test('parses an error paused_reason', () {
      final deployment = Deployment.fromJson(
        deploymentJson(
          pausedReason: {
            'type': 'error',
            'error': {
              'type': 'agent_archived_error',
              'message': 'The agent was archived',
            },
          },
        ),
      );

      expect(deployment.pausedReason, isA<ErrorDeploymentPausedReason>());
      final reason = deployment.pausedReason! as ErrorDeploymentPausedReason;
      expect(reason.error, isA<AgentArchivedDeploymentPausedReasonError>());
    });

    test('copyWith can clear nullable schedule', () {
      final deployment = Deployment.fromJson(deploymentJson());
      expect(deployment.schedule, isNotNull);

      final cleared = deployment.copyWith(schedule: null);
      expect(cleared.schedule, isNull);

      final unchanged = deployment.copyWith(name: 'Renamed');
      expect(unchanged.schedule, isNotNull);
      expect(unchanged.name, 'Renamed');
    });
  });

  group('DeploymentRun', () {
    test('fromJson parses a successful run', () {
      final run = DeploymentRun.fromJson(deploymentRunJson());

      expect(run.type, 'deployment_run');
      expect(run.id, 'drun_test123');
      expect(run.deploymentId, 'dpl_test123');
      expect(run.triggerContext, isA<ScheduleTriggerContext>());
      expect(run.sessionId, 'session_test123');
      expect(run.error, isNull);
      expect(run.agent.id, 'agent_test123');
    });

    test('fromJson parses a failed run', () {
      final run = DeploymentRun.fromJson(
        deploymentRunJson(
          sessionId: null,
          error: {
            'type': 'vault_not_found_error',
            'message': 'Vault not found',
          },
        ),
      );

      expect(run.sessionId, isNull);
      expect(run.error, isA<VaultNotFoundRunError>());
    });

    test('toJson round-trips and always emits required-nullable keys', () {
      final run = DeploymentRun.fromJson(deploymentRunJson(sessionId: null));
      final out = run.toJson();

      // Required + nullable: both keys always present.
      expect(out.containsKey('session_id'), isTrue);
      expect(out['session_id'], isNull);
      expect(out.containsKey('error'), isTrue);
      expect(out['error'], isNull);

      final reparsed = DeploymentRun.fromJson(out);
      expect(reparsed, run);
    });
  });

  group('CreateDeploymentParams', () {
    test('toJson emits required fields and omits absent optionals', () {
      const params = CreateDeploymentParams(
        agent: AgentParamsId(id: 'agent_test123'),
        environmentId: 'env_test123',
        name: 'My Deployment',
        initialEvents: [
          DeploymentUserMessageEventParams(
            UserMessageEventParams(
              content: [
                {'type': 'text', 'text': 'Hello'},
              ],
            ),
          ),
        ],
      );

      final json = params.toJson();
      expect(json['agent'], 'agent_test123');
      expect(json['environment_id'], 'env_test123');
      expect(json['name'], 'My Deployment');
      expect(json['initial_events'], hasLength(1));
      // Absent optionals are omitted entirely.
      expect(json.containsKey('description'), isFalse);
      expect(json.containsKey('metadata'), isFalse);
      expect(json.containsKey('resources'), isFalse);
      expect(json.containsKey('schedule'), isFalse);
      expect(json.containsKey('vault_ids'), isFalse);
    });

    test('toJson includes provided optionals', () {
      const params = CreateDeploymentParams(
        agent: AgentParamsObject(id: 'agent_test123', version: 3),
        environmentId: 'env_test123',
        name: 'My Deployment',
        initialEvents: [
          DeploymentUserMessageEventParams(
            UserMessageEventParams(
              content: [
                {'type': 'text', 'text': 'Hello'},
              ],
            ),
          ),
        ],
        description: 'desc',
        metadata: {'k': 'v'},
        schedule: ScheduleParams.cron(expression: '* * * * *', timezone: 'UTC'),
        vaultIds: ['vault_abc'],
      );

      final json = params.toJson();
      expect(json['agent'], {
        'id': 'agent_test123',
        'type': 'agent',
        'version': 3,
      });
      expect(json['description'], 'desc');
      expect(json['metadata'], {'k': 'v'});
      expect(json['schedule'], {
        'type': 'cron',
        'expression': '* * * * *',
        'timezone': 'UTC',
      });
      expect(json['vault_ids'], ['vault_abc']);
    });

    test('fromJson round-trips', () {
      const params = CreateDeploymentParams(
        agent: AgentParamsId(id: 'agent_test123'),
        environmentId: 'env_test123',
        name: 'My Deployment',
        initialEvents: [
          DeploymentUserMessageEventParams(
            UserMessageEventParams(
              content: [
                {'type': 'text', 'text': 'Hello'},
              ],
            ),
          ),
        ],
        description: 'desc',
      );

      final reparsed = CreateDeploymentParams.fromJson(params.toJson());
      expect(reparsed, params);
    });

    test('toString summarizes resources and never leaks a GitHub token', () {
      const token = 'ghp_SUPER_SECRET_TOKEN';
      const params = CreateDeploymentParams(
        agent: AgentParamsId(id: 'agent_test123'),
        environmentId: 'env_test123',
        name: 'My Deployment',
        initialEvents: [
          DeploymentUserMessageEventParams(
            UserMessageEventParams(
              content: [
                {'type': 'text', 'text': 'Hello'},
              ],
            ),
          ),
        ],
        resources: [
          GitHubRepositoryResourceParams(
            url: 'https://github.com/o/r',
            authorizationToken: token,
          ),
        ],
      );

      final str = params.toString();
      expect(str, contains('resources: 1 items'));
      expect(str, isNot(contains(token)));
    });
  });

  group('Deployment.budget', () {
    test('round-trips when present', () {
      final json = deploymentJson();
      json['budget'] = {
        'type': 'limit',
        'max_list_cost': {'amount': '2500', 'currency': 'USD'},
      };
      final deployment = Deployment.fromJson(json);
      expect(deployment.budget, isA<BudgetLimit>());
      expect(deployment.toJson()['budget'], json['budget']);
    });

    test('is null and omitted from toJson when absent', () {
      final deployment = Deployment.fromJson(deploymentJson());
      expect(deployment.budget, isNull);
      expect(deployment.toJson().containsKey('budget'), isFalse);
    });

    test('copyWith replaces and clears budget', () {
      final json = deploymentJson();
      json['budget'] = {
        'type': 'limit',
        'max_list_cost': {'amount': '2500', 'currency': 'USD'},
      };
      final deployment = Deployment.fromJson(json);
      expect(deployment.copyWith(budget: null).budget, isNull);
      expect(deployment.copyWith().budget, isA<BudgetLimit>());
    });
  });

  group('CreateDeploymentParams.budget', () {
    test('round-trips when present', () {
      final params = CreateDeploymentParams(
        agent: const AgentParamsId(id: 'agent_test123'),
        environmentId: 'env_test123',
        name: 'My Deployment',
        initialEvents: const [
          DeploymentUserMessageEventParams(
            UserMessageEventParams(
              content: [
                {'type': 'text', 'text': 'Hello'},
              ],
            ),
          ),
        ],
        budget: Budget.limit(
          maxListCost: const MonetaryAmount(amount: '2500', currency: 'USD'),
        ),
      );
      expect(params.toJson()['budget'], {
        'type': 'limit',
        'max_list_cost': {'amount': '2500', 'currency': 'USD'},
      });
      final reparsed = CreateDeploymentParams.fromJson(params.toJson());
      expect(reparsed, params);
    });

    test('is omitted from toJson when absent', () {
      const params = CreateDeploymentParams(
        agent: AgentParamsId(id: 'agent_test123'),
        environmentId: 'env_test123',
        name: 'My Deployment',
        initialEvents: [
          DeploymentUserMessageEventParams(
            UserMessageEventParams(
              content: [
                {'type': 'text', 'text': 'Hello'},
              ],
            ),
          ),
        ],
      );
      expect(params.toJson().containsKey('budget'), isFalse);
    });
  });

  group('UpdateDeploymentParams.budget', () {
    test('omitted: no budget key in toJson', () {
      const params = UpdateDeploymentParams();
      expect(params.budget, isNull);
      expect(params.toJson().containsKey('budget'), isFalse);
    });

    test('explicit null: emits budget: null to clear it', () {
      const params = UpdateDeploymentParams(budget: null);
      expect(params.toJson().containsKey('budget'), isTrue);
      expect(params.toJson()['budget'], isNull);
    });

    test('value: emits the serialized budget', () {
      final params = UpdateDeploymentParams(
        budget: Budget.limit(
          maxListCost: const MonetaryAmount(amount: '2500', currency: 'USD'),
        ),
      );
      expect(params.toJson()['budget'], {
        'type': 'limit',
        'max_list_cost': {'amount': '2500', 'currency': 'USD'},
      });
    });

    test('copyWith replaces and clears budget', () {
      final params = UpdateDeploymentParams(
        budget: Budget.limit(
          maxListCost: const MonetaryAmount(amount: '2500', currency: 'USD'),
        ),
      );
      expect(params.copyWith(budget: null).budget, isNull);
      expect(params.copyWith().budget, isA<BudgetLimit>());
    });
  });

  group('GitHubRepositoryResourceParams', () {
    test('toString redacts the authorization token', () {
      const token = 'ghp_SUPER_SECRET_TOKEN';
      const params = GitHubRepositoryResourceParams(
        url: 'https://github.com/o/r',
        authorizationToken: token,
      );
      final str = params.toString();
      expect(str, isNot(contains(token)));
      expect(str, contains('[redacted]'));
    });
  });

  group('UpdateDeploymentParams', () {
    test('empty params emit an empty body', () {
      const params = UpdateDeploymentParams();
      expect(params.toJson(), isEmpty);
    });

    test('non-clearable fields are emitted only when provided', () {
      const params = UpdateDeploymentParams(
        name: 'Renamed',
        environmentId: 'env_new',
      );

      final json = params.toJson();
      expect(json['name'], 'Renamed');
      expect(json['environment_id'], 'env_new');
      // Other fields not provided → omitted.
      expect(json.containsKey('agent'), isFalse);
      expect(json.containsKey('description'), isFalse);
      expect(json.containsKey('schedule'), isFalse);
    });

    test('clearing a field emits explicit null', () {
      const params = UpdateDeploymentParams(
        description: null,
        schedule: null,
        vaultIds: null,
      );

      final json = params.toJson();
      // Clearable fields explicitly set to null → key present with null.
      expect(json.containsKey('description'), isTrue);
      expect(json['description'], isNull);
      expect(json.containsKey('schedule'), isTrue);
      expect(json['schedule'], isNull);
      expect(json.containsKey('vault_ids'), isTrue);
      expect(json['vault_ids'], isNull);
    });

    test('untyped empty literals for clearable collections do not throw', () {
      // `resources: []` / `vaultIds: []` / `metadata: {}` are inferred as
      // dynamic-typed collections via the `Object?` sentinel params; the
      // getters and toJson must not throw on them (the clear-to-empty /
      // full-replacement case).
      const params = UpdateDeploymentParams(
        resources: [],
        vaultIds: [],
        metadata: {},
      );

      expect(params.resources, isEmpty);
      expect(params.vaultIds, isEmpty);
      expect(params.metadata, isEmpty);

      final json = params.toJson();
      expect(json['resources'], isEmpty);
      expect(json['vault_ids'], isEmpty);
      expect(json['metadata'], isEmpty);
    });

    test('omitting a clearable field leaves the key out', () {
      const params = UpdateDeploymentParams(name: 'Renamed');

      final json = params.toJson();
      // Not provided (default _notSet) → omitted.
      expect(json.containsKey('description'), isFalse);
      expect(json.containsKey('schedule'), isFalse);
      expect(json.containsKey('metadata'), isFalse);
      expect(json.containsKey('resources'), isFalse);
      expect(json.containsKey('vault_ids'), isFalse);
    });

    test('clearable field set to a value is emitted', () {
      const params = UpdateDeploymentParams(
        description: 'new desc',
        schedule: ScheduleParams.cron(expression: '0 0 * * *', timezone: 'UTC'),
        vaultIds: ['vault_a'],
        metadata: {'k': 'v', 'remove_me': null},
      );

      final json = params.toJson();
      expect(json['description'], 'new desc');
      expect(json['schedule'], {
        'type': 'cron',
        'expression': '0 0 * * *',
        'timezone': 'UTC',
      });
      expect(json['vault_ids'], ['vault_a']);
      expect(json['metadata'], {'k': 'v', 'remove_me': null});
    });

    test('fromJson distinguishes absent from explicit null', () {
      // description present-with-null → clear; schedule key absent → preserve.
      final cleared = UpdateDeploymentParams.fromJson(const {
        'description': null,
      });
      expect(cleared.toJson().containsKey('description'), isTrue);
      expect(cleared.toJson()['description'], isNull);

      final preserved = UpdateDeploymentParams.fromJson(const {'name': 'X'});
      expect(preserved.toJson().containsKey('description'), isFalse);
      expect(preserved.toJson()['name'], 'X');
    });
  });

  group('DeploymentListResponse', () {
    test('fromJson/toJson round-trips', () {
      final json = {
        'data': [deploymentJson()],
        'next_page': 'page_next',
      };

      final response = DeploymentListResponse.fromJson(json);
      expect(response.data, hasLength(1));
      expect(response.data.first.id, 'dpl_test123');
      expect(response.nextPage, 'page_next');

      final reparsed = DeploymentListResponse.fromJson(response.toJson());
      expect(reparsed, response);
    });

    test('handles missing data and null next_page', () {
      final response = DeploymentListResponse.fromJson(const {'data': null});
      expect(response.data, isEmpty);
      expect(response.nextPage, isNull);
      expect(response.toJson().containsKey('next_page'), isFalse);
    });
  });

  group('DeploymentRunListResponse', () {
    test('fromJson/toJson round-trips', () {
      final json = {
        'data': [deploymentRunJson()],
        'next_page': null,
      };

      final response = DeploymentRunListResponse.fromJson(json);
      expect(response.data, hasLength(1));
      expect(response.data.first.id, 'drun_test123');
      expect(response.nextPage, isNull);

      final reparsed = DeploymentRunListResponse.fromJson(response.toJson());
      expect(reparsed, response);
    });
  });
}
