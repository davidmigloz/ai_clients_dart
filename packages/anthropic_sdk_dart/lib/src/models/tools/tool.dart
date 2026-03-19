import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
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

  /// Allowed caller types for this tool.
  final List<String>? allowedCallers;

  /// If true, tool is not loaded in the initial prompt and is loaded via
  /// tool references.
  final bool? deferLoading;

  /// If true, validates tool inputs strictly against schema.
  final bool? strict;

  /// Optional example inputs for the tool.
  final List<Map<String, dynamic>>? inputExamples;

  /// Whether eager tool input streaming is enabled.
  final bool? eagerInputStreaming;

  /// Creates a [Tool].
  const Tool({
    this.type,
    required this.name,
    this.description,
    required this.inputSchema,
    this.cacheControl,
    this.allowedCallers,
    this.deferLoading,
    this.strict,
    this.inputExamples,
    this.eagerInputStreaming,
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
      allowedCallers: (json['allowed_callers'] as List?)?.cast<String>(),
      deferLoading: json['defer_loading'] as bool?,
      strict: json['strict'] as bool?,
      inputExamples: (json['input_examples'] as List?)
          ?.map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      eagerInputStreaming: json['eager_input_streaming'] as bool?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (type != null) 'type': type,
    'name': name,
    if (description != null) 'description': description,
    'input_schema': inputSchema.toJson(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (allowedCallers != null) 'allowed_callers': allowedCallers,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (strict != null) 'strict': strict,
    if (inputExamples != null) 'input_examples': inputExamples,
    if (eagerInputStreaming != null)
      'eager_input_streaming': eagerInputStreaming,
  };

  /// Creates a copy with replaced values.
  Tool copyWith({
    Object? type = unsetCopyWithValue,
    String? name,
    Object? description = unsetCopyWithValue,
    InputSchema? inputSchema,
    Object? cacheControl = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
    Object? inputExamples = unsetCopyWithValue,
    Object? eagerInputStreaming = unsetCopyWithValue,
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
      allowedCallers: allowedCallers == unsetCopyWithValue
          ? this.allowedCallers
          : allowedCallers as List<String>?,
      deferLoading: deferLoading == unsetCopyWithValue
          ? this.deferLoading
          : deferLoading as bool?,
      strict: strict == unsetCopyWithValue ? this.strict : strict as bool?,
      inputExamples: inputExamples == unsetCopyWithValue
          ? this.inputExamples
          : inputExamples as List<Map<String, dynamic>>?,
      eagerInputStreaming: eagerInputStreaming == unsetCopyWithValue
          ? this.eagerInputStreaming
          : eagerInputStreaming as bool?,
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
          cacheControl == other.cacheControl &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          deferLoading == other.deferLoading &&
          strict == other.strict &&
          listOfMapsEqual(inputExamples, other.inputExamples) &&
          eagerInputStreaming == other.eagerInputStreaming;

  @override
  int get hashCode => Object.hash(
    type,
    name,
    description,
    inputSchema,
    cacheControl,
    listHash(allowedCallers),
    deferLoading,
    strict,
    listOfMapsHash(inputExamples),
    eagerInputStreaming,
  );

  @override
  String toString() =>
      'Tool(type: $type, name: $name, description: $description, '
      'inputSchema: $inputSchema, cacheControl: $cacheControl, '
      'allowedCallers: $allowedCallers, deferLoading: $deferLoading, '
      'strict: $strict, inputExamples: $inputExamples, '
      'eagerInputStreaming: $eagerInputStreaming)';
}
