import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../metadata/cache_control.dart';

// Include beta tools as part of this library to allow them to extend BuiltInTool
part '../beta/tools/advisor_tool.dart';
part '../beta/tools/computer_use_tool.dart';
part '../beta/tools/mcp_toolset.dart';

// ============================================================================
// User Location
// ============================================================================

/// User location for web search personalization.
@immutable
class UserLocation {
  /// The city of the user.
  final String? city;

  /// The two letter ISO country code of the user.
  final String? country;

  /// The region/state/province of the user.
  final String? region;

  /// The IANA timezone of the user.
  final String? timezone;

  /// Creates a [UserLocation].
  const UserLocation({this.city, this.country, this.region, this.timezone});

  /// Creates a [UserLocation] from JSON.
  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      city: json['city'] as String?,
      country: json['country'] as String?,
      region: json['region'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': 'approximate',
    if (city != null) 'city': city,
    if (country != null) 'country': country,
    if (region != null) 'region': region,
    if (timezone != null) 'timezone': timezone,
  };

  /// Creates a copy with replaced values.
  UserLocation copyWith({
    Object? city = unsetCopyWithValue,
    Object? country = unsetCopyWithValue,
    Object? region = unsetCopyWithValue,
    Object? timezone = unsetCopyWithValue,
  }) {
    return UserLocation(
      city: city == unsetCopyWithValue ? this.city : city as String?,
      country: country == unsetCopyWithValue
          ? this.country
          : country as String?,
      region: region == unsetCopyWithValue ? this.region : region as String?,
      timezone: timezone == unsetCopyWithValue
          ? this.timezone
          : timezone as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLocation &&
          runtimeType == other.runtimeType &&
          city == other.city &&
          country == other.country &&
          region == other.region &&
          timezone == other.timezone;

  @override
  int get hashCode => Object.hash(city, country, region, timezone);

  @override
  String toString() =>
      'UserLocation(city: $city, country: $country, region: $region, timezone: $timezone)';
}

// ============================================================================
// Built-in Tools
// ============================================================================

/// Base class for Anthropic built-in tools.
sealed class BuiltInTool {
  const BuiltInTool();

  /// Creates a bash tool.
  factory BuiltInTool.bash({
    CacheControlEphemeral? cacheControl,
    List<String>? allowedCallers,
    bool? deferLoading,
    bool? strict,
    List<Map<String, dynamic>>? inputExamples,
  }) = BashTool;

  /// Creates a text editor tool (latest version).
  factory BuiltInTool.textEditor({
    CacheControlEphemeral? cacheControl,
    int? maxCharacters,
    List<String>? allowedCallers,
    bool? deferLoading,
    bool? strict,
    List<Map<String, dynamic>>? inputExamples,
  }) = TextEditorTool;

  /// Creates a web search tool.
  factory BuiltInTool.webSearch({
    String? type,
    List<String>? allowedDomains,
    List<String>? blockedDomains,
    CacheControlEphemeral? cacheControl,
    int? maxUses,
    UserLocation? userLocation,
    List<String>? allowedCallers,
    bool? deferLoading,
    bool? strict,
  }) = WebSearchTool;

  /// Creates a web fetch tool.
  factory BuiltInTool.webFetch({
    String? type,
    List<String>? allowedDomains,
    List<String>? blockedDomains,
    CacheControlEphemeral? cacheControl,
    int? maxUses,
    int? maxContentTokens,
    RequestCitationsConfig? citations,
    List<String>? allowedCallers,
    bool? deferLoading,
    bool? strict,
    bool? useCache,
  }) = WebFetchTool;

  /// Creates a memory tool.
  factory BuiltInTool.memory({
    String? type,
    CacheControlEphemeral? cacheControl,
    List<String>? allowedCallers,
    bool? deferLoading,
    bool? strict,
    List<Map<String, dynamic>>? inputExamples,
  }) = MemoryTool;

  /// Creates the BM25 tool-search tool.
  factory BuiltInTool.toolSearchBm25({
    String? type,
    CacheControlEphemeral? cacheControl,
    List<String>? allowedCallers,
    bool? deferLoading,
    bool? strict,
  }) = ToolSearchToolBm25;

  /// Creates the regex tool-search tool.
  factory BuiltInTool.toolSearchRegex({
    String? type,
    CacheControlEphemeral? cacheControl,
    List<String>? allowedCallers,
    bool? deferLoading,
    bool? strict,
  }) = ToolSearchToolRegex;

  /// Creates a code execution tool.
  factory BuiltInTool.codeExecution({
    String? type,
    CacheControlEphemeral? cacheControl,
    List<String>? allowedCallers,
    bool? deferLoading,
    bool? strict,
  }) = CodeExecutionBuiltInTool;

  /// Creates a computer use tool (Beta).
  ///
  /// Allows Claude to interact with a computer display.
  factory BuiltInTool.computerUse({
    required int displayWidthPx,
    required int displayHeightPx,
    int? displayNumber,
    CacheControlEphemeral? cacheControl,
  }) = ComputerUseTool;

  /// Creates an advisor tool (Beta).
  ///
  /// Pairs an executor model with a stronger advisor model for
  /// mid-generation strategic guidance.
  factory BuiltInTool.advisor({
    required String model,
    int? maxUses,
    CacheControlEphemeral? caching,
    CacheControlEphemeral? cacheControl,
  }) = AdvisorTool;

  /// Creates an MCP toolset (Beta).
  ///
  /// Connects Claude to external tool servers via MCP.
  factory BuiltInTool.mcp({
    required McpServerUrlDefinition serverDefinition,
    String? authorizationToken,
    McpToolConfig? toolConfiguration,
    CacheControlEphemeral? cacheControl,
  }) = McpToolset;

  /// Creates a [BuiltInTool] from JSON.
  factory BuiltInTool.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'bash_20250124' => BashTool.fromJson(json),
      'text_editor_20250124' => TextEditorTool20250124.fromJson(json),
      'text_editor_20250429' => TextEditorTool20250429.fromJson(json),
      'text_editor_20250728' => TextEditorTool.fromJson(json),
      'web_search_20250305' => WebSearchTool.fromJson(json),
      'web_search_20260209' => WebSearchTool.fromJson(json),
      'web_fetch_20250910' => WebFetchTool.fromJson(json),
      'web_fetch_20260209' => WebFetchTool.fromJson(json),
      'web_fetch_20260309' => WebFetchTool.fromJson(json),
      'memory_20250818' => MemoryTool.fromJson(json),
      'tool_search_tool_bm25' => ToolSearchToolBm25.fromJson(json),
      'tool_search_tool_bm25_20251119' => ToolSearchToolBm25.fromJson(json),
      'tool_search_tool_regex' => ToolSearchToolRegex.fromJson(json),
      'tool_search_tool_regex_20251119' => ToolSearchToolRegex.fromJson(json),
      'code_execution_20250522' => CodeExecutionBuiltInTool.fromJson(json),
      'code_execution_20250825' => CodeExecutionBuiltInTool.fromJson(json),
      'code_execution_20260120' => CodeExecutionBuiltInTool.fromJson(json),
      // Beta tools
      final String t when t.startsWith('advisor_') => AdvisorTool.fromJson(
        json,
      ),
      final String t when t.startsWith('computer_') => ComputerUseTool.fromJson(
        json,
      ),
      final String t when t.startsWith('mcp_') => McpToolset.fromJson(json),
      _ => throw FormatException('Unknown BuiltInTool type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

// ============================================================================
// Bash Tool
// ============================================================================

/// Bash tool for executing shell commands.
///
/// This tool allows Claude to run bash commands in a sandboxed environment.
@immutable
class BashTool extends BuiltInTool {
  /// Tool type version.
  final String type;

  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Allowed caller types.
  final List<String>? allowedCallers;

  /// Whether to defer loading until tool reference is returned.
  final bool? deferLoading;

  /// Whether strict schema validation is enabled.
  final bool? strict;

  /// Optional input examples.
  final List<Map<String, dynamic>>? inputExamples;

  /// Creates a [BashTool].
  const BashTool({
    String? type,
    this.cacheControl,
    this.allowedCallers,
    this.deferLoading,
    this.strict,
    this.inputExamples,
  }) : type = type ?? 'bash_20250124';

  /// Creates a [BashTool] from JSON.
  factory BashTool.fromJson(Map<String, dynamic> json) {
    return BashTool(
      type: json['type'] as String? ?? 'bash_20250124',
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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'bash',
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (allowedCallers != null) 'allowed_callers': allowedCallers,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (strict != null) 'strict': strict,
    if (inputExamples != null) 'input_examples': inputExamples,
  };

  /// Creates a copy with replaced values.
  BashTool copyWith({
    String? type,
    Object? cacheControl = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
    Object? inputExamples = unsetCopyWithValue,
  }) {
    return BashTool(
      type: type ?? this.type,
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BashTool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          cacheControl == other.cacheControl &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          deferLoading == other.deferLoading &&
          strict == other.strict &&
          listOfMapsEqual(inputExamples, other.inputExamples);

  @override
  int get hashCode => Object.hash(
    type,
    cacheControl,
    listHash(allowedCallers),
    deferLoading,
    strict,
    listOfMapsHash(inputExamples),
  );

  @override
  String toString() =>
      'BashTool(type: $type, cacheControl: $cacheControl, '
      'allowedCallers: $allowedCallers, deferLoading: $deferLoading, '
      'strict: $strict, inputExamples: $inputExamples)';
}

// ============================================================================
// Text Editor Tools
// ============================================================================

/// Base class for text editor tool versions.
sealed class TextEditorToolBase extends BuiltInTool {
  const TextEditorToolBase();
}

/// Text editor tool (version 2025-01-24).
///
/// This is an older version with name "str_replace_editor".
@immutable
class TextEditorTool20250124 extends TextEditorToolBase {
  /// Tool type version.
  final String type;

  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Allowed caller types.
  final List<String>? allowedCallers;

  /// Whether to defer loading until requested via tool reference.
  final bool? deferLoading;

  /// Whether strict schema validation is enabled.
  final bool? strict;

  /// Optional input examples.
  final List<Map<String, dynamic>>? inputExamples;

  /// Creates a [TextEditorTool20250124].
  const TextEditorTool20250124({
    String? type,
    this.cacheControl,
    this.allowedCallers,
    this.deferLoading,
    this.strict,
    this.inputExamples,
  }) : type = type ?? 'text_editor_20250124';

  /// Creates a [TextEditorTool20250124] from JSON.
  factory TextEditorTool20250124.fromJson(Map<String, dynamic> json) {
    return TextEditorTool20250124(
      type: json['type'] as String? ?? 'text_editor_20250124',
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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'str_replace_editor',
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (allowedCallers != null) 'allowed_callers': allowedCallers,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (strict != null) 'strict': strict,
    if (inputExamples != null) 'input_examples': inputExamples,
  };

  /// Creates a copy with replaced values.
  TextEditorTool20250124 copyWith({
    String? type,
    Object? cacheControl = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
    Object? inputExamples = unsetCopyWithValue,
  }) {
    return TextEditorTool20250124(
      type: type ?? this.type,
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextEditorTool20250124 &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          cacheControl == other.cacheControl &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          deferLoading == other.deferLoading &&
          strict == other.strict &&
          listOfMapsEqual(inputExamples, other.inputExamples);

  @override
  int get hashCode => Object.hash(
    type,
    cacheControl,
    listHash(allowedCallers),
    deferLoading,
    strict,
    listOfMapsHash(inputExamples),
  );

  @override
  String toString() =>
      'TextEditorTool20250124(type: $type, cacheControl: $cacheControl, '
      'allowedCallers: $allowedCallers, deferLoading: $deferLoading, '
      'strict: $strict, inputExamples: $inputExamples)';
}

/// Text editor tool (version 2025-04-29).
@immutable
class TextEditorTool20250429 extends TextEditorToolBase {
  /// Tool type version.
  final String type;

  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Allowed caller types.
  final List<String>? allowedCallers;

  /// Whether to defer loading until requested via tool reference.
  final bool? deferLoading;

  /// Whether strict schema validation is enabled.
  final bool? strict;

  /// Optional input examples.
  final List<Map<String, dynamic>>? inputExamples;

  /// Creates a [TextEditorTool20250429].
  const TextEditorTool20250429({
    String? type,
    this.cacheControl,
    this.allowedCallers,
    this.deferLoading,
    this.strict,
    this.inputExamples,
  }) : type = type ?? 'text_editor_20250429';

  /// Creates a [TextEditorTool20250429] from JSON.
  factory TextEditorTool20250429.fromJson(Map<String, dynamic> json) {
    return TextEditorTool20250429(
      type: json['type'] as String? ?? 'text_editor_20250429',
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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'str_replace_based_edit_tool',
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (allowedCallers != null) 'allowed_callers': allowedCallers,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (strict != null) 'strict': strict,
    if (inputExamples != null) 'input_examples': inputExamples,
  };

  /// Creates a copy with replaced values.
  TextEditorTool20250429 copyWith({
    String? type,
    Object? cacheControl = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
    Object? inputExamples = unsetCopyWithValue,
  }) {
    return TextEditorTool20250429(
      type: type ?? this.type,
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextEditorTool20250429 &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          cacheControl == other.cacheControl &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          deferLoading == other.deferLoading &&
          strict == other.strict &&
          listOfMapsEqual(inputExamples, other.inputExamples);

  @override
  int get hashCode => Object.hash(
    type,
    cacheControl,
    listHash(allowedCallers),
    deferLoading,
    strict,
    listOfMapsHash(inputExamples),
  );

  @override
  String toString() =>
      'TextEditorTool20250429(type: $type, cacheControl: $cacheControl, '
      'allowedCallers: $allowedCallers, deferLoading: $deferLoading, '
      'strict: $strict, inputExamples: $inputExamples)';
}

/// Text editor tool (version 2025-07-28, latest).
///
/// This is the latest version with additional max_characters option.
@immutable
class TextEditorTool extends TextEditorToolBase {
  /// Tool type version.
  final String type;

  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Maximum number of characters to display when viewing a file.
  ///
  /// If not specified, defaults to displaying the full file.
  final int? maxCharacters;

  /// Allowed caller types.
  final List<String>? allowedCallers;

  /// Whether to defer loading until requested via tool reference.
  final bool? deferLoading;

  /// Whether strict schema validation is enabled.
  final bool? strict;

  /// Optional input examples.
  final List<Map<String, dynamic>>? inputExamples;

  /// Creates a [TextEditorTool].
  const TextEditorTool({
    String? type,
    this.cacheControl,
    this.maxCharacters,
    this.allowedCallers,
    this.deferLoading,
    this.strict,
    this.inputExamples,
  }) : type = type ?? 'text_editor_20250728';

  /// Creates a [TextEditorTool] from JSON.
  factory TextEditorTool.fromJson(Map<String, dynamic> json) {
    return TextEditorTool(
      type: json['type'] as String? ?? 'text_editor_20250728',
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
      maxCharacters: json['max_characters'] as int?,
      allowedCallers: (json['allowed_callers'] as List?)?.cast<String>(),
      deferLoading: json['defer_loading'] as bool?,
      strict: json['strict'] as bool?,
      inputExamples: (json['input_examples'] as List?)
          ?.map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'str_replace_based_edit_tool',
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (maxCharacters != null) 'max_characters': maxCharacters,
    if (allowedCallers != null) 'allowed_callers': allowedCallers,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (strict != null) 'strict': strict,
    if (inputExamples != null) 'input_examples': inputExamples,
  };

  /// Creates a copy with replaced values.
  TextEditorTool copyWith({
    String? type,
    Object? cacheControl = unsetCopyWithValue,
    Object? maxCharacters = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
    Object? inputExamples = unsetCopyWithValue,
  }) {
    return TextEditorTool(
      type: type ?? this.type,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
      maxCharacters: maxCharacters == unsetCopyWithValue
          ? this.maxCharacters
          : maxCharacters as int?,
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextEditorTool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          cacheControl == other.cacheControl &&
          maxCharacters == other.maxCharacters &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          deferLoading == other.deferLoading &&
          strict == other.strict &&
          listOfMapsEqual(inputExamples, other.inputExamples);

  @override
  int get hashCode => Object.hash(
    type,
    cacheControl,
    maxCharacters,
    listHash(allowedCallers),
    deferLoading,
    strict,
    listOfMapsHash(inputExamples),
  );

  @override
  String toString() =>
      'TextEditorTool(type: $type, cacheControl: $cacheControl, '
      'maxCharacters: $maxCharacters, allowedCallers: $allowedCallers, '
      'deferLoading: $deferLoading, strict: $strict, '
      'inputExamples: $inputExamples)';
}

// ============================================================================
// Web Search Tool
// ============================================================================

/// Web search tool for searching the internet.
///
/// This tool allows Claude to search the web and return results.
@immutable
class WebSearchTool extends BuiltInTool {
  /// Tool type version.
  final String type;

  /// If provided, only these domains will be included in results.
  ///
  /// Cannot be used alongside [blockedDomains].
  final List<String>? allowedDomains;

  /// If provided, these domains will never appear in results.
  ///
  /// Cannot be used alongside [allowedDomains].
  final List<String>? blockedDomains;

  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Maximum number of times the tool can be used in the API request.
  final int? maxUses;

  /// User location for search personalization.
  final UserLocation? userLocation;

  /// Allowed caller types.
  final List<String>? allowedCallers;

  /// Whether to defer loading until requested via tool reference.
  final bool? deferLoading;

  /// Whether strict schema validation is enabled.
  final bool? strict;

  /// Creates a [WebSearchTool].
  const WebSearchTool({
    String? type,
    this.allowedDomains,
    this.blockedDomains,
    this.cacheControl,
    this.maxUses,
    this.userLocation,
    this.allowedCallers,
    this.deferLoading,
    this.strict,
  }) : type = type ?? 'web_search_20250305';

  /// Creates a [WebSearchTool] from JSON.
  factory WebSearchTool.fromJson(Map<String, dynamic> json) {
    return WebSearchTool(
      type: json['type'] as String? ?? 'web_search_20250305',
      allowedDomains: (json['allowed_domains'] as List?)?.cast<String>(),
      blockedDomains: (json['blocked_domains'] as List?)?.cast<String>(),
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
      maxUses: json['max_uses'] as int?,
      userLocation: json['user_location'] != null
          ? UserLocation.fromJson(json['user_location'] as Map<String, dynamic>)
          : null,
      allowedCallers: (json['allowed_callers'] as List?)?.cast<String>(),
      deferLoading: json['defer_loading'] as bool?,
      strict: json['strict'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'web_search',
    if (allowedDomains != null) 'allowed_domains': allowedDomains,
    if (blockedDomains != null) 'blocked_domains': blockedDomains,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (maxUses != null) 'max_uses': maxUses,
    if (userLocation != null) 'user_location': userLocation!.toJson(),
    if (allowedCallers != null) 'allowed_callers': allowedCallers,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (strict != null) 'strict': strict,
  };

  /// Creates a copy with replaced values.
  WebSearchTool copyWith({
    String? type,
    Object? allowedDomains = unsetCopyWithValue,
    Object? blockedDomains = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
    Object? maxUses = unsetCopyWithValue,
    Object? userLocation = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
  }) {
    return WebSearchTool(
      type: type ?? this.type,
      allowedDomains: allowedDomains == unsetCopyWithValue
          ? this.allowedDomains
          : allowedDomains as List<String>?,
      blockedDomains: blockedDomains == unsetCopyWithValue
          ? this.blockedDomains
          : blockedDomains as List<String>?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
      maxUses: maxUses == unsetCopyWithValue ? this.maxUses : maxUses as int?,
      userLocation: userLocation == unsetCopyWithValue
          ? this.userLocation
          : userLocation as UserLocation?,
      allowedCallers: allowedCallers == unsetCopyWithValue
          ? this.allowedCallers
          : allowedCallers as List<String>?,
      deferLoading: deferLoading == unsetCopyWithValue
          ? this.deferLoading
          : deferLoading as bool?,
      strict: strict == unsetCopyWithValue ? this.strict : strict as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchTool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          listsEqual(allowedDomains, other.allowedDomains) &&
          listsEqual(blockedDomains, other.blockedDomains) &&
          cacheControl == other.cacheControl &&
          maxUses == other.maxUses &&
          userLocation == other.userLocation &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          deferLoading == other.deferLoading &&
          strict == other.strict;

  @override
  int get hashCode => Object.hash(
    type,
    listHash(allowedDomains),
    listHash(blockedDomains),
    cacheControl,
    maxUses,
    userLocation,
    listHash(allowedCallers),
    deferLoading,
    strict,
  );

  @override
  String toString() =>
      'WebSearchTool(type: $type, allowedDomains: $allowedDomains, '
      'blockedDomains: $blockedDomains, cacheControl: $cacheControl, '
      'maxUses: $maxUses, userLocation: $userLocation, '
      'allowedCallers: $allowedCallers, deferLoading: $deferLoading, '
      'strict: $strict)';
}

/// Citations configuration for web fetch tool output.
@immutable
class RequestCitationsConfig {
  /// Whether citations are enabled for fetched documents.
  final bool enabled;

  /// Creates a [RequestCitationsConfig].
  const RequestCitationsConfig({this.enabled = true});

  /// Creates a [RequestCitationsConfig] from JSON.
  factory RequestCitationsConfig.fromJson(Map<String, dynamic> json) {
    return RequestCitationsConfig(enabled: json['enabled'] as bool? ?? true);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'enabled': enabled};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestCitationsConfig &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled;

  @override
  int get hashCode => enabled.hashCode;

  @override
  String toString() => 'RequestCitationsConfig(enabled: $enabled)';
}

/// Web fetch built-in tool.
@immutable
class WebFetchTool extends BuiltInTool {
  /// Tool type version.
  final String type;

  /// Allowed domains for fetch requests.
  final List<String>? allowedDomains;

  /// Blocked domains for fetch requests.
  final List<String>? blockedDomains;

  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Maximum number of tool invocations.
  final int? maxUses;

  /// Maximum number of content tokens to include from fetched page.
  final int? maxContentTokens;

  /// Citations configuration.
  final RequestCitationsConfig? citations;

  /// Allowed caller types.
  final List<String>? allowedCallers;

  /// Whether to defer loading until requested via tool reference.
  final bool? deferLoading;

  /// Whether strict schema validation is enabled.
  final bool? strict;

  /// Whether to use cached content.
  ///
  /// Set to false to bypass the cache and fetch fresh content. Only set to
  /// false when the user explicitly requests fresh content or when fetching
  /// rapidly-changing sources.
  final bool? useCache;

  /// Creates a [WebFetchTool].
  ///
  /// [useCache] is only supported for `web_fetch_20260309` and is normalized
  /// to `null` for other versions.
  const WebFetchTool({
    String? type,
    this.allowedDomains,
    this.blockedDomains,
    this.cacheControl,
    this.maxUses,
    this.maxContentTokens,
    this.citations,
    this.allowedCallers,
    this.deferLoading,
    this.strict,
    bool? useCache,
  }) : type = type ?? 'web_fetch_20260309',
       useCache = (type == null || type == 'web_fetch_20260309')
           ? useCache
           : null;

  /// Creates a [WebFetchTool] from JSON.
  factory WebFetchTool.fromJson(Map<String, dynamic> json) {
    return WebFetchTool(
      type: json['type'] as String? ?? 'web_fetch_20260309',
      allowedDomains: (json['allowed_domains'] as List?)?.cast<String>(),
      blockedDomains: (json['blocked_domains'] as List?)?.cast<String>(),
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
      maxUses: json['max_uses'] as int?,
      maxContentTokens: json['max_content_tokens'] as int?,
      citations: json['citations'] != null
          ? RequestCitationsConfig.fromJson(
              json['citations'] as Map<String, dynamic>,
            )
          : null,
      allowedCallers: (json['allowed_callers'] as List?)?.cast<String>(),
      deferLoading: json['defer_loading'] as bool?,
      strict: json['strict'] as bool?,
      useCache: json['use_cache'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'web_fetch',
    if (allowedDomains != null) 'allowed_domains': allowedDomains,
    if (blockedDomains != null) 'blocked_domains': blockedDomains,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (maxUses != null) 'max_uses': maxUses,
    if (maxContentTokens != null) 'max_content_tokens': maxContentTokens,
    if (citations != null) 'citations': citations!.toJson(),
    if (allowedCallers != null) 'allowed_callers': allowedCallers,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (strict != null) 'strict': strict,
    if (useCache != null && type == 'web_fetch_20260309') 'use_cache': useCache,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebFetchTool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          listsEqual(allowedDomains, other.allowedDomains) &&
          listsEqual(blockedDomains, other.blockedDomains) &&
          cacheControl == other.cacheControl &&
          maxUses == other.maxUses &&
          maxContentTokens == other.maxContentTokens &&
          citations == other.citations &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          deferLoading == other.deferLoading &&
          strict == other.strict &&
          useCache == other.useCache;

  /// Creates a copy with replaced values.
  WebFetchTool copyWith({
    String? type,
    Object? allowedDomains = unsetCopyWithValue,
    Object? blockedDomains = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
    Object? maxUses = unsetCopyWithValue,
    Object? maxContentTokens = unsetCopyWithValue,
    Object? citations = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
    Object? useCache = unsetCopyWithValue,
  }) {
    return WebFetchTool(
      type: type ?? this.type,
      allowedDomains: allowedDomains == unsetCopyWithValue
          ? this.allowedDomains
          : allowedDomains as List<String>?,
      blockedDomains: blockedDomains == unsetCopyWithValue
          ? this.blockedDomains
          : blockedDomains as List<String>?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
      maxUses: maxUses == unsetCopyWithValue ? this.maxUses : maxUses as int?,
      maxContentTokens: maxContentTokens == unsetCopyWithValue
          ? this.maxContentTokens
          : maxContentTokens as int?,
      citations: citations == unsetCopyWithValue
          ? this.citations
          : citations as RequestCitationsConfig?,
      allowedCallers: allowedCallers == unsetCopyWithValue
          ? this.allowedCallers
          : allowedCallers as List<String>?,
      deferLoading: deferLoading == unsetCopyWithValue
          ? this.deferLoading
          : deferLoading as bool?,
      strict: strict == unsetCopyWithValue ? this.strict : strict as bool?,
      useCache: useCache == unsetCopyWithValue
          ? this.useCache
          : useCache as bool?,
    );
  }

  @override
  int get hashCode => Object.hash(
    type,
    listHash(allowedDomains),
    listHash(blockedDomains),
    cacheControl,
    maxUses,
    maxContentTokens,
    citations,
    listHash(allowedCallers),
    deferLoading,
    strict,
    useCache,
  );

  @override
  String toString() =>
      'WebFetchTool(type: $type, allowedDomains: $allowedDomains, '
      'blockedDomains: $blockedDomains, cacheControl: $cacheControl, '
      'maxUses: $maxUses, maxContentTokens: $maxContentTokens, '
      'citations: $citations, allowedCallers: $allowedCallers, '
      'deferLoading: $deferLoading, strict: $strict, useCache: $useCache)';
}

/// Memory built-in tool.
@immutable
class MemoryTool extends BuiltInTool {
  /// Tool type version.
  final String type;

  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Allowed caller types.
  final List<String>? allowedCallers;

  /// Whether to defer loading until requested via tool reference.
  final bool? deferLoading;

  /// Whether strict schema validation is enabled.
  final bool? strict;

  /// Optional input examples.
  final List<Map<String, dynamic>>? inputExamples;

  /// Creates a [MemoryTool].
  const MemoryTool({
    String? type,
    this.cacheControl,
    this.allowedCallers,
    this.deferLoading,
    this.strict,
    this.inputExamples,
  }) : type = type ?? 'memory_20250818';

  /// Creates a [MemoryTool] from JSON.
  factory MemoryTool.fromJson(Map<String, dynamic> json) {
    return MemoryTool(
      type: json['type'] as String? ?? 'memory_20250818',
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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'memory',
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (allowedCallers != null) 'allowed_callers': allowedCallers,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (strict != null) 'strict': strict,
    if (inputExamples != null) 'input_examples': inputExamples,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryTool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          cacheControl == other.cacheControl &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          deferLoading == other.deferLoading &&
          strict == other.strict &&
          listOfMapsEqual(inputExamples, other.inputExamples);

  /// Creates a copy with replaced values.
  MemoryTool copyWith({
    String? type,
    Object? cacheControl = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
    Object? inputExamples = unsetCopyWithValue,
  }) {
    return MemoryTool(
      type: type ?? this.type,
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
    );
  }

  @override
  int get hashCode => Object.hash(
    type,
    cacheControl,
    listHash(allowedCallers),
    deferLoading,
    strict,
    listOfMapsHash(inputExamples),
  );

  @override
  String toString() =>
      'MemoryTool(type: $type, cacheControl: $cacheControl, '
      'allowedCallers: $allowedCallers, deferLoading: $deferLoading, '
      'strict: $strict, inputExamples: $inputExamples)';
}

/// Base class for tool search built-ins.
sealed class ToolSearchTool extends BuiltInTool {
  const ToolSearchTool();
}

/// BM25 tool search built-in.
@immutable
class ToolSearchToolBm25 extends ToolSearchTool {
  /// Tool type version.
  final String type;

  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Allowed caller types.
  final List<String>? allowedCallers;

  /// Whether to defer loading until requested via tool reference.
  final bool? deferLoading;

  /// Whether strict schema validation is enabled.
  final bool? strict;

  /// Creates a [ToolSearchToolBm25].
  const ToolSearchToolBm25({
    String? type,
    this.cacheControl,
    this.allowedCallers,
    this.deferLoading,
    this.strict,
  }) : type = type ?? 'tool_search_tool_bm25_20251119';

  /// Creates a [ToolSearchToolBm25] from JSON.
  factory ToolSearchToolBm25.fromJson(Map<String, dynamic> json) {
    return ToolSearchToolBm25(
      type: json['type'] as String? ?? 'tool_search_tool_bm25_20251119',
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
      allowedCallers: (json['allowed_callers'] as List?)?.cast<String>(),
      deferLoading: json['defer_loading'] as bool?,
      strict: json['strict'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'tool_search_tool_bm25',
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (allowedCallers != null) 'allowed_callers': allowedCallers,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (strict != null) 'strict': strict,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolSearchToolBm25 &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          cacheControl == other.cacheControl &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          deferLoading == other.deferLoading &&
          strict == other.strict;

  /// Creates a copy with replaced values.
  ToolSearchToolBm25 copyWith({
    String? type,
    Object? cacheControl = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
  }) {
    return ToolSearchToolBm25(
      type: type ?? this.type,
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
    );
  }

  @override
  int get hashCode => Object.hash(
    type,
    cacheControl,
    listHash(allowedCallers),
    deferLoading,
    strict,
  );

  @override
  String toString() =>
      'ToolSearchToolBm25(type: $type, cacheControl: $cacheControl, '
      'allowedCallers: $allowedCallers, deferLoading: $deferLoading, '
      'strict: $strict)';
}

/// Regex tool search built-in.
@immutable
class ToolSearchToolRegex extends ToolSearchTool {
  /// Tool type version.
  final String type;

  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Allowed caller types.
  final List<String>? allowedCallers;

  /// Whether to defer loading until requested via tool reference.
  final bool? deferLoading;

  /// Whether strict schema validation is enabled.
  final bool? strict;

  /// Creates a [ToolSearchToolRegex].
  const ToolSearchToolRegex({
    String? type,
    this.cacheControl,
    this.allowedCallers,
    this.deferLoading,
    this.strict,
  }) : type = type ?? 'tool_search_tool_regex_20251119';

  /// Creates a [ToolSearchToolRegex] from JSON.
  factory ToolSearchToolRegex.fromJson(Map<String, dynamic> json) {
    return ToolSearchToolRegex(
      type: json['type'] as String? ?? 'tool_search_tool_regex_20251119',
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
      allowedCallers: (json['allowed_callers'] as List?)?.cast<String>(),
      deferLoading: json['defer_loading'] as bool?,
      strict: json['strict'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'tool_search_tool_regex',
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (allowedCallers != null) 'allowed_callers': allowedCallers,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (strict != null) 'strict': strict,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolSearchToolRegex &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          cacheControl == other.cacheControl &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          deferLoading == other.deferLoading &&
          strict == other.strict;

  /// Creates a copy with replaced values.
  ToolSearchToolRegex copyWith({
    String? type,
    Object? cacheControl = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
  }) {
    return ToolSearchToolRegex(
      type: type ?? this.type,
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
    );
  }

  @override
  int get hashCode => Object.hash(
    type,
    cacheControl,
    listHash(allowedCallers),
    deferLoading,
    strict,
  );

  @override
  String toString() =>
      'ToolSearchToolRegex(type: $type, cacheControl: $cacheControl, '
      'allowedCallers: $allowedCallers, deferLoading: $deferLoading, '
      'strict: $strict)';
}

/// Code execution built-in tool.
@immutable
class CodeExecutionBuiltInTool extends BuiltInTool {
  /// Tool type version.
  final String type;

  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Allowed caller types.
  final List<String>? allowedCallers;

  /// Whether to defer loading until requested via tool reference.
  final bool? deferLoading;

  /// Whether strict schema validation is enabled.
  final bool? strict;

  /// Creates a [CodeExecutionBuiltInTool].
  const CodeExecutionBuiltInTool({
    String? type,
    this.cacheControl,
    this.allowedCallers,
    this.deferLoading,
    this.strict,
  }) : type = type ?? 'code_execution_20260120';

  /// Creates a [CodeExecutionBuiltInTool] from JSON.
  factory CodeExecutionBuiltInTool.fromJson(Map<String, dynamic> json) {
    return CodeExecutionBuiltInTool(
      type: json['type'] as String? ?? 'code_execution_20260120',
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
      allowedCallers: (json['allowed_callers'] as List?)?.cast<String>(),
      deferLoading: json['defer_loading'] as bool?,
      strict: json['strict'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'code_execution',
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (allowedCallers != null) 'allowed_callers': allowedCallers,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (strict != null) 'strict': strict,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeExecutionBuiltInTool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          cacheControl == other.cacheControl &&
          listsEqual(allowedCallers, other.allowedCallers) &&
          deferLoading == other.deferLoading &&
          strict == other.strict;

  /// Creates a copy with replaced values.
  CodeExecutionBuiltInTool copyWith({
    String? type,
    Object? cacheControl = unsetCopyWithValue,
    Object? allowedCallers = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? strict = unsetCopyWithValue,
  }) {
    return CodeExecutionBuiltInTool(
      type: type ?? this.type,
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
    );
  }

  @override
  int get hashCode => Object.hash(
    type,
    cacheControl,
    listHash(allowedCallers),
    deferLoading,
    strict,
  );

  @override
  String toString() =>
      'CodeExecutionBuiltInTool(type: $type, cacheControl: $cacheControl, '
      'allowedCallers: $allowedCallers, deferLoading: $deferLoading, '
      'strict: $strict)';
}
