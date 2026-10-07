import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigurationUpdateReasoning', () {
    test('supports const construction and an empty update object', () {
      const update = ConfigurationUpdateReasoning();
      expect(update.toJson(), isEmpty);
      expect(ConfigurationUpdateReasoning.fromJson(const {}), update);
      expect(update.copyWith(), update);
      expect(update.toString(), contains('effort: null'));
    });

    for (final effort in ReasoningEffort.values) {
      test('round trips ${effort.value} with a complete value contract', () {
        final json = {'effort': effort.toJson()};
        final parsed = ConfigurationUpdateReasoning.fromJson(json);
        final constructed = ConfigurationUpdateReasoning(effort: effort);

        expect(parsed.effort, effort);
        expect(parsed.toJson(), json);
        expect(parsed, constructed);
        expect(parsed.hashCode, constructed.hashCode);
        expect({parsed, constructed}, hasLength(1));
        expect(parsed.copyWith(), parsed);
        expect(parsed.toString(), contains('effort: $effort'));
      });
    }

    test('accepts nullable effort and normalizes null to omission', () {
      final parsed = ConfigurationUpdateReasoning.fromJson(const {
        'effort': null,
      });
      expect(parsed.effort, isNull);
      expect(parsed.toJson(), isEmpty);
      expect(parsed, const ConfigurationUpdateReasoning());
    });

    test('retains the existing unknown effort fallback', () {
      final parsed = ConfigurationUpdateReasoning.fromJson(const {
        'effort': 'future_effort',
      });
      expect(parsed.effort, ReasoningEffort.unknown);
      expect(parsed.toJson(), {'effort': 'unknown'});
    });

    for (final malformed in <Object>[0, false, [], {}]) {
      test('rejects wrong-type effort $malformed with field context', () {
        expect(
          () => ConfigurationUpdateReasoning.fromJson({'effort': malformed}),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'context',
              contains('ConfigurationUpdateReasoning.effort'),
            ),
          ),
        );
      });
    }

    test(
      'exposes and emits only effort rather than request reasoning fields',
      () {
        final parsed = ConfigurationUpdateReasoning.fromJson(const {
          'effort': 'low',
          'summary': 'auto',
          'context': 'all',
          'mode': 'future_mode',
          'provider_extension': true,
        });
        expect(parsed.toJson(), {'effort': 'low'});
        expect(
          parsed,
          const ConfigurationUpdateReasoning(effort: ReasoningEffort.low),
        );
      },
    );

    test('copy updates and clears effort without changing the original', () {
      const original = ConfigurationUpdateReasoning(
        effort: ReasoningEffort.high,
      );
      final changed = original.copyWith(effort: ReasoningEffort.low);
      final cleared = original.copyWith(effort: null);

      expect(changed.toJson(), {'effort': 'low'});
      expect(changed, isNot(original));
      expect(changed.hashCode, ReasoningEffort.low.hashCode);
      expect(cleared, const ConfigurationUpdateReasoning());
      expect(cleared.toJson(), isEmpty);
      expect(original.toJson(), {'effort': 'high'});
    });
  });
}
