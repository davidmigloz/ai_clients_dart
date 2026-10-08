import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE_LIVE_PAYLOAD';

Matcher _safeError(String context) => isA<FormatException>()
    .having((error) => error.message, 'context', contains(context))
    .having((error) => error.source, 'source', isNull)
    .having((error) => error.offset, 'offset', isNull)
    .having((error) => error.toString(), 'privacy', isNot(contains(_private)));

LiveResponsesDelegationParam _responses() => LiveResponsesDelegationParam(
  responses: LiveResponsesDelegationSettingsInputParam(model: 'backend-future'),
);

LiveSessionResourceParam _snapshot({LiveDelegation? delegation}) =>
    LiveSessionResourceParam(
      model: 'gpt-live-future',
      id: _private,
      expiresAt: 1,
      delegation: delegation,
    );

LiveClientConfigParam _client() =>
    LiveClientConfigParam(dataChannel: LiveDataChannelConfigParam());

void main() {
  group('Finite typed Live integers across runtimes', () {
    final fixtures =
        <
          ({
            String name,
            String key,
            int finite,
            Map<String, dynamic> json,
            Object Function(dynamic) create,
            Object Function(dynamic) copy,
            Object Function(Map<String, dynamic>) parse,
            bool copyAcceptsObject,
          })
        >[
          (
            name: 'startup backend tokens',
            key: 'max_output_tokens',
            finite: 16,
            json: {'model': 'backend-future', 'max_output_tokens': 16},
            create: (dynamic value) =>
                LiveResponsesDelegationSettingsInputParam(
                  model: 'backend-future',
                  maxOutputTokens: value,
                ).toJson(),
            copy: (dynamic value) => LiveResponsesDelegationSettingsInputParam(
              model: 'backend-future',
            ).copyWith(maxOutputTokens: value).toJson(),
            parse: (json) => LiveResponsesDelegationSettingsInputParam.fromJson(
              json,
            ).toJson(),
            copyAcceptsObject: true,
          ),
          (
            name: 'update backend tokens',
            key: 'max_output_tokens',
            finite: 16,
            json: {'max_output_tokens': 16},
            create: (dynamic value) =>
                LiveResponsesDelegationSettingsUpdateInputParam(
                  maxOutputTokens: value,
                ).toJson(),
            copy: (dynamic value) =>
                LiveResponsesDelegationSettingsUpdateInputParam()
                    .copyWith(maxOutputTokens: value)
                    .toJson(),
            parse: (json) =>
                LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
                  json,
                ).toJson(),
            copyAcceptsObject: true,
          ),
          (
            name: 'resolved snapshot expiry',
            key: 'expires_at',
            finite: -1,
            json: {
              'model': 'live-future',
              'id': _private,
              'expires_at': -1,
              'status': 'active',
            },
            create: (dynamic value) => LiveSessionResourceParam(
              model: 'live-future',
              id: _private,
              expiresAt: value,
            ).toJson(),
            copy: (dynamic value) => LiveSessionResourceParam(
              model: 'live-future',
              id: _private,
              expiresAt: 1,
            ).copyWith(expiresAt: value).toJson(),
            parse: (json) => LiveSessionResourceParam.fromJson(json).toJson(),
            copyAcceptsObject: false,
          ),
          (
            name: 'PCM sample rate',
            key: 'rate',
            finite: 16000,
            json: {'type': 'audio/pcm', 'rate': 16000},
            create: (dynamic value) =>
                LiveSessionAudioFormatPCMParam(rate: value).toJson(),
            copy: (dynamic value) => LiveSessionAudioFormatPCMParam(
              rate: 16000,
            ).copyWith(rate: value).toJson(),
            parse: (json) =>
                LiveSessionAudioFormatPCMParam.fromJson(json).toJson(),
            copyAcceptsObject: false,
          ),
          (
            name: 'PCMA sample rate',
            key: 'rate',
            finite: 8000,
            json: {'type': 'audio/pcma', 'rate': 8000},
            create: (dynamic value) =>
                LiveSessionAudioFormatPCMAParam(rate: value).toJson(),
            copy: (dynamic value) => LiveSessionAudioFormatPCMAParam(
              rate: 8000,
            ).copyWith(rate: value).toJson(),
            parse: (json) =>
                LiveSessionAudioFormatPCMAParam.fromJson(json).toJson(),
            copyAcceptsObject: false,
          ),
          (
            name: 'PCMU sample rate',
            key: 'rate',
            finite: 8000,
            json: {'type': 'audio/pcmu', 'rate': 8000},
            create: (dynamic value) =>
                LiveSessionAudioFormatPCMUParam(rate: value).toJson(),
            copy: (dynamic value) => LiveSessionAudioFormatPCMUParam(
              rate: 8000,
            ).copyWith(rate: value).toJson(),
            parse: (json) =>
                LiveSessionAudioFormatPCMUParam.fromJson(json).toJson(),
            copyAcceptsObject: false,
          ),
        ];
    for (final fixture in fixtures) {
      for (final text in ['Infinity', '-Infinity', 'NaN']) {
        test('${fixture.name} rejects dynamically parsed $text', () {
          // JavaScript represents Infinity as an int; VM/Wasm reject the
          // dynamic double at a typed int boundary before validation runs.
          final dynamic value = num.parse(text);
          final constructorError = value is int
              ? _safeError(fixture.key)
              : isA<TypeError>();
          expect(() => fixture.create(value), throwsA(constructorError));
          expect(
            () => fixture.copy(value),
            throwsA(
              fixture.copyAcceptsObject
                  ? _safeError(fixture.key)
                  : constructorError,
            ),
          );
          expect(
            () => fixture.parse({...fixture.json, fixture.key: value}),
            throwsA(_safeError(fixture.key)),
          );
        });
      }
      test('${fixture.name} retains finite constructor/copy/parser wire', () {
        expect(fixture.create(fixture.finite), fixture.json);
        expect(fixture.copy(fixture.finite), fixture.json);
        expect(fixture.parse(fixture.json), fixture.json);
      });
    }
  });
  group('WebSocket audio encodings', () {
    for (final rate in [16000, 24000]) {
      test('PCM exact $rate rate and dispatcher', () {
        final format = LiveAudioFormat.pcm(rate: rate);
        expect(format.type, 'audio/pcm');
        expect(format.rate, rate);
        expect(
          LiveAudioFormat.fromJson(format.toJson() as Map<String, dynamic>),
          format,
        );
      });
    }
    for (final rate in [8000, 15999, 16001, 22050, 24001]) {
      test('PCM rejects unsupported $rate', () {
        expect(
          () => LiveSessionAudioFormatPCMParam(rate: rate),
          throwsA(_safeError('rate')),
        );
      });
    }
    for (final rate in [7999, 8001, 16000]) {
      test('G711 rejects unsupported $rate', () {
        expect(
          () => LiveSessionAudioFormatPCMAParam(rate: rate),
          throwsA(_safeError('rate')),
        );
        expect(
          () => LiveSessionAudioFormatPCMUParam(rate: rate),
          throwsA(_safeError('rate')),
        );
      });
    }
    test('G711 factories fix the 8000 Hz rate', () {
      expect(LiveAudioFormat.pcma().toJson(), {
        'type': 'audio/pcma',
        'rate': 8000,
      });
      expect(LiveAudioFormat.pcmu().toJson(), {
        'type': 'audio/pcmu',
        'rate': 8000,
      });
    });
    for (final value in <Object?>[
      null,
      1.5,
      double.nan,
      double.infinity,
      _private,
    ]) {
      test('PCM malformed rate ${value.runtimeType} stays private', () {
        expect(
          () => LiveAudioFormat.fromJson({'type': 'audio/pcm', 'rate': value}),
          throwsA(_safeError('rate')),
        );
      });
    }
    test('unknown and missing encoding cannot coerce to a known branch', () {
      for (final value in <Object?>[null, 1, _private]) {
        expect(
          () => LiveAudioFormat.fromJson({'type': value, 'rate': 16000}),
          throwsA(_safeError('LiveAudioFormat.type')),
        );
      }
      expect(
        () => LiveAudioFormat.fromJson({'rate': 16000}),
        throwsA(_safeError('LiveAudioFormat.type')),
      );
    });
  });

  group('Live voices', () {
    final voices = <LiveNamedVoice>[
      LiveVoice.alloy,
      LiveVoice.ash,
      LiveVoice.ballad,
      LiveVoice.beacon,
      LiveVoice.bossa,
      LiveVoice.brise,
      LiveVoice.cedar,
      LiveVoice.cinder,
      LiveVoice.coral,
      LiveVoice.delta,
      LiveVoice.echo,
      LiveVoice.flitz,
      LiveVoice.gleam,
      LiveVoice.harema,
      LiveVoice.juni,
      LiveVoice.marin,
      LiveVoice.meridian,
      LiveVoice.nira,
      LiveVoice.noeul,
      LiveVoice.nuri,
      LiveVoice.quartz,
      LiveVoice.ripple,
      LiveVoice.sage,
      LiveVoice.shida,
      LiveVoice.shimmer,
      LiveVoice.sillage,
      LiveVoice.stone,
      LiveVoice.tempo,
      LiveVoice.verse,
      LiveVoice.vesper,
      LiveVoice.willow,
    ];
    for (final voice in voices) {
      test('named convenience ${voice.name} round-trips', () {
        expect(voice.toJson(), voice.name);
        expect(LiveVoice.fromJson(voice.name), voice);
        expect(LiveVoice.fromJson(voice.name).hashCode, voice.hashCode);
      });
    }
    test('open names preserve future and empty strings', () {
      for (final name in ['future-live-name', '', _private]) {
        final voice = LiveVoice.named(name);
        expect(voice.toJson(), name);
        expect(LiveVoice.fromJson(name), voice);
        expect(voice.toString(), isNot(contains(_private)));
      }
      expect(LiveVoice.marin.copyWith(name: _private).name, _private);
    });
    test('custom ID Unicode code point bounds differ from Speech', () {
      final bound = List.filled(128, '😀').join();
      expect(LiveCustomVoiceParam(id: bound).id, bound);
      expect(LiveVoice.custom(id: bound).toJson(), {'id': bound});
      expect(
        () => LiveCustomVoiceParam(id: '$bound😀'),
        throwsA(_safeError('id')),
      );
      expect(() => LiveCustomVoiceParam(id: ''), throwsA(_safeError('id')));
      expect(LiveCustomVoiceParam(id: ' ').id, ' ');
      final speechId = List.filled(129, '😀').join();
      expect(AudioVoice.custom(speechId).toJson(), {'id': speechId});
      expect(
        () => AudioVoice.fromJson(const {'id': 'voice', _private: true}),
        throwsA(_safeError('AudioVoice')),
      );
    });
    test('Live custom references retain finite open metadata', () {
      final voice =
          LiveVoice.fromJson({
                'id': _private,
                'future': {
                  'tokens': [1, null],
                },
              })
              as LiveCustomVoiceParam;
      expect(voice.toJson(), {
        'id': _private,
        'future': {
          'tokens': [1, null],
        },
      });
      expect(
        () =>
            (voice.rawJson['future'] as Map<String, dynamic>)['tokens'] = null,
        throwsUnsupportedError,
      );
      expect(voice.copyWith(id: 'next').toJson()['id'], 'next');
      expect(voice.toString(), isNot(contains(_private)));
    });
  });

  group('Initial history restrictions', () {
    for (final role in ['developer', 'user', 'assistant']) {
      for (final size in [0, 2]) {
        test('$role requires exactly one content part ($size)', () {
          final part = {
            'type': role == 'assistant' ? 'text' : 'input_text',
            'text': _private,
          };
          expect(
            () => LiveInitialItem.fromJson({
              'role': role,
              'content': List.filled(size, part),
            }),
            throwsA(_safeError('content')),
          );
        });
      }
    }
    test('assistant omitted type defaults only to text', () {
      final part = LiveInitialAssistantContentPart.fromJson({'text': _private});
      expect(part, isA<LiveInitialTextContentPartParam>());
      expect(part.toJson(), {'text': _private});
      expect(
        () => LiveInitialOutputTextContentPartParam.fromJson(const {
          'text': _private,
        }),
        throwsA(_safeError('type')),
      );
      expect(
        () => LiveInitialAssistantContentPart.fromJson({
          'type': 'input_text',
          'text': _private,
        }),
        throwsA(_safeError('type')),
      );
      expect(
        () => LiveInitialInputTextContentPartParam.fromJson(const {
          'type': 'text',
          'text': _private,
        }),
        throwsA(_safeError('type')),
      );
      expect(
        () => LiveInitialAssistantContentPart.fromJson({
          'type': null,
          'text': _private,
        }),
        throwsA(_safeError('type')),
      );
    });
    test('history role is required and closed', () {
      for (final role in <Object?>[null, 'system', _private, 1]) {
        expect(
          () => LiveInitialItem.fromJson({
            'role': role,
            'content': [
              {'text': _private},
            ],
          }),
          throwsA(_safeError('role')),
        );
      }
    });
    test('constructor content owns the list', () {
      final parts = [LiveInitialInputTextContentPartParam(text: _private)];
      final item = LiveInitialDeveloperMessageItemParam(content: parts);
      parts.clear();
      expect(item.content.single.text, _private);
      expect(item.content.clear, throwsUnsupportedError);
      expect(() => item.copyWith(content: []), throwsA(_safeError('content')));
    });
    for (final size in [0, 128]) {
      test('startup history admits $size items without invented tokenizer', () {
        final input = List.generate(
          size,
          (_) => LiveInitialUserMessageItemParam(
            content: [LiveInitialInputTextContentPartParam(text: _private)],
          ),
        );
        expect(
          LiveSessionCreateParams(model: 'future', input: input).input!.length,
          size,
        );
        expect(
          LiveMediaSessionCreateParams(
            model: 'future',
            input: input,
          ).input!.length,
          size,
        );
        expect(
          LiveCallAcceptSession(model: 'future', input: input).input!.length,
          size,
        );
        expect(
          LiveSessionResourceParam(
            model: 'future',
            id: _private,
            expiresAt: 1,
            input: input,
          ).input!.length,
          size,
        );
      });
    }
    test('all startup forms reject 129 items', () {
      final input = List.generate(
        129,
        (_) => LiveInitialUserMessageItemParam(
          content: [LiveInitialInputTextContentPartParam(text: 'text')],
        ),
      );
      expect(
        () => LiveSessionCreateParams(model: 'future', input: input),
        throwsA(_safeError('input')),
      );
      expect(
        () => LiveMediaSessionCreateParams(model: 'future', input: input),
        throwsA(_safeError('input')),
      );
      expect(
        () => LiveCallAcceptSession(model: 'future', input: input),
        throwsA(_safeError('input')),
      );
      expect(
        () => LiveSessionResourceParam(
          model: 'future',
          id: 'id',
          expiresAt: 1,
          input: input,
        ),
        throwsA(_safeError('input')),
      );
    });
    test('startup list owns its input and no token counter is invented', () {
      final history = [
        LiveInitialUserMessageItemParam(
          content: [
            LiveInitialInputTextContentPartParam(
              text: List.filled(20000, 'word').join(' '),
            ),
          ],
        ),
      ];
      final config = LiveSessionCreateParams(
        model: 'future',
        input: history,
        instructions: List.filled(20000, 'word').join(' '),
      );
      history.clear();
      expect(config.input, hasLength(1));
      expect(() => config.input!.clear(), throwsUnsupportedError);
      expect(config.instructions, isNotEmpty);
      expect(LiveInitialInputTextContentPartParam(text: '').text, '');
    });
  });

  group('Backend settings and immutable session mode', () {
    for (final count in [16, 1000000]) {
      test('backend admits $count tokens and update model changes', () {
        expect(
          LiveResponsesDelegationSettingsInputParam(
            model: 'backend',
            maxOutputTokens: count,
          ).maxOutputTokens,
          count,
        );
        expect(
          LiveResponsesDelegationSettingsUpdateInputParam(
            model: 'next',
            maxOutputTokens: count,
          ).model,
          'next',
        );
      });
    }
    for (final count in [-1, 0, 15]) {
      test('backend rejects token limit $count', () {
        expect(
          () => LiveResponsesDelegationSettingsInputParam(
            model: 'backend',
            maxOutputTokens: count,
          ),
          throwsA(_safeError('max_output_tokens')),
        );
        expect(
          () => LiveResponsesDelegationSettingsUpdateInputParam(
            maxOutputTokens: count,
          ),
          throwsA(_safeError('max_output_tokens')),
        );
      });
    }
    test('backend model is required only at startup', () {
      expect(
        () => LiveResponsesDelegationSettingsInputParam.fromJson(const {}),
        throwsA(_safeError('model')),
      );
      expect(
        LiveResponsesDelegationSettingsUpdateInputParam.fromJson(
          const {},
        ).toJson(),
        <String, dynamic>{},
      );
      expect(LiveResponsesDelegationSettingsInputParam(model: '').model, '');
    });
    test('typed constructors preserve explicit null for all six settings', () {
      final startup = LiveResponsesDelegationSettingsInputParam(
        model: 'backend',
        hasInstructions: true,
        hasMaxOutputTokens: true,
        hasParallelToolCalls: true,
        hasReasoning: true,
        hasServiceTier: true,
        hasText: true,
      );
      final update = LiveResponsesDelegationSettingsUpdateInputParam(
        hasInstructions: true,
        hasMaxOutputTokens: true,
        hasParallelToolCalls: true,
        hasReasoning: true,
        hasServiceTier: true,
        hasText: true,
      );
      final expected = <String, dynamic>{
        'instructions': null,
        'max_output_tokens': null,
        'parallel_tool_calls': null,
        'reasoning': null,
        'service_tier': null,
        'text': null,
      };
      expect(startup.toJson(), {'model': 'backend', ...expected});
      expect(update.toJson(), expected);
      expect(
        startup
            .copyWith(
              clearInstructions: true,
              clearMaxOutputTokens: true,
              clearParallelToolCalls: true,
              clearReasoning: true,
              clearServiceTier: true,
              clearText: true,
            )
            .toJson(),
        {'model': 'backend'},
      );
      expect(
        update
            .copyWith(
              clearInstructions: true,
              clearMaxOutputTokens: true,
              clearParallelToolCalls: true,
              clearReasoning: true,
              clearServiceTier: true,
              clearText: true,
            )
            .toJson(),
        <String, dynamic>{},
      );
    });
    test('nullable reasoning and text flags preserve null', () {
      expect(
        LiveDelegationReasoningInputParam(
          hasEffort: true,
          hasSummary: true,
        ).toJson(),
        {'effort': null, 'summary': null},
      );
      expect(LiveDelegationTextInputParam(hasVerbosity: true).toJson(), {
        'verbosity': null,
      });
    });
    for (final key in [
      'model',
      'audio',
      'client',
      'input',
      'instructions',
      'store',
      'voice',
      'id',
      'expires_at',
      'status',
      'type',
    ]) {
      test('update rejects immutable startup $key through open overflow', () {
        expect(
          () => LiveSessionUpdateParams.fromJson({key: _private}),
          throwsA(_safeError('startup fields')),
        );
        expect(
          () => LiveSessionUpdateParams(rawJson: {key: _private}),
          throwsA(_safeError('startup fields')),
        );
      });
    }
    test('unrelated finite future update metadata remains open', () {
      final update = LiveSessionUpdateParams.fromJson(const {
        'future': {'private': _private},
      });
      expect(update.toJson(), {
        'future': {'private': _private},
      });
      expect(update.toString(), isNot(contains(_private)));
    });
    test('omitted updates retain both delegation modes', () {
      LiveSessionUpdateParams().validateForSession(_snapshot());
      LiveSessionUpdateParams().validateForSession(
        _snapshot(delegation: _responses()),
      );
      expect(LiveSessionUpdateParams().toJson(), <String, dynamic>{});
    });
    test(
      'client and Responses updates validate only against their own mode',
      () {
        final client = LiveSessionUpdateParams(
          delegation: LiveClientDelegationParam(),
        );
        final responses = LiveSessionUpdateParams(
          delegation: LiveResponsesDelegationUpdateParam(
            responses: LiveResponsesDelegationSettingsUpdateInputParam(
              model: 'next',
            ),
          ),
        );
        client.validateForSession(_snapshot());
        responses.validateForSession(_snapshot(delegation: _responses()));
        expect(
          () => client.validateForSession(_snapshot(delegation: _responses())),
          throwsA(_safeError('immutable')),
        );
        expect(
          () => responses.validateForSession(_snapshot()),
          throwsA(_safeError('immutable')),
        );
      },
    );
    test('explicit null cannot switch a Responses session to client', () {
      final clear = LiveSessionUpdateParams(hasDelegation: true);
      expect(clear.toJson(), {'delegation': null});
      clear.validateForSession(_snapshot());
      expect(
        () => clear.validateForSession(_snapshot(delegation: _responses())),
        throwsA(_safeError('immutable')),
      );
    });
    test('startup and update delegation unions reject unknown owners', () {
      for (final value in <Object?>[null, _private, 1]) {
        expect(
          () => LiveDelegation.fromJson({'type': value}),
          throwsA(_safeError('LiveDelegation.type')),
        );
        expect(
          () => LiveDelegationUpdate.fromJson({'type': value}),
          throwsA(_safeError('LiveDelegationUpdate.type')),
        );
      }
      expect(
        LiveDelegationUpdate.fromJson({'type': 'client'}),
        isA<LiveClientDelegationParam>(),
      );
      expect(
        LiveDelegation.fromJson({
          'type': 'responses',
          'responses': {'model': 'backend'},
        }),
        isA<LiveResponsesDelegationParam>(),
      );
      expect(
        LiveDelegationUpdate.fromJson({'type': 'responses'}),
        isA<LiveResponsesDelegationUpdateParam>(),
      );
    });
  });

  group('Transport and fork configuration', () {
    test('media and call-accept omit format structurally', () {
      expect(
        () => LiveMediaSessionAudioParam.fromJson(const {
          'format': {'type': 'audio/pcm', 'rate': 16000},
        }),
        throwsA(_safeError('unexpected field')),
      );
      expect(
        () => LiveMediaSessionCreateParams.fromJson(const {
          'model': 'future',
          'audio': {
            'format': {'type': 'audio/pcm', 'rate': 16000},
          },
        }),
        throwsA(_safeError('audio')),
      );
      expect(
        () => LiveCallAcceptSession.fromJson(const {
          'model': 'future',
          'type': 'live',
          'client': <String, dynamic>{},
        }),
        throwsA(_safeError('unexpected field')),
      );
      expect(LiveCallAcceptSession(model: 'future').toJson(), {
        'model': 'future',
        'type': 'live',
      });
    });
    test(
      'primary format and frontend permissions require their own transports',
      () {
        final websocket = LiveSessionCreateParams(
          model: 'future',
          audio: LiveInitialSessionAudioParam(format: LiveAudioFormat.pcma()),
        );
        expect(
          () => websocket.validateForTransport('websocket'),
          returnsNormally,
        );
        expect(
          () => websocket.validateForTransport('webrtc'),
          throwsA(_safeError('audio.format')),
        );
        expect(
          () => websocket.validateForTransport('sip'),
          throwsA(_safeError('audio.format')),
        );
        final frontend = LiveSessionCreateParams(
          model: 'future',
          client: _client(),
        );
        expect(() => frontend.validateForTransport('webrtc'), returnsNormally);
        expect(
          () => frontend.validateForTransport('websocket'),
          throwsA(_safeError('client')),
        );
        expect(
          () => frontend.validateForTransport('sip'),
          throwsA(_safeError('client')),
        );
        expect(
          () => frontend.validateForTransport(_private),
          throwsA(_safeError('transport')),
        );
      },
    );
    test(
      'received active snapshots retain all metadata and transport validation',
      () {
        final snapshot = LiveSessionResourceParam(
          model: 'future',
          id: _private,
          expiresAt: -1,
          audio: LiveInitialSessionAudioParam(
            format: LiveAudioFormat.pcm(rate: 24000),
          ),
        );
        expect(snapshot.status, 'active');
        expect(snapshot.expiresAt, -1);
        expect(snapshot.id, _private);
        snapshot.validateForTransport('websocket');
        expect(
          () => snapshot.validateForTransport('webrtc'),
          throwsA(_safeError('audio.format')),
        );
        expect(
          snapshot.copyWith(id: 'next', expiresAt: 42).toJson()['expires_at'],
          42,
        );
        expect(
          () => LiveSessionResourceParam.fromJson(const {
            'model': 'future',
            'id': _private,
            'expires_at': 1,
            'status': 'closed',
          }),
          throwsA(_safeError('status')),
        );
      },
    );
    test('media create checks SIP frontend permissions before sending', () {
      final media = LiveMediaSessionCreateParams(
        model: 'future',
        client: _client(),
      );
      expect(() => media.validateForTransport('webrtc'), returnsNormally);
      expect(
        () => media.validateForTransport('sip'),
        throwsA(_safeError('client')),
      );
      expect(
        () => media.validateForTransport('websocket'),
        throwsA(_safeError('media transport')),
      );
      LiveMediaSessionCreateParams(model: 'future').validateForTransport('sip');
    });
    test('startup model names are open and nonempty', () {
      expect(LiveSessionCreateParams(model: ' future ').model, ' future ');
      expect(
        () => LiveSessionCreateParams(model: ''),
        throwsA(_safeError('model')),
      );
      expect(
        () => LiveMediaSessionCreateParams(model: ''),
        throwsA(_safeError('model')),
      );
      expect(
        () => LiveCallAcceptSession(model: ''),
        throwsA(_safeError('model')),
      );
      expect(
        () => LiveSessionResourceParam(model: '', id: 'id', expiresAt: 1),
        throwsA(_safeError('model')),
      );
    });
    test('empty forks preserve omission and inheritance', () {
      expect(LiveMediaSessionForkParams().toJson(), <String, dynamic>{});
      expect(LiveForkSessionConfigParam().toJson(), <String, dynamic>{});
      LiveForkSessionConfigParam().validateForTransport('webrtc');
      LiveForkSessionConfigParam().validateForTransport('websocket');
      expect(
        () => LiveForkSessionConfigParam().validateForTransport('sip'),
        throwsA(_safeError('fork transport')),
      );
    });
    test('fork format overrides and client permissions remain separate', () {
      final audio = LiveForkSessionConfigParam(
        audio: LiveForkAudioParam(format: LiveAudioFormat.pcmu()),
      );
      expect(() => audio.validateForTransport('websocket'), returnsNormally);
      expect(
        () => audio.validateForTransport('webrtc'),
        throwsA(_safeError('audio')),
      );
      final client = LiveForkSessionConfigParam(client: _client());
      expect(() => client.validateForTransport('webrtc'), returnsNormally);
      expect(
        () => client.validateForTransport('websocket'),
        throwsA(_safeError('client')),
      );
      expect(
        () => LiveForkSessionConfigParam(
          audio: LiveForkAudioParam(),
        ).validateForTransport('webrtc'),
        throwsA(_safeError('audio')),
      );
    });
    test('backend fork overrides require existing Responses mode', () {
      final delegation = LiveResponsesDelegationUpdateParam();
      final media = LiveMediaSessionForkParams(delegation: delegation);
      final websocket = LiveForkSessionConfigParam(delegation: delegation);
      media.validateForSession(_snapshot(delegation: _responses()));
      websocket.validateForSession(_snapshot(delegation: _responses()));
      expect(
        () => media.validateForSession(_snapshot()),
        throwsA(_safeError('stored Responses')),
      );
      expect(
        () => websocket.validateForSession(_snapshot()),
        throwsA(_safeError('stored Responses')),
      );
      LiveMediaSessionForkParams().validateForSession(_snapshot());
      LiveForkSessionConfigParam().validateForSession(_snapshot());
    });
  });

  group('WebRTC frontend permissions', () {
    test('omission, all and none have distinct wire and value semantics', () {
      final omitted = LiveDataChannelConfigParam();
      final all = LiveDataChannelConfigParam(
        allowedClientEvents: const LiveAllowedClientEvents.all(),
        allowedServerEvents: const LiveAllowedServerEvents.all(),
      );
      final none = LiveDataChannelConfigParam(
        allowedClientEvents: LiveAllowedClientEvents.selected(const []),
        allowedServerEvents: LiveAllowedServerEvents.selected(const []),
      );
      expect(omitted.toJson(), <String, dynamic>{});
      expect(all.toJson(), {
        'allowed_client_events': 'all',
        'allowed_server_events': 'all',
      });
      expect(none.toJson(), {
        'allowed_client_events': <Object?>[],
        'allowed_server_events': <Object?>[],
      });
      expect(all, isNot(none));
      expect(omitted, isNot(all));
      expect(
        LiveAllowedClientEvents.fromJson('all'),
        const LiveAllowedClientEvents.all(),
      );
      expect(
        LiveAllowedServerEvents.fromJson('all'),
        const LiveAllowedServerEvents.all(),
      );
      expect(const LiveAllClientEvents(), isNot(const LiveAllServerEvents()));
    });
    for (final name in [
      'error',
      'info',
      'session.input_audio.mute',
      'custom.event-name_1',
    ]) {
      test('client event $name matches canonical grammar', () {
        final selection = LiveAllowedClientEvents.selected([name]);
        expect(selection.toJson(), [name]);
        expect(LiveAllowedClientEvents.fromJson([name]), selection);
      });
    }
    for (final name in [
      '',
      'session',
      'Session.started',
      '_session.started',
      'session. started',
      'session/start',
      'session.',
    ]) {
      test('invalid client event $name fails privately', () {
        expect(
          () => LiveAllowedClientEvents.selected([name]),
          throwsA(_safeError('events')),
        );
      });
    }
    test('client event character length and list cardinality boundaries', () {
      final maximum = 'a.${List.filled(254, 'b').join()}';
      expect(LiveAllowedClientEvents.selected([maximum]).toJson(), [maximum]);
      expect(
        () => LiveAllowedClientEvents.selected(['${maximum}b']),
        throwsA(_safeError('events')),
      );
      expect(
        LiveAllowedClientEvents.selected(List.filled(256, 'info')).toJson(),
        hasLength(256),
      );
      expect(
        () => LiveAllowedClientEvents.selected(List.filled(257, 'info')),
        throwsA(_safeError('events')),
      );
    });
    test('selected permissions own immutable collections', () {
      final clientNames = ['info'];
      final clients = LiveSelectedClientEvents(clientNames);
      clientNames.clear();
      expect(clients.events, ['info']);
      expect(clients.events.clear, throwsUnsupportedError);
      expect(clients.copyWith(events: ['error']).toJson(), ['error']);
      final eventList = [LiveAllowedServerEventParam(type: 'session.started')];
      final servers = LiveSelectedServerEvents(eventList);
      eventList.clear();
      expect(servers.events, hasLength(1));
      expect(servers.events.clear, throwsUnsupportedError);
      expect(servers.copyWith(events: []).toJson(), isEmpty);
    });
    test('response.event requires exactly its nested selector', () {
      expect(
        () => LiveAllowedServerEventParam(type: 'response.event'),
        throwsA(_safeError('response_event')),
      );
      expect(
        () => LiveAllowedServerEventParam(
          type: 'session.started',
          responseEvent: 'response.completed',
        ),
        throwsA(_safeError('response_event')),
      );
      final valid = LiveAllowedServerEventParam(
        type: 'response.event',
        responseEvent: 'response.completed',
      );
      expect(valid.toJson(), {
        'type': 'response.event',
        'response_event': 'response.completed',
      });
      expect(
        valid.copyWith(type: 'session.started', responseEvent: null).toJson(),
        {'type': 'session.started'},
      );
      expect(
        () => valid.copyWith(responseEvent: null),
        throwsA(_safeError('response_event')),
      );
    });
    test(
      'server selector character and cardinality boundaries use canonical rules',
      () {
        final maximum = List.filled(256, '😀').join();
        expect(LiveAllowedServerEventParam(type: maximum).type, maximum);
        expect(
          () => LiveAllowedServerEventParam(type: '$maximum😀'),
          throwsA(_safeError('type')),
        );
        expect(
          () => LiveAllowedServerEventParam(type: ''),
          throwsA(_safeError('type')),
        );
        expect(LiveAllowedServerEventParam(type: ' ').type, ' ');
        expect(
          () => LiveAllowedServerEventParam(
            type: 'response.event',
            responseEvent: '',
          ),
          throwsA(_safeError('response_event')),
        );
        expect(
          () => LiveAllowedServerEventParam(
            type: 'response.event',
            responseEvent: '$maximum😀',
          ),
          throwsA(_safeError('response_event')),
        );
        final event = LiveAllowedServerEventParam(type: 'session.started');
        expect(
          LiveAllowedServerEvents.selected(List.filled(256, event)).toJson(),
          hasLength(256),
        );
        expect(
          () => LiveAllowedServerEvents.selected(List.filled(257, event)),
          throwsA(_safeError('events')),
        );
      },
    );
    test(
      'permission unions reject malformed selectors without private values',
      () {
        for (final json in <Object?>[
          null,
          _private,
          1,
          {},
          [1],
        ]) {
          expect(
            () => LiveAllowedClientEvents.fromJson(json),
            throwsA(_safeError('LiveAllowedClientEvents')),
          );
          expect(
            () => LiveAllowedServerEvents.fromJson(json),
            throwsA(_safeError('LiveAllowedServer')),
          );
        }
        expect(
          () => LiveAllowedServerEvents.fromJson([
            {'type': 'session.started', _private: true},
          ]),
          throwsA(_safeError('unexpected field')),
        );
      },
    );
  });
}
