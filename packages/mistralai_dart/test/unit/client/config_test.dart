import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('MistralConfig', () {
    test('sendRequestIdHeader defaults to false', () {
      const config = MistralConfig();

      expect(config.sendRequestIdHeader, isFalse);
    });

    test('copyWith overrides sendRequestIdHeader', () {
      const config = MistralConfig();

      final updated = config.copyWith(sendRequestIdHeader: true);

      expect(updated.sendRequestIdHeader, isTrue);
    });

    test('copyWith preserves sendRequestIdHeader when not provided', () {
      const config = MistralConfig(sendRequestIdHeader: true);

      final updated = config.copyWith(baseUrl: 'https://example.com');

      expect(updated.sendRequestIdHeader, isTrue);
      expect(updated.baseUrl, 'https://example.com');
    });
  });
}
