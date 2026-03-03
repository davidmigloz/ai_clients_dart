import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Tool definition for the Responses API.
///
/// Supports function tools, MCP tools, and OpenAI built-in tools.
sealed class ResponseTool {
  /// Creates a [ResponseTool].
  const ResponseTool();

  /// Creates a [ResponseTool] from JSON.
  factory ResponseTool.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'function' => FunctionTool.fromJson(json),
      'web_search_preview' ||
      'web_search' ||
      'web_search_preview_2025_03_11' => WebSearchTool.fromJson(json),
      'file_search' => FileSearchTool.fromJson(json),
      'code_interpreter' => CodeInterpreterTool.fromJson(json),
      'computer_use_preview' => ComputerUseTool.fromJson(json),
      'image_generation' => ImageGenerationTool.fromJson(json),
      'mcp' => McpTool.fromJson(json),
      'shell' => ShellTool.fromJson(json),
      'local_shell' => LocalShellTool.fromJson(json),
      _ => throw FormatException('Unknown ResponseTool type: $type'),
    };
  }

  /// Creates a function tool.
  static FunctionTool function({
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

  /// Creates a web search tool.
  static WebSearchTool webSearch({
    String? searchContextSize,
    ApproximateLocation? userLocation,
  }) => WebSearchTool(
    searchContextSize: searchContextSize,
    userLocation: userLocation,
  );

  /// Creates a file search tool.
  static FileSearchTool fileSearch({
    List<String>? vectorStoreIds,
    int? maxNumResults,
    FileSearchRankingOptions? rankingOptions,
    FileSearchFilter? filters,
  }) => FileSearchTool(
    vectorStoreIds: vectorStoreIds,
    maxNumResults: maxNumResults,
    rankingOptions: rankingOptions,
    filters: filters,
  );

  /// Creates a code interpreter tool.
  static CodeInterpreterTool codeInterpreter({
    List<String>? fileIds,
    String? container,
  }) => CodeInterpreterTool(fileIds: fileIds, container: container);

  /// Creates a computer use tool.
  static ComputerUseTool computerUse({
    required String environment,
    required int displayWidth,
    required int displayHeight,
  }) => ComputerUseTool(
    environment: environment,
    displayWidth: displayWidth,
    displayHeight: displayHeight,
  );

  /// Creates an image generation tool.
  static ImageGenerationTool imageGeneration({
    String? background,
    String? inputImageMask,
    String? model,
    bool? moderation,
    String? outputCompression,
    String? outputFormat,
    bool? partialImages,
    String? quality,
    String? size,
  }) => ImageGenerationTool(
    background: background,
    inputImageMask: inputImageMask,
    model: model,
    moderation: moderation,
    outputCompression: outputCompression,
    outputFormat: outputFormat,
    partialImages: partialImages,
    quality: quality,
    size: size,
  );

  /// Creates an MCP tool.
  static McpTool mcp({
    required String serverLabel,
    required String serverUrl,
    List<String>? allowedTools,
    String? requireApproval,
  }) => McpTool(
    serverLabel: serverLabel,
    serverUrl: serverUrl,
    allowedTools: allowedTools,
    requireApproval: requireApproval,
  );

  /// Creates a hosted shell tool.
  static ShellTool shell() => const ShellTool();

  /// Creates a local shell tool.
  static LocalShellTool localShell() => const LocalShellTool();

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A function tool.
@immutable
class FunctionTool extends ResponseTool {
  /// The function name.
  final String name;

  /// Description of what the function does.
  final String? description;

  /// JSON Schema for the function parameters.
  final Map<String, dynamic>? parameters;

  /// Whether to enable strict schema adherence.
  final bool? strict;

  /// Creates a [FunctionTool].
  const FunctionTool({
    required this.name,
    this.description,
    this.parameters,
    this.strict,
  });

  /// Creates a [FunctionTool] from JSON.
  factory FunctionTool.fromJson(Map<String, dynamic> json) {
    return FunctionTool(
      name: json['name'] as String,
      description: json['description'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
      strict: json['strict'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function',
    'name': name,
    if (description != null) 'description': description,
    if (parameters != null) 'parameters': parameters,
    if (strict != null) 'strict': strict,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionTool &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          mapsEqual(parameters, other.parameters) &&
          strict == other.strict;

  @override
  int get hashCode => Object.hash(name, description, parameters, strict);

  @override
  String toString() =>
      'FunctionTool(name: $name, description: $description, parameters: $parameters, strict: $strict)';
}

/// Approximate user location for localized web search results.
@immutable
class ApproximateLocation {
  /// The two-letter country code (e.g. 'US').
  final String? country;

  /// The region or state (e.g. 'New York').
  final String? region;

  /// The city name (e.g. 'New York City').
  final String? city;

  /// The IANA timezone (e.g. 'America/New_York').
  final String? timezone;

  /// Creates an [ApproximateLocation].
  const ApproximateLocation({
    this.country,
    this.region,
    this.city,
    this.timezone,
  });

  /// Creates an [ApproximateLocation] from JSON.
  factory ApproximateLocation.fromJson(Map<String, dynamic> json) {
    return ApproximateLocation(
      country: json['country'] as String?,
      region: json['region'] as String?,
      city: json['city'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': 'approximate',
    if (country != null) 'country': country,
    if (region != null) 'region': region,
    if (city != null) 'city': city,
    if (timezone != null) 'timezone': timezone,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApproximateLocation &&
          runtimeType == other.runtimeType &&
          country == other.country &&
          region == other.region &&
          city == other.city &&
          timezone == other.timezone;

  @override
  int get hashCode => Object.hash(country, region, city, timezone);

  @override
  String toString() =>
      'ApproximateLocation(country: $country, region: $region, city: $city, timezone: $timezone)';
}

/// Web search tool for searching the web.
@immutable
class WebSearchTool extends ResponseTool {
  /// The type of the tool.
  final String type;

  /// The amount of context to include from web search results.
  ///
  /// Can be 'low', 'medium', or 'high'.
  final String? searchContextSize;

  /// The user's approximate location for localized search results.
  final ApproximateLocation? userLocation;

  /// Creates a [WebSearchTool].
  const WebSearchTool({
    this.type = 'web_search_preview',
    this.searchContextSize,
    this.userLocation,
  });

  /// Creates a [WebSearchTool] from JSON.
  factory WebSearchTool.fromJson(Map<String, dynamic> json) {
    return WebSearchTool(
      type: json['type'] as String? ?? 'web_search_preview',
      searchContextSize: json['search_context_size'] as String?,
      userLocation: json['user_location'] != null
          ? ApproximateLocation.fromJson(
              json['user_location'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (searchContextSize != null) 'search_context_size': searchContextSize,
    if (userLocation != null) 'user_location': userLocation!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchTool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          searchContextSize == other.searchContextSize &&
          userLocation == other.userLocation;

  @override
  int get hashCode => Object.hash(type, searchContextSize, userLocation);

  @override
  String toString() =>
      'WebSearchTool(type: $type, searchContextSize: $searchContextSize, userLocation: $userLocation)';
}

/// A filter for file search metadata.
///
/// See [ComparisonFilter] and [CompoundFilter].
sealed class FileSearchFilter {
  /// Creates a [FileSearchFilter].
  const FileSearchFilter();

  /// Creates a [FileSearchFilter] from JSON.
  factory FileSearchFilter.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'eq' ||
      'ne' ||
      'gt' ||
      'gte' ||
      'lt' ||
      'lte' ||
      'in' ||
      'nin' => ComparisonFilter.fromJson(json),
      'and' || 'or' => CompoundFilter.fromJson(json),
      _ => throw FormatException('Unknown FileSearchFilter type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A comparison filter for file search metadata.
@immutable
class ComparisonFilter extends FileSearchFilter {
  /// The comparison operator (e.g. 'eq', 'ne', 'gt', 'gte', 'lt', 'lte',
  /// 'in', 'nin').
  final String type;

  /// The metadata attribute key to filter on.
  final String key;

  /// The value to compare against.
  ///
  /// Can be a [String], [num], [bool], or [List] of those types.
  final Object value;

  /// Creates a [ComparisonFilter].
  const ComparisonFilter({
    required this.type,
    required this.key,
    required this.value,
  });

  /// Creates a [ComparisonFilter] from JSON.
  factory ComparisonFilter.fromJson(Map<String, dynamic> json) {
    return ComparisonFilter(
      type: json['type'] as String,
      key: json['key'] as String,
      value: json['value'] as Object,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'key': key, 'value': value};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComparisonFilter &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          key == other.key &&
          _valuesEqual(value, other.value);

  @override
  int get hashCode => Object.hash(
    type,
    key,
    value is List ? Object.hashAll(value as List) : value,
  );

  static bool _valuesEqual(Object a, Object b) =>
      (a is List && b is List) ? listsEqual(a, b) : a == b;

  @override
  String toString() =>
      'ComparisonFilter(type: $type, key: $key, value: $value)';
}

/// A compound filter that combines multiple filters with a logical operator.
@immutable
class CompoundFilter extends FileSearchFilter {
  /// The logical operator ('and' or 'or').
  final String type;

  /// The list of filters to combine.
  final List<FileSearchFilter> filters;

  /// Creates a [CompoundFilter].
  const CompoundFilter({required this.type, required this.filters});

  /// Creates a [CompoundFilter] from JSON.
  factory CompoundFilter.fromJson(Map<String, dynamic> json) {
    return CompoundFilter(
      type: json['type'] as String,
      filters: (json['filters'] as List)
          .map((e) => FileSearchFilter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'filters': filters.map((f) => f.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompoundFilter &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          listsEqual(filters, other.filters);

  @override
  int get hashCode => Object.hash(type, Object.hashAll(filters));

  @override
  String toString() => 'CompoundFilter(type: $type, filters: $filters)';
}

/// File search tool for searching vector stores.
@immutable
class FileSearchTool extends ResponseTool {
  /// The IDs of the vector stores to search.
  final List<String>? vectorStoreIds;

  /// Maximum number of search results to return.
  final int? maxNumResults;

  /// Ranking options for search results.
  final FileSearchRankingOptions? rankingOptions;

  /// A filter to apply based on file metadata.
  final FileSearchFilter? filters;

  /// Creates a [FileSearchTool].
  const FileSearchTool({
    this.vectorStoreIds,
    this.maxNumResults,
    this.rankingOptions,
    this.filters,
  });

  /// Creates a [FileSearchTool] from JSON.
  factory FileSearchTool.fromJson(Map<String, dynamic> json) {
    return FileSearchTool(
      vectorStoreIds: (json['vector_store_ids'] as List?)?.cast<String>(),
      maxNumResults: json['max_num_results'] as int?,
      rankingOptions: json['ranking_options'] != null
          ? FileSearchRankingOptions.fromJson(
              json['ranking_options'] as Map<String, dynamic>,
            )
          : null,
      filters: json['filters'] != null
          ? FileSearchFilter.fromJson(json['filters'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'file_search',
    if (vectorStoreIds != null) 'vector_store_ids': vectorStoreIds,
    if (maxNumResults != null) 'max_num_results': maxNumResults,
    if (rankingOptions != null) 'ranking_options': rankingOptions!.toJson(),
    if (filters != null) 'filters': filters!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileSearchTool &&
          runtimeType == other.runtimeType &&
          listsEqual(vectorStoreIds, other.vectorStoreIds) &&
          maxNumResults == other.maxNumResults &&
          rankingOptions == other.rankingOptions &&
          filters == other.filters;

  @override
  int get hashCode =>
      Object.hash(vectorStoreIds, maxNumResults, rankingOptions, filters);

  @override
  String toString() =>
      'FileSearchTool(vectorStoreIds: $vectorStoreIds, maxNumResults: $maxNumResults, rankingOptions: $rankingOptions, filters: $filters)';
}

/// Ranking options for file search.
@immutable
class FileSearchRankingOptions {
  /// The ranker to use for scoring results.
  final String? ranker;

  /// The score threshold for filtering results.
  final double? scoreThreshold;

  /// Creates a [FileSearchRankingOptions].
  const FileSearchRankingOptions({this.ranker, this.scoreThreshold});

  /// Creates a [FileSearchRankingOptions] from JSON.
  factory FileSearchRankingOptions.fromJson(Map<String, dynamic> json) {
    return FileSearchRankingOptions(
      ranker: json['ranker'] as String?,
      scoreThreshold: (json['score_threshold'] as num?)?.toDouble(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (ranker != null) 'ranker': ranker,
    if (scoreThreshold != null) 'score_threshold': scoreThreshold,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileSearchRankingOptions &&
          runtimeType == other.runtimeType &&
          ranker == other.ranker &&
          scoreThreshold == other.scoreThreshold;

  @override
  int get hashCode => Object.hash(ranker, scoreThreshold);

  @override
  String toString() =>
      'FileSearchRankingOptions(ranker: $ranker, scoreThreshold: $scoreThreshold)';
}

/// Code interpreter tool for executing code.
@immutable
class CodeInterpreterTool extends ResponseTool {
  /// The IDs of files to make available to the code interpreter.
  final List<String>? fileIds;

  /// The container to use for code execution.
  final String? container;

  /// Creates a [CodeInterpreterTool].
  const CodeInterpreterTool({this.fileIds, this.container});

  /// Creates a [CodeInterpreterTool] from JSON.
  factory CodeInterpreterTool.fromJson(Map<String, dynamic> json) {
    return CodeInterpreterTool(
      fileIds: (json['file_ids'] as List?)?.cast<String>(),
      container: json['container'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'code_interpreter',
    if (fileIds != null) 'file_ids': fileIds,
    if (container != null) 'container': container,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterTool &&
          runtimeType == other.runtimeType &&
          listsEqual(fileIds, other.fileIds) &&
          container == other.container;

  @override
  int get hashCode => Object.hash(fileIds, container);

  @override
  String toString() =>
      'CodeInterpreterTool(fileIds: $fileIds, container: $container)';
}

/// Computer use tool for controlling a computer.
@immutable
class ComputerUseTool extends ResponseTool {
  /// The environment to use.
  ///
  /// Can be 'browser', 'mac', 'windows', or 'ubuntu'.
  final String environment;

  /// The width of the display in pixels.
  final int displayWidth;

  /// The height of the display in pixels.
  final int displayHeight;

  /// Creates a [ComputerUseTool].
  const ComputerUseTool({
    required this.environment,
    required this.displayWidth,
    required this.displayHeight,
  });

  /// Creates a [ComputerUseTool] from JSON.
  factory ComputerUseTool.fromJson(Map<String, dynamic> json) {
    return ComputerUseTool(
      environment: json['environment'] as String,
      displayWidth: json['display_width'] as int,
      displayHeight: json['display_height'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'computer_use_preview',
    'environment': environment,
    'display_width': displayWidth,
    'display_height': displayHeight,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComputerUseTool &&
          runtimeType == other.runtimeType &&
          environment == other.environment &&
          displayWidth == other.displayWidth &&
          displayHeight == other.displayHeight;

  @override
  int get hashCode => Object.hash(environment, displayWidth, displayHeight);

  @override
  String toString() =>
      'ComputerUseTool(environment: $environment, displayWidth: $displayWidth, displayHeight: $displayHeight)';
}

/// Image generation tool for creating images.
@immutable
class ImageGenerationTool extends ResponseTool {
  /// The background color for generated images.
  final String? background;

  /// The input image mask for inpainting.
  final String? inputImageMask;

  /// The model to use for image generation.
  final String? model;

  /// Whether to apply content moderation.
  final bool? moderation;

  /// The compression level for output images.
  final String? outputCompression;

  /// The format for output images.
  final String? outputFormat;

  /// Whether to return partial images during generation.
  final bool? partialImages;

  /// The quality level for generated images.
  final String? quality;

  /// The size of generated images.
  final String? size;

  /// Creates an [ImageGenerationTool].
  const ImageGenerationTool({
    this.background,
    this.inputImageMask,
    this.model,
    this.moderation,
    this.outputCompression,
    this.outputFormat,
    this.partialImages,
    this.quality,
    this.size,
  });

  /// Creates an [ImageGenerationTool] from JSON.
  factory ImageGenerationTool.fromJson(Map<String, dynamic> json) {
    return ImageGenerationTool(
      background: json['background'] as String?,
      inputImageMask: json['input_image_mask'] as String?,
      model: json['model'] as String?,
      moderation: json['moderation'] as bool?,
      outputCompression: json['output_compression'] as String?,
      outputFormat: json['output_format'] as String?,
      partialImages: json['partial_images'] as bool?,
      quality: json['quality'] as String?,
      size: json['size'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'image_generation',
    if (background != null) 'background': background,
    if (inputImageMask != null) 'input_image_mask': inputImageMask,
    if (model != null) 'model': model,
    if (moderation != null) 'moderation': moderation,
    if (outputCompression != null) 'output_compression': outputCompression,
    if (outputFormat != null) 'output_format': outputFormat,
    if (partialImages != null) 'partial_images': partialImages,
    if (quality != null) 'quality': quality,
    if (size != null) 'size': size,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageGenerationTool &&
          runtimeType == other.runtimeType &&
          background == other.background &&
          inputImageMask == other.inputImageMask &&
          model == other.model &&
          moderation == other.moderation &&
          outputCompression == other.outputCompression &&
          outputFormat == other.outputFormat &&
          partialImages == other.partialImages &&
          quality == other.quality &&
          size == other.size;

  @override
  int get hashCode => Object.hash(
    background,
    inputImageMask,
    model,
    moderation,
    outputCompression,
    outputFormat,
    partialImages,
    quality,
    size,
  );

  @override
  String toString() =>
      'ImageGenerationTool(background: $background, inputImageMask: $inputImageMask, model: $model, moderation: $moderation, outputCompression: $outputCompression, outputFormat: $outputFormat, partialImages: $partialImages, quality: $quality, size: $size)';
}

/// Model Context Protocol (MCP) tool.
@immutable
class McpTool extends ResponseTool {
  /// Label for the MCP server.
  final String serverLabel;

  /// URL of the MCP server.
  final String serverUrl;

  /// List of allowed tools from this server.
  final List<String>? allowedTools;

  /// Approval requirement for tool execution.
  final String? requireApproval;

  /// Creates an [McpTool].
  const McpTool({
    required this.serverLabel,
    required this.serverUrl,
    this.allowedTools,
    this.requireApproval,
  });

  /// Creates an [McpTool] from JSON.
  factory McpTool.fromJson(Map<String, dynamic> json) {
    return McpTool(
      serverLabel: json['server_label'] as String,
      serverUrl: json['server_url'] as String,
      allowedTools: (json['allowed_tools'] as List?)?.cast<String>(),
      requireApproval: json['require_approval'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp',
    'server_label': serverLabel,
    'server_url': serverUrl,
    if (allowedTools != null) 'allowed_tools': allowedTools,
    if (requireApproval != null) 'require_approval': requireApproval,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpTool &&
          runtimeType == other.runtimeType &&
          serverLabel == other.serverLabel &&
          serverUrl == other.serverUrl &&
          listsEqual(allowedTools, other.allowedTools) &&
          requireApproval == other.requireApproval;

  @override
  int get hashCode =>
      Object.hash(serverLabel, serverUrl, allowedTools, requireApproval);

  @override
  String toString() =>
      'McpTool(serverLabel: $serverLabel, serverUrl: $serverUrl, allowedTools: $allowedTools, requireApproval: $requireApproval)';
}

/// Hosted shell tool for command execution.
@immutable
class ShellTool extends ResponseTool {
  /// Creates a [ShellTool].
  const ShellTool();

  /// Creates a [ShellTool] from JSON.
  factory ShellTool.fromJson(Map<String, dynamic> json) {
    if ((json['type'] as String?) != 'shell') {
      throw const FormatException('Invalid type for ShellTool');
    }
    return const ShellTool();
  }

  @override
  Map<String, dynamic> toJson() => const {'type': 'shell'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ShellTool;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ShellTool()';
}

/// Local shell tool for command execution in a local environment.
@immutable
class LocalShellTool extends ResponseTool {
  /// Creates a [LocalShellTool].
  const LocalShellTool();

  /// Creates a [LocalShellTool] from JSON.
  factory LocalShellTool.fromJson(Map<String, dynamic> json) {
    if ((json['type'] as String?) != 'local_shell') {
      throw const FormatException('Invalid type for LocalShellTool');
    }
    return const LocalShellTool();
  }

  @override
  Map<String, dynamic> toJson() => const {'type': 'local_shell'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LocalShellTool;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'LocalShellTool()';
}
