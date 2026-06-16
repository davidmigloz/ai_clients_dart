import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

/// Minimal valid `BetaManagedAgentsSession` JSON. Pass [deploymentId] = #absent
/// to omit the key entirely, or any value (including `null`) to include it.
Map<String, dynamic> _sessionJson({Object? deploymentId = #absent}) {
  return {
    'id': 'sesn_1',
    'type': 'session',
    'status': 'idle',
    'agent': {
      'id': 'agent_1',
      'type': 'agent',
      'version': 1,
      'name': 'A',
      'model': {'id': 'claude-opus-4-8', 'type': 'model'},
      'mcp_servers': <Map<String, dynamic>>[],
      'skills': <Map<String, dynamic>>[],
      'tools': <Map<String, dynamic>>[],
    },
    'environment_id': 'env_1',
    if (deploymentId != #absent) 'deployment_id': deploymentId,
    'title': null,
    'metadata': <String, String>{},
    'resources': <Map<String, dynamic>>[],
    'vault_ids': <String>[],
    'stats': {'active_seconds': 0, 'duration_seconds': 0},
    'usage': {
      'input_tokens': 0,
      'output_tokens': 0,
      'cache_read_input_tokens': 0,
    },
    'outcome_evaluations': <Map<String, dynamic>>[],
    'created_at': '2026-04-01T00:00:00.000Z',
    'updated_at': '2026-04-01T00:00:00.000Z',
    'archived_at': null,
  };
}

void main() {
  group('Session.deploymentId', () {
    test('round-trips when present', () {
      final session = Session.fromJson(_sessionJson(deploymentId: 'dpl_123'));

      expect(session.deploymentId, 'dpl_123');
      expect(session.toJson()['deployment_id'], 'dpl_123');
    });

    test('is null and omitted from toJson when absent', () {
      final session = Session.fromJson(_sessionJson());

      expect(session.deploymentId, isNull);
      expect(session.toJson().containsKey('deployment_id'), isFalse);
    });

    test('is null and omitted from toJson when explicitly null', () {
      final session = Session.fromJson(_sessionJson(deploymentId: null));

      expect(session.deploymentId, isNull);
      expect(session.toJson().containsKey('deployment_id'), isFalse);
    });

    test('copyWith updates and clears deploymentId', () {
      final session = Session.fromJson(_sessionJson(deploymentId: 'dpl_123'));

      final updated = session.copyWith(deploymentId: 'dpl_999');
      expect(updated.deploymentId, 'dpl_999');

      final cleared = session.copyWith(deploymentId: null);
      expect(cleared.deploymentId, isNull);

      // Omitting the param keeps the original value.
      final kept = session.copyWith(title: 'New Title');
      expect(kept.deploymentId, 'dpl_123');
    });
  });

  group('CredentialHostUnreachableError', () {
    Map<String, dynamic> errorJson() => {
      'type': 'credential_host_unreachable_error',
      'message': 'Host not reachable',
      'credential_id': 'cred_1',
      'vault_id': 'vlt_1',
      'retry_status': {'type': 'terminal'},
    };

    test('fromJson parses all fields', () {
      final error = CredentialHostUnreachableError.fromJson(errorJson());

      expect(error.type, 'credential_host_unreachable_error');
      expect(error.message, 'Host not reachable');
      expect(error.credentialId, 'cred_1');
      expect(error.vaultId, 'vlt_1');
      expect(error.retryStatus, isA<RetryStatusTerminal>());
    });

    test('toJson round-trips', () {
      final error = CredentialHostUnreachableError.fromJson(errorJson());
      final output = error.toJson();

      expect(output['type'], 'credential_host_unreachable_error');
      expect(output['message'], 'Host not reachable');
      expect(output['credential_id'], 'cred_1');
      expect(output['vault_id'], 'vlt_1');
      expect(output['retry_status'], {'type': 'terminal'});
    });

    test('equality, hashCode, copyWith and toString', () {
      final a = CredentialHostUnreachableError.fromJson(errorJson());
      final b = CredentialHostUnreachableError.fromJson(errorJson());

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      final c = a.copyWith(credentialId: 'cred_2');
      expect(c.credentialId, 'cred_2');
      expect(c.vaultId, 'vlt_1');
      expect(a, isNot(equals(c)));

      expect(a.toString(), contains('CredentialHostUnreachableError'));
      expect(a.toString(), contains('cred_1'));
    });
  });

  group('SessionEvent.fromJson → SystemMessageEvent', () {
    test('dispatches and round-trips with processed_at present', () {
      final json = <String, dynamic>{
        'type': 'system.message',
        'id': 'sevt_1',
        'content': [
          {'type': 'text', 'text': 'system note'},
        ],
        'processed_at': '2026-04-01T12:00:00Z',
      };

      final parsed = SessionEvent.fromJson(json);
      expect(parsed, isA<SystemMessageEvent>());
      final event = parsed as SystemMessageEvent;
      expect(event.id, 'sevt_1');
      expect(event.content, hasLength(1));
      expect(event.content.single, {'type': 'text', 'text': 'system note'});
      expect(event.processedAt, DateTime.utc(2026, 4, 1, 12));

      final output = event.toJson();
      expect(output['type'], 'system.message');
      expect(output['id'], 'sevt_1');
      expect(output['content'], json['content']);
      expect(output['processed_at'], '2026-04-01T12:00:00.000Z');
    });

    test('parses with nullable processed_at absent and omits it in toJson', () {
      final json = <String, dynamic>{
        'type': 'system.message',
        'id': 'sevt_2',
        'content': <Map<String, dynamic>>[],
      };

      final event = SessionEvent.fromJson(json) as SystemMessageEvent;
      expect(event.processedAt, isNull);
      expect(event.toJson().containsKey('processed_at'), isFalse);
    });

    test('equality, hashCode, copyWith and toString', () {
      const a = SystemMessageEvent(
        id: 'sevt_1',
        content: [
          {'type': 'text', 'text': 'note'},
        ],
      );
      const b = SystemMessageEvent(
        id: 'sevt_1',
        content: [
          {'type': 'text', 'text': 'note'},
        ],
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      final withTime = a.copyWith(processedAt: DateTime.utc(2026, 4, 1, 12));
      expect(withTime.processedAt, DateTime.utc(2026, 4, 1, 12));

      final cleared = withTime.copyWith(processedAt: null);
      expect(cleared.processedAt, isNull);

      expect(a.toString(), contains('SystemMessageEvent'));
    });
  });

  group('EventParams.fromJson → SystemMessageEventParams', () {
    test('dispatches and round-trips', () {
      final json = <String, dynamic>{
        'type': 'system.message',
        'content': [
          {'type': 'text', 'text': 'system note'},
        ],
      };

      final parsed = EventParams.fromJson(json);
      expect(parsed, isA<SystemMessageEventParams>());
      final params = parsed as SystemMessageEventParams;
      expect(params.content, hasLength(1));
      expect(params.content.single, {'type': 'text', 'text': 'system note'});

      expect(params.toJson(), json);
    });

    test('equality, hashCode, copyWith and toString', () {
      const a = SystemMessageEventParams(
        content: [
          {'type': 'text', 'text': 'note'},
        ],
      );
      const b = SystemMessageEventParams(
        content: [
          {'type': 'text', 'text': 'note'},
        ],
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      final copied = a.copyWith(
        content: const [
          {'type': 'text', 'text': 'updated'},
        ],
      );
      expect(copied.content.single['text'], 'updated');
      expect(a, isNot(equals(copied)));

      expect(a.toString(), contains('SystemMessageEventParams'));
    });
  });
}
