import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'permission_policy.dart';

// ---------------------------------------------------------------------------
// AgentToolName enum
// ---------------------------------------------------------------------------

/// Built-in agent tool identifier.
enum AgentToolName {
  /// Bash tool.
  bash('bash'),

  /// Edit tool.
  edit('edit'),

  /// Read tool.
  read('read'),

  /// Write tool.
  write('write'),

  /// Glob tool.
  glob('glob'),

  /// Grep tool.
  grep('grep'),

  /// Web fetch tool.
  webFetch('web_fetch'),

  /// Web search tool.
  webSearch('web_search'),

  /// Unknown tool name — fallback for unrecognized values.
  unknown('unknown');

  const AgentToolName(this.value);

  /// JSON value for this tool name.
  final String value;

  /// Parses an [AgentToolName] from JSON.
  static AgentToolName fromJson(String value) => switch (value) {
    'bash' => AgentToolName.bash,
    'edit' => AgentToolName.edit,
    'read' => AgentToolName.read,
    'write' => AgentToolName.write,
    'glob' => AgentToolName.glob,
    'grep' => AgentToolName.grep,
    'web_fetch' => AgentToolName.webFetch,
    'web_search' => AgentToolName.webSearch,
    _ => AgentToolName.unknown,
  };

  /// Converts this tool name to JSON.
  String toJson() => value;
}

/// Evaluated permission for agent tool invocations.
enum AgentEvaluatedPermission {
  /// The tool call is allowed.
  allow('allow'),

  /// The tool call requires user confirmation.
  ask('ask'),

  /// The tool call is denied.
  deny('deny'),

  /// Unknown permission — fallback for unrecognized values.
  unknown('unknown');

  const AgentEvaluatedPermission(this.value);

  /// JSON value for this permission.
  final String value;

  /// Parses an [AgentEvaluatedPermission] from JSON.
  static AgentEvaluatedPermission fromJson(String value) => switch (value) {
    'allow' => AgentEvaluatedPermission.allow,
    'ask' => AgentEvaluatedPermission.ask,
    'deny' => AgentEvaluatedPermission.deny,
    _ => AgentEvaluatedPermission.unknown,
  };

  /// Converts this permission to JSON.
  String toJson() => value;
}

// ---------------------------------------------------------------------------
// AgentTool — sealed union (response)
// ---------------------------------------------------------------------------

/// Union type for tool configurations returned in API responses.
///
/// Variants:
/// - [AgentToolset20260401] — built-in agent tools.
/// - [MCPToolset] — tools from an MCP server.
/// - [CustomTool] — a client-executed custom tool.
/// - [UnknownAgentTool] — unrecognised tool type (preserves raw JSON).
sealed class AgentTool {
  const AgentTool();

  /// Creates an [AgentTool] from JSON.
  factory AgentTool.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'agent_toolset_20260401' => AgentToolset20260401.fromJson(json),
      'mcp_toolset' => MCPToolset.fromJson(json),
      'custom' => CustomTool.fromJson(json),
      _ => UnknownAgentTool._(type: type, raw: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

// ---------------------------------------------------------------------------
// AgentToolParams — sealed union (request)
// ---------------------------------------------------------------------------

/// Union type for tool configurations in create/update requests.
///
/// Variants:
/// - [AgentToolset20260401Params] — built-in agent tools.
/// - [MCPToolsetParams] — tools from an MCP server.
/// - [CustomToolParams] — a client-executed custom tool.
/// - [UnknownAgentToolParams] — unrecognised tool type (preserves raw JSON).
sealed class AgentToolParams {
  const AgentToolParams();

  /// Creates an [AgentToolParams] from JSON.
  factory AgentToolParams.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'agent_toolset_20260401' => AgentToolset20260401Params.fromJson(json),
      'mcp_toolset' => MCPToolsetParams.fromJson(json),
      'custom' => CustomToolParams.fromJson(json),
      _ => UnknownAgentToolParams._(type: type, raw: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

// ---------------------------------------------------------------------------
// AgentToolset20260401 (response)
// ---------------------------------------------------------------------------

/// Configuration for built-in agent tools (response variant).
@immutable
class AgentToolset20260401 extends AgentTool {
  /// The type discriminator. Always `agent_toolset_20260401`.
  final String type;

  /// Default configuration for all tools in this set.
  final AgentToolsetDefaultConfig defaultConfig;

  /// Per-tool configuration overrides.
  final List<AgentToolConfig> configs;

  /// Creates an [AgentToolset20260401].
  const AgentToolset20260401({
    this.type = 'agent_toolset_20260401',
    required this.defaultConfig,
    required this.configs,
  });

  /// Creates an [AgentToolset20260401] from JSON.
  factory AgentToolset20260401.fromJson(Map<String, dynamic> json) {
    return AgentToolset20260401(
      type: json['type'] as String? ?? 'agent_toolset_20260401',
      defaultConfig: AgentToolsetDefaultConfig.fromJson(
        json['default_config'] as Map<String, dynamic>,
      ),
      configs: (json['configs'] as List)
          .map((e) => AgentToolConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'default_config': defaultConfig.toJson(),
    'configs': configs.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  AgentToolset20260401 copyWith({
    String? type,
    AgentToolsetDefaultConfig? defaultConfig,
    List<AgentToolConfig>? configs,
  }) {
    return AgentToolset20260401(
      type: type ?? this.type,
      defaultConfig: defaultConfig ?? this.defaultConfig,
      configs: configs ?? this.configs,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentToolset20260401 &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          defaultConfig == other.defaultConfig &&
          listsEqual(configs, other.configs);

  @override
  int get hashCode => Object.hash(type, defaultConfig, listHash(configs));

  @override
  String toString() =>
      'AgentToolset20260401('
      'type: $type, defaultConfig: $defaultConfig, configs: $configs)';
}

// ---------------------------------------------------------------------------
// AgentToolset20260401Params (request)
// ---------------------------------------------------------------------------

/// Configuration for built-in agent tools (request variant).
@immutable
class AgentToolset20260401Params extends AgentToolParams {
  /// The type discriminator. Always `agent_toolset_20260401`.
  final String type;

  /// Default configuration applied to all tools in this set.
  final AgentToolsetDefaultConfigParams? defaultConfig;

  /// Per-tool configuration overrides.
  final List<AgentToolConfigParams>? configs;

  /// Creates an [AgentToolset20260401Params].
  const AgentToolset20260401Params({
    this.type = 'agent_toolset_20260401',
    this.defaultConfig,
    this.configs,
  });

  /// Creates an [AgentToolset20260401Params] from JSON.
  factory AgentToolset20260401Params.fromJson(Map<String, dynamic> json) {
    return AgentToolset20260401Params(
      type: json['type'] as String? ?? 'agent_toolset_20260401',
      defaultConfig: json['default_config'] != null
          ? AgentToolsetDefaultConfigParams.fromJson(
              json['default_config'] as Map<String, dynamic>,
            )
          : null,
      configs: (json['configs'] as List?)
          ?.map(
            (e) => AgentToolConfigParams.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (defaultConfig != null) 'default_config': defaultConfig!.toJson(),
    if (configs != null) 'configs': configs!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  AgentToolset20260401Params copyWith({
    String? type,
    Object? defaultConfig = unsetCopyWithValue,
    Object? configs = unsetCopyWithValue,
  }) {
    return AgentToolset20260401Params(
      type: type ?? this.type,
      defaultConfig: defaultConfig == unsetCopyWithValue
          ? this.defaultConfig
          : defaultConfig as AgentToolsetDefaultConfigParams?,
      configs: configs == unsetCopyWithValue
          ? this.configs
          : configs as List<AgentToolConfigParams>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentToolset20260401Params &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          defaultConfig == other.defaultConfig &&
          listsEqual(configs, other.configs);

  @override
  int get hashCode => Object.hash(type, defaultConfig, listHash(configs));

  @override
  String toString() =>
      'AgentToolset20260401Params('
      'type: $type, defaultConfig: $defaultConfig, configs: $configs)';
}

// ---------------------------------------------------------------------------
// MCPToolset (response)
// ---------------------------------------------------------------------------

/// Configuration for tools from an MCP server (response variant).
@immutable
class MCPToolset extends AgentTool {
  /// The type discriminator. Always `mcp_toolset`.
  final String type;

  /// Name of the MCP server.
  final String mcpServerName;

  /// Default configuration for all tools from this server.
  final MCPToolsetDefaultConfig defaultConfig;

  /// Per-tool configuration overrides.
  final List<MCPToolConfig> configs;

  /// Creates an [MCPToolset].
  const MCPToolset({
    this.type = 'mcp_toolset',
    required this.mcpServerName,
    required this.defaultConfig,
    required this.configs,
  });

  /// Creates an [MCPToolset] from JSON.
  factory MCPToolset.fromJson(Map<String, dynamic> json) {
    return MCPToolset(
      type: json['type'] as String? ?? 'mcp_toolset',
      mcpServerName: json['mcp_server_name'] as String,
      defaultConfig: MCPToolsetDefaultConfig.fromJson(
        json['default_config'] as Map<String, dynamic>,
      ),
      configs: (json['configs'] as List)
          .map((e) => MCPToolConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'mcp_server_name': mcpServerName,
    'default_config': defaultConfig.toJson(),
    'configs': configs.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  MCPToolset copyWith({
    String? type,
    String? mcpServerName,
    MCPToolsetDefaultConfig? defaultConfig,
    List<MCPToolConfig>? configs,
  }) {
    return MCPToolset(
      type: type ?? this.type,
      mcpServerName: mcpServerName ?? this.mcpServerName,
      defaultConfig: defaultConfig ?? this.defaultConfig,
      configs: configs ?? this.configs,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCPToolset &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mcpServerName == other.mcpServerName &&
          defaultConfig == other.defaultConfig &&
          listsEqual(configs, other.configs);

  @override
  int get hashCode =>
      Object.hash(type, mcpServerName, defaultConfig, listHash(configs));

  @override
  String toString() =>
      'MCPToolset('
      'type: $type, '
      'mcpServerName: $mcpServerName, '
      'defaultConfig: $defaultConfig, '
      'configs: $configs)';
}

// ---------------------------------------------------------------------------
// MCPToolsetParams (request)
// ---------------------------------------------------------------------------

/// Configuration for tools from an MCP server (request variant).
@immutable
class MCPToolsetParams extends AgentToolParams {
  /// The type discriminator. Always `mcp_toolset`.
  final String type;

  /// Name of the MCP server.
  final String mcpServerName;

  /// Default configuration for all tools from this server.
  final MCPToolsetDefaultConfigParams? defaultConfig;

  /// Per-tool configuration overrides.
  final List<MCPToolConfigParams>? configs;

  /// Creates an [MCPToolsetParams].
  const MCPToolsetParams({
    this.type = 'mcp_toolset',
    required this.mcpServerName,
    this.defaultConfig,
    this.configs,
  });

  /// Creates an [MCPToolsetParams] from JSON.
  factory MCPToolsetParams.fromJson(Map<String, dynamic> json) {
    return MCPToolsetParams(
      type: json['type'] as String? ?? 'mcp_toolset',
      mcpServerName: json['mcp_server_name'] as String,
      defaultConfig: json['default_config'] != null
          ? MCPToolsetDefaultConfigParams.fromJson(
              json['default_config'] as Map<String, dynamic>,
            )
          : null,
      configs: (json['configs'] as List?)
          ?.map((e) => MCPToolConfigParams.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'mcp_server_name': mcpServerName,
    if (defaultConfig != null) 'default_config': defaultConfig!.toJson(),
    if (configs != null) 'configs': configs!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  MCPToolsetParams copyWith({
    String? type,
    String? mcpServerName,
    Object? defaultConfig = unsetCopyWithValue,
    Object? configs = unsetCopyWithValue,
  }) {
    return MCPToolsetParams(
      type: type ?? this.type,
      mcpServerName: mcpServerName ?? this.mcpServerName,
      defaultConfig: defaultConfig == unsetCopyWithValue
          ? this.defaultConfig
          : defaultConfig as MCPToolsetDefaultConfigParams?,
      configs: configs == unsetCopyWithValue
          ? this.configs
          : configs as List<MCPToolConfigParams>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCPToolsetParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mcpServerName == other.mcpServerName &&
          defaultConfig == other.defaultConfig &&
          listsEqual(configs, other.configs);

  @override
  int get hashCode =>
      Object.hash(type, mcpServerName, defaultConfig, listHash(configs));

  @override
  String toString() =>
      'MCPToolsetParams('
      'type: $type, '
      'mcpServerName: $mcpServerName, '
      'defaultConfig: $defaultConfig, '
      'configs: $configs)';
}

// ---------------------------------------------------------------------------
// CustomTool (response)
// ---------------------------------------------------------------------------

/// A custom tool as returned in API responses.
@immutable
class CustomTool extends AgentTool {
  /// The type discriminator. Always `custom`.
  final String type;

  /// Name of the custom tool.
  final String name;

  /// Description of what the tool does.
  final String description;

  /// JSON Schema defining the expected input parameters.
  final CustomToolInputSchema inputSchema;

  /// Creates a [CustomTool].
  const CustomTool({
    this.type = 'custom',
    required this.name,
    required this.description,
    required this.inputSchema,
  });

  /// Creates a [CustomTool] from JSON.
  factory CustomTool.fromJson(Map<String, dynamic> json) {
    return CustomTool(
      type: json['type'] as String? ?? 'custom',
      name: json['name'] as String,
      description: json['description'] as String,
      inputSchema: CustomToolInputSchema.fromJson(
        json['input_schema'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'description': description,
    'input_schema': inputSchema.toJson(),
  };

  /// Creates a copy with replaced values.
  CustomTool copyWith({
    String? type,
    String? name,
    String? description,
    CustomToolInputSchema? inputSchema,
  }) {
    return CustomTool(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      inputSchema: inputSchema ?? this.inputSchema,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomTool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          description == other.description &&
          inputSchema == other.inputSchema;

  @override
  int get hashCode => Object.hash(type, name, description, inputSchema);

  @override
  String toString() =>
      'CustomTool('
      'type: $type, '
      'name: $name, '
      'description: $description, '
      'inputSchema: $inputSchema)';
}

// ---------------------------------------------------------------------------
// CustomToolParams (request)
// ---------------------------------------------------------------------------

/// A custom tool parameter for create/update requests.
@immutable
class CustomToolParams extends AgentToolParams {
  /// The type discriminator. Always `custom`.
  final String type;

  /// Name of the custom tool.
  final String name;

  /// Description of what the tool does.
  final String description;

  /// JSON Schema defining the expected input parameters.
  final CustomToolInputSchema inputSchema;

  /// Creates a [CustomToolParams].
  const CustomToolParams({
    this.type = 'custom',
    required this.name,
    required this.description,
    required this.inputSchema,
  });

  /// Creates a [CustomToolParams] from JSON.
  factory CustomToolParams.fromJson(Map<String, dynamic> json) {
    return CustomToolParams(
      type: json['type'] as String? ?? 'custom',
      name: json['name'] as String,
      description: json['description'] as String,
      inputSchema: CustomToolInputSchema.fromJson(
        json['input_schema'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'description': description,
    'input_schema': inputSchema.toJson(),
  };

  /// Creates a copy with replaced values.
  CustomToolParams copyWith({
    String? type,
    String? name,
    String? description,
    CustomToolInputSchema? inputSchema,
  }) {
    return CustomToolParams(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      inputSchema: inputSchema ?? this.inputSchema,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomToolParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          description == other.description &&
          inputSchema == other.inputSchema;

  @override
  int get hashCode => Object.hash(type, name, description, inputSchema);

  @override
  String toString() =>
      'CustomToolParams('
      'type: $type, '
      'name: $name, '
      'description: $description, '
      'inputSchema: $inputSchema)';
}

// ---------------------------------------------------------------------------
// Unknown variants
// ---------------------------------------------------------------------------

/// Unrecognised agent tool type — preserves the raw JSON.
@immutable
class UnknownAgentTool extends AgentTool {
  /// The unrecognised type discriminator.
  final String type;

  /// The raw JSON map.
  final Map<String, dynamic> raw;

  const UnknownAgentTool._({required this.type, required this.raw});

  @override
  Map<String, dynamic> toJson() => raw;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownAgentTool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => Object.hash(type, mapDeepHashCode(raw));

  @override
  String toString() => 'UnknownAgentTool(type: $type, raw: $raw)';
}

/// Unrecognised agent tool params type — preserves the raw JSON.
@immutable
class UnknownAgentToolParams extends AgentToolParams {
  /// The unrecognised type discriminator.
  final String type;

  /// The raw JSON map.
  final Map<String, dynamic> raw;

  const UnknownAgentToolParams._({required this.type, required this.raw});

  @override
  Map<String, dynamic> toJson() => raw;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownAgentToolParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => Object.hash(type, mapDeepHashCode(raw));

  @override
  String toString() => 'UnknownAgentToolParams(type: $type, raw: $raw)';
}

// ---------------------------------------------------------------------------
// Default config types (response)
// ---------------------------------------------------------------------------

/// Resolved default configuration for agent tools.
@immutable
class AgentToolsetDefaultConfig {
  /// Whether tools are enabled.
  final bool enabled;

  /// Permission policy for tools.
  final PermissionPolicy permissionPolicy;

  /// Creates an [AgentToolsetDefaultConfig].
  const AgentToolsetDefaultConfig({
    required this.enabled,
    required this.permissionPolicy,
  });

  /// Creates an [AgentToolsetDefaultConfig] from JSON.
  factory AgentToolsetDefaultConfig.fromJson(Map<String, dynamic> json) {
    return AgentToolsetDefaultConfig(
      enabled: json['enabled'] as bool,
      permissionPolicy: PermissionPolicy.fromJson(
        json['permission_policy'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'permission_policy': permissionPolicy.toJson(),
  };

  /// Creates a copy with replaced values.
  AgentToolsetDefaultConfig copyWith({
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) {
    return AgentToolsetDefaultConfig(
      enabled: enabled ?? this.enabled,
      permissionPolicy: permissionPolicy ?? this.permissionPolicy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentToolsetDefaultConfig &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(enabled, permissionPolicy);

  @override
  String toString() =>
      'AgentToolsetDefaultConfig('
      'enabled: $enabled, permissionPolicy: $permissionPolicy)';
}

/// Resolved default configuration for MCP toolset tools.
@immutable
class MCPToolsetDefaultConfig {
  /// Whether tools are enabled.
  final bool enabled;

  /// Permission policy for tools.
  final PermissionPolicy permissionPolicy;

  /// Creates an [MCPToolsetDefaultConfig].
  const MCPToolsetDefaultConfig({
    required this.enabled,
    required this.permissionPolicy,
  });

  /// Creates an [MCPToolsetDefaultConfig] from JSON.
  factory MCPToolsetDefaultConfig.fromJson(Map<String, dynamic> json) {
    return MCPToolsetDefaultConfig(
      enabled: json['enabled'] as bool,
      permissionPolicy: PermissionPolicy.fromJson(
        json['permission_policy'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'permission_policy': permissionPolicy.toJson(),
  };

  /// Creates a copy with replaced values.
  MCPToolsetDefaultConfig copyWith({
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) {
    return MCPToolsetDefaultConfig(
      enabled: enabled ?? this.enabled,
      permissionPolicy: permissionPolicy ?? this.permissionPolicy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCPToolsetDefaultConfig &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(enabled, permissionPolicy);

  @override
  String toString() =>
      'MCPToolsetDefaultConfig('
      'enabled: $enabled, permissionPolicy: $permissionPolicy)';
}

// ---------------------------------------------------------------------------
// Default config types (request)
// ---------------------------------------------------------------------------

/// Default configuration for agent tools (request variant).
@immutable
class AgentToolsetDefaultConfigParams {
  /// Whether tools are enabled. Defaults to true if not specified.
  final bool? enabled;

  /// Default permission policy for tools.
  final PermissionPolicy? permissionPolicy;

  /// Creates an [AgentToolsetDefaultConfigParams].
  const AgentToolsetDefaultConfigParams({this.enabled, this.permissionPolicy});

  /// Creates an [AgentToolsetDefaultConfigParams] from JSON.
  factory AgentToolsetDefaultConfigParams.fromJson(Map<String, dynamic> json) {
    return AgentToolsetDefaultConfigParams(
      enabled: json['enabled'] as bool?,
      permissionPolicy: json['permission_policy'] != null
          ? PermissionPolicy.fromJson(
              json['permission_policy'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (enabled != null) 'enabled': enabled,
    if (permissionPolicy != null)
      'permission_policy': permissionPolicy!.toJson(),
  };

  /// Creates a copy with replaced values.
  AgentToolsetDefaultConfigParams copyWith({
    Object? enabled = unsetCopyWithValue,
    Object? permissionPolicy = unsetCopyWithValue,
  }) {
    return AgentToolsetDefaultConfigParams(
      enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
      permissionPolicy: permissionPolicy == unsetCopyWithValue
          ? this.permissionPolicy
          : permissionPolicy as PermissionPolicy?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentToolsetDefaultConfigParams &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(enabled, permissionPolicy);

  @override
  String toString() =>
      'AgentToolsetDefaultConfigParams('
      'enabled: $enabled, permissionPolicy: $permissionPolicy)';
}

/// Default configuration for MCP toolset tools (request variant).
@immutable
class MCPToolsetDefaultConfigParams {
  /// Whether tools are enabled by default.
  final bool? enabled;

  /// Default permission policy for tools from this server.
  final PermissionPolicy? permissionPolicy;

  /// Creates an [MCPToolsetDefaultConfigParams].
  const MCPToolsetDefaultConfigParams({this.enabled, this.permissionPolicy});

  /// Creates an [MCPToolsetDefaultConfigParams] from JSON.
  factory MCPToolsetDefaultConfigParams.fromJson(Map<String, dynamic> json) {
    return MCPToolsetDefaultConfigParams(
      enabled: json['enabled'] as bool?,
      permissionPolicy: json['permission_policy'] != null
          ? PermissionPolicy.fromJson(
              json['permission_policy'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (enabled != null) 'enabled': enabled,
    if (permissionPolicy != null)
      'permission_policy': permissionPolicy!.toJson(),
  };

  /// Creates a copy with replaced values.
  MCPToolsetDefaultConfigParams copyWith({
    Object? enabled = unsetCopyWithValue,
    Object? permissionPolicy = unsetCopyWithValue,
  }) {
    return MCPToolsetDefaultConfigParams(
      enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
      permissionPolicy: permissionPolicy == unsetCopyWithValue
          ? this.permissionPolicy
          : permissionPolicy as PermissionPolicy?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCPToolsetDefaultConfigParams &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(enabled, permissionPolicy);

  @override
  String toString() =>
      'MCPToolsetDefaultConfigParams('
      'enabled: $enabled, permissionPolicy: $permissionPolicy)';
}

// ---------------------------------------------------------------------------
// Tool config types (response)
// ---------------------------------------------------------------------------

/// Configuration for a specific built-in agent tool (response variant).
///
/// Variants:
/// - [BashToolConfig], [EditToolConfig], [ReadToolConfig], [WriteToolConfig],
///   [GlobToolConfig], [GrepToolConfig] — the file/shell tools, all sharing
///   the same `{name, enabled, permissionPolicy}` shape.
/// - [WebFetchToolConfig] — adds domain filtering and a content-token cap.
/// - [WebSearchToolConfig] — adds domain filtering and a user location.
/// - [UnknownAgentToolConfig] — unrecognised tool type (preserves raw JSON).
sealed class AgentToolConfig {
  const AgentToolConfig();

  /// Creates an [AgentToolConfig] from JSON.
  factory AgentToolConfig.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'bash' => BashToolConfig.fromJson(json),
      'edit' => EditToolConfig.fromJson(json),
      'read' => ReadToolConfig.fromJson(json),
      'write' => WriteToolConfig.fromJson(json),
      'glob' => GlobToolConfig.fromJson(json),
      'grep' => GrepToolConfig.fromJson(json),
      'web_fetch' => WebFetchToolConfig.fromJson(json),
      'web_search' => WebSearchToolConfig.fromJson(json),
      _ => UnknownAgentToolConfig._(rawType: type, raw: json),
    };
  }

  /// The tool name.
  AgentToolName get name;

  /// Whether this tool is enabled.
  bool get enabled;

  /// Permission policy for this tool.
  PermissionPolicy get permissionPolicy;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Configuration for the `bash` tool (response variant).
@immutable
class BashToolConfig extends AgentToolConfig {
  /// The type discriminator. Always `bash`.
  final String type;

  @override
  final AgentToolName name;

  @override
  final bool enabled;

  @override
  final PermissionPolicy permissionPolicy;

  /// Creates a [BashToolConfig].
  const BashToolConfig({
    this.type = 'bash',
    this.name = AgentToolName.bash,
    required this.enabled,
    required this.permissionPolicy,
  });

  /// Creates a [BashToolConfig] from JSON.
  factory BashToolConfig.fromJson(Map<String, dynamic> json) {
    return BashToolConfig(
      type: json['type'] as String? ?? 'bash',
      name: AgentToolName.fromJson(json['name'] as String),
      enabled: json['enabled'] as bool,
      permissionPolicy: PermissionPolicy.fromJson(
        json['permission_policy'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name.toJson(),
    'enabled': enabled,
    'permission_policy': permissionPolicy.toJson(),
  };

  /// Creates a copy with replaced values.
  BashToolConfig copyWith({
    String? type,
    AgentToolName? name,
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) {
    return BashToolConfig(
      type: type ?? this.type,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      permissionPolicy: permissionPolicy ?? this.permissionPolicy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BashToolConfig &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(type, name, enabled, permissionPolicy);

  @override
  String toString() =>
      'BashToolConfig('
      'type: $type, name: $name, enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
}

/// Configuration for the `edit` tool (response variant).
@immutable
class EditToolConfig extends AgentToolConfig {
  /// The type discriminator. Always `edit`.
  final String type;

  @override
  final AgentToolName name;

  @override
  final bool enabled;

  @override
  final PermissionPolicy permissionPolicy;

  /// Creates an [EditToolConfig].
  const EditToolConfig({
    this.type = 'edit',
    this.name = AgentToolName.edit,
    required this.enabled,
    required this.permissionPolicy,
  });

  /// Creates an [EditToolConfig] from JSON.
  factory EditToolConfig.fromJson(Map<String, dynamic> json) {
    return EditToolConfig(
      type: json['type'] as String? ?? 'edit',
      name: AgentToolName.fromJson(json['name'] as String),
      enabled: json['enabled'] as bool,
      permissionPolicy: PermissionPolicy.fromJson(
        json['permission_policy'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name.toJson(),
    'enabled': enabled,
    'permission_policy': permissionPolicy.toJson(),
  };

  /// Creates a copy with replaced values.
  EditToolConfig copyWith({
    String? type,
    AgentToolName? name,
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) {
    return EditToolConfig(
      type: type ?? this.type,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      permissionPolicy: permissionPolicy ?? this.permissionPolicy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditToolConfig &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(type, name, enabled, permissionPolicy);

  @override
  String toString() =>
      'EditToolConfig('
      'type: $type, name: $name, enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
}

/// Configuration for the `read` tool (response variant).
@immutable
class ReadToolConfig extends AgentToolConfig {
  /// The type discriminator. Always `read`.
  final String type;

  @override
  final AgentToolName name;

  @override
  final bool enabled;

  @override
  final PermissionPolicy permissionPolicy;

  /// Creates a [ReadToolConfig].
  const ReadToolConfig({
    this.type = 'read',
    this.name = AgentToolName.read,
    required this.enabled,
    required this.permissionPolicy,
  });

  /// Creates a [ReadToolConfig] from JSON.
  factory ReadToolConfig.fromJson(Map<String, dynamic> json) {
    return ReadToolConfig(
      type: json['type'] as String? ?? 'read',
      name: AgentToolName.fromJson(json['name'] as String),
      enabled: json['enabled'] as bool,
      permissionPolicy: PermissionPolicy.fromJson(
        json['permission_policy'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name.toJson(),
    'enabled': enabled,
    'permission_policy': permissionPolicy.toJson(),
  };

  /// Creates a copy with replaced values.
  ReadToolConfig copyWith({
    String? type,
    AgentToolName? name,
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) {
    return ReadToolConfig(
      type: type ?? this.type,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      permissionPolicy: permissionPolicy ?? this.permissionPolicy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadToolConfig &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(type, name, enabled, permissionPolicy);

  @override
  String toString() =>
      'ReadToolConfig('
      'type: $type, name: $name, enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
}

/// Configuration for the `write` tool (response variant).
@immutable
class WriteToolConfig extends AgentToolConfig {
  /// The type discriminator. Always `write`.
  final String type;

  @override
  final AgentToolName name;

  @override
  final bool enabled;

  @override
  final PermissionPolicy permissionPolicy;

  /// Creates a [WriteToolConfig].
  const WriteToolConfig({
    this.type = 'write',
    this.name = AgentToolName.write,
    required this.enabled,
    required this.permissionPolicy,
  });

  /// Creates a [WriteToolConfig] from JSON.
  factory WriteToolConfig.fromJson(Map<String, dynamic> json) {
    return WriteToolConfig(
      type: json['type'] as String? ?? 'write',
      name: AgentToolName.fromJson(json['name'] as String),
      enabled: json['enabled'] as bool,
      permissionPolicy: PermissionPolicy.fromJson(
        json['permission_policy'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name.toJson(),
    'enabled': enabled,
    'permission_policy': permissionPolicy.toJson(),
  };

  /// Creates a copy with replaced values.
  WriteToolConfig copyWith({
    String? type,
    AgentToolName? name,
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) {
    return WriteToolConfig(
      type: type ?? this.type,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      permissionPolicy: permissionPolicy ?? this.permissionPolicy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WriteToolConfig &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(type, name, enabled, permissionPolicy);

  @override
  String toString() =>
      'WriteToolConfig('
      'type: $type, name: $name, enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
}

/// Configuration for the `glob` tool (response variant).
@immutable
class GlobToolConfig extends AgentToolConfig {
  /// The type discriminator. Always `glob`.
  final String type;

  @override
  final AgentToolName name;

  @override
  final bool enabled;

  @override
  final PermissionPolicy permissionPolicy;

  /// Creates a [GlobToolConfig].
  const GlobToolConfig({
    this.type = 'glob',
    this.name = AgentToolName.glob,
    required this.enabled,
    required this.permissionPolicy,
  });

  /// Creates a [GlobToolConfig] from JSON.
  factory GlobToolConfig.fromJson(Map<String, dynamic> json) {
    return GlobToolConfig(
      type: json['type'] as String? ?? 'glob',
      name: AgentToolName.fromJson(json['name'] as String),
      enabled: json['enabled'] as bool,
      permissionPolicy: PermissionPolicy.fromJson(
        json['permission_policy'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name.toJson(),
    'enabled': enabled,
    'permission_policy': permissionPolicy.toJson(),
  };

  /// Creates a copy with replaced values.
  GlobToolConfig copyWith({
    String? type,
    AgentToolName? name,
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) {
    return GlobToolConfig(
      type: type ?? this.type,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      permissionPolicy: permissionPolicy ?? this.permissionPolicy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlobToolConfig &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(type, name, enabled, permissionPolicy);

  @override
  String toString() =>
      'GlobToolConfig('
      'type: $type, name: $name, enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
}

/// Configuration for the `grep` tool (response variant).
@immutable
class GrepToolConfig extends AgentToolConfig {
  /// The type discriminator. Always `grep`.
  final String type;

  @override
  final AgentToolName name;

  @override
  final bool enabled;

  @override
  final PermissionPolicy permissionPolicy;

  /// Creates a [GrepToolConfig].
  const GrepToolConfig({
    this.type = 'grep',
    this.name = AgentToolName.grep,
    required this.enabled,
    required this.permissionPolicy,
  });

  /// Creates a [GrepToolConfig] from JSON.
  factory GrepToolConfig.fromJson(Map<String, dynamic> json) {
    return GrepToolConfig(
      type: json['type'] as String? ?? 'grep',
      name: AgentToolName.fromJson(json['name'] as String),
      enabled: json['enabled'] as bool,
      permissionPolicy: PermissionPolicy.fromJson(
        json['permission_policy'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name.toJson(),
    'enabled': enabled,
    'permission_policy': permissionPolicy.toJson(),
  };

  /// Creates a copy with replaced values.
  GrepToolConfig copyWith({
    String? type,
    AgentToolName? name,
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) {
    return GrepToolConfig(
      type: type ?? this.type,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      permissionPolicy: permissionPolicy ?? this.permissionPolicy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrepToolConfig &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(type, name, enabled, permissionPolicy);

  @override
  String toString() =>
      'GrepToolConfig('
      'type: $type, name: $name, enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
}

/// Configuration for the `web_fetch` tool (response variant).
@immutable
class WebFetchToolConfig extends AgentToolConfig {
  /// The type discriminator. Always `web_fetch`.
  final String type;

  @override
  final AgentToolName name;

  @override
  final bool enabled;

  @override
  final PermissionPolicy permissionPolicy;

  /// Only fetch URLs whose host is one of these domains or a subdomain of
  /// one. Mutually exclusive with [blockedDomains].
  final List<String>? allowedDomains;

  /// Never fetch URLs whose host is one of these domains or a subdomain of
  /// one. Mutually exclusive with [allowedDomains].
  final List<String>? blockedDomains;

  /// Maximum number of tokens of fetched text content to include in context
  /// per call. Does not apply to binary content such as PDFs.
  final int? maxContentTokens;

  /// Creates a [WebFetchToolConfig].
  const WebFetchToolConfig({
    this.type = 'web_fetch',
    this.name = AgentToolName.webFetch,
    required this.enabled,
    required this.permissionPolicy,
    this.allowedDomains,
    this.blockedDomains,
    this.maxContentTokens,
  });

  /// Creates a [WebFetchToolConfig] from JSON.
  factory WebFetchToolConfig.fromJson(Map<String, dynamic> json) {
    return WebFetchToolConfig(
      type: json['type'] as String? ?? 'web_fetch',
      name: AgentToolName.fromJson(json['name'] as String),
      enabled: json['enabled'] as bool,
      permissionPolicy: PermissionPolicy.fromJson(
        json['permission_policy'] as Map<String, dynamic>,
      ),
      allowedDomains: (json['allowed_domains'] as List?)
          ?.map((e) => e as String)
          .toList(),
      blockedDomains: (json['blocked_domains'] as List?)
          ?.map((e) => e as String)
          .toList(),
      maxContentTokens: json['max_content_tokens'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name.toJson(),
    'enabled': enabled,
    'permission_policy': permissionPolicy.toJson(),
    if (allowedDomains != null) 'allowed_domains': allowedDomains,
    if (blockedDomains != null) 'blocked_domains': blockedDomains,
    if (maxContentTokens != null) 'max_content_tokens': maxContentTokens,
  };

  /// Creates a copy with replaced values.
  WebFetchToolConfig copyWith({
    String? type,
    AgentToolName? name,
    bool? enabled,
    PermissionPolicy? permissionPolicy,
    Object? allowedDomains = unsetCopyWithValue,
    Object? blockedDomains = unsetCopyWithValue,
    Object? maxContentTokens = unsetCopyWithValue,
  }) {
    return WebFetchToolConfig(
      type: type ?? this.type,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      permissionPolicy: permissionPolicy ?? this.permissionPolicy,
      allowedDomains: allowedDomains == unsetCopyWithValue
          ? this.allowedDomains
          : allowedDomains as List<String>?,
      blockedDomains: blockedDomains == unsetCopyWithValue
          ? this.blockedDomains
          : blockedDomains as List<String>?,
      maxContentTokens: maxContentTokens == unsetCopyWithValue
          ? this.maxContentTokens
          : maxContentTokens as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebFetchToolConfig &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy &&
          listsEqual(allowedDomains, other.allowedDomains) &&
          listsEqual(blockedDomains, other.blockedDomains) &&
          maxContentTokens == other.maxContentTokens;

  @override
  int get hashCode => Object.hash(
    type,
    name,
    enabled,
    permissionPolicy,
    listHash(allowedDomains),
    listHash(blockedDomains),
    maxContentTokens,
  );

  @override
  String toString() =>
      'WebFetchToolConfig('
      'type: $type, name: $name, enabled: $enabled, '
      'permissionPolicy: $permissionPolicy, '
      'allowedDomains: $allowedDomains, '
      'blockedDomains: $blockedDomains, '
      'maxContentTokens: $maxContentTokens)';
}

/// Configuration for the `web_search` tool (response variant).
@immutable
class WebSearchToolConfig extends AgentToolConfig {
  /// The type discriminator. Always `web_search`.
  final String type;

  @override
  final AgentToolName name;

  @override
  final bool enabled;

  @override
  final PermissionPolicy permissionPolicy;

  /// Only return search results whose host is one of these domains or a
  /// subdomain of one. Mutually exclusive with [blockedDomains].
  final List<String>? allowedDomains;

  /// Never return search results whose host is one of these domains or a
  /// subdomain of one. Mutually exclusive with [allowedDomains].
  final List<String>? blockedDomains;

  /// Approximate user location for search result localization.
  final ManagedAgentsUserLocation? userLocation;

  /// Creates a [WebSearchToolConfig].
  const WebSearchToolConfig({
    this.type = 'web_search',
    this.name = AgentToolName.webSearch,
    required this.enabled,
    required this.permissionPolicy,
    this.allowedDomains,
    this.blockedDomains,
    this.userLocation,
  });

  /// Creates a [WebSearchToolConfig] from JSON.
  factory WebSearchToolConfig.fromJson(Map<String, dynamic> json) {
    return WebSearchToolConfig(
      type: json['type'] as String? ?? 'web_search',
      name: AgentToolName.fromJson(json['name'] as String),
      enabled: json['enabled'] as bool,
      permissionPolicy: PermissionPolicy.fromJson(
        json['permission_policy'] as Map<String, dynamic>,
      ),
      allowedDomains: (json['allowed_domains'] as List?)
          ?.map((e) => e as String)
          .toList(),
      blockedDomains: (json['blocked_domains'] as List?)
          ?.map((e) => e as String)
          .toList(),
      userLocation: json['user_location'] != null
          ? ManagedAgentsUserLocation.fromJson(
              json['user_location'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name.toJson(),
    'enabled': enabled,
    'permission_policy': permissionPolicy.toJson(),
    if (allowedDomains != null) 'allowed_domains': allowedDomains,
    if (blockedDomains != null) 'blocked_domains': blockedDomains,
    if (userLocation != null) 'user_location': userLocation!.toJson(),
  };

  /// Creates a copy with replaced values.
  WebSearchToolConfig copyWith({
    String? type,
    AgentToolName? name,
    bool? enabled,
    PermissionPolicy? permissionPolicy,
    Object? allowedDomains = unsetCopyWithValue,
    Object? blockedDomains = unsetCopyWithValue,
    Object? userLocation = unsetCopyWithValue,
  }) {
    return WebSearchToolConfig(
      type: type ?? this.type,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      permissionPolicy: permissionPolicy ?? this.permissionPolicy,
      allowedDomains: allowedDomains == unsetCopyWithValue
          ? this.allowedDomains
          : allowedDomains as List<String>?,
      blockedDomains: blockedDomains == unsetCopyWithValue
          ? this.blockedDomains
          : blockedDomains as List<String>?,
      userLocation: userLocation == unsetCopyWithValue
          ? this.userLocation
          : userLocation as ManagedAgentsUserLocation?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchToolConfig &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy &&
          listsEqual(allowedDomains, other.allowedDomains) &&
          listsEqual(blockedDomains, other.blockedDomains) &&
          userLocation == other.userLocation;

  @override
  int get hashCode => Object.hash(
    type,
    name,
    enabled,
    permissionPolicy,
    listHash(allowedDomains),
    listHash(blockedDomains),
    userLocation,
  );

  @override
  String toString() =>
      'WebSearchToolConfig('
      'type: $type, name: $name, enabled: $enabled, '
      'permissionPolicy: $permissionPolicy, '
      'allowedDomains: $allowedDomains, '
      'blockedDomains: $blockedDomains, '
      'userLocation: $userLocation)';
}

/// Unrecognised agent tool config type — preserves the raw JSON.
@immutable
class UnknownAgentToolConfig extends AgentToolConfig {
  /// The unrecognised type discriminator.
  final String? rawType;

  /// The raw JSON map.
  final Map<String, dynamic> raw;

  const UnknownAgentToolConfig._({required this.rawType, required this.raw});

  @override
  AgentToolName get name =>
      AgentToolName.fromJson(raw['name'] as String? ?? '');

  @override
  bool get enabled => raw['enabled'] as bool? ?? false;

  @override
  PermissionPolicy get permissionPolicy => raw['permission_policy'] != null
      ? PermissionPolicy.fromJson(
          raw['permission_policy'] as Map<String, dynamic>,
        )
      : const AlwaysAskPolicy();

  @override
  Map<String, dynamic> toJson() => raw;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownAgentToolConfig &&
          runtimeType == other.runtimeType &&
          rawType == other.rawType &&
          mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => Object.hash(rawType, mapDeepHashCode(raw));

  @override
  String toString() => 'UnknownAgentToolConfig(rawType: $rawType, raw: $raw)';
}

/// Approximate user location for search result localization, used by
/// [WebSearchToolConfig] and [WebSearchToolConfigParams].
///
/// Distinct from the Messages-API `UserLocation` (a different schema).
@immutable
class ManagedAgentsUserLocation {
  /// Location precision. Only `approximate` is supported.
  final String type;

  /// City name.
  final String? city;

  /// Two-letter ISO 3166-1 country code, uppercase.
  final String? country;

  /// Region or state name.
  final String? region;

  /// IANA timezone identifier, e.g. `America/Los_Angeles`.
  final String? timezone;

  /// Creates a [ManagedAgentsUserLocation].
  const ManagedAgentsUserLocation({
    this.type = 'approximate',
    this.city,
    this.country,
    this.region,
    this.timezone,
  });

  /// Creates a [ManagedAgentsUserLocation] from JSON.
  factory ManagedAgentsUserLocation.fromJson(Map<String, dynamic> json) {
    return ManagedAgentsUserLocation(
      type: json['type'] as String? ?? 'approximate',
      city: json['city'] as String?,
      country: json['country'] as String?,
      region: json['region'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (city != null) 'city': city,
    if (country != null) 'country': country,
    if (region != null) 'region': region,
    if (timezone != null) 'timezone': timezone,
  };

  /// Creates a copy with replaced values.
  ManagedAgentsUserLocation copyWith({
    String? type,
    Object? city = unsetCopyWithValue,
    Object? country = unsetCopyWithValue,
    Object? region = unsetCopyWithValue,
    Object? timezone = unsetCopyWithValue,
  }) {
    return ManagedAgentsUserLocation(
      type: type ?? this.type,
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
      other is ManagedAgentsUserLocation &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          city == other.city &&
          country == other.country &&
          region == other.region &&
          timezone == other.timezone;

  @override
  int get hashCode => Object.hash(type, city, country, region, timezone);

  @override
  String toString() =>
      'ManagedAgentsUserLocation('
      'type: $type, city: $city, country: $country, '
      'region: $region, timezone: $timezone)';
}

/// Configuration for a specific MCP tool (response variant).
@immutable
class MCPToolConfig {
  /// The tool name.
  final String name;

  /// Whether this tool is enabled.
  final bool enabled;

  /// Permission policy for this tool.
  final PermissionPolicy permissionPolicy;

  /// Creates an [MCPToolConfig].
  const MCPToolConfig({
    required this.name,
    required this.enabled,
    required this.permissionPolicy,
  });

  /// Creates an [MCPToolConfig] from JSON.
  factory MCPToolConfig.fromJson(Map<String, dynamic> json) {
    return MCPToolConfig(
      name: json['name'] as String,
      enabled: json['enabled'] as bool,
      permissionPolicy: PermissionPolicy.fromJson(
        json['permission_policy'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'enabled': enabled,
    'permission_policy': permissionPolicy.toJson(),
  };

  /// Creates a copy with replaced values.
  MCPToolConfig copyWith({
    String? name,
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) {
    return MCPToolConfig(
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      permissionPolicy: permissionPolicy ?? this.permissionPolicy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCPToolConfig &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(name, enabled, permissionPolicy);

  @override
  String toString() =>
      'MCPToolConfig('
      'name: $name, enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
}

// ---------------------------------------------------------------------------
// Tool config types (request)
// ---------------------------------------------------------------------------

/// Configuration override for a specific built-in agent tool (request
/// variant).
///
/// Variants:
/// - [BashToolConfigParams], [EditToolConfigParams], [ReadToolConfigParams],
///   [WriteToolConfigParams], [GlobToolConfigParams], [GrepToolConfigParams]
///   — the file/shell tools, all sharing the same
///   `{name, enabled?, permissionPolicy?}` shape.
/// - [WebFetchToolConfigParams] — adds domain filtering and a content-token
///   cap.
/// - [WebSearchToolConfigParams] — adds domain filtering and a user
///   location.
/// - [UnknownAgentToolConfigParams] — unrecognised tool type (preserves raw
///   JSON).
sealed class AgentToolConfigParams {
  const AgentToolConfigParams();

  /// Creates an [AgentToolConfigParams] from JSON.
  factory AgentToolConfigParams.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] ?? json['name']) as String?;
    return switch (type) {
      'bash' => BashToolConfigParams.fromJson(json),
      'edit' => EditToolConfigParams.fromJson(json),
      'read' => ReadToolConfigParams.fromJson(json),
      'write' => WriteToolConfigParams.fromJson(json),
      'glob' => GlobToolConfigParams.fromJson(json),
      'grep' => GrepToolConfigParams.fromJson(json),
      'web_fetch' => WebFetchToolConfigParams.fromJson(json),
      'web_search' => WebSearchToolConfigParams.fromJson(json),
      _ => UnknownAgentToolConfigParams._(rawType: type, raw: json),
    };
  }

  /// The tool name.
  AgentToolName get name;

  /// Whether this tool is enabled. Overrides the `default_config` setting.
  bool? get enabled;

  /// Permission policy for this tool.
  PermissionPolicy? get permissionPolicy;

  /// Creates a [BashToolConfigParams].
  factory AgentToolConfigParams.bash({
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) => BashToolConfigParams(
    enabled: enabled,
    permissionPolicy: permissionPolicy,
  );

  /// Creates an [EditToolConfigParams].
  factory AgentToolConfigParams.edit({
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) => EditToolConfigParams(
    enabled: enabled,
    permissionPolicy: permissionPolicy,
  );

  /// Creates a [ReadToolConfigParams].
  factory AgentToolConfigParams.read({
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) => ReadToolConfigParams(
    enabled: enabled,
    permissionPolicy: permissionPolicy,
  );

  /// Creates a [WriteToolConfigParams].
  factory AgentToolConfigParams.write({
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) => WriteToolConfigParams(
    enabled: enabled,
    permissionPolicy: permissionPolicy,
  );

  /// Creates a [GlobToolConfigParams].
  factory AgentToolConfigParams.glob({
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) => GlobToolConfigParams(
    enabled: enabled,
    permissionPolicy: permissionPolicy,
  );

  /// Creates a [GrepToolConfigParams].
  factory AgentToolConfigParams.grep({
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) => GrepToolConfigParams(
    enabled: enabled,
    permissionPolicy: permissionPolicy,
  );

  /// Creates a [WebFetchToolConfigParams].
  factory AgentToolConfigParams.webFetch({
    bool? enabled,
    PermissionPolicy? permissionPolicy,
    List<String>? allowedDomains,
    List<String>? blockedDomains,
    int? maxContentTokens,
  }) => WebFetchToolConfigParams(
    enabled: enabled,
    permissionPolicy: permissionPolicy,
    allowedDomains: allowedDomains,
    blockedDomains: blockedDomains,
    maxContentTokens: maxContentTokens,
  );

  /// Creates a [WebSearchToolConfigParams].
  factory AgentToolConfigParams.webSearch({
    bool? enabled,
    PermissionPolicy? permissionPolicy,
    List<String>? allowedDomains,
    List<String>? blockedDomains,
    ManagedAgentsUserLocation? userLocation,
  }) => WebSearchToolConfigParams(
    enabled: enabled,
    permissionPolicy: permissionPolicy,
    allowedDomains: allowedDomains,
    blockedDomains: blockedDomains,
    userLocation: userLocation,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Configuration override for the `bash` tool (request variant).
@immutable
class BashToolConfigParams extends AgentToolConfigParams {
  @override
  final AgentToolName name;

  @override
  final bool? enabled;

  @override
  final PermissionPolicy? permissionPolicy;

  /// Creates a [BashToolConfigParams].
  const BashToolConfigParams({
    this.name = AgentToolName.bash,
    this.enabled,
    this.permissionPolicy,
  });

  /// Creates a [BashToolConfigParams] from JSON.
  factory BashToolConfigParams.fromJson(Map<String, dynamic> json) {
    return BashToolConfigParams(
      enabled: json['enabled'] as bool?,
      permissionPolicy: json['permission_policy'] != null
          ? PermissionPolicy.fromJson(
              json['permission_policy'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'bash',
    'name': name.toJson(),
    if (enabled != null) 'enabled': enabled,
    if (permissionPolicy != null)
      'permission_policy': permissionPolicy!.toJson(),
  };

  /// Creates a copy with replaced values.
  BashToolConfigParams copyWith({
    Object? enabled = unsetCopyWithValue,
    Object? permissionPolicy = unsetCopyWithValue,
  }) {
    return BashToolConfigParams(
      enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
      permissionPolicy: permissionPolicy == unsetCopyWithValue
          ? this.permissionPolicy
          : permissionPolicy as PermissionPolicy?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BashToolConfigParams &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(name, enabled, permissionPolicy);

  @override
  String toString() =>
      'BashToolConfigParams(enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
}

/// Configuration override for the `edit` tool (request variant).
@immutable
class EditToolConfigParams extends AgentToolConfigParams {
  @override
  final AgentToolName name;

  @override
  final bool? enabled;

  @override
  final PermissionPolicy? permissionPolicy;

  /// Creates an [EditToolConfigParams].
  const EditToolConfigParams({
    this.name = AgentToolName.edit,
    this.enabled,
    this.permissionPolicy,
  });

  /// Creates an [EditToolConfigParams] from JSON.
  factory EditToolConfigParams.fromJson(Map<String, dynamic> json) {
    return EditToolConfigParams(
      enabled: json['enabled'] as bool?,
      permissionPolicy: json['permission_policy'] != null
          ? PermissionPolicy.fromJson(
              json['permission_policy'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'edit',
    'name': name.toJson(),
    if (enabled != null) 'enabled': enabled,
    if (permissionPolicy != null)
      'permission_policy': permissionPolicy!.toJson(),
  };

  /// Creates a copy with replaced values.
  EditToolConfigParams copyWith({
    Object? enabled = unsetCopyWithValue,
    Object? permissionPolicy = unsetCopyWithValue,
  }) {
    return EditToolConfigParams(
      enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
      permissionPolicy: permissionPolicy == unsetCopyWithValue
          ? this.permissionPolicy
          : permissionPolicy as PermissionPolicy?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditToolConfigParams &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(name, enabled, permissionPolicy);

  @override
  String toString() =>
      'EditToolConfigParams(enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
}

/// Configuration override for the `read` tool (request variant).
@immutable
class ReadToolConfigParams extends AgentToolConfigParams {
  @override
  final AgentToolName name;

  @override
  final bool? enabled;

  @override
  final PermissionPolicy? permissionPolicy;

  /// Creates a [ReadToolConfigParams].
  const ReadToolConfigParams({
    this.name = AgentToolName.read,
    this.enabled,
    this.permissionPolicy,
  });

  /// Creates a [ReadToolConfigParams] from JSON.
  factory ReadToolConfigParams.fromJson(Map<String, dynamic> json) {
    return ReadToolConfigParams(
      enabled: json['enabled'] as bool?,
      permissionPolicy: json['permission_policy'] != null
          ? PermissionPolicy.fromJson(
              json['permission_policy'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'read',
    'name': name.toJson(),
    if (enabled != null) 'enabled': enabled,
    if (permissionPolicy != null)
      'permission_policy': permissionPolicy!.toJson(),
  };

  /// Creates a copy with replaced values.
  ReadToolConfigParams copyWith({
    Object? enabled = unsetCopyWithValue,
    Object? permissionPolicy = unsetCopyWithValue,
  }) {
    return ReadToolConfigParams(
      enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
      permissionPolicy: permissionPolicy == unsetCopyWithValue
          ? this.permissionPolicy
          : permissionPolicy as PermissionPolicy?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadToolConfigParams &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(name, enabled, permissionPolicy);

  @override
  String toString() =>
      'ReadToolConfigParams(enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
}

/// Configuration override for the `write` tool (request variant).
@immutable
class WriteToolConfigParams extends AgentToolConfigParams {
  @override
  final AgentToolName name;

  @override
  final bool? enabled;

  @override
  final PermissionPolicy? permissionPolicy;

  /// Creates a [WriteToolConfigParams].
  const WriteToolConfigParams({
    this.name = AgentToolName.write,
    this.enabled,
    this.permissionPolicy,
  });

  /// Creates a [WriteToolConfigParams] from JSON.
  factory WriteToolConfigParams.fromJson(Map<String, dynamic> json) {
    return WriteToolConfigParams(
      enabled: json['enabled'] as bool?,
      permissionPolicy: json['permission_policy'] != null
          ? PermissionPolicy.fromJson(
              json['permission_policy'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'write',
    'name': name.toJson(),
    if (enabled != null) 'enabled': enabled,
    if (permissionPolicy != null)
      'permission_policy': permissionPolicy!.toJson(),
  };

  /// Creates a copy with replaced values.
  WriteToolConfigParams copyWith({
    Object? enabled = unsetCopyWithValue,
    Object? permissionPolicy = unsetCopyWithValue,
  }) {
    return WriteToolConfigParams(
      enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
      permissionPolicy: permissionPolicy == unsetCopyWithValue
          ? this.permissionPolicy
          : permissionPolicy as PermissionPolicy?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WriteToolConfigParams &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(name, enabled, permissionPolicy);

  @override
  String toString() =>
      'WriteToolConfigParams(enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
}

/// Configuration override for the `glob` tool (request variant).
@immutable
class GlobToolConfigParams extends AgentToolConfigParams {
  @override
  final AgentToolName name;

  @override
  final bool? enabled;

  @override
  final PermissionPolicy? permissionPolicy;

  /// Creates a [GlobToolConfigParams].
  const GlobToolConfigParams({
    this.name = AgentToolName.glob,
    this.enabled,
    this.permissionPolicy,
  });

  /// Creates a [GlobToolConfigParams] from JSON.
  factory GlobToolConfigParams.fromJson(Map<String, dynamic> json) {
    return GlobToolConfigParams(
      enabled: json['enabled'] as bool?,
      permissionPolicy: json['permission_policy'] != null
          ? PermissionPolicy.fromJson(
              json['permission_policy'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'glob',
    'name': name.toJson(),
    if (enabled != null) 'enabled': enabled,
    if (permissionPolicy != null)
      'permission_policy': permissionPolicy!.toJson(),
  };

  /// Creates a copy with replaced values.
  GlobToolConfigParams copyWith({
    Object? enabled = unsetCopyWithValue,
    Object? permissionPolicy = unsetCopyWithValue,
  }) {
    return GlobToolConfigParams(
      enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
      permissionPolicy: permissionPolicy == unsetCopyWithValue
          ? this.permissionPolicy
          : permissionPolicy as PermissionPolicy?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlobToolConfigParams &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(name, enabled, permissionPolicy);

  @override
  String toString() =>
      'GlobToolConfigParams(enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
}

/// Configuration override for the `grep` tool (request variant).
@immutable
class GrepToolConfigParams extends AgentToolConfigParams {
  @override
  final AgentToolName name;

  @override
  final bool? enabled;

  @override
  final PermissionPolicy? permissionPolicy;

  /// Creates a [GrepToolConfigParams].
  const GrepToolConfigParams({
    this.name = AgentToolName.grep,
    this.enabled,
    this.permissionPolicy,
  });

  /// Creates a [GrepToolConfigParams] from JSON.
  factory GrepToolConfigParams.fromJson(Map<String, dynamic> json) {
    return GrepToolConfigParams(
      enabled: json['enabled'] as bool?,
      permissionPolicy: json['permission_policy'] != null
          ? PermissionPolicy.fromJson(
              json['permission_policy'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'grep',
    'name': name.toJson(),
    if (enabled != null) 'enabled': enabled,
    if (permissionPolicy != null)
      'permission_policy': permissionPolicy!.toJson(),
  };

  /// Creates a copy with replaced values.
  GrepToolConfigParams copyWith({
    Object? enabled = unsetCopyWithValue,
    Object? permissionPolicy = unsetCopyWithValue,
  }) {
    return GrepToolConfigParams(
      enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
      permissionPolicy: permissionPolicy == unsetCopyWithValue
          ? this.permissionPolicy
          : permissionPolicy as PermissionPolicy?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrepToolConfigParams &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(name, enabled, permissionPolicy);

  @override
  String toString() =>
      'GrepToolConfigParams(enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
}

/// Configuration override for the `web_fetch` tool (request variant).
@immutable
class WebFetchToolConfigParams extends AgentToolConfigParams {
  @override
  final AgentToolName name;

  @override
  final bool? enabled;

  @override
  final PermissionPolicy? permissionPolicy;

  /// Only fetch URLs whose host is one of these domains or a subdomain of
  /// one. At most 64 entries; an empty list is rejected (omit the field
  /// instead). Mutually exclusive with [blockedDomains].
  final List<String>? allowedDomains;

  /// Never fetch URLs whose host is one of these domains or a subdomain of
  /// one. At most 64 entries; an empty list is rejected (omit the field
  /// instead). Mutually exclusive with [allowedDomains].
  final List<String>? blockedDomains;

  /// Maximum number of tokens of fetched text content to include in context
  /// per call. Does not apply to binary content such as PDFs.
  final int? maxContentTokens;

  /// Creates a [WebFetchToolConfigParams].
  const WebFetchToolConfigParams({
    this.name = AgentToolName.webFetch,
    this.enabled,
    this.permissionPolicy,
    this.allowedDomains,
    this.blockedDomains,
    this.maxContentTokens,
  });

  /// Creates a [WebFetchToolConfigParams] from JSON.
  factory WebFetchToolConfigParams.fromJson(Map<String, dynamic> json) {
    return WebFetchToolConfigParams(
      enabled: json['enabled'] as bool?,
      permissionPolicy: json['permission_policy'] != null
          ? PermissionPolicy.fromJson(
              json['permission_policy'] as Map<String, dynamic>,
            )
          : null,
      allowedDomains: (json['allowed_domains'] as List?)
          ?.map((e) => e as String)
          .toList(),
      blockedDomains: (json['blocked_domains'] as List?)
          ?.map((e) => e as String)
          .toList(),
      maxContentTokens: json['max_content_tokens'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'web_fetch',
    'name': name.toJson(),
    if (enabled != null) 'enabled': enabled,
    if (permissionPolicy != null)
      'permission_policy': permissionPolicy!.toJson(),
    if (allowedDomains != null) 'allowed_domains': allowedDomains,
    if (blockedDomains != null) 'blocked_domains': blockedDomains,
    if (maxContentTokens != null) 'max_content_tokens': maxContentTokens,
  };

  /// Creates a copy with replaced values.
  WebFetchToolConfigParams copyWith({
    Object? enabled = unsetCopyWithValue,
    Object? permissionPolicy = unsetCopyWithValue,
    Object? allowedDomains = unsetCopyWithValue,
    Object? blockedDomains = unsetCopyWithValue,
    Object? maxContentTokens = unsetCopyWithValue,
  }) {
    return WebFetchToolConfigParams(
      enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
      permissionPolicy: permissionPolicy == unsetCopyWithValue
          ? this.permissionPolicy
          : permissionPolicy as PermissionPolicy?,
      allowedDomains: allowedDomains == unsetCopyWithValue
          ? this.allowedDomains
          : allowedDomains as List<String>?,
      blockedDomains: blockedDomains == unsetCopyWithValue
          ? this.blockedDomains
          : blockedDomains as List<String>?,
      maxContentTokens: maxContentTokens == unsetCopyWithValue
          ? this.maxContentTokens
          : maxContentTokens as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebFetchToolConfigParams &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy &&
          listsEqual(allowedDomains, other.allowedDomains) &&
          listsEqual(blockedDomains, other.blockedDomains) &&
          maxContentTokens == other.maxContentTokens;

  @override
  int get hashCode => Object.hash(
    name,
    enabled,
    permissionPolicy,
    listHash(allowedDomains),
    listHash(blockedDomains),
    maxContentTokens,
  );

  @override
  String toString() =>
      'WebFetchToolConfigParams('
      'enabled: $enabled, permissionPolicy: $permissionPolicy, '
      'allowedDomains: $allowedDomains, blockedDomains: $blockedDomains, '
      'maxContentTokens: $maxContentTokens)';
}

/// Configuration override for the `web_search` tool (request variant).
@immutable
class WebSearchToolConfigParams extends AgentToolConfigParams {
  @override
  final AgentToolName name;

  @override
  final bool? enabled;

  @override
  final PermissionPolicy? permissionPolicy;

  /// Only return search results whose host is one of these domains or a
  /// subdomain of one. At most 64 entries; an empty list is rejected (omit
  /// the field instead). Mutually exclusive with [blockedDomains].
  final List<String>? allowedDomains;

  /// Never return search results whose host is one of these domains or a
  /// subdomain of one. At most 64 entries; an empty list is rejected (omit
  /// the field instead). Mutually exclusive with [allowedDomains].
  final List<String>? blockedDomains;

  /// Approximate user location for search result localization.
  final ManagedAgentsUserLocation? userLocation;

  /// Creates a [WebSearchToolConfigParams].
  const WebSearchToolConfigParams({
    this.name = AgentToolName.webSearch,
    this.enabled,
    this.permissionPolicy,
    this.allowedDomains,
    this.blockedDomains,
    this.userLocation,
  });

  /// Creates a [WebSearchToolConfigParams] from JSON.
  factory WebSearchToolConfigParams.fromJson(Map<String, dynamic> json) {
    return WebSearchToolConfigParams(
      enabled: json['enabled'] as bool?,
      permissionPolicy: json['permission_policy'] != null
          ? PermissionPolicy.fromJson(
              json['permission_policy'] as Map<String, dynamic>,
            )
          : null,
      allowedDomains: (json['allowed_domains'] as List?)
          ?.map((e) => e as String)
          .toList(),
      blockedDomains: (json['blocked_domains'] as List?)
          ?.map((e) => e as String)
          .toList(),
      userLocation: json['user_location'] != null
          ? ManagedAgentsUserLocation.fromJson(
              json['user_location'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'web_search',
    'name': name.toJson(),
    if (enabled != null) 'enabled': enabled,
    if (permissionPolicy != null)
      'permission_policy': permissionPolicy!.toJson(),
    if (allowedDomains != null) 'allowed_domains': allowedDomains,
    if (blockedDomains != null) 'blocked_domains': blockedDomains,
    if (userLocation != null) 'user_location': userLocation!.toJson(),
  };

  /// Creates a copy with replaced values.
  WebSearchToolConfigParams copyWith({
    Object? enabled = unsetCopyWithValue,
    Object? permissionPolicy = unsetCopyWithValue,
    Object? allowedDomains = unsetCopyWithValue,
    Object? blockedDomains = unsetCopyWithValue,
    Object? userLocation = unsetCopyWithValue,
  }) {
    return WebSearchToolConfigParams(
      enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
      permissionPolicy: permissionPolicy == unsetCopyWithValue
          ? this.permissionPolicy
          : permissionPolicy as PermissionPolicy?,
      allowedDomains: allowedDomains == unsetCopyWithValue
          ? this.allowedDomains
          : allowedDomains as List<String>?,
      blockedDomains: blockedDomains == unsetCopyWithValue
          ? this.blockedDomains
          : blockedDomains as List<String>?,
      userLocation: userLocation == unsetCopyWithValue
          ? this.userLocation
          : userLocation as ManagedAgentsUserLocation?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchToolConfigParams &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy &&
          listsEqual(allowedDomains, other.allowedDomains) &&
          listsEqual(blockedDomains, other.blockedDomains) &&
          userLocation == other.userLocation;

  @override
  int get hashCode => Object.hash(
    name,
    enabled,
    permissionPolicy,
    listHash(allowedDomains),
    listHash(blockedDomains),
    userLocation,
  );

  @override
  String toString() =>
      'WebSearchToolConfigParams('
      'enabled: $enabled, permissionPolicy: $permissionPolicy, '
      'allowedDomains: $allowedDomains, blockedDomains: $blockedDomains, '
      'userLocation: $userLocation)';
}

/// Unrecognised agent tool config params type — preserves the raw JSON.
@immutable
class UnknownAgentToolConfigParams extends AgentToolConfigParams {
  /// The unrecognised type discriminator (from `type`, falling back to
  /// `name`).
  final String? rawType;

  /// The raw JSON map.
  final Map<String, dynamic> raw;

  const UnknownAgentToolConfigParams._({
    required this.rawType,
    required this.raw,
  });

  @override
  AgentToolName get name =>
      AgentToolName.fromJson(raw['name'] as String? ?? '');

  @override
  bool? get enabled => raw['enabled'] as bool?;

  @override
  PermissionPolicy? get permissionPolicy => raw['permission_policy'] != null
      ? PermissionPolicy.fromJson(
          raw['permission_policy'] as Map<String, dynamic>,
        )
      : null;

  @override
  Map<String, dynamic> toJson() => raw;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownAgentToolConfigParams &&
          runtimeType == other.runtimeType &&
          rawType == other.rawType &&
          mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => Object.hash(rawType, mapDeepHashCode(raw));

  @override
  String toString() =>
      'UnknownAgentToolConfigParams(rawType: $rawType, raw: $raw)';
}

/// Configuration override for a specific MCP tool (request variant).
@immutable
class MCPToolConfigParams {
  /// The tool name.
  final String name;

  /// Whether this tool is enabled.
  final bool? enabled;

  /// Permission policy for this tool.
  final PermissionPolicy? permissionPolicy;

  /// Creates an [MCPToolConfigParams].
  const MCPToolConfigParams({
    required this.name,
    this.enabled,
    this.permissionPolicy,
  });

  /// Creates an [MCPToolConfigParams] from JSON.
  factory MCPToolConfigParams.fromJson(Map<String, dynamic> json) {
    return MCPToolConfigParams(
      name: json['name'] as String,
      enabled: json['enabled'] as bool?,
      permissionPolicy: json['permission_policy'] != null
          ? PermissionPolicy.fromJson(
              json['permission_policy'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (enabled != null) 'enabled': enabled,
    if (permissionPolicy != null)
      'permission_policy': permissionPolicy!.toJson(),
  };

  /// Creates a copy with replaced values.
  MCPToolConfigParams copyWith({
    String? name,
    Object? enabled = unsetCopyWithValue,
    Object? permissionPolicy = unsetCopyWithValue,
  }) {
    return MCPToolConfigParams(
      name: name ?? this.name,
      enabled: enabled == unsetCopyWithValue ? this.enabled : enabled as bool?,
      permissionPolicy: permissionPolicy == unsetCopyWithValue
          ? this.permissionPolicy
          : permissionPolicy as PermissionPolicy?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCPToolConfigParams &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(name, enabled, permissionPolicy);

  @override
  String toString() =>
      'MCPToolConfigParams('
      'name: $name, enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
}

// ---------------------------------------------------------------------------
// CustomToolInputSchema
// ---------------------------------------------------------------------------

/// JSON Schema for custom tool input parameters.
@immutable
class CustomToolInputSchema {
  /// Schema type — always "object".
  final String type;

  /// JSON Schema properties defining the tool's input parameters.
  final Map<String, dynamic>? properties;

  /// List of required property names.
  final List<String>? required;

  /// Additional JSON Schema keywords beyond `type`, `properties`, and
  /// `required` (the schema is open: `additionalProperties: true`).
  final Map<String, dynamic>? extra;

  /// Creates a [CustomToolInputSchema].
  const CustomToolInputSchema({
    this.type = 'object',
    this.properties,
    this.required,
    this.extra,
  });

  /// JSON keys backed by a declared, typed field on this class.
  static const _knownKeys = {'type', 'properties', 'required'};

  /// Creates a [CustomToolInputSchema] from JSON.
  factory CustomToolInputSchema.fromJson(Map<String, dynamic> json) {
    final extraEntries = {
      for (final entry in json.entries)
        if (!_knownKeys.contains(entry.key)) entry.key: entry.value,
    };
    return CustomToolInputSchema(
      type: json['type'] as String? ?? 'object',
      properties: json['properties'] != null
          ? Map<String, dynamic>.from(json['properties'] as Map)
          : null,
      required: (json['required'] as List?)?.cast<String>(),
      extra: extraEntries.isEmpty ? null : extraEntries,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    // Spread only undeclared keys so `extra` can never emit or override a
    // declared field.
    if (extra != null)
      for (final entry in extra!.entries)
        if (!_knownKeys.contains(entry.key)) entry.key: entry.value,
    'type': type,
    if (properties != null) 'properties': properties,
    if (required != null) 'required': required,
  };

  /// Creates a copy with replaced values.
  CustomToolInputSchema copyWith({
    String? type,
    Object? properties = unsetCopyWithValue,
    Object? required = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) {
    return CustomToolInputSchema(
      type: type ?? this.type,
      properties: properties == unsetCopyWithValue
          ? this.properties
          : properties as Map<String, dynamic>?,
      required: required == unsetCopyWithValue
          ? this.required
          : required as List<String>?,
      extra: extra == unsetCopyWithValue
          ? this.extra
          : extra as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomToolInputSchema &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mapsDeepEqual(properties, other.properties) &&
          listsEqual(required, other.required) &&
          mapsDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hash(
    type,
    mapDeepHashCode(properties),
    listHash(required),
    mapDeepHashCode(extra),
  );

  @override
  String toString() =>
      'CustomToolInputSchema('
      'type: $type, properties: $properties, required: $required, '
      'extra: $extra)';
}
