import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DreamOutput', () {
    test('fromJson dispatches memory_store to DreamMemoryStoreOutput', () {
      final output = DreamOutput.fromJson(const {
        'type': 'memory_store',
        'memory_store_id': 'memstore_out1',
      });
      expect(output, isA<DreamMemoryStoreOutput>());
      expect((output as DreamMemoryStoreOutput).memoryStoreId, 'memstore_out1');
      expect(output.toJson(), {
        'type': 'memory_store',
        'memory_store_id': 'memstore_out1',
      });
    });

    test('fromJson falls back to UnknownDreamOutput for unrecognized type', () {
      const json = {'type': 'something_new', 'foo': 'bar'};
      final output = DreamOutput.fromJson(json);
      expect(output, isA<UnknownDreamOutput>());
      expect((output as UnknownDreamOutput).rawJson, json);
      expect(output.toJson(), json);
    });

    test(
      'DreamMemoryStoreOutput.fromJson throws on mismatched discriminator',
      () {
        expect(
          () => DreamMemoryStoreOutput.fromJson(const {
            'type': 'sessions',
            'memory_store_id': 'x',
          }),
          throwsFormatException,
        );
      },
    );

    test('DreamMemoryStoreOutput copyWith/equality/toString', () {
      const a = DreamMemoryStoreOutput(memoryStoreId: 'm1');
      const b = DreamMemoryStoreOutput(memoryStoreId: 'm1');
      const c = DreamMemoryStoreOutput(memoryStoreId: 'm2');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a.copyWith(memoryStoreId: 'm2').memoryStoreId, 'm2');
      expect(a.toString(), contains('memoryStoreId: m1'));
    });

    test('UnknownDreamOutput uses deep equality for nested payloads', () {
      const a = UnknownDreamOutput(
        rawJson: {
          'type': 'x',
          'nested': {'a': 1},
        },
      );
      const b = UnknownDreamOutput(
        rawJson: {
          'type': 'x',
          'nested': {'a': 1},
        },
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
