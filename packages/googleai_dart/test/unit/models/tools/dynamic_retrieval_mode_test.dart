import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DynamicRetrievalMode', () {
    group('dynamicRetrievalModeFromString', () {
      test('parses MODE_DYNAMIC', () {
        expect(
          dynamicRetrievalModeFromString('MODE_DYNAMIC'),
          DynamicRetrievalMode.dynamic_,
        );
      });

      test('returns unspecified for MODE_UNSPECIFIED', () {
        expect(
          dynamicRetrievalModeFromString('MODE_UNSPECIFIED'),
          DynamicRetrievalMode.unspecified,
        );
      });

      test('returns unspecified for unknown value', () {
        expect(
          dynamicRetrievalModeFromString('UNKNOWN'),
          DynamicRetrievalMode.unspecified,
        );
      });

      test('returns unspecified for null', () {
        expect(
          dynamicRetrievalModeFromString(null),
          DynamicRetrievalMode.unspecified,
        );
      });
    });

    group('dynamicRetrievalModeToString', () {
      test('converts dynamic_', () {
        expect(
          dynamicRetrievalModeToString(DynamicRetrievalMode.dynamic_),
          'MODE_DYNAMIC',
        );
      });

      test('converts unspecified', () {
        expect(
          dynamicRetrievalModeToString(DynamicRetrievalMode.unspecified),
          'MODE_UNSPECIFIED',
        );
      });
    });

    test('round-trip conversion preserves value', () {
      for (final mode in DynamicRetrievalMode.values) {
        final str = dynamicRetrievalModeToString(mode);
        final restored = dynamicRetrievalModeFromString(str);
        expect(restored, mode);
      }
    });
  });
}
