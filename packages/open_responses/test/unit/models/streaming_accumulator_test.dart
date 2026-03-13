import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

import '../../fixtures/responses.dart';

void main() {
  group('StreamingEventAccumulator', () {
    late StreamingEventAccumulator accumulator;

    setUp(() {
      accumulator = StreamingEventAccumulator();
    });

    test('starts with empty state', () {
      expect(accumulator.text, isEmpty);
      expect(accumulator.reasoning, isEmpty);
      expect(accumulator.functionArguments, isEmpty);
      expect(accumulator.response, isNull);
      expect(accumulator.latestEvent, isNull);
      expect(accumulator.isComplete, isFalse);
      expect(accumulator.isSuccessful, isFalse);
      expect(accumulator.isFailed, isFalse);
    });

    group('text accumulation', () {
      test('accumulates text deltas progressively', () {
        accumulator.add(
          const OutputTextDeltaEvent(
            sequenceNumber: 0,
            itemId: 'msg_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'Hello',
            logprobs: [],
          ),
        );
        expect(accumulator.text, 'Hello');

        accumulator.add(
          const OutputTextDeltaEvent(
            sequenceNumber: 1,
            itemId: 'msg_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: ' world',
            logprobs: [],
          ),
        );
        expect(accumulator.text, 'Hello world');

        accumulator.add(
          const OutputTextDeltaEvent(
            sequenceNumber: 2,
            itemId: 'msg_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: '!',
            logprobs: [],
          ),
        );
        expect(accumulator.text, 'Hello world!');
      });
    });

    group('reasoning accumulation', () {
      test('accumulates reasoning deltas', () {
        accumulator.add(
          const ReasoningDeltaEvent(
            sequenceNumber: 0,
            itemId: 'r_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'Step 1: ',
          ),
        );
        expect(accumulator.reasoning, 'Step 1: ');

        accumulator.add(
          const ReasoningDeltaEvent(
            sequenceNumber: 1,
            itemId: 'r_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'Analyze',
          ),
        );
        expect(accumulator.reasoning, 'Step 1: Analyze');
      });
    });

    group('function arguments accumulation', () {
      test('accumulates function arguments by item ID', () {
        accumulator
          ..add(
            const FunctionCallArgumentsDeltaEvent(
              sequenceNumber: 0,
              itemId: 'call_1',
              outputIndex: 0,
              delta: '{"loc',
            ),
          )
          ..add(
            const FunctionCallArgumentsDeltaEvent(
              sequenceNumber: 1,
              itemId: 'call_1',
              outputIndex: 0,
              delta: 'ation": "NYC"}',
            ),
          );
        expect(accumulator.functionArguments, {
          'call_1': '{"location": "NYC"}',
        });
      });

      test('tracks multiple function calls independently', () {
        accumulator
          ..add(
            const FunctionCallArgumentsDeltaEvent(
              sequenceNumber: 0,
              itemId: 'call_1',
              outputIndex: 0,
              delta: '{"a":1}',
            ),
          )
          ..add(
            const FunctionCallArgumentsDeltaEvent(
              sequenceNumber: 1,
              itemId: 'call_2',
              outputIndex: 1,
              delta: '{"b":2}',
            ),
          );
        expect(accumulator.functionArguments, {
          'call_1': '{"a":1}',
          'call_2': '{"b":2}',
        });
      });
    });

    group('status transitions', () {
      test('ResponseCompletedEvent sets isComplete and isSuccessful', () {
        final response = ResponseResource.fromJson(basicCompletedResponse());
        accumulator.add(
          ResponseCompletedEvent(sequenceNumber: 0, response: response),
        );
        expect(accumulator.isComplete, isTrue);
        expect(accumulator.isSuccessful, isTrue);
        expect(accumulator.isFailed, isFalse);
        expect(accumulator.response, isNotNull);
      });

      test('ResponseFailedEvent sets isComplete and isFailed', () {
        final response = ResponseResource.fromJson(failedResponse());
        accumulator.add(
          ResponseFailedEvent(sequenceNumber: 0, response: response),
        );
        expect(accumulator.isComplete, isTrue);
        expect(accumulator.isSuccessful, isFalse);
        expect(accumulator.isFailed, isTrue);
        expect(accumulator.response, isNotNull);
      });

      test('ResponseIncompleteEvent sets isComplete only', () {
        final response = ResponseResource.fromJson(incompleteResponse());
        accumulator.add(
          ResponseIncompleteEvent(sequenceNumber: 0, response: response),
        );
        expect(accumulator.isComplete, isTrue);
        expect(accumulator.isSuccessful, isFalse);
        expect(accumulator.isFailed, isFalse);
      });

      test('non-terminal events do not set isComplete', () {
        accumulator.add(
          ResponseCreatedEvent(
            sequenceNumber: 0,
            response: ResponseResource.fromJson(inProgressResponse()),
          ),
        );
        expect(accumulator.isComplete, isFalse);
      });
    });

    group('latestEvent tracking', () {
      test('latestEvent is updated on each add', () {
        const event1 = OutputTextDeltaEvent(
          sequenceNumber: 0,
          itemId: 'msg_1',
          outputIndex: 0,
          contentIndex: 0,
          delta: 'A',
          logprobs: [],
        );
        const event2 = OutputTextDeltaEvent(
          sequenceNumber: 1,
          itemId: 'msg_1',
          outputIndex: 0,
          contentIndex: 0,
          delta: 'B',
          logprobs: [],
        );

        accumulator.add(event1);
        expect(accumulator.latestEvent, event1);
        accumulator.add(event2);
        expect(accumulator.latestEvent, event2);
      });
    });

    group('reset', () {
      test('resets all state', () {
        // Build up some state
        accumulator
          ..add(
            const OutputTextDeltaEvent(
              sequenceNumber: 0,
              itemId: 'msg_1',
              outputIndex: 0,
              contentIndex: 0,
              delta: 'Hello',
              logprobs: [],
            ),
          )
          ..add(
            const ReasoningDeltaEvent(
              sequenceNumber: 1,
              itemId: 'r_1',
              outputIndex: 0,
              contentIndex: 0,
              delta: 'Think',
            ),
          )
          ..add(
            const FunctionCallArgumentsDeltaEvent(
              sequenceNumber: 2,
              itemId: 'call_1',
              outputIndex: 0,
              delta: '{}',
            ),
          )
          ..add(
            ResponseCompletedEvent(
              sequenceNumber: 3,
              response: ResponseResource.fromJson(basicCompletedResponse()),
            ),
          )
          ..reset();

        expect(accumulator.text, isEmpty);
        expect(accumulator.reasoning, isEmpty);
        expect(accumulator.functionArguments, isEmpty);
        expect(accumulator.response, isNull);
        expect(accumulator.latestEvent, isNull);
        expect(accumulator.isComplete, isFalse);
        expect(accumulator.isSuccessful, isFalse);
        expect(accumulator.isFailed, isFalse);
      });
    });

    group('snapshot', () {
      test('returns immutable snapshot of current state', () {
        accumulator.add(
          const OutputTextDeltaEvent(
            sequenceNumber: 0,
            itemId: 'msg_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'Hello',
            logprobs: [],
          ),
        );

        final snap = accumulator.snapshot;
        expect(snap.text, 'Hello');
        expect(snap.isComplete, isFalse);

        // Adding more data doesn't change the snapshot
        accumulator.add(
          const OutputTextDeltaEvent(
            sequenceNumber: 1,
            itemId: 'msg_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: ' world',
            logprobs: [],
          ),
        );

        expect(snap.text, 'Hello'); // snapshot is immutable
        expect(accumulator.text, 'Hello world');
      });

      test('snapshot reflects completion state', () {
        accumulator.add(
          ResponseCompletedEvent(
            sequenceNumber: 0,
            response: ResponseResource.fromJson(basicCompletedResponse()),
          ),
        );

        final snap = accumulator.snapshot;
        expect(snap.isComplete, isTrue);
        expect(snap.isSuccessful, isTrue);
        expect(snap.isFailed, isFalse);
        expect(snap.response, isNotNull);
      });
    });
  });

  group('Stream extensions', () {
    group('.accumulate()', () {
      test('emits progressive snapshots', () async {
        final events = Stream<StreamingEvent>.fromIterable([
          const OutputTextDeltaEvent(
            sequenceNumber: 0,
            itemId: 'msg_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'Hello',
            logprobs: [],
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 1,
            itemId: 'msg_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: ' world',
            logprobs: [],
          ),
          ResponseCompletedEvent(
            sequenceNumber: 2,
            response: ResponseResource.fromJson(basicCompletedResponse()),
          ),
        ]);

        final snapshots = await events.accumulate().toList();
        expect(snapshots, hasLength(3));
        expect(snapshots[0].text, 'Hello');
        expect(snapshots[0].isComplete, isFalse);
        expect(snapshots[1].text, 'Hello world');
        expect(snapshots[1].isComplete, isFalse);
        expect(snapshots[2].text, 'Hello world');
        expect(snapshots[2].isComplete, isTrue);
        expect(snapshots[2].isSuccessful, isTrue);
      });
    });

    group('.textDeltas', () {
      test('filters to only text deltas', () async {
        final events = Stream<StreamingEvent>.fromIterable([
          ResponseCreatedEvent(
            sequenceNumber: 0,
            response: ResponseResource.fromJson(inProgressResponse()),
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 1,
            itemId: 'msg_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'A',
            logprobs: [],
          ),
          const FunctionCallArgumentsDeltaEvent(
            sequenceNumber: 2,
            itemId: 'call_1',
            outputIndex: 1,
            delta: '{}',
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 3,
            itemId: 'msg_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'B',
            logprobs: [],
          ),
        ]);

        final deltas = await events.textDeltas.toList();
        expect(deltas, ['A', 'B']);
      });

      test('returns empty stream when no text events', () async {
        final events = Stream<StreamingEvent>.fromIterable([
          ResponseCreatedEvent(
            sequenceNumber: 0,
            response: ResponseResource.fromJson(inProgressResponse()),
          ),
        ]);

        final deltas = await events.textDeltas.toList();
        expect(deltas, isEmpty);
      });
    });

    group('.collectText()', () {
      test('collects all text into single string', () async {
        final events = Stream<StreamingEvent>.fromIterable([
          const OutputTextDeltaEvent(
            sequenceNumber: 0,
            itemId: 'msg_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'Hello',
            logprobs: [],
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 1,
            itemId: 'msg_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: ' ',
            logprobs: [],
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 2,
            itemId: 'msg_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'world!',
            logprobs: [],
          ),
        ]);

        final text = await events.collectText();
        expect(text, 'Hello world!');
      });

      test('returns empty string when no text events', () async {
        final events = Stream<StreamingEvent>.fromIterable([
          ResponseCreatedEvent(
            sequenceNumber: 0,
            response: ResponseResource.fromJson(inProgressResponse()),
          ),
          ResponseCompletedEvent(
            sequenceNumber: 1,
            response: ResponseResource.fromJson(basicCompletedResponse()),
          ),
        ]);

        final text = await events.collectText();
        expect(text, isEmpty);
      });

      test('ignores non-text events', () async {
        final events = Stream<StreamingEvent>.fromIterable([
          const OutputTextDeltaEvent(
            sequenceNumber: 0,
            itemId: 'msg_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'Text',
            logprobs: [],
          ),
          const FunctionCallArgumentsDeltaEvent(
            sequenceNumber: 1,
            itemId: 'call_1',
            outputIndex: 1,
            delta: '{"ignored": true}',
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 2,
            itemId: 'msg_1',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'Only',
            logprobs: [],
          ),
        ]);

        final text = await events.collectText();
        expect(text, 'TextOnly');
      });
    });
  });
}
