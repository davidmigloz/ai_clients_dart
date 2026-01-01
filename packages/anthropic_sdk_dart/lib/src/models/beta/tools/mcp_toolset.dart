import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../metadata/cache_control.dart';

/// MCP (Model Context Protocol) toolset configuration.
@immutable
class McpToolset {
  /// The tool type. Always "mcp_20250819".
  final String type;

  /// Authorization token for the MCP server.
  final String? authorizationToken;

  /// MCP server definition.
  final McpServerUrlDefinition serverDefinition;

  /// Tool configuration.
  final McpToolConfig? toolConfiguration;

  /// Cache control for this toolset.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [McpToolset].
  const McpToolset({
    this.type = 'mcp_20250819',
    this.authorizationToken,
    required this.serverDefinition,
    this.toolConfiguration,
    this.cacheControl,
  });

  /// Creates a [McpToolset] from JSON.
  factory McpToolset.fromJson(Map<String, dynamic> json) {
    return McpToolset(
      type: json['type'] as String? ?? 'mcp_20250819',
      authorizationToken: json['authorization_token'] as String?,
      serverDefinition: McpServerUrlDefinition.fromJson(
        json['server_definition'] as Map<String, dynamic>,
      ),
      toolConfiguration: json['tool_configuration'] != null
          ? McpToolConfig.fromJson(
              json['tool_configuration'] as Map<String, dynamic>,
            )
          : null,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': 'mcp',
    if (authorizationToken != null) 'authorization_token': authorizationToken,
    'server_definition': serverDefinition.toJson(),
    if (toolConfiguration != null)
      'tool_configuration': toolConfiguration!.toJson(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  McpToolset copyWith({
    String? type,
    Object? authorizationToken = unsetCopyWithValue,
    McpServerUrlDefinition? serverDefinition,
    Object? toolConfiguration = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return McpToolset(
      type: type ?? this.type,
      authorizationToken: authorizationToken == unsetCopyWithValue
          ? this.authorizationToken
          : authorizationToken as String?,
      serverDefinition: serverDefinition ?? this.serverDefinition,
      toolConfiguration: toolConfiguration == unsetCopyWithValue
          ? this.toolConfiguration
          : toolConfiguration as McpToolConfig?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpToolset &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          authorizationToken == other.authorizationToken &&
          serverDefinition == other.serverDefinition &&
          toolConfiguration == other.toolConfiguration &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(
    type,
    authorizationToken,
    serverDefinition,
    toolConfiguration,
    cacheControl,
  );

  @override
  String toString() =>
      'McpToolset(type: $type, serverDefinition: $serverDefinition, '
      'toolConfiguration: $toolConfiguration)';
}

/// MCP server URL definition.
@immutable
class McpServerUrlDefinition {
  /// The server URL.
  final String url;

  /// Creates a [McpServerUrlDefinition].
  const McpServerUrlDefinition({required this.url});

  /// Creates a [McpServerUrlDefinition] from JSON.
  factory McpServerUrlDefinition.fromJson(Map<String, dynamic> json) {
    return McpServerUrlDefinition(url: json['url'] as String);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': 'url', 'url': url};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpServerUrlDefinition &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'McpServerUrlDefinition(url: $url)';
}

/// MCP tool configuration.
@immutable
class McpToolConfig {
  /// Allowed tools (empty means all allowed).
  final List<String>? allowedTools;

  /// Whether the tool is enabled.
  final bool? enabled;

  /// Creates a [McpToolConfig].
  const McpToolConfig({this.allowedTools, this.enabled});

  /// Creates a [McpToolConfig] from JSON.
  factory McpToolConfig.fromJson(Map<String, dynamic> json) {
    return McpToolConfig(
      allowedTools: (json['allowed_tools'] as List?)?.cast<String>(),
      enabled: json['enabled'] as bool?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (allowedTools != null) 'allowed_tools': allowedTools,
    if (enabled != null) 'enabled': enabled,
  };

  /// Creates a copy with replaced values.
  McpToolConfig copyWith({
    Object? allowedTools = unsetCopyWithValue,
    Object? enabled = unsetCopyWithValue,
  }) {
    return McpToolConfig(
      allowedTools: allowedTools == unsetCopyWithValue
          ? this.allowedTools
          : allowedTools as List<String>?,
      enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpToolConfig &&
          runtimeType == other.runtimeType &&
          _listsEqual(allowedTools, other.allowedTools) &&
          enabled == other.enabled;

  @override
  int get hashCode => Object.hash(allowedTools, enabled);

  @override
  String toString() =>
      'McpToolConfig(allowedTools: $allowedTools, enabled: $enabled)';
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
