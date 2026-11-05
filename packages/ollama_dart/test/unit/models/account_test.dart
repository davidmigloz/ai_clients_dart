import 'dart:convert';

import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  final from = DateTime.utc(2026, 10);
  final until = DateTime.utc(2026, 11);
  final currentJson = <String, dynamic>{
    'included': {
      'balance_usd': 72.5,
      'allowance_usd': 100,
      'period': {
        'from': from.toIso8601String(),
        'until': until.toIso8601String(),
      },
    },
    'purchased': {'balance_usd': 25},
  };
  final legacyJson = <String, dynamic>{
    'included': {
      'session': {'remaining_percent': 75, 'resets_at': from.toIso8601String()},
      'weekly': {
        'remaining_percent': 40.5,
        'resets_at': until.toIso8601String(),
      },
    },
    'purchased': {'balance_usd': 25},
  };
  final metricJson = <String, dynamic>{
    'request_count': 15,
    'usage_usd': 0.01718,
    'input_tokens': 106000,
    'cached_input_tokens': 46000,
    'output_tokens': 13600,
  };
  final groupJson = <String, dynamic>{'model': 'clef', ...metricJson};
  final summaryJson = <String, dynamic>{
    ...metricJson,
    'groups': [groupJson],
    'remainder': {'request_count': 2, 'usage_usd': 0.001},
  };
  final bucketJson = <String, dynamic>{
    ...summaryJson,
    'from': from.toIso8601String(),
    'until': until.toIso8601String(),
    'partial': true,
  };
  final usageJson = <String, dynamic>{
    'range': '7d',
    'scope': 'team',
    'granularity': 'day',
    'group_by': 'model',
    'from': from.toIso8601String(),
    'until': until.toIso8601String(),
    'totals': summaryJson,
    'buckets': [bucketJson],
  };

  group('Balance reporting models', () {
    test('decodes both included balance shapes with typed periods', () {
      final current = BalanceResponse.fromJson(currentJson);
      final included = current.included as IncludedBalance;
      expect(included.balanceUsd, 72.5);
      expect(included.allowanceUsd, 100.0);
      expect(included.period.from, from);
      expect(included.period.until, until);
      expect(included.period.from.isUtc, isTrue);
      expect(current.purchased.balanceUsd, 25.0);
      expect(current.toJson(), currentJson);
      expect(current, BalanceResponse.fromJson(current.toJson()));
      expect(
        current.hashCode,
        BalanceResponse.fromJson(current.toJson()).hashCode,
      );
      expect(current, current.copyWith());
      expect(included, included.copyWith());
      expect(included.period, included.period.copyWith());
      expect(current.purchased, current.purchased.copyWith());
      expect(
        current.copyWith(purchased: const PurchasedBalance(balanceUsd: 1)),
        isNot(current),
      );
      expect(included.copyWith(balanceUsd: 2), isNot(included));
      expect(included.copyWith(allowanceUsd: 200), isNot(included));
      expect(included.period.copyWith(until: from), isNot(included.period));

      final legacy = BalanceResponse.fromJson(legacyJson);
      final limits = legacy.included as LegacyIncludedBalance;
      expect(limits.session.remainingPercent, 75.0);
      expect(limits.weekly.remainingPercent, 40.5);
      expect(limits.session.resetsAt, from);
      expect(legacy.toJson(), legacyJson);
      expect(legacy, BalanceResponse.fromJson(legacy.toJson()));
      expect(
        legacy.hashCode,
        BalanceResponse.fromJson(legacy.toJson()).hashCode,
      );
      expect(limits, limits.copyWith());
      expect(limits.session, limits.session.copyWith());
      expect(
        limits.session.copyWith(remainingPercent: 0),
        isNot(limits.session),
      );
      expect(limits.session.copyWith(resetsAt: until), isNot(limits.session));
      expect(limits.copyWith(session: limits.weekly), isNot(limits));
      expect(current, isNot(legacy));
    });

    test('normalizes offset and local DateTimes to UTC', () {
      final period = BalancePeriod.fromJson({
        'from': '2026-10-01T02:00:00+02:00',
        'until': until.toIso8601String(),
      });
      expect(period.from, from);
      expect(period.from.isUtc, isTrue);
      expect(period.toJson()['from'], from.toIso8601String());
      final local = DateTime(2026, 10);
      expect(BalancePeriod(from: local, until: local).from, local.toUtc());
      expect(
        LegacyBalanceLimit(remainingPercent: 1, resetsAt: local).resetsAt.isUtc,
        isTrue,
      );
    });

    test('preserves and freezes unfamiliar included balance shapes', () {
      final raw = <String, dynamic>{
        'future_credits': {
          'values': [1, 2],
        },
      };
      final included = BalanceIncluded.fromJson(raw) as UnknownIncludedBalance;
      final copy = BalanceIncluded.fromJson(
        jsonDecode(jsonEncode(raw)) as Map<String, dynamic>,
      );
      expect(included, copy);
      expect(included.hashCode, copy.hashCode);
      expect(included.toJson(), raw);
      expect(included, included.copyWith());
      ((raw['future_credits'] as Map<String, dynamic>)['values'] as List<int>)
          .clear();
      expect(included.toJson()['future_credits'], {
        'values': [1, 2],
      });
      expect(included.rawJson.clear, throwsUnsupportedError);
      final nested = included.rawJson['future_credits'] as Map<String, dynamic>;
      expect((nested['values'] as List<Object?>).clear, throwsUnsupportedError);
      expect(included.copyWith(rawJson: {'new': true}), isNot(included));
    });

    test('recognized shapes validate required values and nested objects', () {
      for (final json in <Map<String, dynamic>>[
        {},
        {'included': currentJson['included']},
        {'included': 'bad', 'purchased': currentJson['purchased']},
        {
          'included': currentJson['included'],
          'purchased': {'balance_usd': '25'},
        },
        {
          'included': {'balance_usd': 1},
          'purchased': currentJson['purchased'],
        },
        {
          'included': {'session': null},
          'purchased': currentJson['purchased'],
        },
      ]) {
        expect(() => BalanceResponse.fromJson(json), throwsFormatException);
      }
      expect(
        () => BalancePeriod.fromJson(const {
          'from': 'invalid',
          'until': 'invalid',
        }),
        throwsFormatException,
      );
      expect(
        () => LegacyBalanceLimit.fromJson(const {'remaining_percent': 50}),
        throwsFormatException,
      );
    });
  });

  group('Cloud usage models', () {
    test('round-trips all metrics, groups, remainder and partial buckets', () {
      final usage = UsageResponse.fromJson(usageJson);
      expect(usage.range, UsageRange.days7);
      expect(usage.scope, UsageScope.team);
      expect(usage.granularity, UsageGranularity.day);
      expect(usage.groupBy, UsageGroupBy.model);
      expect(usage.from, from);
      expect(usage.until, until);
      expect(usage.totals.requestCount, 15);
      expect(usage.totals.usageUsd, 0.01718);
      expect(usage.totals.inputTokens, 106000);
      expect(usage.totals.cachedInputTokens, 46000);
      expect(usage.totals.outputTokens, 13600);
      expect(usage.totals.groups!.single.model, 'clef');
      expect(usage.totals.remainder!.requestCount, 2);
      expect(usage.buckets.single.partial, isTrue);
      expect(usage.buckets.single.groups, usage.totals.groups);
      expect(usage.buckets.single.remainder, usage.totals.remainder);
      expect(usage.toJson(), usageJson);
      final copy = UsageResponse.fromJson(usage.toJson());
      expect(copy, usage);
      expect(copy.hashCode, usage.hashCode);
      expect(usage, usage.copyWith());
      expect(usage.totals, usage.totals.copyWith());
      expect(usage.buckets.single, usage.buckets.single.copyWith());
      expect(
        usage.totals.groups!.single,
        usage.totals.groups!.single.copyWith(),
      );
      final metrics = UsageMetrics.fromJson(metricJson);
      expect(metrics.toJson(), metricJson);
      expect(metrics, metrics.copyWith());
      expect(metrics, UsageMetrics.fromJson(metrics.toJson()));
      expect(
        metrics.hashCode,
        UsageMetrics.fromJson(metrics.toJson()).hashCode,
      );
      expect(usage.toString(), contains('range: UsageRange.days7'));
    });

    test('supports legacy request-count-only usage and empty periods', () {
      final usage = UsageResponse.fromJson({
        ...usageJson,
        'group_by': null,
        'totals': const {'request_count': 2},
        'buckets': [
          {
            'from': from.toIso8601String(),
            'until': until.toIso8601String(),
            'request_count': 0,
          },
        ],
      });
      expect(usage.totals.usageUsd, isNull);
      expect(usage.totals.inputTokens, isNull);
      expect(usage.totals.cachedInputTokens, isNull);
      expect(usage.totals.outputTokens, isNull);
      expect(usage.totals.groups, isNull);
      expect(usage.totals.remainder, isNull);
      expect(usage.totals.toJson(), {'request_count': 2});
      expect(usage.buckets.single.requestCount, 0);
      expect(usage.buckets.single.partial, isNull);
      expect(usage.toJson().containsKey('group_by'), isFalse);
      final empty = UsageSummary(requestCount: 0, groups: const []);
      expect(empty.toJson()['groups'], isEmpty);
      expect(empty, isNot(UsageSummary(requestCount: 0)));
    });

    test('preserves explicit zero metrics and a completed bucket flag', () {
      final json = <String, dynamic>{
        'from': from.toIso8601String(),
        'until': until.toIso8601String(),
        'partial': false,
        'request_count': 0,
        'usage_usd': 0,
        'input_tokens': 0,
        'cached_input_tokens': 0,
        'output_tokens': 0,
      };
      final bucket = UsageBucket.fromJson(json);
      expect(bucket.partial, isFalse);
      expect(bucket.usageUsd, 0);
      expect(bucket.inputTokens, 0);
      expect(bucket.cachedInputTokens, 0);
      expect(bucket.outputTokens, 0);
      expect(bucket.toJson(), json);
      expect(
        bucket,
        isNot(UsageBucket(from: from, until: until, requestCount: 0)),
      );
    });

    test(
      'collections are copied, immutable, and compare by content and order',
      () {
        final group = UsageGroup.fromJson(groupJson);
        final groups = [group];
        final summary = UsageSummary(requestCount: 15, groups: groups);
        final bucket = UsageBucket(
          from: from,
          until: until,
          requestCount: 15,
          groups: groups,
        );
        groups.clear();
        expect(summary.groups, [group]);
        expect(bucket.groups, [group]);
        expect(summary.groups!.clear, throwsUnsupportedError);
        expect(bucket.groups!.clear, throwsUnsupportedError);
        final buckets = [bucket];
        final usage = UsageResponse(
          range: UsageRange.days7,
          scope: UsageScope.self,
          granularity: UsageGranularity.day,
          from: from,
          until: until,
          totals: summary,
          buckets: buckets,
        );
        buckets.clear();
        expect(usage.buckets, [bucket]);
        expect(usage.buckets.clear, throwsUnsupportedError);
        expect(usage, UsageResponse.fromJson(usage.toJson()));
        expect(
          summary.copyWith(groups: [group.copyWith(model: 'other')]),
          isNot(summary),
        );
      },
    );

    test(
      'nullable metrics and selector fields can be cleared with copyWith',
      () {
        final usage = UsageResponse.fromJson(usageJson);
        final totals = usage.totals.copyWith(
          usageUsd: null,
          inputTokens: null,
          cachedInputTokens: null,
          outputTokens: null,
          groups: null,
          remainder: null,
        );
        expect(totals.toJson(), {'request_count': 15});
        final bucket = usage.buckets.single.copyWith(
          usageUsd: null,
          inputTokens: null,
          cachedInputTokens: null,
          outputTokens: null,
          groups: null,
          remainder: null,
          partial: null,
        );
        expect(bucket.toJson(), {
          'request_count': 15,
          'from': from.toIso8601String(),
          'until': until.toIso8601String(),
        });
        expect(
          usage.copyWith(groupBy: null).toJson().containsKey('group_by'),
          isFalse,
        );
        final metrics = UsageMetrics.fromJson(metricJson).copyWith(
          usageUsd: null,
          inputTokens: null,
          cachedInputTokens: null,
          outputTokens: null,
        );
        expect(metrics.toJson(), {'request_count': 15});
        final group = UsageGroup.fromJson(groupJson).copyWith(
          usageUsd: null,
          inputTokens: null,
          cachedInputTokens: null,
          outputTokens: null,
        );
        expect(group.toJson(), {'model': 'clef', 'request_count': 15});
      },
    );

    test('nullable USD copyWith accepts integer numeric literals', () {
      final values = <double?>[
        UsageMetrics.fromJson(metricJson).copyWith(usageUsd: 1).usageUsd,
        UsageGroup.fromJson(groupJson).copyWith(usageUsd: 1).usageUsd,
        UsageSummary.fromJson(summaryJson).copyWith(usageUsd: 1).usageUsd,
        UsageBucket.fromJson(bucketJson).copyWith(usageUsd: 1).usageUsd,
      ];
      for (final value in values) {
        expect(value, isA<double>());
        expect(value, 1.0);
      }
    });

    test('required fields and malformed collections fail contextually', () {
      for (final key in [
        'range',
        'scope',
        'granularity',
        'from',
        'until',
        'totals',
        'buckets',
      ]) {
        final json = Map<String, dynamic>.of(usageJson)..remove(key);
        expect(
          () => UsageResponse.fromJson(json),
          throwsFormatException,
          reason: key,
        );
      }
      for (final entry in <String, Object?>{
        'totals': [],
        'buckets': [null],
        'from': 'invalid',
        'group_by': 1,
      }.entries) {
        expect(
          () => UsageResponse.fromJson({...usageJson, entry.key: entry.value}),
          throwsFormatException,
        );
      }
      for (final json in <Map<String, dynamic>>[
        {},
        {'request_count': 1.5},
        {'request_count': 1, 'input_tokens': '2'},
        {'request_count': 1, 'usage_usd': double.nan},
      ]) {
        expect(() => UsageMetrics.fromJson(json), throwsFormatException);
      }
      expect(
        () => UsageSummary.fromJson(const {
          'request_count': 0,
          'groups': <String, Object?>{},
        }),
        throwsFormatException,
      );
      expect(
        () => UsageSummary.fromJson(const {
          'request_count': 0,
          'remainder': <Object?>[],
        }),
        throwsFormatException,
      );
      expect(
        () => UsageGroup.fromJson(const {'request_count': 0}),
        throwsFormatException,
      );
      expect(
        () => UsageBucket.fromJson({...bucketJson, 'partial': 'true'}),
        throwsFormatException,
      );
    });

    test(
      'parses documented enum values and tolerates future response selectors',
      () {
        expect(UsageRange.fromJson('24h'), UsageRange.hours24);
        expect(UsageRange.fromJson('7d'), UsageRange.days7);
        expect(UsageRange.fromJson('30d'), UsageRange.days30);
        expect(UsageScope.fromJson('self'), UsageScope.self);
        expect(UsageScope.fromJson('team'), UsageScope.team);
        expect(UsageGroupBy.fromJson('model'), UsageGroupBy.model);
        expect(UsageGranularity.fromJson('hour'), UsageGranularity.hour);
        expect(UsageGranularity.fromJson('day'), UsageGranularity.day);
        final future = UsageResponse.fromJson({
          ...usageJson,
          'range': '90d',
          'scope': 'organization',
          'granularity': 'week',
          'group_by': 'api_key',
        });
        expect(future.range, UsageRange.unknown);
        expect(future.scope, UsageScope.unknown);
        expect(future.granularity, UsageGranularity.unknown);
        expect(future.groupBy, UsageGroupBy.unknown);
      },
    );
  });
}
