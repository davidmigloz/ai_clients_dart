import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

import '../../fixtures/responses.dart';

void main() {
  group('StreamingEventExtensions', () {
    group('textDelta', () {
      test('returns delta from OutputTextDeltaEvent', () {
        const event = OutputTextDeltaEvent(
          sequenceNumber: 0,
          itemId: 'msg_001',
          outputIndex: 0,
          contentIndex: 0,
          delta: 'Hello',
          logprobs: [],
        );

        expect(event.textDelta, equals('Hello'));
      });

      test('returns null for ResponseCreatedEvent', () {
        final json = basicCompletedResponse();
        final event = ResponseCreatedEvent(
          sequenceNumber: 0,
          response: ResponseResource.fromJson(json),
        );

        expect(event.textDelta, isNull);
      });

      test('returns null for ResponseCompletedEvent', () {
        final json = basicCompletedResponse();
        final event = ResponseCompletedEvent(
          sequenceNumber: 0,
          response: ResponseResource.fromJson(json),
        );

        expect(event.textDelta, isNull);
      });

      test('returns null for FunctionCallArgumentsDeltaEvent', () {
        const event = FunctionCallArgumentsDeltaEvent(
          sequenceNumber: 0,
          itemId: 'call_001',
          outputIndex: 0,
          delta: '{"loc',
        );

        expect(event.textDelta, isNull);
      });
    });

    group('isFinal', () {
      test('returns true for ResponseCompletedEvent', () {
        final json = basicCompletedResponse();
        final event = ResponseCompletedEvent(
          sequenceNumber: 0,
          response: ResponseResource.fromJson(json),
        );

        expect(event.isFinal, isTrue);
      });

      test('returns true for ResponseFailedEvent', () {
        final json = failedResponse();
        final event = ResponseFailedEvent(
          sequenceNumber: 0,
          response: ResponseResource.fromJson(json),
        );

        expect(event.isFinal, isTrue);
      });

      test('returns true for ResponseIncompleteEvent', () {
        final json = incompleteResponse();
        final event = ResponseIncompleteEvent(
          sequenceNumber: 0,
          response: ResponseResource.fromJson(json),
        );

        expect(event.isFinal, isTrue);
      });

      test('returns false for ResponseCreatedEvent', () {
        final json = inProgressResponse();
        final event = ResponseCreatedEvent(
          sequenceNumber: 0,
          response: ResponseResource.fromJson(json),
        );

        expect(event.isFinal, isFalse);
      });

      test('returns false for OutputTextDeltaEvent', () {
        const event = OutputTextDeltaEvent(
          sequenceNumber: 0,
          itemId: 'msg_001',
          outputIndex: 0,
          contentIndex: 0,
          delta: 'Hello',
          logprobs: [],
        );

        expect(event.isFinal, isFalse);
      });

      test('returns false for ResponseInProgressEvent', () {
        final json = inProgressResponse();
        final event = ResponseInProgressEvent(
          sequenceNumber: 0,
          response: ResponseResource.fromJson(json),
        );

        expect(event.isFinal, isFalse);
      });
    });
  });

  group('StreamingEventsExtensions', () {
    group('text', () {
      test('accumulates all OutputTextDeltaEvent deltas', () async {
        final events = _createStreamFromJsonList(
          basicStreamingEvents(outputText: 'Hello!'),
        );

        final text = await events.text;

        expect(text, equals('Hello!'));
      });

      test('accumulates multiple text deltas', () async {
        final events = Stream<StreamingEvent>.fromIterable([
          const OutputTextDeltaEvent(
            sequenceNumber: 0,
            itemId: 'msg_001',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'Hello',
            logprobs: [],
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 1,
            itemId: 'msg_001',
            outputIndex: 0,
            contentIndex: 0,
            delta: ' ',
            logprobs: [],
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 2,
            itemId: 'msg_001',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'world',
            logprobs: [],
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 3,
            itemId: 'msg_001',
            outputIndex: 0,
            contentIndex: 0,
            delta: '!',
            logprobs: [],
          ),
        ]);

        final text = await events.text;

        expect(text, equals('Hello world!'));
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

        final text = await events.text;

        expect(text, isEmpty);
      });

      test('ignores non-text events', () async {
        final events = Stream<StreamingEvent>.fromIterable([
          ResponseCreatedEvent(
            sequenceNumber: 0,
            response: ResponseResource.fromJson(inProgressResponse()),
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 1,
            itemId: 'msg_001',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'Hello',
            logprobs: [],
          ),
          const FunctionCallArgumentsDeltaEvent(
            sequenceNumber: 2,
            itemId: 'call_001',
            outputIndex: 1,
            delta: '{"x": 1}',
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 3,
            itemId: 'msg_001',
            outputIndex: 0,
            contentIndex: 0,
            delta: ' world',
            logprobs: [],
          ),
        ]);

        final text = await events.text;

        expect(text, equals('Hello world'));
      });
    });

    group('finalResponse', () {
      test('returns ResponseResource from ResponseCompletedEvent', () async {
        final completedJson = basicCompletedResponse(id: 'resp_final');
        final events = Stream<StreamingEvent>.fromIterable([
          ResponseCreatedEvent(
            sequenceNumber: 0,
            response: ResponseResource.fromJson(inProgressResponse()),
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 1,
            itemId: 'msg_001',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'Hello',
            logprobs: [],
          ),
          ResponseCompletedEvent(
            sequenceNumber: 2,
            response: ResponseResource.fromJson(completedJson),
          ),
        ]);

        final response = await events.finalResponse;

        expect(response, isNotNull);
        expect(response!.id, equals('resp_final'));
        expect(response.isCompleted, isTrue);
      });

      test('returns null when no completion event', () async {
        final events = Stream<StreamingEvent>.fromIterable([
          ResponseCreatedEvent(
            sequenceNumber: 0,
            response: ResponseResource.fromJson(inProgressResponse()),
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 1,
            itemId: 'msg_001',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'Hello',
            logprobs: [],
          ),
        ]);

        final response = await events.finalResponse;

        expect(response, isNull);
      });

      test('returns null for failed stream (no completed event)', () async {
        final events = Stream<StreamingEvent>.fromIterable([
          ResponseCreatedEvent(
            sequenceNumber: 0,
            response: ResponseResource.fromJson(inProgressResponse()),
          ),
          ResponseFailedEvent(
            sequenceNumber: 1,
            response: ResponseResource.fromJson(failedResponse()),
          ),
        ]);

        final response = await events.finalResponse;

        expect(response, isNull);
      });
    });

    group('textDeltas', () {
      test('filters stream to only text deltas', () async {
        final events = Stream<StreamingEvent>.fromIterable([
          ResponseCreatedEvent(
            sequenceNumber: 0,
            response: ResponseResource.fromJson(inProgressResponse()),
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 1,
            itemId: 'msg_001',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'Hello',
            logprobs: [],
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 2,
            itemId: 'msg_001',
            outputIndex: 0,
            contentIndex: 0,
            delta: ' world',
            logprobs: [],
          ),
          ResponseCompletedEvent(
            sequenceNumber: 3,
            response: ResponseResource.fromJson(basicCompletedResponse()),
          ),
        ]);

        final deltas = await events.textDeltas.toList();

        expect(deltas, equals(['Hello', ' world']));
      });

      test('returns empty stream when no text delta events', () async {
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

        final deltas = await events.textDeltas.toList();

        expect(deltas, isEmpty);
      });

      test('maps to string values correctly', () async {
        final events = Stream<StreamingEvent>.fromIterable([
          const OutputTextDeltaEvent(
            sequenceNumber: 0,
            itemId: 'msg_001',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'A',
            logprobs: [],
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 1,
            itemId: 'msg_001',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'B',
            logprobs: [],
          ),
          const OutputTextDeltaEvent(
            sequenceNumber: 2,
            itemId: 'msg_001',
            outputIndex: 0,
            contentIndex: 0,
            delta: 'C',
            logprobs: [],
          ),
        ]);

        final deltas = await events.textDeltas.toList();

        expect(deltas, equals(['A', 'B', 'C']));
      });
    });
  });
}

/// Creates a stream of StreamingEvent from a list of JSON maps.
Stream<StreamingEvent> _createStreamFromJsonList(
  List<Map<String, dynamic>> jsonList,
) {
  return Stream.fromIterable(jsonList.map(StreamingEvent.fromJson));
}
