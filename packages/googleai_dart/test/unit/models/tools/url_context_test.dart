import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('UrlContext', () {
    test('fromJson creates instance from empty map', () {
      final result = UrlContext.fromJson({});
      expect(result, isA<UrlContext>());
    });

    test('fromJson creates instance from non-empty map', () {
      final result = UrlContext.fromJson({'extra': 'field'});
      expect(result, isA<UrlContext>());
    });

    test('toJson returns empty map', () {
      const context = UrlContext();
      expect(context.toJson(), isEmpty);
    });

    test('round-trip conversion works', () {
      const original = UrlContext();
      final json = original.toJson();
      final restored = UrlContext.fromJson(json);
      expect(restored.toJson(), original.toJson());
    });

    test('toString returns expected value', () {
      const context = UrlContext();
      expect(context.toString(), 'UrlContext()');
    });
  });
}
