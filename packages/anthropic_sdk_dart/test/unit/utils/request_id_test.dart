import 'package:anthropic_sdk_dart/src/utils/request_id.dart';
import 'package:test/test.dart';

void main() {
  group('generateRequestId', () {
    test('generates non-empty string', () {
      final id = generateRequestId();

      expect(id, isNotEmpty);
    });

    test('generates unique IDs', () {
      final ids = <String>{};

      for (var i = 0; i < 100; i++) {
        ids.add(generateRequestId());
      }

      expect(ids, hasLength(100));
    });

    test('generates IDs with expected prefix', () {
      final id = generateRequestId();

      // Based on implementation, check format
      expect(id, matches(RegExp(r'^[a-z0-9]+')));
    });

    test('generates IDs of consistent length', () {
      final lengths = <int>{};

      for (var i = 0; i < 10; i++) {
        lengths.add(generateRequestId().length);
      }

      // All IDs should have the same length
      expect(lengths, hasLength(1));
    });

    test('generates IDs with only valid characters', () {
      final id = generateRequestId();

      // Should only contain alphanumeric and possibly dashes
      expect(id, matches(RegExp(r'^[a-zA-Z0-9-]+$')));
    });
  });
}
