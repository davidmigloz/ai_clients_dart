import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _dreamJson({
  String status = 'completed',
  String? endedAt = '2026-04-25T01:00:00.000Z',
  String? archivedAt,
  Map<String, dynamic>? error,
  String? instructions = 'Consolidate notes.',
  String? sessionId,
  Map<String, dynamic> outputBehavior = const {'type': 'create_new'},
}) {
  return {
    'type': 'dream',
    'id': 'dream_test123',
    'inputs': [
      {'type': 'memory_store', 'memory_store_id': 'memstore_in'},
    ],
    'outputs': [
      {'type': 'memory_store', 'memory_store_id': 'memstore_out'},
    ],
    'status': status,
    'created_at': '2026-04-25T00:00:00.000Z',
    'ended_at': endedAt,
    'archived_at': archivedAt,
    'error': error,
    'model': {'id': 'claude-opus-4-7', 'speed': 'standard'},
    'instructions': instructions,
    'session_id': sessionId,
    'usage': {
      'input_tokens': 100,
      'output_tokens': 50,
      'cache_read_input_tokens': 10,
      'cache_creation_input_tokens': 5,
    },
    'output_behavior': outputBehavior,
  };
}

void main() {
  group('Dream', () {
    test('fromJson/toJson round-trip', () {
      final json = _dreamJson();
      final dream = Dream.fromJson(json);

      expect(dream.type, 'dream');
      expect(dream.id, 'dream_test123');
      expect(dream.inputs, hasLength(1));
      expect(dream.inputs.single, isA<DreamMemoryStoreInput>());
      expect(dream.outputs.single, isA<DreamMemoryStoreOutput>());
      expect(dream.status, DreamStatus.completed);
      expect(dream.createdAt, DateTime.parse('2026-04-25T00:00:00.000Z'));
      expect(dream.endedAt, DateTime.parse('2026-04-25T01:00:00.000Z'));
      expect(dream.archivedAt, isNull);
      expect(dream.error, isNull);
      expect(dream.model.id, 'claude-opus-4-7');
      expect(dream.instructions, 'Consolidate notes.');
      expect(dream.sessionId, isNull);
      expect(dream.usage.inputTokens, 100);
      expect(dream.outputBehavior, isA<OutputBehaviorCreateNew>());

      expect(dream.toJson(), json);
    });

    test('parses an update_existing output behavior', () {
      final dream = Dream.fromJson(
        _dreamJson(
          outputBehavior: const {
            'type': 'update_existing',
            'memory_store_id': 'memstore_out',
          },
        ),
      );
      final behavior = dream.outputBehavior as OutputBehaviorUpdateExisting;
      expect(behavior.memoryStoreId, 'memstore_out');
      expect(dream.toJson()['output_behavior'], {
        'type': 'update_existing',
        'memory_store_id': 'memstore_out',
      });
    });

    test('required-nullable fields always emit the key even when null', () {
      final dream = Dream.fromJson(
        _dreamJson(
          status: 'pending',
          endedAt: null,
          archivedAt: null,
          error: null,
          instructions: null,
          sessionId: null,
        ),
      );
      final body = dream.toJson();
      expect(body.containsKey('ended_at'), isTrue);
      expect(body['ended_at'], isNull);
      expect(body.containsKey('archived_at'), isTrue);
      expect(body['archived_at'], isNull);
      expect(body.containsKey('error'), isTrue);
      expect(body['error'], isNull);
      expect(body.containsKey('instructions'), isTrue);
      expect(body['instructions'], isNull);
      expect(body.containsKey('session_id'), isTrue);
      expect(body['session_id'], isNull);
    });

    test('throws FormatException when output_behavior is missing', () {
      final json = _dreamJson()..remove('output_behavior');
      expect(() => Dream.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('throws FormatException when output_behavior is null', () {
      final json = _dreamJson()..['output_behavior'] = null;
      expect(() => Dream.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('parses a failed dream with error detail', () {
      final dream = Dream.fromJson(
        _dreamJson(
          status: 'failed',
          error: const {'type': 'internal_error', 'message': 'boom'},
        ),
      );
      expect(dream.status, DreamStatus.failed);
      expect(dream.error, isNotNull);
      expect(dream.error!.type, 'internal_error');
      expect(dream.error!.message, 'boom');
      expect(dream.toJson()['error'], {
        'type': 'internal_error',
        'message': 'boom',
      });
    });

    test('unknown status falls back to DreamStatus.unknown', () {
      final dream = Dream.fromJson(_dreamJson(status: 'something_new'));
      expect(dream.status, DreamStatus.unknown);
    });

    test('unknown status round-trips the raw wire value', () {
      final json = _dreamJson(status: 'something_new');
      final dream = Dream.fromJson(json);
      expect(dream.status, DreamStatus.unknown);
      expect(dream.rawStatus, 'something_new');
      expect(dream.toJson()['status'], 'something_new');
    });

    test('unknown input/output types round-trip via unknown fallbacks', () {
      final json = _dreamJson();
      json['inputs'] = [
        {'type': 'something_new', 'foo': 'bar'},
      ];
      json['outputs'] = [
        {'type': 'something_new', 'baz': 'qux'},
      ];
      final dream = Dream.fromJson(json);
      expect(dream.inputs.single, isA<UnknownDreamInput>());
      expect(dream.outputs.single, isA<UnknownDreamOutput>());
      expect(dream.toJson()['inputs'], json['inputs']);
      expect(dream.toJson()['outputs'], json['outputs']);
    });

    test('copyWith replaces and clears nullable fields', () {
      final dream = Dream.fromJson(_dreamJson());

      final withArchive = dream.copyWith(archivedAt: DateTime.utc(2026, 5));
      expect(withArchive.archivedAt, DateTime.utc(2026, 5));
      expect(withArchive.id, dream.id);

      final cleared = dream.copyWith(instructions: null);
      expect(cleared.instructions, isNull);

      final unchanged = dream.copyWith();
      expect(unchanged.instructions, dream.instructions);
      expect(unchanged.endedAt, dream.endedAt);
    });

    test('equality and hashCode', () {
      final a = Dream.fromJson(_dreamJson());
      final b = Dream.fromJson(_dreamJson());
      final c = Dream.fromJson(_dreamJson(status: 'failed'));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('toString includes all fields with list counts', () {
      final dream = Dream.fromJson(_dreamJson());
      final str = dream.toString();
      expect(str, contains('id: dream_test123'));
      expect(str, contains('inputs: 1 items'));
      expect(str, contains('outputs: 1 items'));
      expect(str, contains('status: DreamStatus.completed'));
      expect(str, contains('usage: '));
    });
  });
}
