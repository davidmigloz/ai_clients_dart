import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

// =============================================================================
// RealtimeTruncation
// =============================================================================

/// Truncation strategy for Realtime sessions.
///
/// A discriminated union covering the three supported strategies:
///
/// - [TruncationAuto] — string `"auto"`, the default truncation behaviour.
/// - [TruncationDisabled] — string `"disabled"`, errors when context exceeds the
///   token limit instead of dropping older messages.
/// - [TruncationRetentionRatio] — object with `type: "retention_ratio"`, retains a
///   configurable fraction of the conversation when truncating.
///
/// An [UnknownRealtimeTruncation] fallback preserves any unrecognised payload
/// so future server additions do not break existing clients.
sealed class RealtimeTruncation {
  const RealtimeTruncation();

  /// Auto strategy.
  const factory RealtimeTruncation.auto() = TruncationAuto;

  /// Disabled strategy.
  const factory RealtimeTruncation.disabled() = TruncationDisabled;

  /// Retention-ratio strategy.
  const factory RealtimeTruncation.retentionRatio({
    required double retentionRatio,
    int? postInstructionsTokenLimit,
  }) = TruncationRetentionRatio;

  /// Creates from JSON.
  ///
  /// Accepts either the bare strings `"auto"`/`"disabled"` or an object with a
  /// `type: "retention_ratio"` discriminator. Any other shape returns an
  /// [UnknownRealtimeTruncation] preserving the raw payload.
  factory RealtimeTruncation.fromJson(Object json) {
    if (json == 'auto') return const TruncationAuto();
    if (json == 'disabled') return const TruncationDisabled();
    if (json is Map<String, dynamic>) {
      if (json['type'] == 'retention_ratio') {
        return TruncationRetentionRatio.fromJson(json);
      }
      return UnknownRealtimeTruncation(json);
    }
    return UnknownRealtimeTruncation({'value': json});
  }

  /// Converts to JSON.
  ///
  /// Returns either a string (`"auto"`/`"disabled"`) or a `Map`.
  Object toJson();
}

/// `auto` truncation strategy.
@immutable
class TruncationAuto extends RealtimeTruncation {
  /// Creates a [TruncationAuto].
  const TruncationAuto();

  @override
  Object toJson() => 'auto';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TruncationAuto && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'auto'.hashCode;

  @override
  String toString() => 'RealtimeTruncation.auto()';
}

/// `disabled` truncation strategy.
@immutable
class TruncationDisabled extends RealtimeTruncation {
  /// Creates a [TruncationDisabled].
  const TruncationDisabled();

  @override
  Object toJson() => 'disabled';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TruncationDisabled && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'disabled'.hashCode;

  @override
  String toString() => 'RealtimeTruncation.disabled()';
}

/// Retention-ratio truncation strategy.
///
/// Retains [retentionRatio] (0.0–1.0) of the post-instruction conversation
/// tokens when the conversation exceeds the input token limit. Optionally
/// accepts a custom [postInstructionsTokenLimit].
@immutable
class TruncationRetentionRatio extends RealtimeTruncation {
  /// Creates a [TruncationRetentionRatio].
  const TruncationRetentionRatio({
    required this.retentionRatio,
    this.postInstructionsTokenLimit,
  });

  /// Creates from JSON.
  factory TruncationRetentionRatio.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'retention_ratio') {
      throw FormatException(
        'TruncationRetentionRatio.fromJson expected type "retention_ratio", '
        'got ${json['type']}',
      );
    }
    if (json['retention_ratio'] == null) {
      throw const FormatException(
        'TruncationRetentionRatio.fromJson missing required "retention_ratio" field',
      );
    }
    final tokenLimits = json['token_limits'] as Map<String, dynamic>?;
    return TruncationRetentionRatio(
      retentionRatio: (json['retention_ratio'] as num).toDouble(),
      postInstructionsTokenLimit: tokenLimits?['post_instructions'] as int?,
    );
  }

  /// Fraction of post-instruction tokens to retain (0.0–1.0).
  final double retentionRatio;

  /// Optional custom post-instructions token limit.
  final int? postInstructionsTokenLimit;

  /// The discriminator value. Always `"retention_ratio"`.
  String get type => 'retention_ratio';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'retention_ratio': retentionRatio,
    if (postInstructionsTokenLimit != null)
      'token_limits': {'post_instructions': postInstructionsTokenLimit},
  };

  /// Returns a copy of this [TruncationRetentionRatio] with the given fields replaced.
  ///
  /// Pass `null` for [postInstructionsTokenLimit] to clear the existing value.
  TruncationRetentionRatio copyWith({
    double? retentionRatio,
    Object? postInstructionsTokenLimit = unsetCopyWithValue,
  }) => TruncationRetentionRatio(
    retentionRatio: retentionRatio ?? this.retentionRatio,
    postInstructionsTokenLimit:
        identical(postInstructionsTokenLimit, unsetCopyWithValue)
        ? this.postInstructionsTokenLimit
        : postInstructionsTokenLimit as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TruncationRetentionRatio &&
          runtimeType == other.runtimeType &&
          retentionRatio == other.retentionRatio &&
          postInstructionsTokenLimit == other.postInstructionsTokenLimit;

  @override
  int get hashCode => Object.hash(retentionRatio, postInstructionsTokenLimit);

  @override
  String toString() =>
      'TruncationRetentionRatio(retentionRatio: $retentionRatio, '
      'postInstructionsTokenLimit: $postInstructionsTokenLimit)';
}

/// Forward-compatible fallback for unknown [RealtimeTruncation] payloads.
///
/// Preserves the raw JSON so the value can round-trip without loss.
@immutable
class UnknownRealtimeTruncation extends RealtimeTruncation {
  /// Creates an [UnknownRealtimeTruncation] from the raw JSON.
  const UnknownRealtimeTruncation(this.json);

  /// The raw JSON map preserved verbatim.
  final Map<String, dynamic> json;

  @override
  Object toJson() {
    if (json.length == 1 && json.containsKey('value')) {
      return json['value'] as Object;
    }
    return Map<String, dynamic>.from(json);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownRealtimeTruncation &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(json, other.json);

  @override
  int get hashCode => mapDeepHashCode(json);

  @override
  String toString() => 'UnknownRealtimeTruncation($json)';
}
