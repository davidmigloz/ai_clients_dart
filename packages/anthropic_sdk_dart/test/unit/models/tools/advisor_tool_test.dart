import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AdvisorTool', () {
    test('toJson with minimal fields', () {
      const tool = AdvisorTool(model: 'claude-opus-4-8');
      final json = tool.toJson();

      expect(json['type'], 'advisor_20260301');
      expect(json['name'], 'advisor');
      expect(json['model'], 'claude-opus-4-8');
      expect(json.containsKey('max_uses'), isFalse);
      expect(json.containsKey('caching'), isFalse);
      expect(json.containsKey('cache_control'), isFalse);
    });

    test('toJson with all fields', () {
      const tool = AdvisorTool(
        model: 'claude-opus-4-8',
        maxUses: 3,
        caching: CacheControlEphemeral(ttl: CacheTtl.ttl5m),
        cacheControl: CacheControlEphemeral(ttl: CacheTtl.ttl1h),
      );
      final json = tool.toJson();

      expect(json['type'], 'advisor_20260301');
      expect(json['name'], 'advisor');
      expect(json['model'], 'claude-opus-4-8');
      expect(json['max_uses'], 3);
      expect(json['caching'], {'type': 'ephemeral', 'ttl': '5m'});
      expect(json['cache_control'], {'type': 'ephemeral', 'ttl': '1h'});
    });

    test('fromJson round-trip minimal', () {
      final json = {
        'type': 'advisor_20260301',
        'name': 'advisor',
        'model': 'claude-opus-4-8',
      };
      final tool = AdvisorTool.fromJson(json);

      expect(tool.type, 'advisor_20260301');
      expect(tool.model, 'claude-opus-4-8');
      expect(tool.maxUses, isNull);
      expect(tool.caching, isNull);
      expect(tool.cacheControl, isNull);

      expect(tool.toJson(), {
        'type': 'advisor_20260301',
        'name': 'advisor',
        'model': 'claude-opus-4-8',
      });
    });

    test('fromJson round-trip all fields', () {
      final json = {
        'type': 'advisor_20260301',
        'name': 'advisor',
        'model': 'claude-opus-4-8',
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
        'model': 'claude-opus-4-8',
      };
      final tool = BuiltInTool.fromJson(json);

      expect(tool, isA<AdvisorTool>());
      expect((tool as AdvisorTool).model, 'claude-opus-4-8');
    });

    test('BuiltInTool.advisor factory', () {
      final tool = BuiltInTool.advisor(model: 'claude-opus-4-8', maxUses: 2);

      expect(tool, isA<AdvisorTool>());
      expect((tool as AdvisorTool).model, 'claude-opus-4-8');
      expect(tool.maxUses, 2);
    });

    test('ToolDefinition.builtIn wraps AdvisorTool', () {
      const advisorTool = AdvisorTool(model: 'claude-opus-4-8');
      final toolDef = ToolDefinition.builtIn(advisorTool);
      final json = toolDef.toJson();

      expect(json['type'], 'advisor_20260301');
      expect(json['name'], 'advisor');
      expect(json['model'], 'claude-opus-4-8');
    });

    test('equality', () {
      const a = AdvisorTool(model: 'claude-opus-4-8');
      const b = AdvisorTool(model: 'claude-opus-4-8');
      const c = AdvisorTool(model: 'claude-opus-4-8', maxUses: 3);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('copyWith', () {
      const original = AdvisorTool(model: 'claude-opus-4-8');

      final withMaxUses = original.copyWith(maxUses: 5);
      expect(withMaxUses.model, 'claude-opus-4-8');
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
      const tool = AdvisorTool(model: 'claude-opus-4-8');
      expect(tool.toString(), contains('AdvisorTool'));
      expect(tool.toString(), contains('claude-opus-4-8'));
    });

    test('ToolDefinition.fromJson routes advisor tool correctly', () {
      final json = {
        'type': 'advisor_20260301',
        'name': 'advisor',
        'model': 'claude-opus-4-8',
      };
      final toolDef = ToolDefinition.fromJson(json);

      expect(toolDef, isA<BuiltInToolDefinition>());
      final builtIn = (toolDef as BuiltInToolDefinition).tool;
      expect(builtIn, isA<AdvisorTool>());
      expect((builtIn as AdvisorTool).model, 'claude-opus-4-8');
    });

    test('toJson includes allowed_callers, defer_loading, strict', () {
      const tool = AdvisorTool(
        model: 'claude-opus-4-8',
        allowedCallers: ['direct', 'code_execution_20260120'],
        deferLoading: true,
        strict: true,
      );
      final json = tool.toJson();

      expect(json['allowed_callers'], ['direct', 'code_execution_20260120']);
      expect(json['defer_loading'], true);
      expect(json['strict'], true);
    });

    test('fromJson round-trip with parity fields', () {
      final json = {
        'type': 'advisor_20260301',
        'name': 'advisor',
        'model': 'claude-opus-4-8',
        'allowed_callers': ['direct'],
        'defer_loading': false,
        'strict': true,
      };
      final tool = AdvisorTool.fromJson(json);

      expect(tool.allowedCallers, ['direct']);
      expect(tool.deferLoading, false);
      expect(tool.strict, true);
      expect(tool.toJson(), json);
    });

    test('BuiltInTool.advisor forwards parity fields', () {
      final tool =
          BuiltInTool.advisor(
                model: 'claude-opus-4-8',
                allowedCallers: const ['direct'],
                deferLoading: true,
                strict: true,
              )
              as AdvisorTool;

      expect(tool.allowedCallers, ['direct']);
      expect(tool.deferLoading, true);
      expect(tool.strict, true);
    });

    test('copyWith updates and clears parity fields', () {
      const original = AdvisorTool(
        model: 'claude-opus-4-8',
        allowedCallers: ['direct'],
        deferLoading: true,
        strict: true,
      );

      final updated = original.copyWith(allowedCallers: const ['direct', 'x']);
      expect(updated.allowedCallers, ['direct', 'x']);
      expect(updated.deferLoading, true);

      final cleared = original.copyWith(
        allowedCallers: null,
        deferLoading: null,
        strict: null,
      );
      expect(cleared.allowedCallers, isNull);
      expect(cleared.deferLoading, isNull);
      expect(cleared.strict, isNull);
    });

    test('equality includes parity fields', () {
      const a = AdvisorTool(model: 'claude-opus-4-8', strict: true);
      const b = AdvisorTool(model: 'claude-opus-4-8', strict: true);
      const c = AdvisorTool(model: 'claude-opus-4-8', strict: false);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
