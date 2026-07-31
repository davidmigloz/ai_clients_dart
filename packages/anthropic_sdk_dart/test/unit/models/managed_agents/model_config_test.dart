import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ModelConfig.effort', () {
    test('fromJson parses the object wire form', () {
      final config = ModelConfig.fromJson(const {
        'id': 'claude-opus-4-8',
        'effort': {'type': 'high'},
      });
      expect(config.effort, EffortLevel.high);
    });

    test('toJson emits the object wire form', () {
      const config = ModelConfig(
        id: 'claude-opus-4-8',
        effort: EffortLevel.high,
      );
      expect(config.toJson()['effort'], {'type': 'high'});
    });

    test('is null and omitted from toJson when absent', () {
      final config = ModelConfig.fromJson(const {'id': 'claude-opus-4-8'});
      expect(config.effort, isNull);
      expect(config.toJson().containsKey('effort'), isFalse);
    });

    test('round-trips through fromJson/toJson', () {
      const json = {
        'id': 'claude-opus-4-8',
        'speed': 'fast',
        'effort': {'type': 'xhigh'},
      };
      final config = ModelConfig.fromJson(json);
      expect(config.toJson(), json);
    });

    test('copyWith replaces and clears effort', () {
      const config = ModelConfig(
        id: 'claude-opus-4-8',
        effort: EffortLevel.low,
      );
      expect(config.copyWith(effort: EffortLevel.max).effort, EffortLevel.max);
      expect(config.copyWith(effort: null).effort, isNull);
      expect(config.copyWith().effort, EffortLevel.low);
    });

    test('equality and hashCode include effort', () {
      const a = ModelConfig(id: 'claude-opus-4-8', effort: EffortLevel.high);
      const b = ModelConfig(id: 'claude-opus-4-8', effort: EffortLevel.high);
      const c = ModelConfig(id: 'claude-opus-4-8', effort: EffortLevel.low);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('toString includes effort', () {
      const config = ModelConfig(
        id: 'claude-opus-4-8',
        effort: EffortLevel.medium,
      );
      expect(config.toString(), contains('effort: EffortLevel.medium'));
    });
  });

  group('ModelParamsConfig.effort', () {
    test('fromJson parses a bare level string via EffortParams', () {
      final config = ModelParamsConfig.fromJson(const {
        'id': 'claude-opus-4-8',
        'effort': 'high',
      });
      expect(config.effort, isA<EffortParamsLevel>());
      expect((config.effort! as EffortParamsLevel).level, EffortLevel.high);
      expect(config.toJson()['effort'], 'high');
    });

    test('fromJson parses the object wire form via EffortParams', () {
      final config = ModelParamsConfig.fromJson(const {
        'id': 'claude-opus-4-8',
        'effort': {'type': 'max'},
      });
      expect(config.effort, isA<EffortParamsObject>());
      expect((config.effort! as EffortParamsObject).level, EffortLevel.max);
      expect(config.toJson()['effort'], {'type': 'max'});
    });

    test('is null and omitted from toJson when absent', () {
      final config = ModelParamsConfig.fromJson(const {
        'id': 'claude-opus-4-8',
      });
      expect(config.effort, isNull);
      expect(config.toJson().containsKey('effort'), isFalse);
    });

    test('copyWith replaces and clears effort', () {
      const config = ModelParamsConfig(
        id: 'claude-opus-4-8',
        effort: EffortParamsLevel(EffortLevel.low),
      );
      expect(
        config
            .copyWith(effort: const EffortParamsObject(EffortLevel.max))
            .effort,
        isA<EffortParamsObject>(),
      );
      expect(config.copyWith(effort: null).effort, isNull);
      expect(config.copyWith().effort, isA<EffortParamsLevel>());
    });

    test('equality and hashCode include effort', () {
      const a = ModelParamsConfig(
        id: 'claude-opus-4-8',
        effort: EffortParamsLevel(EffortLevel.high),
      );
      const b = ModelParamsConfig(
        id: 'claude-opus-4-8',
        effort: EffortParamsLevel(EffortLevel.high),
      );
      const c = ModelParamsConfig(
        id: 'claude-opus-4-8',
        effort: EffortParamsObject(EffortLevel.high),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('EffortParams', () {
    test('fromJson dispatches String to EffortParamsLevel', () {
      final params = EffortParams.fromJson('medium');
      expect(params, isA<EffortParamsLevel>());
      expect((params as EffortParamsLevel).level, EffortLevel.medium);
      expect(params.toJson(), 'medium');
    });

    test('fromJson dispatches Map to EffortParamsObject', () {
      final params = EffortParams.fromJson(const {'type': 'xhigh'});
      expect(params, isA<EffortParamsObject>());
      expect((params as EffortParamsObject).level, EffortLevel.xhigh);
      expect(params.toJson(), {'type': 'xhigh'});
    });

    test('equality and hashCode', () {
      const a = EffortParamsLevel(EffortLevel.high);
      const b = EffortParamsLevel(EffortLevel.high);
      const objA = EffortParamsObject(EffortLevel.high);
      const objB = EffortParamsObject(EffortLevel.high);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(objA, equals(objB));
      expect(objA.hashCode, equals(objB.hashCode));
      expect(a, isNot(equals(objA)));
    });

    test('toString includes the level', () {
      expect(
        const EffortParamsLevel(EffortLevel.high).toString(),
        contains('EffortLevel.high'),
      );
      expect(
        const EffortParamsObject(EffortLevel.max).toString(),
        contains('EffortLevel.max'),
      );
    });
  });
}
