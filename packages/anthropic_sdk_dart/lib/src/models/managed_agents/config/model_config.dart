import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';

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

  /// Creates a [ModelConfig].
  const ModelConfig({required this.id, this.speed});

  /// Creates a [ModelConfig] from JSON.
  factory ModelConfig.fromJson(Map<String, dynamic> json) {
    return ModelConfig(
      id: json['id'] as String,
      speed: json['speed'] != null
          ? AgentSpeed.fromJson(json['speed'] as String)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    if (speed != null) 'speed': speed!.toJson(),
  };

  /// Creates a copy with replaced values.
  ModelConfig copyWith({String? id, Object? speed = unsetCopyWithValue}) {
    return ModelConfig(
      id: id ?? this.id,
      speed: speed == unsetCopyWithValue ? this.speed : speed as AgentSpeed?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelConfig &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          speed == other.speed;

  @override
  int get hashCode => Object.hash(id, speed);

  @override
  String toString() => 'ModelConfig(id: $id, speed: $speed)';
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
@immutable
class ModelParamsConfig extends ModelParams {
  /// The model identifier.
  final String id;

  /// Inference speed mode.
  final AgentSpeed? speed;

  /// Creates a [ModelParamsConfig].
  const ModelParamsConfig({required this.id, this.speed});

  /// Creates a [ModelParamsConfig] from JSON.
  factory ModelParamsConfig.fromJson(Map<String, dynamic> json) {
    return ModelParamsConfig(
      id: json['id'] as String,
      speed: json['speed'] != null
          ? AgentSpeed.fromJson(json['speed'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    if (speed != null) 'speed': speed!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelParamsConfig &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          speed == other.speed;

  @override
  int get hashCode => Object.hash(id, speed);

  @override
  String toString() => 'ModelParamsConfig(id: $id, speed: $speed)';
}
