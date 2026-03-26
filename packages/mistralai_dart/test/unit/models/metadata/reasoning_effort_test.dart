import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ReasoningEffort', () {
    test('has expected values', () {
      expect(ReasoningEffort.values, hasLength(2));
      expect(ReasoningEffort.high.value, 'high');
      expect(ReasoningEffort.none.value, 'none');
    });

    test('fromString returns high for "high"', () {
      expect(ReasoningEffort.fromString('high'), ReasoningEffort.high);
    });

    test('fromString returns none for "none"', () {
      expect(ReasoningEffort.fromString('none'), ReasoningEffort.none);
    });

    test('fromString returns null for null', () {
      expect(ReasoningEffort.fromString(null), isNull);
    });

    test('value round-trip', () {
      expect(ReasoningEffort.high.value, 'high');
      expect(ReasoningEffort.none.value, 'none');
    });
  });
}
