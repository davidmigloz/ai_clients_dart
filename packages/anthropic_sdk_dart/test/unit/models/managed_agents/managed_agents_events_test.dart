import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _sessionAgentJson() => {
  'id': 'agent_123',
  'type': 'agent',
  'version': 1,
  'name': 'Test Agent',
  'model': {'id': 'claude-sonnet-4-5', 'type': 'model'},
  'mcp_servers': <Map<String, dynamic>>[],
  'skills': <Map<String, dynamic>>[],
  'tools': <Map<String, dynamic>>[],
};

void main() {
  group('SessionEvent.fromJson → SessionUpdatedEvent', () {
    test('dispatches and round-trips with all fields', () {
      final json = <String, dynamic>{
        'type': 'session.updated',
        'id': 'event_001',
        'processed_at': '2026-04-01T12:00:00Z',
        'agent': _sessionAgentJson(),
        'metadata': {'k': 'v'},
        'title': 'Updated Title',
      };

      final parsed = SessionEvent.fromJson(json);
      expect(parsed, isA<SessionUpdatedEvent>());
      final event = parsed as SessionUpdatedEvent;
      expect(event.id, 'event_001');
      expect(event.processedAt, DateTime.utc(2026, 4, 1, 12));
      expect(event.agent, isA<SessionAgent>());
      expect(event.agent!.name, 'Test Agent');
      expect(event.metadata, {'k': 'v'});
      expect(event.title, 'Updated Title');

      expect(event.toJson()['type'], 'session.updated');
      expect(event.toJson()['metadata'], {'k': 'v'});
      expect(event.toJson()['title'], 'Updated Title');
      expect(event.toJson()['agent'], isA<Map<String, dynamic>>());
    });

    test('parses with optional fields absent', () {
      final json = <String, dynamic>{
        'type': 'session.updated',
        'id': 'event_002',
        'processed_at': '2026-04-01T12:00:00Z',
      };

      final event = SessionEvent.fromJson(json) as SessionUpdatedEvent;
      expect(event.agent, isNull);
      expect(event.metadata, isNull);
      expect(event.title, isNull);
      expect(event.toJson().containsKey('agent'), isFalse);
      expect(event.toJson().containsKey('metadata'), isFalse);
      expect(event.toJson().containsKey('title'), isFalse);
    });

    test('equality and hashCode', () {
      final a = SessionEvent.fromJson({
        'type': 'session.updated',
        'id': 'e1',
        'processed_at': '2026-04-01T12:00:00Z',
        'metadata': {'k': 'v'},
        'title': 'T',
      });
      final b = SessionEvent.fromJson({
        'type': 'session.updated',
        'id': 'e1',
        'processed_at': '2026-04-01T12:00:00Z',
        'metadata': {'k': 'v'},
        'title': 'T',
      });

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith and toString', () {
      final event =
          SessionEvent.fromJson({
                'type': 'session.updated',
                'id': 'e1',
                'processed_at': '2026-04-01T12:00:00Z',
              })
              as SessionUpdatedEvent;

      final copied = event.copyWith(title: 'New');
      expect(copied.title, 'New');
      expect(copied.id, 'e1');
      expect(event.toString(), contains('SessionUpdatedEvent'));
    });
  });

  group('SessionEvent.fromJson → UserToolResultEvent', () {
    test('dispatches and round-trips with all fields', () {
      final json = <String, dynamic>{
        'type': 'user.tool_result',
        'id': 'event_003',
        'tool_use_id': 'toolu_abc',
        'content': [
          {'type': 'text', 'text': 'ok'},
        ],
        'is_error': false,
        'processed_at': '2026-04-01T12:00:00Z',
        'session_thread_id': 'thread_x',
      };

      final parsed = SessionEvent.fromJson(json);
      expect(parsed, isA<UserToolResultEvent>());
      final event = parsed as UserToolResultEvent;
      expect(event.id, 'event_003');
      expect(event.toolUseId, 'toolu_abc');
      expect(event.content, hasLength(1));
      expect(event.isError, false);
      expect(event.processedAt, DateTime.utc(2026, 4, 1, 12));
      expect(event.sessionThreadId, 'thread_x');

      // Re-parsing the serialized form yields an equivalent event (the
      // timestamp serializes with millisecond precision: ...T12:00:00.000Z).
      expect(SessionEvent.fromJson(event.toJson()), event);
      expect(event.toJson()['type'], 'user.tool_result');
      expect(event.toJson()['content'], event.content);
      expect(event.toJson()['is_error'], false);
    });

    test('parses with optional fields absent', () {
      final json = <String, dynamic>{
        'type': 'user.tool_result',
        'id': 'event_004',
        'tool_use_id': 'toolu_def',
      };

      final event = SessionEvent.fromJson(json) as UserToolResultEvent;
      expect(event.content, isNull);
      expect(event.isError, isNull);
      expect(event.processedAt, isNull);
      expect(event.sessionThreadId, isNull);
      expect(event.toJson(), {
        'type': 'user.tool_result',
        'id': 'event_004',
        'tool_use_id': 'toolu_def',
      });
    });

    test('equality and hashCode', () {
      final a = SessionEvent.fromJson({
        'type': 'user.tool_result',
        'id': 'e1',
        'tool_use_id': 't1',
        'content': [
          {'type': 'text', 'text': 'x'},
        ],
        'is_error': true,
      });
      final b = SessionEvent.fromJson({
        'type': 'user.tool_result',
        'id': 'e1',
        'tool_use_id': 't1',
        'content': [
          {'type': 'text', 'text': 'x'},
        ],
        'is_error': true,
      });

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith and toString', () {
      final event =
          SessionEvent.fromJson({
                'type': 'user.tool_result',
                'id': 'e1',
                'tool_use_id': 't1',
              })
              as UserToolResultEvent;

      final copied = event.copyWith(isError: true);
      expect(copied.isError, true);
      expect(copied.toolUseId, 't1');
      expect(event.toString(), contains('UserToolResultEvent'));
    });
  });

  group('EventParams.fromJson → UserToolResultEventParams', () {
    test('dispatches and round-trips with all fields', () {
      final json = <String, dynamic>{
        'type': 'user.tool_result',
        'tool_use_id': 'toolu_abc',
        'content': [
          {'type': 'text', 'text': 'ok'},
        ],
        'is_error': false,
      };

      final parsed = EventParams.fromJson(json);
      expect(parsed, isA<UserToolResultEventParams>());
      final params = parsed as UserToolResultEventParams;
      expect(params.toolUseId, 'toolu_abc');
      expect(params.content, hasLength(1));
      expect(params.isError, false);

      expect(params.toJson(), json);
    });

    test('parses with optional fields absent', () {
      final json = <String, dynamic>{
        'type': 'user.tool_result',
        'tool_use_id': 'toolu_def',
      };

      final params = EventParams.fromJson(json) as UserToolResultEventParams;
      expect(params.content, isNull);
      expect(params.isError, isNull);
      expect(params.toJson(), {
        'type': 'user.tool_result',
        'tool_use_id': 'toolu_def',
      });
    });

    test('equality, hashCode, copyWith and toString', () {
      const a = UserToolResultEventParams(toolUseId: 't1', isError: true);
      const b = UserToolResultEventParams(toolUseId: 't1', isError: true);
      const c = UserToolResultEventParams(toolUseId: 't2');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));

      final copied = a.copyWith(toolUseId: 't9');
      expect(copied.toolUseId, 't9');
      expect(copied.isError, true);

      expect(a.toString(), contains('UserToolResultEventParams'));
    });
  });
}
