import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SessionThread', () {
    Map<String, dynamic> threadJson({
      String? archivedAt,
      String? parentThreadId,
      Map<String, dynamic>? usage,
      Map<String, dynamic>? stats,
      String status = 'running',
    }) {
      return {
        'id': 'sthr_011CZkZVWa6oIjw0rgXZpnBt',
        'type': 'session_thread',
        'session_id': 'sesn_011CZkZAtmR3yMPDzynEDxu7',
        'status': status,
        'agent': {
          'id': 'agent_011CZkYqphY8vELVzwCUpqiQ',
          'type': 'agent',
          'version': 1,
          'name': 'Researcher',
          'model': {'id': 'claude-sonnet-4-5', 'type': 'model'},
          'mcp_servers': <Map<String, dynamic>>[],
          'skills': <Map<String, dynamic>>[],
          'tools': <Map<String, dynamic>>[],
        },
        'parent_thread_id': parentThreadId,
        'created_at': '2026-04-01T00:00:00Z',
        'updated_at': '2026-04-01T00:05:00Z',
        'archived_at': archivedAt,
        'usage': usage,
        'stats': stats,
      };
    }

    test('round-trips with all fields populated', () {
      final json = threadJson(
        parentThreadId: 'sthr_parent_123',
        archivedAt: '2026-04-01T01:00:00Z',
        usage: {
          'input_tokens': 100,
          'output_tokens': 50,
          'cache_read_input_tokens': 10,
          'cache_creation': {
            'ephemeral_5m_input_tokens': 4,
            'ephemeral_1h_input_tokens': 0,
          },
        },
        stats: {
          'active_seconds': 12.5,
          'duration_seconds': 60.0,
          'startup_seconds': 0.5,
        },
      );

      final parsed = SessionThread.fromJson(json);
      expect(parsed.id, 'sthr_011CZkZVWa6oIjw0rgXZpnBt');
      expect(parsed.sessionId, 'sesn_011CZkZAtmR3yMPDzynEDxu7');
      expect(parsed.status, SessionStatus.running);
      expect(parsed.parentThreadId, 'sthr_parent_123');
      expect(parsed.archivedAt, isNotNull);
      expect(parsed.usage?.inputTokens, 100);
      expect(parsed.stats?.startupSeconds, 0.5);

      final reparsed = SessionThread.fromJson(parsed.toJson());
      expect(reparsed, equals(parsed));
    });

    test('round-trips with nullable fields null', () {
      final parsed = SessionThread.fromJson(threadJson());
      expect(parsed.parentThreadId, isNull);
      expect(parsed.archivedAt, isNull);
      expect(parsed.usage, isNull);
      expect(parsed.stats, isNull);

      final json = parsed.toJson();
      expect(json.containsKey('parent_thread_id'), isTrue);
      expect(json['parent_thread_id'], isNull);
      expect(json.containsKey('archived_at'), isTrue);
      expect(json['archived_at'], isNull);
    });

    test('dispatches status enum and falls back to unknown', () {
      final running = SessionThread.fromJson(threadJson(status: 'running'));
      expect(running.status, SessionStatus.running);

      final unknown = SessionThread.fromJson(threadJson(status: 'partying'));
      expect(unknown.status, SessionStatus.unknown);
    });

    test('copyWith clears nullable fields with explicit null', () {
      final original = SessionThread.fromJson(
        threadJson(
          parentThreadId: 'sthr_parent_123',
          archivedAt: '2026-04-01T01:00:00Z',
        ),
      );

      final cleared = original.copyWith(parentThreadId: null, archivedAt: null);
      expect(cleared.parentThreadId, isNull);
      expect(cleared.archivedAt, isNull);
    });

    test('copyWith preserves nullable fields when omitted', () {
      final original = SessionThread.fromJson(
        threadJson(parentThreadId: 'sthr_parent_123'),
      );
      final copy = original.copyWith(status: SessionStatus.idle);

      expect(copy.parentThreadId, 'sthr_parent_123');
      expect(copy.status, SessionStatus.idle);
    });

    test('equality uses content-based comparison', () {
      final a = SessionThread.fromJson(threadJson());
      final b = SessionThread.fromJson(threadJson());
      final c = SessionThread.fromJson(threadJson(status: 'idle'));

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });
  });

  group('SessionThreadStats', () {
    test('round-trips startup_seconds', () {
      const stats = SessionThreadStats(
        activeSeconds: 12.5,
        durationSeconds: 60.0,
        startupSeconds: 0.5,
      );
      final json = stats.toJson();
      expect(json, {
        'active_seconds': 12.5,
        'duration_seconds': 60.0,
        'startup_seconds': 0.5,
      });

      expect(SessionThreadStats.fromJson(json), equals(stats));
    });

    test('omits null fields from JSON', () {
      const stats = SessionThreadStats();
      expect(stats.toJson(), isEmpty);
    });
  });

  group('SessionThreadUsage', () {
    test('round-trips cache_creation', () {
      const usage = SessionThreadUsage(
        inputTokens: 100,
        outputTokens: 50,
        cacheReadInputTokens: 10,
        cacheCreation: CacheCreationUsage(ephemeral5mInputTokens: 4),
      );
      final json = usage.toJson();
      expect(json['input_tokens'], 100);
      expect(json['cache_creation'], {'ephemeral_5m_input_tokens': 4});

      expect(SessionThreadUsage.fromJson(json), equals(usage));
    });
  });

  group('ListSessionThreadsResponse', () {
    test('round-trips with next_page', () {
      final json = {
        'data': [
          {
            'id': 'sthr_1',
            'type': 'session_thread',
            'session_id': 'sesn_1',
            'status': 'idle',
            'agent': {
              'id': 'agent_1',
              'type': 'agent',
              'version': 1,
              'name': 'A',
              'model': {'id': 'claude-sonnet-4-5', 'type': 'model'},
              'mcp_servers': <Map<String, dynamic>>[],
              'skills': <Map<String, dynamic>>[],
              'tools': <Map<String, dynamic>>[],
            },
            'parent_thread_id': null,
            'created_at': '2026-04-01T00:00:00Z',
            'updated_at': '2026-04-01T00:00:00Z',
            'archived_at': null,
            'usage': null,
            'stats': null,
          },
        ],
        'next_page': 'page_abc',
      };

      final parsed = ListSessionThreadsResponse.fromJson(json);
      expect(parsed.data, hasLength(1));
      expect(parsed.nextPage, 'page_abc');

      final reparsed = ListSessionThreadsResponse.fromJson(parsed.toJson());
      expect(reparsed, equals(parsed));
    });

    test('omits next_page when null', () {
      const response = ListSessionThreadsResponse(data: []);
      final json = response.toJson();
      expect(json['data'], <Map<String, dynamic>>[]);
      expect(json.containsKey('next_page'), isFalse);
    });
  });
}
