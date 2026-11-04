import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE correlation and context';

void main() {
  for (final parse in <String, LiveClientEvent Function(Map<String, dynamic>)>{
    'primary': LiveClientEvent.fromJson,
    'sideband': LiveSidebandClientEvent.fromJson,
    'fork': LiveClientEvent.fromForkJson,
  }.entries) {
    for (final json in [
      {'type': 'decision.create', 'event_id': _private},
      {
        'type': 'decision.item.create',
        'event_id': null,
        'item': _items().first,
      },
      {'type': 'decision.item.delete', 'item_id': _private},
    ]) {
      test(
        '${parse.key} dispatches ${json['type']} without changing the wire',
        () {
          final event = parse.value(json);
          expect(event, isA<LiveSidebandClientEvent>());
          expect(event.toJson(), json);
          expect(event.toString(), isNot(contains('PRIVATE')));
          final copied = switch (event) {
            final LiveDecisionCreateParam event => event.copyWith(),
            final LiveDecisionItemCreateParam event => event.copyWith(),
            final LiveDecisionItemDeleteParam event => event.copyWith(),
            _ => throw StateError('Unexpected command'),
          };
          expect(copied, event);
          expect(copied.hashCode, event.hashCode);
        },
      );
    }
  }

  for (final id in ['a', '🚀' * 256]) {
    test('decision.create admits ${id.runes.length} code points', () {
      final event = LiveDecisionCreateParam(eventId: id);
      final String nonnullId = event.eventId;
      expect(nonnullId, id);
      expect(event.hasEventId, isTrue);
      expect(event.toJson(), {'type': 'decision.create', 'event_id': id});
      expect(LiveDecisionCreateParam.fromJson(event.toJson()), event);
    });
  }
  for (final id in ['', 'a' * 257, '🚀' * 257]) {
    test('decision.create rejects invalid code-point count ${id.length}', () {
      expect(() => LiveDecisionCreateParam(eventId: id), throwsFormatException);
      expect(
        () => LiveDecisionCreateParam.fromJson({
          'type': 'decision.create',
          'event_id': id,
        }),
        throwsFormatException,
      );
    });
  }
  for (final json in <Map<String, dynamic>>[
    {'type': 'decision.create'},
    {'type': 'decision.create', 'event_id': null},
    {'type': 'decision.create', 'event_id': 1},
    {'type': 'decision.item.create', 'event_id': _private},
    {'type': 'decision.item.delete', 'item_id': ''},
  ]) {
    test('invalid command ${json.keys} fails with redacted context', () {
      expect(
        () => LiveClientEvent.fromJson(json),
        throwsA(
          isA<FormatException>().having(
            (e) => e.toString(),
            'diagnostic',
            isNot(contains('PRIVATE')),
          ),
        ),
      );
    });
  }
  test('required evaluation ID cannot be cleared by copy', () {
    final event = LiveDecisionCreateParam(eventId: 'first');
    expect(() => event.copyWith(eventId: null), throwsFormatException);
    expect(event.copyWith(eventId: 'second'), isNot(event));
  });

  for (final type in ['decision.item.create', 'decision.item.delete']) {
    test(
      '$type correlation distinguishes omitted, null, value and clearing',
      () {
        final base = <String, dynamic>{
          'type': type,
          if (type.endsWith('create'))
            'item': _items().first
          else
            'item_id': _private,
        };
        final absent = LiveClientEvent.fromJson(base);
        final nulled = LiveClientEvent.fromJson({...base, 'event_id': null});
        final valued = LiveClientEvent.fromJson({
          ...base,
          'event_id': _private,
        });
        expect(absent.hasEventId, isFalse);
        expect(nulled.hasEventId, isTrue);
        expect(nulled.eventId, isNull);
        expect(absent, isNot(nulled));
        final cleared = switch (valued) {
          final LiveDecisionItemCreateParam event => event.copyWith(
            clearEventId: true,
          ),
          final LiveDecisionItemDeleteParam event => event.copyWith(
            clearEventId: true,
          ),
          _ => throw StateError('Unexpected command'),
        };
        expect(cleared, absent);
        expect(cleared.toJson().containsKey('event_id'), isFalse);
        expect(
          () => LiveClientEvent.fromJson({...base, 'event_id': '🚀' * 513}),
          throwsFormatException,
        );
        expect(
          LiveClientEvent.fromJson({...base, 'event_id': '🚀' * 512}).eventId,
          '🚀' * 512,
        );
      },
    );
  }

  for (var index = 0; index < _items().length; index++) {
    test(
      'input/stored item branch $index retains its direction and payload',
      () {
        final input = _items()[index];
        final create = LiveDecisionItemCreateParam.fromJson({
          'type': 'decision.item.create',
          'item': input,
        });
        expect(create.item.toJson(), input);
        final stored = {...input, 'id': index.isEven ? '' : _private};
        final created = LiveDecisionItemCreated.fromJson({
          'type': 'decision.item.created',
          'event_id': 'ack',
          'item': stored,
        });
        expect(created.item.toJson(), stored);
        expect(created.copyWith(), created);
        expect(created.copyWith().hashCode, created.hashCode);
        expect(created.toString(), isNot(contains('PRIVATE')));
        expect(
          () => LiveDecisionItemCreated.fromJson({
            'type': 'decision.item.created',
            'event_id': 'ack',
            'item': input..remove('id'),
          }),
          throwsFormatException,
        );
      },
    );
  }

  for (final trigger in [false, true]) {
    test(
      'native ${trigger ? 'trigger' : 'delegation'} event parses typed answers and usage',
      () {
        final json = _event(trigger: trigger);
        final event = LiveServerEvent.fromJson(json) as LiveDecisionEvent;
        expect(event.event.type, 'decision.completed');
        expect(event.event.decision, isA<DecisionResponse>());
        expect(event.typedDecision.model, 'gpt-6-luna');
        expect(event.typedDecision.answers, hasLength(2));
        expect(
          event.typedDecision.answers.first,
          isA<PredicateDecisionAnswer>(),
        );
        expect(event.typedDecision.answers.last, isA<RefusalDecisionAnswer>());
        expect(event.typedDecision.usage.totalTokens, 42);
        expect(event.delegationId, trigger ? null : 'delegation');
        expect(event.triggerId, trigger ? 'trigger' : null);
        expect(event.sourceEventId, trigger ? 'transcript' : null);
        expect(
          event.sourceEventType,
          trigger ? 'session.input_transcript.delta' : null,
        );
        expect(event.toJson(), json);
        expect(event.copyWith(), event);
        expect(event.copyWith().hashCode, event.hashCode);
        expect(event.event.copyWith(), event.event);
        expect(event.toString(), isNot(contains('PRIVATE')));
        expect(identical(event.typedDecision, event.typedDecision), isFalse);
        event
          ..validateForChannel('primary')
          ..validateForChannel('sideband');
      },
    );
  }

  for (final field in [
    'delegation_id',
    'trigger_id',
    'source_event_type',
    'source_event_id',
  ]) {
    test(
      'required nullable $field rejects omission and wrong type, accepts null',
      () {
        final omitted = _event()..remove(field);
        expect(
          () => LiveServerEvent.fromJson(omitted),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'field',
              contains(field),
            ),
          ),
        );
        expect(
          () => LiveServerEvent.fromJson({..._event(), field: 2}),
          throwsFormatException,
        );
        expect(
          (LiveServerEvent.fromJson({..._event(), field: null})
                  as LiveDecisionEvent)
              .toJson()
              .containsKey(field),
          isTrue,
        );
      },
    );
  }
  test('correlations are preserved without an invented exclusive-or rule', () {
    final allNull = LiveDecisionEvent.fromJson({
      ..._event(),
      'delegation_id': null,
    });
    expect(allNull.toJson()['delegation_id'], isNull);
    final combined = LiveDecisionEvent.fromJson({
      ..._event(trigger: true),
      'delegation_id': 'also-present',
    });
    expect(combined.delegationId, 'also-present');
    expect(combined.triggerId, 'trigger');
    final copied = combined.copyWith(
      delegationId: null,
      triggerId: null,
      sourceEventType: null,
      sourceEventId: null,
    );
    expect(copied.toJson(), {
      ...combined.toJson(),
      'delegation_id': null,
      'trigger_id': null,
      'source_event_type': null,
      'source_event_id': null,
    });
    expect(() => combined.copyWith(eventId: null), throwsFormatException);
    expect(
      () => combined.copyWith(sourceEventType: 'old.transcript.type'),
      throwsFormatException,
    );
  });

  test(
    'native and outer future fields stay immutable and survive unrelated copies',
    () {
      final nested = <String, dynamic>{'text': _private};
      final json = _event();
      json['future'] = nested;
      final completion = json['event'] as Map<String, dynamic>;
      completion['future'] = {
        'nested': [_private],
      };
      (completion['decision'] as Map<String, dynamic>)['future_native'] = {
        'a': [_private],
      };
      final parsed = LiveDecisionEvent.fromJson(json);
      nested.clear();
      expect((parsed.toJson()['future'] as Map)['text'], _private);
      expect(parsed.rawJson.clear, throwsUnsupportedError);
      expect(
        () => (parsed.event.toJson()['decision'] as Map).clear(),
        throwsUnsupportedError,
      );
      expect(
        parsed.copyWith(eventId: 'updated').event.toJson(),
        parsed.event.toJson(),
      );
      expect(parsed.event.copyWith().toJson(), parsed.event.toJson());
      final changed = parsed.event.copyWith(
        decision: parsed.typedDecision.copyWith(model: 'updated'),
      );
      expect(changed.decision.model, 'updated');
      expect(changed.toJson()['future'], completion['future']);
    },
  );

  for (final nested in <Object?>[
    null,
    {},
    {'type': 'response.completed', 'decision': _decision()},
    {'type': 'decision.completed'},
    {
      'type': 'decision.completed',
      'decision': {
        'model': 'gpt-6-luna',
        'answers': <Object?>[],
        'usage': <String, dynamic>{},
      },
    },
  ]) {
    test(
      'malformed native completion ${nested.runtimeType} stays a known-event error',
      () {
        expect(
          () => LiveServerEvent.fromJson({..._event(), 'event': nested}),
          throwsFormatException,
        );
      },
    );
  }

  for (final type in ['decision.item.created', 'decision.item.deleted']) {
    test('$type client correlation is optional nonnull and clearable', () {
      final json = <String, dynamic>{
        'type': type,
        'event_id': _private,
        if (type.endsWith('created'))
          'item': {..._items().first, 'id': ''}
        else
          'item_id': '',
      };
      final absent = LiveServerEvent.fromJson(json);
      expect(absent.toJson().containsKey('client_event_id'), isFalse);
      expect(
        () => LiveServerEvent.fromJson({...json, 'client_event_id': null}),
        throwsFormatException,
      );
      final valued = LiveServerEvent.fromJson({
        ...json,
        'client_event_id': _private,
      });
      final copied = switch (valued) {
        final LiveDecisionItemCreated event => event.copyWith(
          clearClientEventId: true,
        ),
        final LiveDecisionItemDeleted event => event.copyWith(
          clearClientEventId: true,
        ),
        _ => throw StateError('Unexpected acknowledgment'),
      };
      expect(copied, absent);
      expect(copied.hashCode, absent.hashCode);
      expect(valued.toString(), isNot(contains('PRIVATE')));
    });
  }

  for (final type in [
    'decision.event',
    'decision.item.created',
    'decision.item.deleted',
  ]) {
    test('$type cannot bypass validation as an Unknown event', () {
      expect(() => UnknownLiveServerEvent(type: type), throwsFormatException);
    });
  }
  test('unknown event and transcript ordering remain untouched', () {
    final frames = [
      {
        'type': 'session.input_transcript.delta',
        'event_id': 'later',
        'delta': 'later fragment',
        'start_ms': 10,
        'end_ms': 20,
      },
      {
        'type': 'session.output_transcript.delta',
        'event_id': 'earlier',
        'delta': 'earlier fragment',
        'start_ms': 0,
        'end_ms': 1,
      },
      {'type': 'future.decision.event', 'data': _private},
      {'type': 'input_audio_transcript.delta', 'legacy': _private},
    ];
    final parsed = frames.map(LiveServerEvent.fromJson).toList();
    expect(parsed[0], isA<LiveInputTranscriptDelta>());
    expect(parsed[1], isA<LiveOutputTranscriptDelta>());
    expect(parsed[2], isA<UnknownLiveServerEvent>());
    expect(parsed[3], isA<UnknownLiveServerEvent>());
    expect(parsed.map((event) => event.toJson()), frames);
  });
}

List<Map<String, dynamic>> _items() => [
  {'role': 'user', 'content': _private, 'id': null},
  {'role': 'developer', 'content': _private},
  {'role': 'system', 'content': _private},
  {'role': 'assistant', 'content': _private},
  {
    'type': 'function_call',
    'arguments': '{}',
    'call_id': _private,
    'name': 'PRIVATE_tool',
  },
  {'type': 'function_call_output', 'call_id': _private, 'output': _private},
  {
    'type': 'custom_tool_call',
    'call_id': _private,
    'name': 'PRIVATE_tool',
    'input': _private,
  },
  {'type': 'custom_tool_call_output', 'call_id': _private, 'output': _private},
];
Map<String, dynamic> _event({bool trigger = false}) => {
  'type': 'decision.event',
  'event_id': _private,
  'delegation_id': trigger ? null : 'delegation',
  'trigger_id': trigger ? 'trigger' : null,
  'source_event_type': trigger ? 'session.input_transcript.delta' : null,
  'source_event_id': trigger ? 'transcript' : null,
  'event': {'type': 'decision.completed', 'decision': _decision()},
};
Map<String, dynamic> _decision() => {
  'model': 'gpt-6-luna',
  'answers': [
    {'type': 'predicate', 'probability': 0.9, 'name': _private},
    {'type': 'refusal', 'reason': _private, 'name': 'refused'},
  ],
  'usage': {
    'input_tokens': 42,
    'output_tokens': 0,
    'total_tokens': 42,
    'input_tokens_details': {'cached_tokens': 0, 'cache_write_tokens': 0},
    'output_tokens_details': {'reasoning_tokens': 0},
  },
};
