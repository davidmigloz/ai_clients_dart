import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

/// Helper to create a minimal [Response] for lifecycle events.
Response _makeResponse({ResponseStatus status = ResponseStatus.completed}) {
  return Response(
    id: 'resp_test',
    object: 'response',
    createdAt: 1700000000,
    status: status,
    output: const <OutputItem>[],
  );
}

void main() {
  group('isFinal', () {
    test('ResponseCompletedEvent is final', () {
      final event = ResponseCompletedEvent(response: _makeResponse());
      expect(event.isFinal, isTrue);
    });

    test('ResponseFailedEvent is final', () {
      final event = ResponseFailedEvent(
        response: _makeResponse(status: ResponseStatus.failed),
      );
      expect(event.isFinal, isTrue);
    });

    test('ResponseIncompleteEvent is final', () {
      final event = ResponseIncompleteEvent(
        response: _makeResponse(status: ResponseStatus.incomplete),
      );
      expect(event.isFinal, isTrue);
    });

    test('ResponseCreatedEvent is not final', () {
      final event = ResponseCreatedEvent(
        response: _makeResponse(status: ResponseStatus.queued),
      );
      expect(event.isFinal, isFalse);
    });

    test('ResponseInProgressEvent is not final', () {
      final event = ResponseInProgressEvent(
        response: _makeResponse(status: ResponseStatus.inProgress),
      );
      expect(event.isFinal, isFalse);
    });

    test('OutputTextDeltaEvent is not final', () {
      const event = OutputTextDeltaEvent(
        outputIndex: 0,
        contentIndex: 0,
        delta: 'hello',
      );
      expect(event.isFinal, isFalse);
    });

    test('FunctionCallArgumentsDeltaEvent is not final', () {
      const event = FunctionCallArgumentsDeltaEvent(
        outputIndex: 0,
        delta: '{"arg":',
      );
      expect(event.isFinal, isFalse);
    });

    test('ReasoningTextDeltaEvent is not final', () {
      const event = ReasoningTextDeltaEvent(
        outputIndex: 0,
        delta: 'thinking...',
      );
      expect(event.isFinal, isFalse);
    });
  });

  group('textDeltas', () {
    test('filters to only text delta strings', () async {
      final events = <ResponseStreamEvent>[
        ResponseCreatedEvent(
          response: _makeResponse(status: ResponseStatus.queued),
        ),
        const OutputTextDeltaEvent(
          outputIndex: 0,
          contentIndex: 0,
          delta: 'Hello',
        ),
        const FunctionCallArgumentsDeltaEvent(outputIndex: 1, delta: '{"key":'),
        const OutputTextDeltaEvent(
          outputIndex: 0,
          contentIndex: 0,
          delta: ' world',
        ),
        ResponseCompletedEvent(response: _makeResponse()),
      ];

      final stream = Stream.fromIterable(events);
      final deltas = await stream.textDeltas().toList();

      expect(deltas, equals(['Hello', ' world']));
    });

    test('returns empty stream when no text deltas', () async {
      final events = <ResponseStreamEvent>[
        ResponseCreatedEvent(
          response: _makeResponse(status: ResponseStatus.queued),
        ),
        const FunctionCallArgumentsDeltaEvent(outputIndex: 0, delta: '{}'),
        ResponseCompletedEvent(response: _makeResponse()),
      ];

      final stream = Stream.fromIterable(events);
      final deltas = await stream.textDeltas().toList();

      expect(deltas, isEmpty);
    });
  });

  group('collectText', () {
    test('collects all text deltas into a single string', () async {
      final events = <ResponseStreamEvent>[
        ResponseCreatedEvent(
          response: _makeResponse(status: ResponseStatus.queued),
        ),
        const OutputTextDeltaEvent(
          outputIndex: 0,
          contentIndex: 0,
          delta: 'Hello',
        ),
        const OutputTextDeltaEvent(
          outputIndex: 0,
          contentIndex: 0,
          delta: ', ',
        ),
        const OutputTextDeltaEvent(
          outputIndex: 0,
          contentIndex: 0,
          delta: 'world!',
        ),
        ResponseCompletedEvent(response: _makeResponse()),
      ];

      final stream = Stream.fromIterable(events);
      final text = await stream.collectText();

      expect(text, equals('Hello, world!'));
    });

    test('returns empty string when no text deltas', () async {
      final events = <ResponseStreamEvent>[
        ResponseCreatedEvent(
          response: _makeResponse(status: ResponseStatus.queued),
        ),
        ResponseCompletedEvent(response: _makeResponse()),
      ];

      final stream = Stream.fromIterable(events);
      final text = await stream.collectText();

      expect(text, isEmpty);
    });

    test('ignores non-text events', () async {
      final events = <ResponseStreamEvent>[
        const ReasoningTextDeltaEvent(outputIndex: 0, delta: 'thinking...'),
        const OutputTextDeltaEvent(
          outputIndex: 0,
          contentIndex: 0,
          delta: 'result',
        ),
        const FunctionCallArgumentsDeltaEvent(
          outputIndex: 1,
          delta: '{"x": 1}',
        ),
      ];

      final stream = Stream.fromIterable(events);
      final text = await stream.collectText();

      expect(text, equals('result'));
    });
  });

  group('accumulate', () {
    test('returns progressive accumulator snapshots', () async {
      final events = <ResponseStreamEvent>[
        ResponseCreatedEvent(
          response: _makeResponse(status: ResponseStatus.queued),
        ),
        const OutputTextDeltaEvent(
          outputIndex: 0,
          contentIndex: 0,
          delta: 'Hi',
        ),
        const OutputTextDeltaEvent(
          outputIndex: 0,
          contentIndex: 0,
          delta: ' there',
        ),
        ResponseCompletedEvent(response: _makeResponse()),
      ];

      final stream = Stream.fromIterable(events);
      final snapshots = await stream.accumulate().toList();

      // One snapshot per event
      expect(snapshots, hasLength(4));

      // The same accumulator instance is yielded each time,
      // so the last snapshot reflects the final accumulated state.
      final last = snapshots.last;
      expect(last.text, equals('Hi there'));
      expect(last.isComplete, isTrue);
      expect(last.isSuccessful, isTrue);
      expect(last.responseId, equals('resp_test'));
    });

    test('accumulates function call arguments', () async {
      final events = <ResponseStreamEvent>[
        ResponseInProgressEvent(
          response: _makeResponse(status: ResponseStatus.inProgress),
        ),
        const FunctionCallArgumentsDeltaEvent(
          outputIndex: 0,
          itemId: 'call_1',
          delta: '{"loc',
        ),
        const FunctionCallArgumentsDeltaEvent(
          outputIndex: 0,
          itemId: 'call_1',
          delta: 'ation": "NYC"}',
        ),
        ResponseCompletedEvent(response: _makeResponse()),
      ];

      final stream = Stream.fromIterable(events);
      final snapshots = await stream.accumulate().toList();
      final last = snapshots.last;

      expect(last.functionArguments, equals({'call_1': '{"location": "NYC"}'}));
    });

    test('accumulates reasoning text', () async {
      final events = <ResponseStreamEvent>[
        const ReasoningTextDeltaEvent(outputIndex: 0, delta: 'Let me '),
        const ReasoningTextDeltaEvent(outputIndex: 0, delta: 'think...'),
        const OutputTextDeltaEvent(
          outputIndex: 0,
          contentIndex: 0,
          delta: 'Answer',
        ),
        ResponseCompletedEvent(response: _makeResponse()),
      ];

      final stream = Stream.fromIterable(events);
      final snapshots = await stream.accumulate().toList();
      final last = snapshots.last;

      expect(last.reasoning, equals('Let me think...'));
      expect(last.text, equals('Answer'));
    });

    test('tracks failure status', () async {
      final events = <ResponseStreamEvent>[
        ResponseCreatedEvent(
          response: _makeResponse(status: ResponseStatus.queued),
        ),
        ResponseFailedEvent(
          response: _makeResponse(status: ResponseStatus.failed),
        ),
      ];

      final stream = Stream.fromIterable(events);
      final snapshots = await stream.accumulate().toList();
      final last = snapshots.last;

      expect(last.isComplete, isTrue);
      expect(last.isFailed, isTrue);
      expect(last.isSuccessful, isFalse);
    });
  });
}
