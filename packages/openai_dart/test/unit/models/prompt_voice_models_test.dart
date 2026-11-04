import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _requestJson() => {
  'type': 'prompt',
  'name': 'private-voice-name',
  'prompt': 'A private-prompt with a calm adult voice.',
};

Map<String, dynamic> _voiceJson({bool storedPrompt = true}) => {
  'object': 'audio.voice',
  'id': 'private-voice-id',
  'name': 'private-voice-name',
  'type': 'prompt',
  'created_at': 0,
  if (storedPrompt) 'prompt': 'private-stored-prompt',
};

Map<String, dynamic> _deletedJson({bool deleted = true}) => {
  'object': 'audio.voice.deleted',
  'id': 'private-voice-id',
  'deleted': deleted,
};

Matcher _safeFormat(String field) => throwsA(
  isA<FormatException>()
      .having((error) => error.message, 'field context', contains(field))
      .having((error) => error.source, 'no source payload', isNull)
      .having(
        (error) => error.toString(),
        'private payload',
        isNot(contains('private-')),
      ),
);

void main() {
  group('PromptVoiceCreateRequest canonical writable contract', () {
    test('both public request variants share the additive base', () {
      final sample = CustomVoiceCreateRequest(
        name: 'sample',
        audioSample: Uint8List.fromList([1]),
        filename: 'sample.wav',
        consent: 'synthetic-consent',
      );
      final prompt = PromptVoiceCreateRequest.fromJson(_requestJson());
      final requests = <VoiceCreateRequest>[sample, prompt];
      for (final request in requests) {
        request.validate();
      }
      expect(sample.type, isNull);
      expect(prompt.type, 'prompt');
      expect(prompt.toJson(), _requestJson());
      expect(prompt.scriptHint, isNull);
      expect(prompt.model, isNull);
    });

    test('all fields round-trip without eager defaults or trimming', () {
      final wire = {
        ..._requestJson(),
        'name': ' name ',
        'prompt': ' prompt ',
        'script_hint': ' speech ',
        'model': 'private-future-model',
      };
      final request = PromptVoiceCreateRequest.fromJson(wire);
      expect(request.name, ' name ');
      expect(request.prompt, ' prompt ');
      expect(request.scriptHint, ' speech ');
      expect(request.model, 'private-future-model');
      expect(request.toJson(), wire);
      expect(PromptVoiceCreateRequest.fromJson(request.toJson()), request);
      expect(
        PromptVoiceCreateRequest.fromJson(request.toJson()).hashCode,
        request.hashCode,
      );
      wire['prompt'] = 'mutated';
      expect(request.prompt, ' prompt ');
    });

    for (final model in ['auto', '2026-10-08', 'future-model', '']) {
      test('open model "$model" is preserved without enum restrictions', () {
        final request = PromptVoiceCreateRequest(
          name: 'name',
          prompt: 'voice',
          model: model,
        );
        expect(request.toJson()['model'], model);
        expect(PromptVoiceCreateRequest.fromJson(request.toJson()), request);
      });
    }

    test('Unicode code points enforce all writable length boundaries', () {
      final name = '😀' * 256;
      final prompt = '😀' * 2000;
      final request = PromptVoiceCreateRequest(
        name: name,
        prompt: prompt,
        scriptHint: prompt,
      );
      expect(request.name.runes.length, 256);
      expect(request.prompt.runes.length, 2000);
      expect(request.scriptHint!.runes.length, 2000);
      expect(() => request.copyWith(name: '$name😀'), _safeFormat('name'));
      expect(
        () => request.copyWith(prompt: '$prompt😀'),
        _safeFormat('prompt'),
      );
      expect(
        () => request.copyWith(scriptHint: '$prompt😀'),
        _safeFormat('scriptHint'),
      );
      expect(() => request.copyWith(name: ''), _safeFormat('name'));
      expect(() => request.copyWith(prompt: ''), _safeFormat('prompt'));
      expect(() => request.copyWith(scriptHint: ''), _safeFormat('scriptHint'));
    });

    for (final blank in [' ', '\t\n\r', '\u00a0\u2003']) {
      test('blank prompt/script reject without changing name rules', () {
        expect(
          () => PromptVoiceCreateRequest(name: 'name', prompt: blank),
          _safeFormat('prompt'),
        );
        expect(
          () => PromptVoiceCreateRequest(
            name: 'name',
            prompt: 'voice',
            scriptHint: blank,
          ),
          _safeFormat('scriptHint'),
        );
        final request = PromptVoiceCreateRequest(
          name: blank,
          prompt: 'x',
          scriptHint: 'x',
        );
        expect(request.name, blank);
        expect(request.scriptHint, 'x');
      });
    }

    for (final field in ['type', 'name', 'prompt']) {
      test('$field is required, nonnull and typed', () {
        for (final wire in [
          _requestJson()..remove(field),
          _requestJson()..[field] = null,
          _requestJson()..[field] = 7,
        ]) {
          expect(
            () => PromptVoiceCreateRequest.fromJson(wire),
            _safeFormat(field),
          );
        }
      });
    }

    for (final field in ['script_hint', 'model']) {
      test(
        '$field omission is allowed but explicit null/type mismatch is not',
        () {
          for (final value in [null, false, <String, dynamic>{}]) {
            expect(
              () => PromptVoiceCreateRequest.fromJson(
                _requestJson()..[field] = value,
              ),
              _safeFormat(field),
            );
          }
        },
      );
    }

    test('wrong discriminator and undeclared writable fields fail safely', () {
      for (final type in ['audio_sample', 'private-unknown-type', '']) {
        expect(
          () => PromptVoiceCreateRequest.fromJson(
            _requestJson()..['type'] = type,
          ),
          _safeFormat('type'),
        );
      }
      for (final field in ['consent', 'audio_sample', 'private-extra-key']) {
        expect(
          () => PromptVoiceCreateRequest.fromJson(
            _requestJson()..[field] = 'private-payload',
          ),
          _safeFormat('PromptVoiceCreateRequest'),
        );
      }
    });

    test(
      'copy, equality and hash include every optional and required field',
      () {
        final request = PromptVoiceCreateRequest.fromJson({
          ..._requestJson(),
          'script_hint': 'private-script',
          'model': 'private-model',
        });
        expect(request.copyWith(), request);
        expect(request.copyWith().hashCode, request.hashCode);
        for (final copy in [
          request.copyWith(name: 'other-name'),
          request.copyWith(prompt: 'other-prompt'),
          request.copyWith(scriptHint: 'other-script'),
          request.copyWith(model: 'other-model'),
          request.copyWith(scriptHint: null),
          request.copyWith(model: null),
        ]) {
          expect(copy, isNot(request));
          expect(PromptVoiceCreateRequest.fromJson(copy.toJson()), copy);
          expect(
            PromptVoiceCreateRequest.fromJson(copy.toJson()).hashCode,
            copy.hashCode,
          );
        }
        expect(
          request
              .copyWith(scriptHint: null)
              .toJson()
              .containsKey('script_hint'),
          isFalse,
        );
        expect(
          request.copyWith(model: null).toJson().containsKey('model'),
          isFalse,
        );
        expect(
          () => request.copyWith(scriptHint: 1),
          _safeFormat('scriptHint'),
        );
        expect(() => request.copyWith(model: true), _safeFormat('model'));
        expect(request.toString(), isNot(contains('private-')));
        for (final field in ['type', 'name', 'prompt', 'scriptHint', 'model']) {
          expect(request.toString(), contains('$field:'));
        }
      },
    );
  });

  group('CustomVoice prompt metadata', () {
    test('stored prompt and method round-trip with private diagnostics', () {
      final voice = CustomVoice.fromJson(_voiceJson());
      expect(voice.type, 'prompt');
      expect(voice.prompt, 'private-stored-prompt');
      expect(voice.toJson(), _voiceJson());
      expect(CustomVoice.fromJson(voice.toJson()), voice);
      expect(CustomVoice.fromJson(voice.toJson()).hashCode, voice.hashCode);
      expect(voice.toString(), isNot(contains('private-')));
      expect(voice.toString(), contains('prompt: [REDACTED]'));
    });

    test('old prompt voices can omit original prompt', () {
      final voice = CustomVoice.fromJson(_voiceJson(storedPrompt: false));
      expect(voice.type, 'prompt');
      expect(voice.prompt, isNull);
      expect(voice.toJson().containsKey('prompt'), isFalse);
      expect(CustomVoice.fromJson(voice.toJson()), voice);
    });

    test(
      'constructor sample default stays compatible and receives no new bounds',
      () {
        final voice = CustomVoice(id: '', name: '', createdAt: -1);
        expect(voice.type, 'audio_sample');
        expect(voice.prompt, isNull);
        expect(voice.toJson().containsKey('prompt'), isFalse);
        for (final prompt in ['', '😀' * 2001]) {
          expect(
            CustomVoice.fromJson(_voiceJson()..['prompt'] = prompt).prompt,
            prompt,
          );
        }
      },
    );

    test('optional original prompt rejects explicit null or wrong types', () {
      for (final value in [null, 1, false, <String, dynamic>{}]) {
        expect(
          () => CustomVoice.fromJson(_voiceJson()..['prompt'] = value),
          _safeFormat('prompt'),
        );
      }
    });

    test(
      'copies include method/prompt and clear known raw prompt authoritatively',
      () {
        final voice = CustomVoice.fromJson({
          ..._voiceJson(),
          'future': const {
            'nested': [1],
          },
        });
        expect(voice.copyWith(), voice);
        expect(voice.copyWith().hashCode, voice.hashCode);
        final changedPrompt = voice.copyWith(prompt: 'private-other-prompt');
        expect(changedPrompt, isNot(voice));
        expect(changedPrompt.toJson()['prompt'], 'private-other-prompt');
        final changedType = voice.copyWith(type: 'audio_sample');
        expect(changedType, isNot(voice));
        expect(changedType.toJson()['type'], 'audio_sample');
        final cleared = voice.copyWith(prompt: null);
        expect(cleared.prompt, isNull);
        expect(cleared.rawJson['prompt'], voice.prompt);
        expect(cleared.toJson().containsKey('prompt'), isFalse);
        expect(cleared.toJson()['future'], {
          'nested': [1],
        });
        for (final copy in [changedPrompt, changedType, cleared]) {
          expect(CustomVoice.fromJson(copy.toJson()), copy);
          expect(CustomVoice.fromJson(copy.toJson()).hashCode, copy.hashCode);
        }
        expect(() => voice.copyWith(prompt: 7), _safeFormat('prompt'));
        expect(
          () => voice.copyWith(type: 'private-future-type'),
          _safeFormat('type'),
        );
      },
    );
  });

  group('CustomVoiceDeleted exact deletion contract', () {
    for (final deleted in [true, false]) {
      test('required bool $deleted round-trips without coercion', () {
        final voice = CustomVoiceDeleted.fromJson(
          _deletedJson(deleted: deleted),
        );
        expect(voice.id, 'private-voice-id');
        expect(voice.object, 'audio.voice.deleted');
        expect(voice.deleted, deleted);
        expect(voice.toJson(), _deletedJson(deleted: deleted));
        expect(CustomVoiceDeleted.fromJson(voice.toJson()), voice);
        expect(
          CustomVoiceDeleted.fromJson(voice.toJson()).hashCode,
          voice.hashCode,
        );
        expect(voice.copyWith(), voice);
        expect(voice.copyWith().hashCode, voice.hashCode);
        expect(voice.toString(), isNot(contains('private-')));
        for (final field in ['id', 'object', 'deleted', 'rawJson']) {
          expect(voice.toString(), contains('$field:'));
        }
      });
    }

    for (final field in ['id', 'object', 'deleted']) {
      test('$field is required, typed and nonnull', () {
        for (final wire in [
          _deletedJson()..remove(field),
          _deletedJson()..[field] = null,
          _deletedJson()..[field] = <String, dynamic>{},
        ]) {
          expect(() => CustomVoiceDeleted.fromJson(wire), _safeFormat(field));
        }
      });
    }

    test(
      'fixed object and boolean do not accept fabricated success values',
      () {
        for (final value in ['audio.voice', 'private-future-object', '']) {
          expect(
            () =>
                CustomVoiceDeleted.fromJson(_deletedJson()..['object'] = value),
            _safeFormat('object'),
          );
        }
        for (final value in [0, 1, 'true']) {
          expect(
            () => CustomVoiceDeleted.fromJson(
              _deletedJson()..['deleted'] = value,
            ),
            _safeFormat('deleted'),
          );
        }
      },
    );

    test('future JSON snapshots detach deeply and typed copies win', () {
      final raw = <String, dynamic>{
        ..._deletedJson(),
        'future': <String, dynamic>{
          'nested': [1, null],
        },
      };
      final voice = CustomVoiceDeleted.fromJson(raw);
      (raw['future'] as Map<String, dynamic>)['nested'] = ['mutated'];
      expect(voice.toJson()['future'], {
        'nested': [1, null],
      });
      expect(() => voice.rawJson['future'] = null, throwsUnsupportedError);
      final future = voice.rawJson['future'] as Map<String, dynamic>;
      expect(
        () => future['nested'] = const <Object?>[],
        throwsUnsupportedError,
      );
      expect(
        () => (future['nested'] as List<dynamic>).add(2),
        throwsUnsupportedError,
      );
      final copies = [
        voice.copyWith(id: 'private-other-id'),
        voice.copyWith(deleted: false),
        voice.copyWith(
          rawJson: {
            'other': [2],
          },
        ),
      ];
      for (final copy in copies) {
        expect(copy, isNot(voice));
        expect(CustomVoiceDeleted.fromJson(copy.toJson()), copy);
        expect(
          CustomVoiceDeleted.fromJson(copy.toJson()).hashCode,
          copy.hashCode,
        );
      }
      expect(copies[0].toJson()['id'], 'private-other-id');
      expect(copies[1].toJson()['deleted'], false);
      expect(copies[2].toJson()['other'], [2]);
      expect(copies[2].toJson().containsKey('future'), isFalse);
      expect(voice.copyWith(rawJson: {}).toJson(), _deletedJson());
    });

    test(
      'finite JSON metadata policy rejects cycles and private malformed extras',
      () {
        final cycle = <String, dynamic>{};
        cycle['private-cycle'] = cycle;
        for (final value in [
          double.nan,
          double.infinity,
          cycle,
          Object(),
          {1: true},
        ]) {
          expect(
            () => CustomVoiceDeleted.fromJson(
              _deletedJson()..['private-extra'] = value,
            ),
            _safeFormat('CustomVoiceDeleted'),
          );
          expect(
            () => CustomVoiceDeleted(
              id: 'private-id',
              deleted: false,
              rawJson: {'private-extra': value},
            ),
            _safeFormat('CustomVoiceDeleted'),
          );
        }
      },
    );
  });
}
