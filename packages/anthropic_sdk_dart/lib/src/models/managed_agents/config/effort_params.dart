import 'package:meta/meta.dart';

import '../../beta/config/output_config.dart' show EffortLevel;

/// Effort parameter for a session or agent — either a bare effort-level
/// string or an object carrying a `type` discriminator.
///
/// Variants:
/// - [EffortParamsLevel] — a bare effort-level string (e.g. `"high"`).
/// - [EffortParamsObject] — an object with a `type` field (e.g.
///   `{"type": "high"}`).
sealed class EffortParams {
  const EffortParams();

  /// Creates an [EffortParams] from JSON.
  ///
  /// If [json] is a [String], returns [EffortParamsLevel]. Otherwise expects
  /// a [Map] and returns [EffortParamsObject].
  static EffortParams fromJson(Object json) {
    if (json is String) {
      return EffortParamsLevel(EffortLevel.fromJson(json));
    }
    final map = json as Map<String, dynamic>;
    return EffortParamsObject(EffortLevel.fromJson(map['type'] as String));
  }

  /// Converts to JSON.
  Object toJson();
}

/// A bare effort-level string, e.g. `"high"`.
@immutable
class EffortParamsLevel extends EffortParams {
  /// The effort level.
  final EffortLevel level;

  /// Creates an [EffortParamsLevel].
  const EffortParamsLevel(this.level);

  @override
  Object toJson() => level.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EffortParamsLevel &&
          runtimeType == other.runtimeType &&
          level == other.level;

  @override
  int get hashCode => level.hashCode;

  @override
  String toString() => 'EffortParamsLevel(level: $level)';
}

/// An effort object with a `type` discriminator, e.g. `{"type": "high"}`.
@immutable
class EffortParamsObject extends EffortParams {
  /// The effort level.
  final EffortLevel level;

  /// Creates an [EffortParamsObject].
  const EffortParamsObject(this.level);

  @override
  Object toJson() => {'type': level.toJson()};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EffortParamsObject &&
          runtimeType == other.runtimeType &&
          level == other.level;

  @override
  int get hashCode => level.hashCode;

  @override
  String toString() => 'EffortParamsObject(level: $level)';
}
