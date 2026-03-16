import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CodeExecution', () {
    test('fromJson creates instance from empty map', () {
      final result = CodeExecution.fromJson({});
      expect(result, isA<CodeExecution>());
    });

    test('fromJson creates instance from non-empty map', () {
      final result = CodeExecution.fromJson({'extra': 'field'});
      expect(result, isA<CodeExecution>());
    });

    test('toJson returns empty map', () {
      const execution = CodeExecution();
      expect(execution.toJson(), isEmpty);
    });

    test('round-trip conversion works', () {
      const original = CodeExecution();
      final json = original.toJson();
      final restored = CodeExecution.fromJson(json);
      expect(restored.toJson(), original.toJson());
    });

    test('toString returns expected value', () {
      const execution = CodeExecution();
      expect(execution.toString(), 'CodeExecution()');
    });
  });
}
