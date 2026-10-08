import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

TranscriptionRequest request({String model = 'future-model'}) =>
    TranscriptionRequest(
      file: Uint8List.fromList([0, 255]),
      filename: 'private.wav',
      model: model,
    );

Map<String, dynamic> object(Object? value) => value! as Map<String, dynamic>;

void main() {
  group('File audio request ownership and admission', () {
    test('transcription constructor owns bytes and every collection', () {
      final bytes = Uint8List.fromList([0, 255]);
      final include = [TranscriptionInclude.logprobs];
      final keywords = ['private-keyword'];
      final names = ['private-speaker'];
      final references = ['data:audio/wav;base64,AP8='];
      final languages = ['en'];
      final granularities = [TimestampGranularity.word];
      final value = TranscriptionRequest(
        file: bytes,
        filename: 'private.wav',
        model: 'future-model',
        include: include,
        keywords: keywords,
        knownSpeakerNames: names,
        knownSpeakerReferences: references,
        languages: languages,
        timestampGranularities: granularities,
        fileContentType: 'audio/wav',
      );
      bytes[0] = 99;
      include.clear();
      keywords.clear();
      names.clear();
      references.clear();
      languages.clear();
      granularities.clear();
      expect(value.file, [0, 255]);
      expect(value.include, [TranscriptionInclude.logprobs]);
      expect(value.keywords, ['private-keyword']);
      expect(value.knownSpeakerNames, ['private-speaker']);
      expect(value.knownSpeakerReferences, ['data:audio/wav;base64,AP8=']);
      expect(value.languages, ['en']);
      expect(value.timestampGranularities, [TimestampGranularity.word]);
      expect(() => value.file[0] = 10, throwsUnsupportedError);
      expect(() => value.keywords!.add('changed'), throwsUnsupportedError);
      expect(value.toString(), isNot(contains('private-')));
      expect(value.copyWith(), value);
      expect(value.copyWith(fileContentType: null).fileContentType, isNull);
      expect(value.copyWith(fileContentType: 'audio/mpeg'), isNot(value));
    });

    test('translation copy owns bytes and clears every optional field', () {
      final bytes = Uint8List.fromList([0, 255]);
      final value = TranslationRequest(
        file: bytes,
        filename: 'private.wav',
        model: 'future-model',
        fileContentType: 'audio/wav',
        prompt: 'private-prompt',
        responseFormat: TranslationResponseFormat.text,
        temperature: 0.5,
      );
      bytes[0] = 99;
      expect(value.file, [0, 255]);
      expect(() => value.file[0] = 1, throwsUnsupportedError);
      final replacement = Uint8List.fromList([7]);
      final copy = value.copyWith(
        file: replacement,
        filename: 'next.wav',
        model: 'next',
        fileContentType: null,
        prompt: null,
        responseFormat: null,
        temperature: null,
      );
      replacement[0] = 8;
      expect(copy.file, [7]);
      expect(copy.filename, 'next.wav');
      expect(copy.model, 'next');
      expect(copy.fileContentType, isNull);
      expect(copy.prompt, isNull);
      expect(copy.responseFormat, isNull);
      expect(copy.temperature, isNull);
      expect(value.copyWith(), value);
      expect(value.toString(), isNot(contains('private-')));
      expect(copy, isNot(value));
    });

    for (final format in AudioResponseFormat.values.where(
      (value) => value != AudioResponseFormat.unknown,
    )) {
      test(
        'canonical transcription format ${format.name} admits without defaults',
        () {
          request().copyWith(responseFormat: format).validate();
        },
      );
    }
    for (final format in TranslationResponseFormat.values.where(
      (value) => value != TranslationResponseFormat.unknown,
    )) {
      test('canonical translation format ${format.name} admits', () {
        TranslationRequest(
          file: Uint8List(0),
          filename: 'audio.wav',
          model: 'future',
          responseFormat: format,
        ).validate();
      });
    }
    test('unknown writable format and include sentinels fail', () {
      expect(
        () => request()
            .copyWith(responseFormat: AudioResponseFormat.unknown)
            .validate(),
        throwsFormatException,
      );
      expect(
        () => request()
            .copyWith(include: [TranscriptionInclude.unknown])
            .validate(),
        throwsFormatException,
      );
      expect(
        () => TranslationRequest(
          file: Uint8List(0),
          filename: 'audio.wav',
          model: 'future',
          responseFormat: TranslationResponseFormat.unknown,
        ).validate(),
        throwsFormatException,
      );
    });
    for (final value in [
      double.nan,
      double.infinity,
      double.negativeInfinity,
      -0.1,
      1.1,
    ]) {
      test('temperature rejects invalid finite/range state $value', () {
        expect(
          () => request().copyWith(temperature: value).validate(),
          throwsFormatException,
        );
        expect(
          () => TranslationRequest(
            file: Uint8List(0),
            filename: 'a.wav',
            model: 'future',
            temperature: value,
          ).validate(),
          throwsFormatException,
        );
      });
    }
    for (final value in [0.0, 1.0]) {
      test('documented temperature endpoint $value accepted', () {
        request().copyWith(temperature: value).validate();
        TranslationRequest(
          file: Uint8List(0),
          filename: 'a.wav',
          model: 'future',
          temperature: value,
        ).validate();
      });
    }
    test('collection constraints match canonical bounds', () {
      expect(
        () => request().copyWith(languages: <String>[]).validate(),
        throwsFormatException,
      );
      expect(
        () => request()
            .copyWith(knownSpeakerNames: List.filled(5, 'name'))
            .validate(),
        throwsFormatException,
      );
      expect(
        () => request()
            .copyWith(
              knownSpeakerReferences: List.filled(
                5,
                'data:audio/wav;base64,AP8=',
              ),
            )
            .validate(),
        throwsFormatException,
      );
      request()
          .copyWith(
            languages: ['en'],
            knownSpeakerNames: List.filled(4, 'name'),
            knownSpeakerReferences: List.filled(
              4,
              'data:audio/wav;base64,AP8=',
            ),
          )
          .validate();
    });
    for (final reference in [
      'AP8=',
      'data:audio/wav,%ZZ',
      'data:audio/wav;base64,private-invalid',
    ]) {
      test(
        'speaker reference rejects invalid data URL without content echo',
        () {
          expect(
            () => request()
                .copyWith(knownSpeakerReferences: [reference])
                .validate(),
            throwsA(
              isA<FormatException>().having(
                (error) => error.toString(),
                'privacy',
                isNot(contains(reference)),
              ),
            ),
          );
        },
      );
    }
    test('gpt-transcribe guide restrictions are scoped to that model', () {
      expect(
        () => request(
          model: 'gpt-transcribe',
        ).copyWith(language: 'en').validate(),
        throwsFormatException,
      );
      for (final keyword in ['bad<tag>', 'bad\rkeyword', 'bad\nkeyword']) {
        expect(
          () => request(
            model: 'gpt-transcribe',
          ).copyWith(keywords: [keyword]).validate(),
          throwsFormatException,
        );
        request()
            .copyWith(language: 'en', languages: ['en'], keywords: [keyword])
            .validate();
      }
      request(model: 'gpt-transcribe')
          .copyWith(
            languages: ['en'],
            keywords: ['long allowed prompt'],
            prompt: List.filled(10000, 'x').join(),
          )
          .validate();
    });
    test(
      'nullable chunking/stream can be cleared; false remains explicit state',
      () {
        final value = request().copyWith(
          chunkingStrategy: const TranscriptionChunkingStrategy.auto(),
          stream: false,
        );
        expect(value.stream, isFalse);
        expect(
          value.copyWith(chunkingStrategy: null, stream: null).chunkingStrategy,
          isNull,
        );
        expect(
          value.copyWith(chunkingStrategy: null, stream: null).stream,
          isNull,
        );
      },
    );
  });

  group('Reviewed boundary regressions', () {
    for (final reference in [
      'data:audio/wav,%00%FF',
      'data:audio/wav,hello%20world',
      'data:audio/wav,AP8=',
    ]) {
      test(
        'percent/unencoded data URL content is forwarded without normalization',
        () {
          final value = request().copyWith(knownSpeakerReferences: [reference])
            ..validate();
          expect(value.knownSpeakerReferences, [reference]);
        },
      );
    }
    for (final reference in [
      'data:audio/wav,%',
      'data:audio/wav,%0',
      'data:audio/wav,%ZZ',
    ]) {
      test(
        'malformed percent syntax is rejected instead of URI-normalized',
        () {
          expect(
            () => request()
                .copyWith(knownSpeakerReferences: [reference])
                .validate(),
            throwsFormatException,
          );
        },
      );
    }
    test('nullable numeric copy slots accept integers and clear with null', () {
      expect(request().copyWith(temperature: 1).temperature, 1.0);
      expect(
        TranslationRequest(
          file: Uint8List(0),
          filename: 'a.wav',
          model: 'future',
        ).copyWith(temperature: 1).temperature,
        1.0,
      );
      expect(TranscriptionLogprob().copyWith(logprob: 0).logprob, 0.0);
      expect(
        const TranscriptionVadConfig().copyWith(threshold: 1).threshold,
        1.0,
      );
      expect(
        request()
            .copyWith(temperature: 1)
            .copyWith(temperature: null)
            .temperature,
        isNull,
      );
      expect(
        TranscriptionLogprob()
            .copyWith(logprob: 0)
            .copyWith(logprob: null)
            .logprob,
        isNull,
      );
    });
    test('nullable numeric copies reject wrong values with safe context', () {
      for (final value in <Object?>['private-malformed', {}, double.nan]) {
        expect(
          () => request().copyWith(temperature: value),
          throwsA(
            isA<FormatException>().having(
              (error) => error.toString(),
              'privacy',
              isNot(contains('private-malformed')),
            ),
          ),
        );
        expect(
          () => TranslationRequest(
            file: Uint8List(0),
            filename: 'a.wav',
            model: 'future',
          ).copyWith(temperature: value),
          throwsFormatException,
        );
        expect(
          () => TranscriptionLogprob().copyWith(logprob: value),
          throwsFormatException,
        );
        expect(
          () => const TranscriptionVadConfig().copyWith(threshold: value),
          throwsFormatException,
        );
      }
    });
    for (final sse in [false, true]) {
      for (final fresh in [false, true]) {
        test(
          'outer parent wins grandchild future metadata with typed counters ($sse/$fresh)',
          () {
            final wire = <String, dynamic>{
              if (sse) 'type': 'transcript.text.done',
              'text': 'private-text',
              'usage': {
                'type': 'tokens',
                'input_tokens': 1,
                'output_tokens': 2,
                'total_tokens': 3,
                'input_token_details': {
                  'audio_tokens': 2,
                  'text_tokens': 1,
                  'future': 'child-old',
                },
              },
            };
            final child =
                const TranscriptTextUsageTokens(
                  inputTokens: 4,
                  outputTokens: 5,
                  totalTokens: 9,
                  inputTokenDetails: TranscriptUsageInputTokenDetails(
                    audioTokens: 10,
                    textTokens: 11,
                  ),
                ).copyWith(
                  inputTokenDetails: const TranscriptUsageInputTokenDetails(
                    audioTokens: 10,
                    textTokens: 11,
                  ).copyWith(rawJson: {'future': 'child-fresh'}),
                );
            final raw = <String, dynamic>{
              'usage': {
                'input_token_details': {
                  'future': 'parent-new',
                  'audio_tokens': 999,
                },
              },
            };
            final Map<String, dynamic> result;
            if (sse) {
              final original = TranscriptTextDoneEvent.fromJson(wire);
              result = fresh
                  ? original.copyWith(usage: child, rawJson: raw).toJson()
                  : original.copyWith(rawJson: raw).toJson();
            } else {
              final original = TranscriptionResponse.fromJson(wire);
              result = fresh
                  ? original.copyWith(usage: child, rawJson: raw).toJson()
                  : original.copyWith(rawJson: raw).toJson();
            }
            final details = object(
              object(result['usage'])['input_token_details'],
            );
            expect(details['future'], 'parent-new');
            expect(details['audio_tokens'], fresh ? 10 : 2);
            expect(details['text_tokens'], fresh ? 11 : 1);
          },
        );
      }
      test(
        'outer raw metadata cannot revive cleared typed token details ($sse)',
        () {
          final wire = <String, dynamic>{
            if (sse) 'type': 'transcript.text.done',
            'text': 'private-text',
            'usage': {
              'type': 'tokens',
              'input_tokens': 1,
              'output_tokens': 2,
              'total_tokens': 3,
              'input_token_details': {'audio_tokens': 1, 'future': 'old'},
            },
          };
          const child = TranscriptTextUsageTokens(
            inputTokens: 1,
            outputTokens: 2,
            totalTokens: 3,
          );
          final raw = <String, dynamic>{
            'usage': {
              'input_token_details': {
                'future': 'explicit',
                'audio_tokens': 999,
              },
            },
          };
          final result = sse
              ? TranscriptTextDoneEvent.fromJson(
                  wire,
                ).copyWith(usage: child, rawJson: raw).toJson()
              : TranscriptionResponse.fromJson(
                  wire,
                ).copyWith(usage: child, rawJson: raw).toJson();
          expect(
            object(result['usage']).containsKey('input_token_details'),
            isFalse,
          );
        },
      );
    }
  });

  group('Exact VAD writable union', () {
    test(
      'const variants and closed JSON preserve explicit values without defaults',
      () {
        const config = TranscriptionVadConfig(
          prefixPaddingMs: -1,
          silenceDurationMs: 0,
          threshold: 1.5,
        );
        // Canonical has no numeric min/max for these fields; no invented bounds.
        final strategy = TranscriptionChunkingStrategy.fromJson(
          config.toJson(),
        );
        expect(strategy, const TranscriptionChunkingStrategy.serverVad(config));
        expect(strategy.toFormFields(), {
          'chunking_strategy[type]': 'server_vad',
          'chunking_strategy[prefix_padding_ms]': '-1',
          'chunking_strategy[silence_duration_ms]': '0',
          'chunking_strategy[threshold]': '1.5',
        });
        expect(
          TranscriptionChunkingStrategy.fromJson('auto'),
          const TranscriptionChunkingStrategy.auto(),
        );
        expect(const TranscriptionVadConfig().toJson(), {'type': 'server_vad'});
        expect(
          config.copyWith(
            prefixPaddingMs: null,
            silenceDurationMs: null,
            threshold: null,
          ),
          const TranscriptionVadConfig(),
        );
      },
    );
    for (final wire in <Object?>[
      null,
      'private-future',
      {},
      {'type': null},
      {'type': 'private-future'},
      {'type': 'server_vad', 'private-future': 1},
      {'type': 'server_vad', 'threshold': null},
      {'type': 'server_vad', 'threshold': double.nan},
      {'type': 'server_vad', 'prefix_padding_ms': 1.5},
    ]) {
      test('VAD malformed union safely rejects', () {
        expect(
          () => TranscriptionChunkingStrategy.fromJson(wire),
          throwsA(
            isA<FormatException>().having(
              (error) => error.toString(),
              'privacy',
              isNot(contains('private-future')),
            ),
          ),
        );
      });
    }
  });

  group('REST versus SSE logprob bytes', () {
    test('REST keeps fractional finite numbers; delta/done reject them', () {
      final wire = <String, dynamic>{
        'token': 'private-token',
        'bytes': [1, 2.5],
        'logprob': -0.3,
      };
      expect(TranscriptionLogprob.fromJson(wire).bytes, [1, 2.5]);
      expect(
        () => TranscriptionLogprob.fromStreamJson(wire),
        throwsFormatException,
      );
      expect(
        () => TranscriptTextDeltaEvent.fromJson({
          'type': 'transcript.text.delta',
          'delta': 'private-text',
          'logprobs': [wire],
        }),
        throwsFormatException,
      );
      expect(
        () => TranscriptTextDoneEvent.fromJson({
          'type': 'transcript.text.done',
          'text': 'private-text',
          'logprobs': [wire],
        }),
        throwsFormatException,
      );
      expect(
        () => TranscriptTextDeltaEvent(
          delta: 'private-text',
          logprobs: [
            TranscriptionLogprob(bytes: const [2.5]),
          ],
        ).toJson(),
        throwsFormatException,
      );
    });
    test(
      'SSE integer bytes and absent inline fields roundtrip without invented requirements',
      () {
        final wire = <String, dynamic>{
          'bytes': [1, 2],
          'future': {'nested': true},
        };
        final value = TranscriptionLogprob.fromStreamJson(wire);
        expect(value.token, isNull);
        expect(value.logprob, isNull);
        expect(value.toJson(), wire);
        expect(TranscriptionLogprob.fromStreamJson(const {}).toJson(), isEmpty);
      },
    );
    test('constructor and copy own byte collections', () {
      final bytes = <num>[1, 2.5];
      final value = TranscriptionLogprob(
        bytes: bytes,
        token: 'private-token',
        logprob: -0.2,
      );
      bytes[0] = 8;
      expect(value.bytes, [1, 2.5]);
      expect(() => value.bytes!.add(8), throwsUnsupportedError);
      final next = <num>[7];
      final copy = value.copyWith(bytes: next);
      next[0] = 9;
      expect(copy.bytes, [7]);
      expect(
        value.copyWith(token: null, bytes: null, logprob: null).toJson(),
        isEmpty,
      );
    });
    for (final value in [
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      test('REST nonfinite byte/logprob is malformed', () {
        expect(
          () => TranscriptionLogprob.fromJson({
            'bytes': [value],
          }),
          throwsFormatException,
        );
        expect(
          () => TranscriptionLogprob.fromJson({'logprob': value}),
          throwsFormatException,
        );
      });
    }
  });

  group('Received discriminators and future ownership', () {
    for (final type in <Object?>[null, 1, false, [], {}]) {
      test('both public unions reject missing/nonstring type', () {
        expect(
          () => TranscriptionStreamEvent.fromJson({'type': type}),
          throwsFormatException,
        );
        expect(
          () => TranscriptUsage.fromJson({'type': type}),
          throwsFormatException,
        );
      });
    }
    test('omitted type is malformed instead of an unknown event', () {
      expect(
        () => TranscriptionStreamEvent.fromJson(const {}),
        throwsFormatException,
      );
      expect(() => TranscriptUsage.fromJson(const {}), throwsFormatException);
    });
    test(
      'future string variants retain deep snapshots and effective copy identity',
      () {
        final wire = <String, dynamic>{
          'type': 'private-future',
          'nested': {
            'items': [1, null, true],
          },
        };
        final event =
            TranscriptionStreamEvent.fromJson(wire)
                as TranscriptTextUnknownEvent;
        final usage = TranscriptUsage.fromJson(wire) as TranscriptUsageUnknown;
        (object(wire['nested'])['items'] as List<dynamic>).add('mutated');
        expect(object(event.toJson()['nested'])['items'], [1, null, true]);
        expect(object(usage.toJson()['nested'])['items'], [1, null, true]);
        expect(
          () => (object(event.rawJson['nested'])['items'] as List<dynamic>).add(
            4,
          ),
          throwsUnsupportedError,
        );
        expect(
          event.copyWith(rawType: 'future-next').toJson()['type'],
          'future-next',
        );
        expect(
          usage.copyWith(rawType: 'future-next').toJson()['type'],
          'future-next',
        );
        expect(event.copyWith(), event);
        expect(usage.copyWith(), usage);
        expect(event.toString(), isNot(contains('private-future')));
        expect(usage.toString(), isNot(contains('private-future')));
      },
    );
    test(
      'unknown constructors cannot substitute for known branch validation',
      () {
        expect(
          () => TranscriptTextUnknownEvent(
            rawType: 'transcript.text.done',
            rawJson: const {},
          ),
          throwsFormatException,
        );
        expect(
          () => TranscriptUsageUnknown(rawType: 'tokens', rawJson: const {}),
          throwsFormatException,
        );
      },
    );
    for (final value in [double.nan, double.infinity, Object()]) {
      test(
        'opaque future values must be finite JSON, with no private key echo',
        () {
          expect(
            () => TranslationResponse.fromJson({
              'text': 'private-text',
              'private-future-key': value,
            }),
            throwsA(
              isA<FormatException>().having(
                (error) => error.toString(),
                'privacy',
                isNot(contains('private-future-key')),
              ),
            ),
          );
        },
      );
    }
    test('cyclic future object safely fails', () {
      final wire = <String, dynamic>{'text': 'private-text'};
      wire['private-future-key'] = wire;
      expect(
        () => TranslationResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'privacy',
            isNot(contains('private-')),
          ),
        ),
      );
    });
  });

  group('Nested metadata replacement and parent priority', () {
    for (final fresh in [false, true]) {
      test(
        'parent override wins future fields but typed counts remain authoritative ($fresh)',
        () {
          final original = TranscriptionResponse.fromJson(const {
            'text': 'private-text',
            'usage': {
              'type': 'tokens',
              'input_tokens': 1,
              'output_tokens': 2,
              'total_tokens': 3,
              'future': 'old',
            },
          });
          final usage = fresh
              ? const TranscriptTextUsageTokens(
                  inputTokens: 4,
                  outputTokens: 5,
                  totalTokens: 9,
                ).copyWith(rawJson: {'future': 'fresh'})
              : original.usage;
          final copy = original.copyWith(
            usage: usage,
            rawJson: {
              'usage': {'future': 'parent', 'input_tokens': 100},
            },
          );
          expect(object(copy.toJson()['usage'])['future'], 'parent');
          expect(object(copy.toJson()['usage'])['input_tokens'], fresh ? 4 : 1);
        },
      );
    }
    test('fresh child usage and child list drops stale parent extras', () {
      final original = TranscriptionResponse.fromJson(const {
        'text': 'private-text',
        'usage': {'type': 'duration', 'seconds': 1, 'future': 'stale'},
        'languages': [
          {'code': 'en', 'future': 'stale'},
        ],
      });
      final copy = original.copyWith(
        usage: const TranscriptTextUsageDuration(seconds: 2),
        languages: [const TranscriptionLanguage(code: 'fr')],
      );
      expect(copy.toJson()['usage'], {'type': 'duration', 'seconds': 2});
      expect(copy.toJson()['languages'], [
        {'code': 'fr'},
      ]);
      expect(original.copyWith(usage: null, languages: null).toJson(), {
        'text': 'private-text',
      });
    });
    test('future usage branch treats only type as known', () {
      final original = TranscriptionResponse.fromJson(const {
        'text': 'private-text',
        'usage': {
          'type': 'future',
          'seconds': {'nested': 'old'},
        },
      });
      final copy = original.copyWith(
        rawJson: {
          'usage': {
            'seconds': {'nested': 'parent'},
          },
        },
      );
      expect(object(copy.toJson()['usage'])['seconds'], {'nested': 'parent'});
    });
    test(
      'parent override for child list preserves future extras and typed code',
      () {
        final value = TranscriptionResponse.fromJson(const {
          'text': 'private-text',
          'languages': [
            {'code': 'en', 'future': 'old'},
          ],
        });
        final copy = value.copyWith(
          rawJson: {
            'languages': [
              {'code': 'wrong', 'future': 'parent'},
            ],
          },
        );
        expect(copy.toJson()['languages'], [
          {'code': 'en', 'future': 'parent'},
        ]);
      },
    );
  });

  group('Translation verbose canonical and legacy state', () {
    test('canonical shape omits task and optional segments', () {
      final value = TranslationVerboseResponse.fromJson(const {
        'language': 'English',
        'duration': 1,
        'text': 'private-text',
      });
      expect(value.task, isNull);
      expect(value.segments, isNull);
      expect(value.toJson(), {
        'language': 'English',
        'duration': 1.0,
        'text': 'private-text',
      });
      final legacy = value.copyWith(task: 'translate');
      expect(legacy.task, 'translate');
      expect(legacy.copyWith(task: null), value);
    });
    test(
      'text, segments and future metadata participate in value identity',
      () {
        final first = TranslationVerboseResponse(
          language: 'English',
          duration: 1,
          text: 'first',
          segments: const [],
        );
        final second = first.copyWith(text: 'second');
        expect(first, isNot(second));
        final same = TranslationVerboseResponse.fromJson(first.toJson());
        expect(first, same);
        expect(first.hashCode, same.hashCode);
        final withFuture = first.copyWith(
          rawJson: {
            'future': {'nested': true},
          },
        );
        expect(first, isNot(withFuture));
      },
    );
    test('segment constructors and translation lists own mutable inputs', () {
      final tokens = [1, 2];
      final segment = TranscriptionSegment(
        id: 1,
        seek: 2,
        start: 0,
        end: 1,
        text: 'private-text',
        tokens: tokens,
        temperature: 0.5,
        avgLogprob: -0.1,
        compressionRatio: 1.5,
        noSpeechProb: 0.2,
      );
      final segments = [segment];
      final value = TranslationVerboseResponse(
        language: 'English',
        duration: 1,
        text: 'private-text',
        segments: segments,
      );
      tokens[0] = 99;
      segments.clear();
      expect(segment.tokens, [1, 2]);
      expect(value.segments, [segment]);
      expect(() => segment.tokens.add(1), throwsUnsupportedError);
      expect(() => value.segments!.clear(), throwsUnsupportedError);
      final copied = segment.copyWith(tokens: [9]);
      expect(copied.tokens, [9]);
      expect(copied, isNot(segment));
    });
    test(
      'scalar const DTOs remain usable and raw metadata copy is snapshotted',
      () {
        const value = TranslationResponse(text: 'private-text');
        const word = TranscriptionWord(word: 'private-word', start: 0, end: 1);
        const language = TranscriptionLanguage(code: 'en');
        const usage = TranscriptTextUsageTokens(
          inputTokens: 1,
          outputTokens: 2,
          totalTokens: 3,
        );
        expect(word.copyWith(), word);
        expect(language.copyWith(), language);
        expect(usage.copyWith(), usage);
        final raw = <String, dynamic>{
          'future': {
            'nested': ['private-meta'],
          },
        };
        final copy = value.copyWith(rawJson: raw);
        (object(raw['future'])['nested'] as List<dynamic>).clear();
        expect(object(copy.toJson()['future'])['nested'], ['private-meta']);
        expect(copy.toString(), isNot(contains('private-meta')));
      },
    );
  });
}
