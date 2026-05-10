import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SessionEvent.sessionThreadId', () {
    test('AgentToolUseEvent round-trips session_thread_id', () {
      final json = <String, dynamic>{
        'type': 'agent.tool_use',
        'id': 'event_001',
        'name': 'agent_toolset_20260401',
        'input': {'query': 'lookup'},
        'processed_at': '2026-04-01T12:00:00Z',
        'session_thread_id': 'thread_abc',
      };

      final parsed = SessionEvent.fromJson(json) as AgentToolUseEvent;
      expect(parsed.sessionThreadId, 'thread_abc');
      expect(parsed.toJson()['session_thread_id'], 'thread_abc');
    });

    test('AgentMcpToolUseEvent omits session_thread_id when null', () {
      final json = <String, dynamic>{
        'type': 'agent.mcp_tool_use',
        'id': 'event_002',
        'mcp_server_name': 'github',
        'name': 'list_repos',
        'input': <String, dynamic>{},
        'processed_at': '2026-04-01T12:00:00Z',
      };

      final parsed = SessionEvent.fromJson(json) as AgentMcpToolUseEvent;
      expect(parsed.sessionThreadId, isNull);
      expect(parsed.toJson().containsKey('session_thread_id'), isFalse);
    });

    test('AgentCustomToolUseEvent copyWith updates and clears the id', () {
      final original = AgentCustomToolUseEvent(
        id: 'event_003',
        name: 'my_tool',
        input: const {},
        processedAt: DateTime.utc(2026, 4, 1, 12),
      );

      final updated = original.copyWith(sessionThreadId: 'thread_x');
      expect(updated.sessionThreadId, 'thread_x');

      final cleared = updated.copyWith(sessionThreadId: null);
      expect(cleared.sessionThreadId, isNull);
    });

    test('UserInterruptEvent round-trips session_thread_id', () {
      final json = <String, dynamic>{
        'type': 'user.interrupt',
        'id': 'event_004',
        'session_thread_id': 'thread_42',
      };

      final parsed = SessionEvent.fromJson(json) as UserInterruptEvent;
      expect(parsed.sessionThreadId, 'thread_42');
    });

    test('UserToolConfirmationEvent round-trips session_thread_id', () {
      final json = <String, dynamic>{
        'type': 'user.tool_confirmation',
        'id': 'event_005',
        'tool_use_id': 'event_001',
        'result': 'allow',
        'session_thread_id': 'thread_42',
      };

      final parsed = SessionEvent.fromJson(json) as UserToolConfirmationEvent;
      expect(parsed.sessionThreadId, 'thread_42');
      expect(parsed.toJson()['session_thread_id'], 'thread_42');
    });

    test('UserCustomToolResultEvent round-trips session_thread_id', () {
      final json = <String, dynamic>{
        'type': 'user.custom_tool_result',
        'id': 'event_006',
        'custom_tool_use_id': 'event_003',
        'session_thread_id': 'thread_42',
      };

      final parsed = SessionEvent.fromJson(json) as UserCustomToolResultEvent;
      expect(parsed.sessionThreadId, 'thread_42');
    });
  });

  group('UserInterruptEventParams', () {
    test('serializes session_thread_id when set', () {
      const params = UserInterruptEventParams(sessionThreadId: 'thread_77');
      expect(params.toJson(), {
        'type': 'user.interrupt',
        'session_thread_id': 'thread_77',
      });
    });

    test('omits session_thread_id when null', () {
      const params = UserInterruptEventParams();
      expect(params.toJson(), {'type': 'user.interrupt'});
    });

    test('round-trips through EventParams.fromJson dispatch', () {
      const params = UserInterruptEventParams(sessionThreadId: 'thread_77');
      final parsed = EventParams.fromJson(params.toJson());
      expect(parsed, isA<UserInterruptEventParams>());
      expect((parsed as UserInterruptEventParams).sessionThreadId, 'thread_77');
    });

    test('copyWith preserves and clears sessionThreadId', () {
      const original = UserInterruptEventParams(sessionThreadId: 'thread_77');
      final preserved = original.copyWith();
      expect(preserved.sessionThreadId, 'thread_77');

      final cleared = original.copyWith(sessionThreadId: null);
      expect(cleared.sessionThreadId, isNull);
    });
  });
}
