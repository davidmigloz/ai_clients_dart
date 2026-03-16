import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ComputerUseEnvironment', () {
    group('computerUseEnvironmentFromString', () {
      test('parses ENVIRONMENT_BROWSER', () {
        expect(
          computerUseEnvironmentFromString('ENVIRONMENT_BROWSER'),
          ComputerUseEnvironment.browser,
        );
      });

      test('returns unspecified for ENVIRONMENT_UNSPECIFIED', () {
        expect(
          computerUseEnvironmentFromString('ENVIRONMENT_UNSPECIFIED'),
          ComputerUseEnvironment.unspecified,
        );
      });

      test('returns unspecified for unknown value', () {
        expect(
          computerUseEnvironmentFromString('UNKNOWN'),
          ComputerUseEnvironment.unspecified,
        );
      });

      test('returns unspecified for null', () {
        expect(
          computerUseEnvironmentFromString(null),
          ComputerUseEnvironment.unspecified,
        );
      });
    });

    group('computerUseEnvironmentToString', () {
      test('converts browser', () {
        expect(
          computerUseEnvironmentToString(ComputerUseEnvironment.browser),
          'ENVIRONMENT_BROWSER',
        );
      });

      test('converts unspecified', () {
        expect(
          computerUseEnvironmentToString(ComputerUseEnvironment.unspecified),
          'ENVIRONMENT_UNSPECIFIED',
        );
      });
    });

    test('round-trip conversion preserves value', () {
      for (final env in ComputerUseEnvironment.values) {
        final str = computerUseEnvironmentToString(env);
        final restored = computerUseEnvironmentFromString(str);
        expect(restored, env);
      }
    });
  });
}
