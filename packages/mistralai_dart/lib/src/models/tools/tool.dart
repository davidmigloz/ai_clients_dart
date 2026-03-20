import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'connector_auth.dart';
import 'function_definition.dart';
import 'tool_configuration.dart';

/// A tool available to the model.
///
/// Tools can be user-defined functions, built-in Mistral tools, or custom
/// connectors.
///
/// Variants:
/// - [FunctionTool] — User-defined function tool.
/// - [WebSearchTool] — Built-in web search tool.
/// - [WebSearchPremiumTool] — Built-in premium web search tool.
/// - [CodeInterpreterTool] — Built-in code interpreter tool.
/// - [ImageGenerationTool] — Built-in image generation tool.
/// - [DocumentLibraryTool] — Built-in document library tool.
/// - [CustomConnectorTool] — Custom connector tool for agents.
@immutable
sealed class Tool {
  const Tool();

  /// Creates a function tool.
  ///
  /// [name] is the function name.
  /// [description] describes what the function does.
  /// [parameters] is the JSON Schema for the function parameters.
  factory Tool.function({
    required String name,
    String? description,
    Map<String, dynamic>? parameters,
  }) => FunctionTool(
    function: FunctionDefinition(
      name: name,
      description: description,
      parameters: parameters,
    ),
  );

  /// Creates a web search tool.
  ///
  /// Enables the model to search the web for relevant information.
  /// [toolConfiguration] optionally configures tool behavior.
  const factory Tool.webSearch({ToolConfiguration? toolConfiguration}) =
      WebSearchTool;

  /// Creates a premium web search tool.
  ///
  /// Enables access to both a search engine and news agencies (AFP, AP).
  /// [toolConfiguration] optionally configures tool behavior.
  const factory Tool.webSearchPremium({ToolConfiguration? toolConfiguration}) =
      WebSearchPremiumTool;

  /// Creates a code interpreter tool.
  ///
  /// Enables the model to execute code in an isolated container.
  /// Useful for graphs, data analysis, mathematical operations, and code validation.
  /// [toolConfiguration] optionally configures tool behavior.
  const factory Tool.codeInterpreter({ToolConfiguration? toolConfiguration}) =
      CodeInterpreterTool;

  /// Creates an image generation tool.
  ///
  /// Enables the model to generate images. Powered by FLUX1.1 [pro] Ultra.
  /// [toolConfiguration] optionally configures tool behavior.
  const factory Tool.imageGeneration({ToolConfiguration? toolConfiguration}) =
      ImageGenerationTool;

  /// Creates a document library tool.
  ///
  /// Enables the model to access documents from Mistral Cloud for RAG.
  /// [libraryIds] specifies which document libraries to use.
  /// [toolConfiguration] optionally configures tool behavior.
  const factory Tool.documentLibrary({
    List<String>? libraryIds,
    ToolConfiguration? toolConfiguration,
  }) = DocumentLibraryTool;

  /// Creates a custom connector tool.
  ///
  /// Enables agents to use custom connectors for external integrations.
  /// [connectorId] is the unique identifier of the connector.
  /// [authorization] optionally provides authentication credentials.
  /// [toolConfiguration] optionally configures tool behavior.
  const factory Tool.connector({
    required String connectorId,
    ConnectorAuth? authorization,
    ToolConfiguration? toolConfiguration,
  }) = CustomConnectorTool;

  /// Creates a [Tool] from JSON.
  factory Tool.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'function':
        return FunctionTool.fromJson(json);
      case 'web_search':
        return WebSearchTool.fromJson(json);
      case 'web_search_premium':
        return WebSearchPremiumTool.fromJson(json);
      case 'code_interpreter':
        return CodeInterpreterTool.fromJson(json);
      case 'image_generation':
        return ImageGenerationTool.fromJson(json);
      case 'document_library':
        return DocumentLibraryTool.fromJson(json);
      case 'connector':
        return CustomConnectorTool.fromJson(json);
      default:
        // Default to function type for backwards compatibility
        return FunctionTool.fromJson(json);
    }
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A user-defined function tool.
@immutable
class FunctionTool extends Tool {
  /// The tool type, always 'function'.
  String get type => 'function';

  /// The function definition.
  final FunctionDefinition function;

  /// Creates a [FunctionTool].
  const FunctionTool({required this.function});

  /// Creates a [FunctionTool] from JSON.
  factory FunctionTool.fromJson(Map<String, dynamic> json) => FunctionTool(
    function: FunctionDefinition.fromJson(
      json['function'] as Map<String, dynamic>? ?? {},
    ),
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function',
    'function': function.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  FunctionTool copyWith({FunctionDefinition? function}) =>
      FunctionTool(function: function ?? this.function);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionTool &&
          runtimeType == other.runtimeType &&
          function == other.function;

  @override
  int get hashCode => function.hashCode;

  @override
  String toString() => 'FunctionTool(function: $function)';
}

/// A built-in web search tool.
@immutable
class WebSearchTool extends Tool {
  /// The tool type, always 'web_search'.
  String get type => 'web_search';

  /// Configuration for the tool's behavior.
  final ToolConfiguration? toolConfiguration;

  /// Creates a [WebSearchTool].
  const WebSearchTool({this.toolConfiguration});

  /// Creates a [WebSearchTool] from JSON.
  factory WebSearchTool.fromJson(Map<String, dynamic> json) => WebSearchTool(
    toolConfiguration: json['tool_configuration'] != null
        ? ToolConfiguration.fromJson(
            json['tool_configuration'] as Map<String, dynamic>,
          )
        : null,
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'web_search',
    if (toolConfiguration != null)
      'tool_configuration': toolConfiguration!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchTool &&
          runtimeType == other.runtimeType &&
          toolConfiguration == other.toolConfiguration;

  @override
  int get hashCode => Object.hash(runtimeType, toolConfiguration);

  @override
  String toString() => 'WebSearchTool(toolConfiguration: $toolConfiguration)';
}

/// A built-in premium web search tool with news agency access.
@immutable
class WebSearchPremiumTool extends Tool {
  /// The tool type, always 'web_search_premium'.
  String get type => 'web_search_premium';

  /// Configuration for the tool's behavior.
  final ToolConfiguration? toolConfiguration;

  /// Creates a [WebSearchPremiumTool].
  const WebSearchPremiumTool({this.toolConfiguration});

  /// Creates a [WebSearchPremiumTool] from JSON.
  factory WebSearchPremiumTool.fromJson(Map<String, dynamic> json) =>
      WebSearchPremiumTool(
        toolConfiguration: json['tool_configuration'] != null
            ? ToolConfiguration.fromJson(
                json['tool_configuration'] as Map<String, dynamic>,
              )
            : null,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'web_search_premium',
    if (toolConfiguration != null)
      'tool_configuration': toolConfiguration!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchPremiumTool &&
          runtimeType == other.runtimeType &&
          toolConfiguration == other.toolConfiguration;

  @override
  int get hashCode => Object.hash(runtimeType, toolConfiguration);

  @override
  String toString() =>
      'WebSearchPremiumTool(toolConfiguration: $toolConfiguration)';
}

/// A built-in code interpreter tool.
@immutable
class CodeInterpreterTool extends Tool {
  /// The tool type, always 'code_interpreter'.
  String get type => 'code_interpreter';

  /// Configuration for the tool's behavior.
  final ToolConfiguration? toolConfiguration;

  /// Creates a [CodeInterpreterTool].
  const CodeInterpreterTool({this.toolConfiguration});

  /// Creates a [CodeInterpreterTool] from JSON.
  factory CodeInterpreterTool.fromJson(Map<String, dynamic> json) =>
      CodeInterpreterTool(
        toolConfiguration: json['tool_configuration'] != null
            ? ToolConfiguration.fromJson(
                json['tool_configuration'] as Map<String, dynamic>,
              )
            : null,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'code_interpreter',
    if (toolConfiguration != null)
      'tool_configuration': toolConfiguration!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterTool &&
          runtimeType == other.runtimeType &&
          toolConfiguration == other.toolConfiguration;

  @override
  int get hashCode => Object.hash(runtimeType, toolConfiguration);

  @override
  String toString() =>
      'CodeInterpreterTool(toolConfiguration: $toolConfiguration)';
}

/// A built-in image generation tool.
@immutable
class ImageGenerationTool extends Tool {
  /// The tool type, always 'image_generation'.
  String get type => 'image_generation';

  /// Configuration for the tool's behavior.
  final ToolConfiguration? toolConfiguration;

  /// Creates an [ImageGenerationTool].
  const ImageGenerationTool({this.toolConfiguration});

  /// Creates an [ImageGenerationTool] from JSON.
  factory ImageGenerationTool.fromJson(Map<String, dynamic> json) =>
      ImageGenerationTool(
        toolConfiguration: json['tool_configuration'] != null
            ? ToolConfiguration.fromJson(
                json['tool_configuration'] as Map<String, dynamic>,
              )
            : null,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'image_generation',
    if (toolConfiguration != null)
      'tool_configuration': toolConfiguration!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageGenerationTool &&
          runtimeType == other.runtimeType &&
          toolConfiguration == other.toolConfiguration;

  @override
  int get hashCode => Object.hash(runtimeType, toolConfiguration);

  @override
  String toString() =>
      'ImageGenerationTool(toolConfiguration: $toolConfiguration)';
}

/// A built-in document library tool for RAG.
@immutable
class DocumentLibraryTool extends Tool {
  /// The tool type, always 'document_library'.
  String get type => 'document_library';

  /// The library IDs to use for document search.
  final List<String>? libraryIds;

  /// Configuration for the tool's behavior.
  final ToolConfiguration? toolConfiguration;

  /// Creates a [DocumentLibraryTool].
  const DocumentLibraryTool({this.libraryIds, this.toolConfiguration});

  /// Creates a [DocumentLibraryTool] from JSON.
  factory DocumentLibraryTool.fromJson(Map<String, dynamic> json) =>
      DocumentLibraryTool(
        libraryIds: (json['library_ids'] as List?)?.cast<String>(),
        toolConfiguration: json['tool_configuration'] != null
            ? ToolConfiguration.fromJson(
                json['tool_configuration'] as Map<String, dynamic>,
              )
            : null,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'document_library',
    if (libraryIds != null) 'library_ids': libraryIds,
    if (toolConfiguration != null)
      'tool_configuration': toolConfiguration!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentLibraryTool &&
          runtimeType == other.runtimeType &&
          listsEqual(libraryIds, other.libraryIds) &&
          toolConfiguration == other.toolConfiguration;

  @override
  int get hashCode => Object.hash(listHash(libraryIds), toolConfiguration);

  @override
  String toString() =>
      'DocumentLibraryTool(libraryIds: $libraryIds, '
      'toolConfiguration: $toolConfiguration)';
}

/// A custom connector tool for agents.
@immutable
class CustomConnectorTool extends Tool {
  /// The tool type, always 'connector'.
  String get type => 'connector';

  /// The unique identifier of the connector.
  final String connectorId;

  /// Authentication credentials for the connector.
  final ConnectorAuth? authorization;

  /// Configuration for the tool's behavior.
  final ToolConfiguration? toolConfiguration;

  /// Creates a [CustomConnectorTool].
  const CustomConnectorTool({
    required this.connectorId,
    this.authorization,
    this.toolConfiguration,
  });

  /// Creates a [CustomConnectorTool] from JSON.
  factory CustomConnectorTool.fromJson(Map<String, dynamic> json) =>
      CustomConnectorTool(
        connectorId: json['connector_id'] as String? ?? '',
        authorization: json['authorization'] != null
            ? ConnectorAuth.fromJson(
                json['authorization'] as Map<String, dynamic>,
              )
            : null,
        toolConfiguration: json['tool_configuration'] != null
            ? ToolConfiguration.fromJson(
                json['tool_configuration'] as Map<String, dynamic>,
              )
            : null,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'connector',
    'connector_id': connectorId,
    if (authorization != null) 'authorization': authorization!.toJson(),
    if (toolConfiguration != null)
      'tool_configuration': toolConfiguration!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  CustomConnectorTool copyWith({
    String? connectorId,
    Object? authorization = unsetCopyWithValue,
    Object? toolConfiguration = unsetCopyWithValue,
  }) => CustomConnectorTool(
    connectorId: connectorId ?? this.connectorId,
    authorization: authorization == unsetCopyWithValue
        ? this.authorization
        : authorization as ConnectorAuth?,
    toolConfiguration: toolConfiguration == unsetCopyWithValue
        ? this.toolConfiguration
        : toolConfiguration as ToolConfiguration?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomConnectorTool &&
          runtimeType == other.runtimeType &&
          connectorId == other.connectorId &&
          authorization == other.authorization &&
          toolConfiguration == other.toolConfiguration;

  @override
  int get hashCode =>
      Object.hash(runtimeType, connectorId, authorization, toolConfiguration);

  @override
  String toString() =>
      'CustomConnectorTool(connectorId: $connectorId, '
      'authorization: $authorization, '
      'toolConfiguration: $toolConfiguration)';
}
