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
      expect(usage.promptAudioSeconds, isNull);
      expect(usage.numCachedTokens, isNull);
      expect(usage.promptTokensDetails, isNull);
      expect(usage.promptTokenDetails, isNull);
      expect(usage.completionTokensDetails, isNull);
    });

    test('constructor with all fields', () {
      const usage = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        promptAudioSeconds: 3,
        numCachedTokens: 8,
        promptTokensDetails: PromptTokensDetails(cachedTokens: 8),
        promptTokenDetails: PromptTokensDetails(cachedTokens: 8),
        completionTokensDetails: CompletionTokensDetails(reasoningTokens: 5),
      );
      expect(usage.promptAudioSeconds, 3);
      expect(usage.numCachedTokens, 8);
      expect(usage.promptTokensDetails?.cachedTokens, 8);
      expect(usage.promptTokenDetails?.cachedTokens, 8);
      expect(usage.completionTokensDetails?.reasoningTokens, 5);
    });

    test('fromJson with all fields', () {
      final usage = UsageInfo.fromJson(const {
        'prompt_tokens': 10,
        'completion_tokens': 20,
        'total_tokens': 30,
        'prompt_audio_seconds': 3,
        'num_cached_tokens': 8,
        'prompt_tokens_details': {'cached_tokens': 8},
        'prompt_token_details': {'cached_tokens': 8},
        'completion_tokens_details': {'reasoning_tokens': 5},
      });
      expect(usage.promptTokens, 10);
      expect(usage.completionTokens, 20);
      expect(usage.totalTokens, 30);
      expect(usage.promptAudioSeconds, 3);
      expect(usage.numCachedTokens, 8);
      expect(
        usage.promptTokensDetails,
        const PromptTokensDetails(cachedTokens: 8),
      );
      expect(
        usage.promptTokenDetails,
        const PromptTokensDetails(cachedTokens: 8),
      );
      expect(
        usage.completionTokensDetails,
        const CompletionTokensDetails(reasoningTokens: 5),
      );
    });

    test('fromJson parses a chat completion usage payload', () {
      final usage = UsageInfo.fromJson(const {
        'prompt_tokens': 1066,
        'total_tokens': 1100,
        'completion_tokens': 34,
        'prompt_tokens_details': {'cached_tokens': 1038},
        'completion_tokens_details': {'reasoning_tokens': 0},
        'service_tier': 'standard',
      });
      expect(usage.promptTokens, 1066);
      expect(usage.completionTokens, 34);
      expect(usage.totalTokens, 1100);
      expect(usage.promptTokensDetails?.cachedTokens, 1038);
      expect(usage.completionTokensDetails?.reasoningTokens, 0);
    });

    test('fromJson with missing optional fields', () {
      final usage = UsageInfo.fromJson(const {
        'prompt_tokens': 10,
        'completion_tokens': 20,
        'total_tokens': 30,
      });
      expect(usage.promptAudioSeconds, isNull);
      expect(usage.numCachedTokens, isNull);
      expect(usage.promptTokensDetails, isNull);
      expect(usage.promptTokenDetails, isNull);
      expect(usage.completionTokensDetails, isNull);
    });

    test('fromJson with null detail objects', () {
      final usage = UsageInfo.fromJson(const {
        'prompt_tokens': 10,
        'completion_tokens': 20,
        'total_tokens': 30,
        'prompt_tokens_details': null,
        'completion_tokens_details': null,
      });
      expect(usage.promptTokensDetails, isNull);
      expect(usage.completionTokensDetails, isNull);
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
      expect(json.containsKey('prompt_audio_seconds'), isFalse);
      expect(json.containsKey('num_cached_tokens'), isFalse);
      expect(json.containsKey('prompt_tokens_details'), isFalse);
      expect(json.containsKey('prompt_token_details'), isFalse);
      expect(json.containsKey('completion_tokens_details'), isFalse);
    });

    test('toJson includes non-null optional fields', () {
      const usage = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        promptAudioSeconds: 3,
        numCachedTokens: 8,
        promptTokensDetails: PromptTokensDetails(cachedTokens: 8),
        promptTokenDetails: PromptTokensDetails(cachedTokens: 8),
        completionTokensDetails: CompletionTokensDetails(reasoningTokens: 5),
      );
      final json = usage.toJson();
      expect(json['prompt_audio_seconds'], 3);
      expect(json['num_cached_tokens'], 8);
      expect(json['prompt_tokens_details'], {'cached_tokens': 8});
      expect(json['prompt_token_details'], {'cached_tokens': 8});
      expect(json['completion_tokens_details'], {'reasoning_tokens': 5});
    });

    test('round-trip fromJson(toJson()) produces equal object', () {
      const original = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        numCachedTokens: 8,
        promptTokensDetails: PromptTokensDetails(cachedTokens: 8),
        completionTokensDetails: CompletionTokensDetails(reasoningTokens: 5),
      );
      expect(UsageInfo.fromJson(original.toJson()), original);
    });

    test('copyWith clears nullable field', () {
      const usage = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        promptAudioSeconds: 3,
        numCachedTokens: 8,
        promptTokensDetails: PromptTokensDetails(cachedTokens: 8),
        promptTokenDetails: PromptTokensDetails(cachedTokens: 8),
        completionTokensDetails: CompletionTokensDetails(reasoningTokens: 5),
      );
      expect(usage.copyWith(promptAudioSeconds: null).promptAudioSeconds, null);
      expect(usage.copyWith(numCachedTokens: null).numCachedTokens, null);
      expect(
        usage.copyWith(promptTokensDetails: null).promptTokensDetails,
        null,
      );
      expect(usage.copyWith(promptTokenDetails: null).promptTokenDetails, null);
      expect(
        usage.copyWith(completionTokensDetails: null).completionTokensDetails,
        null,
      );
      expect(usage.copyWith(completionTokens: 99).completionTokens, 99);
      expect(usage.copyWith().promptAudioSeconds, 3);
      expect(usage.copyWith().promptTokensDetails?.cachedTokens, 8);
      expect(usage.copyWith().completionTokensDetails?.reasoningTokens, 5);
    });

    test('copyWith replaces detail objects', () {
      const usage = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
      );
      final copied = usage.copyWith(
        promptTokensDetails: const PromptTokensDetails(cachedTokens: 4),
        completionTokensDetails: const CompletionTokensDetails(
          reasoningTokens: 2,
        ),
      );
      expect(copied.promptTokensDetails?.cachedTokens, 4);
      expect(copied.completionTokensDetails?.reasoningTokens, 2);
    });

    test('equality comparing all fields', () {
      const a = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        promptAudioSeconds: 3,
        numCachedTokens: 8,
        promptTokensDetails: PromptTokensDetails(cachedTokens: 8),
        completionTokensDetails: CompletionTokensDetails(reasoningTokens: 5),
      );
      const b = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        promptAudioSeconds: 3,
        numCachedTokens: 8,
        promptTokensDetails: PromptTokensDetails(cachedTokens: 8),
        completionTokensDetails: CompletionTokensDetails(reasoningTokens: 5),
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);

      const c = UsageInfo(
        promptTokens: 99,
        completionTokens: 20,
        totalTokens: 30,
      );
      expect(a, isNot(c));

      const d = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        promptAudioSeconds: 3,
        numCachedTokens: 8,
        promptTokensDetails: PromptTokensDetails(cachedTokens: 0),
        completionTokensDetails: CompletionTokensDetails(reasoningTokens: 5),
      );
      expect(a, isNot(d));
    });

    test('toString includes all field names', () {
      const usage = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        promptAudioSeconds: 3,
        numCachedTokens: 8,
        promptTokensDetails: PromptTokensDetails(cachedTokens: 8),
        promptTokenDetails: PromptTokensDetails(cachedTokens: 8),
        completionTokensDetails: CompletionTokensDetails(reasoningTokens: 5),
      );
      final str = usage.toString();
      expect(str, contains('promptTokens: 10'));
      expect(str, contains('completionTokens: 20'));
      expect(str, contains('totalTokens: 30'));
      expect(str, contains('promptAudioSeconds: 3'));
      expect(str, contains('numCachedTokens: 8'));
      expect(str, contains('promptTokensDetails: '));
      expect(str, contains('promptTokenDetails: '));
      expect(str, contains('completionTokensDetails: '));
    });
  });
}
