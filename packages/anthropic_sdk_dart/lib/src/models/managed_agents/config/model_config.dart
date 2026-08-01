import 'package:meta/meta.dart';

import '../../beta/config/output_config.dart' show EffortLevel;
import '../../common/copy_with_sentinel.dart';
import 'effort_params.dart';

/// Private sentinel to distinguish "not provided" from explicit `null`.
const Object _notSet = Object();

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
/// the field leaves the stored effort unchanged, while passing `null`
/// explicitly resets it to the model's default effort.
@immutable
class ModelParamsConfig extends ModelParams {
  /// The model identifier.
  final String id;

  /// Inference speed mode.
  final AgentSpeed? speed;

  /// Response effort level for model generation — a bare level string or an
  /// object with a `type` field.
  ///
  /// Omit to preserve the current value on update; pass `null` explicitly to
  /// reset it to the model's default.
  EffortParams? get effort =>
      _effort == _notSet ? null : _effort as EffortParams?;
  final Object? _effort;

  /// Creates a [ModelParamsConfig].
  ///
  /// Omit [effort] to preserve its current value on update. Pass `null`
  /// explicitly to reset it to the model's default.
  const ModelParamsConfig({
    required this.id,
    this.speed,
    Object? effort = _notSet,
  }) : _effort = effort;

  /// Creates a [ModelParamsConfig] from JSON.
  factory ModelParamsConfig.fromJson(Map<String, dynamic> json) {
    return ModelParamsConfig(
      id: json['id'] as String,
      speed: json['speed'] != null
          ? AgentSpeed.fromJson(json['speed'] as String)
          : null,
      effort: json.containsKey('effort')
          ? (json['effort'] != null
                ? EffortParams.fromJson(json['effort'] as Object)
                : null)
          : _notSet,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    if (speed != null) 'speed': speed!.toJson(),
    if (_effort != _notSet) 'effort': effort?.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// Omit [effort] to preserve its current value. Pass `null` explicitly to
  /// reset it to the model's default.
  ModelParamsConfig copyWith({
    String? id,
    Object? speed = unsetCopyWithValue,
    Object? effort = unsetCopyWithValue,
  }) {
    return ModelParamsConfig(
      id: id ?? this.id,
      speed: speed == unsetCopyWithValue ? this.speed : speed as AgentSpeed?,
      effort: effort == unsetCopyWithValue ? _effort : effort,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelParamsConfig &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          speed == other.speed &&
          _effort == other._effort;

  @override
  int get hashCode => Object.hash(id, speed, _effort);

  @override
  String toString() =>
      'ModelParamsConfig(id: $id, speed: $speed, effort: $effort)';
}
