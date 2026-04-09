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

/// Configuration for a specific agent tool (response variant).
@immutable
class AgentToolConfig {
  /// The tool name.
  final AgentToolName name;

  /// Whether this tool is enabled.
  final bool enabled;

  /// Permission policy for this tool.
  final PermissionPolicy permissionPolicy;

  /// Creates an [AgentToolConfig].
  const AgentToolConfig({
    required this.name,
    required this.enabled,
    required this.permissionPolicy,
  });

  /// Creates an [AgentToolConfig] from JSON.
  factory AgentToolConfig.fromJson(Map<String, dynamic> json) {
    return AgentToolConfig(
      name: AgentToolName.fromJson(json['name'] as String),
      enabled: json['enabled'] as bool,
      permissionPolicy: PermissionPolicy.fromJson(
        json['permission_policy'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name.toJson(),
    'enabled': enabled,
    'permission_policy': permissionPolicy.toJson(),
  };

  /// Creates a copy with replaced values.
  AgentToolConfig copyWith({
    AgentToolName? name,
    bool? enabled,
    PermissionPolicy? permissionPolicy,
  }) {
    return AgentToolConfig(
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      permissionPolicy: permissionPolicy ?? this.permissionPolicy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentToolConfig &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(name, enabled, permissionPolicy);

  @override
  String toString() =>
      'AgentToolConfig('
      'name: $name, enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
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

/// Configuration override for a specific agent tool (request variant).
@immutable
class AgentToolConfigParams {
  /// The tool name.
  final AgentToolName name;

  /// Whether this tool is enabled.
  final bool? enabled;

  /// Permission policy for this tool.
  final PermissionPolicy? permissionPolicy;

  /// Creates an [AgentToolConfigParams].
  const AgentToolConfigParams({
    required this.name,
    this.enabled,
    this.permissionPolicy,
  });

  /// Creates an [AgentToolConfigParams] from JSON.
  factory AgentToolConfigParams.fromJson(Map<String, dynamic> json) {
    return AgentToolConfigParams(
      name: AgentToolName.fromJson(json['name'] as String),
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
    'name': name.toJson(),
    if (enabled != null) 'enabled': enabled,
    if (permissionPolicy != null)
      'permission_policy': permissionPolicy!.toJson(),
  };

  /// Creates a copy with replaced values.
  AgentToolConfigParams copyWith({
    AgentToolName? name,
    Object? enabled = unsetCopyWithValue,
    Object? permissionPolicy = unsetCopyWithValue,
  }) {
    return AgentToolConfigParams(
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
      other is AgentToolConfigParams &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          enabled == other.enabled &&
          permissionPolicy == other.permissionPolicy;

  @override
  int get hashCode => Object.hash(name, enabled, permissionPolicy);

  @override
  String toString() =>
      'AgentToolConfigParams('
      'name: $name, enabled: $enabled, '
      'permissionPolicy: $permissionPolicy)';
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

  /// Creates a [CustomToolInputSchema].
  const CustomToolInputSchema({
    this.type = 'object',
    this.properties,
    this.required,
  });

  /// Creates a [CustomToolInputSchema] from JSON.
  factory CustomToolInputSchema.fromJson(Map<String, dynamic> json) {
    return CustomToolInputSchema(
      type: json['type'] as String? ?? 'object',
      properties: json['properties'] != null
          ? Map<String, dynamic>.from(json['properties'] as Map)
          : null,
      required: (json['required'] as List?)?.cast<String>(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (properties != null) 'properties': properties,
    if (required != null) 'required': required,
  };

  /// Creates a copy with replaced values.
  CustomToolInputSchema copyWith({
    String? type,
    Object? properties = unsetCopyWithValue,
    Object? required = unsetCopyWithValue,
  }) {
    return CustomToolInputSchema(
      type: type ?? this.type,
      properties: properties == unsetCopyWithValue
          ? this.properties
          : properties as Map<String, dynamic>?,
      required: required == unsetCopyWithValue
          ? this.required
          : required as List<String>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomToolInputSchema &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mapsDeepEqual(properties, other.properties) &&
          listsEqual(required, other.required);

  @override
  int get hashCode =>
      Object.hash(type, mapDeepHashCode(properties), listHash(required));

  @override
  String toString() =>
      'CustomToolInputSchema('
      'type: $type, properties: $properties, required: $required)';
}
