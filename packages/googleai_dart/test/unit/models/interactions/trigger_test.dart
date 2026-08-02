import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  // A trigger's `interaction` is a request template (model/agent + input),
  // not a completed Interaction — it carries no `id`/`status`.
  const modelInteraction = CreateModelInteractionParams(
    model: 'gemini-3.5-flash',
    input: InteractionInput.text('hi'),
  );

  group('Trigger', () {
    test('creates with only required fields', () {
      const trigger = Trigger(
        id: 'trg_1',
        interaction: modelInteraction,
        schedule: '0 * * * *',
        timeZone: 'UTC',
      );
      expect(trigger.id, 'trg_1');
      expect(trigger.schedule, '0 * * * *');
      expect(trigger.timeZone, 'UTC');
      expect(trigger.status, isNull);
    });

    test('round-trips all fields', () {
      final trigger = Trigger(
        id: 'trg_1',
        interaction: modelInteraction,
        schedule: '0 * * * *',
        timeZone: 'UTC',
        displayName: 'Hourly digest',
        environmentId: 'env_1',
        executionTimeoutSeconds: 60,
        maxConsecutiveFailures: 3,
        consecutiveFailureCount: 1,
        previousInteractionId: 'i_9',
        status: TriggerStatus.active,
        createTime: DateTime.utc(2026, 1, 1),
        updateTime: DateTime.utc(2026, 1, 2),
        lastRunTime: DateTime.utc(2026, 1, 3),
        nextRunTime: DateTime.utc(2026, 1, 4),
        lastPauseTime: DateTime.utc(2026, 1, 5),
        lastResumeTime: DateTime.utc(2026, 1, 6),
      );

      final json = trigger.toJson();
      expect(json['id'], 'trg_1');
      expect(json['interaction'], isA<Map<String, dynamic>>());
      expect(json['schedule'], '0 * * * *');
      expect(json['time_zone'], 'UTC');
      expect(json['display_name'], 'Hourly digest');
      expect(json['environment_id'], 'env_1');
      expect(json['execution_timeout_seconds'], 60);
      expect(json['max_consecutive_failures'], 3);
      expect(json['consecutive_failure_count'], 1);
      expect(json['previous_interaction_id'], 'i_9');
      expect(json['status'], 'active');
      expect(json['create_time'], '2026-01-01T00:00:00.000Z');
      expect(json['update_time'], '2026-01-02T00:00:00.000Z');
      expect(json['last_run_time'], '2026-01-03T00:00:00.000Z');
      expect(json['next_run_time'], '2026-01-04T00:00:00.000Z');
      expect(json['last_pause_time'], '2026-01-05T00:00:00.000Z');
      expect(json['last_resume_time'], '2026-01-06T00:00:00.000Z');

      final restored = Trigger.fromJson(json);
      expect(restored.id, trigger.id);
      expect(restored.interaction, isA<CreateModelInteractionParams>());
      expect(
        (restored.interaction as CreateModelInteractionParams).model,
        (trigger.interaction as CreateModelInteractionParams).model,
      );
      expect(restored.schedule, trigger.schedule);
      expect(restored.timeZone, trigger.timeZone);
      expect(restored.displayName, trigger.displayName);
      expect(restored.environmentId, trigger.environmentId);
      expect(restored.executionTimeoutSeconds, trigger.executionTimeoutSeconds);
      expect(restored.maxConsecutiveFailures, trigger.maxConsecutiveFailures);
      expect(restored.consecutiveFailureCount, trigger.consecutiveFailureCount);
      expect(restored.previousInteractionId, trigger.previousInteractionId);
      expect(restored.status, trigger.status);
      expect(restored.createTime, trigger.createTime);
      expect(restored.updateTime, trigger.updateTime);
      expect(restored.lastRunTime, trigger.lastRunTime);
      expect(restored.nextRunTime, trigger.nextRunTime);
      expect(restored.lastPauseTime, trigger.lastPauseTime);
      expect(restored.lastResumeTime, trigger.lastResumeTime);
    });

    test('omits null optional fields from JSON', () {
      const trigger = Trigger(
        id: 'trg_1',
        interaction: modelInteraction,
        schedule: '0 * * * *',
        timeZone: 'UTC',
      );
      final json = trigger.toJson();
      expect(json.containsKey('display_name'), isFalse);
      expect(json.containsKey('environment_id'), isFalse);
      expect(json.containsKey('execution_timeout_seconds'), isFalse);
      expect(json.containsKey('max_consecutive_failures'), isFalse);
      expect(json.containsKey('consecutive_failure_count'), isFalse);
      expect(json.containsKey('previous_interaction_id'), isFalse);
      expect(json.containsKey('status'), isFalse);
      expect(json.containsKey('create_time'), isFalse);
    });

    test('unknown status parses to null', () {
      final trigger = Trigger.fromJson({
        'id': 'trg_1',
        'interaction': modelInteraction.toJson(),
        'schedule': '0 * * * *',
        'time_zone': 'UTC',
        'status': 'something_new',
      });
      expect(trigger.status, isNull);
    });

    test('copyWith replaces and preserves values', () {
      const trigger = Trigger(
        id: 'trg_1',
        interaction: modelInteraction,
        schedule: '0 * * * *',
        timeZone: 'UTC',
      );
      final replaced = trigger.copyWith(
        id: 'trg_2',
        status: TriggerStatus.paused,
      );
      expect(replaced.id, 'trg_2');
      expect(replaced.status, TriggerStatus.paused);
      expect(replaced.schedule, trigger.schedule);

      final unchanged = trigger.copyWith();
      expect(unchanged.id, trigger.id);
      expect(unchanged.schedule, trigger.schedule);
    });

    test('parses a real API payload whose interaction is a bare request '
        'template (no id/status) without throwing', () {
      // Regression test: `interaction` used to be typed as `Interaction`,
      // whose fromJson hard-casts `json['id'] as String` and throws on a
      // request-shaped payload like this one (matching real trigger
      // lifecycle payloads, which never carry a completed Interaction).
      final trigger = Trigger.fromJson({
        'id': 'trg_1',
        'interaction': {'model': 'gemini-3.5-flash', 'input': 'hi'},
        'schedule': '0 * * * *',
        'time_zone': 'UTC',
      });
      expect(trigger.interaction, isA<CreateModelInteractionParams>());
      expect(
        (trigger.interaction as CreateModelInteractionParams).model,
        'gemini-3.5-flash',
      );
    });

    test('parses an agent-based request template interaction (dispatch on '
        '"agent" key)', () {
      final trigger = Trigger.fromJson({
        'id': 'trg_1',
        'interaction': {'agent': 'agents/research'},
        'schedule': '0 0 * * *',
        'time_zone': 'America/New_York',
      });
      expect(trigger.interaction, isA<CreateAgentInteractionParams>());
      expect(
        (trigger.interaction as CreateAgentInteractionParams).agent,
        'agents/research',
      );
    });
  });

  group('TriggerCreateParams', () {
    test('creates with only required fields', () {
      const params = TriggerCreateParams(
        interaction: CreateModelInteractionParams(model: 'gemini-3.5-flash'),
        schedule: '0 * * * *',
        timeZone: 'UTC',
      );
      expect(params.schedule, '0 * * * *');
      expect(params.displayName, isNull);
    });

    test('round-trips with a CreateModelInteractionParams interaction', () {
      const params = TriggerCreateParams(
        interaction: CreateModelInteractionParams(model: 'gemini-3.5-flash'),
        schedule: '0 * * * *',
        timeZone: 'UTC',
        displayName: 'Hourly digest',
        environmentId: 'env_1',
        executionTimeoutSeconds: 60,
        maxConsecutiveFailures: 3,
      );
      final json = params.toJson();
      expect((json['interaction'] as Map)['model'], 'gemini-3.5-flash');
      expect(json['schedule'], '0 * * * *');
      expect(json['time_zone'], 'UTC');
      expect(json['display_name'], 'Hourly digest');
      expect(json['environment_id'], 'env_1');
      expect(json['execution_timeout_seconds'], 60);
      expect(json['max_consecutive_failures'], 3);

      final restored = TriggerCreateParams.fromJson(json);
      expect(restored.interaction, isA<CreateModelInteractionParams>());
      expect(
        (restored.interaction as CreateModelInteractionParams).model,
        'gemini-3.5-flash',
      );
      expect(restored.schedule, params.schedule);
      expect(restored.timeZone, params.timeZone);
    });

    test('round-trips with a CreateAgentInteractionParams interaction', () {
      const params = TriggerCreateParams(
        interaction: CreateAgentInteractionParams(agent: 'agents/research'),
        schedule: '0 0 * * *',
        timeZone: 'America/New_York',
      );
      final json = params.toJson();
      expect((json['interaction'] as Map)['agent'], 'agents/research');

      final restored = TriggerCreateParams.fromJson(json);
      expect(restored.interaction, isA<CreateAgentInteractionParams>());
      expect(
        (restored.interaction as CreateAgentInteractionParams).agent,
        'agents/research',
      );
    });

    test('omits null optional fields from JSON', () {
      const params = TriggerCreateParams(
        interaction: CreateModelInteractionParams(model: 'gemini-3.5-flash'),
        schedule: '0 * * * *',
        timeZone: 'UTC',
      );
      final json = params.toJson();
      expect(json.containsKey('display_name'), isFalse);
      expect(json.containsKey('environment_id'), isFalse);
      expect(json.containsKey('execution_timeout_seconds'), isFalse);
      expect(json.containsKey('max_consecutive_failures'), isFalse);
    });

    test('copyWith replaces and preserves values', () {
      const params = TriggerCreateParams(
        interaction: CreateModelInteractionParams(model: 'gemini-3.5-flash'),
        schedule: '0 * * * *',
        timeZone: 'UTC',
      );
      final replaced = params.copyWith(schedule: '0 0 * * *');
      expect(replaced.schedule, '0 0 * * *');
      expect(replaced.timeZone, params.timeZone);

      final unchanged = params.copyWith();
      expect(unchanged.schedule, params.schedule);
    });
  });

  group('CreateInteractionParams.fromJson dispatch', () {
    test(
      'dispatches to CreateAgentInteractionParams when "agent" is present',
      () {
        final result = CreateInteractionParams.fromJson({
          'agent': 'agents/research',
        });
        expect(result, isA<CreateAgentInteractionParams>());
      },
    );

    test('dispatches to CreateModelInteractionParams otherwise', () {
      final result = CreateInteractionParams.fromJson({
        'model': 'gemini-3.5-flash',
      });
      expect(result, isA<CreateModelInteractionParams>());
    });
  });

  group('TriggerUpdate', () {
    test('round-trips fields', () {
      const update = TriggerUpdate(
        displayName: 'New name',
        status: TriggerStatus.paused,
      );
      final json = update.toJson();
      expect(json['display_name'], 'New name');
      expect(json['status'], 'paused');

      final restored = TriggerUpdate.fromJson(json);
      expect(restored.displayName, 'New name');
      expect(restored.status, TriggerStatus.paused);
    });

    test('omits null fields from JSON', () {
      expect(const TriggerUpdate().toJson(), isEmpty);
    });

    test('unknown status parses to null', () {
      final update = TriggerUpdate.fromJson({'status': 'something_new'});
      expect(update.status, isNull);
    });

    test('copyWith replaces and preserves values', () {
      const update = TriggerUpdate(displayName: 'A');
      final replaced = update.copyWith(status: TriggerStatus.active);
      expect(replaced.status, TriggerStatus.active);
      expect(replaced.displayName, 'A');

      final unchanged = update.copyWith();
      expect(unchanged.displayName, update.displayName);
    });
  });

  group('TriggerExecution', () {
    test('creates with only required fields', () {
      const execution = TriggerExecution(id: 'exec_1', triggerId: 'trg_1');
      expect(execution.id, 'exec_1');
      expect(execution.triggerId, 'trg_1');
      expect(execution.status, isNull);
    });

    test('round-trips all fields', () {
      final execution = TriggerExecution(
        id: 'exec_1',
        triggerId: 'trg_1',
        interactionId: 'i_1',
        environmentId: 'env_1',
        error: 'boom',
        scheduledTime: DateTime.utc(2026, 1, 1),
        startTime: DateTime.utc(2026, 1, 1, 0, 1),
        endTime: DateTime.utc(2026, 1, 1, 0, 2),
        status: TriggerExecutionStatus.completed,
      );
      final json = execution.toJson();
      expect(json['id'], 'exec_1');
      expect(json['trigger_id'], 'trg_1');
      expect(json['interaction_id'], 'i_1');
      expect(json['environment_id'], 'env_1');
      expect(json['error'], 'boom');
      expect(json['scheduled_time'], '2026-01-01T00:00:00.000Z');
      expect(json['start_time'], '2026-01-01T00:01:00.000Z');
      expect(json['end_time'], '2026-01-01T00:02:00.000Z');
      expect(json['status'], 'completed');

      final restored = TriggerExecution.fromJson(json);
      expect(restored.id, execution.id);
      expect(restored.triggerId, execution.triggerId);
      expect(restored.interactionId, execution.interactionId);
      expect(restored.environmentId, execution.environmentId);
      expect(restored.error, execution.error);
      expect(restored.scheduledTime, execution.scheduledTime);
      expect(restored.startTime, execution.startTime);
      expect(restored.endTime, execution.endTime);
      expect(restored.status, execution.status);
    });

    test('omits null optional fields from JSON', () {
      const execution = TriggerExecution(id: 'exec_1', triggerId: 'trg_1');
      final json = execution.toJson();
      expect(json.containsKey('interaction_id'), isFalse);
      expect(json.containsKey('environment_id'), isFalse);
      expect(json.containsKey('error'), isFalse);
      expect(json.containsKey('status'), isFalse);
    });

    test('unknown status parses to null', () {
      final execution = TriggerExecution.fromJson({
        'id': 'exec_1',
        'trigger_id': 'trg_1',
        'status': 'something_new',
      });
      expect(execution.status, isNull);
    });

    test(
      'in_progress and timed_out statuses round-trip snake_case wire values',
      () {
        expect(
          triggerExecutionStatusFromString('in_progress'),
          TriggerExecutionStatus.inProgress,
        );
        expect(
          triggerExecutionStatusToString(TriggerExecutionStatus.inProgress),
          'in_progress',
        );
        expect(
          triggerExecutionStatusFromString('timed_out'),
          TriggerExecutionStatus.timedOut,
        );
        expect(
          triggerExecutionStatusToString(TriggerExecutionStatus.timedOut),
          'timed_out',
        );
      },
    );

    test('copyWith replaces and preserves values', () {
      const execution = TriggerExecution(id: 'exec_1', triggerId: 'trg_1');
      final replaced = execution.copyWith(
        status: TriggerExecutionStatus.failed,
      );
      expect(replaced.status, TriggerExecutionStatus.failed);
      expect(replaced.id, execution.id);

      final unchanged = execution.copyWith();
      expect(unchanged.triggerId, execution.triggerId);
    });
  });

  group('ListTriggersResponse', () {
    test('round-trips triggers and nextPageToken', () {
      const response = ListTriggersResponse(
        triggers: [
          Trigger(
            id: 'trg_1',
            interaction: modelInteraction,
            schedule: '0 * * * *',
            timeZone: 'UTC',
          ),
        ],
        nextPageToken: 'tok',
      );
      final json = response.toJson();
      expect(json['triggers'], hasLength(1));
      expect(json['next_page_token'], 'tok');

      final restored = ListTriggersResponse.fromJson(json);
      expect(restored.triggers!.single.id, 'trg_1');
      expect(restored.nextPageToken, 'tok');
    });

    test('omits null fields from JSON', () {
      expect(const ListTriggersResponse().toJson(), isEmpty);
    });

    test('copyWith replaces and preserves values', () {
      const response = ListTriggersResponse(nextPageToken: 'tok');
      final replaced = response.copyWith(nextPageToken: 'tok2');
      expect(replaced.nextPageToken, 'tok2');

      final unchanged = response.copyWith();
      expect(unchanged.nextPageToken, response.nextPageToken);
    });
  });

  group('ListTriggerExecutionsResponse', () {
    test('round-trips triggerExecutions and nextPageToken', () {
      const response = ListTriggerExecutionsResponse(
        triggerExecutions: [TriggerExecution(id: 'exec_1', triggerId: 'trg_1')],
        nextPageToken: 'tok',
      );
      final json = response.toJson();
      expect(json['trigger_executions'], hasLength(1));
      expect(json['next_page_token'], 'tok');

      final restored = ListTriggerExecutionsResponse.fromJson(json);
      expect(restored.triggerExecutions!.single.id, 'exec_1');
      expect(restored.nextPageToken, 'tok');
    });

    test('omits null fields from JSON', () {
      expect(const ListTriggerExecutionsResponse().toJson(), isEmpty);
    });

    test('copyWith replaces and preserves values', () {
      const response = ListTriggerExecutionsResponse(nextPageToken: 'tok');
      final replaced = response.copyWith(nextPageToken: 'tok2');
      expect(replaced.nextPageToken, 'tok2');

      final unchanged = response.copyWith();
      expect(unchanged.nextPageToken, response.nextPageToken);
    });
  });

  group('TriggerStatus', () {
    test('unknown value parses to null', () {
      expect(triggerStatusFromString('something_new'), isNull);
    });
  });
}
