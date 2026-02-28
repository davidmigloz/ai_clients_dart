import 'package:meta/meta.dart';

/// Origin of a tool invocation/result.
sealed class ToolCaller {
  const ToolCaller();

  /// Direct model invocation.
  factory ToolCaller.direct() = DirectToolCaller;

  /// Invocation from a server tool, including source tool id.
  factory ToolCaller.server({required String type, required String toolId}) =
      ServerToolCaller;

  /// Parses a [ToolCaller] from JSON.
  factory ToolCaller.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'direct';
    if (type == 'direct') {
      return const DirectToolCaller();
    }
    return ServerToolCaller(type: type, toolId: json['tool_id'] as String);
  }

  /// Converts this caller to JSON.
  Map<String, dynamic> toJson();
}

/// Direct model caller.
@immutable
class DirectToolCaller extends ToolCaller {
  /// Creates a [DirectToolCaller].
  const DirectToolCaller();

  @override
  Map<String, dynamic> toJson() => {'type': 'direct'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DirectToolCaller && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'DirectToolCaller()';
}

/// Server-side caller (for code execution initiated calls).
@immutable
class ServerToolCaller extends ToolCaller {
  /// Caller type, for example `code_execution_20250825`.
  final String type;

  /// Server tool use id.
  final String toolId;

  /// Creates a [ServerToolCaller].
  const ServerToolCaller({required this.type, required this.toolId});

  /// Parses [ServerToolCaller] from JSON.
  factory ServerToolCaller.fromJson(Map<String, dynamic> json) {
    return ServerToolCaller(
      type: json['type'] as String,
      toolId: json['tool_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'tool_id': toolId};

  /// Creates a copy with replaced values.
  ServerToolCaller copyWith({String? type, String? toolId}) {
    return ServerToolCaller(
      type: type ?? this.type,
      toolId: toolId ?? this.toolId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerToolCaller &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          toolId == other.toolId;

  @override
  int get hashCode => Object.hash(type, toolId);

  @override
  String toString() => 'ServerToolCaller(type: $type, toolId: $toolId)';
}
