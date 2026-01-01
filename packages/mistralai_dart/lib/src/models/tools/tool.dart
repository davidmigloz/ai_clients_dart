import 'package:meta/meta.dart';

import 'function_definition.dart';

/// A tool available to the model.
///
/// Tools can be either user-defined functions or built-in Mistral tools.
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
  const factory Tool.webSearch() = WebSearchTool;

  /// Creates a premium web search tool.
  ///
  /// Enables access to both a search engine and news agencies (AFP, AP).
  const factory Tool.webSearchPremium() = WebSearchPremiumTool;

  /// Creates a code interpreter tool.
  ///
  /// Enables the model to execute code in an isolated container.
  /// Useful for graphs, data analysis, mathematical operations, and code validation.
  const factory Tool.codeInterpreter() = CodeInterpreterTool;

  /// Creates an image generation tool.
  ///
  /// Enables the model to generate images. Powered by FLUX1.1 [pro] Ultra.
  const factory Tool.imageGeneration() = ImageGenerationTool;

  /// Creates a document library tool.
  ///
  /// Enables the model to access documents from Mistral Cloud for RAG.
  /// [libraryIds] specifies which document libraries to use.
  const factory Tool.documentLibrary({List<String>? libraryIds}) =
      DocumentLibraryTool;

  /// Creates a [Tool] from JSON.
  factory Tool.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'function':
        return FunctionTool.fromJson(json);
      case 'web_search':
        return const WebSearchTool();
      case 'web_search_premium':
        return const WebSearchPremiumTool();
      case 'code_interpreter':
        return const CodeInterpreterTool();
      case 'image_generation':
        return const ImageGenerationTool();
      case 'document_library':
        return DocumentLibraryTool.fromJson(json);
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
  /// Creates a [WebSearchTool].
  const WebSearchTool();

  @override
  Map<String, dynamic> toJson() => {'type': 'web_search'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WebSearchTool;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'WebSearchTool()';
}

/// A built-in premium web search tool with news agency access.
@immutable
class WebSearchPremiumTool extends Tool {
  /// Creates a [WebSearchPremiumTool].
  const WebSearchPremiumTool();

  @override
  Map<String, dynamic> toJson() => {'type': 'web_search_premium'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WebSearchPremiumTool;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'WebSearchPremiumTool()';
}

/// A built-in code interpreter tool.
@immutable
class CodeInterpreterTool extends Tool {
  /// Creates a [CodeInterpreterTool].
  const CodeInterpreterTool();

  @override
  Map<String, dynamic> toJson() => {'type': 'code_interpreter'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CodeInterpreterTool;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'CodeInterpreterTool()';
}

/// A built-in image generation tool.
@immutable
class ImageGenerationTool extends Tool {
  /// Creates an [ImageGenerationTool].
  const ImageGenerationTool();

  @override
  Map<String, dynamic> toJson() => {'type': 'image_generation'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ImageGenerationTool;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ImageGenerationTool()';
}

/// A built-in document library tool for RAG.
@immutable
class DocumentLibraryTool extends Tool {
  /// The library IDs to use for document search.
  final List<String>? libraryIds;

  /// Creates a [DocumentLibraryTool].
  const DocumentLibraryTool({this.libraryIds});

  /// Creates a [DocumentLibraryTool] from JSON.
  factory DocumentLibraryTool.fromJson(Map<String, dynamic> json) =>
      DocumentLibraryTool(
        libraryIds: (json['library_ids'] as List?)?.cast<String>(),
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'document_library',
    if (libraryIds != null) 'library_ids': libraryIds,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentLibraryTool &&
          runtimeType == other.runtimeType &&
          _listEquals(libraryIds, other.libraryIds);

  @override
  int get hashCode => Object.hashAll(libraryIds ?? []);

  @override
  String toString() => 'DocumentLibraryTool(libraryIds: $libraryIds)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
