import 'package:openai_dart/openai_dart_realtime.dart';
import 'package:test/test.dart';

void main() {
  group('RealtimeReasoning', () {
    test('roundtrips each effort value', () {
      for (final effort in RealtimeReasoningEffort.values) {
        final reasoning = RealtimeReasoning(effort: effort);
        final json = reasoning.toJson();
        expect(json['effort'], effort.toJson());

        final parsed = RealtimeReasoning.fromJson(json);
        expect(parsed.effort, effort);
        expect(parsed, reasoning);
      }
    });

    test('null effort omits the field', () {
      const reasoning = RealtimeReasoning();
      expect(reasoning.toJson(), isEmpty);

      final parsed = RealtimeReasoning.fromJson(const {});
      expect(parsed.effort, isNull);
      expect(parsed, reasoning);
    });

    test('copyWith updates and clears effort', () {
      const reasoning = RealtimeReasoning(
        effort: RealtimeReasoningEffort.medium,
      );
      expect(
        reasoning.copyWith(effort: RealtimeReasoningEffort.high).effort,
        RealtimeReasoningEffort.high,
      );
      expect(reasoning.copyWith(effort: null).effort, isNull);
      expect(reasoning.copyWith().effort, RealtimeReasoningEffort.medium);
    });

    test('toString includes effort', () {
      const reasoning = RealtimeReasoning(
        effort: RealtimeReasoningEffort.minimal,
      );
      expect(reasoning.toString(), contains('minimal'));
    });

    test('equality is content-based', () {
      const a = RealtimeReasoning(effort: RealtimeReasoningEffort.low);
      const b = RealtimeReasoning(effort: RealtimeReasoningEffort.low);
      const c = RealtimeReasoning(effort: RealtimeReasoningEffort.high);
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  group('RealtimeReasoningEffort', () {
    test('fromJson parses every value', () {
      expect(
        RealtimeReasoningEffort.fromJson('minimal'),
        RealtimeReasoningEffort.minimal,
      );
      expect(
        RealtimeReasoningEffort.fromJson('low'),
        RealtimeReasoningEffort.low,
      );
      expect(
        RealtimeReasoningEffort.fromJson('medium'),
        RealtimeReasoningEffort.medium,
      );
      expect(
        RealtimeReasoningEffort.fromJson('high'),
        RealtimeReasoningEffort.high,
      );
      expect(
        RealtimeReasoningEffort.fromJson('xhigh'),
        RealtimeReasoningEffort.xhigh,
      );
    });

    test('throws on unknown value (matches package convention)', () {
      expect(
        () => RealtimeReasoningEffort.fromJson('extreme'),
        throwsFormatException,
      );
    });
  });
}
