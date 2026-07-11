import 'package:openai_dart/src/models/moderations/moderation_policy.dart';
import 'package:test/test.dart';

void main() {
  group('ModerationMode', () {
    test('maps known values', () {
      expect(ModerationMode.fromJson('score'), ModerationMode.score);
      expect(ModerationMode.fromJson('block'), ModerationMode.block);
      expect(ModerationMode.score.toJson(), 'score');
      expect(ModerationMode.block.toJson(), 'block');
    });

    test('falls back to unknown for unrecognized values', () {
      expect(ModerationMode.fromJson('mystery'), ModerationMode.unknown);
    });
  });

  group('ModerationConfigParam', () {
    test('round-trips through JSON', () {
      const config = ModerationConfigParam(mode: ModerationMode.block);
      expect(config.toJson(), {'mode': 'block'});
      expect(ModerationConfigParam.fromJson(config.toJson()), config);
    });

    test('equality and hashCode', () {
      const a = ModerationConfigParam(mode: ModerationMode.score);
      const b = ModerationConfigParam(mode: ModerationMode.score);
      const c = ModerationConfigParam(mode: ModerationMode.block);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('copyWith replaces fields', () {
      const config = ModerationConfigParam(mode: ModerationMode.score);
      expect(
        config.copyWith(mode: ModerationMode.block).mode,
        ModerationMode.block,
      );
      expect(config.copyWith().mode, ModerationMode.score);
    });
  });

  group('ModerationPolicyParam', () {
    test('round-trips through JSON with both fields set', () {
      const policy = ModerationPolicyParam(
        input: ModerationConfigParam(mode: ModerationMode.score),
        output: ModerationConfigParam(mode: ModerationMode.block),
      );
      expect(policy.toJson(), {
        'input': {'mode': 'score'},
        'output': {'mode': 'block'},
      });
      expect(ModerationPolicyParam.fromJson(policy.toJson()), policy);
    });

    test('omits input and output when null', () {
      const policy = ModerationPolicyParam();
      expect(policy.toJson(), <String, dynamic>{});
      expect(ModerationPolicyParam.fromJson(const {}), policy);
    });

    test('round-trips with only input set', () {
      const policy = ModerationPolicyParam(
        input: ModerationConfigParam(mode: ModerationMode.block),
      );
      expect(policy.toJson(), {
        'input': {'mode': 'block'},
      });
      expect(ModerationPolicyParam.fromJson(policy.toJson()), policy);
    });

    test('equality and hashCode', () {
      const a = ModerationPolicyParam(
        input: ModerationConfigParam(mode: ModerationMode.score),
      );
      const b = ModerationPolicyParam(
        input: ModerationConfigParam(mode: ModerationMode.score),
      );
      const c = ModerationPolicyParam(
        input: ModerationConfigParam(mode: ModerationMode.block),
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('copyWith can set and clear fields explicitly', () {
      const policy = ModerationPolicyParam(
        input: ModerationConfigParam(mode: ModerationMode.score),
      );
      final withOutput = policy.copyWith(
        output: const ModerationConfigParam(mode: ModerationMode.block),
      );
      expect(withOutput.input, policy.input);
      expect(
        withOutput.output,
        const ModerationConfigParam(mode: ModerationMode.block),
      );

      final cleared = policy.copyWith(input: null);
      expect(cleared.input, isNull);
    });
  });
}
