import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Cache controls', () {
    const wide = ResponsePromptCacheOptionsParam(
      mode: PromptCacheMode.explicit,
      ttl: PromptCacheTtl.minutes30,
      comparisonResponseId: 'resp_baseline',
      prewarm: false,
    );
    test('wide request round trip, false, empty, and nullable comparison', () {
      expect(wide.toJson(), {
        'mode': 'explicit',
        'ttl': '30m',
        'comparison_response_id': 'resp_baseline',
        'prewarm': false,
      });
      final parsed = ResponsePromptCacheOptionsParam.fromJson(wide.toJson());
      expect(parsed, wide);
      expect(parsed.hashCode, wide.hashCode);
      expect(wide.copyWith(), wide);
      expect(
        wide
            .copyWith(
              mode: null,
              ttl: null,
              comparisonResponseId: null,
              prewarm: null,
            )
            .toJson(),
        isEmpty,
      );
      expect(
        ResponsePromptCacheOptionsParam.fromJson(const {
          'comparison_response_id': null,
        }).toJson(),
        isEmpty,
      );
      expect(const ResponsePromptCacheOptionsParam().toJson(), isEmpty);
      expect(wide.toString(), contains('prewarm: false'));
      expect(wide.copyWith(prewarm: true), isNot(wide));
      expect(wide.copyWith(comparisonResponseId: 'other'), isNot(wide));
      expect(wide.copyWith(mode: PromptCacheMode.implicit), isNot(wide));
      expect(wide.copyWith(ttl: PromptCacheTtl.unknown), isNot(wide));
    });
    test(
      'narrow options keep an empty object and strict nonnullable members',
      () {
        expect(const PromptCacheOptionsParam().toJson(), isEmpty);
        for (final key in ['mode', 'ttl']) {
          for (final value in [null, 30, false, <String, dynamic>{}]) {
            expect(
              () => PromptCacheOptionsParam.fromJson({key: value}),
              throwsFormatException,
            );
            expect(
              () => ResponsePromptCacheOptionsParam.fromJson({key: value}),
              throwsFormatException,
            );
          }
        }
        for (final value in [null, 0, 'false', <String, dynamic>{}]) {
          expect(
            () => ResponsePromptCacheOptionsParam.fromJson({'prewarm': value}),
            throwsFormatException,
          );
        }
        expect(
          () => ResponsePromptCacheOptionsParam.fromJson(const {
            'comparison_response_id': 1,
          }),
          throwsFormatException,
        );
      },
    );
    test(
      'echo requires mode/TTL, preserves comparison and never echoes prewarm',
      () {
        final echo = PromptCacheOptions.fromJson({
          ...wide.toJson(),
          'prewarm': true,
        });
        expect(echo.toJson(), {
          'mode': 'explicit',
          'ttl': '30m',
          'comparison_response_id': 'resp_baseline',
        });
        expect(echo.copyWith(), echo);
        expect(echo.copyWith().hashCode, echo.hashCode);
        expect(
          echo
              .copyWith(comparisonResponseId: null)
              .toJson()
              .containsKey('comparison_response_id'),
          isFalse,
        );
        expect(echo.copyWith(comparisonResponseId: 'other'), isNot(echo));
        expect(echo.toString(), contains('resp_baseline'));
        for (final json in [
          <String, dynamic>{},
          {'mode': 'implicit'},
          {'ttl': '30m'},
          {'mode': null, 'ttl': '30m'},
          {'mode': 'implicit', 'ttl': null},
        ]) {
          expect(
            () => PromptCacheOptions.fromJson(json),
            throwsFormatException,
          );
        }
      },
    );
  });

  group('Cache diagnostics', () {
    const reasons = [
      CacheMissReason.modelChanged,
      CacheMissReason.promptCacheKeyChanged,
      CacheMissReason.toolsChanged,
      CacheMissReason.textFormatChanged,
      CacheMissReason.reasoningEffortChanged,
      CacheMissReason.verbosityChanged,
      CacheMissReason.contextCompacted,
      CacheMissReason.inputChanged,
      CacheMissReason.serviceTierChanged,
      CacheMissReason('future_reason'),
    ];
    for (final reason in reasons) {
      test(
        'miss reason ${reason.value} preserves exact value and zero counts',
        () {
          final parsed =
              PromptCacheDiagnostics.fromJson({
                    'type': 'cache_miss',
                    'reason': reason.toJson(),
                    'cache_missed_tokens': 0,
                    'comparison_reusable_tokens': 0,
                  })
                  as PromptCacheMissDiagnostics;
          final expected = PromptCacheDiagnostics.cacheMiss(
            reason: reason,
            cacheMissedTokens: 0,
            comparisonReusableTokens: 0,
          );
          expect(parsed, expected);
          expect(parsed.hashCode, expected.hashCode);
          expect(parsed.toJson()['reason'], reason.value);
          expect(parsed.toJson()['comparison_reusable_tokens'], 0);
          expect(parsed.copyWith(), parsed);
          expect(
            parsed.copyWith(comparisonReusableTokens: null),
            isNot(parsed),
          );
          expect(
            parsed
                .copyWith(comparisonReusableTokens: null)
                .toJson()
                .containsKey('comparison_reusable_tokens'),
            isFalse,
          );
          expect(parsed.copyWith(cacheMissedTokens: 1), isNot(parsed));
          expect(
            parsed.copyWith(reason: const CacheMissReason('other')),
            isNot(parsed),
          );
          expect(parsed.toString(), contains('cacheMissedTokens: 0'));
          expect(CacheMissReason.fromJson(reason.toJson()), reason);
          expect(reason.copyWith(), reason);
          expect(reason.copyWith().hashCode, reason.hashCode);
          expect(reason.toString(), contains(reason.value));
        },
      );
    }
    test(
      'fieldless known variants and copies preserve their discriminator',
      () {
        const variants = [
          PromptCacheHitDiagnostics(),
          PromptCacheComparisonResponseNotFoundDiagnostics(),
          PromptCacheUnavailableDiagnostics(),
        ];
        for (final variant in variants) {
          final parsed = PromptCacheDiagnostics.fromJson(variant.toJson());
          expect(parsed, variant);
          expect(parsed.hashCode, variant.hashCode);
          expect(parsed.toJson(), {'type': variant.type});
          expect(parsed.toString(), isNotEmpty);
        }
        expect(
          const PromptCacheHitDiagnostics().copyWith(),
          const PromptCacheHitDiagnostics(),
        );
        expect(
          const PromptCacheComparisonResponseNotFoundDiagnostics().copyWith(),
          const PromptCacheComparisonResponseNotFoundDiagnostics(),
        );
        expect(
          const PromptCacheUnavailableDiagnostics().copyWith(),
          const PromptCacheUnavailableDiagnostics(),
        );
        expect(variants.toSet(), hasLength(3));
      },
    );
    test('known malformed values fail instead of becoming unknown', () {
      for (final json in [
        <String, dynamic>{},
        {'type': null},
        {'type': 1},
        {'type': 'cache_miss'},
        {'type': 'cache_miss', 'reason': null, 'cache_missed_tokens': 0},
        {
          'type': 'cache_miss',
          'reason': 'input_changed',
          'cache_missed_tokens': null,
        },
        {
          'type': 'cache_miss',
          'reason': 'input_changed',
          'cache_missed_tokens': 1.5,
        },
        {
          'type': 'cache_miss',
          'reason': 'input_changed',
          'cache_missed_tokens': 0,
          'comparison_reusable_tokens': null,
        },
        {
          'type': 'cache_miss',
          'reason': 'input_changed',
          'cache_missed_tokens': 0,
          'comparison_reusable_tokens': '0',
        },
      ]) {
        expect(
          () => PromptCacheDiagnostics.fromJson(json),
          throwsFormatException,
        );
      }
      expect(() => CacheMissReason.fromJson(null), throwsFormatException);
      expect(
        () => PromptCacheHitDiagnostics.fromJson(const {'type': 'unavailable'}),
        throwsFormatException,
      );
      expect(
        () => PromptCacheUnavailableDiagnostics.fromJson(const {
          'type': 'cache_hit',
        }),
        throwsFormatException,
      );
      expect(
        () => PromptCacheComparisonResponseNotFoundDiagnostics.fromJson(const {
          'type': 'cache_hit',
        }),
        throwsFormatException,
      );
      expect(
        () => PromptCacheMissDiagnostics.fromJson(const {'type': 'cache_hit'}),
        throwsFormatException,
      );
    });
    test(
      'future objects freeze arbitrary nested JSON and remain hash stable',
      () {
        final child = <dynamic, dynamic>{
          'secret': <dynamic>[
            'private',
            {'count': 0},
          ],
        };
        final source = <String, dynamic>{'type': 'future', 'payload': child};
        final unknown =
            PromptCacheDiagnostics.fromJson(source)
                as UnknownPromptCacheDiagnostics;
        final hash = unknown.hashCode;
        child['secret'] = ['changed'];
        source['type'] = 'changed';
        expect(unknown.type, 'future');
        expect(unknown.hashCode, hash);
        expect(unknown.toJson(), {
          'type': 'future',
          'payload': {
            'secret': [
              'private',
              {'count': 0},
            ],
          },
        });
        expect(
          () => unknown.rawJson['type'] = 'changed',
          throwsUnsupportedError,
        );
        final payload = unknown.toJson()['payload'] as Map<String, dynamic>;
        expect(() => payload['secret'] = 'changed', throwsUnsupportedError);
        final list = payload['secret'] as List<dynamic>;
        expect(() => list.add('changed'), throwsUnsupportedError);
        expect(
          () => (list.last as Map<String, dynamic>)['count'] = 1,
          throwsUnsupportedError,
        );
        final equal = UnknownPromptCacheDiagnostics(const {
          'payload': {
            'secret': [
              'private',
              {'count': 0},
            ],
          },
          'type': 'future',
        });
        expect(unknown, equal);
        expect(unknown.hashCode, equal.hashCode);
        expect(unknown.copyWith(), unknown);
        expect(unknown.copyWith(rawJson: {'type': 'other'}), isNot(unknown));
        expect(unknown.toString(), isNot(contains('private')));
      },
    );
  });
}
