import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  final inputItem = MessageItem.userText('hello');
  final inputItemJson = inputItem.toJson();

  group('ResponseInjectEvent', () {
    test('round-trips through JSON', () {
      final event = ResponseInjectEvent(
        responseId: 'resp_123',
        input: [inputItem],
      );

      final json = event.toJson();
      expect(json, {
        'type': 'response.inject',
        'response_id': 'resp_123',
        'input': [inputItemJson],
      });

      final decoded = ResponseInjectEvent.fromJson(json);
      expect(decoded, event);
      expect(decoded.type, 'response.inject');
    });

    test('supports equality/hashCode', () {
      final a = ResponseInjectEvent(responseId: 'resp_1', input: [inputItem]);
      final b = ResponseInjectEvent(responseId: 'resp_1', input: [inputItem]);
      final c = ResponseInjectEvent(responseId: 'resp_2', input: [inputItem]);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('supports copyWith', () {
      final event = ResponseInjectEvent(
        responseId: 'resp_1',
        input: [inputItem],
      );
      final updated = event.copyWith(responseId: 'resp_2');

      expect(updated.responseId, 'resp_2');
      expect(updated.input, event.input);
    });
  });

  group('ResponseInjectCreatedEvent', () {
    test('round-trips through JSON with stream_id', () {
      const event = ResponseInjectCreatedEvent(
        responseId: 'resp_123',
        sequenceNumber: 5,
        streamId: 'stream_1',
      );

      final json = event.toJson();
      expect(json, {
        'type': 'response.inject.created',
        'response_id': 'resp_123',
        'sequence_number': 5,
        'stream_id': 'stream_1',
      });

      expect(ResponseInjectCreatedEvent.fromJson(json), event);
    });

    test('omits stream_id when null', () {
      const event = ResponseInjectCreatedEvent(
        responseId: 'resp_123',
        sequenceNumber: 5,
      );

      final json = event.toJson();
      expect(json.containsKey('stream_id'), isFalse);

      final decoded = ResponseInjectCreatedEvent.fromJson(json);
      expect(decoded, event);
      expect(decoded.streamId, isNull);
    });

    test('supports equality/hashCode', () {
      const a = ResponseInjectCreatedEvent(
        responseId: 'resp_1',
        sequenceNumber: 1,
      );
      const b = ResponseInjectCreatedEvent(
        responseId: 'resp_1',
        sequenceNumber: 1,
      );
      const c = ResponseInjectCreatedEvent(
        responseId: 'resp_1',
        sequenceNumber: 2,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('supports copyWith clearing stream_id', () {
      const event = ResponseInjectCreatedEvent(
        responseId: 'resp_1',
        sequenceNumber: 1,
        streamId: 'stream_1',
      );
      final updated = event.copyWith(streamId: null);

      expect(updated.streamId, isNull);
    });
  });

  group('ResponseInjectFailedEvent', () {
    test('round-trips through JSON with stream_id', () {
      final event = ResponseInjectFailedEvent(
        responseId: 'resp_123',
        input: [inputItem],
        error: const ResponseInjectError(
          code: ResponseInjectErrorCode.responseNotFound,
          message: 'No active response found.',
        ),
        sequenceNumber: 7,
        streamId: 'stream_1',
      );

      final json = event.toJson();
      expect(json, {
        'type': 'response.inject.failed',
        'response_id': 'resp_123',
        'input': [inputItemJson],
        'error': {
          'code': 'response_not_found',
          'message': 'No active response found.',
        },
        'sequence_number': 7,
        'stream_id': 'stream_1',
      });

      expect(ResponseInjectFailedEvent.fromJson(json), event);
    });

    test('omits stream_id when null', () {
      final event = ResponseInjectFailedEvent(
        responseId: 'resp_123',
        input: [inputItem],
        error: const ResponseInjectError(
          code: ResponseInjectErrorCode.responseAlreadyCompleted,
          message: 'Response already completed.',
        ),
        sequenceNumber: 7,
      );

      final json = event.toJson();
      expect(json.containsKey('stream_id'), isFalse);

      final decoded = ResponseInjectFailedEvent.fromJson(json);
      expect(decoded, event);
      expect(decoded.streamId, isNull);
    });

    test('supports equality/hashCode', () {
      const error = ResponseInjectError(
        code: ResponseInjectErrorCode.responseNotFound,
        message: 'not found',
      );
      final a = ResponseInjectFailedEvent(
        responseId: 'resp_1',
        input: [inputItem],
        error: error,
        sequenceNumber: 1,
      );
      final b = ResponseInjectFailedEvent(
        responseId: 'resp_1',
        input: [inputItem],
        error: error,
        sequenceNumber: 1,
      );
      final c = ResponseInjectFailedEvent(
        responseId: 'resp_1',
        input: [inputItem],
        error: error,
        sequenceNumber: 2,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('supports copyWith', () {
      final event = ResponseInjectFailedEvent(
        responseId: 'resp_1',
        input: [inputItem],
        error: const ResponseInjectError(
          code: ResponseInjectErrorCode.responseNotFound,
          message: 'not found',
        ),
        sequenceNumber: 1,
      );
      final updated = event.copyWith(sequenceNumber: 2);

      expect(updated.sequenceNumber, 2);
      expect(updated.responseId, event.responseId);
    });
  });

  group('ResponseInjectErrorCode', () {
    test('round-trips known values', () {
      expect(
        ResponseInjectErrorCode.fromJson('response_already_completed'),
        ResponseInjectErrorCode.responseAlreadyCompleted,
      );
      expect(
        ResponseInjectErrorCode.fromJson('response_not_found'),
        ResponseInjectErrorCode.responseNotFound,
      );
      expect(
        ResponseInjectErrorCode.responseAlreadyCompleted.toJson(),
        'response_already_completed',
      );
      expect(
        ResponseInjectErrorCode.responseNotFound.toJson(),
        'response_not_found',
      );
    });

    test('falls back to unknown for unrecognized values', () {
      expect(
        ResponseInjectErrorCode.fromJson('something_else'),
        ResponseInjectErrorCode.unknown,
      );
    });
  });

  group('ResponseInjectError', () {
    test('supports equality/hashCode and copyWith', () {
      const a = ResponseInjectError(
        code: ResponseInjectErrorCode.responseNotFound,
        message: 'not found',
      );
      const b = ResponseInjectError(
        code: ResponseInjectErrorCode.responseNotFound,
        message: 'not found',
      );
      final c = a.copyWith(message: 'different');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(c.message, 'different');
      expect(c.code, a.code);
    });
  });
}
