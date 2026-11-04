import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final status in ['completed', 'failed', 'incomplete']) {
    for (final presence in ['omitted', 'null', 'empty']) {
      test('$status terminal output $presence retains its wire presence', () {
        final wire = {
          'type': 'response.$status',
          'stream_id': 'lane',
          'sequence_number': 7,
          'agent': {'agent_name': 'worker'},
          'response': {
            'id': 'warmup',
            'object': 'response',
            'created_at': 1,
            'status': status,
            if (presence == 'null') 'output': null,
            if (presence == 'empty') 'output': <dynamic>[],
          },
        };
        final envelope =
            ResponsesServerEvent.fromJson(wire) as ResponsesStreamEvent;
        expect(_response(envelope.event).id, 'warmup');
        expect(_response(envelope.event).output, isEmpty);
        expect(envelope.streamId, 'lane');
        expect(envelope.event.sequenceNumber, 7);
        expect(envelope.rawJson, wire);
        final encoded = envelope.toJson()['response'] as Map;
        expect(encoded.containsKey('output'), presence != 'omitted');
        expect(encoded['output'], presence == 'empty' ? isEmpty : isNull);
        final parsed = ResponsesServerEvent.fromJson(envelope.toJson());
        expect(parsed, envelope);
        expect(parsed.hashCode, envelope.hashCode);
        final changed = envelope.copyWith(streamId: 'other');
        final changedResponse = changed.toJson()['response'] as Map;
        expect(changedResponse.containsKey('output'), presence != 'omitted');
        expect(
          changedResponse['output'],
          presence == 'empty' ? isEmpty : isNull,
        );
        expect(changed.streamId, 'other');
      });
      test('$status terminal $presence survives unrelated typed edits', () {
        final envelope = ResponsesStreamEvent.fromJson({
          'type': 'response.$status',
          'sequence_number': 7,
          'response': {
            'id': 'warmup',
            'object': 'response',
            'created_at': 1,
            'status': status,
            if (presence == 'null') 'output': null,
            if (presence == 'empty') 'output': <dynamic>[],
          },
        });
        final response = _response(envelope.event);
        final edits = [
          _copyTerminal(envelope.event, sequenceNumber: 8),
          _copyTerminal(
            envelope.event,
            response: response.copyWith(metadata: {'edited': 'yes'}),
          ),
        ];
        for (final edit in edits) {
          final changed = envelope.copyWith(event: edit);
          final wire = changed.toJson();
          final changedResponse = wire['response'] as Map;
          expect(changedResponse.containsKey('output'), presence != 'omitted');
          expect(
            changedResponse['output'],
            presence == 'empty' ? isEmpty : isNull,
          );
          expect(wire['sequence_number'], edit.sequenceNumber);
          expect(changed.event, edit);
          expect(ResponsesStreamEvent.fromJson(wire), changed);
          expect(
            ResponsesStreamEvent.fromJson(wire).hashCode,
            changed.hashCode,
          );
        }
      });
      if (presence != 'empty') {
        test('$status response replacement overrides $presence output', () {
          final envelope = ResponsesStreamEvent.fromJson({
            'type': 'response.$status',
            'response': {
              'id': 'original',
              'object': 'response',
              'created_at': 1,
              'status': status,
              'future_original': 'discarded with old response',
              if (presence == 'null') 'output': null,
            },
          });
          final changed = envelope.copyWith(
            event: _copyTerminal(
              envelope.event,
              response: _response(
                envelope.event,
              ).copyWith(id: 'replacement', output: const []),
            ),
          );
          final wire = changed.toJson();
          final response = wire['response'] as Map;
          expect(response['id'], 'replacement');
          expect(response.containsKey('output'), isTrue);
          expect(response['output'], isEmpty);
          expect(response.containsKey('future_original'), isFalse);
          expect(ResponsesStreamEvent.fromJson(wire), changed);
        });
      }
    }
    test('$status terminal malformed non-list output stays an error', () {
      expect(
        () => ResponsesServerEvent.fromJson({
          'type': 'response.$status',
          'response': {
            'id': 'warmup',
            'object': 'response',
            'created_at': 1,
            'status': status,
            'output': 'private malformed output',
          },
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            allOf(contains('ResponsesServerEvent'), isNot(contains('private'))),
          ),
        ),
      );
    });
  }
  test('typed terminal output replacement overrides original omission', () {
    final envelope = ResponsesStreamEvent.fromJson(const {
      'type': 'response.completed',
      'response': {
        'id': 'warmup',
        'object': 'response',
        'created_at': 1,
        'status': 'completed',
      },
    });
    final event = envelope.event as ResponseCompletedEvent;
    final item = OutputItem.fromJson({
      'type': 'function_call',
      'id': 'call_item',
      'call_id': 'call',
      'name': 'lookup',
      'arguments': '{}',
      'status': 'completed',
    });
    final changed = envelope.copyWith(
      event: event.copyWith(response: event.response.copyWith(output: [item])),
    );
    expect((changed.toJson()['response'] as Map)['output'], [item.toJson()]);
    expect(ResponsesStreamEvent.fromJson(changed.toJson()), changed);
  });
  test('explicit raw override can make normalized terminal output empty', () {
    final envelope = ResponsesStreamEvent.fromJson(const {
      'type': 'response.completed',
      'sequence_number': 7,
      'response': {
        'id': 'warmup',
        'object': 'response',
        'created_at': 1,
        'status': 'completed',
        'output': null,
      },
    });
    final changed = envelope.copyWith(
      event: _copyTerminal(envelope.event, sequenceNumber: 8),
      rawJson: {
        ...envelope.rawJson,
        'response': {
          ...envelope.rawJson['response'] as Map<String, dynamic>,
          'output': <dynamic>[],
        },
      },
    );
    final wire = changed.toJson();
    expect((wire['response'] as Map)['output'], isEmpty);
    expect(wire['sequence_number'], 8);
    expect(ResponsesStreamEvent.fromJson(wire), changed);
  });
  test('HTTP and SSE Response parsing remain strict about omitted output', () {
    final wire = <String, dynamic>{
      'id': 'warmup',
      'object': 'response',
      'created_at': 1,
      'status': 'completed',
    };
    expect(() => Response.fromJson(wire), throwsA(isA<TypeError>()));
    expect(
      () => ResponseStreamEvent.fromJson({
        'type': 'response.completed',
        'response': wire,
      }),
      throwsA(isA<TypeError>()),
    );
    expect(
      () => ResponsesServerEvent.fromJson({
        'type': 'response.created',
        'response': wire,
      }),
      throwsFormatException,
    );
  });
}

Response _response(ResponseStreamEvent event) => switch (event) {
  final ResponseCompletedEvent event => event.response,
  final ResponseFailedEvent event => event.response,
  final ResponseIncompleteEvent event => event.response,
  _ => throw StateError('not terminal'),
};

ResponseStreamEvent _copyTerminal(
  ResponseStreamEvent event, {
  int? sequenceNumber,
  Response? response,
}) => switch (event) {
  final ResponseCompletedEvent event => event.copyWith(
    sequenceNumber: sequenceNumber ?? event.sequenceNumber,
    response: response ?? event.response,
  ),
  final ResponseFailedEvent event => event.copyWith(
    sequenceNumber: sequenceNumber ?? event.sequenceNumber,
    response: response ?? event.response,
  ),
  final ResponseIncompleteEvent event => event.copyWith(
    sequenceNumber: sequenceNumber ?? event.sequenceNumber,
    response: response ?? event.response,
  ),
  _ => throw StateError('not terminal'),
};
