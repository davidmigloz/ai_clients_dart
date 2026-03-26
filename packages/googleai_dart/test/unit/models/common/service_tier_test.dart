import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ServiceTier', () {
    group('serviceTierFromString', () {
      test('converts known values', () {
        expect(serviceTierFromString('unspecified'), ServiceTier.unspecified);
        expect(serviceTierFromString('standard'), ServiceTier.standard);
        expect(serviceTierFromString('flex'), ServiceTier.flex);
        expect(serviceTierFromString('priority'), ServiceTier.priority);
      });

      test('converts null to unspecified', () {
        expect(serviceTierFromString(null), ServiceTier.unspecified);
      });

      test('converts unknown value to unspecified', () {
        expect(serviceTierFromString('UNKNOWN'), ServiceTier.unspecified);
        expect(serviceTierFromString('other'), ServiceTier.unspecified);
      });
    });

    group('serviceTierToString', () {
      test('converts all values', () {
        expect(serviceTierToString(ServiceTier.unspecified), 'unspecified');
        expect(serviceTierToString(ServiceTier.standard), 'standard');
        expect(serviceTierToString(ServiceTier.flex), 'flex');
        expect(serviceTierToString(ServiceTier.priority), 'priority');
      });
    });

    test('round-trip conversion preserves value', () {
      for (final tier in ServiceTier.values) {
        final str = serviceTierToString(tier);
        final converted = serviceTierFromString(str);
        expect(converted, tier);
      }
    });
  });
}
