import 'package:openai_dart/src/platform/environment.dart';
import 'package:test/test.dart';

void main() {
  group('getEnvironmentVariable', () {
    // Note: These tests run on IO platform where environment variables
    // are accessible. On web, getEnvironmentVariable throws UnsupportedError.

    test('returns null for non-existent variable', () {
      final result = getEnvironmentVariable(
        '_OPENAI_DART_TEST_NONEXISTENT_VAR_${DateTime.now().millisecondsSinceEpoch}',
      );
      expect(result, isNull);
    });

    test('returns value for existing variable', () {
      // PATH should exist on all IO platforms
      final result = getEnvironmentVariable('PATH');
      expect(result, isNotNull);
      expect(result, isNotEmpty);
    });

    test('returns HOME or USERPROFILE variable', () {
      // HOME exists on Unix, USERPROFILE on Windows
      final home = getEnvironmentVariable('HOME');
      final userProfile = getEnvironmentVariable('USERPROFILE');
      expect(home != null || userProfile != null, isTrue);
    });
  });
}
