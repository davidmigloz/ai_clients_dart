import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OutputBehavior', () {
    test('create_new round-trips', () {
      const json = {'type': 'create_new'};
      final behavior = OutputBehavior.fromJson(json);
      expect(behavior, isA<OutputBehaviorCreateNew>());
      expect(behavior.toJson(), json);
    });

    test('OutputBehavior.createNew factory builds create_new', () {
      final behavior = OutputBehavior.createNew();
      expect(behavior, isA<OutputBehaviorCreateNew>());
      expect(behavior.toJson(), {'type': 'create_new'});
    });

    test('update_existing round-trips', () {
      const json = {
        'type': 'update_existing',
        'memory_store_id': 'memstore_out',
      };
      final behavior = OutputBehavior.fromJson(json);
      expect(behavior, isA<OutputBehaviorUpdateExisting>());
      expect(
        (behavior as OutputBehaviorUpdateExisting).memoryStoreId,
        'memstore_out',
      );
      expect(behavior.toJson(), json);
    });

    test('OutputBehavior.updateExisting factory builds update_existing', () {
      final behavior = OutputBehavior.updateExisting('memstore_out');
      expect(behavior, isA<OutputBehaviorUpdateExisting>());
      expect(
        (behavior as OutputBehaviorUpdateExisting).memoryStoreId,
        'memstore_out',
      );
    });

    test('update_existing copyWith replaces memoryStoreId', () {
      const behavior = OutputBehaviorUpdateExisting(
        memoryStoreId: 'memstore_a',
      );
      final updated = behavior.copyWith(memoryStoreId: 'memstore_b');
      expect(updated.memoryStoreId, 'memstore_b');
      expect(updated, isNot(behavior));
    });

    test('unknown type falls back to UnknownOutputBehavior', () {
      const json = {'type': 'mystery', 'foo': 'bar'};
      final behavior = OutputBehavior.fromJson(json);
      expect(behavior, isA<UnknownOutputBehavior>());
      expect(behavior.toJson(), json);
    });

    test('equality and hashCode', () {
      const a = OutputBehaviorUpdateExisting(memoryStoreId: 'm1');
      const b = OutputBehaviorUpdateExisting(memoryStoreId: 'm1');
      const c = OutputBehaviorUpdateExisting(memoryStoreId: 'm2');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(
        const OutputBehaviorCreateNew(),
        equals(const OutputBehaviorCreateNew()),
      );
    });
  });
}
