import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CompletionTokensDetails', () {
    test('constructor sets reasoningTokens', () {
      const details = CompletionTokensDetails(reasoningTokens: 100);
      expect(details.reasoningTokens, 100);
    });

    test('fromJson parses reasoning_tokens', () {
      final details = CompletionTokensDetails.fromJson(const {
        'reasoning_tokens': 50,
      });
      expect(details.reasoningTokens, 50);
    });

    test('fromJson defaults missing field to 0', () {
      final details = CompletionTokensDetails.fromJson(
        const <String, dynamic>{},
      );
      expect(details.reasoningTokens, 0);
    });

    test('toJson produces expected map', () {
      const details = CompletionTokensDetails(reasoningTokens: 100);
      expect(details.toJson(), {'reasoning_tokens': 100});
    });

    test('round-trip fromJson(toJson()) produces equal object', () {
      const original = CompletionTokensDetails(reasoningTokens: 100);
      final roundTripped = CompletionTokensDetails.fromJson(original.toJson());
      expect(roundTripped, original);
    });

    test('copyWith replaces reasoningTokens', () {
      const details = CompletionTokensDetails(reasoningTokens: 100);
      expect(details.copyWith(reasoningTokens: 7).reasoningTokens, 7);
      expect(details.copyWith().reasoningTokens, 100);
    });

    test('equality: same reasoningTokens are equal', () {
      const a = CompletionTokensDetails(reasoningTokens: 100);
      const b = CompletionTokensDetails(reasoningTokens: 100);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('equality: different reasoningTokens are not equal', () {
      const a = CompletionTokensDetails(reasoningTokens: 100);
      const b = CompletionTokensDetails(reasoningTokens: 200);
      expect(a, isNot(b));
    });

    test('toString contains reasoningTokens value', () {
      const details = CompletionTokensDetails(reasoningTokens: 100);
      expect(details.toString(), contains('reasoningTokens: 100'));
    });
  });
}
