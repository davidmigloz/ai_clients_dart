import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('MountMode', () {
    test('round-trips known values and falls back to unknown', () {
      expect(MountMode.fromJson('read_write'), MountMode.readWrite);
      expect(MountMode.fromJson('read_only'), MountMode.readOnly);
      expect(MountMode.fromJson('something_new'), MountMode.unknown);
      expect(MountMode.readWrite.toJson(), 'read_write');
      expect(MountMode.readOnly.toJson(), 'read_only');
    });
  });

  group('MemoryView', () {
    test('round-trips known values and falls back to unknown', () {
      expect(MemoryView.fromJson('basic'), MemoryView.basic);
      expect(MemoryView.fromJson('full'), MemoryView.full);
      expect(MemoryView.fromJson('xyz'), MemoryView.unknown);
      expect(MemoryView.basic.toJson(), 'basic');
      expect(MemoryView.full.toJson(), 'full');
    });
  });

  group('MemoryVersionOperation', () {
    test('round-trips known values and falls back to unknown', () {
      for (final op in MemoryVersionOperation.values) {
        if (op == MemoryVersionOperation.unknown) continue;
        expect(MemoryVersionOperation.fromJson(op.value), op);
        expect(op.toJson(), op.value);
      }
      expect(
        MemoryVersionOperation.fromJson('newop'),
        MemoryVersionOperation.unknown,
      );
    });
  });

  group('ManagedAgentActor', () {
    test('parses each variant and round-trips', () {
      final cases = [
        {'type': 'session_actor', 'session_id': 'sess_1'},
        {'type': 'api_actor', 'api_key_id': 'apikey_1'},
        {'type': 'user_actor', 'user_id': 'usr_1'},
      ];
      final expectedTypes = [SessionActor, ApiActor, UserActor];
      for (var i = 0; i < cases.length; i++) {
        final actor = ManagedAgentActor.fromJson(cases[i]);
        expect(actor.runtimeType, expectedTypes[i]);
        expect(actor.toJson(), cases[i]);
      }
    });

    test('falls back to UnknownManagedAgentActor for unknown type', () {
      final raw = {'type': 'robot_actor', 'name': 'r2d2'};
      final actor = ManagedAgentActor.fromJson(raw);
      expect(actor, isA<UnknownManagedAgentActor>());
      // Unknown variant preserves raw JSON.
      expect(actor.toJson(), raw);
    });

    test('equality and hashCode are content-based', () {
      const a = SessionActor(sessionId: 's1');
      const b = SessionActor(sessionId: 's1');
      const c = SessionActor(sessionId: 's2');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  group('MemoryStore', () {
    Map<String, dynamic> fixture({String? archivedAt}) {
      return {
        'type': 'memory_store',
        'id': 'memstore_1',
        'name': 'My Store',
        'description': 'desc',
        'metadata': {'k': 'v'},
        'created_at': '2026-04-25T00:00:00.000Z',
        'updated_at': '2026-04-25T01:00:00.000Z',
        'archived_at': ?archivedAt,
      };
    }

    test('fromJson / toJson round-trips', () {
      final store = MemoryStore.fromJson(fixture());
      expect(store.id, 'memstore_1');
      expect(store.name, 'My Store');
      expect(store.description, 'desc');
      expect(store.metadata, {'k': 'v'});
      expect(store.archivedAt, isNull);
      expect(store.toJson()['metadata'], {'k': 'v'});
    });

    test('archivedAt is parsed when present', () {
      final store = MemoryStore.fromJson(
        fixture(archivedAt: '2026-04-25T02:00:00.000Z'),
      );
      expect(store.archivedAt, isNotNull);
    });

    test('metadata is unmodifiable', () {
      final store = MemoryStore.fromJson(fixture());
      expect(() => store.metadata!['k2'] = 'v2', throwsUnsupportedError);
    });

    test('copyWith with explicit null clears nullable fields', () {
      final store = MemoryStore.fromJson(fixture());
      final cleared = store.copyWith(description: null, metadata: null);
      expect(cleared.description, isNull);
      expect(cleared.metadata, isNull);
    });
  });

  group('UpdateMemoryStoreParams', () {
    test('toJson omits unset fields', () {
      const p = UpdateMemoryStoreParams(name: 'New name');
      expect(p.toJson(), {'name': 'New name'});
    });

    test('toJson emits explicit null for clearable fields', () {
      const p = UpdateMemoryStoreParams(description: null);
      expect(p.toJson(), const {'description': null});
    });

    test('metadata patch supports null values for delete', () {
      const p = UpdateMemoryStoreParams(
        metadata: <String, String?>{'a': null, 'b': 'v'},
      );
      final json = p.toJson();
      expect(json['metadata'], const {'a': null, 'b': 'v'});
    });

    test('fromJson preserves unset vs null distinction', () {
      final preserved = UpdateMemoryStoreParams.fromJson(const {});
      expect(preserved.toJson(), isEmpty);

      final cleared = UpdateMemoryStoreParams.fromJson(const {
        'description': null,
      });
      expect(cleared.toJson(), const {'description': null});
    });
  });

  group('MemoryListItem', () {
    test('parses Memory variant and round-trips', () {
      final raw = {
        'type': 'memory',
        'id': 'mem_1',
        'memory_store_id': 'memstore_1',
        'path': '/foo.md',
        'content_size_bytes': 5,
        'content_sha256': 'abc',
        'memory_version_id': 'memver_1',
        'created_at': '2026-04-25T00:00:00.000Z',
        'updated_at': '2026-04-25T00:00:00.000Z',
      };
      final item = MemoryListItem.fromJson(raw);
      expect(item, isA<Memory>());
      // Round-trip serializes 'created_at'/'updated_at' as UTC ISO 8601.
      final out = item.toJson();
      expect(out['type'], 'memory');
      expect(out['id'], 'mem_1');
      expect(out['memory_store_id'], 'memstore_1');
    });

    test('parses MemoryPrefix variant', () {
      final item = MemoryListItem.fromJson({
        'type': 'memory_prefix',
        'path': '/sub/',
      });
      expect(item, isA<MemoryPrefix>());
      expect(item.toJson(), {'type': 'memory_prefix', 'path': '/sub/'});
    });

    test('falls back to UnknownMemoryListItem for unknown type', () {
      final raw = {'type': 'memory_blob', 'foo': 'bar'};
      final item = MemoryListItem.fromJson(raw);
      expect(item, isA<UnknownMemoryListItem>());
      expect(item.toJson(), raw);
    });
  });

  group('MemoryPrecondition', () {
    test('parses ContentSha256Precondition and round-trips', () {
      final raw = {'type': 'content_sha256', 'content_sha256': 'abc'};
      final p = MemoryPrecondition.fromJson(raw);
      expect(p, isA<ContentSha256Precondition>());
      expect(p.toJson(), raw);
    });

    test('falls back to UnknownMemoryPrecondition for unknown type', () {
      final raw = {'type': 'etag', 'etag': 'W/"123"'};
      final p = MemoryPrecondition.fromJson(raw);
      expect(p, isA<UnknownMemoryPrecondition>());
      expect(p.toJson(), raw);
    });
  });

  group('MemoryStoreSessionResource (sealed extension)', () {
    test(
      'SessionResource.fromJson dispatches to MemoryStoreSessionResource',
      () {
        final raw = {
          'type': 'memory_store',
          'memory_store_id': 'memstore_1',
          'name': 'name',
          'instructions': 'use carefully',
          'access': 'read_only',
        };
        final resource = SessionResource.fromJson(raw);
        expect(resource, isA<MemoryStoreSessionResource>());
        final mem = resource as MemoryStoreSessionResource;
        expect(mem.memoryStoreId, 'memstore_1');
        expect(mem.access, MountMode.readOnly);
        expect(mem.toJson()['type'], 'memory_store');
      },
    );

    test(
      'SessionResourceParams.fromJson dispatches to memory_store variant',
      () {
        final raw = {
          'type': 'memory_store',
          'memory_store_id': 'memstore_2',
          'access': 'read_write',
        };
        final params = SessionResourceParams.fromJson(raw);
        expect(params, isA<MemoryStoreSessionResourceParams>());
        final mem = params as MemoryStoreSessionResourceParams;
        expect(mem.access, MountMode.readWrite);
      },
    );
  });
}
