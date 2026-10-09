import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _outer(Map<String, dynamic> event) => {
  'type': 'response.event',
  'event_id': 'PRIVATE_EVENT_ID',
  'client_event_id': 'PRIVATE_CLIENT_ID',
  'delegation_id': 'PRIVATE_DELEGATION_ID',
  'event': event,
  'future_outer': {
    'secret': ['PRIVATE_FUTURE', null],
  },
};

void main() {
  group('complete compact dispatch', () {
    for (final entry in _granularFixtures.entries) {
      test(
        '${entry.key} canonical granular variant retains complete outer/raw data',
        () {
          final json = _outer(entry.value);
          final parsed = LiveResponsesEvent.fromJson(json);
          expect(parsed, isA<LiveResponsesGranularEvent>());
          final event = parsed as LiveResponsesGranularEvent;
          expect(event.granularEvent.type, entry.key);
          expect(event.toJson(), json);
          expect(event.eventId, 'PRIVATE_EVENT_ID');
          expect(event.clientEventId, 'PRIVATE_CLIENT_ID');
          expect(event.delegationId, 'PRIVATE_DELEGATION_ID');
          expect(event.hasDelegationId, isTrue);
          expect(event.isFinal, isFalse);
          expect(event.copyWith(), event);
          expect(event.copyWith().hashCode, event.hashCode);
          expect(event.toString(), isNot(contains('PRIVATE_')));
          expect(() => event.event['future'] = false, throwsUnsupportedError);
        },
      );
      for (final key in _granularRequired[entry.key]!.where(
        (k) => k != 'type',
      )) {
        test('${entry.key} missing required $key never falls back to raw', () {
          final json = Map<String, dynamic>.of(entry.value)..remove(key);
          expect(
            () => LiveResponsesEvent.fromJson(_outer(json)),
            throwsFormatException,
          );
        });
      }
      test('${entry.key} null required payload never falls back to raw', () {
        final json = Map<String, dynamic>.of(entry.value);
        final key = _granularNonNullRequired[entry.key]!;
        json[key] = null;
        expect(
          () => LiveResponsesEvent.fromJson(_outer(json)),
          throwsFormatException,
        );
      });
    }
    for (final type in [
      'response.created',
      'response.queued',
      'response.in_progress',
      'response.completed',
      'response.failed',
      'response.incomplete',
    ]) {
      test(
        '$type sparse lifecycle does not require full Response defaults',
        () {
          final json = _outer({'type': type, 'response': <String, dynamic>{}});
          final event =
              LiveResponsesEvent.fromJson(json) as LiveResponsesLifecycleEvent;
          expect(event.type, type);
          expect(event.response.toJson(), isEmpty);
          expect(event.response.hasId, isFalse);
          expect(event.sequenceNumber, isNull);
          expect(
            event.isFinal,
            [
              'response.completed',
              'response.failed',
              'response.incomplete',
            ].contains(type),
          );
          expect(event.toJson(), json);
          expect(event.copyWith(), event);
        },
      );
      test(
        '$type cleared snapshot retains future data and backend lifetime',
        () {
          final json = _outer({
            'type': type,
            'sequence_number': 3,
            'response': {
              'id': 'PRIVATE_RESPONSE_ID',
              'instructions': null,
              'tools': <dynamic>[],
              'output': <dynamic>[],
              'future_snapshot': {
                'secret': ['PRIVATE_CONTENT', null],
              },
            },
          });
          final event =
              LiveResponsesEvent.fromJson(json) as LiveResponsesLifecycleEvent;
          expect(event.response.id, 'PRIVATE_RESPONSE_ID');
          expect(event.response.hasInstructions, isTrue);
          expect(event.response.instructions, isNull);
          expect(event.response.tools, isEmpty);
          expect(event.response.output, isEmpty);
          expect(event.sequenceNumber, 3);
          expect(event.toJson(), json);
          expect(event.response.copyWith(), event.response);
          expect(event.response.copyWith().hashCode, event.response.hashCode);
          expect(event.response.toString(), isNot(contains('PRIVATE_')));
        },
      );
      for (final malformed in [
        <String, dynamic>{'type': type},
        {'type': type, 'response': null},
        {'type': type, 'response': <dynamic>[]},
        {
          'type': type,
          'response': <String, dynamic>{},
          'sequence_number': null,
        },
        {'type': type, 'response': <String, dynamic>{}, 'sequence_number': 1.5},
        {
          'type': type,
          'response': {'id': 42},
        },
        {
          'type': type,
          'response': {'output': null},
        },
      ]) {
        test(
          '$type malformed known lifecycle ${malformed.keys.join(',')} ${malformed.values}',
          () {
            expect(
              () => LiveResponsesEvent.fromJson(_outer(malformed)),
              throwsFormatException,
            );
          },
        );
      }
    }
    for (final future in [
      <String, dynamic>{},
      {
        'unknown': <dynamic>[
          null,
          {'data': 'PRIVATE_RAW'},
        ],
      },
      {'type': 'response.future', 'sequence_number': 'PRIVATE_FUTURE_SEQUENCE'},
    ]) {
      test(
        'raw future/typeless object remains lossless ${future.keys.join(',')}',
        () {
          final json = _outer(future);
          final parsed =
              LiveResponsesEvent.fromJson(json) as LiveResponsesRawEvent;
          expect(parsed.toJson(), json);
          expect(parsed.copyWith(), parsed);
          expect(parsed.copyWith().hashCode, parsed.hashCode);
          expect(parsed.isFinal, isFalse);
          expect(parsed.sequenceNumber, isNull);
          expect(parsed.toString(), isNot(contains('PRIVATE_')));
        },
      );
    }
    for (final type in [null, 1, true, <dynamic>[], <String, dynamic>{}]) {
      test('present malformed type cannot masquerade as typeless $type', () {
        expect(
          () => LiveResponsesEvent.fromJson(_outer({'type': type})),
          throwsFormatException,
        );
      });
    }
    test(
      'copy preserves and deliberately clears every outer correlation and raw member',
      () {
        final event = LiveResponsesEvent.fromJson(
          _outer({'type': 'response.future'}),
        );
        final changed = event.copyWith(
          clientEventId: 'new-client',
          delegationId: null,
          eventId: 'new-server',
          event: {
            'type': 'response.completed',
            'response': {'id': 'new-response'},
          },
          rawJson: {'future_outer': false},
        );
        expect(changed, isA<LiveResponsesLifecycleEvent>());
        expect(changed.eventId, 'new-server');
        expect(changed.clientEventId, 'new-client');
        expect(changed.hasDelegationId, isTrue);
        expect(changed.delegationId, isNull);
        expect(changed.toJson()['future_outer'], isFalse);
        expect(changed, isNot(event));
        final cleared = changed.copyWith(
          clearClientEventId: true,
          clearDelegationId: true,
        );
        expect(cleared.clientEventId, isNull);
        expect(cleared.hasDelegationId, isFalse);
        expect(cleared.toJson().containsKey('client_event_id'), isFalse);
        expect(cleared.toJson().containsKey('delegation_id'), isFalse);
      },
    );
    test(
      'parsed ownership is detached and deep immutable through all views',
      () {
        final nested = <dynamic>['PRIVATE_MUTABLE'];
        final json = _outer({
          'type': 'response.completed',
          'response': {
            'future': {'nested': nested},
          },
        });
        final event =
            LiveResponsesEvent.fromJson(json) as LiveResponsesLifecycleEvent;
        nested.add('changed');
        expect((event.response.rawJson['future'] as Map)['nested'], [
          'PRIVATE_MUTABLE',
        ]);
        expect(
          () => ((event.response.rawJson['future'] as Map)['nested'] as List)
              .add('bad'),
          throwsUnsupportedError,
        );
        final output = event.toJson();
        output['event_id'] = 'caller-change';
        expect(event.eventId, 'PRIVATE_EVENT_ID');
      },
    );
    test(
      'future output item branch stays raw within a declared granular event',
      () {
        final json = _outer({
          'type': 'response.output_item.done',
          'output_index': 0,
          'sequence_number': 1,
          'item': {
            'type': 'future_item',
            'private': ['PRIVATE_RAW'],
          },
        });
        final event =
            LiveResponsesEvent.fromJson(json) as LiveResponsesRawEvent;
        expect(event.toJson(), json);
        expect(event.type, 'response.output_item.done');
      },
    );
    test(
      'known output item malformed fields cannot fall back to a future item',
      () {
        final json = _outer({
          'type': 'response.output_item.done',
          'output_index': 0,
          'sequence_number': 1,
          'item': {
            'type': 'function_call',
            'id': 'fc',
            'name': 1,
            'arguments': '{}',
            'call_id': 'call',
          },
        });
        expect(() => LiveResponsesEvent.fromJson(json), throwsFormatException);
      },
    );
    for (final invalid in [double.nan, double.infinity, DateTime(2026)]) {
      test('future metadata must be finite JSON ${invalid.runtimeType}', () {
        expect(
          () => LiveResponsesEvent.fromJson(_outer({'future': invalid})),
          throwsFormatException,
        );
      });
    }
    test('cyclic future data rejected without private value disclosure', () {
      final cyclic = <String, dynamic>{};
      cyclic['cycle'] = cyclic;
      expect(
        () => LiveResponsesEvent.fromJson(_outer(cyclic)),
        throwsFormatException,
      );
    });
  });
  group('canonical output branches use codecs only where compatible', () {
    for (final fixture in _outputItemFixtures.entries) {
      test('${fixture.key} complete canonical minimum remains lossless', () {
        final json = _outer({
          'type': 'response.output_item.done',
          'output_index': 0,
          'sequence_number': 1,
          'item': fixture.value,
        });
        final result = LiveResponsesEvent.fromJson(json);
        expect(
          result,
          anyOf(
            isA<LiveResponsesGranularEvent>(),
            isA<LiveResponsesRawEvent>(),
          ),
        );
        expect(result.toJson(), json);
        expect(result.copyWith(), result);
      });
    }
    test(
      'a compatible complete function call is parsed with preserved IDs',
      () {
        final item = {
          'type': 'function_call',
          'id': 'fc_1',
          'call_id': 'call_1',
          'name': 'lookup',
          'arguments': '{}',
        };
        final json = _outer({
          'type': 'response.output_item.done',
          'output_index': 0,
          'sequence_number': 1,
          'item': item,
        });
        final event =
            LiveResponsesEvent.fromJson(json) as LiveResponsesGranularEvent;
        final granular = event.granularEvent as OutputItemDoneEvent;
        final call = granular.item as FunctionCallOutputItemResponse;
        expect(call.callId, 'call_1');
        expect(call.name, 'lookup');
        expect(event.toJson(), json);
      },
    );
  });
  group('all present compact snapshot properties', () {
    test('raw metadata replacement cannot smuggle absent known fields', () {
      final empty = LiveCompactResponse.fromJson(const <String, dynamic>{});
      final copied = empty.copyWith(
        rawJson: {'id': 'smuggled', 'future': true},
      );
      expect(copied.hasId, isFalse);
      expect(copied.toJson(), {'future': true});
      final explicit = empty.copyWith(
        id: 'explicit',
        rawJson: {'id': 'smuggled', 'future': true},
      );
      expect(explicit.id, 'explicit');
      expect(explicit.toJson(), {'id': 'explicit', 'future': true});
    });

    test(
      'metadata getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'metadata': <String, dynamic>{},
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.metadata, <String, dynamic>{});
        expect(snapshot.hasMetadata, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(metadata: <String, dynamic>{});
        expect(restored.metadata, <String, dynamic>{});
        expect(restored.hasMetadata, isTrue);
        final cleared = snapshot.copyWith(clearMetadata: true);
        expect(cleared.hasMetadata, isFalse);
        expect(cleared.metadata, isNull);
        expect(cleared.toJson().containsKey('metadata'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'metadata': <String, dynamic>{},
          'replacement': true,
        });
      },
    );
    test('metadata malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'metadata': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.metadata'),
          ),
        ),
      );
    });
    test(
      'top_logprobs getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'top_logprobs': 0,
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.topLogprobs, 0);
        expect(snapshot.hasTopLogprobs, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(topLogprobs: 0);
        expect(restored.topLogprobs, 0);
        expect(restored.hasTopLogprobs, isTrue);
        final cleared = snapshot.copyWith(clearTopLogprobs: true);
        expect(cleared.hasTopLogprobs, isFalse);
        expect(cleared.topLogprobs, isNull);
        expect(cleared.toJson().containsKey('top_logprobs'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'top_logprobs': 0,
          'replacement': true,
        });
      },
    );
    test('top_logprobs malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'top_logprobs': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.top_logprobs'),
          ),
        ),
      );
    });
    test(
      'temperature getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'temperature': 1,
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.temperature, 1);
        expect(snapshot.hasTemperature, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(temperature: 1);
        expect(restored.temperature, 1);
        expect(restored.hasTemperature, isTrue);
        final cleared = snapshot.copyWith(clearTemperature: true);
        expect(cleared.hasTemperature, isFalse);
        expect(cleared.temperature, isNull);
        expect(cleared.toJson().containsKey('temperature'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'temperature': 1,
          'replacement': true,
        });
      },
    );
    test('temperature malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'temperature': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.temperature'),
          ),
        ),
      );
    });
    test(
      'top_p getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'top_p': 1,
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.topP, 1);
        expect(snapshot.hasTopP, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const <String, dynamic>{},
        ).copyWith(topP: 1);
        expect(restored.topP, 1);
        expect(restored.hasTopP, isTrue);
        final cleared = snapshot.copyWith(clearTopP: true);
        expect(cleared.hasTopP, isFalse);
        expect(cleared.topP, isNull);
        expect(cleared.toJson().containsKey('top_p'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'top_p': 1,
          'replacement': true,
        });
      },
    );
    test('top_p malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'top_p': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.top_p'),
          ),
        ),
      );
    });
    test(
      'user getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'user': 'user-1234',
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.user, 'user-1234');
        expect(snapshot.hasUser, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(user: 'user-1234');
        expect(restored.user, 'user-1234');
        expect(restored.hasUser, isTrue);
        final cleared = snapshot.copyWith(clearUser: true);
        expect(cleared.hasUser, isFalse);
        expect(cleared.user, isNull);
        expect(cleared.toJson().containsKey('user'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'user': 'user-1234',
          'replacement': true,
        });
      },
    );
    test('user malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'user': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.user'),
          ),
        ),
      );
    });
    test(
      'safety_identifier getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'safety_identifier': 'safety-identifier-1234',
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.safetyIdentifier, 'safety-identifier-1234');
        expect(snapshot.hasSafetyIdentifier, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(safetyIdentifier: 'safety-identifier-1234');
        expect(restored.safetyIdentifier, 'safety-identifier-1234');
        expect(restored.hasSafetyIdentifier, isTrue);
        final cleared = snapshot.copyWith(clearSafetyIdentifier: true);
        expect(cleared.hasSafetyIdentifier, isFalse);
        expect(cleared.safetyIdentifier, isNull);
        expect(cleared.toJson().containsKey('safety_identifier'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'safety_identifier': 'safety-identifier-1234',
          'replacement': true,
        });
      },
    );
    test('safety_identifier malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'safety_identifier': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.safety_identifier'),
          ),
        ),
      );
    });
    test(
      'prompt_cache_key getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'prompt_cache_key': 'prompt-cache-key-1234',
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.promptCacheKey, 'prompt-cache-key-1234');
        expect(snapshot.hasPromptCacheKey, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(promptCacheKey: 'prompt-cache-key-1234');
        expect(restored.promptCacheKey, 'prompt-cache-key-1234');
        expect(restored.hasPromptCacheKey, isTrue);
        final cleared = snapshot.copyWith(clearPromptCacheKey: true);
        expect(cleared.hasPromptCacheKey, isFalse);
        expect(cleared.promptCacheKey, isNull);
        expect(cleared.toJson().containsKey('prompt_cache_key'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'prompt_cache_key': 'prompt-cache-key-1234',
          'replacement': true,
        });
      },
    );
    test('prompt_cache_key malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'prompt_cache_key': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.prompt_cache_key'),
          ),
        ),
      );
    });
    test(
      'prompt_cache_retention getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'prompt_cache_retention': 'in_memory',
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.promptCacheRetention, 'in_memory');
        expect(snapshot.hasPromptCacheRetention, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(promptCacheRetention: 'in_memory');
        expect(restored.promptCacheRetention, 'in_memory');
        expect(restored.hasPromptCacheRetention, isTrue);
        final cleared = snapshot.copyWith(clearPromptCacheRetention: true);
        expect(cleared.hasPromptCacheRetention, isFalse);
        expect(cleared.promptCacheRetention, isNull);
        expect(cleared.toJson().containsKey('prompt_cache_retention'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'prompt_cache_retention': 'in_memory',
          'replacement': true,
        });
      },
    );
    test(
      'prompt_cache_retention malformed present known kind is contextual',
      () {
        expect(
          () => LiveCompactResponse.fromJson(const {
            'prompt_cache_retention': <dynamic>[true],
          }),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'safe context',
              contains('LiveCompactResponse.prompt_cache_retention'),
            ),
          ),
        );
      },
    );
    test(
      'previous_response_id getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'previous_response_id': 'value',
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.previousResponseId, 'value');
        expect(snapshot.hasPreviousResponseId, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(previousResponseId: 'value');
        expect(restored.previousResponseId, 'value');
        expect(restored.hasPreviousResponseId, isTrue);
        final cleared = snapshot.copyWith(clearPreviousResponseId: true);
        expect(cleared.hasPreviousResponseId, isFalse);
        expect(cleared.previousResponseId, isNull);
        expect(cleared.toJson().containsKey('previous_response_id'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'previous_response_id': 'value',
          'replacement': true,
        });
      },
    );
    test('previous_response_id malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'previous_response_id': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.previous_response_id'),
          ),
        ),
      );
    });
    test(
      'model getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'model': 'gpt-6-astra',
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.model, 'gpt-6-astra');
        expect(snapshot.hasModel, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(model: 'gpt-6-astra');
        expect(restored.model, 'gpt-6-astra');
        expect(restored.hasModel, isTrue);
        final cleared = snapshot.copyWith(clearModel: true);
        expect(cleared.hasModel, isFalse);
        expect(cleared.model, isNull);
        expect(cleared.toJson().containsKey('model'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'model': 'gpt-6-astra',
          'replacement': true,
        });
      },
    );
    test('model malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'model': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.model'),
          ),
        ),
      );
    });
    test('model explicit null rejected instead of omitted', () {
      expect(
        () => LiveCompactResponse.fromJson(const {'model': null}),
        throwsFormatException,
      );
    });

    test(
      'background getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'background': false,
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.background, false);
        expect(snapshot.hasBackground, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(background: false);
        expect(restored.background, false);
        expect(restored.hasBackground, isTrue);
        final cleared = snapshot.copyWith(clearBackground: true);
        expect(cleared.hasBackground, isFalse);
        expect(cleared.background, isNull);
        expect(cleared.toJson().containsKey('background'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'background': false,
          'replacement': true,
        });
      },
    );
    test('background malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'background': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.background'),
          ),
        ),
      );
    });
    test(
      'max_tool_calls getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'max_tool_calls': 0,
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.maxToolCalls, 0);
        expect(snapshot.hasMaxToolCalls, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(maxToolCalls: 0);
        expect(restored.maxToolCalls, 0);
        expect(restored.hasMaxToolCalls, isTrue);
        final cleared = snapshot.copyWith(clearMaxToolCalls: true);
        expect(cleared.hasMaxToolCalls, isFalse);
        expect(cleared.maxToolCalls, isNull);
        expect(cleared.toJson().containsKey('max_tool_calls'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'max_tool_calls': 0,
          'replacement': true,
        });
      },
    );
    test('max_tool_calls malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'max_tool_calls': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.max_tool_calls'),
          ),
        ),
      );
    });
    test(
      'text getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'text': <String, dynamic>{},
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.text, <String, dynamic>{});
        expect(snapshot.hasText, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(text: <String, dynamic>{});
        expect(restored.text, <String, dynamic>{});
        expect(restored.hasText, isTrue);
        final cleared = snapshot.copyWith(clearText: true);
        expect(cleared.hasText, isFalse);
        expect(cleared.text, isNull);
        expect(cleared.toJson().containsKey('text'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'text': <String, dynamic>{},
          'replacement': true,
        });
      },
    );
    test('text malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'text': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.text'),
          ),
        ),
      );
    });
    test('text explicit null rejected instead of omitted', () {
      expect(
        () => LiveCompactResponse.fromJson(const {'text': null}),
        throwsFormatException,
      );
    });

    test(
      'tools getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'tools': <dynamic>[],
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.tools, <dynamic>[]);
        expect(snapshot.hasTools, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(tools: <dynamic>[]);
        expect(restored.tools, <dynamic>[]);
        expect(restored.hasTools, isTrue);
        final cleared = snapshot.copyWith(clearTools: true);
        expect(cleared.hasTools, isFalse);
        expect(cleared.tools, isNull);
        expect(cleared.toJson().containsKey('tools'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'tools': <dynamic>[],
          'replacement': true,
        });
      },
    );
    test('tools malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {'tools': 42}),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.tools'),
          ),
        ),
      );
    });
    test('tools explicit null rejected instead of omitted', () {
      expect(
        () => LiveCompactResponse.fromJson(const {'tools': null}),
        throwsFormatException,
      );
    });

    test(
      'tool_choice getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'tool_choice': 'none',
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.toolChoice, 'none');
        expect(snapshot.hasToolChoice, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(toolChoice: 'none');
        expect(restored.toolChoice, 'none');
        expect(restored.hasToolChoice, isTrue);
        final cleared = snapshot.copyWith(clearToolChoice: true);
        expect(cleared.hasToolChoice, isFalse);
        expect(cleared.toolChoice, isNull);
        expect(cleared.toJson().containsKey('tool_choice'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'tool_choice': 'none',
          'replacement': true,
        });
      },
    );
    test('tool_choice malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'tool_choice': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.tool_choice'),
          ),
        ),
      );
    });
    test('tool_choice explicit null rejected instead of omitted', () {
      expect(
        () => LiveCompactResponse.fromJson(const {'tool_choice': null}),
        throwsFormatException,
      );
    });

    test(
      'prompt getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'prompt': <String, dynamic>{'id': 'value'},
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.prompt, <String, dynamic>{'id': 'value'});
        expect(snapshot.hasPrompt, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(prompt: <String, dynamic>{'id': 'value'});
        expect(restored.prompt, <String, dynamic>{'id': 'value'});
        expect(restored.hasPrompt, isTrue);
        final cleared = snapshot.copyWith(clearPrompt: true);
        expect(cleared.hasPrompt, isFalse);
        expect(cleared.prompt, isNull);
        expect(cleared.toJson().containsKey('prompt'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'prompt': <String, dynamic>{'id': 'value'},
          'replacement': true,
        });
      },
    );
    test('prompt malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'prompt': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.prompt'),
          ),
        ),
      );
    });
    test(
      'service_tier getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'service_tier': 'auto',
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.serviceTier, 'auto');
        expect(snapshot.hasServiceTier, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(serviceTier: 'auto');
        expect(restored.serviceTier, 'auto');
        expect(restored.hasServiceTier, isTrue);
        final cleared = snapshot.copyWith(clearServiceTier: true);
        expect(cleared.hasServiceTier, isFalse);
        expect(cleared.serviceTier, isNull);
        expect(cleared.toJson().containsKey('service_tier'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'service_tier': 'auto',
          'replacement': true,
        });
      },
    );
    test('service_tier malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'service_tier': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.service_tier'),
          ),
        ),
      );
    });
    test(
      'truncation getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'truncation': 'auto',
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.truncation, 'auto');
        expect(snapshot.hasTruncation, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(truncation: 'auto');
        expect(restored.truncation, 'auto');
        expect(restored.hasTruncation, isTrue);
        final cleared = snapshot.copyWith(clearTruncation: true);
        expect(cleared.hasTruncation, isFalse);
        expect(cleared.truncation, isNull);
        expect(cleared.toJson().containsKey('truncation'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'truncation': 'auto',
          'replacement': true,
        });
      },
    );
    test('truncation malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'truncation': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.truncation'),
          ),
        ),
      );
    });
    test(
      'id getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'id': 'value',
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.id, 'value');
        expect(snapshot.hasId, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const <String, dynamic>{},
        ).copyWith(id: 'value');
        expect(restored.id, 'value');
        expect(restored.hasId, isTrue);
        final cleared = snapshot.copyWith(clearId: true);
        expect(cleared.hasId, isFalse);
        expect(cleared.id, isNull);
        expect(cleared.toJson().containsKey('id'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'id': 'value',
          'replacement': true,
        });
      },
    );
    test('id malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'id': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.id'),
          ),
        ),
      );
    });
    test('id explicit null rejected instead of omitted', () {
      expect(
        () => LiveCompactResponse.fromJson(const {'id': null}),
        throwsFormatException,
      );
    });

    test(
      'object getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'object': 'response',
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.object, 'response');
        expect(snapshot.hasObject, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(object: 'response');
        expect(restored.object, 'response');
        expect(restored.hasObject, isTrue);
        final cleared = snapshot.copyWith(clearObject: true);
        expect(cleared.hasObject, isFalse);
        expect(cleared.object, isNull);
        expect(cleared.toJson().containsKey('object'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'object': 'response',
          'replacement': true,
        });
      },
    );
    test('object malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'object': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.object'),
          ),
        ),
      );
    });
    test('object explicit null rejected instead of omitted', () {
      expect(
        () => LiveCompactResponse.fromJson(const {'object': null}),
        throwsFormatException,
      );
    });

    test(
      'status getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'status': 'completed',
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.status, 'completed');
        expect(snapshot.hasStatus, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(status: 'completed');
        expect(restored.status, 'completed');
        expect(restored.hasStatus, isTrue);
        final cleared = snapshot.copyWith(clearStatus: true);
        expect(cleared.hasStatus, isFalse);
        expect(cleared.status, isNull);
        expect(cleared.toJson().containsKey('status'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'status': 'completed',
          'replacement': true,
        });
      },
    );
    test('status malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'status': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.status'),
          ),
        ),
      );
    });
    test('status explicit null rejected instead of omitted', () {
      expect(
        () => LiveCompactResponse.fromJson(const {'status': null}),
        throwsFormatException,
      );
    });

    test(
      'access_programs getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'access_programs': <String, dynamic>{'cyber': 'standard'},
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.accessPrograms, <String, dynamic>{'cyber': 'standard'});
        expect(snapshot.hasAccessPrograms, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(accessPrograms: <String, dynamic>{'cyber': 'standard'});
        expect(restored.accessPrograms, <String, dynamic>{'cyber': 'standard'});
        expect(restored.hasAccessPrograms, isTrue);
        final cleared = snapshot.copyWith(clearAccessPrograms: true);
        expect(cleared.hasAccessPrograms, isFalse);
        expect(cleared.accessPrograms, isNull);
        expect(cleared.toJson().containsKey('access_programs'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'access_programs': <String, dynamic>{'cyber': 'standard'},
          'replacement': true,
        });
      },
    );
    test('access_programs malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'access_programs': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.access_programs'),
          ),
        ),
      );
    });
    test(
      'created_at getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'created_at': 0,
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.createdAt, 0);
        expect(snapshot.hasCreatedAt, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(createdAt: 0);
        expect(restored.createdAt, 0);
        expect(restored.hasCreatedAt, isTrue);
        final cleared = snapshot.copyWith(clearCreatedAt: true);
        expect(cleared.hasCreatedAt, isFalse);
        expect(cleared.createdAt, isNull);
        expect(cleared.toJson().containsKey('created_at'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'created_at': 0,
          'replacement': true,
        });
      },
    );
    test('created_at malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'created_at': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.created_at'),
          ),
        ),
      );
    });
    test('created_at explicit null rejected instead of omitted', () {
      expect(
        () => LiveCompactResponse.fromJson(const {'created_at': null}),
        throwsFormatException,
      );
    });

    test(
      'completed_at getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'completed_at': 0,
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.completedAt, 0);
        expect(snapshot.hasCompletedAt, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(completedAt: 0);
        expect(restored.completedAt, 0);
        expect(restored.hasCompletedAt, isTrue);
        final cleared = snapshot.copyWith(clearCompletedAt: true);
        expect(cleared.hasCompletedAt, isFalse);
        expect(cleared.completedAt, isNull);
        expect(cleared.toJson().containsKey('completed_at'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'completed_at': 0,
          'replacement': true,
        });
      },
    );
    test('completed_at malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'completed_at': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.completed_at'),
          ),
        ),
      );
    });
    test(
      'error getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'error': <String, dynamic>{
            'code': 'server_error',
            'message': 'value',
          },
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.error, <String, dynamic>{
          'code': 'server_error',
          'message': 'value',
        });
        expect(snapshot.hasError, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(const <String, dynamic>{})
            .copyWith(
              error: <String, dynamic>{
                'code': 'server_error',
                'message': 'value',
              },
            );
        expect(restored.error, <String, dynamic>{
          'code': 'server_error',
          'message': 'value',
        });
        expect(restored.hasError, isTrue);
        final cleared = snapshot.copyWith(clearError: true);
        expect(cleared.hasError, isFalse);
        expect(cleared.error, isNull);
        expect(cleared.toJson().containsKey('error'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'error': <String, dynamic>{
            'code': 'server_error',
            'message': 'value',
          },
          'replacement': true,
        });
      },
    );
    test('error malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'error': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.error'),
          ),
        ),
      );
    });
    test(
      'incomplete_details getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'incomplete_details': <String, dynamic>{},
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.incompleteDetails, <String, dynamic>{});
        expect(snapshot.hasIncompleteDetails, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(incompleteDetails: <String, dynamic>{});
        expect(restored.incompleteDetails, <String, dynamic>{});
        expect(restored.hasIncompleteDetails, isTrue);
        final cleared = snapshot.copyWith(clearIncompleteDetails: true);
        expect(cleared.hasIncompleteDetails, isFalse);
        expect(cleared.incompleteDetails, isNull);
        expect(cleared.toJson().containsKey('incomplete_details'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'incomplete_details': <String, dynamic>{},
          'replacement': true,
        });
      },
    );
    test('incomplete_details malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'incomplete_details': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.incomplete_details'),
          ),
        ),
      );
    });
    test(
      'output getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'output': <dynamic>[],
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.output, <dynamic>[]);
        expect(snapshot.hasOutput, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(output: <dynamic>[]);
        expect(restored.output, <dynamic>[]);
        expect(restored.hasOutput, isTrue);
        final cleared = snapshot.copyWith(clearOutput: true);
        expect(cleared.hasOutput, isFalse);
        expect(cleared.output, isNull);
        expect(cleared.toJson().containsKey('output'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'output': <dynamic>[],
          'replacement': true,
        });
      },
    );
    test('output malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {'output': 42}),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.output'),
          ),
        ),
      );
    });
    test('output explicit null rejected instead of omitted', () {
      expect(
        () => LiveCompactResponse.fromJson(const {'output': null}),
        throwsFormatException,
      );
    });

    test(
      'reasoning getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'reasoning': <String, dynamic>{},
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.reasoning, <String, dynamic>{});
        expect(snapshot.hasReasoning, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(reasoning: <String, dynamic>{});
        expect(restored.reasoning, <String, dynamic>{});
        expect(restored.hasReasoning, isTrue);
        final cleared = snapshot.copyWith(clearReasoning: true);
        expect(cleared.hasReasoning, isFalse);
        expect(cleared.reasoning, isNull);
        expect(cleared.toJson().containsKey('reasoning'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'reasoning': <String, dynamic>{},
          'replacement': true,
        });
      },
    );
    test('reasoning malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'reasoning': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.reasoning'),
          ),
        ),
      );
    });
    test(
      'instructions getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'instructions': 'value',
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.instructions, 'value');
        expect(snapshot.hasInstructions, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(instructions: 'value');
        expect(restored.instructions, 'value');
        expect(restored.hasInstructions, isTrue);
        final cleared = snapshot.copyWith(clearInstructions: true);
        expect(cleared.hasInstructions, isFalse);
        expect(cleared.instructions, isNull);
        expect(cleared.toJson().containsKey('instructions'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'instructions': 'value',
          'replacement': true,
        });
      },
    );
    test('instructions malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'instructions': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.instructions'),
          ),
        ),
      );
    });
    test(
      'output_text getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'output_text': 'value',
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.outputText, 'value');
        expect(snapshot.hasOutputText, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(outputText: 'value');
        expect(restored.outputText, 'value');
        expect(restored.hasOutputText, isTrue);
        final cleared = snapshot.copyWith(clearOutputText: true);
        expect(cleared.hasOutputText, isFalse);
        expect(cleared.outputText, isNull);
        expect(cleared.toJson().containsKey('output_text'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'output_text': 'value',
          'replacement': true,
        });
      },
    );
    test('output_text malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'output_text': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.output_text'),
          ),
        ),
      );
    });
    test(
      'usage getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'usage': <String, dynamic>{
            'input_tokens': 0,
            'input_tokens_details': <String, dynamic>{
              'cached_tokens': 0,
              'cache_write_tokens': 0,
            },
            'output_tokens': 0,
            'output_tokens_details': <String, dynamic>{'reasoning_tokens': 0},
            'total_tokens': 0,
          },
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.usage, <String, dynamic>{
          'input_tokens': 0,
          'input_tokens_details': <String, dynamic>{
            'cached_tokens': 0,
            'cache_write_tokens': 0,
          },
          'output_tokens': 0,
          'output_tokens_details': <String, dynamic>{'reasoning_tokens': 0},
          'total_tokens': 0,
        });
        expect(snapshot.hasUsage, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(const <String, dynamic>{})
            .copyWith(
              usage: <String, dynamic>{
                'input_tokens': 0,
                'input_tokens_details': <String, dynamic>{
                  'cached_tokens': 0,
                  'cache_write_tokens': 0,
                },
                'output_tokens': 0,
                'output_tokens_details': <String, dynamic>{
                  'reasoning_tokens': 0,
                },
                'total_tokens': 0,
              },
            );
        expect(restored.usage, <String, dynamic>{
          'input_tokens': 0,
          'input_tokens_details': <String, dynamic>{
            'cached_tokens': 0,
            'cache_write_tokens': 0,
          },
          'output_tokens': 0,
          'output_tokens_details': <String, dynamic>{'reasoning_tokens': 0},
          'total_tokens': 0,
        });
        expect(restored.hasUsage, isTrue);
        final cleared = snapshot.copyWith(clearUsage: true);
        expect(cleared.hasUsage, isFalse);
        expect(cleared.usage, isNull);
        expect(cleared.toJson().containsKey('usage'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'usage': <String, dynamic>{
            'input_tokens': 0,
            'input_tokens_details': <String, dynamic>{
              'cached_tokens': 0,
              'cache_write_tokens': 0,
            },
            'output_tokens': 0,
            'output_tokens_details': <String, dynamic>{'reasoning_tokens': 0},
            'total_tokens': 0,
          },
          'replacement': true,
        });
      },
    );
    test('usage malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'usage': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.usage'),
          ),
        ),
      );
    });
    test(
      'prompt_cache_options getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'prompt_cache_options': <String, dynamic>{
            'ttl': '30m',
            'mode': 'implicit',
          },
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.promptCacheOptions, <String, dynamic>{
          'ttl': '30m',
          'mode': 'implicit',
        });
        expect(snapshot.hasPromptCacheOptions, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(const <String, dynamic>{})
            .copyWith(
              promptCacheOptions: <String, dynamic>{
                'ttl': '30m',
                'mode': 'implicit',
              },
            );
        expect(restored.promptCacheOptions, <String, dynamic>{
          'ttl': '30m',
          'mode': 'implicit',
        });
        expect(restored.hasPromptCacheOptions, isTrue);
        final cleared = snapshot.copyWith(clearPromptCacheOptions: true);
        expect(cleared.hasPromptCacheOptions, isFalse);
        expect(cleared.promptCacheOptions, isNull);
        expect(cleared.toJson().containsKey('prompt_cache_options'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'prompt_cache_options': <String, dynamic>{
            'ttl': '30m',
            'mode': 'implicit',
          },
          'replacement': true,
        });
      },
    );
    test('prompt_cache_options malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'prompt_cache_options': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.prompt_cache_options'),
          ),
        ),
      );
    });
    test('prompt_cache_options explicit null rejected instead of omitted', () {
      expect(
        () =>
            LiveCompactResponse.fromJson(const {'prompt_cache_options': null}),
        throwsFormatException,
      );
    });

    test(
      'prompt_cache_diagnostics getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'prompt_cache_diagnostics': <String, dynamic>{
            'type': 'cache_miss',
            'reason': 'model_changed',
            'cache_missed_tokens': 0,
          },
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.promptCacheDiagnostics, <String, dynamic>{
          'type': 'cache_miss',
          'reason': 'model_changed',
          'cache_missed_tokens': 0,
        });
        expect(snapshot.hasPromptCacheDiagnostics, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(const <String, dynamic>{})
            .copyWith(
              promptCacheDiagnostics: <String, dynamic>{
                'type': 'cache_miss',
                'reason': 'model_changed',
                'cache_missed_tokens': 0,
              },
            );
        expect(restored.promptCacheDiagnostics, <String, dynamic>{
          'type': 'cache_miss',
          'reason': 'model_changed',
          'cache_missed_tokens': 0,
        });
        expect(restored.hasPromptCacheDiagnostics, isTrue);
        final cleared = snapshot.copyWith(clearPromptCacheDiagnostics: true);
        expect(cleared.hasPromptCacheDiagnostics, isFalse);
        expect(cleared.promptCacheDiagnostics, isNull);
        expect(
          cleared.toJson().containsKey('prompt_cache_diagnostics'),
          isFalse,
        );
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'prompt_cache_diagnostics': <String, dynamic>{
            'type': 'cache_miss',
            'reason': 'model_changed',
            'cache_missed_tokens': 0,
          },
          'replacement': true,
        });
      },
    );
    test(
      'prompt_cache_diagnostics malformed present known kind is contextual',
      () {
        expect(
          () => LiveCompactResponse.fromJson(const {
            'prompt_cache_diagnostics': <dynamic>[true],
          }),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'safe context',
              contains('LiveCompactResponse.prompt_cache_diagnostics'),
            ),
          ),
        );
      },
    );
    test(
      'prompt_cache_diagnostics explicit null rejected instead of omitted',
      () {
        expect(
          () => LiveCompactResponse.fromJson(const {
            'prompt_cache_diagnostics': null,
          }),
          throwsFormatException,
        );
      },
    );

    test(
      'moderation getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'moderation': <String, dynamic>{
            'input': <String, dynamic>{
              'type': 'moderation_result',
              'model': 'value',
              'flagged': false,
              'categories': <String, dynamic>{},
              'category_scores': <String, dynamic>{},
              'category_applied_input_types': <String, dynamic>{},
            },
            'output': <String, dynamic>{
              'type': 'moderation_result',
              'model': 'value',
              'flagged': false,
              'categories': <String, dynamic>{},
              'category_scores': <String, dynamic>{},
              'category_applied_input_types': <String, dynamic>{},
            },
          },
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.moderation, <String, dynamic>{
          'input': <String, dynamic>{
            'type': 'moderation_result',
            'model': 'value',
            'flagged': false,
            'categories': <String, dynamic>{},
            'category_scores': <String, dynamic>{},
            'category_applied_input_types': <String, dynamic>{},
          },
          'output': <String, dynamic>{
            'type': 'moderation_result',
            'model': 'value',
            'flagged': false,
            'categories': <String, dynamic>{},
            'category_scores': <String, dynamic>{},
            'category_applied_input_types': <String, dynamic>{},
          },
        });
        expect(snapshot.hasModeration, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(const <String, dynamic>{})
            .copyWith(
              moderation: <String, dynamic>{
                'input': <String, dynamic>{
                  'type': 'moderation_result',
                  'model': 'value',
                  'flagged': false,
                  'categories': <String, dynamic>{},
                  'category_scores': <String, dynamic>{},
                  'category_applied_input_types': <String, dynamic>{},
                },
                'output': <String, dynamic>{
                  'type': 'moderation_result',
                  'model': 'value',
                  'flagged': false,
                  'categories': <String, dynamic>{},
                  'category_scores': <String, dynamic>{},
                  'category_applied_input_types': <String, dynamic>{},
                },
              },
            );
        expect(restored.moderation, <String, dynamic>{
          'input': <String, dynamic>{
            'type': 'moderation_result',
            'model': 'value',
            'flagged': false,
            'categories': <String, dynamic>{},
            'category_scores': <String, dynamic>{},
            'category_applied_input_types': <String, dynamic>{},
          },
          'output': <String, dynamic>{
            'type': 'moderation_result',
            'model': 'value',
            'flagged': false,
            'categories': <String, dynamic>{},
            'category_scores': <String, dynamic>{},
            'category_applied_input_types': <String, dynamic>{},
          },
        });
        expect(restored.hasModeration, isTrue);
        final cleared = snapshot.copyWith(clearModeration: true);
        expect(cleared.hasModeration, isFalse);
        expect(cleared.moderation, isNull);
        expect(cleared.toJson().containsKey('moderation'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'moderation': <String, dynamic>{
            'input': <String, dynamic>{
              'type': 'moderation_result',
              'model': 'value',
              'flagged': false,
              'categories': <String, dynamic>{},
              'category_scores': <String, dynamic>{},
              'category_applied_input_types': <String, dynamic>{},
            },
            'output': <String, dynamic>{
              'type': 'moderation_result',
              'model': 'value',
              'flagged': false,
              'categories': <String, dynamic>{},
              'category_scores': <String, dynamic>{},
              'category_applied_input_types': <String, dynamic>{},
            },
          },
          'replacement': true,
        });
      },
    );
    test('moderation malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'moderation': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.moderation'),
          ),
        ),
      );
    });
    test(
      'parallel_tool_calls getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'parallel_tool_calls': true,
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.parallelToolCalls, true);
        expect(snapshot.hasParallelToolCalls, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(parallelToolCalls: true);
        expect(restored.parallelToolCalls, true);
        expect(restored.hasParallelToolCalls, isTrue);
        final cleared = snapshot.copyWith(clearParallelToolCalls: true);
        expect(cleared.hasParallelToolCalls, isFalse);
        expect(cleared.parallelToolCalls, isNull);
        expect(cleared.toJson().containsKey('parallel_tool_calls'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'parallel_tool_calls': true,
          'replacement': true,
        });
      },
    );
    test('parallel_tool_calls malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'parallel_tool_calls': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.parallel_tool_calls'),
          ),
        ),
      );
    });
    test('parallel_tool_calls explicit null rejected instead of omitted', () {
      expect(
        () => LiveCompactResponse.fromJson(const {'parallel_tool_calls': null}),
        throwsFormatException,
      );
    });

    test(
      'conversation getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'conversation': <String, dynamic>{'id': 'value'},
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.conversation, <String, dynamic>{'id': 'value'});
        expect(snapshot.hasConversation, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(conversation: <String, dynamic>{'id': 'value'});
        expect(restored.conversation, <String, dynamic>{'id': 'value'});
        expect(restored.hasConversation, isTrue);
        final cleared = snapshot.copyWith(clearConversation: true);
        expect(cleared.hasConversation, isFalse);
        expect(cleared.conversation, isNull);
        expect(cleared.toJson().containsKey('conversation'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'conversation': <String, dynamic>{'id': 'value'},
          'replacement': true,
        });
      },
    );
    test('conversation malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'conversation': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.conversation'),
          ),
        ),
      );
    });
    test(
      'max_output_tokens getter, omission, presence, copy, clear, equality and privacy',
      () {
        final json = <String, dynamic>{
          'max_output_tokens': 0,
          'future': <String, dynamic>{'secret': 'PRIVATE_SNAPSHOT'},
        };
        final snapshot = LiveCompactResponse.fromJson(json);
        expect(snapshot.maxOutputTokens, 0);
        expect(snapshot.hasMaxOutputTokens, isTrue);
        expect(snapshot.toJson(), json);
        expect(snapshot.copyWith(), snapshot);
        expect(snapshot.copyWith().hashCode, snapshot.hashCode);
        final restored = LiveCompactResponse.fromJson(
          const {},
        ).copyWith(maxOutputTokens: 0);
        expect(restored.maxOutputTokens, 0);
        expect(restored.hasMaxOutputTokens, isTrue);
        final cleared = snapshot.copyWith(clearMaxOutputTokens: true);
        expect(cleared.hasMaxOutputTokens, isFalse);
        expect(cleared.maxOutputTokens, isNull);
        expect(cleared.toJson().containsKey('max_output_tokens'), isFalse);
        expect(cleared.toJson()['future'], json['future']);
        expect(snapshot.toString(), isNot(contains('PRIVATE_')));
        expect(snapshot.copyWith(rawJson: {'replacement': true}).toJson(), {
          'max_output_tokens': 0,
          'replacement': true,
        });
      },
    );
    test('max_output_tokens malformed present known kind is contextual', () {
      expect(
        () => LiveCompactResponse.fromJson(const {
          'max_output_tokens': <dynamic>[true],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'safe context',
            contains('LiveCompactResponse.max_output_tokens'),
          ),
        ),
      );
    });
  });
}

final Map<String, Map<String, dynamic>> _granularFixtures =
    <String, Map<String, dynamic>>{
      'response.output_item.added': <String, dynamic>{
        'type': 'response.output_item.added',
        'output_index': 0,
        'item': <String, dynamic>{
          'id': 'value',
          'type': 'message',
          'role': 'assistant',
          'content': <dynamic>[],
          'status': 'in_progress',
        },
        'sequence_number': 0,
      },
      'response.output_item.done': <String, dynamic>{
        'type': 'response.output_item.done',
        'output_index': 0,
        'item': <String, dynamic>{
          'id': 'value',
          'type': 'message',
          'role': 'assistant',
          'content': <dynamic>[],
          'status': 'in_progress',
        },
        'sequence_number': 0,
      },
      'response.content_part.added': <String, dynamic>{
        'type': 'response.content_part.added',
        'item_id': 'value',
        'output_index': 0,
        'content_index': 0,
        'part': <String, dynamic>{
          'type': 'output_text',
          'text': 'value',
          'annotations': <dynamic>[],
          'logprobs': <dynamic>[],
        },
        'sequence_number': 0,
      },
      'response.content_part.done': <String, dynamic>{
        'type': 'response.content_part.done',
        'item_id': 'value',
        'output_index': 0,
        'content_index': 0,
        'part': <String, dynamic>{
          'type': 'output_text',
          'text': 'value',
          'annotations': <dynamic>[],
          'logprobs': <dynamic>[],
        },
        'sequence_number': 0,
      },
      'response.output_text.delta': <String, dynamic>{
        'type': 'response.output_text.delta',
        'item_id': 'value',
        'output_index': 0,
        'content_index': 0,
        'delta': 'value',
        'sequence_number': 0,
        'logprobs': <dynamic>[],
      },
      'response.output_text.done': <String, dynamic>{
        'type': 'response.output_text.done',
        'item_id': 'value',
        'output_index': 0,
        'content_index': 0,
        'text': 'value',
        'sequence_number': 0,
        'logprobs': <dynamic>[],
      },
      'response.output_text.annotation.added': <String, dynamic>{
        'type': 'response.output_text.annotation.added',
        'item_id': 'value',
        'output_index': 0,
        'content_index': 0,
        'annotation_index': 0,
        'annotation': <String, dynamic>{
          'type': 'file_citation',
          'file_id': 'value',
          'index': 0,
          'filename': 'value',
        },
        'sequence_number': 0,
      },
      'response.refusal.delta': <String, dynamic>{
        'type': 'response.refusal.delta',
        'item_id': 'value',
        'output_index': 0,
        'content_index': 0,
        'delta': 'value',
        'sequence_number': 0,
      },
      'response.refusal.done': <String, dynamic>{
        'type': 'response.refusal.done',
        'item_id': 'value',
        'output_index': 0,
        'content_index': 0,
        'refusal': 'value',
        'sequence_number': 0,
      },
      'response.function_call_arguments.delta': <String, dynamic>{
        'type': 'response.function_call_arguments.delta',
        'item_id': 'value',
        'output_index': 0,
        'delta': 'value',
        'sequence_number': 0,
      },
      'response.function_call_arguments.done': <String, dynamic>{
        'type': 'response.function_call_arguments.done',
        'item_id': 'value',
        'output_index': 0,
        'arguments': 'value',
        'sequence_number': 0,
      },
      'response.reasoning_text.delta': <String, dynamic>{
        'type': 'response.reasoning_text.delta',
        'item_id': 'value',
        'output_index': 0,
        'content_index': 0,
        'delta': 'value',
        'sequence_number': 0,
      },
      'response.reasoning_text.done': <String, dynamic>{
        'type': 'response.reasoning_text.done',
        'item_id': 'value',
        'output_index': 0,
        'content_index': 0,
        'text': 'value',
        'sequence_number': 0,
      },
      'response.reasoning_summary_part.added': <String, dynamic>{
        'type': 'response.reasoning_summary_part.added',
        'item_id': 'value',
        'output_index': 0,
        'summary_index': 0,
        'part': <String, dynamic>{'type': 'summary_text', 'text': 'value'},
        'sequence_number': 0,
      },
      'response.reasoning_summary_part.done': <String, dynamic>{
        'type': 'response.reasoning_summary_part.done',
        'item_id': 'value',
        'output_index': 0,
        'summary_index': 0,
        'part': <String, dynamic>{'type': 'summary_text', 'text': 'value'},
        'sequence_number': 0,
      },
      'response.reasoning_summary_text.delta': <String, dynamic>{
        'type': 'response.reasoning_summary_text.delta',
        'item_id': 'value',
        'output_index': 0,
        'summary_index': 0,
        'delta': 'value',
        'sequence_number': 0,
      },
      'response.reasoning_summary_text.done': <String, dynamic>{
        'type': 'response.reasoning_summary_text.done',
        'item_id': 'value',
        'output_index': 0,
        'summary_index': 0,
        'text': 'value',
        'sequence_number': 0,
      },
      'response.compaction.compacting': <String, dynamic>{
        'type': 'response.compaction.compacting',
        'sequence_number': 0,
        'output_index': 0,
        'item_id': 'value',
      },
      'response.audio.delta': <String, dynamic>{
        'type': 'response.audio.delta',
        'delta': 'value',
        'sequence_number': 0,
      },
      'response.audio.done': <String, dynamic>{
        'type': 'response.audio.done',
        'sequence_number': 0,
        'response_id': null,
      },
      'response.audio.transcript.delta': <String, dynamic>{
        'type': 'response.audio.transcript.delta',
        'response_id': null,
        'delta': 'value',
        'sequence_number': 0,
      },
      'response.audio.transcript.done': <String, dynamic>{
        'type': 'response.audio.transcript.done',
        'response_id': null,
        'sequence_number': 0,
      },
      'response.web_search_call.in_progress': <String, dynamic>{
        'type': 'response.web_search_call.in_progress',
        'output_index': 0,
        'item_id': 'value',
        'sequence_number': 0,
      },
      'response.web_search_call.searching': <String, dynamic>{
        'type': 'response.web_search_call.searching',
        'output_index': 0,
        'item_id': 'value',
        'sequence_number': 0,
      },
      'response.web_search_call.completed': <String, dynamic>{
        'type': 'response.web_search_call.completed',
        'output_index': 0,
        'item_id': 'value',
        'sequence_number': 0,
      },
      'response.file_search_call.in_progress': <String, dynamic>{
        'type': 'response.file_search_call.in_progress',
        'output_index': 0,
        'item_id': 'value',
        'sequence_number': 0,
      },
      'response.file_search_call.searching': <String, dynamic>{
        'type': 'response.file_search_call.searching',
        'output_index': 0,
        'item_id': 'value',
        'sequence_number': 0,
      },
      'response.file_search_call.completed': <String, dynamic>{
        'type': 'response.file_search_call.completed',
        'output_index': 0,
        'item_id': 'value',
        'sequence_number': 0,
      },
      'response.code_interpreter_call.in_progress': <String, dynamic>{
        'type': 'response.code_interpreter_call.in_progress',
        'output_index': 0,
        'item_id': 'value',
        'sequence_number': 0,
      },
      'response.code_interpreter_call.interpreting': <String, dynamic>{
        'type': 'response.code_interpreter_call.interpreting',
        'output_index': 0,
        'item_id': 'value',
        'sequence_number': 0,
      },
      'response.code_interpreter_call_code.delta': <String, dynamic>{
        'type': 'response.code_interpreter_call_code.delta',
        'output_index': 0,
        'item_id': 'value',
        'delta': 'value',
        'sequence_number': 0,
      },
      'response.code_interpreter_call_code.done': <String, dynamic>{
        'type': 'response.code_interpreter_call_code.done',
        'output_index': 0,
        'item_id': 'value',
        'code': 'value',
        'sequence_number': 0,
      },
      'response.code_interpreter_call.completed': <String, dynamic>{
        'type': 'response.code_interpreter_call.completed',
        'output_index': 0,
        'item_id': 'value',
        'sequence_number': 0,
      },
      'response.shell_call_command.added': <String, dynamic>{
        'type': 'response.shell_call_command.added',
        'sequence_number': 0,
        'output_index': 0,
        'command_index': 0,
        'command': 'value',
      },
      'response.shell_call_command.delta': <String, dynamic>{
        'type': 'response.shell_call_command.delta',
        'sequence_number': 0,
        'output_index': 0,
        'command_index': 0,
        'delta': 'value',
      },
      'response.shell_call_command.done': <String, dynamic>{
        'type': 'response.shell_call_command.done',
        'sequence_number': 0,
        'output_index': 0,
        'command_index': 0,
        'command': 'value',
      },
      'response.shell_call_output_content.delta': <String, dynamic>{
        'type': 'response.shell_call_output_content.delta',
        'sequence_number': 0,
        'item_id': 'value',
        'output_index': 0,
        'command_index': 0,
        'delta': <String, dynamic>{},
      },
      'response.shell_call_output_content.done': <String, dynamic>{
        'type': 'response.shell_call_output_content.done',
        'sequence_number': 0,
        'item_id': 'value',
        'output_index': 0,
        'command_index': 0,
        'output': <dynamic>[],
      },
      'response.image_generation_call.in_progress': <String, dynamic>{
        'type': 'response.image_generation_call.in_progress',
        'output_index': 0,
        'item_id': 'value',
        'sequence_number': 0,
      },
      'response.image_generation_call.generating': <String, dynamic>{
        'type': 'response.image_generation_call.generating',
        'output_index': 0,
        'item_id': 'value',
        'sequence_number': 0,
      },
      'response.image_generation_call.partial_image': <String, dynamic>{
        'type': 'response.image_generation_call.partial_image',
        'output_index': 0,
        'item_id': 'value',
        'sequence_number': 0,
        'partial_image_index': 0,
        'partial_image_b64': 'value',
      },
      'response.image_generation_call.completed': <String, dynamic>{
        'type': 'response.image_generation_call.completed',
        'output_index': 0,
        'item_id': 'value',
        'sequence_number': 0,
      },
      'response.mcp_call.in_progress': <String, dynamic>{
        'type': 'response.mcp_call.in_progress',
        'output_index': 0,
        'item_id': 'value',
        'sequence_number': 0,
      },
      'response.mcp_call.completed': <String, dynamic>{
        'type': 'response.mcp_call.completed',
        'item_id': 'value',
        'output_index': 0,
        'sequence_number': 0,
      },
      'response.mcp_call.failed': <String, dynamic>{
        'type': 'response.mcp_call.failed',
        'item_id': 'value',
        'output_index': 0,
        'sequence_number': 0,
      },
      'response.mcp_call_arguments.delta': <String, dynamic>{
        'type': 'response.mcp_call_arguments.delta',
        'output_index': 0,
        'item_id': 'value',
        'delta': 'value',
        'sequence_number': 0,
      },
      'response.mcp_call_arguments.done': <String, dynamic>{
        'type': 'response.mcp_call_arguments.done',
        'output_index': 0,
        'item_id': 'value',
        'arguments': 'value',
        'sequence_number': 0,
      },
      'response.mcp_list_tools.in_progress': <String, dynamic>{
        'type': 'response.mcp_list_tools.in_progress',
        'item_id': 'value',
        'output_index': 0,
        'sequence_number': 0,
      },
      'response.mcp_list_tools.completed': <String, dynamic>{
        'type': 'response.mcp_list_tools.completed',
        'item_id': 'value',
        'output_index': 0,
        'sequence_number': 0,
      },
      'response.mcp_list_tools.failed': <String, dynamic>{
        'type': 'response.mcp_list_tools.failed',
        'item_id': 'value',
        'output_index': 0,
        'sequence_number': 0,
      },
      'response.custom_tool_call_input.delta': <String, dynamic>{
        'type': 'response.custom_tool_call_input.delta',
        'output_index': 0,
        'item_id': 'value',
        'delta': 'value',
        'sequence_number': 0,
      },
      'response.custom_tool_call_input.done': <String, dynamic>{
        'type': 'response.custom_tool_call_input.done',
        'output_index': 0,
        'item_id': 'value',
        'input': 'value',
        'sequence_number': 0,
      },
      'error': <String, dynamic>{
        'type': 'error',
        'code': 'value',
        'message': 'value',
        'param': 'value',
        'sequence_number': 0,
      },
    };
final Map<String, List<String>> _granularRequired = <String, List<String>>{
  'response.output_item.added': <String>[
    'type',
    'output_index',
    'item',
    'sequence_number',
  ],
  'response.output_item.done': <String>[
    'type',
    'output_index',
    'item',
    'sequence_number',
  ],
  'response.content_part.added': <String>[
    'type',
    'item_id',
    'output_index',
    'content_index',
    'part',
    'sequence_number',
  ],
  'response.content_part.done': <String>[
    'type',
    'item_id',
    'output_index',
    'content_index',
    'part',
    'sequence_number',
  ],
  'response.output_text.delta': <String>[
    'type',
    'item_id',
    'output_index',
    'content_index',
    'delta',
    'sequence_number',
    'logprobs',
  ],
  'response.output_text.done': <String>[
    'type',
    'item_id',
    'output_index',
    'content_index',
    'text',
    'sequence_number',
    'logprobs',
  ],
  'response.output_text.annotation.added': <String>[
    'type',
    'item_id',
    'output_index',
    'content_index',
    'annotation_index',
    'annotation',
    'sequence_number',
  ],
  'response.refusal.delta': <String>[
    'type',
    'item_id',
    'output_index',
    'content_index',
    'delta',
    'sequence_number',
  ],
  'response.refusal.done': <String>[
    'type',
    'item_id',
    'output_index',
    'content_index',
    'refusal',
    'sequence_number',
  ],
  'response.function_call_arguments.delta': <String>[
    'type',
    'item_id',
    'output_index',
    'delta',
    'sequence_number',
  ],
  'response.function_call_arguments.done': <String>[
    'type',
    'item_id',
    'output_index',
    'arguments',
    'sequence_number',
  ],
  'response.reasoning_text.delta': <String>[
    'type',
    'item_id',
    'output_index',
    'content_index',
    'delta',
    'sequence_number',
  ],
  'response.reasoning_text.done': <String>[
    'type',
    'item_id',
    'output_index',
    'content_index',
    'text',
    'sequence_number',
  ],
  'response.reasoning_summary_part.added': <String>[
    'type',
    'item_id',
    'output_index',
    'summary_index',
    'part',
    'sequence_number',
  ],
  'response.reasoning_summary_part.done': <String>[
    'type',
    'item_id',
    'output_index',
    'summary_index',
    'part',
    'sequence_number',
  ],
  'response.reasoning_summary_text.delta': <String>[
    'type',
    'item_id',
    'output_index',
    'summary_index',
    'delta',
    'sequence_number',
  ],
  'response.reasoning_summary_text.done': <String>[
    'type',
    'item_id',
    'output_index',
    'summary_index',
    'text',
    'sequence_number',
  ],
  'response.compaction.compacting': <String>[
    'type',
    'sequence_number',
    'output_index',
    'item_id',
  ],
  'response.audio.delta': <String>['type', 'delta', 'sequence_number'],
  'response.audio.done': <String>['type', 'sequence_number', 'response_id'],
  'response.audio.transcript.delta': <String>[
    'type',
    'response_id',
    'delta',
    'sequence_number',
  ],
  'response.audio.transcript.done': <String>[
    'type',
    'response_id',
    'sequence_number',
  ],
  'response.web_search_call.in_progress': <String>[
    'type',
    'output_index',
    'item_id',
    'sequence_number',
  ],
  'response.web_search_call.searching': <String>[
    'type',
    'output_index',
    'item_id',
    'sequence_number',
  ],
  'response.web_search_call.completed': <String>[
    'type',
    'output_index',
    'item_id',
    'sequence_number',
  ],
  'response.file_search_call.in_progress': <String>[
    'type',
    'output_index',
    'item_id',
    'sequence_number',
  ],
  'response.file_search_call.searching': <String>[
    'type',
    'output_index',
    'item_id',
    'sequence_number',
  ],
  'response.file_search_call.completed': <String>[
    'type',
    'output_index',
    'item_id',
    'sequence_number',
  ],
  'response.code_interpreter_call.in_progress': <String>[
    'type',
    'output_index',
    'item_id',
    'sequence_number',
  ],
  'response.code_interpreter_call.interpreting': <String>[
    'type',
    'output_index',
    'item_id',
    'sequence_number',
  ],
  'response.code_interpreter_call_code.delta': <String>[
    'type',
    'output_index',
    'item_id',
    'delta',
    'sequence_number',
  ],
  'response.code_interpreter_call_code.done': <String>[
    'type',
    'output_index',
    'item_id',
    'code',
    'sequence_number',
  ],
  'response.code_interpreter_call.completed': <String>[
    'type',
    'output_index',
    'item_id',
    'sequence_number',
  ],
  'response.shell_call_command.added': <String>[
    'type',
    'sequence_number',
    'output_index',
    'command_index',
    'command',
  ],
  'response.shell_call_command.delta': <String>[
    'type',
    'sequence_number',
    'output_index',
    'command_index',
    'delta',
  ],
  'response.shell_call_command.done': <String>[
    'type',
    'sequence_number',
    'output_index',
    'command_index',
    'command',
  ],
  'response.shell_call_output_content.delta': <String>[
    'type',
    'sequence_number',
    'item_id',
    'output_index',
    'command_index',
    'delta',
  ],
  'response.shell_call_output_content.done': <String>[
    'type',
    'sequence_number',
    'item_id',
    'output_index',
    'command_index',
    'output',
  ],
  'response.image_generation_call.in_progress': <String>[
    'type',
    'output_index',
    'item_id',
    'sequence_number',
  ],
  'response.image_generation_call.generating': <String>[
    'type',
    'output_index',
    'item_id',
    'sequence_number',
  ],
  'response.image_generation_call.partial_image': <String>[
    'type',
    'output_index',
    'item_id',
    'sequence_number',
    'partial_image_index',
    'partial_image_b64',
  ],
  'response.image_generation_call.completed': <String>[
    'type',
    'output_index',
    'item_id',
    'sequence_number',
  ],
  'response.mcp_call.in_progress': <String>[
    'type',
    'output_index',
    'item_id',
    'sequence_number',
  ],
  'response.mcp_call.completed': <String>[
    'type',
    'item_id',
    'output_index',
    'sequence_number',
  ],
  'response.mcp_call.failed': <String>[
    'type',
    'item_id',
    'output_index',
    'sequence_number',
  ],
  'response.mcp_call_arguments.delta': <String>[
    'type',
    'output_index',
    'item_id',
    'delta',
    'sequence_number',
  ],
  'response.mcp_call_arguments.done': <String>[
    'type',
    'output_index',
    'item_id',
    'arguments',
    'sequence_number',
  ],
  'response.mcp_list_tools.in_progress': <String>[
    'type',
    'item_id',
    'output_index',
    'sequence_number',
  ],
  'response.mcp_list_tools.completed': <String>[
    'type',
    'item_id',
    'output_index',
    'sequence_number',
  ],
  'response.mcp_list_tools.failed': <String>[
    'type',
    'item_id',
    'output_index',
    'sequence_number',
  ],
  'response.custom_tool_call_input.delta': <String>[
    'type',
    'output_index',
    'item_id',
    'delta',
    'sequence_number',
  ],
  'response.custom_tool_call_input.done': <String>[
    'type',
    'output_index',
    'item_id',
    'input',
    'sequence_number',
  ],
  'error': <String>['type', 'code', 'message', 'param', 'sequence_number'],
};
final Map<String, String> _granularNonNullRequired = <String, String>{
  'response.output_item.added': 'output_index',
  'response.output_item.done': 'output_index',
  'response.content_part.added': 'item_id',
  'response.content_part.done': 'item_id',
  'response.output_text.delta': 'item_id',
  'response.output_text.done': 'item_id',
  'response.output_text.annotation.added': 'item_id',
  'response.refusal.delta': 'item_id',
  'response.refusal.done': 'item_id',
  'response.function_call_arguments.delta': 'item_id',
  'response.function_call_arguments.done': 'item_id',
  'response.reasoning_text.delta': 'item_id',
  'response.reasoning_text.done': 'item_id',
  'response.reasoning_summary_part.added': 'item_id',
  'response.reasoning_summary_part.done': 'item_id',
  'response.reasoning_summary_text.delta': 'item_id',
  'response.reasoning_summary_text.done': 'item_id',
  'response.compaction.compacting': 'sequence_number',
  'response.audio.delta': 'delta',
  'response.audio.done': 'sequence_number',
  'response.audio.transcript.delta': 'delta',
  'response.audio.transcript.done': 'sequence_number',
  'response.web_search_call.in_progress': 'output_index',
  'response.web_search_call.searching': 'output_index',
  'response.web_search_call.completed': 'output_index',
  'response.file_search_call.in_progress': 'output_index',
  'response.file_search_call.searching': 'output_index',
  'response.file_search_call.completed': 'output_index',
  'response.code_interpreter_call.in_progress': 'output_index',
  'response.code_interpreter_call.interpreting': 'output_index',
  'response.code_interpreter_call_code.delta': 'output_index',
  'response.code_interpreter_call_code.done': 'output_index',
  'response.code_interpreter_call.completed': 'output_index',
  'response.shell_call_command.added': 'sequence_number',
  'response.shell_call_command.delta': 'sequence_number',
  'response.shell_call_command.done': 'sequence_number',
  'response.shell_call_output_content.delta': 'sequence_number',
  'response.shell_call_output_content.done': 'sequence_number',
  'response.image_generation_call.in_progress': 'output_index',
  'response.image_generation_call.generating': 'output_index',
  'response.image_generation_call.partial_image': 'output_index',
  'response.image_generation_call.completed': 'output_index',
  'response.mcp_call.in_progress': 'output_index',
  'response.mcp_call.completed': 'item_id',
  'response.mcp_call.failed': 'item_id',
  'response.mcp_call_arguments.delta': 'output_index',
  'response.mcp_call_arguments.done': 'output_index',
  'response.mcp_list_tools.in_progress': 'item_id',
  'response.mcp_list_tools.completed': 'item_id',
  'response.mcp_list_tools.failed': 'item_id',
  'response.custom_tool_call_input.delta': 'output_index',
  'response.custom_tool_call_input.done': 'output_index',
  'error': 'message',
};

final Map<String, Map<String, dynamic>> _outputItemFixtures =
    <String, Map<String, dynamic>>{
      'OutputMessage': <String, dynamic>{
        'id': 'value',
        'type': 'message',
        'role': 'assistant',
        'content': <dynamic>[],
        'status': 'in_progress',
      },
      'FileSearchToolCall': <String, dynamic>{
        'id': 'value',
        'type': 'file_search_call',
        'status': 'in_progress',
        'queries': <dynamic>[],
      },
      'FunctionToolCall': <String, dynamic>{
        'type': 'function_call',
        'call_id': 'value',
        'name': 'value',
        'arguments': 'value',
      },
      'FunctionToolCallOutputResource': <String, dynamic>{
        'id': 'value',
        'output': 'value',
        'status': 'in_progress',
        'type': 'function_call_output',
      },
      'WebSearchToolCall': <String, dynamic>{
        'id': 'value',
        'type': 'web_search_call',
        'status': 'in_progress',
      },
      'ComputerToolCall': <String, dynamic>{
        'type': 'computer_call',
        'id': 'value',
        'call_id': 'value',
        'pending_safety_checks': <dynamic>[],
        'status': 'in_progress',
      },
      'ComputerToolCallOutputResource': <String, dynamic>{
        'call_id': 'value',
        'id': 'value',
        'output': <String, dynamic>{'type': 'computer_screenshot'},
        'status': 'completed',
        'type': 'computer_call_output',
      },
      'ReasoningItem': <String, dynamic>{
        'id': 'value',
        'summary': <dynamic>[],
        'type': 'reasoning',
      },
      'Program': <String, dynamic>{
        'type': 'program',
        'id': 'value',
        'call_id': 'value',
        'code': 'value',
        'fingerprint': 'value',
      },
      'ProgramOutput': <String, dynamic>{
        'type': 'program_output',
        'id': 'value',
        'call_id': 'value',
        'result': 'value',
        'status': 'completed',
      },
      'ToolSearchCall': <String, dynamic>{
        'type': 'tool_search_call',
        'id': 'value',
        'call_id': 'value',
        'execution': 'server',
        'arguments': null,
        'status': 'in_progress',
      },
      'ToolSearchOutput': <String, dynamic>{
        'type': 'tool_search_output',
        'id': 'value',
        'call_id': 'value',
        'execution': 'server',
        'tools': <dynamic>[],
        'status': 'in_progress',
      },
      'AdditionalTools': <String, dynamic>{
        'type': 'additional_tools',
        'id': 'value',
        'role': 'unknown',
        'tools': <dynamic>[],
      },
      'CompactionBody': <String, dynamic>{
        'type': 'compaction',
        'id': 'value',
        'encrypted_content': 'value',
      },
      'ImageGenToolCall': <String, dynamic>{
        'type': 'image_generation_call',
        'id': 'value',
        'status': 'in_progress',
        'result': 'value',
      },
      'CodeInterpreterToolCall': <String, dynamic>{
        'type': 'code_interpreter_call',
        'id': 'value',
        'status': 'in_progress',
        'container_id': 'value',
        'code': 'value',
        'outputs': <dynamic>[],
      },
      'LocalShellToolCall': <String, dynamic>{
        'type': 'local_shell_call',
        'id': 'value',
        'call_id': 'value',
        'action': <String, dynamic>{
          'type': 'exec',
          'command': <dynamic>[],
          'env': <String, dynamic>{},
        },
        'status': 'in_progress',
      },
      'LocalShellToolCallOutput': <String, dynamic>{
        'id': 'value',
        'type': 'local_shell_call_output',
        'call_id': null,
        'output': 'value',
      },
      'FunctionShellCall': <String, dynamic>{
        'type': 'shell_call',
        'id': 'value',
        'call_id': 'value',
        'action': <String, dynamic>{
          'commands': <dynamic>[],
          'timeout_ms': 0,
          'max_output_length': 0,
        },
        'status': 'in_progress',
        'environment': <String, dynamic>{'type': 'local'},
      },
      'FunctionShellCallOutput': <String, dynamic>{
        'type': 'shell_call_output',
        'id': 'value',
        'call_id': 'value',
        'status': 'in_progress',
        'output': <dynamic>[],
        'max_output_length': 0,
      },
      'ApplyPatchToolCall': <String, dynamic>{
        'type': 'apply_patch_call',
        'id': 'value',
        'call_id': 'value',
        'status': 'in_progress',
        'operation': <String, dynamic>{
          'type': 'create_file',
          'path': 'value',
          'diff': 'value',
        },
      },
      'ApplyPatchToolCallOutput': <String, dynamic>{
        'type': 'apply_patch_call_output',
        'id': 'value',
        'call_id': 'value',
        'status': 'completed',
      },
      'MCPToolCall': <String, dynamic>{
        'type': 'mcp_call',
        'id': 'value',
        'server_label': 'value',
        'name': 'value',
        'arguments': 'value',
      },
      'MCPListTools': <String, dynamic>{
        'type': 'mcp_list_tools',
        'id': 'value',
        'server_label': 'value',
        'tools': <dynamic>[],
      },
      'MCPApprovalRequest': <String, dynamic>{
        'type': 'mcp_approval_request',
        'id': 'value',
        'server_label': 'value',
        'name': 'value',
        'arguments': 'value',
      },
      'MCPApprovalResponseResource': <String, dynamic>{
        'type': 'mcp_approval_response',
        'id': 'value',
        'request_id': null,
        'approve': false,
        'approval_request_id': 'value',
      },
      'CustomToolCall': <String, dynamic>{
        'type': 'custom_tool_call',
        'call_id': 'value',
        'name': 'value',
        'input': 'value',
      },
      'CustomToolCallOutputResource': <String, dynamic>{
        'call_id': 'value',
        'id': 'value',
        'output': 'value',
        'status': 'in_progress',
        'type': 'custom_tool_call_output',
      },
    };
