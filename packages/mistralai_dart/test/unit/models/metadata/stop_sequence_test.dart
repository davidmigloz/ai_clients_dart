import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('StopSequence', () {
    group('StopSequenceSingle', () {
      test('creates with constructor', () {
        const stop = StopSequence.single('\n');
        expect(stop, isA<StopSequenceSingle>());
        expect((stop as StopSequenceSingle).stop, '\n');
      });

      test('toJson returns string', () {
        const stop = StopSequence.single('END');
        expect(stop.toJson(), 'END');
      });

      test('fromJson parses string', () {
        final stop = StopSequence.fromJson('STOP');
        expect(stop, isA<StopSequenceSingle>());
        expect((stop as StopSequenceSingle).stop, 'STOP');
      });

      test('equality works correctly', () {
        const a = StopSequence.single('END');
        const b = StopSequence.single('END');
        const c = StopSequence.single('STOP');

        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
        expect(a, isNot(equals(c)));
      });

      test('toString provides useful representation', () {
        const stop = StopSequence.single('\n');
        expect(stop.toString(), contains('StopSequence.single'));
      });
    });

    group('StopSequenceMultiple', () {
      test('creates with constructor', () {
        const stop = StopSequence.multiple(['\n', 'END']);
        expect(stop, isA<StopSequenceMultiple>());
        expect((stop as StopSequenceMultiple).stops, ['\n', 'END']);
      });

      test('toJson returns list', () {
        const stop = StopSequence.multiple(['END', '###']);
        expect(stop.toJson(), ['END', '###']);
      });

      test('fromJson parses list', () {
        final stop = StopSequence.fromJson(['STOP', 'END']);
        expect(stop, isA<StopSequenceMultiple>());
        expect((stop as StopSequenceMultiple).stops, ['STOP', 'END']);
      });

      test('equality works correctly', () {
        const a = StopSequence.multiple(['END', '###']);
        const b = StopSequence.multiple(['END', '###']);
        const c = StopSequence.multiple(['END']);

        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
        expect(a, isNot(equals(c)));
      });

      test('toString provides useful representation', () {
        const stop = StopSequence.multiple(['\n']);
        expect(stop.toString(), contains('StopSequence.multiple'));
      });
    });

    group('fromJson', () {
      test('throws FormatException for invalid type', () {
        expect(
          () => StopSequence.fromJson(42),
          throwsA(isA<FormatException>()),
        );
      });

      test('single and multiple are not equal', () {
        const single = StopSequence.single('END');
        const multiple = StopSequence.multiple(['END']);
        expect(single, isNot(equals(multiple)));
      });
    });

    group('round-trip', () {
      test('single round-trips through JSON', () {
        const original = StopSequence.single('STOP');
        final json = original.toJson();
        final restored = StopSequence.fromJson(json);
        expect(restored, equals(original));
      });

      test('multiple round-trips through JSON', () {
        const original = StopSequence.multiple(['STOP', 'END', '###']);
        final json = original.toJson();
        final restored = StopSequence.fromJson(json);
        expect(restored, equals(original));
      });
    });
  });
}
