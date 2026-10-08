import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE_FORK_CONTEXT';

Matcher _safeError(String context) => isA<FormatException>()
    .having((error) => error.message, 'context', contains(context))
    .having((error) => error.source, 'source', isNull)
    .having((error) => error.offset, 'offset', isNull)
    .having((error) => error.toString(), 'privacy', isNot(contains(_private)));

void main() {
  group('Inherited fork startup is immutable through open JSON', () {
    for (final key in [
      'model',
      'voice',
      'input',
      'instructions',
      'id',
      'expires_at',
      'status',
      'type',
    ]) {
      test('$key cannot bypass typed fork fields', () {
        final overflow = <String, dynamic>{key: _private};
        expect(
          () => LiveForkSessionConfigParam.fromJson(overflow),
          throwsA(_safeError('inherited startup')),
        );
        expect(
          () => LiveForkSessionConfigParam(rawJson: overflow),
          throwsA(_safeError('inherited startup')),
        );
        expect(
          () => LiveForkSessionConfigParam().copyWith(rawJson: overflow),
          throwsA(_safeError('inherited startup')),
        );
      });
    }
    test('the combined public overflow probe fails before transport use', () {
      expect(
        () => LiveForkSessionConfigParam.fromJson(const {
          'model': _private,
          'voice': _private,
          'instructions': _private,
          'input': <Object?>[],
        }).validateForTransport('websocket'),
        throwsA(_safeError('inherited startup')),
      );
    });
    test(
      'canonical overrides still serialize and unrelated future JSON stays open',
      () {
        final metadata = <String, dynamic>{
          'future': <String, dynamic>{
            _private: <Object?>[1, null],
          },
        };
        final config = LiveForkSessionConfigParam.fromJson({
          'audio': const {
            'format': {'type': 'audio/pcm', 'rate': 16000},
          },
          'delegation': const {
            'type': 'responses',
            'responses': {'model': 'backend-next'},
          },
          'store': false,
          ...metadata,
        });
        expect(() => config.validateForTransport('websocket'), returnsNormally);
        (metadata['future'] as Map<String, dynamic>).clear();
        expect(config.toJson()['future'], {
          _private: [1, null],
        });
        expect(config.toJson()['store'], isFalse);
        expect(config.audio!.format!.rate, 16000);
        expect(config.delegation!.responses!.model, 'backend-next');
        expect(
          () => (config.rawJson['future'] as Map<String, dynamic>).clear(),
          throwsUnsupportedError,
        );
        expect(config.copyWith(), config);
        expect(config.copyWith().hashCode, config.hashCode);
        expect(config.toString(), isNot(contains(_private)));
      },
    );
  });

  group('Fork audio cannot override inherited voice', () {
    for (final key in ['output', 'voice']) {
      test('$key injection is rejected by parse, constructor and copy', () {
        final overflow = <String, dynamic>{
          key: {
            'voice': {'id': _private},
          },
        };
        expect(
          () => LiveForkAudioParam.fromJson(overflow),
          throwsA(_safeError('inherited voice')),
        );
        expect(
          () => LiveForkAudioParam(rawJson: overflow),
          throwsA(_safeError('inherited voice')),
        );
        expect(
          () => LiveForkAudioParam().copyWith(rawJson: overflow),
          throwsA(_safeError('inherited voice')),
        );
      });
    }
    test(
      'a nested audio.output probe fails through the public parent factory',
      () {
        expect(
          () => LiveForkSessionConfigParam.fromJson(const {
            'audio': {
              'format': {'type': 'audio/pcmu', 'rate': 8000},
              'output': {'voice': _private},
            },
          }),
          throwsA(_safeError('LiveForkSessionConfigParam.audio')),
        );
      },
    );
    test(
      'format and unrelated finite future audio metadata remain available',
      () {
        final audio = LiveForkAudioParam.fromJson(const {
          'format': {'type': 'audio/pcma', 'rate': 8000},
          'future': {'private': _private},
        });
        expect(audio.toJson(), {
          'format': {'type': 'audio/pcma', 'rate': 8000},
          'future': {'private': _private},
        });
        expect(
          audio
              .copyWith(format: LiveAudioFormat.pcm(rate: 24000))
              .toJson()['format'],
          {'type': 'audio/pcm', 'rate': 24000},
        );
        expect(audio.copyWith(format: null).toJson(), {
          'future': {'private': _private},
        });
        expect(audio.toString(), isNot(contains(_private)));
      },
    );
  });
}
