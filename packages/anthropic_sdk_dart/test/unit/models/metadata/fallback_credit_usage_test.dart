import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('FallbackCreditNotAppliedReason', () {
    test('fromJson maps all twelve known values', () {
      const expected = {
        'body_mismatch': FallbackCreditNotAppliedReason.bodyMismatch,
        'continuation_excluded':
            FallbackCreditNotAppliedReason.continuationExcluded,
        'continuation_only': FallbackCreditNotAppliedReason.continuationOnly,
        'expired': FallbackCreditNotAppliedReason.expired,
        'invalid_target_model':
            FallbackCreditNotAppliedReason.invalidTargetModel,
        'not_enabled': FallbackCreditNotAppliedReason.notEnabled,
        'reprice_unavailable':
            FallbackCreditNotAppliedReason.repriceUnavailable,
        'temporarily_unavailable':
            FallbackCreditNotAppliedReason.temporarilyUnavailable,
        'variant_fields_present':
            FallbackCreditNotAppliedReason.variantFieldsPresent,
        'wrong_organization': FallbackCreditNotAppliedReason.wrongOrganization,
        'wrong_platform': FallbackCreditNotAppliedReason.wrongPlatform,
        'wrong_workspace': FallbackCreditNotAppliedReason.wrongWorkspace,
      };

      for (final entry in expected.entries) {
        expect(
          FallbackCreditNotAppliedReason.fromJson(entry.key),
          entry.value,
          reason: entry.key,
        );
        expect(entry.value.toJson(), entry.key);
      }
    });

    test('fromJson falls back to unknown for unrecognized values', () {
      expect(
        FallbackCreditNotAppliedReason.fromJson('some_future_reason'),
        FallbackCreditNotAppliedReason.unknown,
      );
    });
  });

  group('FallbackCreditStatus', () {
    test('round-trips redeemed', () {
      const json = {'type': 'redeemed'};
      final status = FallbackCreditStatus.fromJson(json);
      expect(status, isA<FallbackCreditRedeemed>());
      expect(status.toJson(), json);
    });

    test('fromJson rejects a mismatched discriminator for redeemed', () {
      expect(
        () => FallbackCreditRedeemed.fromJson(const {'type': 'not_applied'}),
        throwsFormatException,
      );
    });

    test('round-trips not_applied without remove_to_redeem', () {
      final json = {'type': 'not_applied', 'reason': 'expired'};
      final status = FallbackCreditStatus.fromJson(json);
      expect(status, isA<FallbackCreditNotApplied>());
      final notApplied = status as FallbackCreditNotApplied;
      expect(notApplied.reason, FallbackCreditNotAppliedReason.expired);
      expect(notApplied.removeToRedeem, isNull);
      expect(status.toJson(), json);
    });

    test('round-trips not_applied with remove_to_redeem', () {
      final json = {
        'type': 'not_applied',
        'reason': 'variant_fields_present',
        'remove_to_redeem': ['top_p', 'top_k'],
      };
      final status = FallbackCreditStatus.fromJson(json);
      final notApplied = status as FallbackCreditNotApplied;
      expect(
        notApplied.reason,
        FallbackCreditNotAppliedReason.variantFieldsPresent,
      );
      expect(notApplied.removeToRedeem, ['top_p', 'top_k']);
      expect(status.toJson(), json);
    });

    test('fromJson rejects a mismatched discriminator for not_applied', () {
      expect(
        () => FallbackCreditNotApplied.fromJson(const {
          'type': 'redeemed',
          'reason': 'expired',
        }),
        throwsFormatException,
      );
    });

    test(
      'not_applied fromJson rejects a non-string remove_to_redeem entry',
      () {
        expect(
          () => FallbackCreditNotApplied.fromJson(const {
            'type': 'not_applied',
            'reason': 'variant_fields_present',
            'remove_to_redeem': [1, 2],
          }),
          throwsFormatException,
        );
      },
    );

    test('preserves an unrecognized status type verbatim', () {
      final json = {'type': 'some_future_status', 'extra': 'value'};
      final status = FallbackCreditStatus.fromJson(json);
      expect(status, isA<UnknownFallbackCreditStatus>());
      expect(status.toJson(), json);
    });

    test('not_applied copyWith replaces reason and clears removeToRedeem', () {
      const original = FallbackCreditNotApplied(
        reason: FallbackCreditNotAppliedReason.variantFieldsPresent,
        removeToRedeem: ['top_p'],
      );
      final changed = original.copyWith(
        reason: FallbackCreditNotAppliedReason.expired,
      );
      expect(changed.reason, FallbackCreditNotAppliedReason.expired);
      expect(changed.removeToRedeem, ['top_p']);

      final cleared = original.copyWith(removeToRedeem: null);
      expect(cleared.removeToRedeem, isNull);
      expect(cleared.reason, original.reason);
    });

    test('equality and hashCode for redeemed', () {
      const a = FallbackCreditRedeemed();
      const b = FallbackCreditRedeemed();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), 'FallbackCreditRedeemed()');
    });

    test('equality and hashCode for not_applied', () {
      const a = FallbackCreditNotApplied(
        reason: FallbackCreditNotAppliedReason.expired,
      );
      const b = FallbackCreditNotApplied(
        reason: FallbackCreditNotAppliedReason.expired,
      );
      const c = FallbackCreditNotApplied(
        reason: FallbackCreditNotAppliedReason.notEnabled,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a.toString(), contains('reason: FallbackCreditNotAppliedReason'));
    });

    test('equality and hashCode for unknown status', () {
      const a = UnknownFallbackCreditStatus(
        rawJson: {
          'type': 'x',
          'nested': {'k': 'v'},
        },
      );
      const b = UnknownFallbackCreditStatus(
        rawJson: {
          'type': 'x',
          'nested': {'k': 'v'},
        },
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('rawJson'));
    });
  });

  group('FallbackCreditUsage', () {
    test('round-trips with a redeemed status', () {
      final json = {
        'status': {'type': 'redeemed'},
      };
      final usage = FallbackCreditUsage.fromJson(json);
      expect(usage.status, isA<FallbackCreditRedeemed>());
      expect(usage.toJson(), json);
    });

    test('round-trips with a not_applied status', () {
      final json = {
        'status': {'type': 'not_applied', 'reason': 'wrong_workspace'},
      };
      final usage = FallbackCreditUsage.fromJson(json);
      final status = usage.status as FallbackCreditNotApplied;
      expect(status.reason, FallbackCreditNotAppliedReason.wrongWorkspace);
      expect(usage.toJson(), json);
    });

    test('copyWith replaces status', () {
      const usage = FallbackCreditUsage(status: FallbackCreditRedeemed());
      final changed = usage.copyWith(
        status: const FallbackCreditNotApplied(
          reason: FallbackCreditNotAppliedReason.expired,
        ),
      );
      expect(changed.status, isA<FallbackCreditNotApplied>());
    });

    test('equality, hashCode, and toString', () {
      const a = FallbackCreditUsage(status: FallbackCreditRedeemed());
      const b = FallbackCreditUsage(status: FallbackCreditRedeemed());
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('FallbackCreditRedeemed()'));
    });
  });

  group('FallbackCreditMode', () {
    test('round-trips strict and best_effort', () {
      expect(FallbackCreditMode.fromJson('strict'), FallbackCreditMode.strict);
      expect(
        FallbackCreditMode.fromJson('best_effort'),
        FallbackCreditMode.bestEffort,
      );
      expect(FallbackCreditMode.strict.toJson(), 'strict');
      expect(FallbackCreditMode.bestEffort.toJson(), 'best_effort');
    });

    test('fromJson throws for unrecognized values', () {
      expect(
        () => FallbackCreditMode.fromJson('lenient'),
        throwsFormatException,
      );
    });
  });

  group('FallbackCreditTokenParam', () {
    test('bare token serializes as a plain string', () {
      const param = FallbackCreditTokenParam.token('tok_abc123');
      expect(param.toJson(), 'tok_abc123');
    });

    test('fromJson parses a bare string wire form', () {
      final param = FallbackCreditTokenParam.fromJson('tok_abc123');
      expect(param, isA<FallbackCreditTokenParamToken>());
      expect((param as FallbackCreditTokenParamToken).token, 'tok_abc123');
    });

    test('config form serializes token and mode', () {
      const param = FallbackCreditTokenParam.config(
        token: 'tok_abc123',
        mode: FallbackCreditMode.bestEffort,
      );
      expect(param.toJson(), {'token': 'tok_abc123', 'mode': 'best_effort'});
    });

    test('config form omits mode when null', () {
      const param = FallbackCreditTokenParam.config(token: 'tok_abc123');
      final json = param.toJson() as Map<String, dynamic>;
      expect(json.containsKey('mode'), isFalse);
    });

    test('fromJson parses the object wire form', () {
      final param = FallbackCreditTokenParam.fromJson({
        'token': 'tok_abc123',
        'mode': 'strict',
      });
      expect(param, isA<FallbackCreditTokenParamConfig>());
      final config = param as FallbackCreditTokenParamConfig;
      expect(config.token, 'tok_abc123');
      expect(config.mode, FallbackCreditMode.strict);
    });

    test('config copyWith replaces token and clears mode', () {
      const original = FallbackCreditTokenParamConfig(
        token: 'tok_abc123',
        mode: FallbackCreditMode.bestEffort,
      );
      final changed = original.copyWith(token: 'tok_new');
      expect(changed.token, 'tok_new');
      expect(changed.mode, FallbackCreditMode.bestEffort);

      final cleared = original.copyWith(mode: null);
      expect(cleared.mode, isNull);
      expect(cleared.token, 'tok_abc123');
    });

    test('equality is content-based for both variants', () {
      const a = FallbackCreditTokenParam.token('tok_abc123');
      const b = FallbackCreditTokenParam.token('tok_abc123');
      const c = FallbackCreditTokenParam.token('tok_other');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));

      const d = FallbackCreditTokenParam.config(token: 'tok_abc123');
      const e = FallbackCreditTokenParam.config(token: 'tok_abc123');
      expect(d, equals(e));
      expect(d.hashCode, equals(e.hashCode));
    });

    test('toString masks the token value for both variants', () {
      const bare = FallbackCreditTokenParam.token('tok_super_secret');
      expect(bare.toString(), isNot(contains('tok_super_secret')));
      expect(bare.toString(), contains('[redacted]'));

      const config = FallbackCreditTokenParam.config(
        token: 'tok_super_secret',
        mode: FallbackCreditMode.strict,
      );
      expect(config.toString(), isNot(contains('tok_super_secret')));
      expect(config.toString(), contains('[redacted]'));
      expect(config.toString(), contains('mode: FallbackCreditMode.strict'));
    });
  });
}
