import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

void main() {
  group('FunctionCallStatus', () {
    test('fromJson parses in_progress', () {
      expect(
        FunctionCallStatus.fromJson('in_progress'),
        FunctionCallStatus.inProgress,
      );
    });

    test('fromJson parses completed', () {
      expect(
        FunctionCallStatus.fromJson('completed'),
        FunctionCallStatus.completed,
      );
    });

    test('fromJson parses incomplete', () {
      expect(
        FunctionCallStatus.fromJson('incomplete'),
        FunctionCallStatus.incomplete,
      );
    });

    test('fromJson returns unknown for unrecognized values', () {
      expect(
        FunctionCallStatus.fromJson('some_new_status'),
        FunctionCallStatus.unknown,
      );
      expect(FunctionCallStatus.fromJson(''), FunctionCallStatus.unknown);
    });

    test('toJson returns correct value', () {
      expect(FunctionCallStatus.inProgress.toJson(), 'in_progress');
      expect(FunctionCallStatus.completed.toJson(), 'completed');
      expect(FunctionCallStatus.incomplete.toJson(), 'incomplete');
      expect(FunctionCallStatus.unknown.toJson(), 'unknown');
    });

    test('round-trip serialization', () {
      for (final status in FunctionCallStatus.values) {
        final json = status.toJson();
        final parsed = FunctionCallStatus.fromJson(json);
        expect(parsed, status);
      }
    });
  });

  group('StreamOptions', () {
    test('fromJson parses includeObfuscation true', () {
      final options = StreamOptions.fromJson(const {
        'include_obfuscation': true,
      });
      expect(options.includeObfuscation, true);
    });

    test('fromJson parses includeObfuscation false', () {
      final options = StreamOptions.fromJson(const {
        'include_obfuscation': false,
      });
      expect(options.includeObfuscation, false);
    });

    test('fromJson handles null includeObfuscation', () {
      final options = StreamOptions.fromJson(const {});
      expect(options.includeObfuscation, isNull);
    });

    test('toJson includes includeObfuscation when set', () {
      const options = StreamOptions(includeObfuscation: true);
      expect(options.toJson(), {'include_obfuscation': true});
    });

    test('toJson omits includeObfuscation when null', () {
      const options = StreamOptions();
      expect(options.toJson(), isEmpty);
    });

    test('equality works correctly', () {
      const a = StreamOptions(includeObfuscation: true);
      const b = StreamOptions(includeObfuscation: true);
      const c = StreamOptions(includeObfuscation: false);
      const d = StreamOptions();

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a, isNot(equals(d)));
      expect(c, isNot(equals(d)));
    });

    test('hashCode is consistent with equality', () {
      const a = StreamOptions(includeObfuscation: true);
      const b = StreamOptions(includeObfuscation: true);

      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes field value', () {
      const options = StreamOptions(includeObfuscation: true);
      expect(options.toString(), contains('includeObfuscation: true'));
    });

    test('round-trip serialization', () {
      const original = StreamOptions(includeObfuscation: false);
      final json = original.toJson();
      final parsed = StreamOptions.fromJson(json);

      expect(parsed, equals(original));
    });
  });

  group('ServiceTier', () {
    test('known values match static constants', () {
      expect(ServiceTier.fromJson('auto'), ServiceTier.auto);
      expect(ServiceTier.fromJson('default'), ServiceTier.defaultTier);
      expect(ServiceTier.fromJson('flex'), ServiceTier.flex);
      expect(ServiceTier.fromJson('priority'), ServiceTier.priority);
    });

    test('preserves unknown provider-specific values', () {
      final tier = ServiceTier.fromJson('batch');
      expect(tier.value, 'batch');
      expect(tier.toJson(), 'batch');
    });

    test('round-trip preserves custom values', () {
      final tier = ServiceTier.fromJson('my-custom-tier');
      expect(ServiceTier.fromJson(tier.toJson()), tier);
    });

    test('toJson returns correct string', () {
      expect(ServiceTier.auto.toJson(), 'auto');
      expect(ServiceTier.defaultTier.toJson(), 'default');
      expect(ServiceTier.flex.toJson(), 'flex');
      expect(ServiceTier.priority.toJson(), 'priority');
    });

    test('equality based on value', () {
      expect(ServiceTier.auto, ServiceTier.auto);
      expect(ServiceTier.auto, isNot(ServiceTier.flex));
      expect(const ServiceTier('custom'), const ServiceTier('custom'));
    });
  });
}
