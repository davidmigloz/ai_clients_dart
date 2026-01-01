import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../metadata/cache_control.dart';
import 'input_schema.dart';

/// A tool that can be used by the model.
@immutable
class Tool {
  /// Type of tool. Always "custom" for user-defined tools.
  final String? type;

  /// Name of the tool.
  ///
  /// This is how the tool will be called by the model and in tool_use blocks.
  final String name;

  /// Description of what this tool does.
  ///
  /// Tool descriptions should be as detailed as possible.
  final String? description;

  /// JSON Schema for this tool's input.
  final InputSchema inputSchema;

  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [Tool].
  const Tool({
    this.type,
    required this.name,
    this.description,
    required this.inputSchema,
    this.cacheControl,
  });

  /// Creates a [Tool] from JSON.
  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      type: json['type'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      inputSchema: InputSchema.fromJson(
        json['input_schema'] as Map<String, dynamic>,
      ),
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (type != null) 'type': type,
    'name': name,
    if (description != null) 'description': description,
    'input_schema': inputSchema.toJson(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  Tool copyWith({
    Object? type = unsetCopyWithValue,
    String? name,
    Object? description = unsetCopyWithValue,
    InputSchema? inputSchema,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return Tool(
      type: type == unsetCopyWithValue ? this.type : type as String?,
      name: name ?? this.name,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      inputSchema: inputSchema ?? this.inputSchema,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          description == other.description &&
          inputSchema == other.inputSchema &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode =>
      Object.hash(type, name, description, inputSchema, cacheControl);

  @override
  String toString() =>
      'Tool(type: $type, name: $name, description: $description, '
      'inputSchema: $inputSchema, cacheControl: $cacheControl)';
}
