import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

// Source-derived fixtures cover the public field contracts, not private helpers.
Map<String, dynamic> fixture(String type) =>
    jsonDecode(_wireFixtures[type]!) as Map<String, dynamic>;
final _wireFixtures = <String, String>{
  'TranscriptionResponse':
      '{"text":"private-fixture","languages":[{"code":"private-fixture-lang"}],"logprobs":[{"token":"private-fixture-token","bytes":[1,2.5],"logprob":-0.3}],"usage":{"type":"tokens","input_tokens":2,"output_tokens":3,"total_tokens":5,"input_token_details":{"audio_tokens":1,"text_tokens":1}}}',
  'TranscriptionVerboseResponse':
      '{"task":"private-fixture-task","language":"private-fixture-lang","duration":1.25,"text":"private-fixture","segments":[{"id":1,"seek":2,"start":0.25,"end":1.25,"text":"private-fixture","tokens":[1,2],"temperature":0.4,"avg_logprob":-0.5,"compression_ratio":1.5,"no_speech_prob":0.05}],"words":[{"word":"private-fixture-word","start":0.25,"end":1.25}],"usage":{"type":"duration","seconds":1.25}}',
  'TranscriptionDiarizedResponse':
      '{"task":"transcribe","duration":1.25,"text":"private-fixture","segments":[{"type":"transcript.text.segment","id":"private-fixture-id","start":0.25,"end":1.25,"text":"private-fixture","speaker":"private-fixture-speaker"}],"usage":{"type":"tokens","input_tokens":2,"output_tokens":3,"total_tokens":5,"input_token_details":{"audio_tokens":1,"text_tokens":1}}}',
  'TranscriptionDiarizedSegment':
      '{"type":"transcript.text.segment","id":"private-fixture-id","start":0.25,"end":1.25,"text":"private-fixture","speaker":"private-fixture-speaker"}',
  'TranscriptTextSegmentEvent':
      '{"type":"transcript.text.segment","id":"private-fixture-id","start":0.25,"end":1.25,"text":"private-fixture","speaker":"private-fixture-speaker"}',
  'TranscriptTextDeltaEvent':
      '{"type":"transcript.text.delta","delta":"private-fixture","logprobs":[{"token":"private-fixture-token","bytes":[1,2],"logprob":-0.3}],"segment_id":"private-fixture-id"}',
  'TranscriptTextDoneEvent':
      '{"type":"transcript.text.done","text":"private-fixture","languages":[{"code":"private-fixture-lang"}],"logprobs":[{"token":"private-fixture-token","bytes":[1,2],"logprob":-0.3}],"usage":{"type":"tokens","input_tokens":2,"output_tokens":3,"total_tokens":5,"input_token_details":{"audio_tokens":1,"text_tokens":1}}}',
  'TranscriptTextUsageTokens':
      '{"type":"tokens","input_tokens":2,"output_tokens":3,"total_tokens":5,"input_token_details":{"audio_tokens":1,"text_tokens":1}}',
  'TranscriptUsageInputTokenDetails': '{"audio_tokens":1,"text_tokens":1}',
  'TranscriptTextUsageDuration': '{"type":"duration","seconds":1.25}',
  'TranscriptionLanguage': '{"code":"private-fixture-lang"}',
  'TranscriptionLogprob':
      '{"token":"private-fixture-token","bytes":[1,2.5],"logprob":-0.3}',
  'TranscriptionSegment':
      '{"id":1,"seek":2,"start":0.25,"end":1.25,"text":"private-fixture","tokens":[1,2],"temperature":0.4,"avg_logprob":-0.5,"compression_ratio":1.5,"no_speech_prob":0.05}',
  'TranscriptionWord':
      '{"word":"private-fixture-word","start":0.25,"end":1.25}',
  'TranslationResponse': '{"text":"private-fixture"}',
  'TranslationVerboseResponse':
      '{"task":"private-fixture-task","language":"English","duration":1.25,"text":"private-fixture","segments":[{"id":1,"seek":2,"start":0.25,"end":1.25,"text":"private-fixture","tokens":[1,2],"temperature":0.4,"avg_logprob":-0.5,"compression_ratio":1.5,"no_speech_prob":0.05}]}',
};

void main() {
  group('TranscriptionResponse public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranscriptionResponse');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranscriptionResponse.fromJson(wire);
      final roundtrip = TranscriptionResponse.fromJson(model.toJson());
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('text rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionResponse')..['text'] = null;
      expect(
        () => TranscriptionResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('text'),
          ),
        ),
      );
      wire['text'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('text is required', () {
      expect(
        () => TranscriptionResponse.fromJson(
          fixture('TranscriptionResponse')..remove('text'),
        ),
        throwsFormatException,
      );
    });
    test('text participates in copy and effective value identity', () {
      final model = TranscriptionResponse.fromJson(
        fixture('TranscriptionResponse'),
      );
      final changed = TranscriptionResponse.fromJson(
        fixture('TranscriptionResponse')
          ..['text'] = jsonDecode('"private-fixture-changed"'),
      );
      final copied = model.copyWith(text: changed.text);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('languages rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionResponse')..['languages'] = null;
      expect(
        () => TranscriptionResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('languages'),
          ),
        ),
      );
      wire['languages'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'languages omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptionResponse.fromJson(
          fixture('TranscriptionResponse'),
        );
        final cleared = model.copyWith(languages: null);
        expect(cleared.languages, isNull);
        expect(cleared.toJson().containsKey('languages'), isFalse);
        expect(
          TranscriptionResponse.fromJson(
            fixture('TranscriptionResponse')..remove('languages'),
          ).languages,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('languages participates in copy and effective value identity', () {
      final model = TranscriptionResponse.fromJson(
        fixture('TranscriptionResponse'),
      );
      final changed = TranscriptionResponse.fromJson(
        fixture('TranscriptionResponse')..['languages'] = jsonDecode('[]'),
      );
      final copied = model.copyWith(languages: changed.languages);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('logprobs rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionResponse')..['logprobs'] = null;
      expect(
        () => TranscriptionResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('logprobs'),
          ),
        ),
      );
      wire['logprobs'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'logprobs omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptionResponse.fromJson(
          fixture('TranscriptionResponse'),
        );
        final cleared = model.copyWith(logprobs: null);
        expect(cleared.logprobs, isNull);
        expect(cleared.toJson().containsKey('logprobs'), isFalse);
        expect(
          TranscriptionResponse.fromJson(
            fixture('TranscriptionResponse')..remove('logprobs'),
          ).logprobs,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('logprobs participates in copy and effective value identity', () {
      final model = TranscriptionResponse.fromJson(
        fixture('TranscriptionResponse'),
      );
      final changed = TranscriptionResponse.fromJson(
        fixture('TranscriptionResponse')..['logprobs'] = jsonDecode('[]'),
      );
      final copied = model.copyWith(logprobs: changed.logprobs);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('usage rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionResponse')..['usage'] = null;
      expect(
        () => TranscriptionResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('usage'),
          ),
        ),
      );
      wire['usage'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'usage omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptionResponse.fromJson(
          fixture('TranscriptionResponse'),
        );
        final cleared = model.copyWith(usage: null);
        expect(cleared.usage, isNull);
        expect(cleared.toJson().containsKey('usage'), isFalse);
        expect(
          TranscriptionResponse.fromJson(
            fixture('TranscriptionResponse')..remove('usage'),
          ).usage,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('usage participates in copy and effective value identity', () {
      final model = TranscriptionResponse.fromJson(
        fixture('TranscriptionResponse'),
      );
      final changed = TranscriptionResponse.fromJson(
        fixture('TranscriptionResponse')
          ..['usage'] = jsonDecode(
            '{"type":"tokens","input_tokens":2,"output_tokens":3,"total_tokens":5,"input_token_details":{"audio_tokens":1,"text_tokens":1},"replacement_future":true}',
          ),
      );
      final copied = model.copyWith(usage: changed.usage);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
  });
  group('TranscriptionVerboseResponse public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranscriptionVerboseResponse');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranscriptionVerboseResponse.fromJson(wire);
      final roundtrip = TranscriptionVerboseResponse.fromJson(model.toJson());
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('task rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionVerboseResponse')..['task'] = null;
      expect(
        () => TranscriptionVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('task'),
          ),
        ),
      );
      wire['task'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'task omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptionVerboseResponse.fromJson(
          fixture('TranscriptionVerboseResponse'),
        );
        final cleared = model.copyWith(task: null);
        expect(cleared.task, isNull);
        expect(cleared.toJson().containsKey('task'), isFalse);
        expect(
          TranscriptionVerboseResponse.fromJson(
            fixture('TranscriptionVerboseResponse')..remove('task'),
          ).task,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('task participates in copy and effective value identity', () {
      final model = TranscriptionVerboseResponse.fromJson(
        fixture('TranscriptionVerboseResponse'),
      );
      final changed = TranscriptionVerboseResponse.fromJson(
        fixture('TranscriptionVerboseResponse')
          ..['task'] = jsonDecode('"private-fixture-task-changed"'),
      );
      final copied = model.copyWith(task: changed.task);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('language rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionVerboseResponse')..['language'] = null;
      expect(
        () => TranscriptionVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('language'),
          ),
        ),
      );
      wire['language'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('language is required', () {
      expect(
        () => TranscriptionVerboseResponse.fromJson(
          fixture('TranscriptionVerboseResponse')..remove('language'),
        ),
        throwsFormatException,
      );
    });
    test('language participates in copy and effective value identity', () {
      final model = TranscriptionVerboseResponse.fromJson(
        fixture('TranscriptionVerboseResponse'),
      );
      final changed = TranscriptionVerboseResponse.fromJson(
        fixture('TranscriptionVerboseResponse')
          ..['language'] = jsonDecode('"private-fixture-lang-changed"'),
      );
      final copied = model.copyWith(language: changed.language);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('duration rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionVerboseResponse')..['duration'] = null;
      expect(
        () => TranscriptionVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('duration'),
          ),
        ),
      );
      wire['duration'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('duration is required', () {
      expect(
        () => TranscriptionVerboseResponse.fromJson(
          fixture('TranscriptionVerboseResponse')..remove('duration'),
        ),
        throwsFormatException,
      );
    });
    test('duration participates in copy and effective value identity', () {
      final model = TranscriptionVerboseResponse.fromJson(
        fixture('TranscriptionVerboseResponse'),
      );
      final changed = TranscriptionVerboseResponse.fromJson(
        fixture('TranscriptionVerboseResponse')
          ..['duration'] = jsonDecode('2.25'),
      );
      final copied = model.copyWith(duration: changed.duration);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('text rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionVerboseResponse')..['text'] = null;
      expect(
        () => TranscriptionVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('text'),
          ),
        ),
      );
      wire['text'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('text is required', () {
      expect(
        () => TranscriptionVerboseResponse.fromJson(
          fixture('TranscriptionVerboseResponse')..remove('text'),
        ),
        throwsFormatException,
      );
    });
    test('text participates in copy and effective value identity', () {
      final model = TranscriptionVerboseResponse.fromJson(
        fixture('TranscriptionVerboseResponse'),
      );
      final changed = TranscriptionVerboseResponse.fromJson(
        fixture('TranscriptionVerboseResponse')
          ..['text'] = jsonDecode('"private-fixture-changed"'),
      );
      final copied = model.copyWith(text: changed.text);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('segments rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionVerboseResponse')..['segments'] = null;
      expect(
        () => TranscriptionVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('segments'),
          ),
        ),
      );
      wire['segments'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'segments omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptionVerboseResponse.fromJson(
          fixture('TranscriptionVerboseResponse'),
        );
        final cleared = model.copyWith(segments: null);
        expect(cleared.segments, isNull);
        expect(cleared.toJson().containsKey('segments'), isFalse);
        expect(
          TranscriptionVerboseResponse.fromJson(
            fixture('TranscriptionVerboseResponse')..remove('segments'),
          ).segments,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('segments participates in copy and effective value identity', () {
      final model = TranscriptionVerboseResponse.fromJson(
        fixture('TranscriptionVerboseResponse'),
      );
      final changed = TranscriptionVerboseResponse.fromJson(
        fixture('TranscriptionVerboseResponse')
          ..['segments'] = jsonDecode('[]'),
      );
      final copied = model.copyWith(segments: changed.segments);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('words rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionVerboseResponse')..['words'] = null;
      expect(
        () => TranscriptionVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('words'),
          ),
        ),
      );
      wire['words'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'words omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptionVerboseResponse.fromJson(
          fixture('TranscriptionVerboseResponse'),
        );
        final cleared = model.copyWith(words: null);
        expect(cleared.words, isNull);
        expect(cleared.toJson().containsKey('words'), isFalse);
        expect(
          TranscriptionVerboseResponse.fromJson(
            fixture('TranscriptionVerboseResponse')..remove('words'),
          ).words,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('words participates in copy and effective value identity', () {
      final model = TranscriptionVerboseResponse.fromJson(
        fixture('TranscriptionVerboseResponse'),
      );
      final changed = TranscriptionVerboseResponse.fromJson(
        fixture('TranscriptionVerboseResponse')..['words'] = jsonDecode('[]'),
      );
      final copied = model.copyWith(words: changed.words);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('usage rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionVerboseResponse')..['usage'] = null;
      expect(
        () => TranscriptionVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('usage'),
          ),
        ),
      );
      wire['usage'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'usage omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptionVerboseResponse.fromJson(
          fixture('TranscriptionVerboseResponse'),
        );
        final cleared = model.copyWith(usage: null);
        expect(cleared.usage, isNull);
        expect(cleared.toJson().containsKey('usage'), isFalse);
        expect(
          TranscriptionVerboseResponse.fromJson(
            fixture('TranscriptionVerboseResponse')..remove('usage'),
          ).usage,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('usage participates in copy and effective value identity', () {
      final model = TranscriptionVerboseResponse.fromJson(
        fixture('TranscriptionVerboseResponse'),
      );
      final changed = TranscriptionVerboseResponse.fromJson(
        fixture('TranscriptionVerboseResponse')
          ..['usage'] = jsonDecode(
            '{"type":"duration","seconds":1.25,"replacement_future":true}',
          ),
      );
      final copied = model.copyWith(usage: changed.usage);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
  });
  group('TranscriptionDiarizedResponse public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranscriptionDiarizedResponse');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranscriptionDiarizedResponse.fromJson(wire);
      final roundtrip = TranscriptionDiarizedResponse.fromJson(model.toJson());
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('task rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionDiarizedResponse')..['task'] = null;
      expect(
        () => TranscriptionDiarizedResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('task'),
          ),
        ),
      );
      wire['task'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionDiarizedResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('task is required', () {
      expect(
        () => TranscriptionDiarizedResponse.fromJson(
          fixture('TranscriptionDiarizedResponse')..remove('task'),
        ),
        throwsFormatException,
      );
    });
    test('duration rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionDiarizedResponse')
        ..['duration'] = null;
      expect(
        () => TranscriptionDiarizedResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('duration'),
          ),
        ),
      );
      wire['duration'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionDiarizedResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('duration is required', () {
      expect(
        () => TranscriptionDiarizedResponse.fromJson(
          fixture('TranscriptionDiarizedResponse')..remove('duration'),
        ),
        throwsFormatException,
      );
    });
    test('duration participates in copy and effective value identity', () {
      final model = TranscriptionDiarizedResponse.fromJson(
        fixture('TranscriptionDiarizedResponse'),
      );
      final changed = TranscriptionDiarizedResponse.fromJson(
        fixture('TranscriptionDiarizedResponse')
          ..['duration'] = jsonDecode('2.25'),
      );
      final copied = model.copyWith(duration: changed.duration);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('text rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionDiarizedResponse')..['text'] = null;
      expect(
        () => TranscriptionDiarizedResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('text'),
          ),
        ),
      );
      wire['text'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionDiarizedResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('text is required', () {
      expect(
        () => TranscriptionDiarizedResponse.fromJson(
          fixture('TranscriptionDiarizedResponse')..remove('text'),
        ),
        throwsFormatException,
      );
    });
    test('text participates in copy and effective value identity', () {
      final model = TranscriptionDiarizedResponse.fromJson(
        fixture('TranscriptionDiarizedResponse'),
      );
      final changed = TranscriptionDiarizedResponse.fromJson(
        fixture('TranscriptionDiarizedResponse')
          ..['text'] = jsonDecode('"private-fixture-changed"'),
      );
      final copied = model.copyWith(text: changed.text);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('segments rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionDiarizedResponse')
        ..['segments'] = null;
      expect(
        () => TranscriptionDiarizedResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('segments'),
          ),
        ),
      );
      wire['segments'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionDiarizedResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('segments is required', () {
      expect(
        () => TranscriptionDiarizedResponse.fromJson(
          fixture('TranscriptionDiarizedResponse')..remove('segments'),
        ),
        throwsFormatException,
      );
    });
    test('segments participates in copy and effective value identity', () {
      final model = TranscriptionDiarizedResponse.fromJson(
        fixture('TranscriptionDiarizedResponse'),
      );
      final changed = TranscriptionDiarizedResponse.fromJson(
        fixture('TranscriptionDiarizedResponse')
          ..['segments'] = jsonDecode('[]'),
      );
      final copied = model.copyWith(segments: changed.segments);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('usage rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionDiarizedResponse')..['usage'] = null;
      expect(
        () => TranscriptionDiarizedResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('usage'),
          ),
        ),
      );
      wire['usage'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionDiarizedResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'usage omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptionDiarizedResponse.fromJson(
          fixture('TranscriptionDiarizedResponse'),
        );
        final cleared = model.copyWith(usage: null);
        expect(cleared.usage, isNull);
        expect(cleared.toJson().containsKey('usage'), isFalse);
        expect(
          TranscriptionDiarizedResponse.fromJson(
            fixture('TranscriptionDiarizedResponse')..remove('usage'),
          ).usage,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('usage participates in copy and effective value identity', () {
      final model = TranscriptionDiarizedResponse.fromJson(
        fixture('TranscriptionDiarizedResponse'),
      );
      final changed = TranscriptionDiarizedResponse.fromJson(
        fixture('TranscriptionDiarizedResponse')
          ..['usage'] = jsonDecode(
            '{"type":"tokens","input_tokens":2,"output_tokens":3,"total_tokens":5,"input_token_details":{"audio_tokens":1,"text_tokens":1},"replacement_future":true}',
          ),
      );
      final copied = model.copyWith(usage: changed.usage);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
  });
  group('TranscriptionDiarizedSegment public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranscriptionDiarizedSegment');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranscriptionDiarizedSegment.fromJson(wire);
      final roundtrip = TranscriptionDiarizedSegment.fromJson(model.toJson());
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('id rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionDiarizedSegment')..['id'] = null;
      expect(
        () => TranscriptionDiarizedSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('id'),
          ),
        ),
      );
      wire['id'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionDiarizedSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('id is required', () {
      expect(
        () => TranscriptionDiarizedSegment.fromJson(
          fixture('TranscriptionDiarizedSegment')..remove('id'),
        ),
        throwsFormatException,
      );
    });
    test('id participates in copy and effective value identity', () {
      final model = TranscriptionDiarizedSegment.fromJson(
        fixture('TranscriptionDiarizedSegment'),
      );
      final changed = TranscriptionDiarizedSegment.fromJson(
        fixture('TranscriptionDiarizedSegment')
          ..['id'] = jsonDecode('"private-fixture-id-changed"'),
      );
      final copied = model.copyWith(id: changed.id);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('start rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionDiarizedSegment')..['start'] = null;
      expect(
        () => TranscriptionDiarizedSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('start'),
          ),
        ),
      );
      wire['start'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionDiarizedSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('start is required', () {
      expect(
        () => TranscriptionDiarizedSegment.fromJson(
          fixture('TranscriptionDiarizedSegment')..remove('start'),
        ),
        throwsFormatException,
      );
    });
    test('start participates in copy and effective value identity', () {
      final model = TranscriptionDiarizedSegment.fromJson(
        fixture('TranscriptionDiarizedSegment'),
      );
      final changed = TranscriptionDiarizedSegment.fromJson(
        fixture('TranscriptionDiarizedSegment')..['start'] = jsonDecode('1.25'),
      );
      final copied = model.copyWith(start: changed.start);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('end rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionDiarizedSegment')..['end'] = null;
      expect(
        () => TranscriptionDiarizedSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('end'),
          ),
        ),
      );
      wire['end'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionDiarizedSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('end is required', () {
      expect(
        () => TranscriptionDiarizedSegment.fromJson(
          fixture('TranscriptionDiarizedSegment')..remove('end'),
        ),
        throwsFormatException,
      );
    });
    test('end participates in copy and effective value identity', () {
      final model = TranscriptionDiarizedSegment.fromJson(
        fixture('TranscriptionDiarizedSegment'),
      );
      final changed = TranscriptionDiarizedSegment.fromJson(
        fixture('TranscriptionDiarizedSegment')..['end'] = jsonDecode('2.25'),
      );
      final copied = model.copyWith(end: changed.end);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('text rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionDiarizedSegment')..['text'] = null;
      expect(
        () => TranscriptionDiarizedSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('text'),
          ),
        ),
      );
      wire['text'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionDiarizedSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('text is required', () {
      expect(
        () => TranscriptionDiarizedSegment.fromJson(
          fixture('TranscriptionDiarizedSegment')..remove('text'),
        ),
        throwsFormatException,
      );
    });
    test('text participates in copy and effective value identity', () {
      final model = TranscriptionDiarizedSegment.fromJson(
        fixture('TranscriptionDiarizedSegment'),
      );
      final changed = TranscriptionDiarizedSegment.fromJson(
        fixture('TranscriptionDiarizedSegment')
          ..['text'] = jsonDecode('"private-fixture-changed"'),
      );
      final copied = model.copyWith(text: changed.text);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('speaker rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionDiarizedSegment')..['speaker'] = null;
      expect(
        () => TranscriptionDiarizedSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('speaker'),
          ),
        ),
      );
      wire['speaker'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionDiarizedSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('speaker is required', () {
      expect(
        () => TranscriptionDiarizedSegment.fromJson(
          fixture('TranscriptionDiarizedSegment')..remove('speaker'),
        ),
        throwsFormatException,
      );
    });
    test('speaker participates in copy and effective value identity', () {
      final model = TranscriptionDiarizedSegment.fromJson(
        fixture('TranscriptionDiarizedSegment'),
      );
      final changed = TranscriptionDiarizedSegment.fromJson(
        fixture('TranscriptionDiarizedSegment')
          ..['speaker'] = jsonDecode('"private-fixture-speaker-changed"'),
      );
      final copied = model.copyWith(speaker: changed.speaker);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
  });
  group('TranscriptTextSegmentEvent public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranscriptTextSegmentEvent');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranscriptTextSegmentEvent.fromJson(wire);
      final roundtrip = TranscriptTextSegmentEvent.fromJson(model.toJson());
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('id rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextSegmentEvent')..['id'] = null;
      expect(
        () => TranscriptTextSegmentEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('id'),
          ),
        ),
      );
      wire['id'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextSegmentEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('id is required', () {
      expect(
        () => TranscriptTextSegmentEvent.fromJson(
          fixture('TranscriptTextSegmentEvent')..remove('id'),
        ),
        throwsFormatException,
      );
    });
    test('id participates in copy and effective value identity', () {
      final model = TranscriptTextSegmentEvent.fromJson(
        fixture('TranscriptTextSegmentEvent'),
      );
      final changed = TranscriptTextSegmentEvent.fromJson(
        fixture('TranscriptTextSegmentEvent')
          ..['id'] = jsonDecode('"private-fixture-id-changed"'),
      );
      final copied = model.copyWith(id: changed.id);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('start rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextSegmentEvent')..['start'] = null;
      expect(
        () => TranscriptTextSegmentEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('start'),
          ),
        ),
      );
      wire['start'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextSegmentEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('start is required', () {
      expect(
        () => TranscriptTextSegmentEvent.fromJson(
          fixture('TranscriptTextSegmentEvent')..remove('start'),
        ),
        throwsFormatException,
      );
    });
    test('start participates in copy and effective value identity', () {
      final model = TranscriptTextSegmentEvent.fromJson(
        fixture('TranscriptTextSegmentEvent'),
      );
      final changed = TranscriptTextSegmentEvent.fromJson(
        fixture('TranscriptTextSegmentEvent')..['start'] = jsonDecode('1.25'),
      );
      final copied = model.copyWith(start: changed.start);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('end rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextSegmentEvent')..['end'] = null;
      expect(
        () => TranscriptTextSegmentEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('end'),
          ),
        ),
      );
      wire['end'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextSegmentEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('end is required', () {
      expect(
        () => TranscriptTextSegmentEvent.fromJson(
          fixture('TranscriptTextSegmentEvent')..remove('end'),
        ),
        throwsFormatException,
      );
    });
    test('end participates in copy and effective value identity', () {
      final model = TranscriptTextSegmentEvent.fromJson(
        fixture('TranscriptTextSegmentEvent'),
      );
      final changed = TranscriptTextSegmentEvent.fromJson(
        fixture('TranscriptTextSegmentEvent')..['end'] = jsonDecode('2.25'),
      );
      final copied = model.copyWith(end: changed.end);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('text rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextSegmentEvent')..['text'] = null;
      expect(
        () => TranscriptTextSegmentEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('text'),
          ),
        ),
      );
      wire['text'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextSegmentEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('text is required', () {
      expect(
        () => TranscriptTextSegmentEvent.fromJson(
          fixture('TranscriptTextSegmentEvent')..remove('text'),
        ),
        throwsFormatException,
      );
    });
    test('text participates in copy and effective value identity', () {
      final model = TranscriptTextSegmentEvent.fromJson(
        fixture('TranscriptTextSegmentEvent'),
      );
      final changed = TranscriptTextSegmentEvent.fromJson(
        fixture('TranscriptTextSegmentEvent')
          ..['text'] = jsonDecode('"private-fixture-changed"'),
      );
      final copied = model.copyWith(text: changed.text);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('speaker rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextSegmentEvent')..['speaker'] = null;
      expect(
        () => TranscriptTextSegmentEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('speaker'),
          ),
        ),
      );
      wire['speaker'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextSegmentEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('speaker is required', () {
      expect(
        () => TranscriptTextSegmentEvent.fromJson(
          fixture('TranscriptTextSegmentEvent')..remove('speaker'),
        ),
        throwsFormatException,
      );
    });
    test('speaker participates in copy and effective value identity', () {
      final model = TranscriptTextSegmentEvent.fromJson(
        fixture('TranscriptTextSegmentEvent'),
      );
      final changed = TranscriptTextSegmentEvent.fromJson(
        fixture('TranscriptTextSegmentEvent')
          ..['speaker'] = jsonDecode('"private-fixture-speaker-changed"'),
      );
      final copied = model.copyWith(speaker: changed.speaker);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
  });
  group('TranscriptTextDeltaEvent public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranscriptTextDeltaEvent');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranscriptTextDeltaEvent.fromJson(wire);
      final roundtrip = TranscriptTextDeltaEvent.fromJson(model.toJson());
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('delta rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextDeltaEvent')..['delta'] = null;
      expect(
        () => TranscriptTextDeltaEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('delta'),
          ),
        ),
      );
      wire['delta'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextDeltaEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('delta is required', () {
      expect(
        () => TranscriptTextDeltaEvent.fromJson(
          fixture('TranscriptTextDeltaEvent')..remove('delta'),
        ),
        throwsFormatException,
      );
    });
    test('delta participates in copy and effective value identity', () {
      final model = TranscriptTextDeltaEvent.fromJson(
        fixture('TranscriptTextDeltaEvent'),
      );
      final changed = TranscriptTextDeltaEvent.fromJson(
        fixture('TranscriptTextDeltaEvent')
          ..['delta'] = jsonDecode('"private-fixture-changed"'),
      );
      final copied = model.copyWith(delta: changed.delta);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('logprobs rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextDeltaEvent')..['logprobs'] = null;
      expect(
        () => TranscriptTextDeltaEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('logprobs'),
          ),
        ),
      );
      wire['logprobs'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextDeltaEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'logprobs omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptTextDeltaEvent.fromJson(
          fixture('TranscriptTextDeltaEvent'),
        );
        final cleared = model.copyWith(logprobs: null);
        expect(cleared.logprobs, isNull);
        expect(cleared.toJson().containsKey('logprobs'), isFalse);
        expect(
          TranscriptTextDeltaEvent.fromJson(
            fixture('TranscriptTextDeltaEvent')..remove('logprobs'),
          ).logprobs,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('logprobs participates in copy and effective value identity', () {
      final model = TranscriptTextDeltaEvent.fromJson(
        fixture('TranscriptTextDeltaEvent'),
      );
      final changed = TranscriptTextDeltaEvent.fromJson(
        fixture('TranscriptTextDeltaEvent')..['logprobs'] = jsonDecode('[]'),
      );
      final copied = model.copyWith(logprobs: changed.logprobs);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('segment_id rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextDeltaEvent')..['segment_id'] = null;
      expect(
        () => TranscriptTextDeltaEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('segment_id'),
          ),
        ),
      );
      wire['segment_id'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextDeltaEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'segment_id omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptTextDeltaEvent.fromJson(
          fixture('TranscriptTextDeltaEvent'),
        );
        final cleared = model.copyWith(segmentId: null);
        expect(cleared.segmentId, isNull);
        expect(cleared.toJson().containsKey('segment_id'), isFalse);
        expect(
          TranscriptTextDeltaEvent.fromJson(
            fixture('TranscriptTextDeltaEvent')..remove('segment_id'),
          ).segmentId,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('segment_id participates in copy and effective value identity', () {
      final model = TranscriptTextDeltaEvent.fromJson(
        fixture('TranscriptTextDeltaEvent'),
      );
      final changed = TranscriptTextDeltaEvent.fromJson(
        fixture('TranscriptTextDeltaEvent')
          ..['segment_id'] = jsonDecode('"private-fixture-id-changed"'),
      );
      final copied = model.copyWith(segmentId: changed.segmentId);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
  });
  group('TranscriptTextDoneEvent public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranscriptTextDoneEvent');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranscriptTextDoneEvent.fromJson(wire);
      final roundtrip = TranscriptTextDoneEvent.fromJson(model.toJson());
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('text rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextDoneEvent')..['text'] = null;
      expect(
        () => TranscriptTextDoneEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('text'),
          ),
        ),
      );
      wire['text'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextDoneEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('text is required', () {
      expect(
        () => TranscriptTextDoneEvent.fromJson(
          fixture('TranscriptTextDoneEvent')..remove('text'),
        ),
        throwsFormatException,
      );
    });
    test('text participates in copy and effective value identity', () {
      final model = TranscriptTextDoneEvent.fromJson(
        fixture('TranscriptTextDoneEvent'),
      );
      final changed = TranscriptTextDoneEvent.fromJson(
        fixture('TranscriptTextDoneEvent')
          ..['text'] = jsonDecode('"private-fixture-changed"'),
      );
      final copied = model.copyWith(text: changed.text);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('languages rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextDoneEvent')..['languages'] = null;
      expect(
        () => TranscriptTextDoneEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('languages'),
          ),
        ),
      );
      wire['languages'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextDoneEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'languages omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptTextDoneEvent.fromJson(
          fixture('TranscriptTextDoneEvent'),
        );
        final cleared = model.copyWith(languages: null);
        expect(cleared.languages, isNull);
        expect(cleared.toJson().containsKey('languages'), isFalse);
        expect(
          TranscriptTextDoneEvent.fromJson(
            fixture('TranscriptTextDoneEvent')..remove('languages'),
          ).languages,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('languages participates in copy and effective value identity', () {
      final model = TranscriptTextDoneEvent.fromJson(
        fixture('TranscriptTextDoneEvent'),
      );
      final changed = TranscriptTextDoneEvent.fromJson(
        fixture('TranscriptTextDoneEvent')..['languages'] = jsonDecode('[]'),
      );
      final copied = model.copyWith(languages: changed.languages);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('logprobs rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextDoneEvent')..['logprobs'] = null;
      expect(
        () => TranscriptTextDoneEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('logprobs'),
          ),
        ),
      );
      wire['logprobs'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextDoneEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'logprobs omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptTextDoneEvent.fromJson(
          fixture('TranscriptTextDoneEvent'),
        );
        final cleared = model.copyWith(logprobs: null);
        expect(cleared.logprobs, isNull);
        expect(cleared.toJson().containsKey('logprobs'), isFalse);
        expect(
          TranscriptTextDoneEvent.fromJson(
            fixture('TranscriptTextDoneEvent')..remove('logprobs'),
          ).logprobs,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('logprobs participates in copy and effective value identity', () {
      final model = TranscriptTextDoneEvent.fromJson(
        fixture('TranscriptTextDoneEvent'),
      );
      final changed = TranscriptTextDoneEvent.fromJson(
        fixture('TranscriptTextDoneEvent')..['logprobs'] = jsonDecode('[]'),
      );
      final copied = model.copyWith(logprobs: changed.logprobs);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('usage rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextDoneEvent')..['usage'] = null;
      expect(
        () => TranscriptTextDoneEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('usage'),
          ),
        ),
      );
      wire['usage'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextDoneEvent.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'usage omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptTextDoneEvent.fromJson(
          fixture('TranscriptTextDoneEvent'),
        );
        final cleared = model.copyWith(usage: null);
        expect(cleared.usage, isNull);
        expect(cleared.toJson().containsKey('usage'), isFalse);
        expect(
          TranscriptTextDoneEvent.fromJson(
            fixture('TranscriptTextDoneEvent')..remove('usage'),
          ).usage,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('usage participates in copy and effective value identity', () {
      final model = TranscriptTextDoneEvent.fromJson(
        fixture('TranscriptTextDoneEvent'),
      );
      final changed = TranscriptTextDoneEvent.fromJson(
        fixture('TranscriptTextDoneEvent')
          ..['usage'] = jsonDecode(
            '{"type":"tokens","input_tokens":2,"output_tokens":3,"total_tokens":5,"input_token_details":{"audio_tokens":1,"text_tokens":1},"replacement_future":true}',
          ),
      );
      final copied = model.copyWith(usage: changed.usage);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
  });
  group('TranscriptTextUsageTokens public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranscriptTextUsageTokens');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranscriptTextUsageTokens.fromJson(wire);
      final roundtrip = TranscriptTextUsageTokens.fromJson(model.toJson());
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('input_tokens rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextUsageTokens')
        ..['input_tokens'] = null;
      expect(
        () => TranscriptTextUsageTokens.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('input_tokens'),
          ),
        ),
      );
      wire['input_tokens'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextUsageTokens.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('input_tokens is required', () {
      expect(
        () => TranscriptTextUsageTokens.fromJson(
          fixture('TranscriptTextUsageTokens')..remove('input_tokens'),
        ),
        throwsFormatException,
      );
    });
    test('input_tokens participates in copy and effective value identity', () {
      final model = TranscriptTextUsageTokens.fromJson(
        fixture('TranscriptTextUsageTokens'),
      );
      final changed = TranscriptTextUsageTokens.fromJson(
        fixture('TranscriptTextUsageTokens')
          ..['input_tokens'] = jsonDecode('3'),
      );
      final copied = model.copyWith(inputTokens: changed.inputTokens);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('output_tokens rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextUsageTokens')
        ..['output_tokens'] = null;
      expect(
        () => TranscriptTextUsageTokens.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('output_tokens'),
          ),
        ),
      );
      wire['output_tokens'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextUsageTokens.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('output_tokens is required', () {
      expect(
        () => TranscriptTextUsageTokens.fromJson(
          fixture('TranscriptTextUsageTokens')..remove('output_tokens'),
        ),
        throwsFormatException,
      );
    });
    test('output_tokens participates in copy and effective value identity', () {
      final model = TranscriptTextUsageTokens.fromJson(
        fixture('TranscriptTextUsageTokens'),
      );
      final changed = TranscriptTextUsageTokens.fromJson(
        fixture('TranscriptTextUsageTokens')
          ..['output_tokens'] = jsonDecode('4'),
      );
      final copied = model.copyWith(outputTokens: changed.outputTokens);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('total_tokens rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextUsageTokens')
        ..['total_tokens'] = null;
      expect(
        () => TranscriptTextUsageTokens.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('total_tokens'),
          ),
        ),
      );
      wire['total_tokens'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextUsageTokens.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('total_tokens is required', () {
      expect(
        () => TranscriptTextUsageTokens.fromJson(
          fixture('TranscriptTextUsageTokens')..remove('total_tokens'),
        ),
        throwsFormatException,
      );
    });
    test('total_tokens participates in copy and effective value identity', () {
      final model = TranscriptTextUsageTokens.fromJson(
        fixture('TranscriptTextUsageTokens'),
      );
      final changed = TranscriptTextUsageTokens.fromJson(
        fixture('TranscriptTextUsageTokens')
          ..['total_tokens'] = jsonDecode('6'),
      );
      final copied = model.copyWith(totalTokens: changed.totalTokens);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test(
      'input_token_details rejects malformed values without exposing content',
      () {
        final wire = fixture('TranscriptTextUsageTokens')
          ..['input_token_details'] = null;
        expect(
          () => TranscriptTextUsageTokens.fromJson(wire),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'context',
              contains('input_token_details'),
            ),
          ),
        );
        wire['input_token_details'] = 'private-fixture';
        expect(
          () => TranscriptTextUsageTokens.fromJson(wire),
          throwsA(
            isA<FormatException>().having(
              (error) => error.toString(),
              'private',
              isNot(contains('private-fixture')),
            ),
          ),
        );
      },
    );
    test(
      'input_token_details omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptTextUsageTokens.fromJson(
          fixture('TranscriptTextUsageTokens'),
        );
        final cleared = model.copyWith(inputTokenDetails: null);
        expect(cleared.inputTokenDetails, isNull);
        expect(cleared.toJson().containsKey('input_token_details'), isFalse);
        expect(
          TranscriptTextUsageTokens.fromJson(
            fixture('TranscriptTextUsageTokens')..remove('input_token_details'),
          ).inputTokenDetails,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test(
      'input_token_details participates in copy and effective value identity',
      () {
        final model = TranscriptTextUsageTokens.fromJson(
          fixture('TranscriptTextUsageTokens'),
        );
        final changed = TranscriptTextUsageTokens.fromJson(
          fixture('TranscriptTextUsageTokens')
            ..['input_token_details'] = jsonDecode(
              '{"audio_tokens":1,"text_tokens":1,"replacement_future":true}',
            ),
        );
        final copied = model.copyWith(
          inputTokenDetails: changed.inputTokenDetails,
        );
        expect(copied, changed);
        expect(copied.hashCode, changed.hashCode);
        expect(copied, isNot(model));
      },
    );
  });
  group('TranscriptUsageInputTokenDetails public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranscriptUsageInputTokenDetails');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranscriptUsageInputTokenDetails.fromJson(wire);
      final roundtrip = TranscriptUsageInputTokenDetails.fromJson(
        model.toJson(),
      );
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('audio_tokens rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptUsageInputTokenDetails')
        ..['audio_tokens'] = null;
      expect(
        () => TranscriptUsageInputTokenDetails.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('audio_tokens'),
          ),
        ),
      );
      wire['audio_tokens'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptUsageInputTokenDetails.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'audio_tokens omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptUsageInputTokenDetails.fromJson(
          fixture('TranscriptUsageInputTokenDetails'),
        );
        final cleared = model.copyWith(audioTokens: null);
        expect(cleared.audioTokens, isNull);
        expect(cleared.toJson().containsKey('audio_tokens'), isFalse);
        expect(
          TranscriptUsageInputTokenDetails.fromJson(
            fixture('TranscriptUsageInputTokenDetails')..remove('audio_tokens'),
          ).audioTokens,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('audio_tokens participates in copy and effective value identity', () {
      final model = TranscriptUsageInputTokenDetails.fromJson(
        fixture('TranscriptUsageInputTokenDetails'),
      );
      final changed = TranscriptUsageInputTokenDetails.fromJson(
        fixture('TranscriptUsageInputTokenDetails')
          ..['audio_tokens'] = jsonDecode('2'),
      );
      final copied = model.copyWith(audioTokens: changed.audioTokens);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('text_tokens rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptUsageInputTokenDetails')
        ..['text_tokens'] = null;
      expect(
        () => TranscriptUsageInputTokenDetails.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('text_tokens'),
          ),
        ),
      );
      wire['text_tokens'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptUsageInputTokenDetails.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'text_tokens omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptUsageInputTokenDetails.fromJson(
          fixture('TranscriptUsageInputTokenDetails'),
        );
        final cleared = model.copyWith(textTokens: null);
        expect(cleared.textTokens, isNull);
        expect(cleared.toJson().containsKey('text_tokens'), isFalse);
        expect(
          TranscriptUsageInputTokenDetails.fromJson(
            fixture('TranscriptUsageInputTokenDetails')..remove('text_tokens'),
          ).textTokens,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('text_tokens participates in copy and effective value identity', () {
      final model = TranscriptUsageInputTokenDetails.fromJson(
        fixture('TranscriptUsageInputTokenDetails'),
      );
      final changed = TranscriptUsageInputTokenDetails.fromJson(
        fixture('TranscriptUsageInputTokenDetails')
          ..['text_tokens'] = jsonDecode('2'),
      );
      final copied = model.copyWith(textTokens: changed.textTokens);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
  });
  group('TranscriptTextUsageDuration public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranscriptTextUsageDuration');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranscriptTextUsageDuration.fromJson(wire);
      final roundtrip = TranscriptTextUsageDuration.fromJson(model.toJson());
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('seconds rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptTextUsageDuration')..['seconds'] = null;
      expect(
        () => TranscriptTextUsageDuration.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('seconds'),
          ),
        ),
      );
      wire['seconds'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptTextUsageDuration.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('seconds is required', () {
      expect(
        () => TranscriptTextUsageDuration.fromJson(
          fixture('TranscriptTextUsageDuration')..remove('seconds'),
        ),
        throwsFormatException,
      );
    });
    test('seconds participates in copy and effective value identity', () {
      final model = TranscriptTextUsageDuration.fromJson(
        fixture('TranscriptTextUsageDuration'),
      );
      final changed = TranscriptTextUsageDuration.fromJson(
        fixture('TranscriptTextUsageDuration')
          ..['seconds'] = jsonDecode('2.25'),
      );
      final copied = model.copyWith(seconds: changed.seconds);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
  });
  group('TranscriptionLanguage public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranscriptionLanguage');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranscriptionLanguage.fromJson(wire);
      final roundtrip = TranscriptionLanguage.fromJson(model.toJson());
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('code rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionLanguage')..['code'] = null;
      expect(
        () => TranscriptionLanguage.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('code'),
          ),
        ),
      );
      wire['code'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionLanguage.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('code is required', () {
      expect(
        () => TranscriptionLanguage.fromJson(
          fixture('TranscriptionLanguage')..remove('code'),
        ),
        throwsFormatException,
      );
    });
    test('code participates in copy and effective value identity', () {
      final model = TranscriptionLanguage.fromJson(
        fixture('TranscriptionLanguage'),
      );
      final changed = TranscriptionLanguage.fromJson(
        fixture('TranscriptionLanguage')
          ..['code'] = jsonDecode('"private-fixture-lang-changed"'),
      );
      final copied = model.copyWith(code: changed.code);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
  });
  group('TranscriptionLogprob public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranscriptionLogprob');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranscriptionLogprob.fromJson(wire);
      final roundtrip = TranscriptionLogprob.fromJson(model.toJson());
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('token rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionLogprob')..['token'] = null;
      expect(
        () => TranscriptionLogprob.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('token'),
          ),
        ),
      );
      wire['token'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionLogprob.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'token omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptionLogprob.fromJson(
          fixture('TranscriptionLogprob'),
        );
        final cleared = model.copyWith(token: null);
        expect(cleared.token, isNull);
        expect(cleared.toJson().containsKey('token'), isFalse);
        expect(
          TranscriptionLogprob.fromJson(
            fixture('TranscriptionLogprob')..remove('token'),
          ).token,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('token participates in copy and effective value identity', () {
      final model = TranscriptionLogprob.fromJson(
        fixture('TranscriptionLogprob'),
      );
      final changed = TranscriptionLogprob.fromJson(
        fixture('TranscriptionLogprob')
          ..['token'] = jsonDecode('"private-fixture-token-changed"'),
      );
      final copied = model.copyWith(token: changed.token);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('bytes rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionLogprob')..['bytes'] = null;
      expect(
        () => TranscriptionLogprob.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('bytes'),
          ),
        ),
      );
      wire['bytes'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionLogprob.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'bytes omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptionLogprob.fromJson(
          fixture('TranscriptionLogprob'),
        );
        final cleared = model.copyWith(bytes: null);
        expect(cleared.bytes, isNull);
        expect(cleared.toJson().containsKey('bytes'), isFalse);
        expect(
          TranscriptionLogprob.fromJson(
            fixture('TranscriptionLogprob')..remove('bytes'),
          ).bytes,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('bytes participates in copy and effective value identity', () {
      final model = TranscriptionLogprob.fromJson(
        fixture('TranscriptionLogprob'),
      );
      final changed = TranscriptionLogprob.fromJson(
        fixture('TranscriptionLogprob')..['bytes'] = jsonDecode('[]'),
      );
      final copied = model.copyWith(bytes: changed.bytes);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('logprob rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionLogprob')..['logprob'] = null;
      expect(
        () => TranscriptionLogprob.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('logprob'),
          ),
        ),
      );
      wire['logprob'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionLogprob.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'logprob omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranscriptionLogprob.fromJson(
          fixture('TranscriptionLogprob'),
        );
        final cleared = model.copyWith(logprob: null);
        expect(cleared.logprob, isNull);
        expect(cleared.toJson().containsKey('logprob'), isFalse);
        expect(
          TranscriptionLogprob.fromJson(
            fixture('TranscriptionLogprob')..remove('logprob'),
          ).logprob,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('logprob participates in copy and effective value identity', () {
      final model = TranscriptionLogprob.fromJson(
        fixture('TranscriptionLogprob'),
      );
      final changed = TranscriptionLogprob.fromJson(
        fixture('TranscriptionLogprob')..['logprob'] = jsonDecode('0.7'),
      );
      final copied = model.copyWith(logprob: changed.logprob);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
  });
  group('TranscriptionSegment public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranscriptionSegment');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranscriptionSegment.fromJson(wire);
      final roundtrip = TranscriptionSegment.fromJson(model.toJson());
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('id rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionSegment')..['id'] = null;
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('id'),
          ),
        ),
      );
      wire['id'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('id is required', () {
      expect(
        () => TranscriptionSegment.fromJson(
          fixture('TranscriptionSegment')..remove('id'),
        ),
        throwsFormatException,
      );
    });
    test('id participates in copy and effective value identity', () {
      final model = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment'),
      );
      final changed = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment')..['id'] = jsonDecode('2'),
      );
      final copied = model.copyWith(id: changed.id);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('seek rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionSegment')..['seek'] = null;
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('seek'),
          ),
        ),
      );
      wire['seek'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('seek is required', () {
      expect(
        () => TranscriptionSegment.fromJson(
          fixture('TranscriptionSegment')..remove('seek'),
        ),
        throwsFormatException,
      );
    });
    test('seek participates in copy and effective value identity', () {
      final model = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment'),
      );
      final changed = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment')..['seek'] = jsonDecode('3'),
      );
      final copied = model.copyWith(seek: changed.seek);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('start rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionSegment')..['start'] = null;
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('start'),
          ),
        ),
      );
      wire['start'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('start is required', () {
      expect(
        () => TranscriptionSegment.fromJson(
          fixture('TranscriptionSegment')..remove('start'),
        ),
        throwsFormatException,
      );
    });
    test('start participates in copy and effective value identity', () {
      final model = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment'),
      );
      final changed = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment')..['start'] = jsonDecode('1.25'),
      );
      final copied = model.copyWith(start: changed.start);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('end rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionSegment')..['end'] = null;
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('end'),
          ),
        ),
      );
      wire['end'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('end is required', () {
      expect(
        () => TranscriptionSegment.fromJson(
          fixture('TranscriptionSegment')..remove('end'),
        ),
        throwsFormatException,
      );
    });
    test('end participates in copy and effective value identity', () {
      final model = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment'),
      );
      final changed = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment')..['end'] = jsonDecode('2.25'),
      );
      final copied = model.copyWith(end: changed.end);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('text rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionSegment')..['text'] = null;
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('text'),
          ),
        ),
      );
      wire['text'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('text is required', () {
      expect(
        () => TranscriptionSegment.fromJson(
          fixture('TranscriptionSegment')..remove('text'),
        ),
        throwsFormatException,
      );
    });
    test('text participates in copy and effective value identity', () {
      final model = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment'),
      );
      final changed = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment')
          ..['text'] = jsonDecode('"private-fixture-changed"'),
      );
      final copied = model.copyWith(text: changed.text);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('tokens rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionSegment')..['tokens'] = null;
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('tokens'),
          ),
        ),
      );
      wire['tokens'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('tokens is required', () {
      expect(
        () => TranscriptionSegment.fromJson(
          fixture('TranscriptionSegment')..remove('tokens'),
        ),
        throwsFormatException,
      );
    });
    test('tokens participates in copy and effective value identity', () {
      final model = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment'),
      );
      final changed = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment')..['tokens'] = jsonDecode('[]'),
      );
      final copied = model.copyWith(tokens: changed.tokens);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('temperature rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionSegment')..['temperature'] = null;
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('temperature'),
          ),
        ),
      );
      wire['temperature'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('temperature is required', () {
      expect(
        () => TranscriptionSegment.fromJson(
          fixture('TranscriptionSegment')..remove('temperature'),
        ),
        throwsFormatException,
      );
    });
    test('temperature participates in copy and effective value identity', () {
      final model = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment'),
      );
      final changed = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment')..['temperature'] = jsonDecode('1.4'),
      );
      final copied = model.copyWith(temperature: changed.temperature);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('avg_logprob rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionSegment')..['avg_logprob'] = null;
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('avg_logprob'),
          ),
        ),
      );
      wire['avg_logprob'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionSegment.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('avg_logprob is required', () {
      expect(
        () => TranscriptionSegment.fromJson(
          fixture('TranscriptionSegment')..remove('avg_logprob'),
        ),
        throwsFormatException,
      );
    });
    test('avg_logprob participates in copy and effective value identity', () {
      final model = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment'),
      );
      final changed = TranscriptionSegment.fromJson(
        fixture('TranscriptionSegment')..['avg_logprob'] = jsonDecode('0.5'),
      );
      final copied = model.copyWith(avgLogprob: changed.avgLogprob);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test(
      'compression_ratio rejects malformed values without exposing content',
      () {
        final wire = fixture('TranscriptionSegment')
          ..['compression_ratio'] = null;
        expect(
          () => TranscriptionSegment.fromJson(wire),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'context',
              contains('compression_ratio'),
            ),
          ),
        );
        wire['compression_ratio'] = {'private-fixture': 'unsafe'};
        expect(
          () => TranscriptionSegment.fromJson(wire),
          throwsA(
            isA<FormatException>().having(
              (error) => error.toString(),
              'private',
              isNot(contains('private-fixture')),
            ),
          ),
        );
      },
    );
    test('compression_ratio is required', () {
      expect(
        () => TranscriptionSegment.fromJson(
          fixture('TranscriptionSegment')..remove('compression_ratio'),
        ),
        throwsFormatException,
      );
    });
    test(
      'compression_ratio participates in copy and effective value identity',
      () {
        final model = TranscriptionSegment.fromJson(
          fixture('TranscriptionSegment'),
        );
        final changed = TranscriptionSegment.fromJson(
          fixture('TranscriptionSegment')
            ..['compression_ratio'] = jsonDecode('2.5'),
        );
        final copied = model.copyWith(
          compressionRatio: changed.compressionRatio,
        );
        expect(copied, changed);
        expect(copied.hashCode, changed.hashCode);
        expect(copied, isNot(model));
      },
    );
    test(
      'no_speech_prob rejects malformed values without exposing content',
      () {
        final wire = fixture('TranscriptionSegment')..['no_speech_prob'] = null;
        expect(
          () => TranscriptionSegment.fromJson(wire),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'context',
              contains('no_speech_prob'),
            ),
          ),
        );
        wire['no_speech_prob'] = {'private-fixture': 'unsafe'};
        expect(
          () => TranscriptionSegment.fromJson(wire),
          throwsA(
            isA<FormatException>().having(
              (error) => error.toString(),
              'private',
              isNot(contains('private-fixture')),
            ),
          ),
        );
      },
    );
    test('no_speech_prob is required', () {
      expect(
        () => TranscriptionSegment.fromJson(
          fixture('TranscriptionSegment')..remove('no_speech_prob'),
        ),
        throwsFormatException,
      );
    });
    test(
      'no_speech_prob participates in copy and effective value identity',
      () {
        final model = TranscriptionSegment.fromJson(
          fixture('TranscriptionSegment'),
        );
        final changed = TranscriptionSegment.fromJson(
          fixture('TranscriptionSegment')
            ..['no_speech_prob'] = jsonDecode('1.05'),
        );
        final copied = model.copyWith(noSpeechProb: changed.noSpeechProb);
        expect(copied, changed);
        expect(copied.hashCode, changed.hashCode);
        expect(copied, isNot(model));
      },
    );
  });
  group('TranscriptionWord public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranscriptionWord');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranscriptionWord.fromJson(wire);
      final roundtrip = TranscriptionWord.fromJson(model.toJson());
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('word rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionWord')..['word'] = null;
      expect(
        () => TranscriptionWord.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('word'),
          ),
        ),
      );
      wire['word'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionWord.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('word is required', () {
      expect(
        () => TranscriptionWord.fromJson(
          fixture('TranscriptionWord')..remove('word'),
        ),
        throwsFormatException,
      );
    });
    test('word participates in copy and effective value identity', () {
      final model = TranscriptionWord.fromJson(fixture('TranscriptionWord'));
      final changed = TranscriptionWord.fromJson(
        fixture('TranscriptionWord')
          ..['word'] = jsonDecode('"private-fixture-word-changed"'),
      );
      final copied = model.copyWith(word: changed.word);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('start rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionWord')..['start'] = null;
      expect(
        () => TranscriptionWord.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('start'),
          ),
        ),
      );
      wire['start'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionWord.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('start is required', () {
      expect(
        () => TranscriptionWord.fromJson(
          fixture('TranscriptionWord')..remove('start'),
        ),
        throwsFormatException,
      );
    });
    test('start participates in copy and effective value identity', () {
      final model = TranscriptionWord.fromJson(fixture('TranscriptionWord'));
      final changed = TranscriptionWord.fromJson(
        fixture('TranscriptionWord')..['start'] = jsonDecode('1.25'),
      );
      final copied = model.copyWith(start: changed.start);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('end rejects malformed values without exposing content', () {
      final wire = fixture('TranscriptionWord')..['end'] = null;
      expect(
        () => TranscriptionWord.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('end'),
          ),
        ),
      );
      wire['end'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranscriptionWord.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('end is required', () {
      expect(
        () => TranscriptionWord.fromJson(
          fixture('TranscriptionWord')..remove('end'),
        ),
        throwsFormatException,
      );
    });
    test('end participates in copy and effective value identity', () {
      final model = TranscriptionWord.fromJson(fixture('TranscriptionWord'));
      final changed = TranscriptionWord.fromJson(
        fixture('TranscriptionWord')..['end'] = jsonDecode('2.25'),
      );
      final copied = model.copyWith(end: changed.end);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
  });
  group('TranslationResponse public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranslationResponse');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranslationResponse.fromJson(wire);
      final roundtrip = TranslationResponse.fromJson(model.toJson());
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('text rejects malformed values without exposing content', () {
      final wire = fixture('TranslationResponse')..['text'] = null;
      expect(
        () => TranslationResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('text'),
          ),
        ),
      );
      wire['text'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranslationResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('text is required', () {
      expect(
        () => TranslationResponse.fromJson(
          fixture('TranslationResponse')..remove('text'),
        ),
        throwsFormatException,
      );
    });
    test('text participates in copy and effective value identity', () {
      final model = TranslationResponse.fromJson(
        fixture('TranslationResponse'),
      );
      final changed = TranslationResponse.fromJson(
        fixture('TranslationResponse')
          ..['text'] = jsonDecode('"private-fixture-changed"'),
      );
      final copied = model.copyWith(text: changed.text);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
  });
  group('TranslationVerboseResponse public value contract', () {
    test('all fields and future metadata roundtrip with owned snapshots', () {
      final wire = fixture('TranslationVerboseResponse');
      wire['future-private-key'] = {
        'nested': ['private-fixture', 1, null],
      };
      final model = TranslationVerboseResponse.fromJson(wire);
      final roundtrip = TranslationVerboseResponse.fromJson(model.toJson());
      expect(model, roundtrip);
      expect(model.hashCode, roundtrip.hashCode);
      expect(model.copyWith(), model);
      (wire['future-private-key'] as Map<String, dynamic>)['nested'] = [
        'mutated',
      ];
      expect(
        (model.rawJson['future-private-key'] as Map<String, dynamic>)['nested'],
        ['private-fixture', 1, null],
      );
      expect(() => model.rawJson['added'] = true, throwsUnsupportedError);
      expect(
        () =>
            (model.rawJson['future-private-key']
                    as Map<String, dynamic>)['added'] =
                true,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson['future-private-key']
                        as Map<String, dynamic>)['nested']
                    as List<dynamic>)
                .add(true),
        throwsUnsupportedError,
      );
      expect(model.toString(), isNot(contains('private-fixture')));
      expect(model.toString(), isNot(contains('future-private-key')));
    });
    test('task rejects malformed values without exposing content', () {
      final wire = fixture('TranslationVerboseResponse')..['task'] = null;
      expect(
        () => TranslationVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('task'),
          ),
        ),
      );
      wire['task'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranslationVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'task omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranslationVerboseResponse.fromJson(
          fixture('TranslationVerboseResponse'),
        );
        final cleared = model.copyWith(task: null);
        expect(cleared.task, isNull);
        expect(cleared.toJson().containsKey('task'), isFalse);
        expect(
          TranslationVerboseResponse.fromJson(
            fixture('TranslationVerboseResponse')..remove('task'),
          ).task,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('task participates in copy and effective value identity', () {
      final model = TranslationVerboseResponse.fromJson(
        fixture('TranslationVerboseResponse'),
      );
      final changed = TranslationVerboseResponse.fromJson(
        fixture('TranslationVerboseResponse')
          ..['task'] = jsonDecode('"private-fixture-task-changed"'),
      );
      final copied = model.copyWith(task: changed.task);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('language rejects malformed values without exposing content', () {
      final wire = fixture('TranslationVerboseResponse')..['language'] = null;
      expect(
        () => TranslationVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('language'),
          ),
        ),
      );
      wire['language'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranslationVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('language is required', () {
      expect(
        () => TranslationVerboseResponse.fromJson(
          fixture('TranslationVerboseResponse')..remove('language'),
        ),
        throwsFormatException,
      );
    });
    test('language participates in copy and effective value identity', () {
      final model = TranslationVerboseResponse.fromJson(
        fixture('TranslationVerboseResponse'),
      );
      final changed = TranslationVerboseResponse.fromJson(
        fixture('TranslationVerboseResponse')
          ..['language'] = jsonDecode('"English-changed"'),
      );
      final copied = model.copyWith(language: changed.language);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('duration rejects malformed values without exposing content', () {
      final wire = fixture('TranslationVerboseResponse')..['duration'] = null;
      expect(
        () => TranslationVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('duration'),
          ),
        ),
      );
      wire['duration'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranslationVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('duration is required', () {
      expect(
        () => TranslationVerboseResponse.fromJson(
          fixture('TranslationVerboseResponse')..remove('duration'),
        ),
        throwsFormatException,
      );
    });
    test('duration participates in copy and effective value identity', () {
      final model = TranslationVerboseResponse.fromJson(
        fixture('TranslationVerboseResponse'),
      );
      final changed = TranslationVerboseResponse.fromJson(
        fixture('TranslationVerboseResponse')
          ..['duration'] = jsonDecode('2.25'),
      );
      final copied = model.copyWith(duration: changed.duration);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('text rejects malformed values without exposing content', () {
      final wire = fixture('TranslationVerboseResponse')..['text'] = null;
      expect(
        () => TranslationVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('text'),
          ),
        ),
      );
      wire['text'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranslationVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test('text is required', () {
      expect(
        () => TranslationVerboseResponse.fromJson(
          fixture('TranslationVerboseResponse')..remove('text'),
        ),
        throwsFormatException,
      );
    });
    test('text participates in copy and effective value identity', () {
      final model = TranslationVerboseResponse.fromJson(
        fixture('TranslationVerboseResponse'),
      );
      final changed = TranslationVerboseResponse.fromJson(
        fixture('TranslationVerboseResponse')
          ..['text'] = jsonDecode('"private-fixture-changed"'),
      );
      final copied = model.copyWith(text: changed.text);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
    test('segments rejects malformed values without exposing content', () {
      final wire = fixture('TranslationVerboseResponse')..['segments'] = null;
      expect(
        () => TranslationVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'context',
            contains('segments'),
          ),
        ),
      );
      wire['segments'] = {'private-fixture': 'unsafe'};
      expect(
        () => TranslationVerboseResponse.fromJson(wire),
        throwsA(
          isA<FormatException>().having(
            (error) => error.toString(),
            'private',
            isNot(contains('private-fixture')),
          ),
        ),
      );
    });
    test(
      'segments omission and explicit copy clearing remain distinct from null input',
      () {
        final model = TranslationVerboseResponse.fromJson(
          fixture('TranslationVerboseResponse'),
        );
        final cleared = model.copyWith(segments: null);
        expect(cleared.segments, isNull);
        expect(cleared.toJson().containsKey('segments'), isFalse);
        expect(
          TranslationVerboseResponse.fromJson(
            fixture('TranslationVerboseResponse')..remove('segments'),
          ).segments,
          isNull,
        );
        expect(cleared, isNot(model));
      },
    );
    test('segments participates in copy and effective value identity', () {
      final model = TranslationVerboseResponse.fromJson(
        fixture('TranslationVerboseResponse'),
      );
      final changed = TranslationVerboseResponse.fromJson(
        fixture('TranslationVerboseResponse')..['segments'] = jsonDecode('[]'),
      );
      final copied = model.copyWith(segments: changed.segments);
      expect(copied, changed);
      expect(copied.hashCode, changed.hashCode);
      expect(copied, isNot(model));
    });
  });
}
