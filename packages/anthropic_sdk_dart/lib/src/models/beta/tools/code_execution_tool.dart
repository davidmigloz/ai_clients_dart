import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality.dart';
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

  /// Allowed caller types.
  final List<String>? allowedCallers;

  /// Whether to defer loading until requested via tool reference.
  final bool? deferLoading;

  /// Whether strict schema validation is enabled.
  final bool? strict;

  /// Creates a [CodeExecutionTool].
  const CodeExecutionTool({
    this.type = 'code_execution_20250825',
    this.cacheControl,
    this.container,
    this.allowedCallers,
    this.deferLoading,
    this.strict,
  });

  /// Creates a [CodeExecutionTool] with version 2025-05-22.
  factory CodeExecutionTool.v20250522({
    CacheControlEphemeral? cacheControl,
    ContainerParams? container,
    List<String>? allowedCallers,
    bool? deferLoading,
    bool? strict,
  }) {
    return CodeExecutionTool(
      type: 'code_execution_20250522',
      cacheControl: cacheControl,
      container: container,
      allowedCallers: allowedCallers,
      deferLoading: deferLoading,
      strict: strict,
    );
  }

  /// Creates a [CodeExecutionTool] with version 2026-01-20.
  factory CodeExecutionTool.v20260120({
    CacheControlEphemeral? cacheControl,
    List<String>? allowedCallers,
    bool? deferLoading,
    bool? strict,
  }) {
    return CodeExecutionTool(
      type: 'code_execution_20260120',
      cacheControl: cacheControl,
      allowedCallers: allowedCallers,
      deferLoading: deferLoading,
      strict: strict,
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
      allowedCallers: (json['allowed_callers'] as List?)?.cast<String>(),
      deferLoading: json['defer_loading'] as bool?,
      strict: json['strict'] as bool?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'code_execution',
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (container != null) 'container': container!.toJson(),
    if (allowedCallers != null) 'allowed_callers': allowedCallers,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (strict != null) 'strict': strict,
  };

  /// Creates a copy with replaced values.
  CodeExecutionTool copyWith({
    String? type,
    Object? cacheControl = unsetCopyWithValue,
    Object? container = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
  }) {
    return CodeExecutionTool(
      type: type ?? this.type,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
      container: container == unsetCopyWithValue
          ? this.container
          : container as ContainerParams?,
      allowedCallers: allowedCallers == unsetCopyWithValue
          ? this.allowedCallers
          : allowedCallers as List<String>?,
      deferLoading: deferLoading == unsetCopyWithValue
          ? this.deferLoading
          : deferLoading as bool?,
      strict: strict == unsetCopyWithValue ? this.strict : strict as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeExecutionTool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          cacheControl == other.cacheControl &&
          container == other.container &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          deferLoading == other.deferLoading &&
          strict == other.strict;

  @override
  int get hashCode => Object.hash(
    type,
    cacheControl,
    container,
    listHash(allowedCallers),
    deferLoading,
    strict,
  );

  @override
  String toString() =>
      'CodeExecutionTool(type: $type, cacheControl: $cacheControl, '
      'container: $container, allowedCallers: $allowedCallers, '
      'deferLoading: $deferLoading, strict: $strict)';
}
