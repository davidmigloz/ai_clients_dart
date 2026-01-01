import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../metadata/cache_control.dart';

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
  factory BuiltInTool.bash({CacheControlEphemeral? cacheControl}) = BashTool;

  /// Creates a text editor tool (latest version).
  factory BuiltInTool.textEditor({
    CacheControlEphemeral? cacheControl,
    int? maxCharacters,
  }) = TextEditorTool;

  /// Creates a web search tool.
  factory BuiltInTool.webSearch({
    List<String>? allowedDomains,
    List<String>? blockedDomains,
    CacheControlEphemeral? cacheControl,
    int? maxUses,
    UserLocation? userLocation,
  }) = WebSearchTool;

  /// Creates a [BuiltInTool] from JSON.
  factory BuiltInTool.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'bash_20250124' => BashTool.fromJson(json),
      'text_editor_20250124' => TextEditorTool20250124.fromJson(json),
      'text_editor_20250429' => TextEditorTool20250429.fromJson(json),
      'text_editor_20250728' => TextEditorTool.fromJson(json),
      'web_search_20250305' => WebSearchTool.fromJson(json),
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
  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [BashTool].
  const BashTool({this.cacheControl});

  /// Creates a [BashTool] from JSON.
  factory BashTool.fromJson(Map<String, dynamic> json) {
    return BashTool(
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'bash_20250124',
    'name': 'bash',
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  BashTool copyWith({Object? cacheControl = unsetCopyWithValue}) {
    return BashTool(
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BashTool &&
          runtimeType == other.runtimeType &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => cacheControl.hashCode;

  @override
  String toString() => 'BashTool(cacheControl: $cacheControl)';
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
  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [TextEditorTool20250124].
  const TextEditorTool20250124({this.cacheControl});

  /// Creates a [TextEditorTool20250124] from JSON.
  factory TextEditorTool20250124.fromJson(Map<String, dynamic> json) {
    return TextEditorTool20250124(
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'text_editor_20250124',
    'name': 'str_replace_editor',
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  TextEditorTool20250124 copyWith({Object? cacheControl = unsetCopyWithValue}) {
    return TextEditorTool20250124(
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextEditorTool20250124 &&
          runtimeType == other.runtimeType &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => cacheControl.hashCode;

  @override
  String toString() => 'TextEditorTool20250124(cacheControl: $cacheControl)';
}

/// Text editor tool (version 2025-04-29).
@immutable
class TextEditorTool20250429 extends TextEditorToolBase {
  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [TextEditorTool20250429].
  const TextEditorTool20250429({this.cacheControl});

  /// Creates a [TextEditorTool20250429] from JSON.
  factory TextEditorTool20250429.fromJson(Map<String, dynamic> json) {
    return TextEditorTool20250429(
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'text_editor_20250429',
    'name': 'str_replace_based_edit_tool',
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  TextEditorTool20250429 copyWith({Object? cacheControl = unsetCopyWithValue}) {
    return TextEditorTool20250429(
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextEditorTool20250429 &&
          runtimeType == other.runtimeType &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => cacheControl.hashCode;

  @override
  String toString() => 'TextEditorTool20250429(cacheControl: $cacheControl)';
}

/// Text editor tool (version 2025-07-28, latest).
///
/// This is the latest version with additional max_characters option.
@immutable
class TextEditorTool extends TextEditorToolBase {
  /// Cache control for this tool definition.
  final CacheControlEphemeral? cacheControl;

  /// Maximum number of characters to display when viewing a file.
  ///
  /// If not specified, defaults to displaying the full file.
  final int? maxCharacters;

  /// Creates a [TextEditorTool].
  const TextEditorTool({this.cacheControl, this.maxCharacters});

  /// Creates a [TextEditorTool] from JSON.
  factory TextEditorTool.fromJson(Map<String, dynamic> json) {
    return TextEditorTool(
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
      maxCharacters: json['max_characters'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'text_editor_20250728',
    'name': 'str_replace_based_edit_tool',
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (maxCharacters != null) 'max_characters': maxCharacters,
  };

  /// Creates a copy with replaced values.
  TextEditorTool copyWith({
    Object? cacheControl = unsetCopyWithValue,
    Object? maxCharacters = unsetCopyWithValue,
  }) {
    return TextEditorTool(
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
      maxCharacters: maxCharacters == unsetCopyWithValue
          ? this.maxCharacters
          : maxCharacters as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextEditorTool &&
          runtimeType == other.runtimeType &&
          cacheControl == other.cacheControl &&
          maxCharacters == other.maxCharacters;

  @override
  int get hashCode => Object.hash(cacheControl, maxCharacters);

  @override
  String toString() =>
      'TextEditorTool(cacheControl: $cacheControl, maxCharacters: $maxCharacters)';
}

// ============================================================================
// Web Search Tool
// ============================================================================

/// Web search tool for searching the internet.
///
/// This tool allows Claude to search the web and return results.
@immutable
class WebSearchTool extends BuiltInTool {
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

  /// Creates a [WebSearchTool].
  const WebSearchTool({
    this.allowedDomains,
    this.blockedDomains,
    this.cacheControl,
    this.maxUses,
    this.userLocation,
  });

  /// Creates a [WebSearchTool] from JSON.
  factory WebSearchTool.fromJson(Map<String, dynamic> json) {
    return WebSearchTool(
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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'web_search_20250305',
    'name': 'web_search',
    if (allowedDomains != null) 'allowed_domains': allowedDomains,
    if (blockedDomains != null) 'blocked_domains': blockedDomains,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (maxUses != null) 'max_uses': maxUses,
    if (userLocation != null) 'user_location': userLocation!.toJson(),
  };

  /// Creates a copy with replaced values.
  WebSearchTool copyWith({
    Object? allowedDomains = unsetCopyWithValue,
    Object? blockedDomains = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
    Object? maxUses = unsetCopyWithValue,
    Object? userLocation = unsetCopyWithValue,
  }) {
    return WebSearchTool(
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchTool &&
          runtimeType == other.runtimeType &&
          _listsEqual(allowedDomains, other.allowedDomains) &&
          _listsEqual(blockedDomains, other.blockedDomains) &&
          cacheControl == other.cacheControl &&
          maxUses == other.maxUses &&
          userLocation == other.userLocation;

  @override
  int get hashCode => Object.hash(
    allowedDomains,
    blockedDomains,
    cacheControl,
    maxUses,
    userLocation,
  );

  @override
  String toString() =>
      'WebSearchTool(allowedDomains: $allowedDomains, blockedDomains: $blockedDomains, '
      'cacheControl: $cacheControl, maxUses: $maxUses, userLocation: $userLocation)';
}

bool _listsEqual<T>(List<T>? a, List<T>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
