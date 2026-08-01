import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DreamStatus', () {
    test('fromJson parses all known values', () {
      expect(DreamStatus.fromJson('pending'), DreamStatus.pending);
      expect(DreamStatus.fromJson('running'), DreamStatus.running);
      expect(DreamStatus.fromJson('completed'), DreamStatus.completed);
      expect(DreamStatus.fromJson('failed'), DreamStatus.failed);
      expect(DreamStatus.fromJson('canceled'), DreamStatus.canceled);
    });

    test('fromJson falls back to unknown for unrecognized values', () {
      expect(DreamStatus.fromJson('something_new'), DreamStatus.unknown);
    });

    test('toJson round-trips known values', () {
      for (final status in DreamStatus.values.where(
        (s) => s != DreamStatus.unknown,
      )) {
        expect(DreamStatus.fromJson(status.toJson()), status);
      }
    });
  });
}
