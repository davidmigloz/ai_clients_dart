import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DreamInput', () {
    test('fromJson dispatches memory_store to DreamMemoryStoreInput', () {
      final input = DreamInput.fromJson(const {
        'type': 'memory_store',
        'memory_store_id': 'memstore_1',
      });
      expect(input, isA<DreamMemoryStoreInput>());
      expect((input as DreamMemoryStoreInput).memoryStoreId, 'memstore_1');
      expect(input.toJson(), {
        'type': 'memory_store',
        'memory_store_id': 'memstore_1',
      });
    });

    test('fromJson dispatches sessions to DreamSessionsInput', () {
      final input = DreamInput.fromJson(const {
        'type': 'sessions',
        'session_ids': ['s1', 's2'],
      });
      expect(input, isA<DreamSessionsInput>());
      expect((input as DreamSessionsInput).sessionIds, ['s1', 's2']);
      expect(input.toJson(), {
        'type': 'sessions',
        'session_ids': ['s1', 's2'],
      });
    });

    test('fromJson falls back to UnknownDreamInput for unrecognized type', () {
      const json = {'type': 'something_new', 'foo': 'bar'};
      final input = DreamInput.fromJson(json);
      expect(input, isA<UnknownDreamInput>());
      expect((input as UnknownDreamInput).rawJson, json);
      expect(input.toJson(), json);
    });

    test(
      'DreamMemoryStoreInput.fromJson throws on mismatched discriminator',
      () {
        expect(
          () => DreamMemoryStoreInput.fromJson(const {
            'type': 'sessions',
            'memory_store_id': 'x',
          }),
          throwsFormatException,
        );
      },
    );

    test('DreamSessionsInput.fromJson throws on mismatched discriminator', () {
      expect(
        () => DreamSessionsInput.fromJson(const {
          'type': 'memory_store',
          'session_ids': <String>[],
        }),
        throwsFormatException,
      );
    });

    test('DreamMemoryStoreInput copyWith/equality/toString', () {
      const a = DreamMemoryStoreInput(memoryStoreId: 'm1');
      const b = DreamMemoryStoreInput(memoryStoreId: 'm1');
      const c = DreamMemoryStoreInput(memoryStoreId: 'm2');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a.copyWith(memoryStoreId: 'm2').memoryStoreId, 'm2');
      expect(a.toString(), contains('memoryStoreId: m1'));
    });

    test('DreamSessionsInput copyWith/equality/toString', () {
      const a = DreamSessionsInput(sessionIds: ['s1']);
      const b = DreamSessionsInput(sessionIds: ['s1']);
      const c = DreamSessionsInput(sessionIds: ['s2']);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a.copyWith(sessionIds: ['s2']).sessionIds, ['s2']);
      expect(a.toString(), contains('sessionIds: [s1]'));
    });

    test('UnknownDreamInput uses deep equality for nested payloads', () {
      const a = UnknownDreamInput(
        rawJson: {
          'type': 'x',
          'nested': {'a': 1},
        },
      );
      const b = UnknownDreamInput(
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
