import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DreamModelConfig', () {
    test('fromJson/toJson round-trip with speed', () {
      const json = {'id': 'claude-opus-4-7', 'speed': 'fast'};
      final config = DreamModelConfig.fromJson(json);
      expect(config.id, 'claude-opus-4-7');
      expect(config.speed, AgentSpeed.fast);
      expect(config.toJson(), json);
    });

    test('speed is null and omitted from toJson when absent', () {
      final config = DreamModelConfig.fromJson(const {'id': 'claude-opus-4-7'});
      expect(config.speed, isNull);
      expect(config.toJson().containsKey('speed'), isFalse);
    });

    test('copyWith replaces and clears speed', () {
      const config = DreamModelConfig(
        id: 'claude-opus-4-7',
        speed: AgentSpeed.standard,
      );
      expect(config.copyWith(speed: AgentSpeed.fast).speed, AgentSpeed.fast);
      expect(config.copyWith(speed: null).speed, isNull);
      expect(config.copyWith().speed, AgentSpeed.standard);
    });

    test('equality and hashCode', () {
      const a = DreamModelConfig(id: 'x', speed: AgentSpeed.fast);
      const b = DreamModelConfig(id: 'x', speed: AgentSpeed.fast);
      const c = DreamModelConfig(id: 'x', speed: AgentSpeed.standard);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('toString includes all fields', () {
      const config = DreamModelConfig(id: 'x', speed: AgentSpeed.fast);
      expect(config.toString(), contains('id: x'));
      expect(config.toString(), contains('speed: AgentSpeed.fast'));
    });
  });

  group('DreamModelParams', () {
    test('fromJson dispatches a bare string to DreamModelParamsId', () {
      final params = DreamModelParams.fromJson('claude-opus-4-7');
      expect(params, isA<DreamModelParamsId>());
      expect((params as DreamModelParamsId).id, 'claude-opus-4-7');
      expect(params.toJson(), 'claude-opus-4-7');
    });

    test('fromJson dispatches a Map to DreamModelConfigParams', () {
      final params = DreamModelParams.fromJson(const {
        'id': 'claude-opus-4-7',
        'speed': 'fast',
      });
      expect(params, isA<DreamModelConfigParams>());
      final config = params as DreamModelConfigParams;
      expect(config.id, 'claude-opus-4-7');
      expect(config.speed, AgentSpeed.fast);
      expect(params.toJson(), {'id': 'claude-opus-4-7', 'speed': 'fast'});
    });

    test('DreamModelParamsId equality/hashCode/toString', () {
      const a = DreamModelParamsId(id: 'x');
      const b = DreamModelParamsId(id: 'x');
      const c = DreamModelParamsId(id: 'y');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a.toString(), contains('id: x'));
    });

    test('DreamModelConfigParams speed omitted from toJson when absent', () {
      const config = DreamModelConfigParams(id: 'x');
      expect(config.toJson().containsKey('speed'), isFalse);
    });

    test('DreamModelConfigParams copyWith replaces and clears speed', () {
      const config = DreamModelConfigParams(id: 'x', speed: AgentSpeed.fast);
      expect(
        config.copyWith(speed: AgentSpeed.standard).speed,
        AgentSpeed.standard,
      );
      expect(config.copyWith(speed: null).speed, isNull);
      expect(config.copyWith().speed, AgentSpeed.fast);
    });

    test('DreamModelConfigParams equality/hashCode/toString', () {
      const a = DreamModelConfigParams(id: 'x', speed: AgentSpeed.fast);
      const b = DreamModelConfigParams(id: 'x', speed: AgentSpeed.fast);
      const c = DreamModelConfigParams(id: 'x', speed: AgentSpeed.standard);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a.toString(), contains('speed: AgentSpeed.fast'));
    });
  });
}
