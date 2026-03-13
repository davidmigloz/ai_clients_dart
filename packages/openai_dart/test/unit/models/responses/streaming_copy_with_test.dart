import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

/// Helper to create a minimal [Response] for lifecycle events.
Response _makeResponse({
  String id = 'resp_test',
  ResponseStatus status = ResponseStatus.completed,
}) {
  return Response(
    id: id,
    object: 'response',
    createdAt: 1700000000,
    status: status,
    output: const <OutputItem>[],
  );
}

void main() {
  group('ResponseCreatedEvent copyWith', () {
    final original = ResponseCreatedEvent(
      response: _makeResponse(id: 'resp_1', status: ResponseStatus.queued),
      sequenceNumber: 1,
    );

    test('no changes returns equal object', () {
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('changes response field', () {
      final newResponse = _makeResponse(id: 'resp_2');
      final copy = original.copyWith(response: newResponse);

      expect(copy.response.id, equals('resp_2'));
      expect(copy.sequenceNumber, equals(1));
    });

    test('sets nullable sequenceNumber to null', () {
      final copy = original.copyWith(sequenceNumber: null);

      expect(copy.sequenceNumber, isNull);
      expect(copy.response, equals(original.response));
    });

    test('sets nullable sequenceNumber to new value', () {
      final copy = original.copyWith(sequenceNumber: 42);

      expect(copy.sequenceNumber, equals(42));
    });
  });

  group('ResponseCompletedEvent copyWith', () {
    final original = ResponseCompletedEvent(
      response: _makeResponse(),
      sequenceNumber: 10,
    );

    test('no changes returns equal object', () {
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('changes response', () {
      final newResponse = _makeResponse(id: 'resp_new');
      final copy = original.copyWith(response: newResponse);

      expect(copy.response.id, equals('resp_new'));
      expect(copy.isFinal, isTrue);
    });

    test('sets sequenceNumber to null', () {
      final copy = original.copyWith(sequenceNumber: null);
      expect(copy.sequenceNumber, isNull);
    });
  });

  group('OutputTextDeltaEvent copyWith', () {
    const original = OutputTextDeltaEvent(
      outputIndex: 0,
      contentIndex: 1,
      delta: 'hello',
      itemId: 'item_1',
      sequenceNumber: 5,
    );

    test('no changes returns equal object', () {
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('changes required fields', () {
      final copy = original.copyWith(
        outputIndex: 2,
        contentIndex: 3,
        delta: 'world',
      );

      expect(copy.outputIndex, equals(2));
      expect(copy.contentIndex, equals(3));
      expect(copy.delta, equals('world'));
      // Unchanged fields preserved
      expect(copy.itemId, equals('item_1'));
      expect(copy.sequenceNumber, equals(5));
    });

    test('sets nullable itemId to null', () {
      final copy = original.copyWith(itemId: null);

      expect(copy.itemId, isNull);
      expect(copy.delta, equals('hello'));
    });

    test('sets nullable itemId to new value', () {
      final copy = original.copyWith(itemId: 'item_2');
      expect(copy.itemId, equals('item_2'));
    });

    test('sets nullable logprobs to null', () {
      const withLogprobs = OutputTextDeltaEvent(
        outputIndex: 0,
        contentIndex: 0,
        delta: 'hi',
        logprobs: <LogProb>[],
      );
      final copy = withLogprobs.copyWith(logprobs: null);
      expect(copy.logprobs, isNull);
    });

    test('sets nullable sequenceNumber to null', () {
      final copy = original.copyWith(sequenceNumber: null);
      expect(copy.sequenceNumber, isNull);
    });
  });

  group('FunctionCallArgumentsDeltaEvent copyWith', () {
    const original = FunctionCallArgumentsDeltaEvent(
      outputIndex: 0,
      delta: '{"key":',
      itemId: 'call_1',
      sequenceNumber: 3,
    );

    test('no changes returns equal object', () {
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('changes required fields', () {
      final copy = original.copyWith(outputIndex: 1, delta: '"value"}');

      expect(copy.outputIndex, equals(1));
      expect(copy.delta, equals('"value"}'));
      expect(copy.itemId, equals('call_1'));
    });

    test('sets nullable itemId to null', () {
      final copy = original.copyWith(itemId: null);
      expect(copy.itemId, isNull);
    });

    test('sets nullable itemId to new value', () {
      final copy = original.copyWith(itemId: 'call_2');
      expect(copy.itemId, equals('call_2'));
    });

    test('sets nullable sequenceNumber to null', () {
      final copy = original.copyWith(sequenceNumber: null);
      expect(copy.sequenceNumber, isNull);
    });
  });

  group('ReasoningTextDeltaEvent copyWith', () {
    const original = ReasoningTextDeltaEvent(
      outputIndex: 0,
      delta: 'thinking',
      itemId: 'reason_1',
      contentIndex: 2,
      sequenceNumber: 7,
    );

    test('no changes returns equal object', () {
      final copy = original.copyWith();
      expect(copy, equals(original));
    });

    test('changes required fields', () {
      final copy = original.copyWith(outputIndex: 1, delta: 'harder');

      expect(copy.outputIndex, equals(1));
      expect(copy.delta, equals('harder'));
      expect(copy.itemId, equals('reason_1'));
      expect(copy.contentIndex, equals(2));
    });

    test('sets nullable itemId to null', () {
      final copy = original.copyWith(itemId: null);
      expect(copy.itemId, isNull);
    });

    test('sets nullable contentIndex to null', () {
      final copy = original.copyWith(contentIndex: null);
      expect(copy.contentIndex, isNull);
    });

    test('sets nullable contentIndex to new value', () {
      final copy = original.copyWith(contentIndex: 5);
      expect(copy.contentIndex, equals(5));
    });

    test('sets nullable sequenceNumber to null', () {
      final copy = original.copyWith(sequenceNumber: null);
      expect(copy.sequenceNumber, isNull);
    });

    test('sets multiple nullable fields at once', () {
      final copy = original.copyWith(
        itemId: null,
        contentIndex: null,
        sequenceNumber: null,
      );

      expect(copy.itemId, isNull);
      expect(copy.contentIndex, isNull);
      expect(copy.sequenceNumber, isNull);
      // Required fields preserved
      expect(copy.outputIndex, equals(0));
      expect(copy.delta, equals('thinking'));
    });
  });
}
