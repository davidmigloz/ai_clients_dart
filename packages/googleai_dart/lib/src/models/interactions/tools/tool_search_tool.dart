part of 'tools.dart';

/// Where an Interactions tool search runs.
enum ToolSearchExecution {
  /// Gemini retrieves deferred declarations from the tools in the request.
  server,

  /// The application retrieves declarations and returns them as a tool result.
  client,
}

/// Loads function schemas on demand in the Gemini Developer API `v1beta`.
///
/// Tool retrieval is in Preview and requires Gemini 3.6 or later. Omit
/// [execution] for server-side search and set `deferLoading: true` on the
/// functions or MCP servers to withhold. For client-side search, pass
/// [ToolSearchExecution.client] with a [name] and [description] and respond to
/// the resulting function call with matching function declarations.
class ToolSearchTool extends InteractionTool {
  @override
  String get type => 'tool_search';

  /// The execution mode, or null to use the server default.
  final ToolSearchExecution? execution;

  /// The name of the client-side search function.
  final String? name;

  /// Describes how the client-side search function works.
  final String? description;

  /// The optional JSON Schema of the client-side search arguments.
  final Object? parameters;

  /// Creates a server-side search by default, or a client-side search.
  const ToolSearchTool({
    this.execution,
    this.name,
    this.description,
    this.parameters,
  });

  /// Creates a [ToolSearchTool] from its wire representation.
  factory ToolSearchTool.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'tool_search') {
      throw const FormatException(
        'ToolSearchTool: expected type "tool_search"',
      );
    }
    final tool = ToolSearchTool(
      execution: switch (json['execution']) {
        null => null,
        'server' => ToolSearchExecution.server,
        'client' => ToolSearchExecution.client,
        _ => throw const FormatException(
          'ToolSearchTool: invalid execution mode',
        ),
      },
      name: json['name'] as String?,
      description: json['description'] as String?,
      parameters: json['parameters'],
    );
    final error = tool._validationError;
    if (error != null) throw FormatException(error);
    return tool;
  }

  String? get _validationError {
    if (execution == ToolSearchExecution.client) {
      if (name == null ||
          name!.isEmpty ||
          description == null ||
          description!.isEmpty) {
        return 'A client-side tool search requires a name and description.';
      }
    } else if (name != null || description != null || parameters != null) {
      return 'Only client-side tool searches accept a name, description, or parameters.';
    }
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    final error = _validationError;
    if (error != null) throw ArgumentError(error);
    return {
      'type': type,
      if (execution != null) 'execution': execution!.name,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (parameters != null) 'parameters': parameters,
    };
  }
}
