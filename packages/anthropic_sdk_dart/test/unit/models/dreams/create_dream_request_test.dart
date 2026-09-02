import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CreateDreamRequest', () {
    test('fromJson/toJson round-trip with a bare model-id string', () {
      const json = {
        'inputs': [
          {'type': 'memory_store', 'memory_store_id': 'memstore_in'},
          {
            'type': 'sessions',
            'session_ids': ['s1'],
          },
        ],
        'instructions': 'Focus on preferences.',
        'model': 'claude-opus-4-7',
      };
      final request = CreateDreamRequest.fromJson(json);

      expect(request.inputs, hasLength(2));
      expect(request.inputs[0], isA<DreamMemoryStoreInput>());
      expect(request.inputs[1], isA<DreamSessionsInput>());
      expect(request.instructions, 'Focus on preferences.');
      expect(request.model, isA<DreamModelParamsId>());
      expect(request.toJson(), json);
    });

    test('fromJson/toJson round-trip with a model config object', () {
      const json = {
        'inputs': [
          {'type': 'memory_store', 'memory_store_id': 'memstore_in'},
        ],
        'model': {'id': 'claude-opus-4-7', 'speed': 'fast'},
      };
      final request = CreateDreamRequest.fromJson(json);
      expect(request.model, isA<DreamModelConfigParams>());
      expect(request.instructions, isNull);
      expect(request.toJson(), json);
      expect(request.toJson().containsKey('instructions'), isFalse);
    });

    test('copyWith replaces and clears instructions', () {
      const request = CreateDreamRequest(
        inputs: [DreamMemoryStoreInput(memoryStoreId: 'm1')],
        instructions: 'a',
        model: DreamModelParamsId(id: 'claude-opus-4-7'),
      );
      expect(request.copyWith(instructions: 'b').instructions, 'b');
      expect(request.copyWith(instructions: null).instructions, isNull);
      expect(request.copyWith().instructions, 'a');
    });

    test('equality and hashCode', () {
      const a = CreateDreamRequest(
        inputs: [DreamMemoryStoreInput(memoryStoreId: 'm1')],
        model: DreamModelParamsId(id: 'claude-opus-4-7'),
      );
      const b = CreateDreamRequest(
        inputs: [DreamMemoryStoreInput(memoryStoreId: 'm1')],
        model: DreamModelParamsId(id: 'claude-opus-4-7'),
      );
      const c = CreateDreamRequest(
        inputs: [DreamMemoryStoreInput(memoryStoreId: 'm2')],
        model: DreamModelParamsId(id: 'claude-opus-4-7'),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('toString includes input count and model', () {
      const request = CreateDreamRequest(
        inputs: [DreamMemoryStoreInput(memoryStoreId: 'm1')],
        model: DreamModelParamsId(id: 'claude-opus-4-7'),
      );
      expect(request.toString(), contains('inputs: 1 items'));
    });

    test('outputBehavior is omitted from toJson when absent', () {
      const request = CreateDreamRequest(
        inputs: [DreamMemoryStoreInput(memoryStoreId: 'm1')],
        model: DreamModelParamsId(id: 'claude-opus-4-7'),
      );
      expect(request.outputBehavior, isNull);
      expect(request.toJson().containsKey('output_behavior'), isFalse);
    });

    test('outputBehavior round-trips create_new', () {
      const json = {
        'inputs': [
          {'type': 'memory_store', 'memory_store_id': 'memstore_in'},
        ],
        'model': 'claude-opus-4-7',
        'output_behavior': {'type': 'create_new'},
      };
      final request = CreateDreamRequest.fromJson(json);
      expect(request.outputBehavior, isA<OutputBehaviorCreateNew>());
      expect(request.toJson(), json);
    });

    test('outputBehavior round-trips update_existing', () {
      const json = {
        'inputs': [
          {'type': 'memory_store', 'memory_store_id': 'memstore_in'},
        ],
        'model': 'claude-opus-4-7',
        'output_behavior': {
          'type': 'update_existing',
          'memory_store_id': 'memstore_out',
        },
      };
      final request = CreateDreamRequest.fromJson(json);
      final behavior = request.outputBehavior! as OutputBehaviorUpdateExisting;
      expect(behavior.memoryStoreId, 'memstore_out');
      expect(request.toJson(), json);
    });

    test('copyWith replaces and clears outputBehavior', () {
      const request = CreateDreamRequest(
        inputs: [DreamMemoryStoreInput(memoryStoreId: 'm1')],
        model: DreamModelParamsId(id: 'claude-opus-4-7'),
        outputBehavior: OutputBehaviorCreateNew(),
      );
      expect(request.copyWith(outputBehavior: null).outputBehavior, isNull);
      expect(request.copyWith().outputBehavior, isA<OutputBehaviorCreateNew>());
    });
  });
}
