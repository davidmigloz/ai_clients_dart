import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../metadata/cache_control.dart';
import '../config/container.dart';

/// Code execution tool for running code in a sandboxed environment.
@immutable
class CodeExecutionTool {
  /// The tool type version.
  final String type;

  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Container configuration.
  final ContainerParams? container;

  /// Creates a [CodeExecutionTool].
  const CodeExecutionTool({
    this.type = 'code_execution_20250825',
    this.cacheControl,
    this.container,
  });

  /// Creates a [CodeExecutionTool] with version 2025-05-22.
  factory CodeExecutionTool.v20250522({
    CacheControlEphemeral? cacheControl,
    ContainerParams? container,
  }) {
    return CodeExecutionTool(
      type: 'code_execution_20250522',
      cacheControl: cacheControl,
      container: container,
    );
  }

  /// Creates a [CodeExecutionTool] from JSON.
  factory CodeExecutionTool.fromJson(Map<String, dynamic> json) {
    return CodeExecutionTool(
      type: json['type'] as String,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
      container: json['container'] != null
          ? ContainerParams.fromJson(json['container'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'code_execution',
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (container != null) 'container': container!.toJson(),
  };

  /// Creates a copy with replaced values.
  CodeExecutionTool copyWith({
    String? type,
    Object? cacheControl = unsetCopyWithValue,
    Object? container = unsetCopyWithValue,
  }) {
    return CodeExecutionTool(
      type: type ?? this.type,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
      container: container == unsetCopyWithValue
          ? this.container
          : container as ContainerParams?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeExecutionTool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          cacheControl == other.cacheControl &&
          container == other.container;

  @override
  int get hashCode => Object.hash(type, cacheControl, container);

  @override
  String toString() =>
      'CodeExecutionTool(type: $type, cacheControl: $cacheControl, '
      'container: $container)';
}
