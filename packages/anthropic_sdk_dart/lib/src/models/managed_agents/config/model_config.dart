import 'package:meta/meta.dart';

import '../../beta/config/output_config.dart' show EffortLevel;
import '../../common/copy_with_sentinel.dart';
import 'effort_params.dart';

/// Inference speed mode for agents.
enum AgentSpeed {
  /// Standard throughput mode.
  standard('standard'),

  /// Fast mode (premium pricing).
  fast('fast'),

  /// Unknown speed mode — fallback for unrecognized values.
  unknown('unknown');

  const AgentSpeed(this.value);

  /// JSON value for this speed mode.
  final String value;

  /// Parses an [AgentSpeed] from JSON.
  static AgentSpeed fromJson(String value) => switch (value) {
    'standard' => AgentSpeed.standard,
    'fast' => AgentSpeed.fast,
    _ => AgentSpeed.unknown,
  };

  /// Converts this speed mode to JSON.
  String toJson() => value;
}

/// Model identifier and configuration as returned in API responses.
@immutable
class ModelConfig {
  /// The model identifier string.
  final String id;

  /// Inference speed mode.
  final AgentSpeed? speed;

  /// Response effort level for model generation, e.g. `{"type": "high"}`.
  final EffortLevel? effort;

  /// Creates a [ModelConfig].
  const ModelConfig({required this.id, this.speed, this.effort});

  /// Creates a [ModelConfig] from JSON.
  factory ModelConfig.fromJson(Map<String, dynamic> json) {
    return ModelConfig(
      id: json['id'] as String,
      speed: json['speed'] != null
          ? AgentSpeed.fromJson(json['speed'] as String)
          : null,
      effort: json['effort'] != null
          ? EffortLevel.fromJson(
              (json['effort'] as Map<String, dynamic>)['type'] as String,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    if (speed != null) 'speed': speed!.toJson(),
    if (effort != null) 'effort': {'type': effort!.toJson()},
  };

  /// Creates a copy with replaced values.
  ModelConfig copyWith({
    String? id,
    Object? speed = unsetCopyWithValue,
    Object? effort = unsetCopyWithValue,
  }) {
    return ModelConfig(
      id: id ?? this.id,
      speed: speed == unsetCopyWithValue ? this.speed : speed as AgentSpeed?,
      effort: effort == unsetCopyWithValue
          ? this.effort
          : effort as EffortLevel?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelConfig &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          speed == other.speed &&
          effort == other.effort;

  @override
  int get hashCode => Object.hash(id, speed, effort);

  @override
  String toString() => 'ModelConfig(id: $id, speed: $speed, effort: $effort)';
}

/// Model parameter — either a simple model ID string or a [ModelConfig].
///
/// Variants:
/// - [ModelParamsId] — a plain model ID string.
/// - [ModelParamsConfig] — a [ModelConfig] object.
sealed class ModelParams {
  const ModelParams();

  /// Creates a [ModelParams] from JSON.
  ///
  /// If [json] is a [String], returns [ModelParamsId].
  /// Otherwise expects a [Map] and returns [ModelParamsConfig].
  static ModelParams fromJson(Object json) {
    if (json is String) {
      return ModelParamsId(id: json);
    }
    return ModelParamsConfig.fromJson(json as Map<String, dynamic>);
  }

  /// Converts to JSON.
  Object toJson();
}

/// A plain model ID string.
@immutable
class ModelParamsId extends ModelParams {
  /// The model identifier.
  final String id;

  /// Creates a [ModelParamsId].
  const ModelParamsId({required this.id});

  @override
  Object toJson() => id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelParamsId &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ModelParamsId(id: $id)';
}

/// A model configuration object with optional speed setting.
///
/// [effort] distinguishes omission from an explicit `null` on update: omitting
/// the field (and [clearEffort]) leaves the stored effort unchanged, while
/// passing `clearEffort: true` emits an explicit JSON `null` that resets it to
/// the model's default effort.
@immutable
class ModelParamsConfig extends ModelParams {
  /// The model identifier.
  final String id;

  /// Inference speed mode.
  final AgentSpeed? speed;

  /// Response effort level for model generation — a bare level string or an
  /// object with a `type` field.
  ///
  /// Leave both this and [clearEffort] at their defaults to preserve the
  /// current value on update; set this to reset it to a new value; or pass
  /// `clearEffort: true` (with this left `null`) to reset it to the model's
  /// default.
  final EffortParams? effort;

  /// Whether to emit an explicit JSON `null` for `effort`, resetting it to
  /// the model's default. Ignored — and must be `false` — when [effort] is
  /// non-null.
  final bool clearEffort;

  /// Creates a [ModelParamsConfig].
  const ModelParamsConfig({
    required this.id,
    this.speed,
    this.effort,
    this.clearEffort = false,
  }) : assert(
         effort == null || !clearEffort,
         'Cannot pass both a non-null effort and clearEffort: true',
       );

  /// Creates a [ModelParamsConfig] from JSON.
  factory ModelParamsConfig.fromJson(Map<String, dynamic> json) {
    return ModelParamsConfig(
      id: json['id'] as String,
      speed: json['speed'] != null
          ? AgentSpeed.fromJson(json['speed'] as String)
          : null,
      effort: json['effort'] != null
          ? EffortParams.fromJson(json['effort'] as Object)
          : null,
      clearEffort: json.containsKey('effort') && json['effort'] == null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    if (speed != null) 'speed': speed!.toJson(),
    if (effort != null)
      'effort': effort!.toJson()
    else if (clearEffort)
      'effort': null,
  };

  /// Creates a copy with replaced values.
  ///
  /// Omit [effort] to preserve its current value (including whether it is
  /// currently marked for clearing). Pass `null` explicitly to reset it to
  /// the model's default; pass a value to replace it. Pass
  /// `clearEffort: false` to return a cleared instance to the omitted /
  /// no-change state.
  ModelParamsConfig copyWith({
    String? id,
    Object? speed = unsetCopyWithValue,
    Object? effort = unsetCopyWithValue,
    bool? clearEffort,
  }) {
    final effortSet = effort != unsetCopyWithValue;
    assert(
      !(clearEffort ?? false) || !effortSet || effort == null,
      'Cannot pass both a non-null effort and clearEffort: true',
    );
    final clear =
        clearEffort ?? (effortSet ? effort == null : this.clearEffort);
    return ModelParamsConfig(
      id: id ?? this.id,
      speed: speed == unsetCopyWithValue ? this.speed : speed as AgentSpeed?,
      effort: clear
          ? null
          : (effortSet ? effort as EffortParams? : this.effort),
      clearEffort: clear,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelParamsConfig &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          speed == other.speed &&
          effort == other.effort &&
          clearEffort == other.clearEffort;

  @override
  int get hashCode => Object.hash(id, speed, effort, clearEffort);

  @override
  String toString() =>
      'ModelParamsConfig(id: $id, speed: $speed, effort: $effort, '
      'clearEffort: $clearEffort)';
}
