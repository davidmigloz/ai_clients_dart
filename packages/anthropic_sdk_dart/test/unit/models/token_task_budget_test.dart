import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TokenTaskBudget', () {
    test('round-trips with remaining', () {
      const budget = TokenTaskBudget(total: 32768, remaining: 16000);
      final json = budget.toJson();

      expect(json, {'type': 'tokens', 'total': 32768, 'remaining': 16000});

      final parsed = TokenTaskBudget.fromJson(json);
      expect(parsed, equals(budget));
    });

    test('omits remaining when null', () {
      const budget = TokenTaskBudget(total: 32768);
      final json = budget.toJson();

      expect(json.containsKey('remaining'), isFalse);

      final parsed = TokenTaskBudget.fromJson(json);
      expect(parsed.total, 32768);
      expect(parsed.remaining, isNull);
    });

    test('copyWith clears remaining', () {
      const budget = TokenTaskBudget(total: 32768, remaining: 1000);
      final cleared = budget.copyWith(remaining: null);

      expect(cleared.remaining, isNull);
      expect(cleared.total, 32768);
    });
  });

  group('OutputConfig', () {
    test('round-trips task_budget', () {
      const config = OutputConfig(
        effort: EffortLevel.xhigh,
        taskBudget: TokenTaskBudget(total: 8192),
      );
      final json = config.toJson();

      expect(json['effort'], 'xhigh');
      expect(json['task_budget'], {'type': 'tokens', 'total': 8192});

      final parsed = OutputConfig.fromJson(json);
      expect(parsed, equals(config));
    });
  });

  group('MessageCreateRequest.userProfileId', () {
    test('serializes user_profile_id when set', () {
      final request = MessageCreateRequest(
        model: 'claude-opus-4-7',
        messages: [InputMessage.user('hi')],
        maxTokens: 16,
        userProfileId: 'uprof_abc123',
      );

      final json = request.toJson();
      expect(json['user_profile_id'], 'uprof_abc123');

      final parsed = MessageCreateRequest.fromJson(json);
      expect(parsed.userProfileId, 'uprof_abc123');
    });

    test('omits user_profile_id when null', () {
      final request = MessageCreateRequest(
        model: 'claude-opus-4-7',
        messages: [InputMessage.user('hi')],
        maxTokens: 16,
      );

      expect(request.toJson().containsKey('user_profile_id'), isFalse);
    });
  });
}
