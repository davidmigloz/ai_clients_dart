import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

CustomVoiceCreateRequest _request({
  String name = 'private-voice-name',
  Uint8List? audioSample,
  String filename = 'private-sample.wav',
  String consent = 'private-consent-id',
  String? audioSampleContentType,
  String? type,
}) => CustomVoiceCreateRequest(
  name: name,
  audioSample: audioSample ?? Uint8List.fromList([0, 128, 255]),
  filename: filename,
  consent: consent,
  audioSampleContentType: audioSampleContentType,
  type: type,
);

Map<String, dynamic> _voiceJson() => {
  'object': 'audio.voice',
  'id': 'private-voice-id',
  'name': 'private-voice-name',
  'type': 'audio_sample',
  'created_at': 1734220800,
};

Map<String, dynamic> _futureJson() => {
  'private-future-key': {
    'nested': ['private-value', 1, null],
  },
};

Matcher _safeFormat(String context) => throwsA(
  isA<FormatException>()
      .having((error) => error.message, 'context', contains(context))
      .having(
        (error) => error.toString(),
        'private content',
        isNot(contains('private-')),
      )
      .having((error) => error.source, 'source', isNull),
);

void _expectOwnedJson(Map<String, dynamic> json) {
  expect(() => json['added'] = true, throwsUnsupportedError);
  final future = json['private-future-key'] as Map<String, dynamic>;
  expect(() => future['added'] = true, throwsUnsupportedError);
  expect(
    () => (future['nested'] as List<dynamic>).add(true),
    throwsUnsupportedError,
  );
}

void _expectPrivateDiagnostics(String text, List<String> fields) {
  expect(text, isNot(contains('private-')));
  for (final field in fields) {
    expect(text, contains('$field:'));
  }
}

void main() {
  group('CustomVoiceCreateRequest public multipart contract', () {
    test('required fields and omitted optional type/MIME are preserved', () {
      final request = _request();
      expect(request.name, 'private-voice-name');
      expect(request.audioSample, [0, 128, 255]);
      expect(request.filename, 'private-sample.wav');
      expect(request.consent, 'private-consent-id');
      expect(request.type, isNull);
      expect(request.audioSampleContentType, isNull);
      expect(request.effectiveAudioSampleContentType, 'audio/wav');
      request.validate();
      expect(request.copyWith(), request);
      expect(request.copyWith().hashCode, request.hashCode);
      _expectPrivateDiagnostics(request.toString(), [
        'name',
        'audioSample',
        'filename',
        'consent',
        'audioSampleContentType',
        'type',
      ]);
      expect(request.toString(), contains('audioSample: 3 bytes'));
      expect(request.toString(), contains('type: null'));
    });

    test(
      'explicit audio_sample differs from omission and can clear to omission',
      () {
        final omitted = _request();
        final explicit = _request(type: 'audio_sample');
        expect(explicit.type, 'audio_sample');
        expect(explicit.copyWith().type, 'audio_sample');
        expect(explicit, isNot(omitted));
        expect({explicit, omitted}, hasLength(2));
        expect(omitted.copyWith(type: 'audio_sample'), explicit);
        expect(
          omitted.copyWith(type: 'audio_sample').hashCode,
          explicit.hashCode,
        );
        expect(explicit.copyWith(type: null), omitted);
        expect(explicit.copyWith(type: null).hashCode, omitted.hashCode);
        expect(explicit.toString(), contains('type: audio_sample'));
      },
    );

    for (final type in [
      '',
      'text_prompt',
      'private-future-type',
      'AUDIO_SAMPLE',
    ]) {
      test('rejects unsupported creation type $type without coercion', () {
        expect(() => _request(type: type), _safeFormat('type'));
        expect(() => _request().copyWith(type: type), _safeFormat('type'));
      });
    }

    test('type copy rejects nonstring private values safely', () {
      expect(
        () => _request().copyWith(type: {'private-type': true}),
        _safeFormat('type'),
      );
    });

    for (final length in [1, 255, 256]) {
      test('accepts $length BMP code point name', () {
        final name = List.filled(length, 'x').join();
        expect(_request(name: name).name, name);
      });
      test(
        'accepts $length astral code point name, independent of UTF16 length',
        () {
          final name = List.filled(length, '🚀').join();
          expect(name.runes.length, length);
          expect(name.length, length * 2);
          expect(_request(name: name).name, name);
        },
      );
    }

    for (final name in [
      '',
      List.filled(257, 'x').join(),
      List.filled(257, '🚀').join(),
    ]) {
      test('rejects name with ${name.runes.length} Unicode code points', () {
        expect(() => _request(name: name), _safeFormat('name'));
        expect(() => _request().copyWith(name: name), _safeFormat('name'));
      });
    }

    test('counts combining marks and ZWJ sequences as Unicode code points', () {
      final combining = List.filled(128, 'e\u0301').join();
      expect(combining.runes.length, 256);
      expect(_request(name: combining).name, combining);
      expect(() => _request(name: '${combining}x'), _safeFormat('name'));
      const family = '👨‍👩‍👧‍👦';
      expect(family.runes.length, 7);
      final valid = List.filled(36, family).join();
      expect(valid.runes.length, 252);
      expect(_request(name: valid).name, valid);
      expect(() => _request(name: '$valid$family'), _safeFormat('name'));
    });

    test(
      'does not invent consent, filename, name grammar, or audio quality rules',
      () {
        final request = _request(
          name: ' ',
          consent: '',
          filename: '',
          audioSample: Uint8List(0),
          audioSampleContentType: 'audio/aac',
        );
        expect(request.name, ' ');
        expect(request.consent, '');
        expect(request.filename, '');
        expect(request.audioSample, isEmpty);
        expect(request.effectiveAudioSampleContentType, 'audio/aac');
      },
    );

    test(
      'snapshots exact views and all exposed byte-buffer views are readonly',
      () {
        final input = Uint8List.fromList([10, 0, 128, 255, 20]);
        final view = Uint8List.sublistView(input, 1, 4);
        final request = _request(audioSample: view);
        expect(request.audioSample, [0, 128, 255]);
        input[1] = 11;
        view[1] = 12;
        expect(request.audioSample, [0, 128, 255]);
        expect(() => request.audioSample[0] = 4, throwsUnsupportedError);
        expect(
          () => request.audioSample.buffer.asUint8List()[0] = 4,
          throwsUnsupportedError,
        );
        expect(
          () => request.audioSample.buffer.asByteData().setUint8(0, 4),
          throwsUnsupportedError,
        );
      },
    );

    test('allows exactly 10 MiB and rejects one more byte safely', () {
      final bytes = Uint8List(10 * 1024 * 1024);
      bytes[bytes.length - 1] = 255;
      final request = _request(audioSample: bytes);
      expect(CustomVoiceCreateRequest.maxAudioSampleBytes, 10 * 1024 * 1024);
      expect(request.audioSample.length, 10 * 1024 * 1024);
      expect(request.audioSample.last, 255);
      expect(
        () => _request(audioSample: Uint8List(10 * 1024 * 1024 + 1)),
        _safeFormat('audioSample'),
      );
    });

    const mimeTypes = [
      'audio/mpeg',
      'audio/wav',
      'audio/x-wav',
      'audio/ogg',
      'audio/aac',
      'audio/flac',
      'audio/webm',
      'audio/mp4',
    ];
    for (final type in mimeTypes) {
      test('admits documented base $type without changing bytes/filename', () {
        final request = _request(
          filename: 'private-sample.opaque',
          audioSampleContentType: type,
        );
        expect(request.audioSampleContentType, type);
        expect(request.effectiveAudioSampleContentType, type);
        expect(request.filename, 'private-sample.opaque');
        expect(request.audioSample, [0, 128, 255]);
      });
    }

    test('normalizes browser parameters and MIME case without transcoding', () {
      final normalized = _request(
        audioSampleContentType: ' AUDIO/WEBM;codecs="opus,pcm" ',
      );
      final base = _request(audioSampleContentType: 'audio/webm');
      expect(normalized.audioSampleContentType, 'audio/webm');
      expect(normalized.effectiveAudioSampleContentType, 'audio/webm');
      expect(normalized.audioSample, [0, 128, 255]);
      expect(normalized.filename, 'private-sample.wav');
      expect(normalized, base);
      expect(normalized.hashCode, base.hashCode);
      expect(normalized, isNot(_request()));
    });

    for (final type in [
      '',
      'private-invalid',
      'audio/pcm',
      'application/octet-stream',
      'audio/webm;private-invalid',
    ]) {
      test('MIME rejects unsupported/malformed metadata $type safely', () {
        expect(
          () => _request(audioSampleContentType: type),
          _safeFormat('audioSampleContentType'),
        );
      });
    }

    const extensions = {
      'mp3': 'audio/mpeg',
      'mpeg': 'audio/mpeg',
      'mpga': 'audio/mpeg',
      'wav': 'audio/wav',
      'ogg': 'audio/ogg',
      'oga': 'audio/ogg',
      'aac': 'audio/aac',
      'flac': 'audio/flac',
      'webm': 'audio/webm',
      'mp4': 'audio/mp4',
      'm4a': 'audio/mp4',
    };
    for (final extension in extensions.entries) {
      test(
        'infers recognized ${extension.key} extension case-insensitively',
        () {
          final request = _request(
            filename: 'private-sample.${extension.key.toUpperCase()}',
          );
          expect(request.audioSampleContentType, isNull);
          expect(request.effectiveAudioSampleContentType, extension.value);
        },
      );
    }

    for (final filename in [
      'private-sample',
      'private-sample.bin',
      'wav',
      'mp3',
      'private-sample.',
    ]) {
      test('unknown extension requires explicit metadata ($filename)', () {
        expect(
          () => _request(filename: filename),
          _safeFormat('audioSampleContentType'),
        );
        expect(
          _request(
            filename: filename,
            audioSampleContentType: 'audio/ogg',
          ).filename,
          filename,
        );
      });
    }

    test(
      'copies all fields, preserving normalized metadata and clear semantics',
      () {
        final request = _request(
          type: 'audio_sample',
          audioSampleContentType: 'audio/x-wav',
        );
        final bytes = Uint8List.fromList([9, 8, 7]);
        final copied = request.copyWith(
          name: 'private-new-name',
          audioSample: bytes,
          filename: 'private-new.mp4',
          consent: 'private-new-consent',
          audioSampleContentType: null,
          type: null,
        );
        final expected = _request(
          name: 'private-new-name',
          audioSample: Uint8List.fromList([9, 8, 7]),
          filename: 'private-new.mp4',
          consent: 'private-new-consent',
        );
        expect(copied, expected);
        expect(copied.hashCode, expected.hashCode);
        expect(copied.type, isNull);
        expect(copied.audioSampleContentType, isNull);
        expect(copied.effectiveAudioSampleContentType, 'audio/mp4');
        bytes[0] = 3;
        expect(copied.audioSample, [9, 8, 7]);
        expect(() => copied.audioSample[0] = 1, throwsUnsupportedError);
        expect(request.copyWith(), request);
        expect(request.copyWith().hashCode, request.hashCode);
        final changes = [
          request.copyWith(name: 'private-new-name'),
          request.copyWith(audioSample: Uint8List.fromList([1])),
          request.copyWith(filename: 'private-new.wav'),
          request.copyWith(consent: 'private-new-consent'),
          request.copyWith(audioSampleContentType: 'audio/wav'),
          request.copyWith(type: null),
        ];
        for (final change in changes) {
          expect(change, isNot(request));
        }
        expect(
          request
              .copyWith(audioSampleContentType: 'audio/webm;codecs=opus')
              .audioSampleContentType,
          'audio/webm',
        );
        expect(
          () =>
              request.copyWith(audioSampleContentType: {'private-mime': true}),
          _safeFormat('audioSampleContentType'),
        );
        expect(
          () => request.copyWith(
            filename: 'private-opaque.bin',
            audioSampleContentType: null,
          ),
          _safeFormat('audioSampleContentType'),
        );
      },
    );
  });

  group('CustomVoice strict public received contract', () {
    test(
      'all required fields and finite future extras roundtrip with ownership',
      () {
        final wire = _voiceJson()..addAll(_futureJson());
        final model = CustomVoice.fromJson(wire);
        final roundtrip = CustomVoice.fromJson(model.toJson());
        expect(model.object, 'audio.voice');
        expect(model.type, 'audio_sample');
        expect(model.id, 'private-voice-id');
        expect(model.name, 'private-voice-name');
        expect(model.createdAt, 1734220800);
        expect(model.rawJson, wire);
        expect(model.toJson(), wire);
        expect(model, roundtrip);
        expect(model.hashCode, roundtrip.hashCode);
        expect(model.copyWith(), model);
        wire['name'] = 'mutated';
        (wire['private-future-key'] as Map<String, dynamic>)['nested'] = [
          'mutated',
        ];
        expect(model.name, 'private-voice-name');
        expect(model.rawJson['name'], 'private-voice-name');
        expect(model.toJson()['private-future-key'], {
          'nested': ['private-value', 1, null],
        });
        _expectOwnedJson(model.rawJson);
        _expectPrivateDiagnostics(model.toString(), [
          'object',
          'id',
          'name',
          'type',
          'createdAt',
          'rawJson',
        ]);
      },
    );

    for (final field in ['object', 'type', 'id', 'name', 'created_at']) {
      test('$field is required, nonnull, and rejects wrong types safely', () {
        expect(
          () => CustomVoice.fromJson(_voiceJson()..remove(field)),
          _safeFormat(field),
        );
        expect(
          () => CustomVoice.fromJson(_voiceJson()..[field] = null),
          _safeFormat(field),
        );
        expect(
          () => CustomVoice.fromJson(
            _voiceJson()..[field] = {'private-malformed': true},
          ),
          _safeFormat(field),
        );
      });
    }

    for (final entry in {
      'object': 'private-future-object',
      'type': 'private-future-type',
    }.entries) {
      test('fixed ${entry.key} rejects unknown strings without coercion', () {
        expect(
          () => CustomVoice.fromJson(_voiceJson()..[entry.key] = entry.value),
          _safeFormat(entry.key),
        );
      });
    }

    for (final type in ['text_prompt', 'AUDIO_SAMPLE', '']) {
      test(
        'returned type $type is rejected even though future extras are received',
        () {
          expect(
            () => CustomVoice.fromJson(
              _voiceJson()
                ..['type'] = type
                ..addAll(_futureJson()),
            ),
            _safeFormat('type'),
          );
        },
      );
    }

    for (final timestamp in [
      1.25,
      double.nan,
      double.infinity,
      double.negativeInfinity,
      'private-time',
    ]) {
      test('created_at rejects noninteger/nonfinite timestamp $timestamp', () {
        expect(
          () => CustomVoice.fromJson(_voiceJson()..['created_at'] = timestamp),
          _safeFormat('created_at'),
        );
      });
    }

    test('received fields do not acquire request-only name/ID/time bounds', () {
      final longName = List.filled(257, '🚀').join();
      for (final name in ['', longName]) {
        final model = CustomVoice.fromJson(
          _voiceJson()
            ..['name'] = name
            ..['id'] = ''
            ..['created_at'] = -1,
        );
        expect(model.name, name);
        expect(model.id, '');
        expect(model.createdAt, -1);
      }
    });

    test(
      'copies each field, typed authority, and future extras with full value identity',
      () {
        final model = CustomVoice.fromJson(_voiceJson()..addAll(_futureJson()));
        final copies = [
          model.copyWith(id: 'private-new-id'),
          model.copyWith(name: 'private-new-name'),
          model.copyWith(createdAt: 42),
          model.copyWith(
            rawJson: {
              'private-new-key': [2],
            },
          ),
        ];
        for (final copy in copies) {
          expect(copy, isNot(model));
          expect(copy.object, 'audio.voice');
          expect(copy.type, 'audio_sample');
          final roundtrip = CustomVoice.fromJson(copy.toJson());
          expect(copy, roundtrip);
          expect(copy.hashCode, roundtrip.hashCode);
        }
        expect(copies[0].id, 'private-new-id');
        expect(copies[1].name, 'private-new-name');
        expect(copies[1].rawJson['name'], model.name);
        expect(copies[1].toJson()['name'], copies[1].name);
        expect(copies[2].createdAt, 42);
        expect(copies[3].toJson()['private-new-key'], [2]);
        expect(copies[3].toJson().containsKey('private-future-key'), isFalse);
        expect(model.copyWith(rawJson: {}).toJson(), _voiceJson());
        expect(model.copyWith(name: '').name, '');
      },
    );

    test(
      'direct constructor and rawJson copy take independent immutable snapshots',
      () {
        final raw = _futureJson();
        final model = CustomVoice(
          id: 'private-id',
          name: 'private-name',
          createdAt: 0,
          rawJson: raw,
        );
        final copy = model.copyWith(rawJson: raw);
        (raw['private-future-key'] as Map<String, dynamic>)['nested'] = [
          'mutated',
        ];
        for (final snapshot in [model.rawJson, copy.rawJson]) {
          expect(snapshot['private-future-key'], {
            'nested': ['private-value', 1, null],
          });
          _expectOwnedJson(snapshot);
        }
      },
    );

    test(
      'deep value equality/hash ignores map insertion order but includes future values',
      () {
        final first = CustomVoice.fromJson(
          _voiceJson()
            ..['private-future-key'] = {
              'a': [
                1,
                {'b': null},
              ],
              'c': true,
            },
        );
        final second = CustomVoice.fromJson({
          'private-future-key': const {
            'c': true,
            'a': [
              1,
              {'b': null},
            ],
          },
          ..._voiceJson(),
        });
        expect(first, second);
        expect(first.hashCode, second.hashCode);
        expect({first, second}, hasLength(1));
        expect(
          first.copyWith(
            rawJson: {
              'private-future-key': {
                'a': [2],
              },
            },
          ),
          isNot(first),
        );
      },
    );

    test(
      'nonfinite, cyclic, nonstring-key and non-JSON future extras fail safely',
      () {
        final cycle = <String, dynamic>{};
        cycle['private-cycle'] = cycle;
        for (final value in [
          double.nan,
          double.infinity,
          cycle,
          Object(),
          {1: 'private-value'},
        ]) {
          expect(
            () => CustomVoice.fromJson(
              _voiceJson()..['private-future-key'] = value,
            ),
            _safeFormat('CustomVoice'),
          );
          expect(
            () => CustomVoice(
              id: 'private-id',
              name: 'private-name',
              createdAt: 0,
              rawJson: {'private-future-key': value},
            ),
            _safeFormat('CustomVoice'),
          );
        }
      },
    );

    test(
      'returned ID can be explicitly selected as the existing custom reference',
      () {
        final voice = CustomVoice.fromJson(_voiceJson());
        final reference = AudioVoice.custom(voice.id);
        expect(reference.toJson(), {'id': 'private-voice-id'});
        expect(AudioVoice.fromJson(reference.toJson()), reference);
      },
    );
  });

  group('Shared upload extraction preserves the public consent contract', () {
    VoiceConsentCreateRequest consent({
      String filename = 'private-consent.wav',
      Uint8List? recording,
      String? contentType,
    }) => VoiceConsentCreateRequest(
      name: '',
      recording: recording ?? Uint8List.fromList([0, 128, 255]),
      filename: filename,
      language: '',
      recordingContentType: contentType,
    );

    test('all original diagnostics are byte-for-byte contextual equivalents', () {
      final cases = <String, void Function()>{
        'VoiceConsentCreateRequest.recording: maximum size is 10 MiB': () =>
            consent(recording: Uint8List(10 * 1024 * 1024 + 1)),
        'VoiceConsentCreateRequest.recordingContentType: expected a valid supported audio MIME type':
            () => consent(contentType: 'private-invalid'),
        'VoiceConsentCreateRequest.recordingContentType: unsupported audio MIME type':
            () => consent(contentType: 'audio/pcm'),
        'VoiceConsentCreateRequest.recordingContentType: provide a supported audio MIME type for an unrecognized filename extension':
            () => consent(filename: 'wav'),
      };
      for (final entry in cases.entries) {
        expect(
          entry.value,
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'exact existing message',
              entry.key,
            ),
          ),
        );
      }
    });

    test(
      'consent retains open names/languages, MIME clear and original snapshots',
      () {
        final bytes = Uint8List.fromList([0, 128, 255]);
        final request = consent(
          recording: bytes,
          contentType: 'AUDIO/WEBM;codecs=opus',
        );
        bytes[0] = 99;
        expect(request.name, '');
        expect(request.language, '');
        expect(request.recordingContentType, 'audio/webm');
        expect(request.recording, [0, 128, 255]);
        expect(() => request.recording[0] = 99, throwsUnsupportedError);
        final cleared = request.copyWith(recordingContentType: null);
        expect(cleared.recordingContentType, isNull);
        expect(cleared.effectiveRecordingContentType, 'audio/wav');
        expect(
          VoiceConsentCreateRequest.maxRecordingBytes,
          CustomVoiceCreateRequest.maxAudioSampleBytes,
        );
        request.validate();
        cleared.validate();
      },
    );
  });
}
