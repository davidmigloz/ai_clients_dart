import 'package:openai_dart/src/helpers/live/live_transcript_values.dart';
import 'package:test/test.dart';

const _private = 'private-transcript-secret';

LiveTranscriptSegment _segment() => LiveTranscriptSegment(
  id: _private,
  previousId: 'previous-$_private',
  speaker: LiveTranscriptSpeaker.assistant,
  text: _private,
  startMs: 100,
  endMs: 500,
);

void _sameValue(Object left, Object right) {
  expect(left, right);
  expect(left.hashCode, right.hashCode);
  expect({left, right}, hasLength(1));
}

void main() {
  group('immutable transcript options', () {
    test('defaults, ownership, clear and complete equality/hash', () {
      final phrases = <String>[_private];
      final options = LiveTranscriptOptions(additionalAcknowledgments: phrases);
      phrases.clear();
      expect(options.minTurnSeparationMs, 500);
      expect(options.assistantSilenceMs, 2000);
      expect(options.backchannelMaxDurationMs, 1000);
      expect(options.backchannelIsolationMs, 2000);
      expect(options.additionalAcknowledgments, [_private]);
      expect(options.additionalAcknowledgments.clear, throwsUnsupportedError);
      _sameValue(options, options.copyWith());
      expect(
        options
            .copyWith(additionalAcknowledgments: [])
            .additionalAcknowledgments,
        isEmpty,
      );
      expect(options.toString(), isNot(contains(_private)));
      final replacements = [
        options.copyWith(minTurnSeparationMs: 0.1),
        options.copyWith(assistantSilenceMs: 2),
        options.copyWith(backchannelMaxDurationMs: 3),
        options.copyWith(backchannelIsolationMs: 4),
        options.copyWith(additionalAcknowledgments: ['different']),
      ];
      expect(replacements.every((value) => value != options), isTrue);
      expect(replacements.toSet(), hasLength(5));
      expect(options.toString(), contains('1 phrases'));
    });
    for (final value in [-1.0, double.nan, double.infinity, 2147483648.0]) {
      for (final field in ['separation', 'silence', 'duration', 'isolation']) {
        test('$field rejects invalid threshold $value', () {
          expect(
            () => LiveTranscriptOptions(
              minTurnSeparationMs: field == 'separation' ? value : 500,
              assistantSilenceMs: field == 'silence' ? value : 2000,
              backchannelMaxDurationMs: field == 'duration' ? value : 1000,
              backchannelIsolationMs: field == 'isolation' ? value : 2000,
            ),
            throwsArgumentError,
          );
        });
      }
    }
    test('zero, fractional and maximum thresholds are admitted', () {
      final options = LiveTranscriptOptions(
        minTurnSeparationMs: 0,
        assistantSilenceMs: 0.1,
        backchannelMaxDurationMs: 2147483647,
        backchannelIsolationMs: 0,
      );
      expect(options.minTurnSeparationMs, 0);
      expect(options.assistantSilenceMs, 0.1);
      expect(options.backchannelMaxDurationMs, 2147483647);
    });
  });

  group('projection values', () {
    test(
      'fragment complete copy/equality/hash and private text diagnostics',
      () {
        final fragment = LiveTranscriptFragment(
          speaker: LiveTranscriptSpeaker.user,
          text: _private,
          startMs: 100,
          endMs: 500,
        );
        _sameValue(fragment, fragment.copyWith());
        final different = [
          fragment.copyWith(speaker: LiveTranscriptSpeaker.assistant),
          fragment.copyWith(text: 'changed'),
          fragment.copyWith(startMs: 101),
          fragment.copyWith(endMs: 501),
        ];
        expect(different.every((value) => value != fragment), isTrue);
        expect(fragment.copyWith(text: '').text, '');
        expect(fragment.toString(), isNot(contains(_private)));
        expect(fragment.toString(), contains('speaker: user'));
        expect(fragment.toString(), contains('startMs: 100'));
        expect(fragment.toString(), contains('endMs: 500'));
      },
    );

    test(
      'segment complete copy/clear/equality/hash hides all text and IDs',
      () {
        final segment = _segment();
        _sameValue(segment, segment.copyWith());
        final different = [
          segment.copyWith(id: 'new'),
          segment.copyWith(previousId: 'new'),
          segment.copyWith(clearPreviousId: true),
          segment.copyWith(speaker: LiveTranscriptSpeaker.user),
          segment.copyWith(text: 'new'),
          segment.copyWith(startMs: 101),
          segment.copyWith(endMs: 501),
        ];
        expect(different.every((value) => value != segment), isTrue);
        expect(different.toSet(), hasLength(7));
        expect(
          segment
              .copyWith(previousId: 'ignored', clearPreviousId: true)
              .previousId,
          isNull,
        );
        expect(segment.toString(), isNot(contains(_private)));
        expect(segment.toString(), contains('hasPreviousId: true'));
      },
    );

    for (final interval in [(-1, 0), (2, 1), (0, 9007199254740992)]) {
      test('fragment and segment reject interval $interval', () {
        expect(
          () => LiveTranscriptFragment(
            speaker: LiveTranscriptSpeaker.user,
            text: _private,
            startMs: interval.$1,
            endMs: interval.$2,
          ),
          throwsArgumentError,
        );
        expect(
          () => LiveTranscriptSegment(
            id: _private,
            speaker: LiveTranscriptSpeaker.user,
            text: _private,
            startMs: interval.$1,
            endMs: interval.$2,
          ),
          throwsArgumentError,
        );
      });
    }

    test('empty projection IDs fail safely', () {
      expect(() => _segment().copyWith(id: ''), throwsArgumentError);
      expect(() => _segment().copyWith(previousId: ''), throwsArgumentError);
    });

    for (final invalid in [
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      test('direct and copied intervals reject nonfinite int runtime $invalid', () {
        // JavaScript can represent a nonfinite number with an int runtime type.
        // Other runtimes reject the cast before the constructor; both must fail.
        expect(
          () => LiveTranscriptFragment(
            speaker: LiveTranscriptSpeaker.user,
            text: _private,
            startMs: invalid as dynamic,
            endMs: 500,
          ),
          throwsA(anyOf(isA<ArgumentError>(), isA<TypeError>())),
        );
        expect(
          () => LiveTranscriptSegment(
            id: _private,
            speaker: LiveTranscriptSpeaker.user,
            text: _private,
            startMs: 100,
            endMs: invalid as dynamic,
          ),
          throwsA(anyOf(isA<ArgumentError>(), isA<TypeError>())),
        );
        expect(
          () => _segment().copyWith(startMs: invalid as dynamic),
          throwsA(anyOf(isA<ArgumentError>(), isA<TypeError>())),
        );
        final fragment = LiveTranscriptFragment(
          speaker: LiveTranscriptSpeaker.user,
          text: '',
          startMs: 0,
          endMs: 0,
        );
        expect(
          () => fragment.copyWith(endMs: invalid as dynamic),
          throwsA(anyOf(isA<ArgumentError>(), isA<TypeError>())),
        );
      });
    }

    for (final reason in LiveTranscriptCloseReason.values) {
      test(
        'update reason ${reason.name} complete copy/clear and equality/hash',
        () {
          final update = LiveTranscriptUpdate(
            segment: _segment(),
            reason: reason,
          );
          _sameValue(update, update.copyWith());
          expect(update.isClosed, isTrue);
          expect(update.copyWith(clearReason: true).reason, isNull);
          expect(update.copyWith(clearReason: true).isClosed, isFalse);
          expect(
            update.copyWith(segment: _segment().copyWith(text: 'new')),
            isNot(update),
          );
          expect(update.copyWith(clearReason: true), isNot(update));
          expect(update.toString(), contains(reason.name));
          expect(update.toString(), isNot(contains(_private)));
        },
      );
    }

    test('update supplied reason changes and null default is open', () {
      final update = LiveTranscriptUpdate(segment: _segment());
      expect(update.isClosed, isFalse);
      expect(
        update.copyWith(reason: LiveTranscriptCloseReason.inactivity).reason,
        LiveTranscriptCloseReason.inactivity,
      );
      expect(
        update.copyWith(
          reason: LiveTranscriptCloseReason.manual,
          clearReason: true,
        ),
        update,
      );
    });
  });

  group('explicit caller playback projection', () {
    test(
      'anchors and rate map source timing without changing or clipping it',
      () {
        final segment = _segment();
        final projection = projectLiveTranscriptPlayback(
          segment,
          sourceAnchorMs: 300,
          playbackAnchorMs: 1000,
          rate: 2,
        );
        expect(projection.segment, same(segment));
        expect(projection.startMs, 900);
        expect(projection.endMs, 1100);
        expect(projection.rate, 2);
        expect(segment.startMs, 100);
        expect(segment.endMs, 500);
        _sameValue(projection, projection.copyWith());
        final different = [
          projection.copyWith(segment: segment.copyWith(text: 'new')),
          projection.copyWith(sourceAnchorMs: 100),
          projection.copyWith(playbackAnchorMs: 2000),
          projection.copyWith(rate: 0.5),
        ];
        expect(different.every((value) => value != projection), isTrue);
        expect(different.toSet(), hasLength(4));
        expect(projection.toString(), isNot(contains(_private)));
        expect(projection.toString(), contains('sourceAnchorMs: 300'));
      },
    );

    test('negative projected time and discontinuous clocks are deliberate', () {
      final projection = projectLiveTranscriptPlayback(
        _segment(),
        sourceAnchorMs: 1000,
        playbackAnchorMs: -100,
      );
      expect(projection.startMs, -1000);
      expect(projection.endMs, -600);
      expect(projection.copyWith(playbackAnchorMs: 5000).startMs, 4100);
    });

    for (final rate in [0.0, -1.0, double.nan, double.infinity]) {
      test('rejects invalid playback rate $rate', () {
        expect(
          () => projectLiveTranscriptPlayback(
            _segment(),
            sourceAnchorMs: 0,
            playbackAnchorMs: 0,
            rate: rate,
          ),
          throwsArgumentError,
        );
      });
    }
    for (final value in [double.nan, double.infinity]) {
      test('rejects nonfinite playback/source anchor $value', () {
        expect(
          () => projectLiveTranscriptPlayback(
            _segment(),
            sourceAnchorMs: value,
            playbackAnchorMs: 0,
          ),
          throwsArgumentError,
        );
        expect(
          () => projectLiveTranscriptPlayback(
            _segment(),
            sourceAnchorMs: 0,
            playbackAnchorMs: value,
          ),
          throwsArgumentError,
        );
      });
    }
    test('rejects finite inputs that overflow projected timestamps', () {
      expect(
        () => projectLiveTranscriptPlayback(
          _segment(),
          sourceAnchorMs: -1e308,
          playbackAnchorMs: 1e308,
          rate: 1e-308,
        ),
        throwsArgumentError,
      );
    });
  });
}
