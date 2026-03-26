import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('UsageInfo', () {
    test('constructor with required fields only', () {
      const usage = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
      );
      expect(usage.promptTokens, 10);
      expect(usage.completionTokens, 20);
      expect(usage.totalTokens, 30);
      expect(usage.numCachedTokens, isNull);
      expect(usage.promptAudioSeconds, isNull);
      expect(usage.promptTokenDetails, isNull);
      expect(usage.promptTokensDetails, isNull);
    });

    test('constructor with all fields', () {
      const details = PromptTokensDetails(cachedTokens: 10);
      const usage = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        numCachedTokens: 5,
        promptAudioSeconds: 3,
        promptTokenDetails: details,
        promptTokensDetails: details,
      );
      expect(usage.numCachedTokens, 5);
      expect(usage.promptAudioSeconds, 3);
      expect(usage.promptTokenDetails, details);
      expect(usage.promptTokensDetails, details);
    });

    test('fromJson with all fields', () {
      final usage = UsageInfo.fromJson(const {
        'prompt_tokens': 10,
        'completion_tokens': 20,
        'total_tokens': 30,
        'num_cached_tokens': 5,
        'prompt_audio_seconds': 3,
        'prompt_token_details': {'cached_tokens': 10},
        'prompt_tokens_details': {'cached_tokens': 10},
      });
      expect(usage.promptTokens, 10);
      expect(usage.completionTokens, 20);
      expect(usage.totalTokens, 30);
      expect(usage.numCachedTokens, 5);
      expect(usage.promptAudioSeconds, 3);
      expect(
        usage.promptTokenDetails,
        const PromptTokensDetails(cachedTokens: 10),
      );
      expect(
        usage.promptTokensDetails,
        const PromptTokensDetails(cachedTokens: 10),
      );
    });

    test('fromJson with missing optional fields', () {
      final usage = UsageInfo.fromJson(const {
        'prompt_tokens': 10,
        'completion_tokens': 20,
        'total_tokens': 30,
      });
      expect(usage.numCachedTokens, isNull);
      expect(usage.promptAudioSeconds, isNull);
      expect(usage.promptTokenDetails, isNull);
      expect(usage.promptTokensDetails, isNull);
    });

    test('toJson omits null optional fields', () {
      const usage = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
      );
      final json = usage.toJson();
      expect(json, {
        'prompt_tokens': 10,
        'completion_tokens': 20,
        'total_tokens': 30,
      });
      expect(json.containsKey('num_cached_tokens'), isFalse);
      expect(json.containsKey('prompt_audio_seconds'), isFalse);
      expect(json.containsKey('prompt_token_details'), isFalse);
      expect(json.containsKey('prompt_tokens_details'), isFalse);
    });

    test('toJson includes non-null optional fields', () {
      const details = PromptTokensDetails(cachedTokens: 10);
      const usage = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        numCachedTokens: 5,
        promptAudioSeconds: 3,
        promptTokenDetails: details,
        promptTokensDetails: details,
      );
      final json = usage.toJson();
      expect(json['num_cached_tokens'], 5);
      expect(json['prompt_audio_seconds'], 3);
      expect(json['prompt_token_details'], {'cached_tokens': 10});
      expect(json['prompt_tokens_details'], {'cached_tokens': 10});
    });

    test('equality comparing all fields', () {
      const details = PromptTokensDetails(cachedTokens: 10);
      const a = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        numCachedTokens: 5,
        promptAudioSeconds: 3,
        promptTokenDetails: details,
        promptTokensDetails: details,
      );
      const b = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        numCachedTokens: 5,
        promptAudioSeconds: 3,
        promptTokenDetails: details,
        promptTokensDetails: details,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);

      const c = UsageInfo(
        promptTokens: 99,
        completionTokens: 20,
        totalTokens: 30,
      );
      expect(a, isNot(c));
    });

    test('toString includes all field names', () {
      const details = PromptTokensDetails(cachedTokens: 10);
      const usage = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        numCachedTokens: 5,
        promptAudioSeconds: 3,
        promptTokenDetails: details,
        promptTokensDetails: details,
      );
      final str = usage.toString();
      expect(str, contains('promptTokens: 10'));
      expect(str, contains('completionTokens: 20'));
      expect(str, contains('totalTokens: 30'));
      expect(str, contains('numCachedTokens: 5'));
      expect(str, contains('promptAudioSeconds: 3'));
      expect(str, contains('promptTokenDetails:'));
      expect(str, contains('promptTokensDetails:'));
    });
  });
}
