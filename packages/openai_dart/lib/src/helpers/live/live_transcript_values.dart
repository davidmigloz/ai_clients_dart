// Copyright 2026 OpenAI.
// SPDX-License-Identifier: Apache-2.0
// Adapted from OpenAI's Live transcript helpers for Dart by ai_clients_dart
// contributors. See THIRD_PARTY_NOTICES.md and licenses/openai-sdk-apache-2.0.txt.

import 'package:meta/meta.dart';

/// Speaker inferred from the public input or output transcript event type.
enum LiveTranscriptSpeaker {
  /// Input transcript text.
  user,

  /// Output transcript text.
  assistant,
}

/// Why a local display segment stopped receiving updates.
///
/// None of these reasons confirms that audio finished playing.
enum LiveTranscriptCloseReason {
  /// The grouping policy promoted another speaker.
  speakerChange,

  /// Assistant transcript source time or local inactivity reached its threshold.
  inactivity,

  /// An earlier source timestamp or explicit reset began another timeline.
  timestampReset,

  /// A public session.closed event confirmed backend session finalization.
  sessionClosed,

  /// The caller finished or detached this projection.
  manual,

  /// An attached event stream ended without a session.closed event.
  transportClosed,
}

/// Immutable thresholds for the official SDK speaker and backchannel policy.
@immutable
final class LiveTranscriptOptions {
  /// Creates validated thresholds in milliseconds, including fractional values.
  LiveTranscriptOptions({
    this.minTurnSeparationMs = 500,
    this.assistantSilenceMs = 2000,
    this.backchannelMaxDurationMs = 1000,
    this.backchannelIsolationMs = 2000,
    List<String> additionalAcknowledgments = const [],
  }) : additionalAcknowledgments = List.unmodifiable(
         additionalAcknowledgments,
       ) {
    _threshold(minTurnSeparationMs, 'minTurnSeparationMs');
    _threshold(assistantSilenceMs, 'assistantSilenceMs');
    _threshold(backchannelMaxDurationMs, 'backchannelMaxDurationMs');
    _threshold(backchannelIsolationMs, 'backchannelIsolationMs');
  }

  /// Minimum source gap before promoting buffered assistant text.
  final double minTurnSeparationMs;

  /// Assistant text inactivity threshold; not a VAD or playback signal.
  final double assistantSilenceMs;

  /// Shorter acknowledgments may be suppressed. Zero disables suppression.
  final double backchannelMaxDurationMs;

  /// Isolation window distinguishing acknowledgments from replies.
  final double backchannelIsolationMs;

  /// Extra acknowledgment phrases, copied and normalized by the grouping policy.
  final List<String> additionalAcknowledgments;

  /// Copies every option. An empty list clears the additional phrases.
  LiveTranscriptOptions copyWith({
    double? minTurnSeparationMs,
    double? assistantSilenceMs,
    double? backchannelMaxDurationMs,
    double? backchannelIsolationMs,
    List<String>? additionalAcknowledgments,
  }) => LiveTranscriptOptions(
    minTurnSeparationMs: minTurnSeparationMs ?? this.minTurnSeparationMs,
    assistantSilenceMs: assistantSilenceMs ?? this.assistantSilenceMs,
    backchannelMaxDurationMs:
        backchannelMaxDurationMs ?? this.backchannelMaxDurationMs,
    backchannelIsolationMs:
        backchannelIsolationMs ?? this.backchannelIsolationMs,
    additionalAcknowledgments:
        additionalAcknowledgments ?? this.additionalAcknowledgments,
  );

  @override
  bool operator ==(Object other) =>
      other is LiveTranscriptOptions &&
      minTurnSeparationMs == other.minTurnSeparationMs &&
      assistantSilenceMs == other.assistantSilenceMs &&
      backchannelMaxDurationMs == other.backchannelMaxDurationMs &&
      backchannelIsolationMs == other.backchannelIsolationMs &&
      _sameStrings(additionalAcknowledgments, other.additionalAcknowledgments);

  @override
  int get hashCode => Object.hash(
    minTurnSeparationMs,
    assistantSilenceMs,
    backchannelMaxDurationMs,
    backchannelIsolationMs,
    Object.hashAll(additionalAcknowledgments),
  );

  @override
  String toString() =>
      'LiveTranscriptOptions(minTurnSeparationMs: $minTurnSeparationMs, '
      'assistantSilenceMs: $assistantSilenceMs, '
      'backchannelMaxDurationMs: $backchannelMaxDurationMs, '
      'backchannelIsolationMs: $backchannelIsolationMs, '
      'additionalAcknowledgments: ${additionalAcknowledgments.length} phrases)';
}

/// A timed text fragment supplied to the pure grouping policy.
@immutable
final class LiveTranscriptFragment {
  /// Creates a source interval. Its timestamps are session milliseconds.
  LiveTranscriptFragment({
    required this.speaker,
    required this.text,
    required this.startMs,
    required this.endMs,
  }) {
    _validateTranscriptInterval(startMs, endMs);
  }

  /// Input or output speaker.
  final LiveTranscriptSpeaker speaker;

  /// Original append-only text, explicitly accessible and excluded from logs.
  final String text;

  /// Beginning of the source interval.
  final int startMs;

  /// End of the source interval, possibly equal to its beginning.
  final int endMs;

  /// Copies all fields.
  LiveTranscriptFragment copyWith({
    LiveTranscriptSpeaker? speaker,
    String? text,
    int? startMs,
    int? endMs,
  }) => LiveTranscriptFragment(
    speaker: speaker ?? this.speaker,
    text: text ?? this.text,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
  );

  @override
  bool operator ==(Object other) =>
      other is LiveTranscriptFragment &&
      speaker == other.speaker &&
      text == other.text &&
      startMs == other.startMs &&
      endMs == other.endMs;

  @override
  int get hashCode => Object.hash(speaker, text, startMs, endMs);

  @override
  String toString() =>
      'LiveTranscriptFragment(speaker: ${speaker.name}, '
      'text: ${text.length} chars, startMs: $startMs, endMs: $endMs)';
}

/// Immutable display text projected from public Live transcript intervals.
@immutable
final class LiveTranscriptSegment {
  /// Creates a local segment snapshot, not a server conversation item.
  LiveTranscriptSegment({
    required this.id,
    this.previousId,
    required this.speaker,
    required this.text,
    required this.startMs,
    required this.endMs,
  }) {
    if (id.isEmpty || previousId == '') {
      throw ArgumentError('Transcript projection IDs must not be empty.');
    }
    _validateTranscriptInterval(startMs, endMs);
  }

  /// Stable ID local to the helper; never a server turn or item ID.
  final String id;

  /// Previous emitted local segment, or null for the first.
  final String? previousId;

  /// Speaker represented by this segment.
  final LiveTranscriptSpeaker speaker;

  /// Complete text. Replace displayed text for this ID on each update.
  final String text;

  /// Start of the first contributing source interval.
  final int startMs;

  /// Latest contributing source end; never a playback completion time.
  final int endMs;

  /// Copies every field; [clearPreviousId] clears its optional predecessor.
  LiveTranscriptSegment copyWith({
    String? id,
    String? previousId,
    bool clearPreviousId = false,
    LiveTranscriptSpeaker? speaker,
    String? text,
    int? startMs,
    int? endMs,
  }) => LiveTranscriptSegment(
    id: id ?? this.id,
    previousId: clearPreviousId ? null : (previousId ?? this.previousId),
    speaker: speaker ?? this.speaker,
    text: text ?? this.text,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
  );

  @override
  bool operator ==(Object other) =>
      other is LiveTranscriptSegment &&
      id == other.id &&
      previousId == other.previousId &&
      speaker == other.speaker &&
      text == other.text &&
      startMs == other.startMs &&
      endMs == other.endMs;

  @override
  int get hashCode =>
      Object.hash(id, previousId, speaker, text, startMs, endMs);

  @override
  String toString() =>
      'LiveTranscriptSegment(id: ${id.length} chars, '
      'previousId: ${previousId == null ? null : '${previousId!.length} chars'}, '
      'speaker: ${speaker.name}, '
      'text: ${text.length} chars, startMs: $startMs, endMs: $endMs, '
      'hasPreviousId: ${previousId != null})';
}

/// One complete segment snapshot, optionally finalized by a local decision.
@immutable
final class LiveTranscriptUpdate {
  /// Creates an update; null [reason] means the segment remains open.
  const LiveTranscriptUpdate({required this.segment, this.reason});

  /// Immutable current or final snapshot.
  final LiveTranscriptSegment segment;

  /// Final grouping reason, or null for an updated segment.
  final LiveTranscriptCloseReason? reason;

  /// Whether this is the final snapshot for this local segment.
  bool get isClosed => reason != null;

  /// Copies all fields; [clearReason] creates an open update.
  LiveTranscriptUpdate copyWith({
    LiveTranscriptSegment? segment,
    LiveTranscriptCloseReason? reason,
    bool clearReason = false,
  }) => LiveTranscriptUpdate(
    segment: segment ?? this.segment,
    reason: clearReason ? null : (reason ?? this.reason),
  );

  @override
  bool operator ==(Object other) =>
      other is LiveTranscriptUpdate &&
      segment == other.segment &&
      reason == other.reason;

  @override
  int get hashCode => Object.hash(segment, reason);

  @override
  String toString() =>
      'LiveTranscriptUpdate(segment: $segment, reason: ${reason?.name})';
}

/// Caller-supplied mapping between source and playback clocks.
///
/// This projection schedules no media and makes no audible-completion claim.
@immutable
final class LiveTranscriptPlayback {
  /// Creates a pure affine timeline mapping with a positive playback [rate].
  LiveTranscriptPlayback({
    required this.segment,
    required this.sourceAnchorMs,
    required this.playbackAnchorMs,
    this.rate = 1,
  }) {
    if (!sourceAnchorMs.isFinite ||
        !playbackAnchorMs.isFinite ||
        !rate.isFinite ||
        rate <= 0) {
      throw ArgumentError('Playback anchors must be finite and rate positive.');
    }
    if (!startMs.isFinite || !endMs.isFinite) {
      throw ArgumentError('Projected playback interval must be finite.');
    }
  }

  /// Original immutable text and source interval.
  final LiveTranscriptSegment segment;

  /// Position on the session source clock supplied by the caller.
  final double sourceAnchorMs;

  /// Corresponding position on the caller's playback clock.
  final double playbackAnchorMs;

  /// Source milliseconds consumed per playback millisecond.
  final double rate;

  /// Projected start; may precede zero or the playback anchor.
  double get startMs =>
      playbackAnchorMs + (segment.startMs - sourceAnchorMs) / rate;

  /// Projected end; does not confirm queued audio played.
  double get endMs =>
      playbackAnchorMs + (segment.endMs - sourceAnchorMs) / rate;

  /// Copies every mapping field without changing the original segment.
  LiveTranscriptPlayback copyWith({
    LiveTranscriptSegment? segment,
    double? sourceAnchorMs,
    double? playbackAnchorMs,
    double? rate,
  }) => LiveTranscriptPlayback(
    segment: segment ?? this.segment,
    sourceAnchorMs: sourceAnchorMs ?? this.sourceAnchorMs,
    playbackAnchorMs: playbackAnchorMs ?? this.playbackAnchorMs,
    rate: rate ?? this.rate,
  );

  @override
  bool operator ==(Object other) =>
      other is LiveTranscriptPlayback &&
      segment == other.segment &&
      sourceAnchorMs == other.sourceAnchorMs &&
      playbackAnchorMs == other.playbackAnchorMs &&
      rate == other.rate;

  @override
  int get hashCode =>
      Object.hash(segment, sourceAnchorMs, playbackAnchorMs, rate);

  @override
  String toString() =>
      'LiveTranscriptPlayback(segment: $segment, sourceAnchorMs: '
      '$sourceAnchorMs, playbackAnchorMs: $playbackAnchorMs, rate: $rate)';
}

/// Projects transcript source timing onto an explicitly supplied playback clock.
LiveTranscriptPlayback projectLiveTranscriptPlayback(
  LiveTranscriptSegment segment, {
  required double sourceAnchorMs,
  required double playbackAnchorMs,
  double rate = 1,
}) => LiveTranscriptPlayback(
  segment: segment,
  sourceAnchorMs: sourceAnchorMs,
  playbackAnchorMs: playbackAnchorMs,
  rate: rate,
);

void _threshold(double value, String field) {
  if (!value.isFinite || value < 0 || value > 2147483647) {
    throw ArgumentError('$field must be finite and between 0 and 2147483647.');
  }
}

void _validateTranscriptInterval(int startMs, int endMs) {
  if (!startMs.isFinite ||
      !endMs.isFinite ||
      startMs < 0 ||
      endMs < startMs ||
      endMs > 9007199254740991) {
    throw ArgumentError('Transcript interval must be nonnegative and safe.');
  }
}

bool _sameStrings(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
