part of '../../tools/built_in_tools.dart';

/// An MCP URL server declared in `mcp_servers` on a Messages request.
@immutable
final class McpConnectorServer {
  /// Creates an MCP server definition.
  const McpConnectorServer({
    required this.name,
    required this.url,
    this.authorizationToken,
    this.toolConfiguration,
  });

  /// Parses a URL server definition.
  factory McpConnectorServer.fromJson(Map<String, dynamic> json) {
    if (json case {
      'type': 'url',
      'name': final String name,
      'url': final String url,
    }) {
      final config = json['tool_configuration'] as Map<String, dynamic>?;
      return McpConnectorServer(
        name: name,
        url: url,
        authorizationToken: json['authorization_token'] as String?,
        toolConfiguration: config == null
            ? null
            : McpToolConfig.fromJson(config),
      );
    }
    throw const FormatException('Invalid MCP URL server definition');
  }

  /// Name used by tools and listing blocks to reference this server.
  final String name;

  /// Remote MCP endpoint URL.
  final String url;

  /// Optional credential that Claude supplies to the MCP server.
  final String? authorizationToken;

  /// Tool configuration for the legacy connector beta.
  ///
  /// For current requests use [McpConnectorToolset.defaultConfig] and
  /// [McpConnectorToolset.configs].
  final McpToolConfig? toolConfiguration;

  /// Serializes this definition for the Messages API.
  Map<String, dynamic> toJson() => {
    'type': 'url',
    'name': name,
    'url': url,
    'authorization_token': ?authorizationToken,
    'tool_configuration': ?toolConfiguration?.toJson(),
  };

  /// Copies the server, with null clearing an optional setting.
  McpConnectorServer copyWith({
    String? name,
    String? url,
    Object? authorizationToken = unsetCopyWithValue,
    Object? toolConfiguration = unsetCopyWithValue,
  }) => McpConnectorServer(
    name: name ?? this.name,
    url: url ?? this.url,
    authorizationToken: authorizationToken == unsetCopyWithValue
        ? this.authorizationToken
        : authorizationToken as String?,
    toolConfiguration: toolConfiguration == unsetCopyWithValue
        ? this.toolConfiguration
        : toolConfiguration as McpToolConfig?,
  );

  @override
  bool operator ==(Object other) =>
      other is McpConnectorServer &&
      name == other.name &&
      url == other.url &&
      authorizationToken == other.authorizationToken &&
      toolConfiguration == other.toolConfiguration;

  @override
  int get hashCode =>
      Object.hash(name, url, authorizationToken, toolConfiguration);

  @override
  String toString() => 'McpConnectorServer(name: $name)';
}

/// Settings for the tools exposed by an MCP server.
@immutable
final class McpConnectorToolSettings {
  /// Creates defaults or overrides for MCP tools.
  const McpConnectorToolSettings({this.enabled, this.deferLoading});

  /// Parses tool settings.
  factory McpConnectorToolSettings.fromJson(Map<String, dynamic> json) =>
      McpConnectorToolSettings(
        enabled: json['enabled'] as bool?,
        deferLoading: json['defer_loading'] as bool?,
      );

  /// Whether the tool is exposed to Claude.
  final bool? enabled;

  /// Whether tool search must discover the tool before using it.
  final bool? deferLoading;

  /// Serializes the settings for a toolset request.
  Map<String, dynamic> toJson() => {
    'enabled': ?enabled,
    'defer_loading': ?deferLoading,
  };

  /// Copies these settings, with null clearing an override.
  McpConnectorToolSettings copyWith({
    Object? enabled = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
  }) => McpConnectorToolSettings(
    enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
    deferLoading: deferLoading == unsetCopyWithValue
        ? this.deferLoading
        : deferLoading as bool?,
  );

  @override
  bool operator ==(Object other) =>
      other is McpConnectorToolSettings &&
      enabled == other.enabled &&
      deferLoading == other.deferLoading;

  @override
  int get hashCode => Object.hash(enabled, deferLoading);

  @override
  String toString() =>
      'McpConnectorToolSettings(enabled: $enabled, deferLoading: $deferLoading)';
}

/// A tool schema returned in an MCP server's tool listing.
@immutable
final class McpListedTool {
  /// Creates a tool listing entry with an immutable input schema.
  McpListedTool({
    required this.name,
    required Map<String, dynamic> inputSchema,
    this.description,
    bool hasDescription = false,
  }) : inputSchema = deepUnmodifiableMap(inputSchema),
       hasDescription = hasDescription || description != null;

  /// Parses one tool entry from the provider.
  factory McpListedTool.fromJson(Map<String, dynamic> json) {
    if (json case {
      'name': final String name,
      'input_schema': final Map<String, dynamic> schema,
    }) {
      return McpListedTool(
        name: name,
        inputSchema: schema,
        description: json['description'] as String?,
        hasDescription: json.containsKey('description'),
      );
    }
    throw const FormatException('Invalid MCP listed tool');
  }

  /// The tool name on this server.
  final String name;

  /// JSON schema for the tool's inputs.
  final Map<String, dynamic> inputSchema;

  /// Human-readable tool description.
  final String? description;

  /// Whether the listing supplied the description, including explicit null.
  final bool hasDescription;

  /// Serializes the tool for pinning or history replay.
  Map<String, dynamic> toJson() => {
    'name': name,
    'input_schema': inputSchema,
    if (hasDescription) 'description': description,
  };

  /// Copies this tool listing entry.
  McpListedTool copyWith({
    String? name,
    Map<String, dynamic>? inputSchema,
    Object? description = unsetCopyWithValue,
    bool? hasDescription,
  }) => McpListedTool(
    name: name ?? this.name,
    inputSchema: inputSchema ?? this.inputSchema,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    hasDescription:
        hasDescription ??
        (description == unsetCopyWithValue
            ? this.hasDescription
            : description != null),
  );

  @override
  bool operator ==(Object other) =>
      other is McpListedTool &&
      name == other.name &&
      description == other.description &&
      hasDescription == other.hasDescription &&
      mapsDeepEqual(inputSchema, other.inputSchema);

  @override
  int get hashCode => Object.hash(
    name,
    description,
    hasDescription,
    mapDeepHashCode(inputSchema),
  );

  @override
  String toString() =>
      'McpListedTool(name: $name, hasDescription: $hasDescription, '
      'schema: ${inputSchema.length} fields)';
}

/// A Messages toolset referencing a server declared in `mcp_servers`.
@immutable
final class McpConnectorToolset extends BuiltInTool {
  /// Creates a toolset for the named MCP server.
  McpConnectorToolset({
    required this.serverName,
    this.defaultConfig,
    Map<String, McpConnectorToolSettings>? configs,
    List<McpListedTool>? tools,
    this.cacheControl,
  }) : configs = configs == null ? null : Map.unmodifiable(configs),
       tools = tools == null ? null : List.unmodifiable(tools);

  /// Parses the current `mcp_toolset` shape.
  factory McpConnectorToolset.fromJson(Map<String, dynamic> json) {
    if (json case {
      'type': 'mcp_toolset',
      'mcp_server_name': final String serverName,
    }) {
      final defaults = json['default_config'] as Map<String, dynamic>?;
      return McpConnectorToolset(
        serverName: serverName,
        defaultConfig: defaults == null
            ? null
            : McpConnectorToolSettings.fromJson(defaults),
        configs: (json['configs'] as Map<String, dynamic>?)?.map(
          (name, value) => MapEntry(
            name,
            McpConnectorToolSettings.fromJson(value as Map<String, dynamic>),
          ),
        ),
        tools: (json['tools'] as List<Object?>?)
            ?.map(
              (value) => McpListedTool.fromJson(value! as Map<String, dynamic>),
            )
            .toList(),
        cacheControl: switch (json['cache_control']) {
          final Map<String, dynamic> value => CacheControlEphemeral.fromJson(
            value,
          ),
          _ => null,
        },
      );
    }
    throw const FormatException('Invalid MCP connector toolset');
  }

  /// Name of the matching server definition.
  final String serverName;

  /// Defaults applied to all tools from the server.
  final McpConnectorToolSettings? defaultConfig;

  /// Per-tool configuration keyed by the tool's name.
  final Map<String, McpConnectorToolSettings>? configs;

  /// Tool listing pinned by the application when using
  /// `mcp-client-2026-09-15`. An empty list pins no tools.
  final List<McpListedTool>? tools;

  /// Optional prompt-cache breakpoint.
  final CacheControlEphemeral? cacheControl;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp_toolset',
    'mcp_server_name': serverName,
    'default_config': ?defaultConfig?.toJson(),
    'configs': ?configs?.map((name, config) => MapEntry(name, config.toJson())),
    'tools': ?tools?.map((tool) => tool.toJson()).toList(),
    'cache_control': ?cacheControl?.toJson(),
  };

  /// Copies this toolset, with null clearing an optional setting.
  McpConnectorToolset copyWith({
    String? serverName,
    Object? defaultConfig = unsetCopyWithValue,
    Object? configs = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) => McpConnectorToolset(
    serverName: serverName ?? this.serverName,
    defaultConfig: defaultConfig == unsetCopyWithValue
        ? this.defaultConfig
        : defaultConfig as McpConnectorToolSettings?,
    configs: configs == unsetCopyWithValue
        ? this.configs
        : (configs as Map?)?.cast<String, McpConnectorToolSettings>(),
    tools: tools == unsetCopyWithValue
        ? this.tools
        : (tools as List<Object?>?)?.cast<McpListedTool>(),
    cacheControl: cacheControl == unsetCopyWithValue
        ? this.cacheControl
        : cacheControl as CacheControlEphemeral?,
  );

  @override
  bool operator ==(Object other) =>
      other is McpConnectorToolset &&
      serverName == other.serverName &&
      defaultConfig == other.defaultConfig &&
      mapsEqual(configs, other.configs) &&
      listsEqual(tools, other.tools) &&
      cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(
    serverName,
    defaultConfig,
    mapHash(configs),
    listHash(tools),
    cacheControl,
  );

  @override
  String toString() =>
      'McpConnectorToolset(serverName: $serverName, tools: ${tools?.length})';
}
