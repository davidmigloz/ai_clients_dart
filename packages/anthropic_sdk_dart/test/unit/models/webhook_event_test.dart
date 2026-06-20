import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  // (discriminator type, has vault_id, matcher) for every spec variant.
  final variants = <(String, bool, Matcher)>[
    ('session.archived', false, isA<WebhookSessionArchivedEventData>()),
    ('session.created', false, isA<WebhookSessionCreatedEventData>()),
    ('session.deleted', false, isA<WebhookSessionDeletedEventData>()),
    ('session.idled', false, isA<WebhookSessionIdledEventData>()),
    (
      'session.outcome_evaluation_ended',
      false,
      isA<WebhookSessionOutcomeEvaluationEndedEventData>(),
    ),
    ('session.pending', false, isA<WebhookSessionPendingEventData>()),
    (
      'session.requires_action',
      false,
      isA<WebhookSessionRequiresActionEventData>(),
    ),
    ('session.running', false, isA<WebhookSessionRunningEventData>()),
    ('session.status_idled', false, isA<WebhookSessionStatusIdledEventData>()),
    (
      'session.status_rescheduled',
      false,
      isA<WebhookSessionStatusRescheduledEventData>(),
    ),
    (
      'session.status_run_started',
      false,
      isA<WebhookSessionStatusRunStartedEventData>(),
    ),
    (
      'session.status_terminated',
      false,
      isA<WebhookSessionStatusTerminatedEventData>(),
    ),
    (
      'session.thread_created',
      false,
      isA<WebhookSessionThreadCreatedEventData>(),
    ),
    ('session.thread_idled', false, isA<WebhookSessionThreadIdledEventData>()),
    (
      'session.thread_terminated',
      false,
      isA<WebhookSessionThreadTerminatedEventData>(),
    ),
    ('session.updated', false, isA<WebhookSessionUpdatedEventData>()),
    ('vault.created', false, isA<WebhookVaultCreatedEventData>()),
    ('vault.archived', false, isA<WebhookVaultArchivedEventData>()),
    ('vault.deleted', false, isA<WebhookVaultDeletedEventData>()),
    (
      'vault_credential.created',
      true,
      isA<WebhookVaultCredentialCreatedEventData>(),
    ),
    (
      'vault_credential.archived',
      true,
      isA<WebhookVaultCredentialArchivedEventData>(),
    ),
    (
      'vault_credential.deleted',
      true,
      isA<WebhookVaultCredentialDeletedEventData>(),
    ),
    (
      'vault_credential.refresh_failed',
      true,
      isA<WebhookVaultCredentialRefreshFailedEventData>(),
    ),
  ];

  Map<String, dynamic> dataJson(String type, {required bool withVault}) {
    return {
      'type': type,
      'id': 'res_123',
      'organization_id': 'org_123',
      'workspace_id': 'wrkspc_123',
      if (withVault) 'vault_id': 'vlt_123',
      // session.thread_* events carry the multi-agent thread id.
      if (type.startsWith('session.thread_'))
        'session_thread_id': 'sessn_thread_123',
    };
  }

  group('WebhookEventData dispatch', () {
    test('covers all 23 spec variants', () {
      expect(variants, hasLength(23));
    });

    for (final (type, withVault, matcher) in variants) {
      test('$type dispatches and round-trips', () {
        final json = dataJson(type, withVault: withVault);
        final data = WebhookEventData.fromJson(json);
        expect(data, matcher);
        expect(data.toJson(), json);
      });
    }

    test('WebhookSessionUpdatedEventData.fromJson parses directly', () {
      final json = dataJson('session.updated', withVault: false);
      final data = WebhookSessionUpdatedEventData.fromJson(json);
      expect(data.id, 'res_123');
      expect(data.organizationId, 'org_123');
      expect(data.workspaceId, 'wrkspc_123');
      expect(data.toJson(), json);
    });

    test('WebhookSessionUpdatedEventData.fromJson rejects a wrong type', () {
      expect(
        () => WebhookSessionUpdatedEventData.fromJson(
          dataJson('session.created', withVault: false),
        ),
        throwsFormatException,
      );
    });

    test('unknown type falls back to UnknownWebhookEventData', () {
      final json = {'type': 'mystery.event', 'foo': 'bar'};
      final data = WebhookEventData.fromJson(json);
      expect(data, isA<UnknownWebhookEventData>());
      expect(data.toJson(), json);
    });

    test('vault-credential variants carry vaultId', () {
      final data =
          WebhookEventData.fromJson(
                dataJson('vault_credential.refresh_failed', withVault: true),
              )
              as WebhookVaultCredentialRefreshFailedEventData;
      expect(data.vaultId, 'vlt_123');
      expect(data.id, 'res_123');
    });
  });

  group('WebhookEvent wrapper', () {
    final json = {
      'type': 'event',
      'id': 'evt_011CZkZRSw2kEfs6ncTVljxP',
      'created_at': '2026-04-01T00:00:00.000Z',
      'data': {
        'type': 'session.created',
        'id': 'sesn_123',
        'organization_id': 'org_123',
        'workspace_id': 'wrkspc_123',
      },
    };

    test('parses the typed payload and round-trips', () {
      final event = WebhookEvent.fromJson(json);
      expect(event.type, 'event');
      expect(event.id, 'evt_011CZkZRSw2kEfs6ncTVljxP');
      expect(event.data, isA<WebhookSessionCreatedEventData>());
      expect(event.toJson(), json);
    });

    test('copyWith replaces fields', () {
      final event = WebhookEvent.fromJson(json);
      final swapped = event.copyWith(
        data: const WebhookSessionDeletedEventData(
          id: 'sesn_123',
          organizationId: 'org_123',
          workspaceId: 'wrkspc_123',
        ),
      );
      expect(swapped.data, isA<WebhookSessionDeletedEventData>());
      expect(swapped.id, event.id);
    });
  });

  group('equality', () {
    test('value equality holds for identical variants', () {
      const a = WebhookSessionCreatedEventData(
        id: 'sesn_1',
        organizationId: 'org_1',
        workspaceId: 'wrkspc_1',
      );
      const b = WebhookSessionCreatedEventData(
        id: 'sesn_1',
        organizationId: 'org_1',
        workspaceId: 'wrkspc_1',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('UnknownWebhookEventData uses deep equality', () {
      final a = WebhookEventData.fromJson({
        'type': 'x',
        'nested': {'k': 1},
      });
      final b = WebhookEventData.fromJson({
        'type': 'x',
        'nested': {'k': 1},
      });
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
