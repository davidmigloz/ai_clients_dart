import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('RunError', () {
    // type -> the concrete Dart class fromJson should produce.
    final cases = <String, Type>{
      'agent_archived_error': AgentArchivedRunError,
      'environment_archived_error': EnvironmentArchivedRunError,
      'environment_not_found_error': EnvironmentNotFoundRunError,
      'file_not_found_error': FileNotFoundRunError,
      'mcp_egress_blocked_error': McpEgressBlockedRunError,
      'memory_store_archived_error': MemoryStoreArchivedRunError,
      'organization_disabled_error': OrganizationDisabledRunError,
      'self_hosted_resources_unsupported_error':
          SelfHostedResourcesUnsupportedRunError,
      'session_creation_rejected_error': SessionCreationRejectedRunError,
      'session_rate_limited_error': SessionRateLimitedRunError,
      'session_resource_not_found_error': SessionResourceNotFoundRunError,
      'skill_not_found_error': SkillNotFoundRunError,
      'unknown_error': UnknownRunError,
      'vault_archived_error': VaultArchivedRunError,
      'vault_not_found_error': VaultNotFoundRunError,
      'workspace_archived_error': WorkspaceArchivedRunError,
    };

    test('covers all 16 typed variants', () {
      expect(cases, hasLength(16));
    });

    cases.forEach((type, dartType) {
      test('dispatches "$type" and round-trips {message, type}', () {
        final json = {'type': type, 'message': 'boom'};
        final parsed = RunError.fromJson(json);

        expect(parsed.runtimeType, dartType);
        expect(parsed.type, type);
        // Every typed variant exposes a `message`.
        expect((parsed as dynamic).message, 'boom');
        expect(parsed.toJson(), json);
      });
    });

    test('typed unknown_error maps to UnknownRunError (not the fallback)', () {
      final parsed = RunError.fromJson({
        'type': 'unknown_error',
        'message': 'mystery',
      });

      expect(parsed, isA<UnknownRunError>());
      expect(parsed, isNot(isA<UnrecognizedRunError>()));
      expect((parsed as UnknownRunError).message, 'mystery');
    });

    test('unrecognized type falls back to UnrecognizedRunError', () {
      final json = {
        'type': 'some_future_error',
        'message': 'hi',
        'extra': {
          'nested': [1, 2, 3],
        },
      };
      final parsed = RunError.fromJson(json);

      expect(parsed, isA<UnrecognizedRunError>());
      final fallback = parsed as UnrecognizedRunError;
      expect(fallback.type, 'some_future_error');
      // Raw JSON preserved verbatim (including unknown nested keys).
      expect(fallback.toJson(), json);
      expect(fallback.rawJson, json);
    });

    test('UnrecognizedRunError round-trips with deep equality', () {
      final json = {
        'type': 'weird',
        'message': 'm',
        'details': {
          'a': [
            1,
            {'b': 2},
          ],
        },
      };
      final first = RunError.fromJson(json) as UnrecognizedRunError;
      // Re-parse the serialized form — deep content must compare equal.
      final second = RunError.fromJson(first.toJson()) as UnrecognizedRunError;

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test(
      'UnrecognizedRunError without a type falls back to "unrecognized"',
      () {
        final parsed = RunError.fromJson({'message': 'no type here'});

        expect(parsed, isA<UnrecognizedRunError>());
        expect(parsed.type, 'unrecognized');
      },
    );

    test('== / hashCode / toString for a typed variant', () {
      const a = AgentArchivedRunError(message: 'x');
      const b = AgentArchivedRunError(message: 'x');
      const c = AgentArchivedRunError(message: 'y');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(
        a.toString(),
        'AgentArchivedRunError(type: agent_archived_error, message: x)',
      );
    });

    test('different RunError variants with same message are not equal', () {
      const a = VaultArchivedRunError(message: 'm');
      const b = VaultNotFoundRunError(message: 'm');

      expect(a, isNot(equals(b)));
    });

    test('copyWith replaces message', () {
      const original = SkillNotFoundRunError(message: 'old');
      final updated = original.copyWith(message: 'new');

      expect(updated.message, 'new');
      expect(updated.type, 'skill_not_found_error');
    });
  });

  group('DeploymentPausedReasonError', () {
    // type -> the concrete Dart class fromJson should produce.
    final cases = <String, Type>{
      'agent_archived_error': AgentArchivedDeploymentPausedReasonError,
      'environment_archived_error':
          EnvironmentArchivedDeploymentPausedReasonError,
      'environment_not_found_error':
          EnvironmentNotFoundDeploymentPausedReasonError,
      'file_not_found_error': FileNotFoundDeploymentPausedReasonError,
      'mcp_egress_blocked_error': McpEgressBlockedDeploymentPausedReasonError,
      'memory_store_archived_error':
          MemoryStoreArchivedDeploymentPausedReasonError,
      'organization_disabled_error':
          OrganizationDisabledDeploymentPausedReasonError,
      'self_hosted_resources_unsupported_error':
          SelfHostedResourcesUnsupportedDeploymentPausedReasonError,
      'session_resource_not_found_error':
          SessionResourceNotFoundDeploymentPausedReasonError,
      'skill_not_found_error': SkillNotFoundDeploymentPausedReasonError,
      'unknown_error': UnknownDeploymentPausedReasonError,
      'vault_archived_error': VaultArchivedDeploymentPausedReasonError,
      'vault_not_found_error': VaultNotFoundDeploymentPausedReasonError,
      'workspace_archived_error': WorkspaceArchivedDeploymentPausedReasonError,
    };

    test('covers all 14 typed variants', () {
      expect(cases, hasLength(14));
    });

    cases.forEach((type, dartType) {
      test('dispatches "$type" and round-trips {type}-only', () {
        final json = {'type': type};
        final parsed = DeploymentPausedReasonError.fromJson(json);

        expect(parsed.runtimeType, dartType);
        expect(parsed.type, type);
        // These variants carry only the discriminator — no message.
        expect(parsed.toJson(), {'type': type});
      });
    });

    test('typed unknown_error maps to UnknownDeploymentPausedReasonError', () {
      final parsed = DeploymentPausedReasonError.fromJson({
        'type': 'unknown_error',
      });

      expect(parsed, isA<UnknownDeploymentPausedReasonError>());
      expect(parsed, isNot(isA<UnrecognizedDeploymentPausedReasonError>()));
    });

    test('unrecognized type falls back, preserving raw JSON', () {
      final json = {'type': 'brand_new_error', 'hint': 'forward-compat'};
      final parsed = DeploymentPausedReasonError.fromJson(json);

      expect(parsed, isA<UnrecognizedDeploymentPausedReasonError>());
      final fallback = parsed as UnrecognizedDeploymentPausedReasonError;
      expect(fallback.type, 'brand_new_error');
      expect(fallback.toJson(), json);
    });

    test('fallback round-trips with deep equality', () {
      final json = {
        'type': 'future',
        'payload': {
          'k': [true, false],
        },
      };
      final first =
          DeploymentPausedReasonError.fromJson(json)
              as UnrecognizedDeploymentPausedReasonError;
      final second =
          DeploymentPausedReasonError.fromJson(first.toJson())
              as UnrecognizedDeploymentPausedReasonError;

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('== / hashCode / toString for a typed variant', () {
      const a = VaultArchivedDeploymentPausedReasonError();
      const b = VaultArchivedDeploymentPausedReasonError();
      const c = VaultNotFoundDeploymentPausedReasonError();

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
      expect(
        a.toString(),
        'VaultArchivedDeploymentPausedReasonError(type: vault_archived_error)',
      );
    });
  });

  group('DeploymentPausedReason', () {
    test('dispatches "manual" to ManualDeploymentPausedReason', () {
      final json = {'type': 'manual'};
      final parsed = DeploymentPausedReason.fromJson(json);

      expect(parsed, isA<ManualDeploymentPausedReason>());
      expect(parsed.type, 'manual');
      expect(parsed.toJson(), json);
    });

    test('dispatches "error" and round-trips the nested error union', () {
      final json = {
        'type': 'error',
        'error': {'type': 'vault_archived_error'},
      };
      final parsed = DeploymentPausedReason.fromJson(json);

      expect(parsed, isA<ErrorDeploymentPausedReason>());
      final error = parsed as ErrorDeploymentPausedReason;
      expect(error.type, 'error');
      expect(error.error, isA<VaultArchivedDeploymentPausedReasonError>());
      expect(error.error.type, 'vault_archived_error');
      expect(parsed.toJson(), json);
    });

    test('nested error union falls back for unrecognized inner type', () {
      final json = {
        'type': 'error',
        'error': {'type': 'mystery_error', 'note': 'x'},
      };
      final parsed =
          DeploymentPausedReason.fromJson(json) as ErrorDeploymentPausedReason;

      expect(parsed.error, isA<UnrecognizedDeploymentPausedReasonError>());
      expect(parsed.toJson(), json);
    });

    test('ErrorDeploymentPausedReason copyWith replaces the error', () {
      const original = ErrorDeploymentPausedReason(
        error: VaultArchivedDeploymentPausedReasonError(),
      );
      final updated = original.copyWith(
        error: const SkillNotFoundDeploymentPausedReasonError(),
      );

      expect(updated.error, isA<SkillNotFoundDeploymentPausedReasonError>());
    });

    test('unrecognized reason type falls back, preserving raw JSON', () {
      final json = {'type': 'something_new', 'extra': 42};
      final parsed = DeploymentPausedReason.fromJson(json);

      expect(parsed, isA<UnrecognizedDeploymentPausedReason>());
      final fallback = parsed as UnrecognizedDeploymentPausedReason;
      expect(fallback.type, 'something_new');
      expect(fallback.toJson(), json);
    });

    test('fallback round-trips with deep equality', () {
      final json = {
        'type': 'future_reason',
        'meta': {
          'tags': ['a', 'b'],
        },
      };
      final first =
          DeploymentPausedReason.fromJson(json)
              as UnrecognizedDeploymentPausedReason;
      final second =
          DeploymentPausedReason.fromJson(first.toJson())
              as UnrecognizedDeploymentPausedReason;

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('== / toString for ManualDeploymentPausedReason', () {
      const a = ManualDeploymentPausedReason();
      const b = ManualDeploymentPausedReason();

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.toString(), 'ManualDeploymentPausedReason(type: manual)');
    });
  });
}
