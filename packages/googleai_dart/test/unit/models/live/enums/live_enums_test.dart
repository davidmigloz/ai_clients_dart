import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ActivityHandling', () {
    test('uses the documented unspecified value', () {
      const wire = 'ACTIVITY_HANDLING_UNSPECIFIED';
      expect(ActivityHandling.fromJson(wire), ActivityHandling.unspecified);
      expect(ActivityHandling.unspecified.toJson(), wire);
    });

    test('startOfActivityInterrupts has correct value', () {
      expect(
        ActivityHandling.startOfActivityInterrupts.value,
        'START_OF_ACTIVITY_INTERRUPTS',
      );
    });

    test('noInterruption has correct value', () {
      expect(ActivityHandling.noInterruption.value, 'NO_INTERRUPTION');
    });

    group('fromJson', () {
      test('parses START_OF_ACTIVITY_INTERRUPTS', () {
        final result = ActivityHandling.fromJson(
          'START_OF_ACTIVITY_INTERRUPTS',
        );
        expect(result, ActivityHandling.startOfActivityInterrupts);
      });

      test('parses NO_INTERRUPTION', () {
        final result = ActivityHandling.fromJson('NO_INTERRUPTION');
        expect(result, ActivityHandling.noInterruption);
      });

      test('throws FormatException for unknown value', () {
        expect(
          () => ActivityHandling.fromJson('UNKNOWN_VALUE'),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('toJson', () {
      test('startOfActivityInterrupts serializes correctly', () {
        expect(
          ActivityHandling.startOfActivityInterrupts.toJson(),
          'START_OF_ACTIVITY_INTERRUPTS',
        );
      });

      test('noInterruption serializes correctly', () {
        expect(ActivityHandling.noInterruption.toJson(), 'NO_INTERRUPTION');
      });
    });

    test('round-trip conversion for all values', () {
      for (final value in ActivityHandling.values) {
        final json = value.toJson();
        final restored = ActivityHandling.fromJson(json);
        expect(restored, value);
      }
    });
  });

  group('StartSensitivity', () {
    test('high has correct value', () {
      expect(StartSensitivity.high.value, 'START_SENSITIVITY_HIGH');
    });

    test('low has correct value', () {
      expect(StartSensitivity.low.value, 'START_SENSITIVITY_LOW');
    });

    group('fromJson', () {
      test('parses HIGH', () {
        final result = StartSensitivity.fromJson('HIGH');
        expect(result, StartSensitivity.high);
      });

      test('parses LOW', () {
        final result = StartSensitivity.fromJson('LOW');
        expect(result, StartSensitivity.low);
      });

      test('throws FormatException for unknown value', () {
        expect(
          () => StartSensitivity.fromJson('MEDIUM'),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('toJson', () {
      test('high serializes correctly', () {
        expect(StartSensitivity.high.toJson(), 'START_SENSITIVITY_HIGH');
      });

      test('low serializes correctly', () {
        expect(StartSensitivity.low.toJson(), 'START_SENSITIVITY_LOW');
      });

      test('unspecified uses the documented default marker', () {
        expect(
          StartSensitivity.unspecified.toJson(),
          'START_SENSITIVITY_UNSPECIFIED',
        );
      });
    });

    test('round-trip conversion for all values', () {
      for (final value in StartSensitivity.values) {
        final json = value.toJson();
        final restored = StartSensitivity.fromJson(json);
        expect(restored, value);
      }
    });
  });

  group('EndSensitivity', () {
    test('high has correct value', () {
      expect(EndSensitivity.high.value, 'END_SENSITIVITY_HIGH');
    });

    test('low has correct value', () {
      expect(EndSensitivity.low.value, 'END_SENSITIVITY_LOW');
    });

    group('fromJson', () {
      test('parses HIGH', () {
        final result = EndSensitivity.fromJson('HIGH');
        expect(result, EndSensitivity.high);
      });

      test('parses LOW', () {
        final result = EndSensitivity.fromJson('LOW');
        expect(result, EndSensitivity.low);
      });

      test('throws FormatException for unknown value', () {
        expect(
          () => EndSensitivity.fromJson('VERY_HIGH'),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('toJson', () {
      test('high serializes correctly', () {
        expect(EndSensitivity.high.toJson(), 'END_SENSITIVITY_HIGH');
      });

      test('low serializes correctly', () {
        expect(EndSensitivity.low.toJson(), 'END_SENSITIVITY_LOW');
      });

      test('unspecified uses the documented default marker', () {
        expect(
          EndSensitivity.unspecified.toJson(),
          'END_SENSITIVITY_UNSPECIFIED',
        );
      });
    });

    test('round-trip conversion for all values', () {
      for (final value in EndSensitivity.values) {
        final json = value.toJson();
        final restored = EndSensitivity.fromJson(json);
        expect(restored, value);
      }
    });
  });

  group('TurnCoverage', () {
    test('supports unspecified and detected audio with all video', () {
      expect(TurnCoverage.unspecified.toJson(), 'TURN_COVERAGE_UNSPECIFIED');
      expect(
        TurnCoverage.turnIncludesAudioActivityAndAllVideo.toJson(),
        'TURN_INCLUDES_AUDIO_ACTIVITY_AND_ALL_VIDEO',
      );
    });

    test('turnIncludesOnlyActivity has correct value', () {
      expect(
        TurnCoverage.turnIncludesOnlyActivity.value,
        'TURN_INCLUDES_ONLY_ACTIVITY',
      );
    });

    test('turnIncludesAllInput has correct value', () {
      expect(
        TurnCoverage.turnIncludesAllInput.value,
        'TURN_INCLUDES_ALL_INPUT',
      );
    });

    group('fromJson', () {
      test('parses TURN_INCLUDES_ONLY_ACTIVITY', () {
        final result = TurnCoverage.fromJson('TURN_INCLUDES_ONLY_ACTIVITY');
        expect(result, TurnCoverage.turnIncludesOnlyActivity);
      });

      test('parses TURN_INCLUDES_ALL_INPUT', () {
        final result = TurnCoverage.fromJson('TURN_INCLUDES_ALL_INPUT');
        expect(result, TurnCoverage.turnIncludesAllInput);
      });

      test('throws FormatException for unknown value', () {
        expect(
          () => TurnCoverage.fromJson('TURN_INCLUDES_NOTHING'),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('toJson', () {
      test('turnIncludesOnlyActivity serializes correctly', () {
        expect(
          TurnCoverage.turnIncludesOnlyActivity.toJson(),
          'TURN_INCLUDES_ONLY_ACTIVITY',
        );
      });

      test('turnIncludesAllInput serializes correctly', () {
        expect(
          TurnCoverage.turnIncludesAllInput.toJson(),
          'TURN_INCLUDES_ALL_INPUT',
        );
      });
    });

    test('round-trip conversion for all values', () {
      for (final value in TurnCoverage.values) {
        final json = value.toJson();
        final restored = TurnCoverage.fromJson(json);
        expect(restored, value);
      }
    });
  });
}
