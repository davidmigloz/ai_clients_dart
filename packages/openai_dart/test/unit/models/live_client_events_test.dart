import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE_CLIENT_COMMAND';
Matcher _safe(String field) => isA<FormatException>()
    .having((error) => error.message, 'context', contains(field))
    .having((error) => error.source, 'source', isNull)
    .having((error) => error.offset, 'offset', isNull)
    .having((error) => error.toString(), 'privacy', isNot(contains(_private)));
void main() {
  group('LiveSessionStartEvent', () {
    final minimal = <String, dynamic>{
      'type': 'session.start',
      'session': {'model': 'gpt-live-future'},
    };
    final full = <String, dynamic>{
      'type': 'session.start',
      'event_id': 'PRIVATE_CLIENT_COMMAND',
      'session': {
        'model': 'gpt-live-future',
        'instructions': null,
        'audio': {
          'format': {'type': 'audio/pcm', 'rate': 24000},
        },
        'delegation': {'type': 'client'},
        'store': false,
      },
    };
    test(
      'all declared fields, fixed type, roundtrip/copy/value/hash/private contracts',
      () {
        for (final wire in [minimal, full]) {
          final model = LiveSessionStartEvent.fromJson(wire);
          final peer = LiveSessionStartEvent.fromJson({...wire});
          expect(model.type, 'session.start');
          expect(model.toJson(), wire);
          expect(model, peer);
          expect(model.hashCode, peer.hashCode);
          expect(model.copyWith(), model);
          expect(model.toString(), isNot(contains(_private)));
        }
        final model = LiveSessionStartEvent.fromJson(full);
        expect(model.eventId, _private);
        expect(model.hasEventId, isTrue);
        expect(model.session.toJson(), full['session']);
        expect(model.copyWith(session: model.session), model);
      },
    );
    test('public primary/sideband/fork role roots preserve exact wire', () {
      final model = LiveSessionStartEvent.fromJson(full);
      expect(LiveClientEvent.fromJson(full), model);
      expect(
        () => LiveClientEvent.fromForkJson(full),
        throwsA(_safe('session')),
      );
      expect(model, isNot(isA<LiveSidebandClientEvent>()));
      expect(
        () => LiveSidebandClientEvent.fromJson(full),
        throwsA(_safe('type')),
      );
    });
    test(
      'correlation absence/null/value and explicit clear survive copies',
      () {
        final absent = LiveSessionStartEvent.fromJson(minimal);
        expect(absent.eventId, isNull);
        expect(absent.hasEventId, isFalse);
        expect(absent.copyWith().toJson().containsKey('event_id'), isFalse);
        final nulled = absent.copyWith(eventId: null);
        expect(nulled.hasEventId, isTrue);
        expect(nulled.toJson(), {...minimal, 'event_id': null});
        expect(LiveSessionStartEvent.fromJson(nulled.toJson()), nulled);
        final valued = nulled.copyWith(eventId: _private);
        expect(valued.eventId, _private);
        expect(valued.hasEventId, isTrue);
        expect(valued.copyWith(eventId: null).toJson(), nulled.toJson());
        expect(valued.copyWith(clearEventId: true), absent);
        expect(valued.copyWith(clearEventId: true, eventId: 'ignored'), absent);
        expect(absent, isNot(nulled));
        expect(valued, isNot(nulled));
      },
    );
    test(
      'correlation uses exact 512 Unicode codepoint bound with no minimum',
      () {
        final model = LiveSessionStartEvent.fromJson(minimal);
        final bound = List.filled(512, '😀').join();
        expect(model.copyWith(eventId: bound).eventId, bound);
        expect(model.copyWith(eventId: '').eventId, '');
        expect(
          () => model.copyWith(eventId: '$bound😀'),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveSessionStartEvent.fromJson({
            ...minimal,
            'event_id': '$bound😀',
          }),
          throwsA(_safe('event_id')),
        );
      },
    );
    test('known event_id and discriminator malformed values are safe', () {
      for (final value in <Object?>[5, false, [], {}]) {
        expect(
          () => LiveSessionStartEvent.fromJson({...minimal, 'event_id': value}),
          throwsA(_safe('event_id')),
        );
        expect(
          () =>
              LiveSessionStartEvent.fromJson(minimal).copyWith(eventId: value),
          throwsA(_safe('event_id')),
        );
      }
      for (final value in <Object?>[null, 5, false, _private]) {
        expect(
          () => LiveSessionStartEvent.fromJson({...minimal, 'type': value}),
          throwsA(_safe('type')),
        );
      }
      expect(
        () => LiveSessionStartEvent.fromJson({...minimal}..remove('type')),
        throwsA(_safe('type')),
      );
    });
    test(
      'finite future metadata stays private, owned and typed authoritative',
      () {
        final metadata = <String, dynamic>{
          'nested': <Object?>[_private],
        };
        final source = <String, dynamic>{...full, 'future': metadata};
        final model = LiveSessionStartEvent.fromJson(source);
        metadata['nested'] = <Object?>[];
        expect((model.rawJson['future'] as Map)['nested'], [_private]);
        expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
        expect(
          () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
          throwsUnsupportedError,
        );
        expect(model.copyWith().toJson(), model.toJson());
        expect(
          model
              .copyWith(
                rawJson: {
                  'type': _private,
                  'event_id': 5,
                  'future': {
                    'nested': [_private],
                  },
                },
              )
              .toJson(),
          model.toJson(),
        );
        expect(model.toString(), isNot(contains(_private)));
      },
    );
    test('required session presence and wrong known shape', () {
      expect(
        () => LiveSessionStartEvent.fromJson({...minimal}..remove('session')),
        throwsA(_safe('session')),
      );
      expect(
        () => LiveSessionStartEvent.fromJson({
          ...minimal,
          'session': 'PRIVATE_CLIENT_COMMAND',
        }),
        throwsA(_safe('session')),
      );
      expect(
        () => LiveSessionStartEvent.fromJson({...minimal, 'session': null}),
        throwsA(_safe('session')),
      );
    });
    test('runtime Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveSessionStartEvent.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveSessionStartEvent')),
      );
      expect(
        () => LiveSessionStartEvent.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveSessionStartEvent')),
      );
    });
    test('runtime -Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveSessionStartEvent.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveSessionStartEvent')),
      );
      expect(
        () => LiveSessionStartEvent.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveSessionStartEvent')),
      );
    });
    test('runtime NaN overflow stays finite-only', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveSessionStartEvent.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveSessionStartEvent')),
      );
      expect(
        () => LiveSessionStartEvent.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveSessionStartEvent')),
      );
    });
  });
  group('LiveForkSessionStartEvent', () {
    final minimal = <String, dynamic>{
      'type': 'session.start',
      'session': <String, dynamic>{},
    };
    final full = <String, dynamic>{
      'type': 'session.start',
      'event_id': 'PRIVATE_CLIENT_COMMAND',
      'session': {
        'audio': {
          'format': {'type': 'audio/pcm', 'rate': 16000},
        },
        'store': false,
      },
    };
    test(
      'all declared fields, fixed type, roundtrip/copy/value/hash/private contracts',
      () {
        for (final wire in [minimal, full]) {
          final model = LiveForkSessionStartEvent.fromJson(wire);
          final peer = LiveForkSessionStartEvent.fromJson({...wire});
          expect(model.type, 'session.start');
          expect(model.toJson(), wire);
          expect(model, peer);
          expect(model.hashCode, peer.hashCode);
          expect(model.copyWith(), model);
          expect(model.toString(), isNot(contains(_private)));
        }
        final model = LiveForkSessionStartEvent.fromJson(full);
        expect(model.eventId, _private);
        expect(model.hasEventId, isTrue);
        expect(model.session.toJson(), full['session']);
        expect(model.copyWith(session: model.session), model);
      },
    );
    test('public primary/sideband/fork role roots preserve exact wire', () {
      final model = LiveForkSessionStartEvent.fromJson(full);
      expect(LiveClientEvent.fromForkJson(full), model);
      expect(() => LiveClientEvent.fromJson(full), throwsA(_safe('session')));
      expect(
        () => LiveSidebandClientEvent.fromJson(full),
        throwsA(_safe('type')),
      );
    });
    test(
      'correlation absence/null/value and explicit clear survive copies',
      () {
        final absent = LiveForkSessionStartEvent.fromJson(minimal);
        expect(absent.eventId, isNull);
        expect(absent.hasEventId, isFalse);
        expect(absent.copyWith().toJson().containsKey('event_id'), isFalse);
        final nulled = absent.copyWith(eventId: null);
        expect(nulled.hasEventId, isTrue);
        expect(nulled.toJson(), {...minimal, 'event_id': null});
        expect(LiveForkSessionStartEvent.fromJson(nulled.toJson()), nulled);
        final valued = nulled.copyWith(eventId: _private);
        expect(valued.eventId, _private);
        expect(valued.hasEventId, isTrue);
        expect(valued.copyWith(eventId: null).toJson(), nulled.toJson());
        expect(valued.copyWith(clearEventId: true), absent);
        expect(valued.copyWith(clearEventId: true, eventId: 'ignored'), absent);
        expect(absent, isNot(nulled));
        expect(valued, isNot(nulled));
      },
    );
    test(
      'correlation uses exact 512 Unicode codepoint bound with no minimum',
      () {
        final model = LiveForkSessionStartEvent.fromJson(minimal);
        final bound = List.filled(512, '😀').join();
        expect(model.copyWith(eventId: bound).eventId, bound);
        expect(model.copyWith(eventId: '').eventId, '');
        expect(
          () => model.copyWith(eventId: '$bound😀'),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveForkSessionStartEvent.fromJson({
            ...minimal,
            'event_id': '$bound😀',
          }),
          throwsA(_safe('event_id')),
        );
      },
    );
    test('known event_id and discriminator malformed values are safe', () {
      for (final value in <Object?>[5, false, [], {}]) {
        expect(
          () => LiveForkSessionStartEvent.fromJson({
            ...minimal,
            'event_id': value,
          }),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveForkSessionStartEvent.fromJson(
            minimal,
          ).copyWith(eventId: value),
          throwsA(_safe('event_id')),
        );
      }
      for (final value in <Object?>[null, 5, false, _private]) {
        expect(
          () => LiveForkSessionStartEvent.fromJson({...minimal, 'type': value}),
          throwsA(_safe('type')),
        );
      }
      expect(
        () => LiveForkSessionStartEvent.fromJson({...minimal}..remove('type')),
        throwsA(_safe('type')),
      );
    });
    test(
      'finite future metadata stays private, owned and typed authoritative',
      () {
        final metadata = <String, dynamic>{
          'nested': <Object?>[_private],
        };
        final source = <String, dynamic>{...full, 'future': metadata};
        final model = LiveForkSessionStartEvent.fromJson(source);
        metadata['nested'] = <Object?>[];
        expect((model.rawJson['future'] as Map)['nested'], [_private]);
        expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
        expect(
          () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
          throwsUnsupportedError,
        );
        expect(model.copyWith().toJson(), model.toJson());
        expect(
          model
              .copyWith(
                rawJson: {
                  'type': _private,
                  'event_id': 5,
                  'future': {
                    'nested': [_private],
                  },
                },
              )
              .toJson(),
          model.toJson(),
        );
        expect(model.toString(), isNot(contains(_private)));
      },
    );
    test('required session presence and wrong known shape', () {
      expect(
        () =>
            LiveForkSessionStartEvent.fromJson({...minimal}..remove('session')),
        throwsA(_safe('session')),
      );
      expect(
        () => LiveForkSessionStartEvent.fromJson({
          ...minimal,
          'session': 'PRIVATE_CLIENT_COMMAND',
        }),
        throwsA(_safe('session')),
      );
      expect(
        () => LiveForkSessionStartEvent.fromJson({...minimal, 'session': null}),
        throwsA(_safe('session')),
      );
    });
    test('runtime Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveForkSessionStartEvent.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveForkSessionStartEvent')),
      );
      expect(
        () => LiveForkSessionStartEvent.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveForkSessionStartEvent')),
      );
    });
    test('runtime -Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveForkSessionStartEvent.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveForkSessionStartEvent')),
      );
      expect(
        () => LiveForkSessionStartEvent.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveForkSessionStartEvent')),
      );
    });
    test('runtime NaN overflow stays finite-only', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveForkSessionStartEvent.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveForkSessionStartEvent')),
      );
      expect(
        () => LiveForkSessionStartEvent.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveForkSessionStartEvent')),
      );
    });
  });
  group('LiveSessionUpdateParam', () {
    final minimal = <String, dynamic>{
      'type': 'session.update',
      'session': <String, dynamic>{},
    };
    final full = <String, dynamic>{
      'type': 'session.update',
      'event_id': 'PRIVATE_CLIENT_COMMAND',
      'session': {
        'delegation': {
          'type': 'responses',
          'responses': {'instructions': null, 'max_output_tokens': 16},
        },
      },
    };
    test(
      'all declared fields, fixed type, roundtrip/copy/value/hash/private contracts',
      () {
        for (final wire in [minimal, full]) {
          final model = LiveSessionUpdateParam.fromJson(wire);
          final peer = LiveSessionUpdateParam.fromJson({...wire});
          expect(model.type, 'session.update');
          expect(model.toJson(), wire);
          expect(model, peer);
          expect(model.hashCode, peer.hashCode);
          expect(model.copyWith(), model);
          expect(model.toString(), isNot(contains(_private)));
        }
        final model = LiveSessionUpdateParam.fromJson(full);
        expect(model.eventId, _private);
        expect(model.hasEventId, isTrue);
        expect(model.session.toJson(), full['session']);
        expect(model.copyWith(session: model.session), model);
      },
    );
    test('public primary/sideband/fork role roots preserve exact wire', () {
      final model = LiveSessionUpdateParam.fromJson(full);
      expect(LiveClientEvent.fromJson(full), model);
      expect(LiveClientEvent.fromForkJson(full), model);
      expect(model, isA<LiveSidebandClientEvent>());
      expect(LiveSidebandClientEvent.fromJson(full), model);
    });
    test(
      'correlation absence/null/value and explicit clear survive copies',
      () {
        final absent = LiveSessionUpdateParam.fromJson(minimal);
        expect(absent.eventId, isNull);
        expect(absent.hasEventId, isFalse);
        expect(absent.copyWith().toJson().containsKey('event_id'), isFalse);
        final nulled = absent.copyWith(eventId: null);
        expect(nulled.hasEventId, isTrue);
        expect(nulled.toJson(), {...minimal, 'event_id': null});
        expect(LiveSessionUpdateParam.fromJson(nulled.toJson()), nulled);
        final valued = nulled.copyWith(eventId: _private);
        expect(valued.eventId, _private);
        expect(valued.hasEventId, isTrue);
        expect(valued.copyWith(eventId: null).toJson(), nulled.toJson());
        expect(valued.copyWith(clearEventId: true), absent);
        expect(valued.copyWith(clearEventId: true, eventId: 'ignored'), absent);
        expect(absent, isNot(nulled));
        expect(valued, isNot(nulled));
      },
    );
    test(
      'correlation uses exact 512 Unicode codepoint bound with no minimum',
      () {
        final model = LiveSessionUpdateParam.fromJson(minimal);
        final bound = List.filled(512, '😀').join();
        expect(model.copyWith(eventId: bound).eventId, bound);
        expect(model.copyWith(eventId: '').eventId, '');
        expect(
          () => model.copyWith(eventId: '$bound😀'),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveSessionUpdateParam.fromJson({
            ...minimal,
            'event_id': '$bound😀',
          }),
          throwsA(_safe('event_id')),
        );
      },
    );
    test('known event_id and discriminator malformed values are safe', () {
      for (final value in <Object?>[5, false, [], {}]) {
        expect(
          () =>
              LiveSessionUpdateParam.fromJson({...minimal, 'event_id': value}),
          throwsA(_safe('event_id')),
        );
        expect(
          () =>
              LiveSessionUpdateParam.fromJson(minimal).copyWith(eventId: value),
          throwsA(_safe('event_id')),
        );
      }
      for (final value in <Object?>[null, 5, false, _private]) {
        expect(
          () => LiveSessionUpdateParam.fromJson({...minimal, 'type': value}),
          throwsA(_safe('type')),
        );
      }
      expect(
        () => LiveSessionUpdateParam.fromJson({...minimal}..remove('type')),
        throwsA(_safe('type')),
      );
    });
    test(
      'finite future metadata stays private, owned and typed authoritative',
      () {
        final metadata = <String, dynamic>{
          'nested': <Object?>[_private],
        };
        final source = <String, dynamic>{...full, 'future': metadata};
        final model = LiveSessionUpdateParam.fromJson(source);
        metadata['nested'] = <Object?>[];
        expect((model.rawJson['future'] as Map)['nested'], [_private]);
        expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
        expect(
          () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
          throwsUnsupportedError,
        );
        expect(model.copyWith().toJson(), model.toJson());
        expect(
          model
              .copyWith(
                rawJson: {
                  'type': _private,
                  'event_id': 5,
                  'future': {
                    'nested': [_private],
                  },
                },
              )
              .toJson(),
          model.toJson(),
        );
        expect(model.toString(), isNot(contains(_private)));
      },
    );
    test('required session presence and wrong known shape', () {
      expect(
        () => LiveSessionUpdateParam.fromJson({...minimal}..remove('session')),
        throwsA(_safe('session')),
      );
      expect(
        () => LiveSessionUpdateParam.fromJson({
          ...minimal,
          'session': 'PRIVATE_CLIENT_COMMAND',
        }),
        throwsA(_safe('session')),
      );
      expect(
        () => LiveSessionUpdateParam.fromJson({...minimal, 'session': null}),
        throwsA(_safe('session')),
      );
    });
    test('runtime Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveSessionUpdateParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveSessionUpdateParam')),
      );
      expect(
        () => LiveSessionUpdateParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveSessionUpdateParam')),
      );
    });
    test('runtime -Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveSessionUpdateParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveSessionUpdateParam')),
      );
      expect(
        () => LiveSessionUpdateParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveSessionUpdateParam')),
      );
    });
    test('runtime NaN overflow stays finite-only', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveSessionUpdateParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveSessionUpdateParam')),
      );
      expect(
        () => LiveSessionUpdateParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveSessionUpdateParam')),
      );
    });
  });
  group('LiveInputAudioAppendEvent', () {
    final minimal = <String, dynamic>{
      'type': 'session.input_audio.append',
      'audio': 'AA==',
    };
    final full = <String, dynamic>{
      'type': 'session.input_audio.append',
      'event_id': 'PRIVATE_CLIENT_COMMAND',
      'audio': 'AACAAIAAAIAAAP9/AIAAgA==',
    };
    test(
      'all declared fields, fixed type, roundtrip/copy/value/hash/private contracts',
      () {
        for (final wire in [minimal, full]) {
          final model = LiveInputAudioAppendEvent.fromJson(wire);
          final peer = LiveInputAudioAppendEvent.fromJson({...wire});
          expect(model.type, 'session.input_audio.append');
          expect(model.toJson(), wire);
          expect(model, peer);
          expect(model.hashCode, peer.hashCode);
          expect(model.copyWith(), model);
          expect(model.toString(), isNot(contains(_private)));
        }
        final model = LiveInputAudioAppendEvent.fromJson(full);
        expect(model.eventId, _private);
        expect(model.hasEventId, isTrue);
        expect(model.audio, full['audio']);
        expect(model.copyWith(audio: model.audio), model);
      },
    );
    test('public primary/sideband/fork role roots preserve exact wire', () {
      final model = LiveInputAudioAppendEvent.fromJson(full);
      expect(LiveClientEvent.fromJson(full), model);
      expect(LiveClientEvent.fromForkJson(full), model);
      expect(model, isNot(isA<LiveSidebandClientEvent>()));
      expect(
        () => LiveSidebandClientEvent.fromJson(full),
        throwsA(_safe('type')),
      );
    });
    test(
      'correlation absence/null/value and explicit clear survive copies',
      () {
        final absent = LiveInputAudioAppendEvent.fromJson(minimal);
        expect(absent.eventId, isNull);
        expect(absent.hasEventId, isFalse);
        expect(absent.copyWith().toJson().containsKey('event_id'), isFalse);
        final nulled = absent.copyWith(eventId: null);
        expect(nulled.hasEventId, isTrue);
        expect(nulled.toJson(), {...minimal, 'event_id': null});
        expect(LiveInputAudioAppendEvent.fromJson(nulled.toJson()), nulled);
        final valued = nulled.copyWith(eventId: _private);
        expect(valued.eventId, _private);
        expect(valued.hasEventId, isTrue);
        expect(valued.copyWith(eventId: null).toJson(), nulled.toJson());
        expect(valued.copyWith(clearEventId: true), absent);
        expect(valued.copyWith(clearEventId: true, eventId: 'ignored'), absent);
        expect(absent, isNot(nulled));
        expect(valued, isNot(nulled));
      },
    );
    test(
      'correlation uses exact 512 Unicode codepoint bound with no minimum',
      () {
        final model = LiveInputAudioAppendEvent.fromJson(minimal);
        final bound = List.filled(512, '😀').join();
        expect(model.copyWith(eventId: bound).eventId, bound);
        expect(model.copyWith(eventId: '').eventId, '');
        expect(
          () => model.copyWith(eventId: '$bound😀'),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveInputAudioAppendEvent.fromJson({
            ...minimal,
            'event_id': '$bound😀',
          }),
          throwsA(_safe('event_id')),
        );
      },
    );
    test('known event_id and discriminator malformed values are safe', () {
      for (final value in <Object?>[5, false, [], {}]) {
        expect(
          () => LiveInputAudioAppendEvent.fromJson({
            ...minimal,
            'event_id': value,
          }),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveInputAudioAppendEvent.fromJson(
            minimal,
          ).copyWith(eventId: value),
          throwsA(_safe('event_id')),
        );
      }
      for (final value in <Object?>[null, 5, false, _private]) {
        expect(
          () => LiveInputAudioAppendEvent.fromJson({...minimal, 'type': value}),
          throwsA(_safe('type')),
        );
      }
      expect(
        () => LiveInputAudioAppendEvent.fromJson({...minimal}..remove('type')),
        throwsA(_safe('type')),
      );
    });
    test(
      'finite future metadata stays private, owned and typed authoritative',
      () {
        final metadata = <String, dynamic>{
          'nested': <Object?>[_private],
        };
        final source = <String, dynamic>{...full, 'future': metadata};
        final model = LiveInputAudioAppendEvent.fromJson(source);
        metadata['nested'] = <Object?>[];
        expect((model.rawJson['future'] as Map)['nested'], [_private]);
        expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
        expect(
          () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
          throwsUnsupportedError,
        );
        expect(model.copyWith().toJson(), model.toJson());
        expect(
          model
              .copyWith(
                rawJson: {
                  'type': _private,
                  'event_id': 5,
                  'future': {
                    'nested': [_private],
                  },
                },
              )
              .toJson(),
          model.toJson(),
        );
        expect(model.toString(), isNot(contains(_private)));
      },
    );
    test('required audio presence and wrong known shape', () {
      expect(
        () => LiveInputAudioAppendEvent.fromJson({...minimal}..remove('audio')),
        throwsA(_safe('audio')),
      );
      expect(
        () => LiveInputAudioAppendEvent.fromJson({...minimal, 'audio': 5}),
        throwsA(_safe('audio')),
      );
      expect(
        () => LiveInputAudioAppendEvent.fromJson({...minimal, 'audio': null}),
        throwsA(_safe('audio')),
      );
    });
    test('runtime Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputAudioAppendEvent.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveInputAudioAppendEvent')),
      );
      expect(
        () => LiveInputAudioAppendEvent.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveInputAudioAppendEvent')),
      );
    });
    test('runtime -Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputAudioAppendEvent.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveInputAudioAppendEvent')),
      );
      expect(
        () => LiveInputAudioAppendEvent.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveInputAudioAppendEvent')),
      );
    });
    test('runtime NaN overflow stays finite-only', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputAudioAppendEvent.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveInputAudioAppendEvent')),
      );
      expect(
        () => LiveInputAudioAppendEvent.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveInputAudioAppendEvent')),
      );
    });
  });
  group('LiveInputAudioMuteParam', () {
    final minimal = <String, dynamic>{'type': 'session.input_audio.mute'};
    final full = <String, dynamic>{
      'type': 'session.input_audio.mute',
      'event_id': 'PRIVATE_CLIENT_COMMAND',
    };
    test(
      'all declared fields, fixed type, roundtrip/copy/value/hash/private contracts',
      () {
        for (final wire in [minimal, full]) {
          final model = LiveInputAudioMuteParam.fromJson(wire);
          final peer = LiveInputAudioMuteParam.fromJson({...wire});
          expect(model.type, 'session.input_audio.mute');
          expect(model.toJson(), wire);
          expect(model, peer);
          expect(model.hashCode, peer.hashCode);
          expect(model.copyWith(), model);
          expect(model.toString(), isNot(contains(_private)));
        }
        final model = LiveInputAudioMuteParam.fromJson(full);
        expect(model.eventId, _private);
        expect(model.hasEventId, isTrue);
      },
    );
    test('public primary/sideband/fork role roots preserve exact wire', () {
      final model = LiveInputAudioMuteParam.fromJson(full);
      expect(LiveClientEvent.fromJson(full), model);
      expect(LiveClientEvent.fromForkJson(full), model);
      expect(model, isA<LiveSidebandClientEvent>());
      expect(LiveSidebandClientEvent.fromJson(full), model);
    });
    test(
      'correlation absence/null/value and explicit clear survive copies',
      () {
        final absent = LiveInputAudioMuteParam.fromJson(minimal);
        expect(absent.eventId, isNull);
        expect(absent.hasEventId, isFalse);
        expect(absent.copyWith().toJson().containsKey('event_id'), isFalse);
        final nulled = absent.copyWith(eventId: null);
        expect(nulled.hasEventId, isTrue);
        expect(nulled.toJson(), {...minimal, 'event_id': null});
        expect(LiveInputAudioMuteParam.fromJson(nulled.toJson()), nulled);
        final valued = nulled.copyWith(eventId: _private);
        expect(valued.eventId, _private);
        expect(valued.hasEventId, isTrue);
        expect(valued.copyWith(eventId: null).toJson(), nulled.toJson());
        expect(valued.copyWith(clearEventId: true), absent);
        expect(valued.copyWith(clearEventId: true, eventId: 'ignored'), absent);
        expect(absent, isNot(nulled));
        expect(valued, isNot(nulled));
      },
    );
    test(
      'correlation uses exact 512 Unicode codepoint bound with no minimum',
      () {
        final model = LiveInputAudioMuteParam.fromJson(minimal);
        final bound = List.filled(512, '😀').join();
        expect(model.copyWith(eventId: bound).eventId, bound);
        expect(model.copyWith(eventId: '').eventId, '');
        expect(
          () => model.copyWith(eventId: '$bound😀'),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveInputAudioMuteParam.fromJson({
            ...minimal,
            'event_id': '$bound😀',
          }),
          throwsA(_safe('event_id')),
        );
      },
    );
    test('known event_id and discriminator malformed values are safe', () {
      for (final value in <Object?>[5, false, [], {}]) {
        expect(
          () =>
              LiveInputAudioMuteParam.fromJson({...minimal, 'event_id': value}),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveInputAudioMuteParam.fromJson(
            minimal,
          ).copyWith(eventId: value),
          throwsA(_safe('event_id')),
        );
      }
      for (final value in <Object?>[null, 5, false, _private]) {
        expect(
          () => LiveInputAudioMuteParam.fromJson({...minimal, 'type': value}),
          throwsA(_safe('type')),
        );
      }
      expect(
        () => LiveInputAudioMuteParam.fromJson({...minimal}..remove('type')),
        throwsA(_safe('type')),
      );
    });
    test(
      'finite future metadata stays private, owned and typed authoritative',
      () {
        final metadata = <String, dynamic>{
          'nested': <Object?>[_private],
        };
        final source = <String, dynamic>{...full, 'future': metadata};
        final model = LiveInputAudioMuteParam.fromJson(source);
        metadata['nested'] = <Object?>[];
        expect((model.rawJson['future'] as Map)['nested'], [_private]);
        expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
        expect(
          () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
          throwsUnsupportedError,
        );
        expect(model.copyWith().toJson(), model.toJson());
        expect(
          model
              .copyWith(
                rawJson: {
                  'type': _private,
                  'event_id': 5,
                  'future': {
                    'nested': [_private],
                  },
                },
              )
              .toJson(),
          model.toJson(),
        );
        expect(model.toString(), isNot(contains(_private)));
      },
    );
    test('runtime Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputAudioMuteParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveInputAudioMuteParam')),
      );
      expect(
        () => LiveInputAudioMuteParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveInputAudioMuteParam')),
      );
    });
    test('runtime -Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputAudioMuteParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveInputAudioMuteParam')),
      );
      expect(
        () => LiveInputAudioMuteParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveInputAudioMuteParam')),
      );
    });
    test('runtime NaN overflow stays finite-only', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputAudioMuteParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveInputAudioMuteParam')),
      );
      expect(
        () => LiveInputAudioMuteParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveInputAudioMuteParam')),
      );
    });
  });
  group('LiveInputAudioUnmuteParam', () {
    final minimal = <String, dynamic>{'type': 'session.input_audio.unmute'};
    final full = <String, dynamic>{
      'type': 'session.input_audio.unmute',
      'event_id': 'PRIVATE_CLIENT_COMMAND',
    };
    test(
      'all declared fields, fixed type, roundtrip/copy/value/hash/private contracts',
      () {
        for (final wire in [minimal, full]) {
          final model = LiveInputAudioUnmuteParam.fromJson(wire);
          final peer = LiveInputAudioUnmuteParam.fromJson({...wire});
          expect(model.type, 'session.input_audio.unmute');
          expect(model.toJson(), wire);
          expect(model, peer);
          expect(model.hashCode, peer.hashCode);
          expect(model.copyWith(), model);
          expect(model.toString(), isNot(contains(_private)));
        }
        final model = LiveInputAudioUnmuteParam.fromJson(full);
        expect(model.eventId, _private);
        expect(model.hasEventId, isTrue);
      },
    );
    test('public primary/sideband/fork role roots preserve exact wire', () {
      final model = LiveInputAudioUnmuteParam.fromJson(full);
      expect(LiveClientEvent.fromJson(full), model);
      expect(LiveClientEvent.fromForkJson(full), model);
      expect(model, isA<LiveSidebandClientEvent>());
      expect(LiveSidebandClientEvent.fromJson(full), model);
    });
    test(
      'correlation absence/null/value and explicit clear survive copies',
      () {
        final absent = LiveInputAudioUnmuteParam.fromJson(minimal);
        expect(absent.eventId, isNull);
        expect(absent.hasEventId, isFalse);
        expect(absent.copyWith().toJson().containsKey('event_id'), isFalse);
        final nulled = absent.copyWith(eventId: null);
        expect(nulled.hasEventId, isTrue);
        expect(nulled.toJson(), {...minimal, 'event_id': null});
        expect(LiveInputAudioUnmuteParam.fromJson(nulled.toJson()), nulled);
        final valued = nulled.copyWith(eventId: _private);
        expect(valued.eventId, _private);
        expect(valued.hasEventId, isTrue);
        expect(valued.copyWith(eventId: null).toJson(), nulled.toJson());
        expect(valued.copyWith(clearEventId: true), absent);
        expect(valued.copyWith(clearEventId: true, eventId: 'ignored'), absent);
        expect(absent, isNot(nulled));
        expect(valued, isNot(nulled));
      },
    );
    test(
      'correlation uses exact 512 Unicode codepoint bound with no minimum',
      () {
        final model = LiveInputAudioUnmuteParam.fromJson(minimal);
        final bound = List.filled(512, '😀').join();
        expect(model.copyWith(eventId: bound).eventId, bound);
        expect(model.copyWith(eventId: '').eventId, '');
        expect(
          () => model.copyWith(eventId: '$bound😀'),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveInputAudioUnmuteParam.fromJson({
            ...minimal,
            'event_id': '$bound😀',
          }),
          throwsA(_safe('event_id')),
        );
      },
    );
    test('known event_id and discriminator malformed values are safe', () {
      for (final value in <Object?>[5, false, [], {}]) {
        expect(
          () => LiveInputAudioUnmuteParam.fromJson({
            ...minimal,
            'event_id': value,
          }),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveInputAudioUnmuteParam.fromJson(
            minimal,
          ).copyWith(eventId: value),
          throwsA(_safe('event_id')),
        );
      }
      for (final value in <Object?>[null, 5, false, _private]) {
        expect(
          () => LiveInputAudioUnmuteParam.fromJson({...minimal, 'type': value}),
          throwsA(_safe('type')),
        );
      }
      expect(
        () => LiveInputAudioUnmuteParam.fromJson({...minimal}..remove('type')),
        throwsA(_safe('type')),
      );
    });
    test(
      'finite future metadata stays private, owned and typed authoritative',
      () {
        final metadata = <String, dynamic>{
          'nested': <Object?>[_private],
        };
        final source = <String, dynamic>{...full, 'future': metadata};
        final model = LiveInputAudioUnmuteParam.fromJson(source);
        metadata['nested'] = <Object?>[];
        expect((model.rawJson['future'] as Map)['nested'], [_private]);
        expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
        expect(
          () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
          throwsUnsupportedError,
        );
        expect(model.copyWith().toJson(), model.toJson());
        expect(
          model
              .copyWith(
                rawJson: {
                  'type': _private,
                  'event_id': 5,
                  'future': {
                    'nested': [_private],
                  },
                },
              )
              .toJson(),
          model.toJson(),
        );
        expect(model.toString(), isNot(contains(_private)));
      },
    );
    test('runtime Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveInputAudioUnmuteParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveInputAudioUnmuteParam')),
      );
      expect(
        () => LiveInputAudioUnmuteParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveInputAudioUnmuteParam')),
      );
    });
    test('runtime -Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveInputAudioUnmuteParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveInputAudioUnmuteParam')),
      );
      expect(
        () => LiveInputAudioUnmuteParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveInputAudioUnmuteParam')),
      );
    });
    test('runtime NaN overflow stays finite-only', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveInputAudioUnmuteParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveInputAudioUnmuteParam')),
      );
      expect(
        () => LiveInputAudioUnmuteParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveInputAudioUnmuteParam')),
      );
    });
  });
  group('LiveInstructionsAppendParam', () {
    final minimal = <String, dynamic>{
      'type': 'session.instructions.append',
      'content': '',
      'delegation_id': null,
    };
    final full = <String, dynamic>{
      'type': 'session.instructions.append',
      'event_id': 'PRIVATE_CLIENT_COMMAND',
      'content': 'PRIVATE_CLIENT_COMMAND',
      'delegation_id': 'client-delegation',
    };
    test(
      'all declared fields, fixed type, roundtrip/copy/value/hash/private contracts',
      () {
        for (final wire in [minimal, full]) {
          final model = LiveInstructionsAppendParam.fromJson(wire);
          final peer = LiveInstructionsAppendParam.fromJson({...wire});
          expect(model.type, 'session.instructions.append');
          expect(model.toJson(), wire);
          expect(model, peer);
          expect(model.hashCode, peer.hashCode);
          expect(model.copyWith(), model);
          expect(model.toString(), isNot(contains(_private)));
        }
        final model = LiveInstructionsAppendParam.fromJson(full);
        expect(model.eventId, _private);
        expect(model.hasEventId, isTrue);
        expect(model.content, full['content']);
        expect(model.copyWith(content: model.content), model);
        expect(model.delegationId, full['delegation_id']);
        expect(model.copyWith(delegationId: model.delegationId), model);
      },
    );
    test('public primary/sideband/fork role roots preserve exact wire', () {
      final model = LiveInstructionsAppendParam.fromJson(full);
      expect(LiveClientEvent.fromJson(full), model);
      expect(LiveClientEvent.fromForkJson(full), model);
      expect(model, isA<LiveSidebandClientEvent>());
      expect(LiveSidebandClientEvent.fromJson(full), model);
    });
    test(
      'correlation absence/null/value and explicit clear survive copies',
      () {
        final absent = LiveInstructionsAppendParam.fromJson(minimal);
        expect(absent.eventId, isNull);
        expect(absent.hasEventId, isFalse);
        expect(absent.copyWith().toJson().containsKey('event_id'), isFalse);
        final nulled = absent.copyWith(eventId: null);
        expect(nulled.hasEventId, isTrue);
        expect(nulled.toJson(), {...minimal, 'event_id': null});
        expect(LiveInstructionsAppendParam.fromJson(nulled.toJson()), nulled);
        final valued = nulled.copyWith(eventId: _private);
        expect(valued.eventId, _private);
        expect(valued.hasEventId, isTrue);
        expect(valued.copyWith(eventId: null).toJson(), nulled.toJson());
        expect(valued.copyWith(clearEventId: true), absent);
        expect(valued.copyWith(clearEventId: true, eventId: 'ignored'), absent);
        expect(absent, isNot(nulled));
        expect(valued, isNot(nulled));
      },
    );
    test(
      'correlation uses exact 512 Unicode codepoint bound with no minimum',
      () {
        final model = LiveInstructionsAppendParam.fromJson(minimal);
        final bound = List.filled(512, '😀').join();
        expect(model.copyWith(eventId: bound).eventId, bound);
        expect(model.copyWith(eventId: '').eventId, '');
        expect(
          () => model.copyWith(eventId: '$bound😀'),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveInstructionsAppendParam.fromJson({
            ...minimal,
            'event_id': '$bound😀',
          }),
          throwsA(_safe('event_id')),
        );
      },
    );
    test('known event_id and discriminator malformed values are safe', () {
      for (final value in <Object?>[5, false, [], {}]) {
        expect(
          () => LiveInstructionsAppendParam.fromJson({
            ...minimal,
            'event_id': value,
          }),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveInstructionsAppendParam.fromJson(
            minimal,
          ).copyWith(eventId: value),
          throwsA(_safe('event_id')),
        );
      }
      for (final value in <Object?>[null, 5, false, _private]) {
        expect(
          () =>
              LiveInstructionsAppendParam.fromJson({...minimal, 'type': value}),
          throwsA(_safe('type')),
        );
      }
      expect(
        () =>
            LiveInstructionsAppendParam.fromJson({...minimal}..remove('type')),
        throwsA(_safe('type')),
      );
    });
    test(
      'finite future metadata stays private, owned and typed authoritative',
      () {
        final metadata = <String, dynamic>{
          'nested': <Object?>[_private],
        };
        final source = <String, dynamic>{...full, 'future': metadata};
        final model = LiveInstructionsAppendParam.fromJson(source);
        metadata['nested'] = <Object?>[];
        expect((model.rawJson['future'] as Map)['nested'], [_private]);
        expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
        expect(
          () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
          throwsUnsupportedError,
        );
        expect(model.copyWith().toJson(), model.toJson());
        expect(
          model
              .copyWith(
                rawJson: {
                  'type': _private,
                  'event_id': 5,
                  'future': {
                    'nested': [_private],
                  },
                },
              )
              .toJson(),
          model.toJson(),
        );
        expect(model.toString(), isNot(contains(_private)));
      },
    );
    test('required content presence and wrong known shape', () {
      expect(
        () => LiveInstructionsAppendParam.fromJson(
          {...minimal}..remove('content'),
        ),
        throwsA(_safe('content')),
      );
      expect(
        () => LiveInstructionsAppendParam.fromJson({...minimal, 'content': 5}),
        throwsA(_safe('content')),
      );
      expect(
        () =>
            LiveInstructionsAppendParam.fromJson({...minimal, 'content': null}),
        throwsA(_safe('content')),
      );
    });
    test('required delegation_id presence and wrong known shape', () {
      expect(
        () => LiveInstructionsAppendParam.fromJson(
          {...minimal}..remove('delegation_id'),
        ),
        throwsA(_safe('delegation_id')),
      );
      expect(
        () => LiveInstructionsAppendParam.fromJson({
          ...minimal,
          'delegation_id': 5,
        }),
        throwsA(_safe('delegation_id')),
      );
    });
    test('runtime Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () =>
            LiveInstructionsAppendParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveInstructionsAppendParam')),
      );
      expect(
        () => LiveInstructionsAppendParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveInstructionsAppendParam')),
      );
    });
    test('runtime -Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () =>
            LiveInstructionsAppendParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveInstructionsAppendParam')),
      );
      expect(
        () => LiveInstructionsAppendParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveInstructionsAppendParam')),
      );
    });
    test('runtime NaN overflow stays finite-only', () {
      final dynamic value = num.parse('NaN');
      expect(
        () =>
            LiveInstructionsAppendParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveInstructionsAppendParam')),
      );
      expect(
        () => LiveInstructionsAppendParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveInstructionsAppendParam')),
      );
    });
  });
  group('LiveThinkingAppendParam', () {
    final minimal = <String, dynamic>{
      'type': 'session.thinking.append',
      'content': '',
      'delegation_id': null,
    };
    final full = <String, dynamic>{
      'type': 'session.thinking.append',
      'event_id': 'PRIVATE_CLIENT_COMMAND',
      'content': 'PRIVATE_CLIENT_COMMAND',
      'delegation_id': 'client-delegation',
    };
    test(
      'all declared fields, fixed type, roundtrip/copy/value/hash/private contracts',
      () {
        for (final wire in [minimal, full]) {
          final model = LiveThinkingAppendParam.fromJson(wire);
          final peer = LiveThinkingAppendParam.fromJson({...wire});
          expect(model.type, 'session.thinking.append');
          expect(model.toJson(), wire);
          expect(model, peer);
          expect(model.hashCode, peer.hashCode);
          expect(model.copyWith(), model);
          expect(model.toString(), isNot(contains(_private)));
        }
        final model = LiveThinkingAppendParam.fromJson(full);
        expect(model.eventId, _private);
        expect(model.hasEventId, isTrue);
        expect(model.content, full['content']);
        expect(model.copyWith(content: model.content), model);
        expect(model.delegationId, full['delegation_id']);
        expect(model.copyWith(delegationId: model.delegationId), model);
      },
    );
    test('public primary/sideband/fork role roots preserve exact wire', () {
      final model = LiveThinkingAppendParam.fromJson(full);
      expect(LiveClientEvent.fromJson(full), model);
      expect(LiveClientEvent.fromForkJson(full), model);
      expect(model, isA<LiveSidebandClientEvent>());
      expect(LiveSidebandClientEvent.fromJson(full), model);
    });
    test(
      'correlation absence/null/value and explicit clear survive copies',
      () {
        final absent = LiveThinkingAppendParam.fromJson(minimal);
        expect(absent.eventId, isNull);
        expect(absent.hasEventId, isFalse);
        expect(absent.copyWith().toJson().containsKey('event_id'), isFalse);
        final nulled = absent.copyWith(eventId: null);
        expect(nulled.hasEventId, isTrue);
        expect(nulled.toJson(), {...minimal, 'event_id': null});
        expect(LiveThinkingAppendParam.fromJson(nulled.toJson()), nulled);
        final valued = nulled.copyWith(eventId: _private);
        expect(valued.eventId, _private);
        expect(valued.hasEventId, isTrue);
        expect(valued.copyWith(eventId: null).toJson(), nulled.toJson());
        expect(valued.copyWith(clearEventId: true), absent);
        expect(valued.copyWith(clearEventId: true, eventId: 'ignored'), absent);
        expect(absent, isNot(nulled));
        expect(valued, isNot(nulled));
      },
    );
    test(
      'correlation uses exact 512 Unicode codepoint bound with no minimum',
      () {
        final model = LiveThinkingAppendParam.fromJson(minimal);
        final bound = List.filled(512, '😀').join();
        expect(model.copyWith(eventId: bound).eventId, bound);
        expect(model.copyWith(eventId: '').eventId, '');
        expect(
          () => model.copyWith(eventId: '$bound😀'),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveThinkingAppendParam.fromJson({
            ...minimal,
            'event_id': '$bound😀',
          }),
          throwsA(_safe('event_id')),
        );
      },
    );
    test('known event_id and discriminator malformed values are safe', () {
      for (final value in <Object?>[5, false, [], {}]) {
        expect(
          () =>
              LiveThinkingAppendParam.fromJson({...minimal, 'event_id': value}),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveThinkingAppendParam.fromJson(
            minimal,
          ).copyWith(eventId: value),
          throwsA(_safe('event_id')),
        );
      }
      for (final value in <Object?>[null, 5, false, _private]) {
        expect(
          () => LiveThinkingAppendParam.fromJson({...minimal, 'type': value}),
          throwsA(_safe('type')),
        );
      }
      expect(
        () => LiveThinkingAppendParam.fromJson({...minimal}..remove('type')),
        throwsA(_safe('type')),
      );
    });
    test(
      'finite future metadata stays private, owned and typed authoritative',
      () {
        final metadata = <String, dynamic>{
          'nested': <Object?>[_private],
        };
        final source = <String, dynamic>{...full, 'future': metadata};
        final model = LiveThinkingAppendParam.fromJson(source);
        metadata['nested'] = <Object?>[];
        expect((model.rawJson['future'] as Map)['nested'], [_private]);
        expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
        expect(
          () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
          throwsUnsupportedError,
        );
        expect(model.copyWith().toJson(), model.toJson());
        expect(
          model
              .copyWith(
                rawJson: {
                  'type': _private,
                  'event_id': 5,
                  'future': {
                    'nested': [_private],
                  },
                },
              )
              .toJson(),
          model.toJson(),
        );
        expect(model.toString(), isNot(contains(_private)));
      },
    );
    test('required content presence and wrong known shape', () {
      expect(
        () => LiveThinkingAppendParam.fromJson({...minimal}..remove('content')),
        throwsA(_safe('content')),
      );
      expect(
        () => LiveThinkingAppendParam.fromJson({...minimal, 'content': 5}),
        throwsA(_safe('content')),
      );
      expect(
        () => LiveThinkingAppendParam.fromJson({...minimal, 'content': null}),
        throwsA(_safe('content')),
      );
    });
    test('required delegation_id presence and wrong known shape', () {
      expect(
        () => LiveThinkingAppendParam.fromJson(
          {...minimal}..remove('delegation_id'),
        ),
        throwsA(_safe('delegation_id')),
      );
      expect(
        () =>
            LiveThinkingAppendParam.fromJson({...minimal, 'delegation_id': 5}),
        throwsA(_safe('delegation_id')),
      );
    });
    test('runtime Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveThinkingAppendParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveThinkingAppendParam')),
      );
      expect(
        () => LiveThinkingAppendParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveThinkingAppendParam')),
      );
    });
    test('runtime -Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveThinkingAppendParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveThinkingAppendParam')),
      );
      expect(
        () => LiveThinkingAppendParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveThinkingAppendParam')),
      );
    });
    test('runtime NaN overflow stays finite-only', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveThinkingAppendParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveThinkingAppendParam')),
      );
      expect(
        () => LiveThinkingAppendParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveThinkingAppendParam')),
      );
    });
  });
  group('LiveCommentaryAppendParam', () {
    final minimal = <String, dynamic>{
      'type': 'session.commentary.append',
      'content': '',
      'delegation_id': null,
    };
    final full = <String, dynamic>{
      'type': 'session.commentary.append',
      'event_id': 'PRIVATE_CLIENT_COMMAND',
      'content': 'PRIVATE_CLIENT_COMMAND',
      'delegation_id': 'client-delegation',
    };
    test(
      'all declared fields, fixed type, roundtrip/copy/value/hash/private contracts',
      () {
        for (final wire in [minimal, full]) {
          final model = LiveCommentaryAppendParam.fromJson(wire);
          final peer = LiveCommentaryAppendParam.fromJson({...wire});
          expect(model.type, 'session.commentary.append');
          expect(model.toJson(), wire);
          expect(model, peer);
          expect(model.hashCode, peer.hashCode);
          expect(model.copyWith(), model);
          expect(model.toString(), isNot(contains(_private)));
        }
        final model = LiveCommentaryAppendParam.fromJson(full);
        expect(model.eventId, _private);
        expect(model.hasEventId, isTrue);
        expect(model.content, full['content']);
        expect(model.copyWith(content: model.content), model);
        expect(model.delegationId, full['delegation_id']);
        expect(model.copyWith(delegationId: model.delegationId), model);
      },
    );
    test('public primary/sideband/fork role roots preserve exact wire', () {
      final model = LiveCommentaryAppendParam.fromJson(full);
      expect(LiveClientEvent.fromJson(full), model);
      expect(LiveClientEvent.fromForkJson(full), model);
      expect(model, isA<LiveSidebandClientEvent>());
      expect(LiveSidebandClientEvent.fromJson(full), model);
    });
    test(
      'correlation absence/null/value and explicit clear survive copies',
      () {
        final absent = LiveCommentaryAppendParam.fromJson(minimal);
        expect(absent.eventId, isNull);
        expect(absent.hasEventId, isFalse);
        expect(absent.copyWith().toJson().containsKey('event_id'), isFalse);
        final nulled = absent.copyWith(eventId: null);
        expect(nulled.hasEventId, isTrue);
        expect(nulled.toJson(), {...minimal, 'event_id': null});
        expect(LiveCommentaryAppendParam.fromJson(nulled.toJson()), nulled);
        final valued = nulled.copyWith(eventId: _private);
        expect(valued.eventId, _private);
        expect(valued.hasEventId, isTrue);
        expect(valued.copyWith(eventId: null).toJson(), nulled.toJson());
        expect(valued.copyWith(clearEventId: true), absent);
        expect(valued.copyWith(clearEventId: true, eventId: 'ignored'), absent);
        expect(absent, isNot(nulled));
        expect(valued, isNot(nulled));
      },
    );
    test(
      'correlation uses exact 512 Unicode codepoint bound with no minimum',
      () {
        final model = LiveCommentaryAppendParam.fromJson(minimal);
        final bound = List.filled(512, '😀').join();
        expect(model.copyWith(eventId: bound).eventId, bound);
        expect(model.copyWith(eventId: '').eventId, '');
        expect(
          () => model.copyWith(eventId: '$bound😀'),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveCommentaryAppendParam.fromJson({
            ...minimal,
            'event_id': '$bound😀',
          }),
          throwsA(_safe('event_id')),
        );
      },
    );
    test('known event_id and discriminator malformed values are safe', () {
      for (final value in <Object?>[5, false, [], {}]) {
        expect(
          () => LiveCommentaryAppendParam.fromJson({
            ...minimal,
            'event_id': value,
          }),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveCommentaryAppendParam.fromJson(
            minimal,
          ).copyWith(eventId: value),
          throwsA(_safe('event_id')),
        );
      }
      for (final value in <Object?>[null, 5, false, _private]) {
        expect(
          () => LiveCommentaryAppendParam.fromJson({...minimal, 'type': value}),
          throwsA(_safe('type')),
        );
      }
      expect(
        () => LiveCommentaryAppendParam.fromJson({...minimal}..remove('type')),
        throwsA(_safe('type')),
      );
    });
    test(
      'finite future metadata stays private, owned and typed authoritative',
      () {
        final metadata = <String, dynamic>{
          'nested': <Object?>[_private],
        };
        final source = <String, dynamic>{...full, 'future': metadata};
        final model = LiveCommentaryAppendParam.fromJson(source);
        metadata['nested'] = <Object?>[];
        expect((model.rawJson['future'] as Map)['nested'], [_private]);
        expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
        expect(
          () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
          throwsUnsupportedError,
        );
        expect(model.copyWith().toJson(), model.toJson());
        expect(
          model
              .copyWith(
                rawJson: {
                  'type': _private,
                  'event_id': 5,
                  'future': {
                    'nested': [_private],
                  },
                },
              )
              .toJson(),
          model.toJson(),
        );
        expect(model.toString(), isNot(contains(_private)));
      },
    );
    test('required content presence and wrong known shape', () {
      expect(
        () =>
            LiveCommentaryAppendParam.fromJson({...minimal}..remove('content')),
        throwsA(_safe('content')),
      );
      expect(
        () => LiveCommentaryAppendParam.fromJson({...minimal, 'content': 5}),
        throwsA(_safe('content')),
      );
      expect(
        () => LiveCommentaryAppendParam.fromJson({...minimal, 'content': null}),
        throwsA(_safe('content')),
      );
    });
    test('required delegation_id presence and wrong known shape', () {
      expect(
        () => LiveCommentaryAppendParam.fromJson(
          {...minimal}..remove('delegation_id'),
        ),
        throwsA(_safe('delegation_id')),
      );
      expect(
        () => LiveCommentaryAppendParam.fromJson({
          ...minimal,
          'delegation_id': 5,
        }),
        throwsA(_safe('delegation_id')),
      );
    });
    test('runtime Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveCommentaryAppendParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveCommentaryAppendParam')),
      );
      expect(
        () => LiveCommentaryAppendParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveCommentaryAppendParam')),
      );
    });
    test('runtime -Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveCommentaryAppendParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveCommentaryAppendParam')),
      );
      expect(
        () => LiveCommentaryAppendParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveCommentaryAppendParam')),
      );
    });
    test('runtime NaN overflow stays finite-only', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveCommentaryAppendParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveCommentaryAppendParam')),
      );
      expect(
        () => LiveCommentaryAppendParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveCommentaryAppendParam')),
      );
    });
  });
  group('LiveResponseItemCreateParam', () {
    final minimal = <String, dynamic>{
      'type': 'response.item.create',
      'item': {'type': 'function_call_output', 'output': 'result'},
    };
    final full = <String, dynamic>{
      'type': 'response.item.create',
      'event_id': 'PRIVATE_CLIENT_COMMAND',
      'item': {
        'type': 'function_call_output',
        'call_id': 'call',
        'output': 'PRIVATE_CLIENT_COMMAND',
        'name': null,
        'namespace': null,
      },
    };
    test(
      'all declared fields, fixed type, roundtrip/copy/value/hash/private contracts',
      () {
        for (final wire in [minimal, full]) {
          final model = LiveResponseItemCreateParam.fromJson(wire);
          final peer = LiveResponseItemCreateParam.fromJson({...wire});
          expect(model.type, 'response.item.create');
          expect(model.toJson(), wire);
          expect(model, peer);
          expect(model.hashCode, peer.hashCode);
          expect(model.copyWith(), model);
          expect(model.toString(), isNot(contains(_private)));
        }
        final model = LiveResponseItemCreateParam.fromJson(full);
        expect(model.eventId, _private);
        expect(model.hasEventId, isTrue);
        expect(model.item.toJson(), full['item']);
        expect(model.copyWith(item: model.item), model);
      },
    );
    test('public primary/sideband/fork role roots preserve exact wire', () {
      final model = LiveResponseItemCreateParam.fromJson(full);
      expect(LiveClientEvent.fromJson(full), model);
      expect(LiveClientEvent.fromForkJson(full), model);
      expect(model, isA<LiveSidebandClientEvent>());
      expect(LiveSidebandClientEvent.fromJson(full), model);
    });
    test(
      'correlation absence/null/value and explicit clear survive copies',
      () {
        final absent = LiveResponseItemCreateParam.fromJson(minimal);
        expect(absent.eventId, isNull);
        expect(absent.hasEventId, isFalse);
        expect(absent.copyWith().toJson().containsKey('event_id'), isFalse);
        final nulled = absent.copyWith(eventId: null);
        expect(nulled.hasEventId, isTrue);
        expect(nulled.toJson(), {...minimal, 'event_id': null});
        expect(LiveResponseItemCreateParam.fromJson(nulled.toJson()), nulled);
        final valued = nulled.copyWith(eventId: _private);
        expect(valued.eventId, _private);
        expect(valued.hasEventId, isTrue);
        expect(valued.copyWith(eventId: null).toJson(), nulled.toJson());
        expect(valued.copyWith(clearEventId: true), absent);
        expect(valued.copyWith(clearEventId: true, eventId: 'ignored'), absent);
        expect(absent, isNot(nulled));
        expect(valued, isNot(nulled));
      },
    );
    test(
      'correlation uses exact 512 Unicode codepoint bound with no minimum',
      () {
        final model = LiveResponseItemCreateParam.fromJson(minimal);
        final bound = List.filled(512, '😀').join();
        expect(model.copyWith(eventId: bound).eventId, bound);
        expect(model.copyWith(eventId: '').eventId, '');
        expect(
          () => model.copyWith(eventId: '$bound😀'),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveResponseItemCreateParam.fromJson({
            ...minimal,
            'event_id': '$bound😀',
          }),
          throwsA(_safe('event_id')),
        );
      },
    );
    test('known event_id and discriminator malformed values are safe', () {
      for (final value in <Object?>[5, false, [], {}]) {
        expect(
          () => LiveResponseItemCreateParam.fromJson({
            ...minimal,
            'event_id': value,
          }),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveResponseItemCreateParam.fromJson(
            minimal,
          ).copyWith(eventId: value),
          throwsA(_safe('event_id')),
        );
      }
      for (final value in <Object?>[null, 5, false, _private]) {
        expect(
          () =>
              LiveResponseItemCreateParam.fromJson({...minimal, 'type': value}),
          throwsA(_safe('type')),
        );
      }
      expect(
        () =>
            LiveResponseItemCreateParam.fromJson({...minimal}..remove('type')),
        throwsA(_safe('type')),
      );
    });
    test(
      'finite future metadata stays private, owned and typed authoritative',
      () {
        final metadata = <String, dynamic>{
          'nested': <Object?>[_private],
        };
        final source = <String, dynamic>{...full, 'future': metadata};
        final model = LiveResponseItemCreateParam.fromJson(source);
        metadata['nested'] = <Object?>[];
        expect((model.rawJson['future'] as Map)['nested'], [_private]);
        expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
        expect(
          () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
          throwsUnsupportedError,
        );
        expect(model.copyWith().toJson(), model.toJson());
        expect(
          model
              .copyWith(
                rawJson: {
                  'type': _private,
                  'event_id': 5,
                  'future': {
                    'nested': [_private],
                  },
                },
              )
              .toJson(),
          model.toJson(),
        );
        expect(model.toString(), isNot(contains(_private)));
      },
    );
    test('required item presence and wrong known shape', () {
      expect(
        () =>
            LiveResponseItemCreateParam.fromJson({...minimal}..remove('item')),
        throwsA(_safe('item')),
      );
      expect(
        () => LiveResponseItemCreateParam.fromJson({
          ...minimal,
          'item': 'PRIVATE_CLIENT_COMMAND',
        }),
        throwsA(_safe('item')),
      );
      expect(
        () => LiveResponseItemCreateParam.fromJson({...minimal, 'item': null}),
        throwsA(_safe('item')),
      );
    });
    test('runtime Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () =>
            LiveResponseItemCreateParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveResponseItemCreateParam')),
      );
      expect(
        () => LiveResponseItemCreateParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveResponseItemCreateParam')),
      );
    });
    test('runtime -Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () =>
            LiveResponseItemCreateParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveResponseItemCreateParam')),
      );
      expect(
        () => LiveResponseItemCreateParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveResponseItemCreateParam')),
      );
    });
    test('runtime NaN overflow stays finite-only', () {
      final dynamic value = num.parse('NaN');
      expect(
        () =>
            LiveResponseItemCreateParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveResponseItemCreateParam')),
      );
      expect(
        () => LiveResponseItemCreateParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveResponseItemCreateParam')),
      );
    });
  });
  group('LiveResponseCreateParam', () {
    final minimal = <String, dynamic>{'type': 'response.create'};
    final full = <String, dynamic>{
      'type': 'response.create',
      'event_id': 'PRIVATE_CLIENT_COMMAND',
    };
    test(
      'all declared fields, fixed type, roundtrip/copy/value/hash/private contracts',
      () {
        for (final wire in [minimal, full]) {
          final model = LiveResponseCreateParam.fromJson(wire);
          final peer = LiveResponseCreateParam.fromJson({...wire});
          expect(model.type, 'response.create');
          expect(model.toJson(), wire);
          expect(model, peer);
          expect(model.hashCode, peer.hashCode);
          expect(model.copyWith(), model);
          expect(model.toString(), isNot(contains(_private)));
        }
        final model = LiveResponseCreateParam.fromJson(full);
        expect(model.eventId, _private);
        expect(model.hasEventId, isTrue);
      },
    );
    test('public primary/sideband/fork role roots preserve exact wire', () {
      final model = LiveResponseCreateParam.fromJson(full);
      expect(LiveClientEvent.fromJson(full), model);
      expect(LiveClientEvent.fromForkJson(full), model);
      expect(model, isA<LiveSidebandClientEvent>());
      expect(LiveSidebandClientEvent.fromJson(full), model);
    });
    test(
      'correlation absence/null/value and explicit clear survive copies',
      () {
        final absent = LiveResponseCreateParam.fromJson(minimal);
        expect(absent.eventId, isNull);
        expect(absent.hasEventId, isFalse);
        expect(absent.copyWith().toJson().containsKey('event_id'), isFalse);
        final nulled = absent.copyWith(eventId: null);
        expect(nulled.hasEventId, isTrue);
        expect(nulled.toJson(), {...minimal, 'event_id': null});
        expect(LiveResponseCreateParam.fromJson(nulled.toJson()), nulled);
        final valued = nulled.copyWith(eventId: _private);
        expect(valued.eventId, _private);
        expect(valued.hasEventId, isTrue);
        expect(valued.copyWith(eventId: null).toJson(), nulled.toJson());
        expect(valued.copyWith(clearEventId: true), absent);
        expect(valued.copyWith(clearEventId: true, eventId: 'ignored'), absent);
        expect(absent, isNot(nulled));
        expect(valued, isNot(nulled));
      },
    );
    test(
      'correlation uses exact 512 Unicode codepoint bound with no minimum',
      () {
        final model = LiveResponseCreateParam.fromJson(minimal);
        final bound = List.filled(512, '😀').join();
        expect(model.copyWith(eventId: bound).eventId, bound);
        expect(model.copyWith(eventId: '').eventId, '');
        expect(
          () => model.copyWith(eventId: '$bound😀'),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveResponseCreateParam.fromJson({
            ...minimal,
            'event_id': '$bound😀',
          }),
          throwsA(_safe('event_id')),
        );
      },
    );
    test('known event_id and discriminator malformed values are safe', () {
      for (final value in <Object?>[5, false, [], {}]) {
        expect(
          () =>
              LiveResponseCreateParam.fromJson({...minimal, 'event_id': value}),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveResponseCreateParam.fromJson(
            minimal,
          ).copyWith(eventId: value),
          throwsA(_safe('event_id')),
        );
      }
      for (final value in <Object?>[null, 5, false, _private]) {
        expect(
          () => LiveResponseCreateParam.fromJson({...minimal, 'type': value}),
          throwsA(_safe('type')),
        );
      }
      expect(
        () => LiveResponseCreateParam.fromJson({...minimal}..remove('type')),
        throwsA(_safe('type')),
      );
    });
    test(
      'finite future metadata stays private, owned and typed authoritative',
      () {
        final metadata = <String, dynamic>{
          'nested': <Object?>[_private],
        };
        final source = <String, dynamic>{...full, 'future': metadata};
        final model = LiveResponseCreateParam.fromJson(source);
        metadata['nested'] = <Object?>[];
        expect((model.rawJson['future'] as Map)['nested'], [_private]);
        expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
        expect(
          () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
          throwsUnsupportedError,
        );
        expect(model.copyWith().toJson(), model.toJson());
        expect(
          model
              .copyWith(
                rawJson: {
                  'type': _private,
                  'event_id': 5,
                  'future': {
                    'nested': [_private],
                  },
                },
              )
              .toJson(),
          model.toJson(),
        );
        expect(model.toString(), isNot(contains(_private)));
      },
    );
    test('runtime Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveResponseCreateParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveResponseCreateParam')),
      );
      expect(
        () => LiveResponseCreateParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveResponseCreateParam')),
      );
    });
    test('runtime -Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveResponseCreateParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveResponseCreateParam')),
      );
      expect(
        () => LiveResponseCreateParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveResponseCreateParam')),
      );
    });
    test('runtime NaN overflow stays finite-only', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveResponseCreateParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveResponseCreateParam')),
      );
      expect(
        () => LiveResponseCreateParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveResponseCreateParam')),
      );
    });
  });
  group('LiveSessionCloseParam', () {
    final minimal = <String, dynamic>{'type': 'session.close'};
    final full = <String, dynamic>{
      'type': 'session.close',
      'event_id': 'PRIVATE_CLIENT_COMMAND',
    };
    test(
      'all declared fields, fixed type, roundtrip/copy/value/hash/private contracts',
      () {
        for (final wire in [minimal, full]) {
          final model = LiveSessionCloseParam.fromJson(wire);
          final peer = LiveSessionCloseParam.fromJson({...wire});
          expect(model.type, 'session.close');
          expect(model.toJson(), wire);
          expect(model, peer);
          expect(model.hashCode, peer.hashCode);
          expect(model.copyWith(), model);
          expect(model.toString(), isNot(contains(_private)));
        }
        final model = LiveSessionCloseParam.fromJson(full);
        expect(model.eventId, _private);
        expect(model.hasEventId, isTrue);
      },
    );
    test('public primary/sideband/fork role roots preserve exact wire', () {
      final model = LiveSessionCloseParam.fromJson(full);
      expect(LiveClientEvent.fromJson(full), model);
      expect(LiveClientEvent.fromForkJson(full), model);
      expect(model, isA<LiveSidebandClientEvent>());
      expect(LiveSidebandClientEvent.fromJson(full), model);
    });
    test(
      'correlation absence/null/value and explicit clear survive copies',
      () {
        final absent = LiveSessionCloseParam.fromJson(minimal);
        expect(absent.eventId, isNull);
        expect(absent.hasEventId, isFalse);
        expect(absent.copyWith().toJson().containsKey('event_id'), isFalse);
        final nulled = absent.copyWith(eventId: null);
        expect(nulled.hasEventId, isTrue);
        expect(nulled.toJson(), {...minimal, 'event_id': null});
        expect(LiveSessionCloseParam.fromJson(nulled.toJson()), nulled);
        final valued = nulled.copyWith(eventId: _private);
        expect(valued.eventId, _private);
        expect(valued.hasEventId, isTrue);
        expect(valued.copyWith(eventId: null).toJson(), nulled.toJson());
        expect(valued.copyWith(clearEventId: true), absent);
        expect(valued.copyWith(clearEventId: true, eventId: 'ignored'), absent);
        expect(absent, isNot(nulled));
        expect(valued, isNot(nulled));
      },
    );
    test(
      'correlation uses exact 512 Unicode codepoint bound with no minimum',
      () {
        final model = LiveSessionCloseParam.fromJson(minimal);
        final bound = List.filled(512, '😀').join();
        expect(model.copyWith(eventId: bound).eventId, bound);
        expect(model.copyWith(eventId: '').eventId, '');
        expect(
          () => model.copyWith(eventId: '$bound😀'),
          throwsA(_safe('event_id')),
        );
        expect(
          () => LiveSessionCloseParam.fromJson({
            ...minimal,
            'event_id': '$bound😀',
          }),
          throwsA(_safe('event_id')),
        );
      },
    );
    test('known event_id and discriminator malformed values are safe', () {
      for (final value in <Object?>[5, false, [], {}]) {
        expect(
          () => LiveSessionCloseParam.fromJson({...minimal, 'event_id': value}),
          throwsA(_safe('event_id')),
        );
        expect(
          () =>
              LiveSessionCloseParam.fromJson(minimal).copyWith(eventId: value),
          throwsA(_safe('event_id')),
        );
      }
      for (final value in <Object?>[null, 5, false, _private]) {
        expect(
          () => LiveSessionCloseParam.fromJson({...minimal, 'type': value}),
          throwsA(_safe('type')),
        );
      }
      expect(
        () => LiveSessionCloseParam.fromJson({...minimal}..remove('type')),
        throwsA(_safe('type')),
      );
    });
    test(
      'finite future metadata stays private, owned and typed authoritative',
      () {
        final metadata = <String, dynamic>{
          'nested': <Object?>[_private],
        };
        final source = <String, dynamic>{...full, 'future': metadata};
        final model = LiveSessionCloseParam.fromJson(source);
        metadata['nested'] = <Object?>[];
        expect((model.rawJson['future'] as Map)['nested'], [_private]);
        expect(() => model.rawJson['new'] = true, throwsUnsupportedError);
        expect(
          () => ((model.rawJson['future'] as Map)['nested'] as List).add(true),
          throwsUnsupportedError,
        );
        expect(model.copyWith().toJson(), model.toJson());
        expect(
          model
              .copyWith(
                rawJson: {
                  'type': _private,
                  'event_id': 5,
                  'future': {
                    'nested': [_private],
                  },
                },
              )
              .toJson(),
          model.toJson(),
        );
        expect(model.toString(), isNot(contains(_private)));
      },
    );
    test('runtime Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('Infinity');
      expect(
        () => LiveSessionCloseParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveSessionCloseParam')),
      );
      expect(
        () => LiveSessionCloseParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveSessionCloseParam')),
      );
    });
    test('runtime -Infinity overflow stays finite-only', () {
      final dynamic value = num.parse('-Infinity');
      expect(
        () => LiveSessionCloseParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveSessionCloseParam')),
      );
      expect(
        () => LiveSessionCloseParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveSessionCloseParam')),
      );
    });
    test('runtime NaN overflow stays finite-only', () {
      final dynamic value = num.parse('NaN');
      expect(
        () => LiveSessionCloseParam.fromJson({...minimal, _private: value}),
        throwsA(_safe('LiveSessionCloseParam')),
      );
      expect(
        () => LiveSessionCloseParam.fromJson(
          minimal,
        ).copyWith(rawJson: {_private: value}),
        throwsA(_safe('LiveSessionCloseParam')),
      );
    });
  });
  group('Command-specific content, session and input constraints', () {
    test('primary startup copy replaces session with changed exact wire', () {
      final model = LiveSessionStartEvent(
        session: LiveSessionCreateParams(model: 'original'),
      );
      final session = LiveSessionCreateParams(
        model: 'replacement',
        store: false,
      );
      final copy = model.copyWith(session: session);
      expect(copy.session, session);
      expect(copy.toJson()['session'], session.toJson());
      expect(copy, isNot(model));
      expect(copy.hashCode, isNot(model.hashCode));
      expect(model.session.model, 'original');
    });
    test('fork startup copy replaces session with changed exact wire', () {
      final model = LiveForkSessionStartEvent(
        session: LiveForkSessionConfigParam(),
      );
      final session = LiveForkSessionConfigParam(store: false);
      final copy = model.copyWith(session: session);
      expect(copy.session, session);
      expect(copy.toJson()['session'], {'store': false});
      expect(copy, isNot(model));
      expect(copy.hashCode, isNot(model.hashCode));
      expect(model.session.toJson(), isEmpty);
    });
    test(
      'session update copy replaces backend settings with changed exact wire',
      () {
        final model = LiveSessionUpdateParam(
          session: LiveSessionUpdateParams(),
        );
        final session = LiveSessionUpdateParams.fromJson(const {
          'delegation': {
            'type': 'responses',
            'responses': {'max_output_tokens': 16},
          },
        });
        final copy = model.copyWith(session: session);
        expect(copy.session, session);
        expect(copy.toJson()['session'], session.toJson());
        expect(copy, isNot(model));
        expect(copy.hashCode, isNot(model.hashCode));
        expect(model.session.toJson(), isEmpty);
      },
    );
    test(
      'audio append copy replaces supplied audio with changed exact wire',
      () {
        final model = LiveInputAudioAppendEvent(audio: 'AA==');
        final copy = model.copyWith(audio: 'AQ==');
        expect(copy.audio, 'AQ==');
        expect(copy.toJson()['audio'], 'AQ==');
        expect(copy, isNot(model));
        expect(copy.hashCode, isNot(model.hashCode));
        expect(model.audio, 'AA==');
      },
    );
    test(
      'instructions copy changes content and required nullable delegation',
      () {
        final model = LiveInstructionsAppendParam(
          content: 'original',
          delegationId: null,
        );
        final copy = model.copyWith(
          content: 'replacement',
          delegationId: 'new-delegation',
        );
        expect(copy.content, 'replacement');
        expect(copy.delegationId, 'new-delegation');
        expect(copy.toJson(), {
          'type': model.type,
          'content': 'replacement',
          'delegation_id': 'new-delegation',
        });
        expect(copy, isNot(model));
        expect(copy.hashCode, isNot(model.hashCode));
        expect(
          copy.copyWith(delegationId: null).toJson()['delegation_id'],
          isNull,
        );
        expect(model.content, 'original');
      },
    );
    test('thinking copy changes content and required nullable delegation', () {
      final model = LiveThinkingAppendParam(
        content: 'original',
        delegationId: null,
      );
      final copy = model.copyWith(
        content: 'replacement',
        delegationId: 'new-delegation',
      );
      expect(copy.content, 'replacement');
      expect(copy.delegationId, 'new-delegation');
      expect(copy.toJson(), {
        'type': model.type,
        'content': 'replacement',
        'delegation_id': 'new-delegation',
      });
      expect(copy, isNot(model));
      expect(copy.hashCode, isNot(model.hashCode));
      expect(
        copy.copyWith(delegationId: null).toJson()['delegation_id'],
        isNull,
      );
      expect(model.content, 'original');
    });
    test(
      'commentary copy changes content and required nullable delegation',
      () {
        final model = LiveCommentaryAppendParam(
          content: 'original',
          delegationId: null,
        );
        final copy = model.copyWith(
          content: 'replacement',
          delegationId: 'new-delegation',
        );
        expect(copy.content, 'replacement');
        expect(copy.delegationId, 'new-delegation');
        expect(copy.toJson(), {
          'type': model.type,
          'content': 'replacement',
          'delegation_id': 'new-delegation',
        });
        expect(copy, isNot(model));
        expect(copy.hashCode, isNot(model.hashCode));
        expect(
          copy.copyWith(delegationId: null).toJson()['delegation_id'],
          isNull,
        );
        expect(model.content, 'original');
      },
    );
    test(
      'item command copy replaces a typed input with changed exact wire',
      () {
        final model = LiveResponseItemCreateParam(
          item: LiveInputItem.fromJson(const {
            'role': 'user',
            'content': 'original',
          }),
        );
        final item = LiveInputItem.fromJson(const {
          'role': 'user',
          'content': 'replacement',
        });
        final copy = model.copyWith(item: item);
        expect(copy.item, item);
        expect(copy.toJson()['item'], item.toJson());
        expect(copy, isNot(model));
        expect(copy.hashCode, isNot(model.hashCode));
        expect(model.item.toJson()['content'], 'original');
      },
    );
    test(
      'unknown/Realtime/DTMF command tags never become writable fallbacks',
      () {
        for (final type in [
          _private,
          'input_audio_buffer.commit',
          'transport.dtmf.send',
        ]) {
          final wire = <String, dynamic>{'type': type};
          expect(() => LiveClientEvent.fromJson(wire), throwsA(_safe('type')));
          expect(
            () => LiveClientEvent.fromForkJson(wire),
            throwsA(_safe('type')),
          );
          expect(
            () => LiveSidebandClientEvent.fromJson(wire),
            throwsA(_safe('type')),
          );
        }
      },
    );
    test(
      'all appends require nullable delegation ID, preserve plain content, do not count tokens',
      () {
        final content = List.filled(6000, 'word').join(' ');
        for (final factory in [
          LiveInstructionsAppendParam.fromJson,
          LiveThinkingAppendParam.fromJson,
          LiveCommentaryAppendParam.fromJson,
        ]) {
          final type = factory == LiveInstructionsAppendParam.fromJson
              ? 'session.instructions.append'
              : factory == LiveThinkingAppendParam.fromJson
              ? 'session.thinking.append'
              : 'session.commentary.append';
          final model = factory({
            'type': type,
            'content': content,
            'delegation_id': null,
          });
          expect(model.toJson()['content'], content);
          expect(model.toJson()['delegation_id'], isNull);
          expect(
            () => factory({'type': type, 'content': '', 'delegation_id': ''}),
            throwsA(_safe('delegation_id')),
          );
          expect(
            factory({
              'type': type,
              'content': '',
              'delegation_id': ' ',
            }).toJson()['delegation_id'],
            ' ',
          );
        }
      },
    );
    test(
      'audio is the exact supplied raw Base64 string and only nonempty is bounded',
      () {
        const audio = 'AACAAIAAAIAAAP9/AIAAgA==';
        final model = LiveInputAudioAppendEvent(audio: audio);
        expect(model.audio, audio);
        expect(model.toJson()['audio'], audio);
        expect(model.copyWith(audio: 'AA==').audio, 'AA==');
        expect(
          () => LiveInputAudioAppendEvent(audio: ''),
          throwsA(_safe('audio')),
        );
      },
    );
    test('primary/fork startup admit only WebSocket configuration', () {
      expect(
        () => LiveSessionStartEvent(
          session: LiveSessionCreateParams(
            model: 'live',
            client: LiveClientConfigParam(
              dataChannel: LiveDataChannelConfigParam(),
            ),
          ),
        ),
        throwsA(_safe('client')),
      );
      expect(
        () => LiveForkSessionStartEvent(
          session: LiveForkSessionConfigParam(
            client: LiveClientConfigParam(
              dataChannel: LiveDataChannelConfigParam(),
            ),
          ),
        ),
        throwsA(_safe('client')),
      );
      expect(
        () => LiveClientEvent.fromForkJson(const {
          'type': 'session.start',
          'session': {'model': _private},
        }),
        throwsA(_safe('session')),
      );
    });
    test(
      'backend token nonfinite bug remains rejected through command nested factories',
      () {
        for (final text in ['Infinity', '-Infinity', 'NaN']) {
          final dynamic value = num.parse(text);
          expect(
            () => LiveClientEvent.fromJson({
              'type': 'session.start',
              'session': {
                'model': 'live',
                'delegation': {
                  'type': 'responses',
                  'responses': {'model': 'backend', 'max_output_tokens': value},
                },
              },
            }),
            throwsA(_safe('session')),
          );
          expect(
            () => LiveClientEvent.fromJson({
              'type': 'session.update',
              'session': {
                'delegation': {
                  'type': 'responses',
                  'responses': {'max_output_tokens': value},
                },
              },
            }),
            throwsA(_safe('session')),
          );
        }
      },
    );
    test(
      'existing typed Responses inputs are detached into exact Live item commands',
      () {
        final output = FunctionCallOutputItem.string(
          callId: 'call',
          output: _private,
        );
        final item = LiveInputItem.fromItem(output);
        final model = LiveResponseItemCreateParam(item: item);
        expect(model.toJson(), {
          'type': 'response.item.create',
          'item': output.toJson(),
        });
        expect(model.toString(), isNot(contains(_private)));
        expect(item.toString(), isNot(contains(_private)));
      },
    );
  });
}
