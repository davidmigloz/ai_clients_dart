import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ToolsetMemberConfig', () {
    test('round-trips enabled and deferLoading', () {
      final json = {'enabled': false, 'defer_loading': true};
      final config = ToolsetMemberConfig.fromJson(json);
      expect(config.enabled, isFalse);
      expect(config.deferLoading, isTrue);
      expect(config.toJson(), json);
    });

    test('omits null fields', () {
      const config = ToolsetMemberConfig();
      expect(config.toJson(), isEmpty);
    });

    test('copyWith / equality / toString', () {
      const a = ToolsetMemberConfig(enabled: true);
      const b = ToolsetMemberConfig(enabled: true);
      final c = a.copyWith(enabled: false);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(c.enabled, isFalse);
      expect(a.toString(), contains('ToolsetMemberConfig'));
    });
  });

  group('ComputerToolsetConfigs', () {
    test('round-trips only set keys', () {
      final json = {
        'zoom': {'enabled': false},
        'left_click': {'defer_loading': true},
      };
      final configs = ComputerToolsetConfigs.fromJson(json);
      expect(configs.zoom?.enabled, isFalse);
      expect(configs.leftClick?.deferLoading, isTrue);
      expect(configs.screenshot, isNull);
      expect(configs.toJson(), json);
    });

    test('type wire key maps to typeAction field', () {
      final json = {
        'type': {'enabled': false},
      };
      final configs = ComputerToolsetConfigs.fromJson(json);
      expect(configs.typeAction?.enabled, isFalse);
      expect(configs.toJson(), json);
    });

    test('empty configs serialize to an empty object', () {
      const configs = ComputerToolsetConfigs();
      expect(configs.toJson(), isEmpty);
    });

    test('copyWith updates a single member and preserves others', () {
      const configs = ComputerToolsetConfigs(
        zoom: ToolsetMemberConfig(enabled: false),
      );
      final updated = configs.copyWith(
        screenshot: const ToolsetMemberConfig(enabled: true),
      );
      expect(updated.zoom?.enabled, isFalse);
      expect(updated.screenshot?.enabled, isTrue);
    });

    test('equality and hashCode', () {
      const a = ComputerToolsetConfigs(
        zoom: ToolsetMemberConfig(enabled: false),
      );
      const b = ComputerToolsetConfigs(
        zoom: ToolsetMemberConfig(enabled: false),
      );
      const c = ComputerToolsetConfigs(
        zoom: ToolsetMemberConfig(enabled: true),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('BrowserToolsetConfigs', () {
    test('round-trips only set keys', () {
      final json = {
        'navigate': {'enabled': true},
        'read_page': {'defer_loading': false},
      };
      final configs = BrowserToolsetConfigs.fromJson(json);
      expect(configs.navigate?.enabled, isTrue);
      expect(configs.readPage?.deferLoading, isFalse);
      expect(configs.screenshot, isNull);
      expect(configs.toJson(), json);
    });

    test('type wire key maps to typeAction field', () {
      final json = {
        'type': {'enabled': false},
      };
      final configs = BrowserToolsetConfigs.fromJson(json);
      expect(configs.typeAction?.enabled, isFalse);
      expect(configs.toJson(), json);
    });

    test('empty configs serialize to an empty object', () {
      const configs = BrowserToolsetConfigs();
      expect(configs.toJson(), isEmpty);
    });
  });

  group('ComputerToolset', () {
    test('toJson with no configs', () {
      const tool = ComputerToolset();
      final json = tool.toJson();
      expect(json['type'], 'computer_toolset_20260801');
      expect(json.containsKey('configs'), isFalse);
      expect(json.containsKey('cache_control'), isFalse);
    });

    test('toJson with configs disabling zoom', () {
      const tool = ComputerToolset(
        configs: ComputerToolsetConfigs(
          zoom: ToolsetMemberConfig(enabled: false),
        ),
      );
      final json = tool.toJson();
      expect(json['configs'], {
        'zoom': {'enabled': false},
      });
    });

    test('BuiltInTool.fromJson dispatches to ComputerToolset, not '
        'ComputerUseTool', () {
      final json = {'type': 'computer_toolset_20260801'};
      final tool = BuiltInTool.fromJson(json);
      expect(tool, isA<ComputerToolset>());
      expect(tool, isNot(isA<ComputerUseTool>()));
    });

    test('ToolDefinition.fromJson dispatches to ComputerToolset', () {
      final json = {'type': 'computer_toolset_20260801'};
      final def = ToolDefinition.fromJson(json) as BuiltInToolDefinition;
      expect(def.tool, isA<ComputerToolset>());
    });

    test('BuiltInTool.computerToolset factory', () {
      final tool = BuiltInTool.computerToolset(
        configs: const ComputerToolsetConfigs(
          zoom: ToolsetMemberConfig(enabled: false),
        ),
      );
      expect(tool, isA<ComputerToolset>());
      expect((tool as ComputerToolset).configs?.zoom?.enabled, isFalse);
    });

    test('copyWith / equality / toString', () {
      const a = ComputerToolset();
      const b = ComputerToolset();
      final c = a.copyWith(
        configs: const ComputerToolsetConfigs(
          zoom: ToolsetMemberConfig(enabled: false),
        ),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(c.configs, isNotNull);
      expect(a.toString(), contains('ComputerToolset'));
    });
  });

  group('BrowserToolset', () {
    test('toJson with no configs', () {
      const tool = BrowserToolset();
      final json = tool.toJson();
      expect(json['type'], 'browser_toolset_20260801');
      expect(json.containsKey('configs'), isFalse);
    });

    test('BuiltInTool.fromJson dispatches to BrowserToolset', () {
      final json = {'type': 'browser_toolset_20260801'};
      final tool = BuiltInTool.fromJson(json);
      expect(tool, isA<BrowserToolset>());
    });

    test('ToolDefinition.fromJson dispatches to BrowserToolset (via the '
        'browser_toolset_ prefix)', () {
      final json = {'type': 'browser_toolset_20260801'};
      final def = ToolDefinition.fromJson(json) as BuiltInToolDefinition;
      expect(def.tool, isA<BrowserToolset>());
    });

    test('BuiltInTool.browserToolset factory', () {
      final tool = BuiltInTool.browserToolset(
        configs: const BrowserToolsetConfigs(
          navigate: ToolsetMemberConfig(enabled: false),
        ),
      );
      expect(tool, isA<BrowserToolset>());
      expect((tool as BrowserToolset).configs?.navigate?.enabled, isFalse);
    });

    test('copyWith / equality / toString', () {
      const a = BrowserToolset();
      const b = BrowserToolset();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), contains('BrowserToolset'));
    });
  });
}
