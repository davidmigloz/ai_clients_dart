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

    test('explicit null is null but present as null in toJson', () {
      final config = ModelParamsConfig.fromJson(const {
        'id': 'claude-opus-4-8',
        'effort': null,
      });
      expect(config.effort, isNull);
      expect(config.clearEffort, isTrue);
      expect(config.toJson().containsKey('effort'), isTrue);
      expect(config.toJson()['effort'], isNull);
    });

    test('clearEffort: true emits an explicit JSON null', () {
      const config = ModelParamsConfig(
        id: 'claude-opus-4-8',
        clearEffort: true,
      );
      expect(config.effort, isNull);
      expect(config.toJson().containsKey('effort'), isTrue);
      expect(config.toJson()['effort'], isNull);
    });

    test('passing both effort and clearEffort: true asserts', () {
      expect(
        () => ModelParamsConfig(
          id: 'claude-opus-4-8',
          effort: const EffortParamsLevel(EffortLevel.high),
          clearEffort: true,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('fromJson round-trips omitted, explicit null, and set states', () {
      final omitted = ModelParamsConfig.fromJson(const {
        'id': 'claude-opus-4-8',
      });
      expect(omitted.clearEffort, isFalse);
      expect(omitted.toJson(), const {'id': 'claude-opus-4-8'});

      final explicitNull = ModelParamsConfig.fromJson(const {
        'id': 'claude-opus-4-8',
        'effort': null,
      });
      expect(explicitNull.clearEffort, isTrue);
      expect(explicitNull.toJson(), const {
        'id': 'claude-opus-4-8',
        'effort': null,
      });

      final set = ModelParamsConfig.fromJson(const {
        'id': 'claude-opus-4-8',
        'effort': 'high',
      });
      expect(set.clearEffort, isFalse);
      expect(set.toJson(), const {'id': 'claude-opus-4-8', 'effort': 'high'});
    });

    test(
      'copyWith replaces effort, clears to explicit null, and preserves',
      () {
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

        final cleared = config.copyWith(effort: null);
        expect(cleared.effort, isNull);
        expect(cleared.toJson()['effort'], isNull);

        final preserved = config.copyWith();
        expect(preserved.effort, isA<EffortParamsLevel>());
        expect(preserved.toJson()['effort'], 'low');

        final reset = cleared.copyWith(
          effort: const EffortParamsLevel(EffortLevel.medium),
        );
        expect(reset.clearEffort, isFalse);
        expect(reset.toJson()['effort'], 'medium');

        final stillCleared = cleared.copyWith();
        expect(stillCleared.clearEffort, isTrue);
        expect(stillCleared.toJson()['effort'], isNull);
      },
    );

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
