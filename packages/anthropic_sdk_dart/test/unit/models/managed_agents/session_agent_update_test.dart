import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SessionAgentUpdate', () {
    test('round-trips with tools and mcp_servers', () {
      final json = <String, dynamic>{
        'tools': [
          {
            'type': 'custom',
            'name': 'lookup',
            'description': 'Look something up',
            'input_schema': {'type': 'object'},
          },
        ],
        'mcp_servers': [
          {'type': 'url', 'name': 'github', 'url': 'https://mcp.example.com'},
        ],
      };

      final parsed = SessionAgentUpdate.fromJson(json);
      expect(parsed.tools, hasLength(1));
      expect(parsed.tools!.first, isA<CustomToolParams>());
      expect(parsed.mcpServers, hasLength(1));
      expect(parsed.mcpServers!.first, isA<URLMCPServerParams>());

      expect(parsed.toJson(), json);
    });

    test('empty arrays are serialized as empty lists (clear semantics)', () {
      const update = SessionAgentUpdate(tools: [], mcpServers: []);

      expect(update.toJson(), {
        'tools': <Map<String, dynamic>>[],
        'mcp_servers': <Map<String, dynamic>>[],
      });
    });

    test(
      'omitted (null) fields are omitted from JSON (preserve semantics)',
      () {
        const update = SessionAgentUpdate();

        expect(update.toJson(), isEmpty);
        expect(update.tools, isNull);
        expect(update.mcpServers, isNull);
      },
    );

    test('distinguishes empty array from omitted', () {
      const cleared = SessionAgentUpdate(tools: []);
      const preserved = SessionAgentUpdate();

      expect(cleared.toJson().containsKey('tools'), isTrue);
      expect(preserved.toJson().containsKey('tools'), isFalse);
    });

    test('equality and hashCode', () {
      // Build distinct instances via fromJson so const-canonicalization does
      // not collapse them into the same object, genuinely exercising `==`.
      Map<String, dynamic> source() => {
        'tools': [
          {
            'type': 'custom',
            'name': 'lookup',
            'description': 'Look up',
            'input_schema': {'type': 'object'},
          },
        ],
        'mcp_servers': [
          {'type': 'url', 'name': 'gh', 'url': 'https://x'},
        ],
      };
      final a = SessionAgentUpdate.fromJson(source());
      final b = SessionAgentUpdate.fromJson(source());
      const c = SessionAgentUpdate();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('copyWith replaces only provided fields', () {
      const update = SessionAgentUpdate(
        mcpServers: [URLMCPServerParams(name: 'gh', url: 'https://x')],
      );
      final copied = update.copyWith(tools: const []);

      expect(copied.tools, isEmpty);
      expect(copied.mcpServers, equals(update.mcpServers));
    });

    test('toString includes fields', () {
      const update = SessionAgentUpdate(tools: []);
      expect(update.toString(), contains('SessionAgentUpdate'));
      expect(update.toString(), contains('tools'));
      expect(update.toString(), contains('mcpServers'));
    });
  });

  group('UpdateSessionParams.agent', () {
    test('round-trips agent', () {
      final json = <String, dynamic>{
        'agent': {
          'tools': <Map<String, dynamic>>[],
          'mcp_servers': [
            {'type': 'url', 'name': 'gh', 'url': 'https://x'},
          ],
        },
      };

      final parsed = UpdateSessionParams.fromJson(json);
      expect(parsed.agent, isNotNull);
      expect(parsed.agent!.tools, isEmpty);
      expect(parsed.agent!.mcpServers, hasLength(1));
      expect(parsed.toJson(), json);
    });

    test('omit-to-preserve: omitted agent absent from JSON', () {
      const params = UpdateSessionParams(title: 'New Title');
      expect(params.toJson().containsKey('agent'), isFalse);
      expect(params.agent, isNull);
    });

    test('explicit null agent is included as null (clear semantics)', () {
      const params = UpdateSessionParams(agent: null);
      expect(params.toJson().containsKey('agent'), isTrue);
      expect(params.toJson()['agent'], isNull);
    });

    test('fromJson preserves agent when key omitted', () {
      final parsed = UpdateSessionParams.fromJson(const {'title': 'x'});
      expect(parsed.toJson().containsKey('agent'), isFalse);
    });

    test('copyWith replaces agent and preserves others', () {
      const params = UpdateSessionParams(title: 'Title');
      final copied = params.copyWith(
        agent: const SessionAgentUpdate(tools: []),
      );

      expect(copied.title, 'Title');
      expect(copied.agent, isNotNull);
      expect(copied.agent!.tools, isEmpty);
    });

    test('copyWith without agent preserves existing agent', () {
      const params = UpdateSessionParams(agent: SessionAgentUpdate(tools: []));
      final copied = params.copyWith(title: 'New');

      expect(copied.agent, isNotNull);
      expect(copied.title, 'New');
    });

    test('equality considers agent', () {
      // Build via fromJson so the two instances are genuinely distinct.
      final a = UpdateSessionParams.fromJson(const {
        'agent': {'tools': <Map<String, dynamic>>[]},
      });
      final b = UpdateSessionParams.fromJson(const {
        'agent': {'tools': <Map<String, dynamic>>[]},
      });
      const c = UpdateSessionParams();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('toString includes agent', () {
      const params = UpdateSessionParams(agent: SessionAgentUpdate(tools: []));
      expect(params.toString(), contains('agent'));
    });
  });
}
