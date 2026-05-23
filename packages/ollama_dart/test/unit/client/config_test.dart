import 'package:ollama_dart/src/client/config.dart';
import 'package:test/test.dart';

void main() {
  group('OllamaConfig', () {
    test('sendRequestIdHeader defaults to false', () {
      const config = OllamaConfig();

      expect(config.sendRequestIdHeader, isFalse);
    });

    test('copyWith overrides sendRequestIdHeader', () {
      const config = OllamaConfig();

      final updated = config.copyWith(sendRequestIdHeader: true);

      expect(updated.sendRequestIdHeader, isTrue);
    });

    test('copyWith preserves sendRequestIdHeader when not provided', () {
      const config = OllamaConfig(sendRequestIdHeader: true);

      final updated = config.copyWith(baseUrl: 'http://example.com');

      expect(updated.sendRequestIdHeader, isTrue);
      expect(updated.baseUrl, 'http://example.com');
    });
  });
}
