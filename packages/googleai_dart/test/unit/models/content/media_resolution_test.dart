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
    group('mediaResolutionLevelFromString', () {
      test('parses all known values', () {
        expect(
          mediaResolutionLevelFromString('MEDIA_RESOLUTION_LOW'),
          MediaResolutionLevel.low,
        );
        expect(
          mediaResolutionLevelFromString('MEDIA_RESOLUTION_MEDIUM'),
          MediaResolutionLevel.medium,
        );
        expect(
          mediaResolutionLevelFromString('MEDIA_RESOLUTION_HIGH'),
          MediaResolutionLevel.high,
        );
        expect(
          mediaResolutionLevelFromString('MEDIA_RESOLUTION_ULTRA_HIGH'),
          MediaResolutionLevel.ultraHigh,
        );
      });

      test('returns unspecified for unknown values', () {
        expect(
          mediaResolutionLevelFromString('UNKNOWN_VALUE'),
          MediaResolutionLevel.unspecified,
        );
      });

      test('returns unspecified for null', () {
        expect(
          mediaResolutionLevelFromString(null),
          MediaResolutionLevel.unspecified,
        );
      });

      test('is case-insensitive', () {
        expect(
          mediaResolutionLevelFromString('media_resolution_high'),
          MediaResolutionLevel.high,
        );
      });
    });

    group('mediaResolutionLevelToString', () {
      test('converts all enum values', () {
        expect(
          mediaResolutionLevelToString(MediaResolutionLevel.low),
          'MEDIA_RESOLUTION_LOW',
        );
        expect(
          mediaResolutionLevelToString(MediaResolutionLevel.ultraHigh),
          'MEDIA_RESOLUTION_ULTRA_HIGH',
        );
        expect(
          mediaResolutionLevelToString(MediaResolutionLevel.unspecified),
          'MEDIA_RESOLUTION_UNSPECIFIED',
        );
      });
    });

    test('round-trip conversion preserves all values', () {
      for (final level in MediaResolutionLevel.values) {
        final str = mediaResolutionLevelToString(level);
        final restored = mediaResolutionLevelFromString(str);
        expect(restored, level, reason: 'Failed for $level');
      }
    });
  });
}
