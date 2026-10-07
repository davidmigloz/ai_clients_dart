import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';
import '../config/search_content_type.dart';
import '../config/tool_search_execution_type.dart';
import '../config/web_search_return_token_budget.dart';
import 'code_interpreter_container.dart';
import 'shell_tool_environment.dart';
import 'tool_call_caller.dart';
import 'web_search_filters.dart';
import 'web_search_image_settings.dart';

/// Marker interface for tools that may appear inside a [NamespaceTool].
///
/// Only [FunctionTool] and [CustomTool] are permitted by the spec.
abstract interface class NamespaceAllowedTool {
  /// Converts this tool to its JSON representation.
  Map<String, dynamic> toJson();
}

/// Tool definition for the Responses API.
///
/// ## Supported Tools
///
/// - [FunctionTool] - Custom function definitions
/// - [CustomTool] - Custom tool (type: 'custom')
/// - [WebSearchTool] - Built-in web search
/// - [FileSearchTool] - Search vector stores
/// - [CodeInterpreterTool] - Execute code
/// - [ComputerUseTool] - Control a computer (preview)
/// - [ComputerTool] - Control a computer (GA)
/// - [ImageGenerationTool] - Generate images
/// - [McpTool] - Model Context Protocol tools
/// - [ToolSearchTool] - Search available tools
/// - [NamespaceTool] - Group tools under a namespace
/// - [ShellTool] - Hosted or local shell tool
/// - [LocalShellTool] - Local shell tool
/// - [ProgrammaticToolCallingTool] - Programmatic tool calling
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
      'web_search_2025_08_26' ||
      'web_search_preview_2025_03_11' => WebSearchTool.fromJson(json),
      'file_search' => FileSearchTool.fromJson(json),
      'code_interpreter' => CodeInterpreterTool.fromJson(json),
      'computer_use_preview' => ComputerUseTool.fromJson(json),
      'image_generation' => ImageGenerationTool.fromJson(json),
      'computer' => ComputerTool.fromJson(json),
      'mcp' => McpTool.fromJson(json),
      'namespace' => NamespaceTool.fromJson(json),
      'shell' => ShellTool.fromJson(json),
      'local_shell' => LocalShellTool.fromJson(json),
      'tool_search' => ToolSearchTool.fromJson(json),
      'custom' => CustomTool.fromJson(json),
      'programmatic_tool_calling' => ProgrammaticToolCallingTool.fromJson(json),
      _ => throw FormatException('Unknown ResponseTool type: $type'),
    };
  }

  /// Creates a function tool.
  static FunctionTool function({
    required String name,
    String? description,
    Map<String, dynamic>? parameters,
    bool? strict,
    bool? deferLoading,
    List<CallableToolAllowedCaller>? allowedCallers,
    Map<String, dynamic>? outputSchema,
    bool? async,
  }) => FunctionTool(
    name: name,
    description: description,
    parameters: parameters,
    strict: strict,
    deferLoading: deferLoading,
    allowedCallers: allowedCallers,
    outputSchema: outputSchema,
    async: async,
  );

  /// Creates a custom tool with an optional input format.
  static CustomTool custom({
    required String name,
    String? description,
    Map<String, dynamic>? format,
    bool? deferLoading,
    List<CallableToolAllowedCaller>? allowedCallers,
    bool? async,
  }) => CustomTool(
    name: name,
    description: description,
    format: format,
    deferLoading: deferLoading,
    allowedCallers: allowedCallers,
    async: async,
  );

  /// Creates a GA web search tool.
  ///
  /// Pass an explicit preview [type] to retain preview behavior. Preview tools
  /// do not support [externalWebAccess], [filters], [returnTokenBudget], or
  /// [imageSettings]; supplying them fails when serialized.
  static WebSearchTool webSearch({
    String type = 'web_search',
    String? searchContextSize,
    ApproximateLocation? userLocation,
    List<SearchContentType>? searchContentTypes,
    bool? externalWebAccess,
    WebSearchFilters? filters,
    WebSearchReturnTokenBudget? returnTokenBudget,
    WebSearchImageSettings? imageSettings,
  }) => WebSearchTool(
    type: type,
    searchContextSize: searchContextSize,
    userLocation: userLocation,
    searchContentTypes: searchContentTypes,
    externalWebAccess: externalWebAccess,
    filters: filters,
    returnTokenBudget: returnTokenBudget,
    imageSettings: imageSettings,
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
    required CodeInterpreterContainer container,
  }) => CodeInterpreterTool(container: container);

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
    int? partialImages,
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

  /// Creates a computer tool (GA).
  static ComputerTool computer() => const ComputerTool();

  /// Creates a namespace tool.
  static NamespaceTool namespace({
    required String name,
    required String description,
    required List<NamespaceAllowedTool> tools,
  }) => NamespaceTool(name: name, description: description, tools: tools);

  /// Creates a tool search tool.
  static ToolSearchTool toolSearch({
    ToolSearchExecutionType? execution,
    String? description,
    Map<String, dynamic>? parameters,
  }) => ToolSearchTool(
    execution: execution,
    description: description,
    parameters: parameters,
  );

  /// Creates an MCP tool.
  ///
  /// One of [serverUrl], [connectorId], or [tunnelId] must be provided;
  /// otherwise an [ArgumentError] is thrown.
  static McpTool mcp({
    required String serverLabel,
    String? serverUrl,
    String? connectorId,
    String? tunnelId,
    List<String>? allowedTools,
    String? requireApproval,
    bool? deferLoading,
  }) {
    if (serverUrl == null && connectorId == null && tunnelId == null) {
      throw ArgumentError(
        'McpTool requires one of serverUrl, connectorId, or tunnelId',
      );
    }
    return McpTool(
      serverLabel: serverLabel,
      serverUrl: serverUrl,
      connectorId: connectorId,
      tunnelId: tunnelId,
      allowedTools: allowedTools,
      requireApproval: requireApproval,
      deferLoading: deferLoading,
    );
  }

  /// Creates a hosted or local shell tool.
  ///
  /// Omit [environment] to leave selection to the server. Optional nullable
  /// settings normalize parsed explicit null to omission.
  static ShellTool shell({
    ShellToolEnvironment? environment,
    List<CallableToolAllowedCaller>? allowedCallers,
  }) => ShellTool(environment: environment, allowedCallers: allowedCallers);

  /// Creates a local shell tool.
  static LocalShellTool localShell() => const LocalShellTool();

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A function tool.
@immutable
class FunctionTool extends ResponseTool implements NamespaceAllowedTool {
  /// The fixed tool discriminator.
  String get type => 'function';

  /// The function name.
  final String name;

  /// Description of what the function does.
  final String? description;

  /// JSON Schema for the function parameters.
  final Map<String, dynamic>? parameters;

  /// Whether to enable strict schema adherence.
  final bool? strict;

  /// Whether to defer loading this tool until needed.
  final bool? deferLoading;

  /// The tool invocation context(s) this function may be called from.
  final List<CallableToolAllowedCaller>? allowedCallers;

  /// A JSON schema object describing the JSON value encoded in string
  /// outputs for this function.
  final Map<String, dynamic>? outputSchema;

  /// Whether the model may continue while this tool call is pending.
  ///
  /// The application executes the tool and returns its result. Omission leaves
  /// the server's behavior unchanged; an explicit false is preserved.
  final bool? async;

  /// Creates a [FunctionTool].
  const FunctionTool({
    required this.name,
    this.description,
    this.parameters,
    this.strict,
    this.deferLoading,
    this.allowedCallers,
    this.outputSchema,
    this.async,
  });

  /// Creates a [FunctionTool] from JSON.
  factory FunctionTool.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'function', 'FunctionTool');
    return FunctionTool(
      name: requireJsonString(json['name'], 'FunctionTool.name'),
      description: json['description'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
      strict: json['strict'] as bool?,
      deferLoading: json['defer_loading'] as bool?,
      allowedCallers: (json['allowed_callers'] as List?)
          ?.map((e) => CallableToolAllowedCaller.fromJson(e as String))
          .toList(),
      outputSchema: json['output_schema'] as Map<String, dynamic>?,
      async: optionalJsonBool(json, 'async', 'FunctionTool'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function',
    'name': name,
    if (description != null) 'description': description,
    if (parameters != null) 'parameters': parameters,
    if (strict != null) 'strict': strict,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (allowedCallers != null)
      'allowed_callers': allowedCallers!.map((e) => e.toJson()).toList(),
    if (outputSchema != null) 'output_schema': outputSchema,
    if (async != null) 'async': async,
  };

  /// Creates a copy; pass null to clear an optional setting.
  ///
  /// Schema maps and caller lists retain their existing ownership semantics.
  FunctionTool copyWith({
    String? name,
    Object? description = unsetCopyWithValue,
    Object? parameters = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? outputSchema = unsetCopyWithValue,
    Object? async = unsetCopyWithValue,
  }) => FunctionTool(
    name: name ?? this.name,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    parameters: parameters == unsetCopyWithValue
        ? this.parameters
        : parameters as Map<String, dynamic>?,
    strict: strict == unsetCopyWithValue ? this.strict : strict as bool?,
    deferLoading: deferLoading == unsetCopyWithValue
        ? this.deferLoading
        : deferLoading as bool?,
    allowedCallers: allowedCallers == unsetCopyWithValue
        ? this.allowedCallers
        : allowedCallers as List<CallableToolAllowedCaller>?,
    outputSchema: outputSchema == unsetCopyWithValue
        ? this.outputSchema
        : outputSchema as Map<String, dynamic>?,
    async: async == unsetCopyWithValue ? this.async : async as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionTool &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          mapsDeepEqual(parameters, other.parameters) &&
          strict == other.strict &&
          deferLoading == other.deferLoading &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          mapsDeepEqual(outputSchema, other.outputSchema) &&
          async == other.async;

  @override
  int get hashCode => Object.hash(
    name,
    description,
    mapDeepHashCode(parameters),
    strict,
    deferLoading,
    listHash(allowedCallers),
    mapDeepHashCode(outputSchema),
    async,
  );

  @override
  String toString() =>
      'FunctionTool(name: $name, '
      'description: ${description == null ? 'null' : '${description!.length} chars'}, '
      'parameters: ${parameters == null ? 'null' : '${parameters!.length} keys'}, '
      'strict: $strict, deferLoading: $deferLoading, '
      'allowedCallers: $allowedCallers, '
      'outputSchema: ${outputSchema == null ? 'null' : '${outputSchema!.length} keys'}, '
      'async: $async)';
}

/// Approximate user location for localized web search results.
@immutable
class ApproximateLocation {
  /// The fixed location discriminator, optional when parsing.
  String get type => 'approximate';

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
    if (json.containsKey('type')) {
      requireJsonType(json, 'approximate', 'ApproximateLocation');
    }
    return ApproximateLocation(
      country: optionalJsonString(
        json,
        'country',
        'ApproximateLocation',
        nullable: true,
      ),
      region: optionalJsonString(
        json,
        'region',
        'ApproximateLocation',
        nullable: true,
      ),
      city: optionalJsonString(
        json,
        'city',
        'ApproximateLocation',
        nullable: true,
      ),
      timezone: optionalJsonString(
        json,
        'timezone',
        'ApproximateLocation',
        nullable: true,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (country != null) 'country': country,
    if (region != null) 'region': region,
    if (city != null) 'city': city,
    if (timezone != null) 'timezone': timezone,
  };

  /// Creates a copy, with explicit null clearing an optional location member.
  ApproximateLocation copyWith({
    Object? country = unsetCopyWithValue,
    Object? region = unsetCopyWithValue,
    Object? city = unsetCopyWithValue,
    Object? timezone = unsetCopyWithValue,
  }) => ApproximateLocation(
    country: identical(country, unsetCopyWithValue)
        ? this.country
        : country as String?,
    region: identical(region, unsetCopyWithValue)
        ? this.region
        : region as String?,
    city: identical(city, unsetCopyWithValue) ? this.city : city as String?,
    timezone: identical(timezone, unsetCopyWithValue)
        ? this.timezone
        : timezone as String?,
  );

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
      'ApproximateLocation(type: $type, '
      'country: ${country == null ? 'null' : '${country!.length} chars'}, '
      'region: ${region == null ? 'null' : '${region!.length} chars'}, '
      'city: ${city == null ? 'null' : '${city!.length} chars'}, '
      'timezone: ${timezone == null ? 'null' : '${timezone!.length} chars'})';
}

/// Web search tool for searching the web.
///
/// Defaults to GA `web_search`. Explicit preview types remain available, but
/// reject GA-only access, filters, budget and image settings. The original
/// [searchContentTypes] list remains caller-owned for compatibility and must
/// not be mutated after construction.
@immutable
class WebSearchTool extends ResponseTool {
  /// One of `web_search`, `web_search_2025_08_26`, `web_search_preview`, or
  /// `web_search_preview_2025_03_11`.
  final String type;

  /// The amount of context to include from web search results.
  ///
  /// Can be 'low', 'medium', or 'high'.
  final String? searchContextSize;

  /// The user's approximate location for localized search results.
  final ApproximateLocation? userLocation;

  /// The types of content to search for.
  final List<SearchContentType>? searchContentTypes;

  /// Whether GA search may access the live web. Explicit false is preserved.
  final bool? externalWebAccess;

  /// Optional GA domain filters, including guide-defined blocked domains.
  final WebSearchFilters? filters;

  /// Guide-defined GA return-token budget. Supported models vary.
  final WebSearchReturnTokenBudget? returnTokenBudget;

  /// Guide-defined GA image-result settings.
  final WebSearchImageSettings? imageSettings;

  /// Creates a [WebSearchTool].
  const WebSearchTool({
    this.type = 'web_search',
    this.searchContextSize,
    this.userLocation,
    this.searchContentTypes,
    this.externalWebAccess,
    this.filters,
    this.returnTokenBudget,
    this.imageSettings,
  });

  /// Creates a [WebSearchTool] from JSON.
  factory WebSearchTool.fromJson(Map<String, dynamic> json) {
    final contentTypes = json['search_content_types'];
    if (contentTypes != null && contentTypes is! List) {
      throw const FormatException(
        'WebSearchTool.search_content_types: expected an array',
      );
    }
    final rawBudget = optionalJsonString(
      json,
      'return_token_budget',
      'WebSearchTool',
    );
    if (rawBudget != null &&
        rawBudget != 'default' &&
        rawBudget != 'unlimited') {
      throw const FormatException(
        'WebSearchTool.return_token_budget: expected "default" or "unlimited"',
      );
    }
    final tool = WebSearchTool(
      type: requireJsonString(json['type'], 'WebSearchTool.type'),
      searchContextSize: optionalJsonString(
        json,
        'search_context_size',
        'WebSearchTool',
      ),
      userLocation: json['user_location'] != null
          ? ApproximateLocation.fromJson(
              requireJsonObject(
                json['user_location'],
                'WebSearchTool.user_location',
              ),
            )
          : null,
      searchContentTypes: contentTypes == null
          ? null
          : [
              for (var i = 0; i < (contentTypes as List).length; i++)
                SearchContentType.fromJson(
                  requireJsonString(
                    contentTypes[i],
                    'WebSearchTool.search_content_types[$i]',
                  ),
                ),
            ],
      externalWebAccess: optionalJsonBool(
        json,
        'external_web_access',
        'WebSearchTool',
      ),
      filters: json['filters'] == null
          ? null
          : WebSearchFilters.fromJson(
              requireJsonObject(json['filters'], 'WebSearchTool.filters'),
            ),
      returnTokenBudget: rawBudget == null
          ? null
          : WebSearchReturnTokenBudget.fromJson(rawBudget),
      imageSettings: !json.containsKey('image_settings')
          ? null
          : WebSearchImageSettings.fromJson(
              requireJsonObject(
                json['image_settings'],
                'WebSearchTool.image_settings',
              ),
            ),
    ).._validate(parsing: true);
    return tool;
  }

  @override
  Map<String, dynamic> toJson() {
    _validate();
    return {
      'type': type,
      if (searchContextSize != null) 'search_context_size': searchContextSize,
      if (userLocation != null) 'user_location': userLocation!.toJson(),
      if (searchContentTypes != null)
        'search_content_types': searchContentTypes!
            .map((e) => e.toJson())
            .toList(),
      if (externalWebAccess != null) 'external_web_access': externalWebAccess,
      if (filters != null) 'filters': filters!.toJson(),
      if (returnTokenBudget != null)
        'return_token_budget': returnTokenBudget!.toJson(),
      if (imageSettings != null) 'image_settings': imageSettings!.toJson(),
    };
  }

  /// Creates a copy, with explicit null clearing any optional member.
  WebSearchTool copyWith({
    String? type,
    Object? searchContextSize = unsetCopyWithValue,
    Object? userLocation = unsetCopyWithValue,
    Object? searchContentTypes = unsetCopyWithValue,
    Object? externalWebAccess = unsetCopyWithValue,
    Object? filters = unsetCopyWithValue,
    Object? returnTokenBudget = unsetCopyWithValue,
    Object? imageSettings = unsetCopyWithValue,
  }) => WebSearchTool(
    type: type ?? this.type,
    searchContextSize: identical(searchContextSize, unsetCopyWithValue)
        ? this.searchContextSize
        : searchContextSize as String?,
    userLocation: identical(userLocation, unsetCopyWithValue)
        ? this.userLocation
        : userLocation as ApproximateLocation?,
    searchContentTypes: identical(searchContentTypes, unsetCopyWithValue)
        ? this.searchContentTypes
        : searchContentTypes as List<SearchContentType>?,
    externalWebAccess: identical(externalWebAccess, unsetCopyWithValue)
        ? this.externalWebAccess
        : externalWebAccess as bool?,
    filters: identical(filters, unsetCopyWithValue)
        ? this.filters
        : filters as WebSearchFilters?,
    returnTokenBudget: identical(returnTokenBudget, unsetCopyWithValue)
        ? this.returnTokenBudget
        : returnTokenBudget as WebSearchReturnTokenBudget?,
    imageSettings: identical(imageSettings, unsetCopyWithValue)
        ? this.imageSettings
        : imageSettings as WebSearchImageSettings?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchTool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          searchContextSize == other.searchContextSize &&
          userLocation == other.userLocation &&
          listsEqual(searchContentTypes, other.searchContentTypes) &&
          externalWebAccess == other.externalWebAccess &&
          filters == other.filters &&
          returnTokenBudget == other.returnTokenBudget &&
          imageSettings == other.imageSettings;

  @override
  int get hashCode => Object.hash(
    type,
    searchContextSize,
    userLocation,
    listHash(searchContentTypes),
    externalWebAccess,
    filters,
    returnTokenBudget,
    imageSettings,
  );

  @override
  String toString() =>
      'WebSearchTool(type: $type, searchContextSize: $searchContextSize, '
      'userLocation: $userLocation, searchContentTypes: $searchContentTypes, '
      'externalWebAccess: $externalWebAccess, filters: $filters, '
      'returnTokenBudget: $returnTokenBudget, imageSettings: $imageSettings)';

  void _validate({bool parsing = false}) {
    void reject(String field, String expected) {
      final message = 'WebSearchTool.$field: $expected';
      if (parsing) throw FormatException(message);
      throw ArgumentError(message);
    }

    if (type != 'web_search' &&
        type != 'web_search_2025_08_26' &&
        type != 'web_search_preview' &&
        type != 'web_search_preview_2025_03_11') {
      reject('type', 'expected a GA or preview web-search discriminator');
    }
    if (searchContextSize != null &&
        searchContextSize != 'low' &&
        searchContextSize != 'medium' &&
        searchContextSize != 'high') {
      reject('search_context_size', 'expected "low", "medium", or "high"');
    }
    if (type == 'web_search_preview' ||
        type == 'web_search_preview_2025_03_11') {
      for (final field in [
        if (externalWebAccess != null) 'external_web_access',
        if (filters != null) 'filters',
        if (returnTokenBudget != null) 'return_token_budget',
        if (imageSettings != null) 'image_settings',
      ]) {
        reject(field, 'requires a GA web-search type');
      }
    }
  }
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
  int get hashCode => Object.hash(
    vectorStoreIds != null ? Object.hashAll(vectorStoreIds!) : null,
    maxNumResults,
    rankingOptions,
    filters,
  );

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
  /// The container to use for code execution.
  final CodeInterpreterContainer container;

  /// The tool invocation context(s) this tool may be called from.
  final List<CallableToolAllowedCaller>? allowedCallers;

  /// Creates a [CodeInterpreterTool].
  const CodeInterpreterTool({required this.container, this.allowedCallers});

  /// Creates a [CodeInterpreterTool] from JSON.
  factory CodeInterpreterTool.fromJson(Map<String, dynamic> json) {
    return CodeInterpreterTool(
      container: CodeInterpreterContainer.fromJson(json['container'] as Object),
      allowedCallers: (json['allowed_callers'] as List?)
          ?.map((e) => CallableToolAllowedCaller.fromJson(e as String))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'code_interpreter',
    'container': container.toJson(),
    if (allowedCallers != null)
      'allowed_callers': allowedCallers!.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterTool &&
          runtimeType == other.runtimeType &&
          container == other.container &&
          listsEqual(allowedCallers, other.allowedCallers);

  @override
  int get hashCode => Object.hash(container, listHash(allowedCallers));

  @override
  String toString() =>
      'CodeInterpreterTool(container: $container, allowedCallers: $allowedCallers)';
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

  /// Number of partial images to return during generation (0–3).
  final int? partialImages;

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
      partialImages: json['partial_images'] as int?,
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
///
/// One of [serverUrl], [connectorId], or [tunnelId] must be provided. The
/// default [McpTool] constructor enforces this with an `assert` (debug/test
/// builds); use [ResponseTool.mcp] for a runtime [ArgumentError] in all build
/// modes.
@immutable
class McpTool extends ResponseTool {
  /// Label for the MCP server.
  final String serverLabel;

  /// URL of the MCP server.
  ///
  /// One of [serverUrl], [connectorId], or [tunnelId] must be provided.
  final String? serverUrl;

  /// Identifier for a service connector, like those available in ChatGPT
  /// (e.g. `connector_dropbox`, `connector_gmail`, `connector_googlecalendar`,
  /// `connector_googledrive`, `connector_microsoftteams`,
  /// `connector_outlookcalendar`, `connector_outlookemail`,
  /// `connector_sharepoint`).
  ///
  /// One of [serverUrl], [connectorId], or [tunnelId] must be provided.
  final String? connectorId;

  /// The Secure MCP Tunnel ID to use instead of a direct server URL.
  ///
  /// One of [serverUrl], [connectorId], or [tunnelId] must be provided.
  final String? tunnelId;

  /// List of allowed tools from this server.
  final List<String>? allowedTools;

  /// Approval requirement for tool execution.
  final String? requireApproval;

  /// Whether to defer loading this tool until needed.
  final bool? deferLoading;

  /// The tool invocation context(s) this tool may be called from.
  final List<CallableToolAllowedCaller>? allowedCallers;

  /// Creates an [McpTool].
  ///
  /// One of [serverUrl], [connectorId], or [tunnelId] must be provided.
  const McpTool({
    required this.serverLabel,
    this.serverUrl,
    this.connectorId,
    this.tunnelId,
    this.allowedTools,
    this.requireApproval,
    this.deferLoading,
    this.allowedCallers,
  }) : assert(
         serverUrl != null || connectorId != null || tunnelId != null,
         'McpTool requires one of serverUrl, connectorId, or tunnelId',
       );

  /// Creates an [McpTool] from JSON.
  ///
  /// Throws a [FormatException] if none of `server_url`, `connector_id`, or
  /// `tunnel_id` is present, since such a tool has no address and would
  /// re-serialize as an invalid request.
  factory McpTool.fromJson(Map<String, dynamic> json) {
    final serverUrl = json['server_url'] as String?;
    final connectorId = json['connector_id'] as String?;
    final tunnelId = json['tunnel_id'] as String?;
    if (serverUrl == null && connectorId == null && tunnelId == null) {
      throw const FormatException(
        'McpTool requires one of server_url, connector_id, or tunnel_id',
      );
    }
    return McpTool(
      serverLabel: json['server_label'] as String,
      serverUrl: serverUrl,
      connectorId: connectorId,
      tunnelId: tunnelId,
      allowedTools: (json['allowed_tools'] as List?)?.cast<String>(),
      requireApproval: json['require_approval'] as String?,
      deferLoading: json['defer_loading'] as bool?,
      allowedCallers: (json['allowed_callers'] as List?)
          ?.map((e) => CallableToolAllowedCaller.fromJson(e as String))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp',
    'server_label': serverLabel,
    if (serverUrl != null) 'server_url': serverUrl,
    if (connectorId != null) 'connector_id': connectorId,
    if (tunnelId != null) 'tunnel_id': tunnelId,
    if (allowedTools != null) 'allowed_tools': allowedTools,
    if (requireApproval != null) 'require_approval': requireApproval,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (allowedCallers != null)
      'allowed_callers': allowedCallers!.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpTool &&
          runtimeType == other.runtimeType &&
          serverLabel == other.serverLabel &&
          serverUrl == other.serverUrl &&
          connectorId == other.connectorId &&
          tunnelId == other.tunnelId &&
          listsEqual(allowedTools, other.allowedTools) &&
          requireApproval == other.requireApproval &&
          deferLoading == other.deferLoading &&
          listsEqual(allowedCallers, other.allowedCallers);

  @override
  int get hashCode => Object.hash(
    serverLabel,
    serverUrl,
    connectorId,
    tunnelId,
    allowedTools != null ? Object.hashAll(allowedTools!) : null,
    requireApproval,
    deferLoading,
    listHash(allowedCallers),
  );

  @override
  String toString() =>
      'McpTool(serverLabel: $serverLabel, serverUrl: $serverUrl, connectorId: $connectorId, tunnelId: $tunnelId, allowedTools: $allowedTools, requireApproval: $requireApproval, deferLoading: $deferLoading, allowedCallers: $allowedCallers)';
}

/// Shell tool for command execution in a hosted or local environment.
@immutable
class ShellTool extends ResponseTool {
  /// The fixed tool discriminator.
  String get type => 'shell';

  /// Optional environment configuration. Parsed null is normalized to omission.
  final ShellToolEnvironment? environment;

  /// The tool invocation context(s) this tool may be called from.
  ///
  /// Caller-owned lists must not be mutated after construction. Parsed lists
  /// are unmodifiable, and parsed null is normalized to omission.
  final List<CallableToolAllowedCaller>? allowedCallers;

  /// Creates a [ShellTool].
  const ShellTool({this.environment, this.allowedCallers});

  /// Creates a [ShellTool] from JSON.
  factory ShellTool.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'shell', 'ShellTool');
    final environmentJson = json['environment'];
    ShellToolEnvironment? environment;
    if (environmentJson != null) {
      final object = requireJsonObject(
        environmentJson,
        'ShellTool.environment',
      );
      try {
        environment = ShellToolEnvironment.fromJson(object);
      } on FormatException catch (error) {
        throw FormatException('ShellTool.environment: ${error.message}');
      }
    }
    final allowedCallersJson = json['allowed_callers'];
    if (allowedCallersJson != null && allowedCallersJson is! List) {
      throw const FormatException(
        'ShellTool.allowed_callers: expected an array',
      );
    }
    return ShellTool(
      environment: environment,
      allowedCallers: allowedCallersJson == null
          ? null
          : List.unmodifiable([
              for (var i = 0; i < (allowedCallersJson as List).length; i++)
                CallableToolAllowedCaller.fromJson(
                  requireJsonString(
                    allowedCallersJson[i],
                    'ShellTool.allowed_callers[$i]',
                  ),
                ),
            ]),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (environment != null) 'environment': environment!.toJson(),
    if (allowedCallers != null)
      'allowed_callers': allowedCallers!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy; explicit null clears either optional setting.
  ShellTool copyWith({
    Object? environment = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
  }) => ShellTool(
    environment: identical(environment, unsetCopyWithValue)
        ? this.environment
        : environment as ShellToolEnvironment?,
    allowedCallers: identical(allowedCallers, unsetCopyWithValue)
        ? this.allowedCallers
        : allowedCallers == null
        ? null
        : List<CallableToolAllowedCaller>.from(allowedCallers as List),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellTool &&
          runtimeType == other.runtimeType &&
          environment == other.environment &&
          listsEqual(allowedCallers, other.allowedCallers);

  @override
  int get hashCode => Object.hash(environment, listHash(allowedCallers));

  @override
  String toString() =>
      'ShellTool(environment: $environment, '
      'allowedCallers: ${allowedCallers == null ? 'null' : '${allowedCallers!.length} items'})';
}

/// Computer tool (GA) for controlling a computer.
///
/// This is distinct from [ComputerUseTool] (`computer_use_preview`).
@immutable
class ComputerTool extends ResponseTool {
  /// Creates a [ComputerTool].
  const ComputerTool();

  /// Creates a [ComputerTool] from JSON.
  factory ComputerTool.fromJson(Map<String, dynamic> json) {
    if ((json['type'] as String?) != 'computer') {
      throw const FormatException('Invalid type for ComputerTool');
    }
    return const ComputerTool();
  }

  @override
  Map<String, dynamic> toJson() => const {'type': 'computer'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ComputerTool;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ComputerTool()';
}

/// Namespace tool for grouping tools under a namespace.
@immutable
class NamespaceTool extends ResponseTool {
  /// The namespace name.
  final String name;

  /// Description of the namespace.
  final String description;

  /// The tools in this namespace.
  final List<NamespaceAllowedTool> tools;

  /// Creates a [NamespaceTool].
  const NamespaceTool({
    required this.name,
    required this.description,
    required this.tools,
  });

  /// Creates a [NamespaceTool] from JSON.
  factory NamespaceTool.fromJson(Map<String, dynamic> json) {
    return NamespaceTool(
      name: json['name'] as String,
      description: json['description'] as String,
      tools: (json['tools'] as List).map<NamespaceAllowedTool>((e) {
        final map = e as Map<String, dynamic>;
        return switch (map['type'] as String?) {
          'function' => FunctionTool.fromJson(map),
          'custom' => CustomTool.fromJson(map),
          _ => UnknownNamespaceTool(map),
        };
      }).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'namespace',
    'name': name,
    'description': description,
    'tools': tools.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NamespaceTool &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          listsEqual(tools, other.tools);

  @override
  int get hashCode => Object.hash(name, description, Object.hashAll(tools));

  @override
  String toString() =>
      'NamespaceTool(name: $name, description: $description, tools: $tools)';
}

/// Tool search tool for searching available tools.
@immutable
class ToolSearchTool extends ResponseTool {
  /// The execution type (server or client).
  final ToolSearchExecutionType? execution;

  /// Description of the tool search.
  final String? description;

  /// Parameters for the tool search.
  final Map<String, dynamic>? parameters;

  /// Creates a [ToolSearchTool].
  const ToolSearchTool({this.execution, this.description, this.parameters});

  /// Creates a [ToolSearchTool] from JSON.
  factory ToolSearchTool.fromJson(Map<String, dynamic> json) {
    return ToolSearchTool(
      execution: json['execution'] != null
          ? ToolSearchExecutionType.fromJson(json['execution'] as String)
          : null,
      description: json['description'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tool_search',
    if (execution != null) 'execution': execution!.toJson(),
    if (description != null) 'description': description,
    if (parameters != null) 'parameters': parameters,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolSearchTool &&
          runtimeType == other.runtimeType &&
          execution == other.execution &&
          description == other.description &&
          mapsEqual(parameters, other.parameters);

  @override
  int get hashCode => Object.hash(execution, description, mapHash(parameters));

  @override
  String toString() =>
      'ToolSearchTool(execution: $execution, description: $description, parameters: $parameters)';
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

/// Programmatic tool calling tool, letting the model call tools from
/// generated code instead of one function call per turn.
@immutable
class ProgrammaticToolCallingTool extends ResponseTool {
  /// Creates a [ProgrammaticToolCallingTool].
  const ProgrammaticToolCallingTool();

  /// Creates a [ProgrammaticToolCallingTool] from JSON.
  factory ProgrammaticToolCallingTool.fromJson(Map<String, dynamic> json) {
    if ((json['type'] as String?) != 'programmatic_tool_calling') {
      throw const FormatException(
        'Invalid type for ProgrammaticToolCallingTool',
      );
    }
    return const ProgrammaticToolCallingTool();
  }

  @override
  Map<String, dynamic> toJson() => const {'type': 'programmatic_tool_calling'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProgrammaticToolCallingTool;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ProgrammaticToolCallingTool()';
}

/// A custom tool (type: 'custom').
///
/// Custom tools allow models to use provider-defined or operator-defined
/// tool capabilities. The [format] field is kept as a raw map for forward
/// compatibility as it accepts a discriminated union of format types.
@immutable
class CustomTool extends ResponseTool implements NamespaceAllowedTool {
  /// The fixed tool discriminator.
  String get type => 'custom';

  /// The tool name.
  final String name;

  /// Description of what the tool does.
  final String? description;

  /// Input format specification. Kept as [Map] for forward compatibility.
  final Map<String, dynamic>? format;

  /// Whether to defer loading this tool until needed.
  final bool? deferLoading;

  /// The tool invocation context(s) this tool may be called from.
  final List<CallableToolAllowedCaller>? allowedCallers;

  /// Whether the model may continue while this tool call is pending.
  ///
  /// The application executes the tool and returns its result. Omission leaves
  /// the server's behavior unchanged; an explicit false is preserved.
  final bool? async;

  /// Creates a [CustomTool].
  const CustomTool({
    required this.name,
    this.description,
    this.format,
    this.deferLoading,
    this.allowedCallers,
    this.async,
  });

  /// Creates a [CustomTool] from JSON.
  factory CustomTool.fromJson(Map<String, dynamic> json) {
    requireJsonType(json, 'custom', 'CustomTool');
    return CustomTool(
      name: requireJsonString(json['name'], 'CustomTool.name'),
      description: json['description'] as String?,
      format: json['format'] as Map<String, dynamic>?,
      deferLoading: json['defer_loading'] as bool?,
      allowedCallers: (json['allowed_callers'] as List?)
          ?.map((e) => CallableToolAllowedCaller.fromJson(e as String))
          .toList(),
      async: optionalJsonBool(json, 'async', 'CustomTool'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'custom',
    'name': name,
    if (description != null) 'description': description,
    if (format != null) 'format': format,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (allowedCallers != null)
      'allowed_callers': allowedCallers!.map((e) => e.toJson()).toList(),
    if (async != null) 'async': async,
  };

  /// Creates a copy; pass null to clear an optional setting.
  ///
  /// Format maps and caller lists retain their existing ownership semantics.
  CustomTool copyWith({
    String? name,
    Object? description = unsetCopyWithValue,
    Object? format = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? async = unsetCopyWithValue,
  }) => CustomTool(
    name: name ?? this.name,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    format: format == unsetCopyWithValue
        ? this.format
        : format as Map<String, dynamic>?,
    deferLoading: deferLoading == unsetCopyWithValue
        ? this.deferLoading
        : deferLoading as bool?,
    allowedCallers: allowedCallers == unsetCopyWithValue
        ? this.allowedCallers
        : allowedCallers as List<CallableToolAllowedCaller>?,
    async: async == unsetCopyWithValue ? this.async : async as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomTool &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          mapsDeepEqual(format, other.format) &&
          deferLoading == other.deferLoading &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          async == other.async;

  @override
  int get hashCode => Object.hash(
    name,
    description,
    mapDeepHashCode(format),
    deferLoading,
    listHash(allowedCallers),
    async,
  );

  @override
  String toString() =>
      'CustomTool(name: $name, '
      'description: ${description == null ? 'null' : '${description!.length} chars'}, '
      'format: ${format == null ? 'null' : '${format!.length} keys'}, '
      'deferLoading: $deferLoading, allowedCallers: $allowedCallers, '
      'async: $async)';
}

/// An unknown namespace tool for forward compatibility.
///
/// Returned by [NamespaceTool.fromJson] when an unrecognized tool type is
/// encountered inside a namespace. Preserves the raw JSON so the data can
/// be round-tripped without loss.
@immutable
class UnknownNamespaceTool implements NamespaceAllowedTool {
  /// The raw JSON data for this tool.
  final Map<String, dynamic> data;

  /// Creates an [UnknownNamespaceTool].
  const UnknownNamespaceTool(this.data);

  @override
  Map<String, dynamic> toJson() => data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownNamespaceTool &&
          runtimeType == other.runtimeType &&
          mapsEqual(data, other.data);

  @override
  int get hashCode => mapHash(data);

  @override
  String toString() => 'UnknownNamespaceTool(data: $data)';
}
