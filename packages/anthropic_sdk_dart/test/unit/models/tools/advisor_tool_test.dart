import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AdvisorTool', () {
    test('toJson with minimal fields', () {
      const tool = AdvisorTool(model: 'claude-opus-4-7');
      final json = tool.toJson();

      expect(json['type'], 'advisor_20260301');
      expect(json['name'], 'advisor');
      expect(json['model'], 'claude-opus-4-7');
      expect(json.containsKey('max_uses'), isFalse);
      expect(json.containsKey('caching'), isFalse);
      expect(json.containsKey('cache_control'), isFalse);
    });

    test('toJson with all fields', () {
      const tool = AdvisorTool(
        model: 'claude-opus-4-7',
        maxUses: 3,
        caching: CacheControlEphemeral(ttl: CacheTtl.ttl5m),
        cacheControl: CacheControlEphemeral(ttl: CacheTtl.ttl1h),
      );
      final json = tool.toJson();

      expect(json['type'], 'advisor_20260301');
      expect(json['name'], 'advisor');
      expect(json['model'], 'claude-opus-4-7');
      expect(json['max_uses'], 3);
      expect(json['caching'], {'type': 'ephemeral', 'ttl': '5m'});
      expect(json['cache_control'], {'type': 'ephemeral', 'ttl': '1h'});
    });

    test('fromJson round-trip minimal', () {
      final json = {
        'type': 'advisor_20260301',
        'name': 'advisor',
        'model': 'claude-opus-4-7',
      };
      final tool = AdvisorTool.fromJson(json);

      expect(tool.type, 'advisor_20260301');
      expect(tool.model, 'claude-opus-4-7');
      expect(tool.maxUses, isNull);
      expect(tool.caching, isNull);
      expect(tool.cacheControl, isNull);

      expect(tool.toJson(), {
        'type': 'advisor_20260301',
        'name': 'advisor',
        'model': 'claude-opus-4-7',
      });
    });

    test('fromJson round-trip all fields', () {
      final json = {
        'type': 'advisor_20260301',
        'name': 'advisor',
        'model': 'claude-opus-4-7',
        'max_uses': 5,
        'caching': {'type': 'ephemeral', 'ttl': '1h'},
        'cache_control': {'type': 'ephemeral', 'ttl': '5m'},
      };
      final tool = AdvisorTool.fromJson(json);

      expect(tool.maxUses, 5);
      expect(tool.caching, const CacheControlEphemeral(ttl: CacheTtl.ttl1h));
      expect(
        tool.cacheControl,
        const CacheControlEphemeral(ttl: CacheTtl.ttl5m),
      );
      expect(tool.toJson(), json);
    });

    test('BuiltInTool.fromJson dispatches to AdvisorTool', () {
      final json = {
        'type': 'advisor_20260301',
        'name': 'advisor',
        'model': 'claude-opus-4-7',
      };
      final tool = BuiltInTool.fromJson(json);

      expect(tool, isA<AdvisorTool>());
      expect((tool as AdvisorTool).model, 'claude-opus-4-7');
    });

    test('BuiltInTool.advisor factory', () {
      final tool = BuiltInTool.advisor(model: 'claude-opus-4-7', maxUses: 2);

      expect(tool, isA<AdvisorTool>());
      expect((tool as AdvisorTool).model, 'claude-opus-4-7');
      expect(tool.maxUses, 2);
    });

    test('ToolDefinition.builtIn wraps AdvisorTool', () {
      const advisorTool = AdvisorTool(model: 'claude-opus-4-7');
      final toolDef = ToolDefinition.builtIn(advisorTool);
      final json = toolDef.toJson();

      expect(json['type'], 'advisor_20260301');
      expect(json['name'], 'advisor');
      expect(json['model'], 'claude-opus-4-7');
    });

    test('equality', () {
      const a = AdvisorTool(model: 'claude-opus-4-7');
      const b = AdvisorTool(model: 'claude-opus-4-7');
      const c = AdvisorTool(model: 'claude-opus-4-7', maxUses: 3);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('copyWith', () {
      const original = AdvisorTool(model: 'claude-opus-4-7');

      final withMaxUses = original.copyWith(maxUses: 5);
      expect(withMaxUses.model, 'claude-opus-4-7');
      expect(withMaxUses.maxUses, 5);

      final withCaching = original.copyWith(
        caching: const CacheControlEphemeral(ttl: CacheTtl.ttl5m),
      );
      expect(
        withCaching.caching,
        const CacheControlEphemeral(ttl: CacheTtl.ttl5m),
      );

      final clearMaxUses = withMaxUses.copyWith(maxUses: null);
      expect(clearMaxUses.maxUses, isNull);
    });

    test('toString', () {
      const tool = AdvisorTool(model: 'claude-opus-4-7');
      expect(tool.toString(), contains('AdvisorTool'));
      expect(tool.toString(), contains('claude-opus-4-7'));
    });

    test('ToolDefinition.fromJson routes advisor tool correctly', () {
      final json = {
        'type': 'advisor_20260301',
        'name': 'advisor',
        'model': 'claude-opus-4-7',
      };
      final toolDef = ToolDefinition.fromJson(json);

      expect(toolDef, isA<BuiltInToolDefinition>());
      final builtIn = (toolDef as BuiltInToolDefinition).tool;
      expect(builtIn, isA<AdvisorTool>());
      expect((builtIn as AdvisorTool).model, 'claude-opus-4-7');
    });
  });
}
