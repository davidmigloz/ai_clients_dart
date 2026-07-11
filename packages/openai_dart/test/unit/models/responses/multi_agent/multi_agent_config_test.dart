import 'package:openai_dart/src/models/responses/multi_agent/multi_agent_config.dart';
import 'package:test/test.dart';

void main() {
  group('MultiAgentConfig', () {
    test('round-trips through JSON with max_concurrent_subagents', () {
      const config = MultiAgentConfig(enabled: true, maxConcurrentSubagents: 5);

      final json = config.toJson();
      expect(json, {'enabled': true, 'max_concurrent_subagents': 5});
      expect(MultiAgentConfig.fromJson(json), config);
    });

    test('omits max_concurrent_subagents when null', () {
      const config = MultiAgentConfig(enabled: true);

      final json = config.toJson();
      expect(json.containsKey('max_concurrent_subagents'), isFalse);

      final decoded = MultiAgentConfig.fromJson(json);
      expect(decoded, config);
      expect(decoded.maxConcurrentSubagents, isNull);
    });

    test('supports equality/hashCode', () {
      const a = MultiAgentConfig(enabled: true, maxConcurrentSubagents: 3);
      const b = MultiAgentConfig(enabled: true, maxConcurrentSubagents: 3);
      const c = MultiAgentConfig(enabled: false, maxConcurrentSubagents: 3);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('supports copyWith clearing max_concurrent_subagents', () {
      const config = MultiAgentConfig(enabled: true, maxConcurrentSubagents: 3);
      final updated = config.copyWith(maxConcurrentSubagents: null);

      expect(updated.maxConcurrentSubagents, isNull);
      expect(updated.enabled, isTrue);
    });
  });
}
