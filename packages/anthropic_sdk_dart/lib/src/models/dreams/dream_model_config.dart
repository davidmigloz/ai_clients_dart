import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../managed_agents/config/model_config.dart';

/// Model identifier and configuration applied to every pipeline stage of a
/// Dream, as returned in API responses.
///
/// Same wire shape as the Agents API `ModelConfig`.
@immutable
class DreamModelConfig {
  /// Model identifier, e.g. `"claude-opus-4-7"`.
  final String id;

  /// Inference speed mode. Defaults to `standard`.
  final AgentSpeed? speed;

  /// Creates a [DreamModelConfig].
  const DreamModelConfig({required this.id, this.speed});

  /// Creates a [DreamModelConfig] from JSON.
  factory DreamModelConfig.fromJson(Map<String, dynamic> json) {
    return DreamModelConfig(
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
  DreamModelConfig copyWith({String? id, Object? speed = unsetCopyWithValue}) {
    return DreamModelConfig(
      id: id ?? this.id,
      speed: speed == unsetCopyWithValue ? this.speed : speed as AgentSpeed?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DreamModelConfig &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          speed == other.speed;

  @override
  int get hashCode => Object.hash(id, speed);

  @override
  String toString() => 'DreamModelConfig(id: $id, speed: $speed)';
}

/// Model parameter for creating a Dream — either a plain model ID string or a
/// [DreamModelConfigParams] object.
///
/// Variants:
/// - [DreamModelParamsId] — a plain model ID string.
/// - [DreamModelConfigParams] — a model configuration object.
sealed class DreamModelParams {
  const DreamModelParams();

  /// Creates a [DreamModelParams] from JSON.
  ///
  /// If [json] is a [String], returns [DreamModelParamsId].
  /// Otherwise expects a [Map] and returns [DreamModelConfigParams].
  static DreamModelParams fromJson(Object json) {
    if (json is String) {
      return DreamModelParamsId(id: json);
    }
    return DreamModelConfigParams.fromJson(json as Map<String, dynamic>);
  }

  /// Converts to JSON.
  Object toJson();
}

/// A plain model ID string.
@immutable
class DreamModelParamsId extends DreamModelParams {
  /// The model identifier.
  final String id;

  /// Creates a [DreamModelParamsId].
  const DreamModelParamsId({required this.id});

  @override
  Object toJson() => id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DreamModelParamsId &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DreamModelParamsId(id: $id)';
}

/// Model identifier and configuration applied to every pipeline stage,
/// supplied when creating a Dream.
@immutable
class DreamModelConfigParams extends DreamModelParams {
  /// Model identifier, e.g. `"claude-opus-4-7"`.
  final String id;

  /// Inference speed mode. Defaults to `standard`.
  final AgentSpeed? speed;

  /// Creates a [DreamModelConfigParams].
  const DreamModelConfigParams({required this.id, this.speed});

  /// Creates a [DreamModelConfigParams] from JSON.
  factory DreamModelConfigParams.fromJson(Map<String, dynamic> json) {
    return DreamModelConfigParams(
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

  /// Creates a copy with replaced values.
  DreamModelConfigParams copyWith({
    String? id,
    Object? speed = unsetCopyWithValue,
  }) {
    return DreamModelConfigParams(
      id: id ?? this.id,
      speed: speed == unsetCopyWithValue ? this.speed : speed as AgentSpeed?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DreamModelConfigParams &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          speed == other.speed;

  @override
  int get hashCode => Object.hash(id, speed);

  @override
  String toString() => 'DreamModelConfigParams(id: $id, speed: $speed)';
}
