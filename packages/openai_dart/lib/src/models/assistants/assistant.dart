import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/response_format.dart';
import 'assistant_tool.dart';
import 'tool_resources.dart';

/// Parses response_format which can be either a string (like "auto") or an object.
ResponseFormat? _parseResponseFormat(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    // API returns "auto" as a string - treat as text format
    return const TextResponseFormat();
  }
  if (value is Map<String, dynamic>) {
    return ResponseFormat.fromJson(value);
  }
  return null;
}

/// An assistant that can interact with users and use tools.
///
/// Assistants can use code interpreter, file search, and custom functions.
///
/// ## Example
///
/// ```dart
/// final assistant = await client.assistants.create(
///   CreateAssistantRequest(
///     model: 'gpt-4o',
///     name: 'Math Tutor',
///     instructions: 'You are a helpful math tutor.',
///   ),
/// );
/// ```
@immutable
class Assistant {
  /// Creates an [Assistant].
  const Assistant({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.model,
    this.name,
    this.description,
    this.instructions,
    required this.tools,
    this.toolResources,
    required this.metadata,
    this.temperature,
    this.topP,
    this.responseFormat,
  });

  /// Creates an [Assistant] from JSON.
  factory Assistant.fromJson(Map<String, dynamic> json) {
    return Assistant(
      id: json['id'] as String,
      object: json['object'] as String,
      createdAt: json['created_at'] as int,
      model: json['model'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      instructions: json['instructions'] as String?,
      tools: (json['tools'] as List<dynamic>)
          .map((e) => AssistantTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolResources: json['tool_resources'] != null
          ? ToolResources.fromJson(
              json['tool_resources'] as Map<String, dynamic>,
            )
          : null,
      metadata:
          (json['metadata'] as Map<String, dynamic>?)?.cast<String, String>() ??
          {},
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      responseFormat: _parseResponseFormat(json['response_format']),
    );
  }

  /// The assistant identifier.
  final String id;

  /// The object type (always "assistant").
  final String object;

  /// The Unix timestamp when the assistant was created.
  final int createdAt;

  /// The model the assistant uses.
  final String model;

  /// The name of the assistant.
  final String? name;

  /// The description of the assistant.
  final String? description;

  /// The system instructions for the assistant.
  final String? instructions;

  /// The tools enabled for the assistant.
  final List<AssistantTool> tools;

  /// Resources available to the assistant's tools.
  final ToolResources? toolResources;

  /// Custom metadata for the assistant.
  final Map<String, String> metadata;

  /// The sampling temperature.
  final double? temperature;

  /// The nucleus sampling parameter.
  final double? topP;

  /// The response format.
  final ResponseFormat? responseFormat;

  /// The creation time as a DateTime.
  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);

  /// Whether the assistant has code interpreter enabled.
  bool get hasCodeInterpreter => tools.any((t) => t is CodeInterpreterTool);

  /// Whether the assistant has file search enabled.
  bool get hasFileSearch => tools.any((t) => t is FileSearchTool);

  /// Whether the assistant has any function tools.
  bool get hasFunctions => tools.any((t) => t is FunctionTool);

  /// Creates a copy with the given fields replaced.
  Assistant copyWith({
    String? id,
    String? object,
    int? createdAt,
    String? model,
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? instructions = unsetCopyWithValue,
    List<AssistantTool>? tools,
    Object? toolResources = unsetCopyWithValue,
    Map<String, String>? metadata,
    Object? temperature = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
  }) {
    return Assistant(
      id: id ?? this.id,
      object: object ?? this.object,
      createdAt: createdAt ?? this.createdAt,
      model: model ?? this.model,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      instructions: instructions == unsetCopyWithValue
          ? this.instructions
          : instructions as String?,
      tools: tools ?? this.tools,
      toolResources: toolResources == unsetCopyWithValue
          ? this.toolResources
          : toolResources as ToolResources?,
      metadata: metadata ?? this.metadata,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
      responseFormat: responseFormat == unsetCopyWithValue
          ? this.responseFormat
          : responseFormat as ResponseFormat?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created_at': createdAt,
    'model': model,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (instructions != null) 'instructions': instructions,
    'tools': tools.map((t) => t.toJson()).toList(),
    if (toolResources != null) 'tool_resources': toolResources!.toJson(),
    'metadata': metadata,
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Assistant &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          createdAt == other.createdAt &&
          model == other.model &&
          name == other.name &&
          description == other.description &&
          instructions == other.instructions &&
          listsEqual(tools, other.tools) &&
          toolResources == other.toolResources &&
          mapsEqual(metadata, other.metadata) &&
          temperature == other.temperature &&
          topP == other.topP &&
          responseFormat == other.responseFormat;

  @override
  int get hashCode => Object.hash(
    id,
    object,
    createdAt,
    model,
    name,
    description,
    instructions,
    Object.hashAll(tools),
    toolResources,
    Object.hashAll(metadata.entries),
    temperature,
    topP,
    responseFormat,
  );

  @override
  String toString() {
    final instrPreview = instructions != null && instructions!.length > 50
        ? '${instructions!.substring(0, 50)}...'
        : instructions;
    return 'Assistant(id: $id, object: $object, createdAt: $createdAt, '
        'model: $model, name: $name, description: $description, '
        'instructions: $instrPreview, tools: ${tools.length} items, '
        'toolResources: $toolResources, metadata: ${metadata.length} entries, '
        'temperature: $temperature, topP: $topP, '
        'responseFormat: $responseFormat)';
  }
}

/// A list of assistants.
@immutable
class AssistantList {
  /// Creates an [AssistantList].
  const AssistantList({
    required this.object,
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  /// Creates an [AssistantList] from JSON.
  factory AssistantList.fromJson(Map<String, dynamic> json) {
    return AssistantList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Assistant.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool,
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of assistants.
  final List<Assistant> data;

  /// The ID of the first assistant.
  final String? firstId;

  /// The ID of the last assistant.
  final String? lastId;

  /// Whether there are more assistants to retrieve.
  final bool hasMore;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((a) => a.toJson()).toList(),
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantList &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length;

  @override
  int get hashCode => data.length.hashCode;

  @override
  String toString() => 'AssistantList(${data.length} assistants)';
}

/// A request to create an assistant.
@immutable
class CreateAssistantRequest {
  /// Creates a [CreateAssistantRequest].
  const CreateAssistantRequest({
    required this.model,
    this.name,
    this.description,
    this.instructions,
    this.tools,
    this.toolResources,
    this.metadata,
    this.temperature,
    this.topP,
    this.responseFormat,
  });

  /// Creates a [CreateAssistantRequest] from JSON.
  factory CreateAssistantRequest.fromJson(Map<String, dynamic> json) {
    return CreateAssistantRequest(
      model: json['model'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      instructions: json['instructions'] as String?,
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => AssistantTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolResources: json['tool_resources'] != null
          ? ToolResources.fromJson(
              json['tool_resources'] as Map<String, dynamic>,
            )
          : null,
      metadata: (json['metadata'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      responseFormat: _parseResponseFormat(json['response_format']),
    );
  }

  /// The model to use.
  final String model;

  /// The name of the assistant.
  final String? name;

  /// The description of the assistant.
  final String? description;

  /// The system instructions for the assistant.
  final String? instructions;

  /// The tools to enable.
  final List<AssistantTool>? tools;

  /// Resources for the tools.
  final ToolResources? toolResources;

  /// Custom metadata.
  final Map<String, String>? metadata;

  /// The sampling temperature.
  final double? temperature;

  /// The nucleus sampling parameter.
  final double? topP;

  /// The response format.
  final ResponseFormat? responseFormat;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (instructions != null) 'instructions': instructions,
    if (tools != null) 'tools': tools!.map((t) => t.toJson()).toList(),
    if (toolResources != null) 'tool_resources': toolResources!.toJson(),
    if (metadata != null) 'metadata': metadata,
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateAssistantRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          name == other.name;

  @override
  int get hashCode => Object.hash(model, name);

  @override
  String toString() => 'CreateAssistantRequest(model: $model, name: $name)';
}

/// A request to modify an assistant.
@immutable
class ModifyAssistantRequest {
  /// Creates a [ModifyAssistantRequest].
  const ModifyAssistantRequest({
    this.model,
    this.name,
    this.description,
    this.instructions,
    this.tools,
    this.toolResources,
    this.metadata,
    this.temperature,
    this.topP,
    this.responseFormat,
  });

  /// Creates a [ModifyAssistantRequest] from JSON.
  factory ModifyAssistantRequest.fromJson(Map<String, dynamic> json) {
    return ModifyAssistantRequest(
      model: json['model'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      instructions: json['instructions'] as String?,
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => AssistantTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolResources: json['tool_resources'] != null
          ? ToolResources.fromJson(
              json['tool_resources'] as Map<String, dynamic>,
            )
          : null,
      metadata: (json['metadata'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      responseFormat: _parseResponseFormat(json['response_format']),
    );
  }

  /// The model to use.
  final String? model;

  /// The name of the assistant.
  final String? name;

  /// The description of the assistant.
  final String? description;

  /// The system instructions for the assistant.
  final String? instructions;

  /// The tools to enable.
  final List<AssistantTool>? tools;

  /// Resources for the tools.
  final ToolResources? toolResources;

  /// Custom metadata.
  final Map<String, String>? metadata;

  /// The sampling temperature.
  final double? temperature;

  /// The nucleus sampling parameter.
  final double? topP;

  /// The response format.
  final ResponseFormat? responseFormat;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (model != null) 'model': model,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (instructions != null) 'instructions': instructions,
    if (tools != null) 'tools': tools!.map((t) => t.toJson()).toList(),
    if (toolResources != null) 'tool_resources': toolResources!.toJson(),
    if (metadata != null) 'metadata': metadata,
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModifyAssistantRequest && runtimeType == other.runtimeType;

  @override
  int get hashCode => Object.hash(model, name);

  @override
  String toString() => 'ModifyAssistantRequest(model: $model, name: $name)';
}

/// The response from deleting an assistant.
@immutable
class DeleteAssistantResponse {
  /// Creates a [DeleteAssistantResponse].
  const DeleteAssistantResponse({
    required this.id,
    required this.object,
    required this.deleted,
  });

  /// Creates a [DeleteAssistantResponse] from JSON.
  factory DeleteAssistantResponse.fromJson(Map<String, dynamic> json) {
    return DeleteAssistantResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      deleted: json['deleted'] as bool,
    );
  }

  /// The ID of the deleted assistant.
  final String id;

  /// The object type.
  final String object;

  /// Whether the assistant was deleted.
  final bool deleted;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'deleted': deleted,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteAssistantResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DeleteAssistantResponse(id: $id, deleted: $deleted)';
}
