import 'dart:async';
import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import 'live_transcript_sdk_goldens.dart';

Future<void> _pump() => Future<void>.delayed(Duration.zero);

LiveServerEvent _text(
  String text, {
  String id = 'event',
  bool assistant = false,
  int start = 0,
  int end = 200,
}) => LiveServerEvent.fromJson({
  'type': assistant
      ? 'session.output_transcript.delta'
      : 'session.input_transcript.delta',
  'event_id': id,
  'delta': text,
  'start_ms': start,
  'end_ms': end,
});

LiveServerEvent _final() => LiveServerEvent.fromJson({
  'type': 'session.closed',
  'event_id': 'final',
  'reason': 'close_requested',
  'session': {
    'model': 'synthetic-live',
    'id': 'private-session-id',
    'expires_at': -1,
    'status': 'active',
  },
  'usage': {'seconds': 1.5},
});

String _wireReason(LiveTranscriptCloseReason reason) => switch (reason) {
  LiveTranscriptCloseReason.speakerChange => 'speaker_change',
  LiveTranscriptCloseReason.timestampReset => 'timestamp_reset',
  LiveTranscriptCloseReason.sessionClosed => 'session_closed',
  LiveTranscriptCloseReason.transportClosed => 'transport_closed',
  LiveTranscriptCloseReason.inactivity => 'inactivity',
  LiveTranscriptCloseReason.manual => 'manual',
};

int? _suffix(String? id) => id == null ? null : int.parse(id.split('_').last);

void main() {
  group('independent actual Node SDK fake-clock goldens', () {
    final corpus = jsonDecode(liveTranscriptSdkGoldens) as List;
    test('corpus contains 41 independently executed cases', () {
      expect(corpus, hasLength(41));
    });
    for (final raw in corpus) {
      final fixture = Map<String, dynamic>.from(raw as Map);
      test('${fixture['name']} (${fixture['sdkTest']})', () async {
        final clock = _Clock();
        final options = fixture['options'] as Map;
        final grouper = LiveTranscriptGrouper(
          nowMs: () => clock.now,
          timerFactory: clock.timer,
          options: LiveTranscriptOptions(
            minTurnSeparationMs:
                (options['minTurnSeparationMs'] as num?)?.toDouble() ?? 500,
            assistantSilenceMs:
                (options['assistantSilenceMs'] as num?)?.toDouble() ?? 2000,
            backchannelMaxDurationMs:
                (options['backchannelMaxDurationMs'] as num?)?.toDouble() ??
                1000,
            backchannelIsolationMs:
                (options['backchannelIsolationMs'] as num?)?.toDouble() ?? 2000,
            additionalAcknowledgments:
                (options['additionalAcknowledgments'] as List?)
                    ?.cast<String>() ??
                [],
          ),
        );
        final actual = <Map<String, dynamic>>[];
        final subscription = grouper.updates.listen((update) {
          final segment = update.segment;
          actual.add({
            'at': clock.now,
            'kind': update.isClosed ? 'closed' : 'updated',
            'segment': {
              'id': _suffix(segment.id),
              'previousId': _suffix(segment.previousId),
              'speaker': segment.speaker.name,
              'text': segment.text,
              'startMs': segment.startMs,
              'endMs': segment.endMs,
            },
            if (update.reason != null) 'reason': _wireReason(update.reason!),
          });
        });
        var nextId = 0;
        try {
          for (final rawOperation in fixture['operations'] as List) {
            final operation = rawOperation as Map;
            switch (operation['kind']) {
              case 'advance':
                await clock.advance((operation['ms'] as num).toDouble());
              case 'close':
                grouper.close();
              case 'event':
                if (operation['type'] == 'session.closed') {
                  grouper.push(_final());
                } else {
                  grouper.push(
                    _text(
                      operation['delta'] as String,
                      id: (operation['event_id'] ?? '${nextId++}') as String,
                      assistant:
                          operation['type'] ==
                          'session.output_transcript.delta',
                      start: operation['start_ms'] as int,
                      end: operation['end_ms'] as int,
                    ),
                  );
                }
              default:
                fail('Unrecognized independent golden operation.');
            }
            await _pump();
          }
          expect(actual, fixture['updates']);
          expect(clock.active, hasLength(fixture['pendingTimers'] as int));
          expect(grouper.isClosed, isTrue);
        } finally {
          grouper.close();
          await subscription.cancel();
        }
      });
    }
  });

  group('pure public grouping', () {
    test('speaker preference, source gaps and predecessor identities', () {
      final grouping = LiveTranscriptGrouping(idPrefix: 'pure-local');
      final updates = <LiveTranscriptUpdate>[
        ...grouping.process([
          LiveTranscriptFragment(
            speaker: LiveTranscriptSpeaker.assistant,
            text: 'Answer',
            startMs: 0,
            endMs: 200,
          ),
          LiveTranscriptFragment(
            speaker: LiveTranscriptSpeaker.user,
            text: 'Question',
            startMs: 0,
            endMs: 200,
          ),
        ]),
        ...grouping.advance(1000),
        ...grouping.process([
          LiveTranscriptFragment(
            speaker: LiveTranscriptSpeaker.assistant,
            text: 'Later.',
            startMs: 4000,
            endMs: 4200,
          ),
        ]),
        ...grouping.finish(4200),
      ];
      final closed = updates.where((update) => update.isClosed).toList();
      expect(closed.map((update) => update.segment.text), [
        'Question',
        'Answer',
        'Later.',
      ]);
      expect(closed.map((update) => update.segment.id), [
        'pure-local_0',
        'pure-local_1',
        'pure-local_2',
      ]);
      expect(closed.map((update) => update.segment.previousId), [
        null,
        'pure-local_0',
        'pure-local_1',
      ]);
      expect(closed[1].reason, LiveTranscriptCloseReason.inactivity);
      expect(grouping.deadline, isNull);
      expect(() => updates.first.segment.toString(), returnsNormally);
    });

    for (final invalid in [double.nan, double.infinity, -1.0]) {
      test('rejects invalid explicit source time $invalid', () {
        final grouping = LiveTranscriptGrouping();
        expect(() => grouping.advance(invalid), throwsArgumentError);
        expect(() => grouping.finish(invalid), throwsArgumentError);
        expect(grouping.speaker, isNull);
      });
    }
    test('empty and immutable process/finish outputs', () {
      final grouping = LiveTranscriptGrouping();
      expect(grouping.process([]), isEmpty);
      final updates = grouping.process([
        LiveTranscriptFragment(
          speaker: LiveTranscriptSpeaker.user,
          text: 'raw-private',
          startMs: 0,
          endMs: 0,
        ),
      ]);
      expect(updates.clear, throwsUnsupportedError);
      expect(() => grouping.process([]).clear(), throwsUnsupportedError);
      expect(() => grouping.finish(0).clear(), throwsUnsupportedError);
      expect(grouping.finish(0), isEmpty);
    });

    test('advance returns immutable speaker and inactivity snapshots', () {
      final grouping = LiveTranscriptGrouping()
        ..process([
          LiveTranscriptFragment(
            speaker: LiveTranscriptSpeaker.user,
            text: 'Question',
            startMs: 0,
            endMs: 200,
          ),
          LiveTranscriptFragment(
            speaker: LiveTranscriptSpeaker.assistant,
            text: 'Answer',
            startMs: 200,
            endMs: 400,
          ),
        ]);
      final promoted = grouping.advance(1000);
      expect(promoted, hasLength(2));
      expect(promoted.clear, throwsUnsupportedError);
      final inactive = grouping.advance(2400);
      expect(inactive.single.reason, LiveTranscriptCloseReason.inactivity);
      expect(inactive.clear, throwsUnsupportedError);
    });
  });

  group('clock, reset, flush and cleanup', () {
    for (final gap in [499, 500, 501]) {
      test('SDK minimum turn separation boundary $gap ms', () async {
        final clock = _Clock();
        final grouper =
            LiveTranscriptGrouper(
                nowMs: () => clock.now,
                timerFactory: clock.timer,
              )
              ..push(_text('Question', id: 'user'))
              ..push(
                _text(
                  'Answer',
                  id: 'assistant',
                  assistant: true,
                  start: 200 + gap,
                  end: 400 + gap,
                ),
              );
        await clock.advance(3000);
        grouper.close();
        expect(grouper.segments.map((segment) => segment.text), [
          'Question',
          'Answer',
        ]);
        expect(clock.active, isEmpty);
      });
    }
    for (final duration in [999, 1000, 1001]) {
      test('SDK backchannel duration boundary $duration ms', () async {
        final clock = _Clock();
        final grouper =
            LiveTranscriptGrouper(
                nowMs: () => clock.now,
                timerFactory: clock.timer,
              )
              ..push(_text('Tell me', id: 'user', end: 100))
              ..push(
                _text(
                  'mhm',
                  id: 'ack',
                  assistant: true,
                  start: 100,
                  end: 100 + duration,
                ),
              )
              ..push(_text('more', id: 'more', start: 1200, end: 1400));
        await clock.advance(5000);
        grouper.close();
        expect(
          grouper.segments.map((segment) => segment.text),
          duration < 1000 ? ['Tell me more'] : ['Tell me', 'mhm', 'more'],
        );
        expect(clock.active, isEmpty);
      });
    }
    for (final fixture in [
      ('\ufeffYEAH\ufeff', true),
      ('\u0085yeah\u0085', false),
      ('\u001cyeah\u001c', false),
      ('\u00a0uh\u2003huh!\u00a0', true),
      ('okay-ish', false),
      ('hm', true),
      ('İ', false),
    ]) {
      test(
        'SDK ECMAScript whitespace acknowledgment ${fixture.$1.codeUnits}',
        () {
          final clock = _Clock();
          final grouper =
              LiveTranscriptGrouper(
                  nowMs: () => clock.now,
                  timerFactory: clock.timer,
                )
                ..push(_text('Tell me', id: 'user'))
                ..push(
                  _text(
                    fixture.$1,
                    id: 'ack',
                    assistant: true,
                    start: 200,
                    end: 400,
                  ),
                )
                ..push(_text('more', id: 'more', start: 800, end: 1000))
                ..close();
          expect(
            grouper.segments.map((segment) => segment.text),
            fixture.$2 ? ['Tell me more'] : ['Tell me', fixture.$1, 'more'],
          );
          expect(clock.active, isEmpty);
        },
      );
    }
    for (final fixture in [
      ('你好', '世界', '你好 世界'),
      ('Ⅻ', '½', 'Ⅻ ½'),
      ('x😀', 'y', 'x😀y'),
      ('a', '\u0301b', 'a\u0301b'),
    ]) {
      test('SDK Unicode separator ${fixture.$1} / ${fixture.$2}', () {
        final clock = _Clock();
        final grouper =
            LiveTranscriptGrouper(
                nowMs: () => clock.now,
                timerFactory: clock.timer,
              )
              ..push(_text(fixture.$1, id: 'user'))
              ..push(
                _text('mhm', id: 'ack', assistant: true, start: 200, end: 400),
              )
              ..push(_text(fixture.$2, id: 'more', start: 800, end: 1000))
              ..close();
        expect(grouper.segments.single.text, fixture.$3);
        expect(clock.active, isEmpty);
      });
    }
    for (final disabled in [false, true]) {
      test(
        'SDK copied custom acknowledgments and suppression disabled=$disabled',
        () {
          final phrases = [' XY-Z! ', '...'];
          final clock = _Clock();
          final options = LiveTranscriptOptions(
            backchannelMaxDurationMs: disabled ? 0 : 1000,
            additionalAcknowledgments: phrases,
          );
          phrases.clear();
          final grouper =
              LiveTranscriptGrouper(
                  options: options,
                  nowMs: () => clock.now,
                  timerFactory: clock.timer,
                )
                ..push(_text('Tell me', id: 'user'))
                ..push(
                  _text(
                    'xy-',
                    id: 'ack-1',
                    assistant: true,
                    start: 200,
                    end: 400,
                  ),
                )
                ..push(
                  _text(
                    'z!',
                    id: 'ack-2',
                    assistant: true,
                    start: 400,
                    end: 600,
                  ),
                )
                ..push(_text('more', id: 'more', start: 800, end: 1000))
                ..close();
          expect(
            grouper.segments.map((segment) => segment.text),
            disabled ? ['Tell me', 'xy-z!', 'more'] : ['Tell me more'],
          );
          expect(clock.active, isEmpty);
        },
      );
    }
    for (final fixture in [
      ('overlapping text', 'x', 200, false),
      ('overlapping punctuation', '.', 200, false),
      ('standalone acknowledgment suffix', '.', 700, false),
      ('changing duration eligibility', '.', 200, true),
    ]) {
      test('SDK large-fragment regression: ${fixture.$1}', () async {
        final clock = _Clock();
        final grouper =
            LiveTranscriptGrouper(
                nowMs: () => clock.now,
                timerFactory: clock.timer,
              )
              ..push(_text('Tell me', id: 'user'))
              ..push(
                _text('yes', id: 'yes', assistant: true, start: 200, end: 201),
              );
        final closed = <LiveTranscriptUpdate>[];
        final subscription = grouper.updates.listen((update) {
          if (update.isClosed) closed.add(update);
        });
        for (var index = 0; index < 4000; index++) {
          final duration = fixture.$4 && index.isEven ? 1000 : 1 + index % 2;
          grouper.push(
            _text(
              fixture.$2,
              id: 'part-$index',
              assistant: true,
              start: fixture.$3,
              end: fixture.$3 + duration,
            ),
          );
        }
        grouper.close();
        await _pump();
        expect(closed.map((update) => update.segment.text), [
          'Tell me',
          'yes${fixture.$2 * 4000}',
        ]);
        expect(clock.active, isEmpty);
        await subscription.cancel();
      });
    }
    for (final padding in ['.', ' ']) {
      test(
        'SDK million-character interior padding: ${padding.codeUnitAt(0)}',
        () {
          final clock = _Clock();
          final large = 'a${padding * 1000000}b';
          final grouper =
              LiveTranscriptGrouper(
                  nowMs: () => clock.now,
                  timerFactory: clock.timer,
                )
                ..push(_text('Tell me', id: 'user'))
                ..push(
                  _text(
                    large,
                    id: 'long',
                    assistant: true,
                    start: 200,
                    end: 400,
                  ),
                )
                ..close();
          expect(grouper.segments.map((segment) => segment.text), [
            'Tell me',
            large,
          ]);
          expect(clock.active, isEmpty);
        },
      );
    }
    test(
      'flush settles text but does not finalize; reset keeps local IDs',
      () async {
        final clock = _Clock();
        final grouper = LiveTranscriptGrouper(
          nowMs: () => clock.now,
          timerFactory: clock.timer,
        );
        final updates = <LiveTranscriptUpdate>[];
        final subscription = grouper.updates.listen(updates.add);
        grouper.push(_text('First'));
        expect(grouper.segments, isEmpty);
        grouper.flush();
        expect(grouper.segments.single.text, 'First');
        expect(grouper.isClosed, isFalse);
        final original = grouper.segments.single;
        grouper
          ..reset()
          ..push(_text('Second', start: 0, end: 100))
          ..flush();
        expect(grouper.segments, hasLength(2));
        expect(grouper.segments.last.id, isNot(original.id));
        expect(grouper.segments.last.previousId, original.id);
        grouper.reset(clearSegments: true);
        expect(grouper.segments, isEmpty);
        grouper.close();
        await _pump();
        expect(
          updates
              .where((update) => update.isClosed)
              .map((update) => update.reason),
          [
            LiveTranscriptCloseReason.timestampReset,
            LiveTranscriptCloseReason.timestampReset,
          ],
        );
        expect(clock.active, isEmpty);
        await subscription.cancel();
        expect(() => grouper.push(_text('late')), throwsStateError);
        expect(grouper.flush, throwsStateError);
        expect(grouper.reset, throwsStateError);
        grouper.close();
      },
    );

    test('canceled timer generations cannot commit stale text', () {
      final clock = _Clock();
      final grouper = LiveTranscriptGrouper(
        nowMs: () => clock.now,
        timerFactory: clock.timer,
      )..push(_text('old', assistant: true));
      final stale = clock.active.single;
      grouper.reset(clearSegments: true);
      stale.fireEvenIfCanceled();
      expect(grouper.segments, isEmpty);
      grouper.push(_text('new', assistant: true));
      final afterReset = clock.active.single;
      grouper.close();
      final snapshots = grouper.segments;
      afterReset.fireEvenIfCanceled();
      expect(grouper.segments, snapshots);
      expect(clock.active, isEmpty);
    });

    test('safe integer boundaries and malformed intervals do not mutate', () {
      final clock = _Clock();
      final grouper = LiveTranscriptGrouper(
        nowMs: () => clock.now,
        timerFactory: clock.timer,
      );
      for (final event in [
        _text('private', id: '', start: 0, end: 0),
        _text('private', start: -1, end: 0),
        _text('private', start: 2, end: 1),
      ]) {
        expect(() => grouper.push(event), throwsArgumentError);
        expect(grouper.segments, isEmpty);
        expect(clock.active, isEmpty);
      }
      grouper
        ..push(_text('safe', start: 9007199254740791, end: 9007199254740991))
        ..close();
      expect(grouper.segments.single.endMs, 9007199254740991);
      expect(clock.active, isEmpty);
    });

    test('invalid injected clock fails before deduplication mutation', () {
      var local = double.nan;
      final grouper = LiveTranscriptGrouper(nowMs: () => local);
      final event = _text('once');
      expect(() => grouper.push(event), throwsStateError);
      local = 0;
      grouper
        ..push(event)
        ..close();
      expect(grouper.segments.single.text, 'once');
    });

    test(
      'bad clock during finalization still clears timer and closes updates',
      () async {
        final clock = _Clock();
        var local = 0.0;
        final grouper = LiveTranscriptGrouper(
          nowMs: () => local,
          timerFactory: clock.timer,
        );
        final updates = <LiveTranscriptUpdate>[];
        final done = Completer<void>();
        final subscription = grouper.updates.listen(
          updates.add,
          onDone: done.complete,
        );
        grouper.push(_text('pending', assistant: true));
        expect(clock.active, hasLength(1));
        local = double.nan;
        expect(grouper.close, throwsStateError);
        await done.future;
        expect(grouper.isClosed, isTrue);
        expect(clock.active, isEmpty);
        expect(updates, isEmpty);
        grouper.close();
        await subscription.cancel();
      },
    );

    test(
      'unrelated raw future metadata remains intact and does not touch timers',
      () {
        final clock = _Clock();
        final grouper = LiveTranscriptGrouper(
          nowMs: () => clock.now,
          timerFactory: clock.timer,
        )..push(_text('pending'));
        final timer = clock.active.single;
        final event = LiveServerEvent.fromJson({
          'type': 'future.received',
          'private': {
            'nested': ['raw-private', null],
          },
        });
        final raw = event.toJson();
        grouper.push(event);
        expect(clock.active.single, same(timer));
        expect(event.toJson(), raw);
        grouper.close();
        expect(grouper.isSessionFinalized, isFalse);
        expect(grouper.completionReason, LiveTranscriptCloseReason.manual);
      },
    );

    test(
      'asynchronous listener reentrancy preserves every final snapshot',
      () async {
        final clock = _Clock();
        final grouper = LiveTranscriptGrouper(
          nowMs: () => clock.now,
          timerFactory: clock.timer,
        );
        final updates = <LiveTranscriptUpdate>[];
        final subscription = grouper.updates.listen((update) {
          updates.add(update);
          if (!update.isClosed && update.segment.text == 'one') {
            grouper
              ..push(_text(' two', id: 'two', start: 200, end: 400))
              ..close();
          }
        });
        grouper.push(_text('one'));
        await clock.advance(50);
        expect(updates.map((update) => update.segment.text), [
          'one',
          'one two',
          'one two',
        ]);
        expect(updates.map((update) => update.isClosed), [false, false, true]);
        expect(clock.active, isEmpty);
        await subscription.cancel();
      },
    );

    test(
      'listener failures are zone-local and do not stop another tap',
      () async {
        final clock = _Clock();
        final grouper = LiveTranscriptGrouper(
          nowMs: () => clock.now,
          timerFactory: clock.timer,
        );
        final listenerErrors = <Object>[];
        StreamSubscription<LiveTranscriptUpdate>? failing;
        runZonedGuarded(() {
          failing = grouper.updates.listen(
            (_) => throw StateError('listener-private'),
          );
        }, (error, _) => listenerErrors.add(error));
        final healthy = <LiveTranscriptUpdate>[];
        final subscription = grouper.updates.listen(healthy.add);
        grouper
          ..push(_text('one'))
          ..close();
        await _pump();
        expect(listenerErrors, hasLength(2));
        expect(healthy, hasLength(2));
        expect(healthy.last.isClosed, isTrue);
        expect(clock.active, isEmpty);
        await failing?.cancel();
        await subscription.cancel();
      },
    );

    test(
      'session finalization is explicit and repeat close is harmless',
      () async {
        final clock = _Clock();
        final grouper = LiveTranscriptGrouper(
          nowMs: () => clock.now,
          timerFactory: clock.timer,
        );
        final updates = <LiveTranscriptUpdate>[];
        final subscription = grouper.updates.listen(updates.add);
        grouper
          ..push(_text('last'))
          ..push(_final())
          ..close();
        await _pump();
        expect(grouper.isSessionFinalized, isTrue);
        expect(updates.last.reason, LiveTranscriptCloseReason.sessionClosed);
        expect(clock.active, isEmpty);
        await subscription.cancel();
      },
    );
  });
}

final class _Clock {
  double now = 0;
  final List<_FakeTimer> _timers = [];
  List<_FakeTimer> get active =>
      _timers.where((timer) => timer.isActive).toList();
  Timer timer(Duration delay, void Function() callback) {
    final timer = _FakeTimer(now + delay.inMilliseconds, callback);
    _timers.add(timer);
    return timer;
  }

  Future<void> advance(double milliseconds) async {
    final target = now + milliseconds;
    var iterations = 0;
    while (true) {
      final ready = active.where((timer) => timer.deadline <= target).toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));
      if (ready.isEmpty) break;
      if (++iterations > 10000) fail('Timer did not make progress.');
      now = ready.first.deadline;
      ready.first.fire();
      await _pump();
    }
    now = target;
    await _pump();
  }
}

final class _FakeTimer implements Timer {
  _FakeTimer(this.deadline, this.callback);
  final double deadline;
  final void Function() callback;
  bool _active = true;
  int _tick = 0;
  @override
  bool get isActive => _active;
  @override
  int get tick => _tick;
  @override
  void cancel() => _active = false;
  void fire() {
    if (!_active) return;
    _active = false;
    _tick++;
    callback();
  }

  void fireEvenIfCanceled() => callback();
}
