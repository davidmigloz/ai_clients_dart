import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';

/// Container configuration for code execution.
@immutable
class ContainerParams {
  /// Memory limit in MB (defaults to 512).
  final int? memoryMb;

  /// Timeout in seconds (defaults to 300).
  final int? timeoutSeconds;

  /// Creates a [ContainerParams].
  const ContainerParams({this.memoryMb, this.timeoutSeconds});

  /// Creates a [ContainerParams] from JSON.
  factory ContainerParams.fromJson(Map<String, dynamic> json) {
    return ContainerParams(
      memoryMb: json['memory_mb'] as int?,
      timeoutSeconds: json['timeout_seconds'] as int?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (memoryMb != null) 'memory_mb': memoryMb,
    if (timeoutSeconds != null) 'timeout_seconds': timeoutSeconds,
  };

  /// Creates a copy with replaced values.
  ContainerParams copyWith({
    Object? memoryMb = unsetCopyWithValue,
    Object? timeoutSeconds = unsetCopyWithValue,
  }) {
    return ContainerParams(
      memoryMb: memoryMb == unsetCopyWithValue
          ? this.memoryMb
          : memoryMb as int?,
      timeoutSeconds: timeoutSeconds == unsetCopyWithValue
          ? this.timeoutSeconds
          : timeoutSeconds as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerParams &&
          runtimeType == other.runtimeType &&
          memoryMb == other.memoryMb &&
          timeoutSeconds == other.timeoutSeconds;

  @override
  int get hashCode => Object.hash(memoryMb, timeoutSeconds);

  @override
  String toString() =>
      'ContainerParams(memoryMb: $memoryMb, timeoutSeconds: $timeoutSeconds)';
}

/// Container information in response.
@immutable
class Container {
  /// The container ID.
  final String id;

  /// The expiration time.
  final DateTime expiresAt;

  /// Creates a [Container].
  const Container({required this.id, required this.expiresAt});

  /// Creates a [Container] from JSON.
  factory Container.fromJson(Map<String, dynamic> json) {
    return Container(
      id: json['id'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'expires_at': expiresAt.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Container &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode => Object.hash(id, expiresAt);

  @override
  String toString() => 'Container(id: $id, expiresAt: $expiresAt)';
}
