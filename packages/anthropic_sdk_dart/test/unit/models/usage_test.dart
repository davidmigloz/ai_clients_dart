import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('IterationUsage', () {
    test('fromJson parses message iteration without model', () {
      final json = {
        'type': 'message',
        'input_tokens': 412,
        'output_tokens': 89,
        'cache_creation_input_tokens': 0,
        'cache_read_input_tokens': 0,
      };
      final usage = IterationUsage.fromJson(json);

      expect(usage.type, 'message');
      expect(usage.inputTokens, 412);
      expect(usage.outputTokens, 89);
      expect(usage.model, isNull);
    });

    test('fromJson parses advisor_message iteration with model', () {
      final json = {
        'type': 'advisor_message',
        'model': 'claude-opus-4-8',
        'input_tokens': 823,
        'output_tokens': 1612,
        'cache_creation_input_tokens': 0,
        'cache_read_input_tokens': 0,
      };
      final usage = IterationUsage.fromJson(json);

      expect(usage.type, 'advisor_message');
      expect(usage.model, 'claude-opus-4-8');
      expect(usage.inputTokens, 823);
      expect(usage.outputTokens, 1612);
    });

    test('toJson includes model when set', () {
      const usage = IterationUsage(
        type: 'advisor_message',
        inputTokens: 100,
        outputTokens: 200,
        model: 'claude-opus-4-8',
      );
      final json = usage.toJson();

      expect(json['type'], 'advisor_message');
      expect(json['model'], 'claude-opus-4-8');
    });

    test('toJson omits model when null', () {
      const usage = IterationUsage(
        type: 'message',
        inputTokens: 100,
        outputTokens: 200,
      );
      final json = usage.toJson();

      expect(json.containsKey('model'), isFalse);
    });

    test('round-trip advisor_message iteration', () {
      final original = {
        'type': 'advisor_message',
        'model': 'claude-opus-4-8',
        'input_tokens': 823,
        'output_tokens': 1612,
        'cache_creation_input_tokens': 0,
        'cache_read_input_tokens': 0,
      };
      final usage = IterationUsage.fromJson(original);
      expect(usage.toJson(), original);
    });

    test('equality includes model field', () {
      const a = IterationUsage(
        type: 'advisor_message',
        inputTokens: 100,
        outputTokens: 200,
        model: 'claude-opus-4-8',
      );
      const b = IterationUsage(
        type: 'advisor_message',
        inputTokens: 100,
        outputTokens: 200,
        model: 'claude-opus-4-8',
      );
      const c = IterationUsage(
        type: 'advisor_message',
        inputTokens: 100,
        outputTokens: 200,
        model: 'claude-sonnet-4-6',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('copyWith model field', () {
      const original = IterationUsage(
        type: 'advisor_message',
        inputTokens: 100,
        outputTokens: 200,
        model: 'claude-opus-4-8',
      );

      final changed = original.copyWith(model: 'claude-sonnet-4-6');
      expect(changed.model, 'claude-sonnet-4-6');

      final cleared = original.copyWith(model: null);
      expect(cleared.model, isNull);
    });
  });

  group('Usage with advisor iterations', () {
    test('parses Usage with mixed iterations array', () {
      final json = {
        'input_tokens': 412,
        'output_tokens': 531,
        'iterations': [
          {
            'type': 'message',
            'input_tokens': 412,
            'output_tokens': 89,
            'cache_creation_input_tokens': 0,
            'cache_read_input_tokens': 0,
          },
          {
            'type': 'advisor_message',
            'model': 'claude-opus-4-8',
            'input_tokens': 823,
            'output_tokens': 1612,
            'cache_creation_input_tokens': 0,
            'cache_read_input_tokens': 0,
          },
          {
            'type': 'message',
            'input_tokens': 1348,
            'output_tokens': 442,
            'cache_creation_input_tokens': 0,
            'cache_read_input_tokens': 412,
          },
        ],
      };
      final usage = Usage.fromJson(json);

      expect(usage.iterations, isNotNull);
      expect(usage.iterations!.length, 3);

      expect(usage.iterations![0].type, 'message');
      expect(usage.iterations![0].model, isNull);

      expect(usage.iterations![1].type, 'advisor_message');
      expect(usage.iterations![1].model, 'claude-opus-4-8');
      expect(usage.iterations![1].inputTokens, 823);

      expect(usage.iterations![2].type, 'message');
      expect(usage.iterations![2].cacheReadInputTokens, 412);
    });
  });

  group('OutputTokensDetails', () {
    test('fromJson/toJson round-trip', () {
      final json = {'thinking_tokens': 128};
      final details = OutputTokensDetails.fromJson(json);
      expect(details.thinkingTokens, 128);
      expect(details.toJson(), json);
    });

    test('defaults thinkingTokens to 0 when absent', () {
      final json = <String, dynamic>{};
      final details = OutputTokensDetails.fromJson(json);
      expect(details.thinkingTokens, 0);
    });

    test('copyWith and equality', () {
      const a = OutputTokensDetails(thinkingTokens: 10);
      expect(a.copyWith(thinkingTokens: 20).thinkingTokens, 20);
      expect(a, const OutputTokensDetails(thinkingTokens: 10));
      expect(
        a.hashCode,
        const OutputTokensDetails(thinkingTokens: 10).hashCode,
      );
      expect(a, isNot(const OutputTokensDetails(thinkingTokens: 20)));
      expect(a.toString(), contains('thinkingTokens: 10'));
    });
  });

  group('Usage.outputTokensDetails', () {
    test('parses and round-trips outputTokensDetails', () {
      final json = {
        'input_tokens': 10,
        'output_tokens': 200,
        'output_tokens_details': {'thinking_tokens': 150},
      };
      final usage = Usage.fromJson(json);
      expect(usage.outputTokensDetails, isNotNull);
      expect(usage.outputTokensDetails!.thinkingTokens, 150);
      expect(usage.toJson(), json);
    });

    test('omits output_tokens_details when null', () {
      const usage = Usage(inputTokens: 10, outputTokens: 20);
      expect(usage.toJson().containsKey('output_tokens_details'), isFalse);
    });

    test('copyWith updates and clears outputTokensDetails', () {
      const usage = Usage(
        inputTokens: 10,
        outputTokens: 20,
        outputTokensDetails: OutputTokensDetails(thinkingTokens: 5),
      );
      final updated = usage.copyWith(
        outputTokensDetails: const OutputTokensDetails(thinkingTokens: 9),
      );
      expect(updated.outputTokensDetails!.thinkingTokens, 9);
      expect(
        usage.copyWith(outputTokensDetails: null).outputTokensDetails,
        isNull,
      );
    });

    test('equality and toString include outputTokensDetails', () {
      const a = Usage(
        inputTokens: 10,
        outputTokens: 20,
        outputTokensDetails: OutputTokensDetails(thinkingTokens: 5),
      );
      const b = Usage(inputTokens: 10, outputTokens: 20);
      expect(a, isNot(b));
      expect(a.toString(), contains('outputTokensDetails'));
    });
  });

  group('MessageDeltaUsage.outputTokensDetails', () {
    test('parses and round-trips outputTokensDetails', () {
      final json = {
        'output_tokens': 80,
        'output_tokens_details': {'thinking_tokens': 40},
      };
      final usage = MessageDeltaUsage.fromJson(json);
      expect(usage.outputTokensDetails!.thinkingTokens, 40);
      expect(usage.toJson(), json);
    });

    test('omits output_tokens_details when null', () {
      const usage = MessageDeltaUsage(outputTokens: 80);
      expect(usage.toJson().containsKey('output_tokens_details'), isFalse);
    });

    test('copyWith clears outputTokensDetails', () {
      const usage = MessageDeltaUsage(
        outputTokens: 80,
        outputTokensDetails: OutputTokensDetails(thinkingTokens: 5),
      );
      expect(
        usage.copyWith(outputTokensDetails: null).outputTokensDetails,
        isNull,
      );
    });
  });

  group('Usage.fallbackCredit', () {
    test('parses and round-trips a redeemed fallbackCredit', () {
      final json = {
        'input_tokens': 10,
        'output_tokens': 20,
        'fallback_credit': {
          'status': {'type': 'redeemed'},
        },
      };
      final usage = Usage.fromJson(json);
      expect(usage.fallbackCredit, isNotNull);
      expect(usage.fallbackCredit!.status, isA<FallbackCreditRedeemed>());
      expect(usage.toJson(), json);
    });

    test('parses and round-trips a not_applied fallbackCredit', () {
      final json = {
        'input_tokens': 10,
        'output_tokens': 20,
        'fallback_credit': {
          'status': {'type': 'not_applied', 'reason': 'expired'},
        },
      };
      final usage = Usage.fromJson(json);
      final status = usage.fallbackCredit!.status as FallbackCreditNotApplied;
      expect(status.reason, FallbackCreditNotAppliedReason.expired);
      expect(usage.toJson(), json);
    });

    test('omits fallback_credit when null', () {
      const usage = Usage(inputTokens: 10, outputTokens: 20);
      expect(usage.toJson().containsKey('fallback_credit'), isFalse);
    });

    test('copyWith updates and clears fallbackCredit', () {
      const usage = Usage(
        inputTokens: 10,
        outputTokens: 20,
        fallbackCredit: FallbackCreditUsage(status: FallbackCreditRedeemed()),
      );
      final updated = usage.copyWith(
        fallbackCredit: const FallbackCreditUsage(
          status: FallbackCreditNotApplied(
            reason: FallbackCreditNotAppliedReason.notEnabled,
          ),
        ),
      );
      expect(updated.fallbackCredit!.status, isA<FallbackCreditNotApplied>());
      expect(usage.copyWith(fallbackCredit: null).fallbackCredit, isNull);
    });

    test('equality and toString include fallbackCredit', () {
      const a = Usage(
        inputTokens: 10,
        outputTokens: 20,
        fallbackCredit: FallbackCreditUsage(status: FallbackCreditRedeemed()),
      );
      const b = Usage(inputTokens: 10, outputTokens: 20);
      expect(a, isNot(b));
      expect(a.toString(), contains('fallbackCredit'));
    });
  });

  group('MessageDeltaUsage.fallbackCredit', () {
    test('parses and round-trips fallbackCredit', () {
      final json = {
        'output_tokens': 80,
        'fallback_credit': {
          'status': {'type': 'redeemed'},
        },
      };
      final usage = MessageDeltaUsage.fromJson(json);
      expect(usage.fallbackCredit!.status, isA<FallbackCreditRedeemed>());
      expect(usage.toJson(), json);
    });

    test('omits fallback_credit when null', () {
      const usage = MessageDeltaUsage(outputTokens: 80);
      expect(usage.toJson().containsKey('fallback_credit'), isFalse);
    });

    test('copyWith clears fallbackCredit', () {
      const usage = MessageDeltaUsage(
        outputTokens: 80,
        fallbackCredit: FallbackCreditUsage(status: FallbackCreditRedeemed()),
      );
      expect(usage.copyWith(fallbackCredit: null).fallbackCredit, isNull);
    });
  });
}
