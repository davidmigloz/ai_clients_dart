import 'package:meta/meta.dart';

/// A tool that an assistant can use.
///
/// Tools extend the assistant's capabilities beyond text generation.
sealed class AssistantTool {
  /// Creates an [AssistantTool] from JSON.
  factory AssistantTool.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'code_interpreter' => const CodeInterpreterTool(),
      'file_search' => FileSearchTool.fromJson(json),
      'function' => FunctionTool.fromJson(json),
      _ => throw FormatException('Unknown tool type: $type'),
    };
  }

  /// Creates a code interpreter tool.
  static AssistantTool codeInterpreter() => const CodeInterpreterTool();

  /// Creates a file search tool.
  static AssistantTool fileSearch({
    int? maxNumResults,
    FileSearchRankingOptions? rankingOptions,
  }) => FileSearchTool(
    maxNumResults: maxNumResults,
    rankingOptions: rankingOptions,
  );

  /// Creates a function tool.
  static AssistantTool function({
    required String name,
    String? description,
    Map<String, dynamic>? parameters,
    bool? strict,
  }) => FunctionTool(
    name: name,
    description: description,
    parameters: parameters,
    strict: strict,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Code interpreter tool for executing Python code.
///
/// Enables the assistant to write and run Python code in a sandboxed
/// environment, useful for data analysis, file processing, and more.
@immutable
class CodeInterpreterTool implements AssistantTool {
  /// Creates a [CodeInterpreterTool].
  const CodeInterpreterTool();

  @override
  Map<String, dynamic> toJson() => {'type': 'code_interpreter'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterTool && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'code_interpreter'.hashCode;

  @override
  String toString() => 'CodeInterpreterTool()';
}

/// File search tool for semantic search over files.
///
/// Enables the assistant to search through uploaded files using
/// semantic search to find relevant information.
@immutable
class FileSearchTool implements AssistantTool {
  /// Creates a [FileSearchTool].
  const FileSearchTool({this.maxNumResults, this.rankingOptions});

  /// Creates a [FileSearchTool] from JSON.
  factory FileSearchTool.fromJson(Map<String, dynamic> json) {
    final fileSearch = json['file_search'] as Map<String, dynamic>?;
    return FileSearchTool(
      maxNumResults: fileSearch?['max_num_results'] as int?,
      rankingOptions: fileSearch?['ranking_options'] != null
          ? FileSearchRankingOptions.fromJson(
              fileSearch!['ranking_options'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// The maximum number of results to return.
  ///
  /// Defaults to 20. Range: 1-50.
  final int? maxNumResults;

  /// The ranking options for file search.
  final FileSearchRankingOptions? rankingOptions;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'file_search',
    if (maxNumResults != null || rankingOptions != null)
      'file_search': {
        if (maxNumResults != null) 'max_num_results': maxNumResults,
        if (rankingOptions != null) 'ranking_options': rankingOptions!.toJson(),
      },
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileSearchTool &&
          runtimeType == other.runtimeType &&
          maxNumResults == other.maxNumResults;

  @override
  int get hashCode => maxNumResults.hashCode;

  @override
  String toString() => 'FileSearchTool(maxNumResults: $maxNumResults)';
}

/// Ranking options for file search.
@immutable
class FileSearchRankingOptions {
  /// Creates a [FileSearchRankingOptions].
  const FileSearchRankingOptions({required this.ranker, this.scoreThreshold});

  /// Creates a [FileSearchRankingOptions] from JSON.
  factory FileSearchRankingOptions.fromJson(Map<String, dynamic> json) {
    return FileSearchRankingOptions(
      ranker: json['ranker'] as String,
      scoreThreshold: (json['score_threshold'] as num?)?.toDouble(),
    );
  }

  /// The ranker to use.
  ///
  /// Currently only `default_2024_08_21` is available.
  final String ranker;

  /// The minimum score threshold for results.
  ///
  /// Range: 0-1. Higher values return fewer, more relevant results.
  final double? scoreThreshold;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'ranker': ranker,
    if (scoreThreshold != null) 'score_threshold': scoreThreshold,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileSearchRankingOptions &&
          runtimeType == other.runtimeType &&
          ranker == other.ranker;

  @override
  int get hashCode => ranker.hashCode;

  @override
  String toString() => 'FileSearchRankingOptions(ranker: $ranker)';
}

/// Function tool for calling custom functions.
///
/// Allows the assistant to call functions you define to interact
/// with external systems, databases, or APIs.
@immutable
class FunctionTool implements AssistantTool {
  /// Creates a [FunctionTool].
  const FunctionTool({
    required this.name,
    this.description,
    this.parameters,
    this.strict,
  });

  /// Creates a [FunctionTool] from JSON.
  factory FunctionTool.fromJson(Map<String, dynamic> json) {
    final function = json['function'] as Map<String, dynamic>;
    return FunctionTool(
      name: function['name'] as String,
      description: function['description'] as String?,
      parameters: function['parameters'] as Map<String, dynamic>?,
      strict: function['strict'] as bool?,
    );
  }

  /// The name of the function.
  final String name;

  /// A description of what the function does.
  final String? description;

  /// The JSON schema for the function parameters.
  final Map<String, dynamic>? parameters;

  /// Whether to enable strict schema adherence.
  final bool? strict;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function',
    'function': {
      'name': name,
      if (description != null) 'description': description,
      if (parameters != null) 'parameters': parameters,
      if (strict != null) 'strict': strict,
    },
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionTool &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'FunctionTool(name: $name)';
}
