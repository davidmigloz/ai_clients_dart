import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _consentJson() => {
  'object': 'audio.voice_consent',
  'id': 'private-consent-id',
  'name': 'private-consent-name',
  'language': 'private-consent-language',
  'created_at': 1734220800,
};

Map<String, dynamic> _listJson() => {
  'object': 'list',
  'data': [_consentJson()],
  'has_more': true,
};

Map<String, dynamic> _deletedJson() => {
  'object': 'audio.voice_consent',
  'id': 'private-consent-id',
  'deleted': false,
};

VoiceConsentCreateRequest _create({
  String name = 'private-consent-name',
  Uint8List? recording,
  String filename = 'private-consent.wav',
  String language = 'private-consent-language',
  String? recordingContentType,
}) => VoiceConsentCreateRequest(
  name: name,
  recording: recording ?? Uint8List.fromList([0, 128, 255]),
  filename: filename,
  language: language,
  recordingContentType: recordingContentType,
);

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
  group('VoiceConsentCreateRequest public upload contract', () {
    test('snapshots the exact byte view with immutable buffer ownership', () {
      final buffer = Uint8List.fromList([10, 0, 128, 255, 20]);
      final recording = Uint8List.sublistView(buffer, 1, 4);
      final request = _create(recording: recording);
      expect(request.recording, [0, 128, 255]);
      buffer[1] = 99;
      recording[1] = 77;
      expect(request.recording, [0, 128, 255]);
      expect(() => request.recording[0] = 12, throwsUnsupportedError);
      expect(
        () => request.recording.buffer.asUint8List()[0] = 12,
        throwsUnsupportedError,
      );
      expect(
        () => request.recording.buffer.asByteData().setUint8(0, 12),
        throwsUnsupportedError,
      );
      expect(request.name, 'private-consent-name');
      expect(request.filename, 'private-consent.wav');
      expect(request.language, 'private-consent-language');
      expect(request.recordingContentType, isNull);
      expect(request.effectiveRecordingContentType, 'audio/wav');
      request.validate();
    });

    const types = [
      'audio/mpeg',
      'audio/wav',
      'audio/x-wav',
      'audio/ogg',
      'audio/aac',
      'audio/flac',
      'audio/webm',
      'audio/mp4',
    ];
    for (final type in types) {
      test('supports exact documented MIME $type', () {
        final request = _create(
          filename: 'private-recording.opaque',
          recordingContentType: type,
        );
        expect(request.recordingContentType, type);
        expect(request.effectiveRecordingContentType, type);
        expect(request.recording, [0, 128, 255]);
      });
    }

    test('normalizes browser MIME parameters without changing bytes', () {
      final request = _create(
        filename: 'private-recording.opaque',
        recordingContentType: ' AUDIO/WEBM;codecs="opus,pcm" ',
      );
      expect(request.recordingContentType, 'audio/webm');
      expect(request.effectiveRecordingContentType, 'audio/webm');
      expect(request.recording, [0, 128, 255]);
      expect(request.filename, 'private-recording.opaque');
      expect(
        request,
        _create(filename: request.filename, recordingContentType: 'audio/webm'),
      );
      expect(
        request.hashCode,
        _create(
          filename: request.filename,
          recordingContentType: 'audio/webm',
        ).hashCode,
      );
    });

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
        'infers supported ${extension.key} extension case-insensitively',
        () {
          final filename = 'private-recording.${extension.key.toUpperCase()}';
          final request = _create(filename: filename);
          expect(request.filename, filename);
          expect(request.recordingContentType, isNull);
          expect(request.effectiveRecordingContentType, extension.value);
        },
      );
    }

    test('has no invented name, language, or filename restrictions', () {
      final request = _create(
        name: '',
        language: 'future/nonstandard private-language',
        filename: '',
        recordingContentType: 'audio/aac',
        recording: Uint8List(0),
      );
      expect(request.name, '');
      expect(request.language, 'future/nonstandard private-language');
      expect(request.filename, '');
      expect(request.recording, isEmpty);
      expect(request.effectiveRecordingContentType, 'audio/aac');
    });

    test('accepts exactly 10 MiB and rejects one more byte contextually', () {
      final recording = Uint8List(10 * 1024 * 1024);
      recording[recording.length - 1] = 255;
      final request = _create(recording: recording);
      expect(VoiceConsentCreateRequest.maxRecordingBytes, 10 * 1024 * 1024);
      expect(request.recording.length, 10 * 1024 * 1024);
      expect(request.recording.last, 255);
      expect(
        () => _create(recording: Uint8List(10 * 1024 * 1024 + 1)),
        _safeFormat('recording'),
      );
    });

    for (final invalid in [
      '',
      'private-unsupported',
      'application/octet-stream',
      'audio/pcm',
      'audio/webm;private-malformed-parameter',
    ]) {
      test('rejects unsupported or malformed MIME $invalid safely', () {
        expect(
          () => _create(recordingContentType: invalid),
          _safeFormat('recordingContentType'),
        );
      });
    }

    test('requires explicit supported MIME for an unknown filename', () {
      expect(
        () => _create(filename: 'private-recording.bin'),
        _safeFormat('recordingContentType'),
      );
      expect(
        () => _create(filename: 'private-recording'),
        _safeFormat('recordingContentType'),
      );
      expect(
        () => _create(filename: 'wav'),
        _safeFormat('recordingContentType'),
      );
      expect(
        () => _create(filename: 'mp3'),
        _safeFormat('recordingContentType'),
      );
      expect(
        _create(
          filename: 'private-recording.bin',
          recordingContentType: 'audio/ogg',
        ).effectiveRecordingContentType,
        'audio/ogg',
      );
    });

    test('copies every field with byte value equality and MIME clearing', () {
      final request = _create(recordingContentType: 'audio/x-wav');
      final changedBytes = Uint8List.fromList([4, 3, 2, 1]);
      final copied = request.copyWith(
        name: 'private-new-name',
        recording: changedBytes,
        filename: 'private-new.mp4',
        language: 'private-new-language',
        recordingContentType: null,
      );
      final expected = _create(
        name: 'private-new-name',
        recording: Uint8List.fromList([4, 3, 2, 1]),
        filename: 'private-new.mp4',
        language: 'private-new-language',
      );
      expect(request.copyWith(), request);
      expect(request.copyWith().hashCode, request.hashCode);
      expect(copied, expected);
      expect(copied.hashCode, expected.hashCode);
      expect(copied.recordingContentType, isNull);
      expect(copied.effectiveRecordingContentType, 'audio/mp4');
      changedBytes[0] = 99;
      expect(copied.recording, [4, 3, 2, 1]);
      expect(() => copied.recording[0] = 99, throwsUnsupportedError);
      expect(request.copyWith(name: ''), isNot(request));
      expect(request.copyWith(recording: Uint8List(0)), isNot(request));
      expect(request.copyWith(filename: 'private-other.wav'), isNot(request));
      expect(request.copyWith(language: ''), isNot(request));
      expect(
        request.copyWith(recordingContentType: 'audio/wav'),
        isNot(request),
      );
      expect(
        () => request.copyWith(recordingContentType: {'private-key': true}),
        _safeFormat('recordingContentType'),
      );
      expect(
        () => request.copyWith(
          filename: 'private-opaque.bin',
          recordingContentType: null,
        ),
        _safeFormat('recordingContentType'),
      );
      _expectPrivateDiagnostics(request.toString(), [
        'name',
        'recording',
        'filename',
        'language',
        'recordingContentType',
      ]);
    });
  });

  group('VoiceConsentUpdateRequest closed public contract', () {
    test(
      'required open name roundtrips and supports constant construction',
      () {
        const request = VoiceConsentUpdateRequest(name: 'private-consent-name');
        final parsed = VoiceConsentUpdateRequest.fromJson(request.toJson());
        expect(parsed.name, request.name);
        expect(parsed.toJson(), {'name': 'private-consent-name'});
        expect(parsed, request);
        expect(parsed.hashCode, request.hashCode);
        expect(request.copyWith(), request);
        expect(
          request.copyWith(name: ''),
          const VoiceConsentUpdateRequest(name: ''),
        );
        expect(
          request.copyWith(name: '').hashCode,
          const VoiceConsentUpdateRequest(name: '').hashCode,
        );
        expect(request.copyWith(name: ''), isNot(request));
        expect(VoiceConsentUpdateRequest.fromJson(const {'name': ''}).name, '');
        _expectPrivateDiagnostics(request.toString(), ['name']);
      },
    );

    for (final invalid in <Map<String, dynamic>>[
      {},
      {'name': null},
      {'name': 1},
      {
        'name': {'private-name': true},
      },
    ]) {
      test('rejects missing/null/malformed name ${invalid.length}', () {
        expect(
          () => VoiceConsentUpdateRequest.fromJson(invalid),
          _safeFormat('name'),
        );
      });
    }

    test('future received metadata cannot enter closed writable request', () {
      expect(
        () => VoiceConsentUpdateRequest.fromJson(const {
          'name': 'private-consent-name',
          'private-future-key': {'private-value': true},
        }),
        _safeFormat('VoiceConsentUpdateRequest'),
      );
      expect(
        () => VoiceConsentUpdateRequest.fromJson(_consentJson()),
        _safeFormat('VoiceConsentUpdateRequest'),
      );
      final response = VoiceConsent.fromJson(
        _consentJson()..['private-future-key'] = {'private-value': true},
      );
      expect(VoiceConsentUpdateRequest(name: response.name).toJson(), {
        'name': 'private-consent-name',
      });
    });
  });

  group('VoiceConsent public response contract', () {
    test('all required fields and immutable future metadata roundtrip', () {
      final wire = _consentJson()
        ..['private-future-key'] = {
          'nested': ['private-value', 1, null],
        };
      final model = VoiceConsent.fromJson(wire);
      final roundtrip = VoiceConsent.fromJson(model.toJson());
      expect(model.object, 'audio.voice_consent');
      expect(model.id, 'private-consent-id');
      expect(model.name, 'private-consent-name');
      expect(model.language, 'private-consent-language');
      expect(model.createdAt, 1734220800);
      expect(model.toJson(), wire);
      expect(model.rawJson, wire);
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['private-future-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      wire['name'] = 'mutated';
      expect(
        (model.rawJson['private-future-key'] as Map<String, dynamic>)['nested'],
        ['private-value', 1, null],
      );
      expect(model.name, 'private-consent-name');
      _expectOwnedJson(model.rawJson);
      _expectPrivateDiagnostics(model.toString(), [
        'object',
        'id',
        'name',
        'language',
        'createdAt',
        'rawJson',
      ]);
    });

    const requiredFields = ['object', 'id', 'name', 'language', 'created_at'];
    for (final field in requiredFields) {
      test('$field is required and nonnull', () {
        expect(
          () => VoiceConsent.fromJson(_consentJson()..remove(field)),
          _safeFormat(field),
        );
        expect(
          () => VoiceConsent.fromJson(_consentJson()..[field] = null),
          _safeFormat(field),
        );
      });
      test('$field rejects malformed private values contextually', () {
        expect(
          () => VoiceConsent.fromJson(
            _consentJson()..[field] = {'private-malformed': 'private-value'},
          ),
          _safeFormat(field),
        );
      });
    }

    test('fixed object rejects unknown strings without exposing them', () {
      expect(
        () => VoiceConsent.fromJson(
          _consentJson()..['object'] = 'private-invalid',
        ),
        _safeFormat('object'),
      );
    });

    for (final value in [
      1.25,
      double.nan,
      double.infinity,
      double.negativeInfinity,
      'private-time',
    ]) {
      test('created_at rejects noninteger and nonfinite $value', () {
        expect(
          () => VoiceConsent.fromJson(_consentJson()..['created_at'] = value),
          _safeFormat('created_at'),
        );
      });
    }

    test('has no invented ID, name, language, or timestamp bounds', () {
      final model = VoiceConsent.fromJson(const {
        'object': 'audio.voice_consent',
        'id': '',
        'name': '',
        'language': 'private-open-language',
        'created_at': -1,
      });
      expect(model.id, '');
      expect(model.name, '');
      expect(model.language, 'private-open-language');
      expect(model.createdAt, -1);
    });

    test('copy exposes each typed field, fixed object, and future extras', () {
      final model = VoiceConsent.fromJson(
        _consentJson()
          ..['private-future-key'] = {
            'nested': [1, 2],
          },
      );
      final copies = [
        model.copyWith(id: 'private-changed-id'),
        model.copyWith(name: 'private-changed-name'),
        model.copyWith(language: 'private-changed-language'),
        model.copyWith(createdAt: 42),
        model.copyWith(
          rawJson: {
            'private-other-key': [3],
          },
        ),
      ];
      for (final copy in copies) {
        expect(copy, isNot(model));
        expect(copy.object, 'audio.voice_consent');
        final roundtrip = VoiceConsent.fromJson(copy.toJson());
        expect(copy, roundtrip);
        expect(copy.hashCode, roundtrip.hashCode);
      }
      expect(copies[0].id, 'private-changed-id');
      expect(copies[1].name, 'private-changed-name');
      expect(copies[2].language, 'private-changed-language');
      expect(copies[3].createdAt, 42);
      expect(copies[4].toJson()['private-other-key'], [3]);
      expect(copies[4].toJson().containsKey('private-future-key'), isFalse);
      expect(model.copyWith(rawJson: {}).toJson(), _consentJson());
      final changed = model.copyWith(name: 'private-changed-name');
      expect(changed.rawJson['name'], model.name);
      expect(changed.toJson()['name'], changed.name);
    });

    test(
      'value equality includes nested extras without depending on map order',
      () {
        final first = VoiceConsent.fromJson(
          _consentJson()
            ..['private-future-key'] = {
              'a': [
                1,
                {'b': null},
              ],
              'c': true,
            },
        );
        final second = VoiceConsent.fromJson({
          'private-future-key': const {
            'c': true,
            'a': [
              1,
              {'b': null},
            ],
          },
          ..._consentJson(),
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
  });

  group('VoiceConsentList exact public page contract', () {
    const cursorStates = ['absent', 'null', 'value'];
    for (final first in cursorStates) {
      for (final last in cursorStates) {
        test(
          'preserves first_id $first and last_id $last through copy/roundtrip',
          () {
            final wire = _listJson();
            if (first != 'absent') {
              wire['first_id'] = first == 'null' ? null : 'private-first';
            }
            if (last != 'absent') {
              wire['last_id'] = last == 'null' ? null : 'private-last';
            }
            final model = VoiceConsentList.fromJson(wire);
            final copy = model.copyWith();
            final roundtrip = VoiceConsentList.fromJson(copy.toJson());
            expect(model.object, 'list');
            expect(model.data, [VoiceConsent.fromJson(_consentJson())]);
            expect(model.hasMore, isTrue);
            expect(model.hasFirstId, first != 'absent');
            expect(model.hasLastId, last != 'absent');
            expect(model.firstId, first == 'value' ? 'private-first' : null);
            expect(model.lastId, last == 'value' ? 'private-last' : null);
            expect(copy.toJson(), wire);
            expect(copy, model);
            expect(copy.hashCode, model.hashCode);
            expect(roundtrip, model);
            expect(roundtrip.hashCode, model.hashCode);
          },
        );
      }
    }

    test('constructs nullable cursor presence without inferred IDs', () {
      final model = VoiceConsentList(
        data: [VoiceConsent.fromJson(_consentJson())],
        hasMore: false,
        hasFirstId: true,
      );
      expect(model.toJson(), {
        ..._listJson(),
        'has_more': false,
        'first_id': null,
      });
      expect(model.firstId, isNull);
      expect(model.lastId, isNull);
      expect(model.hasFirstId, isTrue);
      expect(model.hasLastId, isFalse);
      final value = VoiceConsentList(
        data: const [],
        hasMore: false,
        firstId: 'private-first',
      );
      expect(value.hasFirstId, isTrue);
      expect(value.toJson()['first_id'], 'private-first');
    });

    test(
      'copies every field and independently clears null versus omission',
      () {
        final model = VoiceConsentList.fromJson(
          _listJson()
            ..['first_id'] = 'private-first'
            ..['last_id'] = 'private-last'
            ..['private-future-key'] = {
              'nested': [1],
            },
        );
        final nulled = model.copyWith(firstId: null, lastId: null);
        expect(nulled.hasFirstId, isTrue);
        expect(nulled.hasLastId, isTrue);
        expect(nulled.toJson()['first_id'], isNull);
        expect(nulled.toJson()['last_id'], isNull);
        expect(nulled.toJson().containsKey('first_id'), isTrue);
        expect(nulled.toJson().containsKey('last_id'), isTrue);
        final absent = model.copyWith(
          firstId: null,
          lastId: null,
          hasFirstId: false,
          hasLastId: false,
        );
        expect(absent.hasFirstId, isFalse);
        expect(absent.hasLastId, isFalse);
        expect(absent.toJson().containsKey('first_id'), isFalse);
        expect(absent.toJson().containsKey('last_id'), isFalse);
        expect(absent, isNot(nulled));
        expect(absent.copyWith().toJson(), absent.toJson());
        expect(nulled.copyWith().toJson(), nulled.toJson());
        final replaced = absent.copyWith(
          data: [],
          hasMore: false,
          firstId: 'private-new-first',
          lastId: 'private-new-last',
          rawJson: {'private-other-key': true},
        );
        expect(replaced.data, isEmpty);
        expect(replaced.hasMore, isFalse);
        expect(replaced.firstId, 'private-new-first');
        expect(replaced.lastId, 'private-new-last');
        expect(replaced.hasFirstId, isTrue);
        expect(replaced.hasLastId, isTrue);
        expect(replaced.toJson()['private-other-key'], isTrue);
        expect(replaced.toJson().containsKey('private-future-key'), isFalse);
        expect(absent.copyWith(rawJson: {}).toJson(), _listJson());
        for (final copy in [nulled, absent, replaced]) {
          final roundtrip = VoiceConsentList.fromJson(copy.toJson());
          expect(copy, roundtrip);
          expect(copy.hashCode, roundtrip.hashCode);
        }
        expect(model.copyWith(hasMore: false), isNot(model));
        expect(model.copyWith(data: []), isNot(model));
        expect(model.copyWith(firstId: 'private-changed'), isNot(model));
        expect(model.copyWith(lastId: 'private-changed'), isNot(model));
        expect(absent.copyWith(hasFirstId: true), isNot(absent));
        expect(absent.copyWith(hasLastId: true), isNot(absent));
        expect(
          () => model.copyWith(firstId: {'private-bad': true}),
          _safeFormat('first_id'),
        );
        expect(
          () => model.copyWith(lastId: ['private-bad']),
          _safeFormat('last_id'),
        );
      },
    );

    test(
      'owns data, parent extras, and child extras in parsed/constructed pages',
      () {
        final child = _consentJson()
          ..['private-child-key'] = {
            'nested': [1],
          };
        final wire = {
          ..._listJson(),
          'data': [child],
          'private-future-key': {
            'nested': [1, null],
          },
        };
        final model = VoiceConsentList.fromJson(wire);
        (child['private-child-key'] as Map<String, dynamic>)['nested'] = [9];
        (wire['data'] as List<dynamic>).clear();
        (wire['private-future-key'] as Map<String, dynamic>)['nested'] = [9];
        expect(model.data, hasLength(1));
        expect(model.data.single.toJson()['private-child-key'], {
          'nested': [1],
        });
        expect(model.toJson()['private-future-key'], {
          'nested': [1, null],
        });
        expect(model.data.clear, throwsUnsupportedError);
        _expectOwnedJson(model.rawJson);
        final input = [model.data.single];
        final constructed = VoiceConsentList(data: input, hasMore: false);
        input.clear();
        expect(constructed.data, hasLength(1));
        expect(constructed.data.clear, throwsUnsupportedError);
        _expectPrivateDiagnostics(model.toString(), [
          'object',
          'data',
          'hasMore',
          'firstId',
          'lastId',
          'hasFirstId',
          'hasLastId',
          'rawJson',
        ]);
      },
    );

    test('fresh child replacements discard stale parent child metadata', () {
      final model = VoiceConsentList.fromJson({
        ..._listJson(),
        'data': [
          _consentJson()
            ..['private-child-key'] = {
              'nested': [1],
            },
        ],
      });
      final replacement = VoiceConsent.fromJson(
        _consentJson()..['private-replacement-key'] = [2],
      );
      final copied = model.copyWith(data: [replacement]);
      final child =
          (copied.toJson()['data'] as List<dynamic>).single
              as Map<String, dynamic>;
      expect(child['private-replacement-key'], [2]);
      expect(child.containsKey('private-child-key'), isFalse);
      expect(copied.data, [replacement]);
      expect(copied, VoiceConsentList.fromJson(copied.toJson()));
    });

    for (final field in ['object', 'data', 'has_more']) {
      test('$field is required, nonnull, and type checked', () {
        expect(
          () => VoiceConsentList.fromJson(_listJson()..remove(field)),
          _safeFormat(field),
        );
        expect(
          () => VoiceConsentList.fromJson(_listJson()..[field] = null),
          _safeFormat(field),
        );
        expect(
          () => VoiceConsentList.fromJson(
            _listJson()..[field] = 'private-malformed',
          ),
          _safeFormat(field),
        );
      });
    }
    for (final field in ['first_id', 'last_id']) {
      test('$field rejects malformed present values safely', () {
        expect(
          () => VoiceConsentList.fromJson(
            _listJson()..[field] = ['private-malformed'],
          ),
          _safeFormat(field),
        );
      });
    }

    test('malformed child has indexed field context', () {
      expect(
        () => VoiceConsentList.fromJson(
          _listJson()..['data'] = ['private-malformed'],
        ),
        _safeFormat('VoiceConsentList.data[0]'),
      );
      for (final field in ['object', 'id', 'name', 'language', 'created_at']) {
        expect(
          () => VoiceConsentList.fromJson(
            _listJson()..['data'] = [_consentJson()..remove(field)],
          ),
          _safeFormat('VoiceConsentList.data[0].$field'),
        );
      }
      expect(
        () => VoiceConsentList.fromJson(
          _listJson()..['data'] = [_consentJson()..['created_at'] = double.nan],
        ),
        _safeFormat('VoiceConsentList.data[0].created_at'),
      );
    });

    test(
      'cursor presence, child values, and nested extras affect value identity',
      () {
        final absent = VoiceConsentList.fromJson(_listJson());
        final nullFirst = VoiceConsentList.fromJson(
          _listJson()..['first_id'] = null,
        );
        final nullLast = VoiceConsentList.fromJson(
          _listJson()..['last_id'] = null,
        );
        expect({absent, nullFirst, nullLast}, hasLength(3));
        final changed = absent.copyWith(
          data: [absent.data.single.copyWith(name: 'private-changed')],
        );
        expect(changed, isNot(absent));
        final extra = absent.copyWith(
          rawJson: {
            'private-future-key': {
              'nested': [1],
            },
          },
        );
        final same = VoiceConsentList.fromJson(extra.toJson());
        expect(extra, same);
        expect(extra.hashCode, same.hashCode);
        expect(
          extra.copyWith(
            rawJson: {
              'private-future-key': {
                'nested': [2],
              },
            },
          ),
          isNot(extra),
        );
      },
    );
  });

  group('VoiceConsentDeleted exact public response contract', () {
    for (final deleted in [false, true]) {
      test(
        'preserves required deletion boolean $deleted and immutable extras',
        () {
          final wire = _deletedJson()
            ..['deleted'] = deleted
            ..['private-future-key'] = {
              'nested': ['private-value', null],
            };
          final model = VoiceConsentDeleted.fromJson(wire);
          final roundtrip = VoiceConsentDeleted.fromJson(model.toJson());
          expect(model.object, 'audio.voice_consent');
          expect(model.id, 'private-consent-id');
          expect(model.deleted, deleted);
          expect(model.toJson(), wire);
          expect(model, roundtrip);
          expect(model.hashCode, roundtrip.hashCode);
          expect(model.copyWith(), model);
          (wire['private-future-key'] as Map<String, dynamic>)['nested'] = [
            'mutated',
          ];
          expect(model.toJson()['private-future-key'], {
            'nested': ['private-value', null],
          });
          _expectOwnedJson(model.rawJson);
          _expectPrivateDiagnostics(model.toString(), [
            'object',
            'id',
            'deleted',
            'rawJson',
          ]);
        },
      );
    }

    for (final field in ['object', 'id', 'deleted']) {
      test('$field is required, nonnull, and malformed values are safe', () {
        expect(
          () => VoiceConsentDeleted.fromJson(_deletedJson()..remove(field)),
          _safeFormat(field),
        );
        expect(
          () => VoiceConsentDeleted.fromJson(_deletedJson()..[field] = null),
          _safeFormat(field),
        );
        expect(
          () => VoiceConsentDeleted.fromJson(
            _deletedJson()..[field] = {'private-invalid': true},
          ),
          _safeFormat(field),
        );
      });
    }

    test('object is fixed while deleted false is a valid copy value', () {
      expect(
        () => VoiceConsentDeleted.fromJson(
          _deletedJson()..['object'] = 'private-invalid',
        ),
        _safeFormat('object'),
      );
      final model = VoiceConsentDeleted.fromJson(
        _deletedJson()
          ..['deleted'] = true
          ..['private-future-key'] = {
            'nested': [1],
          },
      );
      final changed = model.copyWith(
        id: 'private-new-id',
        deleted: false,
        rawJson: {
          'private-other-key': [2],
        },
      );
      expect(changed.object, 'audio.voice_consent');
      expect(changed.id, 'private-new-id');
      expect(changed.deleted, isFalse);
      expect(changed.toJson()['deleted'], isFalse);
      expect(changed.toJson()['private-other-key'], [2]);
      expect(changed.toJson().containsKey('private-future-key'), isFalse);
      expect(changed, VoiceConsentDeleted.fromJson(changed.toJson()));
      expect(
        changed.hashCode,
        VoiceConsentDeleted.fromJson(changed.toJson()).hashCode,
      );
      expect(model.copyWith(deleted: false), isNot(model));
      expect(model.copyWith(id: ''), isNot(model));
      expect(model.copyWith(rawJson: {}).toJson(), {
        ..._deletedJson(),
        'deleted': true,
      });
      expect(
        model.copyWith(
          rawJson: {
            'private-future-key': {
              'nested': [2],
            },
          },
        ),
        isNot(model),
      );
    });
  });

  group('Voice consent receive-only JSON admission and diagnostics', () {
    test('direct constructors and copies own immutable supplied metadata', () {
      final raw = <String, dynamic>{
        'private-future-key': {
          'nested': ['private-value', null],
        },
      };
      final consent = VoiceConsent(
        id: 'private-consent-id',
        name: 'private-consent-name',
        language: 'private-consent-language',
        createdAt: 1734220800,
        rawJson: raw,
      );
      final page = VoiceConsentList(
        data: [consent],
        hasMore: false,
        rawJson: raw,
      );
      final deletion = VoiceConsentDeleted(
        id: 'private-consent-id',
        deleted: false,
        rawJson: raw,
      );
      final consentCopy = consent.copyWith(rawJson: raw);
      final pageCopy = page.copyWith(rawJson: raw);
      final deletionCopy = deletion.copyWith(rawJson: raw);
      (raw['private-future-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      for (final snapshot in [
        consent.rawJson,
        page.rawJson,
        deletion.rawJson,
        consentCopy.rawJson,
        pageCopy.rawJson,
        deletionCopy.rawJson,
      ]) {
        expect(snapshot['private-future-key'], {
          'nested': ['private-value', null],
        });
        _expectOwnedJson(snapshot);
      }
    });

    final factories = <String, Object Function(Map<String, dynamic>)>{
      'VoiceConsent': VoiceConsent.fromJson,
      'VoiceConsentList': VoiceConsentList.fromJson,
      'VoiceConsentDeleted': VoiceConsentDeleted.fromJson,
    };
    final fixtures = <String, Map<String, dynamic> Function()>{
      'VoiceConsent': _consentJson,
      'VoiceConsentList': _listJson,
      'VoiceConsentDeleted': _deletedJson,
    };
    for (final entry in factories.entries) {
      test(
        '${entry.key} rejects cyclic, nonfinite, and non-JSON extras safely',
        () {
          final cycle = <String, dynamic>{};
          cycle['private-cycle-key'] = cycle;
          for (final invalid in [
            cycle,
            double.nan,
            Object(),
            {1: 'private-value'},
          ]) {
            expect(
              () => entry.value(
                fixtures[entry.key]!()..['private-future-key'] = invalid,
              ),
              _safeFormat(entry.key),
            );
          }
        },
      );
    }
  });
}
