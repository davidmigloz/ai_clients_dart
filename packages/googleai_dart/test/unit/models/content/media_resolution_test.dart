import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('MediaResolution', () {
    test('fromJson parses level and numTokens', () {
      final json = {'level': 'MEDIA_RESOLUTION_HIGH', 'numTokens': 256};

      final resolution = MediaResolution.fromJson(json);

      expect(resolution.level, MediaResolutionLevel.high);
      expect(resolution.numTokens, 256);
    });

    test('fromJson handles null fields', () {
      final json = <String, dynamic>{};

      final resolution = MediaResolution.fromJson(json);

      expect(resolution.level, isNull);
      expect(resolution.numTokens, isNull);
    });

    test('toJson serializes level and numTokens', () {
      const resolution = MediaResolution(
        level: MediaResolutionLevel.medium,
        numTokens: 128,
      );

      final json = resolution.toJson();

      expect(json['level'], 'MEDIA_RESOLUTION_MEDIUM');
      expect(json['numTokens'], 128);
    });

    test('toJson omits null fields', () {
      const resolution = MediaResolution();

      final json = resolution.toJson();

      expect(json.containsKey('level'), isFalse);
      expect(json.containsKey('numTokens'), isFalse);
    });

    test('round-trip serialization preserves numTokens', () {
      final json = {'level': 'MEDIA_RESOLUTION_LOW', 'numTokens': 64};

      final resolution = MediaResolution.fromJson(json);
      final serialized = resolution.toJson();

      expect(serialized['level'], json['level']);
      expect(serialized['numTokens'], json['numTokens']);
    });

    test('copyWith replaces numTokens', () {
      const original = MediaResolution(
        level: MediaResolutionLevel.low,
        numTokens: 64,
      );

      final updated = original.copyWith(numTokens: 512);

      expect(updated.numTokens, 512);
      expect(updated.level, MediaResolutionLevel.low);
      expect(original.numTokens, 64);
    });
  });

  group('MediaResolutionLevel', () {
    test('fromString returns ultraHigh for MEDIA_RESOLUTION_ULTRA_HIGH', () {
      expect(
        MediaResolutionLevel.fromString('MEDIA_RESOLUTION_ULTRA_HIGH'),
        MediaResolutionLevel.ultraHigh,
      );
    });

    test('fromString falls back to unspecified for unknown values', () {
      expect(
        MediaResolutionLevel.fromString('UNKNOWN_VALUE'),
        MediaResolutionLevel.unspecified,
      );
    });
  });
}
