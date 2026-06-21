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
    });

    test('constructor with all fields', () {
      const usage = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        promptAudioSeconds: 3,
      );
      expect(usage.promptAudioSeconds, 3);
    });

    test('fromJson with all fields', () {
      final usage = UsageInfo.fromJson(const {
        'prompt_tokens': 10,
        'completion_tokens': 20,
        'total_tokens': 30,
        'prompt_audio_seconds': 3,
      });
      expect(usage.promptTokens, 10);
      expect(usage.completionTokens, 20);
      expect(usage.totalTokens, 30);
      expect(usage.promptAudioSeconds, 3);
    });

    test('fromJson with missing optional fields', () {
      final usage = UsageInfo.fromJson(const {
        'prompt_tokens': 10,
        'completion_tokens': 20,
        'total_tokens': 30,
      });
      expect(usage.promptAudioSeconds, isNull);
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
    });

    test('toJson includes non-null optional fields', () {
      const usage = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        promptAudioSeconds: 3,
      );
      final json = usage.toJson();
      expect(json['prompt_audio_seconds'], 3);
    });

    test('copyWith clears nullable field', () {
      const usage = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        promptAudioSeconds: 3,
      );
      expect(usage.copyWith(promptAudioSeconds: null).promptAudioSeconds, null);
      expect(usage.copyWith(completionTokens: 99).completionTokens, 99);
      expect(usage.copyWith().promptAudioSeconds, 3);
    });

    test('equality comparing all fields', () {
      const a = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        promptAudioSeconds: 3,
      );
      const b = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        promptAudioSeconds: 3,
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
      const usage = UsageInfo(
        promptTokens: 10,
        completionTokens: 20,
        totalTokens: 30,
        promptAudioSeconds: 3,
      );
      final str = usage.toString();
      expect(str, contains('promptTokens: 10'));
      expect(str, contains('completionTokens: 20'));
      expect(str, contains('totalTokens: 30'));
      expect(str, contains('promptAudioSeconds: 3'));
    });
  });
}
