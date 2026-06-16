import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DeploymentStatus', () {
    test('fromJson/toJson round-trips each known value', () {
      for (final value in ['active', 'paused']) {
        final status = DeploymentStatus.fromJson(value);
        expect(status.value, value);
        expect(status.toJson(), value);
      }
      expect(DeploymentStatus.fromJson('active'), DeploymentStatus.active);
      expect(DeploymentStatus.fromJson('paused'), DeploymentStatus.paused);
    });

    test('unrecognized value falls back to unknown', () {
      final status = DeploymentStatus.fromJson('archived');
      expect(status, DeploymentStatus.unknown);
      // The enum does not preserve the raw wire string; the fallback
      // serializes as the canonical "unknown" sentinel.
      expect(status.toJson(), 'unknown');
    });
  });

  group('TriggerType', () {
    test('fromJson/toJson round-trips each known value', () {
      for (final value in ['schedule', 'manual']) {
        final type = TriggerType.fromJson(value);
        expect(type.value, value);
        expect(type.toJson(), value);
      }
      expect(TriggerType.fromJson('schedule'), TriggerType.schedule);
      expect(TriggerType.fromJson('manual'), TriggerType.manual);
    });

    test('unrecognized value falls back to unknown', () {
      final type = TriggerType.fromJson('webhook');
      expect(type, TriggerType.unknown);
      // The enum does not preserve the raw wire string; the fallback
      // serializes as the canonical "unknown" sentinel.
      expect(type.toJson(), 'unknown');
    });
  });

  group('Schedule', () {
    test('cron round-trips with last_run_at and upcoming_runs_at present', () {
      final json = {
        'type': 'cron',
        'expression': '0 9 * * 1-5',
        'timezone': 'America/Los_Angeles',
        'last_run_at': '2026-04-01T09:00:00.000Z',
        'upcoming_runs_at': [
          '2026-04-02T09:00:00.000Z',
          '2026-04-03T09:00:00.000Z',
        ],
      };

      final schedule = Schedule.fromJson(json);
      expect(schedule, isA<CronSchedule>());
      final cron = schedule as CronSchedule;
      expect(cron.type, 'cron');
      expect(cron.expression, '0 9 * * 1-5');
      expect(cron.timezone, 'America/Los_Angeles');
      expect(cron.lastRunAt, DateTime.utc(2026, 4, 1, 9));
      expect(cron.upcomingRunsAt, [
        DateTime.utc(2026, 4, 2, 9),
        DateTime.utc(2026, 4, 3, 9),
      ]);

      expect(cron.toJson(), {
        'type': 'cron',
        'expression': '0 9 * * 1-5',
        'timezone': 'America/Los_Angeles',
        'last_run_at': '2026-04-01T09:00:00.000Z',
        'upcoming_runs_at': [
          '2026-04-02T09:00:00.000Z',
          '2026-04-03T09:00:00.000Z',
        ],
      });
    });

    test('cron round-trips with last_run_at and upcoming_runs_at absent', () {
      final json = {
        'type': 'cron',
        'expression': '* * * * *',
        'timezone': 'UTC',
      };

      final cron = Schedule.fromJson(json) as CronSchedule;
      expect(cron.lastRunAt, isNull);
      expect(cron.upcomingRunsAt, isNull);

      final out = cron.toJson();
      expect(out.containsKey('last_run_at'), isFalse);
      expect(out.containsKey('upcoming_runs_at'), isFalse);
      expect(out, {
        'type': 'cron',
        'expression': '* * * * *',
        'timezone': 'UTC',
      });
    });

    test('unrecognized type falls back to UnknownSchedule', () {
      final json = {'type': 'interval', 'every_seconds': 60};

      final schedule = Schedule.fromJson(json);
      expect(schedule, isA<UnknownSchedule>());
      expect(schedule.toJson(), json);
    });
  });

  group('ScheduleParams', () {
    test('cron round-trips', () {
      final json = {
        'type': 'cron',
        'expression': '0 0 * * *',
        'timezone': 'UTC',
      };

      final params = ScheduleParams.fromJson(json);
      expect(params, isA<CronScheduleParams>());
      final cron = params as CronScheduleParams;
      expect(cron.type, 'cron');
      expect(cron.expression, '0 0 * * *');
      expect(cron.timezone, 'UTC');
      expect(cron.toJson(), json);
    });

    test('unrecognized type falls back to UnknownScheduleParams', () {
      final json = {'type': 'interval', 'every_seconds': 30};

      final params = ScheduleParams.fromJson(json);
      expect(params, isA<UnknownScheduleParams>());
      expect(params.toJson(), json);
    });
  });

  group('TriggerContext', () {
    test('schedule round-trips with scheduled_at', () {
      final json = {
        'type': 'schedule',
        'scheduled_at': '2026-04-01T09:00:00.000Z',
      };

      final context = TriggerContext.fromJson(json);
      expect(context, isA<ScheduleTriggerContext>());
      final schedule = context as ScheduleTriggerContext;
      expect(schedule.type, 'schedule');
      expect(schedule.scheduledAt, DateTime.utc(2026, 4, 1, 9));
      expect(schedule.toJson(), json);
    });

    test('manual round-trips', () {
      final json = {'type': 'manual'};

      final context = TriggerContext.fromJson(json);
      expect(context, isA<ManualTriggerContext>());
      final manual = context as ManualTriggerContext;
      expect(manual.type, 'manual');
      expect(manual.toJson(), json);
    });

    test('unrecognized type falls back to UnknownTriggerContext', () {
      final json = {'type': 'webhook', 'webhook_id': 'wh_1'};

      final context = TriggerContext.fromJson(json);
      expect(context, isA<UnknownTriggerContext>());
      expect(context.toJson(), json);
    });
  });
}
