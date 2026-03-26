import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('PromptTokensDetails', () {
    test('constructor sets cachedTokens', () {
      const details = PromptTokensDetails(cachedTokens: 100);
      expect(details.cachedTokens, 100);
    });

    test('fromJson parses cached_tokens', () {
      final details = PromptTokensDetails.fromJson(const {'cached_tokens': 50});
      expect(details.cachedTokens, 50);
    });

    test('fromJson defaults missing field to 0', () {
      final details = PromptTokensDetails.fromJson(const <String, dynamic>{});
      expect(details.cachedTokens, 0);
    });

    test('toJson produces expected map', () {
      const details = PromptTokensDetails(cachedTokens: 100);
      expect(details.toJson(), {'cached_tokens': 100});
    });

    test('round-trip fromJson(toJson()) produces equal object', () {
      const original = PromptTokensDetails(cachedTokens: 100);
      final roundTripped = PromptTokensDetails.fromJson(original.toJson());
      expect(roundTripped, original);
    });

    test('equality: same cachedTokens are equal', () {
      const a = PromptTokensDetails(cachedTokens: 100);
      const b = PromptTokensDetails(cachedTokens: 100);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('equality: different cachedTokens are not equal', () {
      const a = PromptTokensDetails(cachedTokens: 100);
      const b = PromptTokensDetails(cachedTokens: 200);
      expect(a, isNot(b));
    });

    test('toString contains cachedTokens value', () {
      const details = PromptTokensDetails(cachedTokens: 100);
      expect(details.toString(), contains('cachedTokens: 100'));
    });
  });
}
