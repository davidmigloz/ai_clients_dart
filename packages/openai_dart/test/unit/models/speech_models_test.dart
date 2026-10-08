import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('speech voice compatibility and exact writable admission', () {
    test('old const requests and enum indices remain usable', () {
      const value = SpeechRequest(
        model: 'tts-1',
        input: 'Hello',
        voice: SpeechVoice.alloy,
      );
      expect(value.toJson(), _request());
      expect(SpeechVoice.values.take(6), [
        SpeechVoice.alloy,
        SpeechVoice.echo,
        SpeechVoice.fable,
        SpeechVoice.onyx,
        SpeechVoice.nova,
        SpeechVoice.shimmer,
      ]);
      expect(
        SpeechVoice.values.map((voice) => voice.index),
        orderedEquals(List.generate(13, (index) => index)),
      );
    });

    for (final voice in SpeechVoice.values) {
      test(
        '${voice.toJson()} enum and open named requests have equal wire values',
        () {
          final named = SpeechRequest(
            model: 'future-model',
            input: '',
            voice: AudioVoice.named(voice.toJson()),
          );
          final builtin = named.copyWith(voice: voice);
          final parsed = SpeechRequest.fromJson(named.toJson());
          expect(SpeechVoice.fromJson(voice.toJson()), voice);
          expect(parsed.voice, voice);
          _sameValue(named, builtin);
          _sameValue(named, parsed);
        },
      );
    }

    for (final name in ['', 'future-voice', 'sensitive-value']) {
      test('open voice name ${name.length} characters is preserved', () {
        final voice = AudioVoice.named(name);
        final request = SpeechRequest.fromJson({..._request(), 'voice': name});
        expect(request.voice, voice);
        expect(request.toJson()['voice'], name);
        _sameValue(voice, AudioVoice.fromJson(voice.toJson()));
        _sameValue(request, SpeechRequest.fromJson(request.toJson()));
      });
    }

    test(
      'custom references are const and impose no invented ID restrictions',
      () {
        const voice = AudioVoice.custom('opaque / id');
        const request = SpeechRequest(
          model: 'future-model',
          input: '',
          voice: voice,
        );
        expect(request.toJson()['voice'], {'id': 'opaque / id'});
        expect(SpeechRequest.fromJson(request.toJson()).voice, voice);
        expect(const AudioVoice.custom('').toJson(), {'id': ''});
        _sameValue(request, SpeechRequest.fromJson(request.toJson()));
      },
    );

    for (final invalid in <Object?>[
      null,
      true,
      4,
      ['sensitive-value'],
      {},
      {'id': null},
      {'id': 4},
      {'id': 'valid', 'sensitive-key': 'sensitive-value'},
    ]) {
      test('rejects malformed voice shape ${_shape(invalid)}', () {
        expect(() => AudioVoice.fromJson(invalid), throwsA(_safeFormat()));
        expect(
          () => SpeechRequest.fromJson({..._request(), 'voice': invalid}),
          throwsA(_safeFormat()),
        );
      });
    }

    test(
      'caller-defined voice implementations still obey the closed wire union',
      () {
        for (final value in <Object>[
          false,
          ['sensitive-value'],
          {'id': 'v', 'sensitive-key': true},
          {'id': 5},
        ]) {
          final request = SpeechRequest(
            model: 'm',
            input: '',
            voice: _CallerVoice(value),
          );
          expect(request.toJson, throwsA(_safeFormat()));
        }
        const request = SpeechRequest(
          model: 'm',
          input: '',
          voice: _CallerVoice({'id': 'v'}),
        );
        expect(request.toJson()['voice'], {'id': 'v'});
      },
    );

    test('voice value copy and diagnostics do not expose names or IDs', () {
      const name = NamedAudioVoice('sensitive-value');
      const custom = CustomAudioVoice('sensitive-value');
      _sameValue(name, NamedAudioVoice.fromJson(name.toJson()));
      _sameValue(custom, CustomAudioVoice.fromJson(custom.toJson()));
      expect(name.copyWith(name: 'changed').toJson(), 'changed');
      expect(custom.copyWith(id: 'changed').toJson(), {'id': 'changed'});
      expect(name.copyWith(), name);
      expect(custom.copyWith(), custom);
      expect(
        name.toString(),
        allOf(contains('name:'), isNot(contains('sensitive-value'))),
      );
      expect(
        custom.toString(),
        allOf(contains('id:'), isNot(contains('sensitive-value'))),
      );
      expect(
        () => SpeechVoice.fromJson('sensitive-value'),
        throwsA(_safeFormat()),
      );
      expect(
        () => NamedAudioVoice.fromJson(false),
        throwsA(_safeFormat('name')),
      );
    });
  });

  group('complete speech request', () {
    test(
      'all optional fields roundtrip without materializing absent defaults',
      () {
        final wire = {
          ..._request(),
          'instructions': 'sensitive-value',
          'response_format': 'wav',
          'speed': 0.25,
          'stream_format': 'sse',
        };
        final parsed = SpeechRequest.fromJson(wire);
        expect(parsed.instructions, 'sensitive-value');
        expect(parsed.responseFormat, SpeechResponseFormat.wav);
        expect(parsed.speed, 0.25);
        expect(parsed.streamFormat, SpeechStreamFormat.sse);
        expect(parsed.toJson(), wire);
        _sameValue(parsed, SpeechRequest.fromJson(parsed.toJson()));
        expect(SpeechRequest.fromJson(_request()).toJson(), _request());
      },
    );

    for (final field in ['model', 'input', 'voice']) {
      test('$field is required and nonnull', () {
        final missing = _request()..remove(field);
        expect(() => SpeechRequest.fromJson(missing), throwsA(_safeFormat()));
        expect(
          () => SpeechRequest.fromJson({..._request(), field: null}),
          throwsA(_safeFormat()),
        );
      });
    }

    for (final field in [
      'instructions',
      'response_format',
      'speed',
      'stream_format',
    ]) {
      for (final bad in [
        null,
        false,
        <String, dynamic>{'sensitive-key': 'sensitive-value'},
      ]) {
        test('$field rejects present ${_shape(bad)}', () {
          expect(
            () => SpeechRequest.fromJson({..._request(), field: bad}),
            throwsA(_safeFormat(field)),
          );
        });
      }
    }

    for (final field in ['language', 'format', 'stream', 'sensitive-key']) {
      test('closed request rejects undeclared $field without echo', () {
        expect(
          () =>
              SpeechRequest.fromJson({..._request(), field: 'sensitive-value'}),
          throwsA(_safeFormat()),
        );
      });
    }

    for (final format in SpeechResponseFormat.values) {
      test('exact audio codec ${format.toJson()}', () {
        expect(SpeechResponseFormat.fromJson(format.toJson()), format);
        expect(
          SpeechRequest.fromJson({
            ..._request(),
            'response_format': format.toJson(),
          }).responseFormat,
          format,
        );
      });
    }
    for (final format in SpeechStreamFormat.values) {
      test('exact stream format ${format.toJson()}', () {
        expect(SpeechStreamFormat.fromJson(format.toJson()), format);
        expect(
          SpeechRequest.fromJson({
            ..._request(),
            'stream_format': format.toJson(),
          }).streamFormat,
          format,
        );
      });
    }
    for (final invalid in ['sensitive-value', 'pcm16']) {
      test('closed formats reject $invalid', () {
        expect(
          () => SpeechResponseFormat.fromJson(invalid),
          throwsA(_safeFormat()),
        );
        expect(
          () => SpeechStreamFormat.fromJson(invalid),
          throwsA(_safeFormat()),
        );
        expect(
          () => SpeechRequest.fromJson({
            ..._request(),
            'response_format': invalid,
          }),
          throwsA(_safeFormat('response_format')),
        );
        expect(
          () =>
              SpeechRequest.fromJson({..._request(), 'stream_format': invalid}),
          throwsA(_safeFormat('stream_format')),
        );
      });
    }

    for (final field in ['input', 'instructions']) {
      test('$field counts Unicode characters at 4096 boundary', () {
        final boundary = List.filled(4096, '🧪').join();
        final wire = {..._request(), field: boundary};
        expect(SpeechRequest.fromJson(wire).toJson()[field], boundary);
        final invalid = '$boundary🧪';
        expect(
          () => SpeechRequest.fromJson({...wire, field: invalid}),
          throwsA(_safeFormat(field)),
        );
        final request = field == 'input'
            ? const SpeechRequest(
                model: 'm',
                input: '',
                voice: SpeechVoice.alloy,
              ).copyWith(input: invalid)
            : const SpeechRequest(
                model: 'm',
                input: '',
                voice: SpeechVoice.alloy,
              ).copyWith(instructions: invalid);
        expect(request.toJson, throwsA(_safeFormat(field)));
        expect(
          SpeechRequest.fromJson({..._request(), field: ''}).toJson()[field],
          '',
        );
      });
    }

    for (final speed in [0.25, 1, 4.0]) {
      test('speed admits finite boundary $speed', () {
        expect(
          SpeechRequest.fromJson({..._request(), 'speed': speed}).speed,
          speed,
        );
      });
    }
    for (final bad in <Object>[
      0.249,
      4.001,
      double.nan,
      double.infinity,
      double.negativeInfinity,
      'sensitive-value',
    ]) {
      test('speed rejects ${_shape(bad)} or invalid range', () {
        expect(
          () => SpeechRequest.fromJson({..._request(), 'speed': bad}),
          throwsA(_safeFormat('speed')),
        );
      });
    }
    test('const construction cannot bypass runtime speed validation', () {
      const request = SpeechRequest(
        model: 'm',
        input: '',
        voice: SpeechVoice.alloy,
        speed: double.infinity,
      );
      expect(request.toJson, throwsA(_safeFormat('speed')));
    });

    test('copy replaces every field, optional null clears wire keys', () {
      const old = SpeechRequest(
        model: 'm',
        input: 'old',
        voice: SpeechVoice.alloy,
      );
      final changed = old.copyWith(
        model: 'future',
        input: 'new',
        voice: const AudioVoice.custom('v'),
        instructions: 'style',
        responseFormat: SpeechResponseFormat.aac,
        speed: 4,
        streamFormat: SpeechStreamFormat.sse,
      );
      expect(changed.toJson(), {
        'model': 'future',
        'input': 'new',
        'voice': {'id': 'v'},
        'instructions': 'style',
        'response_format': 'aac',
        'speed': 4.0,
        'stream_format': 'sse',
      });
      _sameValue(changed, changed.copyWith());
      expect(
        changed
            .copyWith(
              instructions: null,
              responseFormat: null,
              speed: null,
              streamFormat: null,
            )
            .toJson(),
        {
          'model': 'future',
          'input': 'new',
          'voice': {'id': 'v'},
        },
      );
      for (final copy in [
        changed.copyWith(model: 'other'),
        changed.copyWith(input: 'other'),
        changed.copyWith(voice: SpeechVoice.echo),
        changed.copyWith(instructions: null),
        changed.copyWith(responseFormat: null),
        changed.copyWith(speed: 1.0),
        changed.copyWith(streamFormat: null),
      ]) {
        expect(copy, isNot(changed));
        _sameValue(copy, SpeechRequest.fromJson(copy.toJson()));
      }
    });

    test('copy wrong optional types fail privately', () {
      const request = SpeechRequest(
        model: 'm',
        input: '',
        voice: SpeechVoice.alloy,
      );
      expect(
        () => request.copyWith(
          instructions: {'sensitive-key': 'sensitive-value'},
        ),
        throwsA(_safeFormat('instructions')),
      );
      expect(
        () => request.copyWith(responseFormat: 'sensitive-value'),
        throwsA(_safeFormat('response_format')),
      );
      expect(
        () => request.copyWith(streamFormat: 'sensitive-value'),
        throwsA(_safeFormat('stream_format')),
      );
      expect(
        () => request.copyWith(speed: 'sensitive-value'),
        throwsA(_safeFormat('speed')),
      );
    });

    test(
      'diagnostics summarize every field without private request content',
      () {
        const request = SpeechRequest(
          model: 'sensitive-value',
          input: 'sensitive-value',
          voice: AudioVoice.custom('sensitive-value'),
          instructions: 'sensitive-value',
          responseFormat: SpeechResponseFormat.mp3,
          speed: 1,
          streamFormat: SpeechStreamFormat.audio,
        );
        final output = request.toString();
        for (final field in [
          'model',
          'input',
          'voice',
          'instructions',
          'responseFormat',
          'speed',
          'streamFormat',
        ]) {
          expect(output, contains('$field:'));
        }
        expect(output, isNot(contains('sensitive-value')));
        expect(
          const SpeechRequest(
            model: '',
            input: '',
            voice: SpeechVoice.alloy,
          ).toString(),
          contains('instructions: null'),
        );
      },
    );
  });

  group('speech events and exact inline usage', () {
    test('both canonical events and arbitrary future events roundtrip', () {
      for (final wire in [
        _delta(),
        _done(),
        {
          'type': 'speech.future',
          'payload': {
            'sensitive-key': ['sensitive-value'],
          },
        },
      ]) {
        final event = SpeechStreamEvent.fromJson(wire);
        expect(event.toJson(), wire);
        _sameValue(event, SpeechStreamEvent.fromJson(event.toJson()));
      }
      expect(
        SpeechStreamEvent.fromJson(_delta()),
        isA<SpeechAudioDeltaEvent>(),
      );
      expect(SpeechStreamEvent.fromJson(_done()), isA<SpeechAudioDoneEvent>());
      expect(
        SpeechStreamEvent.fromJson(const {'type': ''}),
        isA<SpeechUnknownEvent>(),
      );
    });

    for (final type in <Object?>[
      null,
      false,
      1,
      ['sensitive-value'],
      {'sensitive-key': 'sensitive-value'},
    ]) {
      test(
        'all event factories reject malformed discriminator ${_shape(type)}',
        () {
          for (final parse in [
            SpeechStreamEvent.fromJson,
            SpeechAudioDeltaEvent.fromJson,
            SpeechAudioDoneEvent.fromJson,
            SpeechUnknownEvent.fromJson,
          ]) {
            expect(() => parse({'type': type}), throwsA(_safeFormat('type')));
            expect(() => parse({}), throwsA(_safeFormat('type')));
          }
        },
      );
    }
    test('direct known variant and unknown factory cannot hide wrong type', () {
      expect(
        () => SpeechAudioDeltaEvent.fromJson({
          ..._delta(),
          'type': 'sensitive-value',
        }),
        throwsA(_safeFormat('type')),
      );
      expect(
        () => SpeechAudioDoneEvent.fromJson({
          ..._done(),
          'type': 'sensitive-value',
        }),
        throwsA(_safeFormat('type')),
      );
      expect(
        () => SpeechUnknownEvent.fromJson(_delta()),
        throwsA(_safeFormat('type')),
      );
      expect(
        () => SpeechUnknownEvent.fromJson(_done()),
        throwsA(_safeFormat('type')),
      );
    });

    for (final audio in <Object?>[
      null,
      false,
      1,
      ['sensitive-value'],
      {'sensitive-key': 'sensitive-value'},
    ]) {
      test('delta audio requires a nonnull string ${_shape(audio)}', () {
        expect(
          () => SpeechStreamEvent.fromJson({..._delta(), 'audio': audio}),
          throwsA(_safeFormat('audio')),
        );
      });
    }
    test('empty audio allowed, decoder preserves raw byte identity', () {
      final original = Uint8List.fromList([0, 1, 128, 255, 0, 42]);
      final encoded = base64Encode(original);
      final event = SpeechAudioDeltaEvent(audio: encoded);
      expect(event.decodeAudio(), original);
      expect(event.toJson()['audio'], encoded);
      event.decodeAudio()[0] = 200;
      expect(event.decodeAudio(), original);
      expect(SpeechAudioDeltaEvent(audio: '').decodeAudio(), isEmpty);
    });
    for (final encoded in [
      'sensitive-value:invalid',
      'data:audio/wav;base64,AQID',
    ]) {
      test('invalid raw Base64 is preserved until explicit private decode', () {
        final event = SpeechAudioDeltaEvent.fromJson({
          ..._delta(),
          'audio': encoded,
        });
        expect(event.audio, encoded);
        expect(event.toJson()['audio'], encoded);
        expect(event.decodeAudio, throwsA(_safeFormat('audio')));
      });
    }

    for (final usage in <Object?>[
      null,
      false,
      4,
      ['sensitive-value'],
    ]) {
      test('done usage requires an object ${_shape(usage)}', () {
        expect(
          () => SpeechStreamEvent.fromJson({..._done(), 'usage': usage}),
          throwsA(_safeFormat('usage')),
        );
      });
    }
    test('missing required audio and usage are rejected', () {
      expect(
        () => SpeechStreamEvent.fromJson(const {'type': 'speech.audio.delta'}),
        throwsA(_safeFormat('audio')),
      );
      expect(
        () => SpeechStreamEvent.fromJson(const {'type': 'speech.audio.done'}),
        throwsA(_safeFormat('usage')),
      );
    });

    for (final count in ['input_tokens', 'output_tokens', 'total_tokens']) {
      test('$count cannot be missing', () {
        final wire = _usage()..remove(count);
        expect(() => SpeechUsage.fromJson(wire), throwsA(_safeFormat(count)));
        expect(
          () => SpeechStreamEvent.fromJson({..._done(), 'usage': wire}),
          throwsA(_safeFormat(count)),
        );
      });
      for (final bad in <Object?>[
        null,
        false,
        'sensitive-value',
        1.5,
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        test('$count rejects malformed ${_shape(bad)}', () {
          expect(
            () => SpeechUsage.fromJson({..._usage(), count: bad}),
            throwsA(_safeFormat(count)),
          );
          expect(
            () => SpeechStreamEvent.fromJson({
              ..._done(),
              'usage': {..._usage(), count: bad},
            }),
            throwsA(_safeFormat()),
          );
        });
      }
    }

    test(
      'usage has no invented discriminator, minimum or arithmetic constraint',
      () {
        final usage = SpeechUsage.fromJson(const {
          'input_tokens': -1,
          'output_tokens': 2,
          'total_tokens': 0,
        });
        expect(usage.toJson(), {
          'input_tokens': -1,
          'output_tokens': 2,
          'total_tokens': 0,
        });
        expect(usage.toJson().containsKey('type'), isFalse);
        expect(usage.toJson().containsKey('input_token_details'), isFalse);
        _sameValue(usage, SpeechUsage.fromJson(usage.toJson()));
      },
    );
    test(
      'usage covers every typed counter and raw metadata in copy/value/diagnostics',
      () {
        final usage = SpeechUsage.fromJson({
          ..._usage(),
          'future': const {
            'nested': [1],
          },
        });
        _sameValue(usage, usage.copyWith());
        for (final copy in [
          usage.copyWith(inputTokens: 7),
          usage.copyWith(outputTokens: 7),
          usage.copyWith(totalTokens: 7),
          usage.copyWith(rawJson: {}),
        ]) {
          expect(copy, isNot(usage));
          _sameValue(copy, SpeechUsage.fromJson(copy.toJson()));
        }
        expect(usage.copyWith(inputTokens: 7).toJson()['input_tokens'], 7);
        expect(usage.copyWith(rawJson: {}).toJson(), _usage());
        for (final field in [
          'inputTokens',
          'outputTokens',
          'totalTokens',
          'rawJson',
        ]) {
          expect(usage.toString(), contains('$field:'));
        }
      },
    );

    test(
      'all parsed and caller-created event metadata is deeply immutable',
      () {
        for (final make in <SpeechStreamEvent Function(Map<String, dynamic>)>[
          (raw) => SpeechAudioDeltaEvent(audio: 'AQID', rawJson: raw),
          (raw) => SpeechAudioDoneEvent(
            usage: SpeechUsage.fromJson(_usage()),
            rawJson: raw,
          ),
          (raw) => SpeechUnknownEvent(rawType: 'speech.future', rawJson: raw),
          (raw) => SpeechStreamEvent.fromJson({..._delta(), ...raw}),
          (raw) => SpeechStreamEvent.fromJson({..._done(), ...raw}),
          (raw) =>
              SpeechStreamEvent.fromJson({'type': 'speech.future', ...raw}),
        ]) {
          final raw = _metadata();
          final event = make(raw);
          final before = event.toJson();
          (raw['future'] as Map<String, dynamic>)['nested'] = ['changed'];
          expect(event.toJson(), before);
          final data = event.toJson()['future'] as Map<String, dynamic>;
          expect(() => data['nested'] = false, throwsUnsupportedError);
          expect(
            () => (data['nested'] as List<dynamic>).add('changed'),
            throwsUnsupportedError,
          );
          _sameValue(event, SpeechStreamEvent.fromJson(event.toJson()));
        }
        final raw = _metadata();
        final usage = SpeechUsage(
          inputTokens: 1,
          outputTokens: 2,
          totalTokens: 3,
          rawJson: raw,
        );
        raw['future'] = false;
        expect(usage.toJson()['future'], {
          'nested': [
            1,
            {'private': 'sensitive-value'},
          ],
        });
        expect(() => usage.rawJson['other'] = false, throwsUnsupportedError);
      },
    );

    test(
      'effective value ignores stale typed raw keys while future metadata matters',
      () {
        final delta = SpeechAudioDeltaEvent(
          audio: 'AQID',
          rawJson: const {'audio': 'stale', 'type': 'stale'},
        );
        _sameValue(delta, SpeechAudioDeltaEvent.fromJson(_delta()));
        expect(delta.copyWith(audio: 'AA=='), isNot(delta));
        expect(delta.copyWith(rawJson: _metadata()), isNot(delta));
        final done = SpeechAudioDoneEvent.fromJson({
          ..._done(),
          ..._metadata(),
        });
        _sameValue(done, done.copyWith());
        expect(done.copyWith(rawJson: {}), isNot(done));
        expect(
          done.copyWith(usage: done.usage.copyWith(inputTokens: 8)),
          isNot(done),
        );
        final unknown = SpeechUnknownEvent.fromJson({
          'type': 'speech.future',
          ..._metadata(),
        });
        _sameValue(unknown, unknown.copyWith());
        expect(
          unknown.copyWith(rawType: 'speech.next').toJson()['type'],
          'speech.next',
        );
        expect(unknown.copyWith(rawType: 'speech.next'), isNot(unknown));
        expect(unknown.copyWith(rawJson: {}).toJson(), {
          'type': 'speech.future',
        });
        expect(unknown.copyWith(rawJson: {}), isNot(unknown));
      },
    );

    test(
      'fresh usage replacement and child raw clear discard stale nested metadata',
      () {
        final original = SpeechAudioDoneEvent.fromJson({
          ..._done(),
          'usage': {
            ..._usage(),
            'old_child': const {
              'nested': [1],
            },
          },
          'parent_future': true,
        });
        for (final fresh in [
          SpeechUsage.fromJson(_usage()),
          original.usage.copyWith(rawJson: {}),
        ]) {
          final changed = original.copyWith(usage: fresh);
          expect(changed.toJson()['usage'], _usage());
          expect(changed.toJson()['parent_future'], isTrue);
          _sameValue(changed, SpeechStreamEvent.fromJson(changed.toJson()));
        }
      },
    );
    test(
      'explicit parent raw override retains child future values and typed counts win',
      () {
        final original = SpeechAudioDoneEvent.fromJson(_done());
        final override = {
          'usage': {
            'parent_override': {
              'nested': [1],
            },
            'input_tokens': 99,
          },
          'parent_future': true,
        };
        final changed = original.copyWith(
          usage: SpeechUsage.fromJson(_usage()),
          rawJson: override,
        );
        expect(changed.toJson(), {
          'parent_future': true,
          'type': 'speech.audio.done',
          'usage': {
            'parent_override': {
              'nested': [1],
            },
            ..._usage(),
          },
        });
        (override['usage']! as Map<String, dynamic>)['input_tokens'] = 66;
        expect(
          (changed.toJson()['usage'] as Map<String, dynamic>)['input_tokens'],
          1,
        );
        _sameValue(changed, SpeechStreamEvent.fromJson(changed.toJson()));
      },
    );

    for (final replaceUsage in [false, true]) {
      test(
        'explicit parent future metadata overrides ${replaceUsage ? 'fresh' : 'existing'} child future metadata',
        () {
          final original = SpeechAudioDoneEvent.fromJson({
            ..._done(),
            'usage': {..._usage(), 'future': 'child-old'},
          });
          final fresh = SpeechUsage.fromJson({
            ..._usage(),
            'input_tokens': 5,
            'future': 'child-new',
          });
          final changed = original.copyWith(
            usage: replaceUsage ? fresh : null,
            rawJson: const {
              'usage': {
                'input_tokens': 99,
                'future': 'parent-new',
                'new_parent_member': true,
              },
            },
          );
          expect(changed.toJson()['usage'], {
            ..._usage(),
            'input_tokens': replaceUsage ? 5 : 1,
            'future': 'parent-new',
            'new_parent_member': true,
          });
          expect(original.toJson()['usage'], {
            ..._usage(),
            'future': 'child-old',
          });
          _sameValue(changed, SpeechStreamEvent.fromJson(changed.toJson()));
        },
      );
    }

    for (final malformed in <Object>[
      double.nan,
      double.infinity,
      double.negativeInfinity,
      Object(),
      {1: 'sensitive-value'},
    ]) {
      test('future metadata must be finite JSON ${_shape(malformed)}', () {
        for (final wire in [
          {..._delta(), 'sensitive-key': malformed},
          {..._done(), 'sensitive-key': malformed},
          {'type': 'speech.future', 'sensitive-key': malformed},
        ]) {
          expect(
            () => SpeechStreamEvent.fromJson(wire),
            throwsA(_safeFormat()),
          );
        }
        expect(
          () => SpeechUsage.fromJson({..._usage(), 'sensitive-key': malformed}),
          throwsA(_safeFormat()),
        );
        expect(
          () => SpeechRequest.fromJson({
            ..._request(),
            'sensitive-key': malformed,
          }),
          throwsA(_safeFormat()),
        );
      });
    }
    test(
      'cyclic metadata fails privately rather than recursing indefinitely',
      () {
        final object = <String, dynamic>{};
        object['sensitive-key'] = object;
        final list = <dynamic>[];
        list.add(list);
        for (final cycle in [object, list]) {
          expect(
            () => SpeechAudioDeltaEvent(
              audio: '',
              rawJson: {'sensitive-key': cycle},
            ),
            throwsA(_safeFormat()),
          );
          expect(
            () => SpeechAudioDoneEvent(
              usage: SpeechUsage.fromJson(_usage()),
              rawJson: {'sensitive-key': cycle},
            ),
            throwsA(_safeFormat()),
          );
          expect(
            () => SpeechUnknownEvent(
              rawType: 'future',
              rawJson: {'sensitive-key': cycle},
            ),
            throwsA(_safeFormat()),
          );
          expect(
            () => SpeechUsage(
              inputTokens: 1,
              outputTokens: 2,
              totalTokens: 3,
              rawJson: {'sensitive-key': cycle},
            ),
            throwsA(_safeFormat()),
          );
        }
      },
    );
    test('all diagnostic fields are present with opaque content redacted', () {
      final delta = SpeechAudioDeltaEvent(
        audio: 'sensitive-value',
        rawJson: _metadata(),
      );
      final done = SpeechAudioDoneEvent(
        usage: SpeechUsage.fromJson({..._usage(), ..._metadata()}),
        rawJson: _metadata(),
      );
      final unknown = SpeechUnknownEvent(
        rawType: 'sensitive-value',
        rawJson: _metadata(),
      );
      for (final event in [delta, done, unknown]) {
        expect(
          event.toString(),
          allOf(
            contains('rawJson:'),
            isNot(contains('sensitive-value')),
            isNot(contains('sensitive-key')),
          ),
        );
      }
      expect(delta.toString(), contains('audio:'));
      expect(done.toString(), contains('usage:'));
      expect(unknown.toString(), contains('rawType:'));
    });
  });
}

Map<String, dynamic> _request() => {
  'model': 'tts-1',
  'input': 'Hello',
  'voice': 'alloy',
};
Map<String, dynamic> _delta() => {
  'type': 'speech.audio.delta',
  'audio': 'AQID',
};
Map<String, dynamic> _usage() => {
  'input_tokens': 1,
  'output_tokens': 2,
  'total_tokens': 3,
};
Map<String, dynamic> _done() => {
  'type': 'speech.audio.done',
  'usage': _usage(),
};
Map<String, dynamic> _metadata() => {
  'future': {
    'nested': [
      1,
      {'private': 'sensitive-value'},
    ],
  },
};

Matcher _safeFormat([String? field]) => isA<FormatException>()
    .having((error) => error.source, 'no diagnostic source payload', isNull)
    .having(
      (error) => error.toString(),
      'no private value/key echo',
      allOf(
        isNot(contains('sensitive-value')),
        isNot(contains('sensitive-key')),
      ),
    )
    .having(
      (error) => error.message,
      'context',
      field == null ? isNotEmpty : contains(field),
    );

void _sameValue(Object a, Object b) {
  expect(a, b);
  expect(b, a);
  expect(a.hashCode, b.hashCode);
  expect({a, b}, hasLength(1));
}

String _shape(Object? value) => switch (value) {
  null => 'null',
  final String _ => 'string',
  final bool _ => 'boolean',
  final num _ => 'number',
  final Map<dynamic, dynamic> _ => 'map',
  final List<dynamic> _ => 'list',
  _ => 'object',
};

final class _CallerVoice implements AudioVoice {
  const _CallerVoice(this.value);
  final Object value;
  @override
  Object toJson() => value;
}
