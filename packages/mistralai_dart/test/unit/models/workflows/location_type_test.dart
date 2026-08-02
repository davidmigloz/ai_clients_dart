import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('LocationType', () {
    test('has expected values with correct string representations', () {
      expect(LocationType.local.value, 'local');
      expect(LocationType.k8s.value, 'k8s');
      expect(LocationType.managed.value, 'managed');
    });

    test('fromJson returns correct enum for each valid value', () {
      expect(LocationType.fromJson('local'), LocationType.local);
      expect(LocationType.fromJson('k8s'), LocationType.k8s);
      expect(LocationType.fromJson('managed'), LocationType.managed);
    });

    test('fromJson returns unknown for null input', () {
      expect(LocationType.fromJson(null), LocationType.unknown);
    });

    test('fromJson returns unknown for unrecognized value', () {
      expect(LocationType.fromJson('cloud'), LocationType.unknown);
    });

    test('toJson returns the string value', () {
      expect(LocationType.managed.toJson(), 'managed');
    });

    test('value round-trips through fromJson', () {
      for (final type in LocationType.values) {
        expect(LocationType.fromJson(type.value), type);
      }
    });
  });
}
