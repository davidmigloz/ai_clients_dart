// Copyright 2026 OpenAI.
// SPDX-License-Identifier: Apache-2.0
// Adapted from OpenAI's Live transcript helpers for Dart by ai_clients_dart
// contributors. See THIRD_PARTY_NOTICES.md and licenses/openai-sdk-apache-2.0.txt.

import 'dart:async';
import 'dart:math' as math;

import '../../models/live/live_server_events.dart';
import '../../resources/live/live_connection.dart';
import 'live_transcript_grouping.dart';
import 'live_transcript_values.dart';

/// Injected monotonic clock, in local milliseconds, distinct from source time.
typedef LiveTranscriptClock = double Function();

/// Timer seam for deterministic offline clocks; the returned timer is owned.
typedef LiveTranscriptTimerFactory =
    Timer Function(Duration delay, void Function() callback);

/// Value-safe failure encountered by the helper's independent event tap.
final class LiveTranscriptAttachmentException implements Exception {
  /// Creates a diagnostic without copying event text or transport values.
  const LiveTranscriptAttachmentException(this.cause);

  /// Original error, available only through explicit inspection.
  final Object cause;

  @override
  String toString() => 'LiveTranscriptAttachmentException: event tap failed';
}

/// Clock-driven grouping of public Live transcript additions.
///
/// This ports the SDK speaker/backchannel policy, including its 50 ms speaker
/// settle window and local monotonic inactivity fallback. Duplicates are ignored;
/// out-of-order source starts finalize the old timestamp epoch. Some assistant
/// acknowledgments are suppressed. This is not VAD, audio playback tracking or a
/// lossless transcript. Raw events remain available on the connection.
///
/// One instance belongs to one session. [close] cancels only its timers and event
/// tap. It never closes a connection, borrowed socket, data channel or media.
final class LiveTranscriptGrouper {
  /// Creates the policy with optional deterministic local clock/timer seams.
  LiveTranscriptGrouper({
    LiveTranscriptOptions? options,
    LiveTranscriptClock? nowMs,
    LiveTranscriptTimerFactory? timerFactory,
  }) : _grouping = LiveTranscriptGrouping(
         options: options,
         idPrefix: 'segment_${_nextGrouperId++}',
       ),
       _now = nowMs ?? _monotonicClock(),
       _timerFactory = timerFactory ?? Timer.new;

  static var _nextGrouperId = 0;
  final LiveTranscriptGrouping _grouping;
  final LiveTranscriptClock _now;
  final LiveTranscriptTimerFactory _timerFactory;
  final _updates = StreamController<LiveTranscriptUpdate>.broadcast();
  final Set<String> _seenIds = {};
  final List<_ReceivedFragment> _pending = [];
  final Map<String, LiveTranscriptSegment> _segments = {};
  Timer? _timer;
  var _timerGeneration = 0;
  double? _anchorSourceMs;
  double? _anchorReceivedAt;
  int? _lastStartMs;
  bool _closed = false;
  LiveTranscriptCloseReason? _completionReason;
  LiveTranscriptAttachment? _attachment;

  /// Independent broadcast snapshots; listeners never consume raw Live events.
  ///
  /// Dart stream callbacks are asynchronous and preserve per-listener ordering.
  /// A listener failure goes to its zone and does not stop state/timer cleanup or
  /// another listener. No history is replayed to listeners attaching late.
  Stream<LiveTranscriptUpdate> get updates => _updates.stream;

  /// Complete latest snapshots in local emission order, copied on each access.
  List<LiveTranscriptSegment> get segments =>
      List.unmodifiable(_segments.values);

  /// Immutable resolved configuration.
  LiveTranscriptOptions get options => _grouping.options;

  /// Whether this projection stopped accepting events.
  bool get isClosed => _closed;

  /// True only after the helper observed a public session.closed event.
  bool get isSessionFinalized =>
      _completionReason == LiveTranscriptCloseReason.sessionClosed;

  /// Why this helper stopped; transport loss never implies session finalization.
  LiveTranscriptCloseReason? get completionReason => _completionReason;

  /// Consumes one event without modifying or retaining its raw JSON.
  ///
  /// Only input/output transcript additions and session.closed change grouping.
  /// Transcript IDs must be nonempty and timestamps nonnegative safe integers.
  /// Empty text is marked seen but does not restart inactivity. Invalid consumed
  /// values and use after closure fail before changing the projection.
  void push(LiveServerEvent event) {
    _ensureOpen();
    if (event is LiveSessionClosed) {
      _finish(LiveTranscriptCloseReason.sessionClosed);
      return;
    }
    final LiveTranscriptFragment fragment;
    final String id;
    switch (event) {
      case LiveInputTranscriptDelta():
        id = event.eventId;
        fragment = LiveTranscriptFragment(
          speaker: LiveTranscriptSpeaker.user,
          text: event.delta,
          startMs: event.startMs,
          endMs: event.endMs,
        );
      case LiveOutputTranscriptDelta():
        id = event.eventId;
        fragment = LiveTranscriptFragment(
          speaker: LiveTranscriptSpeaker.assistant,
          text: event.delta,
          startMs: event.startMs,
          endMs: event.endMs,
        );
      default:
        return;
    }
    if (id.isEmpty) {
      throw ArgumentError('Transcript event ID must not be empty.');
    }
    if (_seenIds.contains(id)) return;
    final receivedAt = _clockNow();
    _seenIds.add(id);
    if (fragment.text.isEmpty) return;
    final received = _ReceivedFragment(fragment, receivedAt);
    final changes = <LiveTranscriptUpdate>[];
    final pending = _pending.isEmpty ? null : _pending.first.fragment;
    if (pending != null &&
        pending.startMs == fragment.startMs &&
        pending.endMs == fragment.endMs) {
      _pending.add(received);
      if (_pending.any((part) => part.fragment.speaker != fragment.speaker)) {
        changes.addAll(_flushPending());
      }
    } else {
      changes.addAll(_flushPending());
      if (_grouping.speaker == fragment.speaker) {
        changes.addAll(_commit([received]));
      } else {
        _pending.add(received);
      }
    }
    _schedule();
    _dispatch(changes);
  }

  /// Settles pending fragments and resolves elapsed time without finalizing.
  void flush() {
    _ensureOpen();
    final changes = _flushPending()..addAll(_grouping.advance(_sourceNow()));
    _schedule();
    _dispatch(changes);
  }

  /// Finalizes this epoch and deliberately clears deduplication and source clocks.
  ///
  /// Local IDs continue monotonically. [clearSegments] clears retained display
  /// snapshots only; raw transport state and another helper remain untouched.
  void reset({bool clearSegments = false}) {
    _ensureOpen();
    _clearTimer();
    final changes = _flushPending()
      ..addAll(
        _grouping.finish(
          _sourceNow(),
          reason: LiveTranscriptCloseReason.timestampReset,
        ),
      );
    _seenIds.clear();
    _anchorSourceMs = null;
    _anchorReceivedAt = null;
    _lastStartMs = null;
    _dispatch(changes);
    if (clearSegments) _segments.clear();
  }

  /// Finalizes once and cancels owned timers/tap without closing the transport.
  void close() => _finish(LiveTranscriptCloseReason.manual);

  /// Attaches one non-consuming tap to a connection's broadcast event stream.
  ///
  /// Application listeners and other groupers keep their independent taps.
  /// The returned attachment owns only its subscription and this grouper's
  /// timers. Detaching finishes this helper; it never sends session.close.
  LiveTranscriptAttachment attach(LiveConnection connection) {
    _ensureOpen();
    if (_attachment != null) {
      throw StateError('This transcript grouper already has an event tap.');
    }
    final attachment = LiveTranscriptAttachment._(this);
    _attachment = attachment;
    attachment._subscription = connection.events.listen(
      (event) {
        if (_closed) return;
        try {
          push(event);
        } catch (error, stackTrace) {
          if (!_updates.isClosed) {
            _updates.addError(
              LiveTranscriptAttachmentException(error),
              stackTrace,
            );
          }
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!_updates.isClosed) {
          _updates.addError(
            LiveTranscriptAttachmentException(error),
            stackTrace,
          );
        }
      },
      onDone: () => _finish(LiveTranscriptCloseReason.transportClosed),
    );
    return attachment;
  }

  void _ensureOpen() {
    if (_closed) throw StateError('Transcript grouper is closed.');
  }

  double _clockNow() {
    final value = _now();
    if (!value.isFinite || value < 0) {
      throw StateError(
        'Transcript local clock must be finite and nonnegative.',
      );
    }
    return value;
  }

  List<LiveTranscriptUpdate> _commit(List<_ReceivedFragment> fragments) {
    if (fragments.isEmpty) return [];
    final first = fragments.first.fragment;
    final changes = <LiveTranscriptUpdate>[];
    if (_lastStartMs != null && first.startMs < _lastStartMs!) {
      changes.addAll(
        _grouping.finish(
          _sourceNow(),
          reason: LiveTranscriptCloseReason.timestampReset,
        ),
      );
      _anchorSourceMs = null;
      _anchorReceivedAt = null;
    }
    _lastStartMs = first.startMs;
    _anchorSourceMs = math.max(_anchorSourceMs ?? 0, first.endMs.toDouble());
    _anchorReceivedAt = fragments.first.receivedAt;
    for (final part in fragments) {
      _anchorSourceMs = math.max(
        _anchorSourceMs!,
        part.fragment.endMs.toDouble(),
      );
      _anchorReceivedAt = math.max(_anchorReceivedAt!, part.receivedAt);
    }
    changes.addAll(
      _grouping.process(fragments.map((part) => part.fragment).toList()),
    );
    return changes;
  }

  List<LiveTranscriptUpdate> _flushPending() {
    final pending = List<_ReceivedFragment>.of(_pending);
    _pending.clear();
    return _commit(pending);
  }

  double _sourceNow() => _anchorSourceMs == null
      ? 0
      : _anchorSourceMs! + math.max(0, _clockNow() - _anchorReceivedAt!);

  void _finish(LiveTranscriptCloseReason reason) {
    if (_closed) return;
    _closed = true;
    _completionReason = reason;
    _clearTimer();
    try {
      final changes = _flushPending()
        ..addAll(_grouping.finish(_sourceNow(), reason: reason));
      _dispatch(changes);
    } finally {
      _seenIds.clear();
      _pending.clear();
      unawaited(_attachment?._cancelOnly() ?? Future<void>.value());
      unawaited(_updates.close());
    }
  }

  void _clearTimer() {
    _timerGeneration++;
    _timer?.cancel();
    _timer = null;
  }

  void _schedule() {
    _clearTimer();
    if (_closed) return;
    final pending = _pending.isEmpty ? null : _pending.first;
    final deadline = _grouping.deadline;
    final double delay;
    if (pending != null) {
      delay = pending.receivedAt + 50 - _clockNow();
    } else if (deadline != null) {
      delay = deadline - _sourceNow();
    } else {
      return;
    }
    final generation = _timerGeneration;
    _timer = _timerFactory(
      Duration(milliseconds: math.min(2147483647, math.max(0, delay.ceil()))),
      () {
        if (generation != _timerGeneration || _closed) return;
        _timer = null;
        final changes = _flushPending()
          ..addAll(_grouping.advance(_sourceNow()));
        _schedule();
        _dispatch(changes);
      },
    );
  }

  void _dispatch(List<LiveTranscriptUpdate> changes) {
    for (final change in changes) {
      _segments[change.segment.id] = change.segment;
      _updates.add(change);
    }
  }
}

/// Owned listener for one helper, independent of application/other helper taps.
final class LiveTranscriptAttachment {
  LiveTranscriptAttachment._(this.grouper);

  /// Helper whose projection and timers belong to this attachment.
  final LiveTranscriptGrouper grouper;
  StreamSubscription<LiveServerEvent>? _subscription;
  Future<void>? _cancelFuture;
  bool _detached = false;

  /// Whether this listener has detached or its helper finished.
  bool get isDetached => _detached;

  /// Flushes/finishes this helper and cancels only this event subscription.
  Future<void> detach() {
    grouper.close();
    return _cancelOnly();
  }

  Future<void> _cancelOnly() {
    _detached = true;
    return _cancelFuture ??= _subscription?.cancel() ?? Future<void>.value();
  }
}

final class _ReceivedFragment {
  const _ReceivedFragment(this.fragment, this.receivedAt);
  final LiveTranscriptFragment fragment;
  final double receivedAt;
}

LiveTranscriptClock _monotonicClock() {
  final stopwatch = Stopwatch()..start();
  return () => stopwatch.elapsedMicroseconds / 1000;
}
