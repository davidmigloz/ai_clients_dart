part of 'agent_session_models.dart';

/// A tool available to the agent.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionTool extends AgentJsonModel {
  const AgentSessionTool();

  /// Parses a known contract or detached future received value.
  factory AgentSessionTool.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(json['type'], 'AgentSessionTool.type')) {
      'computer_use' => AgentSessionComputerUseTool.fromJson(json),
      'function' => AgentSessionFunctionTool.fromJson(json),
      'mcp' => AgentSessionMcpTool.fromJson(json),
      'programmatic_tool_calling' =>
        AgentSessionProgrammaticToolCallingTool.fromJson(json),
      'tool_search' => AgentSessionToolSearchTool.fromJson(json),
      'web_search' => AgentSessionWebSearchTool.fromJson(json),
      _ => UnknownAgentSessionTool.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `computer_use` contract.
  factory AgentSessionTool.computerUse({bool? includeScreenshots}) =
      AgentSessionComputerUseTool;

  /// Builds the `function` contract.
  factory AgentSessionTool.function({
    bool? deferLoading,
    required String description,
    required String name,
    required Map<String, dynamic> parameters,
  }) = AgentSessionFunctionTool;

  /// Builds the `mcp` contract.
  factory AgentSessionTool.mcp({
    List<String>? allowedTools,
    bool clearAllowedTools,
    AgentMcpConnectionOriginParam? connectionOrigin,
    bool clearConnectionOrigin,
    String? credentialId,
    bool clearCredentialId,
    Map<String, dynamic>? requestMetadata,
    bool clearRequestMetadata,
    bool? required,
    required String serverLabel,
    required AgentSessionMcpTransport transport,
  }) = AgentSessionMcpTool;

  /// Builds the `programmatic_tool_calling` contract.
  factory AgentSessionTool.programmaticToolCalling({bool? enabled}) =
      AgentSessionProgrammaticToolCallingTool;

  /// Builds the `tool_search` contract.
  factory AgentSessionTool.toolSearch() = AgentSessionToolSearchTool;

  /// Builds the `web_search` contract.
  factory AgentSessionTool.webSearch({
    List<String>? allowedDomains,
    bool clearAllowedDomains,
    AgentWebSearchContextSizeParam? contextSize,
    bool clearContextSize,
    AgentWebSearchLocation? location,
    bool clearLocation,
    AgentWebSearchModeParam? mode,
    bool clearMode,
  }) = AgentSessionWebSearchTool;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionTool extends AgentSessionTool {
  const UnknownAgentSessionTool._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionTool.fromJson(Map<String, dynamic> json) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionTool.type',
    );
    if (const [
      'computer_use',
      'function',
      'mcp',
      'programmatic_tool_calling',
      'tool_search',
      'web_search',
    ].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionTool: expected a future discriminator',
      );
    }
    return UnknownAgentSessionTool._(
      snapshotAgentJson(json, 'UnknownAgentSessionTool'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionTool copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentSessionTool.fromJson(rawJson ?? this.rawJson);
  @override
  void validate() => throw const FormatException(
    'UnknownAgentSessionTool: future input is not writable',
  );
}

/// Browser use in an OpenAI-hosted session.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionComputerUseTool extends AgentSessionTool {
  /// Creates a validated [AgentSessionComputerUseTool].
  AgentSessionComputerUseTool({this.includeScreenshots}) {
    validate();
  }

  /// Whether computer tool outputs include screenshots. Defaults to `false`.
  final bool? includeScreenshots;

  /// The type of the object. Always `computer_use`.
  @override
  String get type => 'computer_use';

  /// Parses [AgentSessionComputerUseTool] with contextual, payload-free errors.
  factory AgentSessionComputerUseTool.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'include_screenshots',
      'type',
    ], 'AgentSessionComputerUseTool');
    requireAgentTag(
      json,
      'type',
      'computer_use',
      'AgentSessionComputerUseTool',
    );
    return AgentSessionComputerUseTool(
      includeScreenshots: optionalAgentValue(
        json,
        'include_screenshots',
        'AgentSessionComputerUseTool.includeScreenshots',
        requireAgentBool,
        nullable: false,
      ),
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {
    'include_screenshots': ?includeScreenshots,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionComputerUseTool copyWith({
    Object? includeScreenshots = unsetCopyWithValue,
  }) => AgentSessionComputerUseTool(
    includeScreenshots: copyAgentValue<bool>(
      includeScreenshots,
      this.includeScreenshots,
      'AgentSessionComputerUseTool.includeScreenshots',
    ),
  );
}

/// A function defined by the application.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionFunctionTool extends AgentSessionTool {
  /// Creates a validated [AgentSessionFunctionTool].
  AgentSessionFunctionTool({
    this.deferLoading,
    required this.description,
    required this.name,
    required Map<String, dynamic> parameters,
  }) : parameters = snapshotAgentJson(
         parameters,
         'AgentSessionFunctionTool.parameters',
       ) {
    validate();
  }

  /// Whether this function is deferred and discovered through tool search. Defaults to `false`.
  final bool? deferLoading;

  /// A description of what the function does.
  final String description;

  /// The name of the function.
  final String name;

  /// A JSON Schema object describing the function's arguments.
  final Map<String, dynamic> parameters;

  /// The type of the object. Always `function`.
  @override
  String get type => 'function';

  /// Parses [AgentSessionFunctionTool] with contextual, payload-free errors.
  factory AgentSessionFunctionTool.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'defer_loading',
      'description',
      'name',
      'parameters',
      'type',
    ], 'AgentSessionFunctionTool');
    requireAgentTag(json, 'type', 'function', 'AgentSessionFunctionTool');
    return AgentSessionFunctionTool(
      deferLoading: optionalAgentValue(
        json,
        'defer_loading',
        'AgentSessionFunctionTool.deferLoading',
        requireAgentBool,
        nullable: false,
      ),
      description: requiredAgentValue(
        json,
        'description',
        'AgentSessionFunctionTool.description',
        requireAgentString,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentSessionFunctionTool.name',
        requireAgentString,
        nullable: false,
      )!,
      parameters: requiredAgentValue(
        json,
        'parameters',
        'AgentSessionFunctionTool.parameters',
        requireAgentObject,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      description,
      'AgentSessionFunctionTool.description',
      min: 0,
      max: 1048576,
    );
    validateAgentLength(
      name,
      'AgentSessionFunctionTool.name',
      min: 0,
      max: 1048576,
    );
    validateAgentCount(
      parameters.length,
      'AgentSessionFunctionTool.parameters',
      min: 0,
      max: 1024,
    );
    for (final key in parameters.keys) {
      validateAgentLength(
        key,
        'AgentSessionFunctionTool.parameters',
        min: 1,
        max: 256,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'defer_loading': ?deferLoading,
    'description': description,
    'name': name,
    'parameters': parameters,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionFunctionTool copyWith({
    Object? deferLoading = unsetCopyWithValue,
    String? description,
    String? name,
    Map<String, dynamic>? parameters,
  }) => AgentSessionFunctionTool(
    deferLoading: copyAgentValue<bool>(
      deferLoading,
      this.deferLoading,
      'AgentSessionFunctionTool.deferLoading',
    ),
    description: description ?? this.description,
    name: name ?? this.name,
    parameters: parameters ?? this.parameters,
  );
}

/// Tools provided by a remote MCP server.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionMcpTool extends AgentSessionTool {
  /// Creates a validated [AgentSessionMcpTool].
  AgentSessionMcpTool({
    List<String>? allowedTools,
    bool clearAllowedTools = false,
    AgentMcpConnectionOriginParam? connectionOrigin,
    bool clearConnectionOrigin = false,
    String? credentialId,
    bool clearCredentialId = false,
    Map<String, dynamic>? requestMetadata,
    bool clearRequestMetadata = false,
    this.required,
    required this.serverLabel,
    required this.transport,
  }) : clearAllowedTools = clearAllowedTools,
       allowedTools = ownAgentValue<List<String>>(
         clearAllowedTools ? null : allowedTools,
         List.unmodifiable,
       ),
       clearConnectionOrigin = clearConnectionOrigin,
       connectionOrigin = clearConnectionOrigin ? null : connectionOrigin,
       clearCredentialId = clearCredentialId,
       credentialId = clearCredentialId ? null : credentialId,
       clearRequestMetadata = clearRequestMetadata,
       requestMetadata = ownAgentValue<Map<String, dynamic>>(
         clearRequestMetadata ? null : requestMetadata,
         (value) =>
             snapshotAgentJson(value, 'AgentSessionMcpTool.requestMetadata'),
       ) {
    validate();
  }

  /// The MCP tools the agent may call. All server tools are allowed when omitted.
  final List<String>? allowedTools;

  /// Sends `allowed_tools: null`, rather than omitting it.
  final bool clearAllowedTools;

  /// Selects where outbound MCP HTTP connections originate. Omitted or `service` uses the Managed Agents service network; `environment` uses the session's selected environment.
  final AgentMcpConnectionOriginParam? connectionOrigin;

  /// Sends `connection_origin: null`, rather than omitting it.
  final bool clearConnectionOrigin;

  /// The attached vault credential used to authenticate this MCP server. Optional when exactly one attached credential matches the server URL.
  final String? credentialId;

  /// Sends `credential_id: null`, rather than omitting it.
  final bool clearCredentialId;

  /// Metadata included with requests to this MCP server.
  final Map<String, dynamic>? requestMetadata;

  /// Sends `request_metadata: null`, rather than omitting it.
  final bool clearRequestMetadata;

  /// Whether this MCP server must initialize before the first turn. Defaults to `false`.
  final bool? required;

  /// A label used to identify the MCP server in tool calls.
  final String serverLabel;

  /// The transport used to connect to the MCP server.
  final AgentSessionMcpTransport transport;

  /// The type of the object. Always `mcp`.
  @override
  String get type => 'mcp';

  /// Parses [AgentSessionMcpTool] with contextual, payload-free errors.
  factory AgentSessionMcpTool.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'allowed_tools',
      'connection_origin',
      'credential_id',
      'request_metadata',
      'required',
      'server_label',
      'transport',
      'type',
    ], 'AgentSessionMcpTool');
    requireAgentTag(json, 'type', 'mcp', 'AgentSessionMcpTool');
    return AgentSessionMcpTool(
      allowedTools: optionalAgentValue(
        json,
        'allowed_tools',
        'AgentSessionMcpTool.allowedTools',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      clearAllowedTools:
          json.containsKey('allowed_tools') && json['allowed_tools'] == null,
      connectionOrigin: optionalAgentValue(
        json,
        'connection_origin',
        'AgentSessionMcpTool.connectionOrigin',
        (value, context) => AgentMcpConnectionOriginParam.fromJson(value),
        nullable: true,
      ),
      clearConnectionOrigin:
          json.containsKey('connection_origin') &&
          json['connection_origin'] == null,
      credentialId: optionalAgentValue(
        json,
        'credential_id',
        'AgentSessionMcpTool.credentialId',
        requireAgentString,
        nullable: true,
      ),
      clearCredentialId:
          json.containsKey('credential_id') && json['credential_id'] == null,
      requestMetadata: optionalAgentValue(
        json,
        'request_metadata',
        'AgentSessionMcpTool.requestMetadata',
        requireAgentObject,
        nullable: true,
      ),
      clearRequestMetadata:
          json.containsKey('request_metadata') &&
          json['request_metadata'] == null,
      required: optionalAgentValue(
        json,
        'required',
        'AgentSessionMcpTool.required',
        requireAgentBool,
        nullable: false,
      ),
      serverLabel: requiredAgentValue(
        json,
        'server_label',
        'AgentSessionMcpTool.serverLabel',
        requireAgentString,
        nullable: false,
      )!,
      transport: requiredAgentValue(
        json,
        'transport',
        'AgentSessionMcpTool.transport',
        (value, context) => AgentSessionMcpTransport.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    if (allowedTools != null) {
      validateAgentCount(
        allowedTools!.length,
        'AgentSessionMcpTool.allowedTools',
        min: 0,
        max: 16384,
      );
      for (final item in allowedTools!) {
        validateAgentLength(
          item,
          'AgentSessionMcpTool.allowedTools',
          min: 0,
          max: 1048576,
        );
      }
    }
    if (connectionOrigin != null) {
      validateAgentEnum(connectionOrigin!.value, [
        'service',
        'environment',
      ], 'AgentSessionMcpTool.connectionOrigin');
    }
    if (credentialId != null) {
      validateAgentLength(
        credentialId!,
        'AgentSessionMcpTool.credentialId',
        min: 0,
        max: 1048576,
      );
    }
    if (requestMetadata != null) {
      validateAgentCount(
        requestMetadata!.length,
        'AgentSessionMcpTool.requestMetadata',
        min: 0,
        max: 1024,
      );
      for (final key in requestMetadata!.keys) {
        validateAgentLength(
          key,
          'AgentSessionMcpTool.requestMetadata',
          min: 1,
          max: 256,
        );
      }
    }
    validateAgentLength(
      serverLabel,
      'AgentSessionMcpTool.serverLabel',
      min: 0,
      max: 1048576,
    );
    transport.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearAllowedTools)
      'allowed_tools': null
    else if (allowedTools != null)
      'allowed_tools': allowedTools!.map((value) => value).toList(),
    if (clearConnectionOrigin)
      'connection_origin': null
    else if (connectionOrigin != null)
      'connection_origin': connectionOrigin!.toJson(),
    if (clearCredentialId)
      'credential_id': null
    else
      'credential_id': ?credentialId,
    if (clearRequestMetadata)
      'request_metadata': null
    else
      'request_metadata': ?requestMetadata,
    'required': ?required,
    'server_label': serverLabel,
    'transport': transport.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionMcpTool copyWith({
    Object? allowedTools = unsetCopyWithValue,
    bool? clearAllowedTools,
    Object? connectionOrigin = unsetCopyWithValue,
    bool? clearConnectionOrigin,
    Object? credentialId = unsetCopyWithValue,
    bool? clearCredentialId,
    Object? requestMetadata = unsetCopyWithValue,
    bool? clearRequestMetadata,
    Object? required = unsetCopyWithValue,
    String? serverLabel,
    AgentSessionMcpTransport? transport,
  }) => AgentSessionMcpTool(
    allowedTools: copyAgentValue<List<String>>(
      allowedTools,
      this.allowedTools,
      'AgentSessionMcpTool.allowedTools',
    ),
    clearAllowedTools:
        clearAllowedTools ??
        (identical(allowedTools, unsetCopyWithValue)
            ? this.clearAllowedTools
            : allowedTools == null),
    connectionOrigin: copyAgentValue<AgentMcpConnectionOriginParam>(
      connectionOrigin,
      this.connectionOrigin,
      'AgentSessionMcpTool.connectionOrigin',
    ),
    clearConnectionOrigin:
        clearConnectionOrigin ??
        (identical(connectionOrigin, unsetCopyWithValue)
            ? this.clearConnectionOrigin
            : connectionOrigin == null),
    credentialId: copyAgentValue<String>(
      credentialId,
      this.credentialId,
      'AgentSessionMcpTool.credentialId',
    ),
    clearCredentialId:
        clearCredentialId ??
        (identical(credentialId, unsetCopyWithValue)
            ? this.clearCredentialId
            : credentialId == null),
    requestMetadata: copyAgentValue<Map<String, dynamic>>(
      requestMetadata,
      this.requestMetadata,
      'AgentSessionMcpTool.requestMetadata',
    ),
    clearRequestMetadata:
        clearRequestMetadata ??
        (identical(requestMetadata, unsetCopyWithValue)
            ? this.clearRequestMetadata
            : requestMetadata == null),
    required: copyAgentValue<bool>(
      required,
      this.required,
      'AgentSessionMcpTool.required',
    ),
    serverLabel: serverLabel ?? this.serverLabel,
    transport: transport ?? this.transport,
  );
}

/// Enables calling tools from model-generated code.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionProgrammaticToolCallingTool extends AgentSessionTool {
  /// Creates a validated [AgentSessionProgrammaticToolCallingTool].
  AgentSessionProgrammaticToolCallingTool({this.enabled}) {
    validate();
  }

  /// Whether tools can be called from model-generated code. Defaults to `true`.
  final bool? enabled;

  /// The type of the object. Always `programmatic_tool_calling`.
  @override
  String get type => 'programmatic_tool_calling';

  /// Parses [AgentSessionProgrammaticToolCallingTool] with contextual, payload-free errors.
  factory AgentSessionProgrammaticToolCallingTool.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'enabled',
      'type',
    ], 'AgentSessionProgrammaticToolCallingTool');
    requireAgentTag(
      json,
      'type',
      'programmatic_tool_calling',
      'AgentSessionProgrammaticToolCallingTool',
    );
    return AgentSessionProgrammaticToolCallingTool(
      enabled: optionalAgentValue(
        json,
        'enabled',
        'AgentSessionProgrammaticToolCallingTool.enabled',
        requireAgentBool,
        nullable: false,
      ),
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {'enabled': ?enabled, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionProgrammaticToolCallingTool copyWith({
    Object? enabled = unsetCopyWithValue,
  }) => AgentSessionProgrammaticToolCallingTool(
    enabled: copyAgentValue<bool>(
      enabled,
      this.enabled,
      'AgentSessionProgrammaticToolCallingTool.enabled',
    ),
  );
}

/// Discovers deferred function tools and loads them into the model context.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionToolSearchTool extends AgentSessionTool {
  /// Creates a validated [AgentSessionToolSearchTool].
  AgentSessionToolSearchTool() {
    validate();
  }

  /// The type of the object. Always `tool_search`.
  @override
  String get type => 'tool_search';

  /// Parses [AgentSessionToolSearchTool] with contextual, payload-free errors.
  factory AgentSessionToolSearchTool.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const ['type'], 'AgentSessionToolSearchTool');
    requireAgentTag(json, 'type', 'tool_search', 'AgentSessionToolSearchTool');
    return AgentSessionToolSearchTool();
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionToolSearchTool copyWith() => AgentSessionToolSearchTool();
}

/// Web search.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionWebSearchTool extends AgentSessionTool {
  /// Creates a validated [AgentSessionWebSearchTool].
  AgentSessionWebSearchTool({
    List<String>? allowedDomains,
    bool clearAllowedDomains = false,
    AgentWebSearchContextSizeParam? contextSize,
    bool clearContextSize = false,
    AgentWebSearchLocation? location,
    bool clearLocation = false,
    AgentWebSearchModeParam? mode,
    bool clearMode = false,
  }) : clearAllowedDomains = clearAllowedDomains,
       allowedDomains = ownAgentValue<List<String>>(
         clearAllowedDomains ? null : allowedDomains,
         List.unmodifiable,
       ),
       clearContextSize = clearContextSize,
       contextSize = clearContextSize ? null : contextSize,
       clearLocation = clearLocation,
       location = clearLocation ? null : location,
       clearMode = clearMode,
       mode = clearMode ? null : mode {
    validate();
  }

  /// Domains the search may include.
  final List<String>? allowedDomains;

  /// Sends `allowed_domains: null`, rather than omitting it.
  final bool clearAllowedDomains;

  /// The amount of search context made available to the model. Defaults to `medium`.
  final AgentWebSearchContextSizeParam? contextSize;

  /// Sends `context_size: null`, rather than omitting it.
  final bool clearContextSize;

  /// Approximate location used to localize search results.
  final AgentWebSearchLocation? location;

  /// Sends `location: null`, rather than omitting it.
  final bool clearLocation;

  /// The source used for web search results. Defaults to `live`.
  final AgentWebSearchModeParam? mode;

  /// Sends `mode: null`, rather than omitting it.
  final bool clearMode;

  /// The type of the object. Always `web_search`.
  @override
  String get type => 'web_search';

  /// Parses [AgentSessionWebSearchTool] with contextual, payload-free errors.
  factory AgentSessionWebSearchTool.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'allowed_domains',
      'context_size',
      'location',
      'mode',
      'type',
    ], 'AgentSessionWebSearchTool');
    requireAgentTag(json, 'type', 'web_search', 'AgentSessionWebSearchTool');
    return AgentSessionWebSearchTool(
      allowedDomains: optionalAgentValue(
        json,
        'allowed_domains',
        'AgentSessionWebSearchTool.allowedDomains',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      clearAllowedDomains:
          json.containsKey('allowed_domains') &&
          json['allowed_domains'] == null,
      contextSize: optionalAgentValue(
        json,
        'context_size',
        'AgentSessionWebSearchTool.contextSize',
        (value, context) => AgentWebSearchContextSizeParam.fromJson(value),
        nullable: true,
      ),
      clearContextSize:
          json.containsKey('context_size') && json['context_size'] == null,
      location: optionalAgentValue(
        json,
        'location',
        'AgentSessionWebSearchTool.location',
        (value, context) =>
            AgentWebSearchLocation.fromJson(requireAgentObject(value, context)),
        nullable: true,
      ),
      clearLocation: json.containsKey('location') && json['location'] == null,
      mode: optionalAgentValue(
        json,
        'mode',
        'AgentSessionWebSearchTool.mode',
        (value, context) => AgentWebSearchModeParam.fromJson(value),
        nullable: true,
      ),
      clearMode: json.containsKey('mode') && json['mode'] == null,
    );
  }
  @override
  void validate() {
    if (allowedDomains != null) {
      validateAgentCount(
        allowedDomains!.length,
        'AgentSessionWebSearchTool.allowedDomains',
        min: 0,
        max: 16384,
      );
      for (final item in allowedDomains!) {
        validateAgentLength(
          item,
          'AgentSessionWebSearchTool.allowedDomains',
          min: 0,
          max: 1048576,
        );
      }
    }
    if (contextSize != null) {
      validateAgentEnum(contextSize!.value, [
        'low',
        'medium',
        'high',
      ], 'AgentSessionWebSearchTool.contextSize');
    }
    if (location != null) {
      location!.validate();
    }
    if (mode != null) {
      validateAgentEnum(mode!.value, [
        'disabled',
        'cached',
        'live',
      ], 'AgentSessionWebSearchTool.mode');
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearAllowedDomains)
      'allowed_domains': null
    else if (allowedDomains != null)
      'allowed_domains': allowedDomains!.map((value) => value).toList(),
    if (clearContextSize)
      'context_size': null
    else if (contextSize != null)
      'context_size': contextSize!.toJson(),
    if (clearLocation)
      'location': null
    else if (location != null)
      'location': location!.toJson(),
    if (clearMode) 'mode': null else if (mode != null) 'mode': mode!.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionWebSearchTool copyWith({
    Object? allowedDomains = unsetCopyWithValue,
    bool? clearAllowedDomains,
    Object? contextSize = unsetCopyWithValue,
    bool? clearContextSize,
    Object? location = unsetCopyWithValue,
    bool? clearLocation,
    Object? mode = unsetCopyWithValue,
    bool? clearMode,
  }) => AgentSessionWebSearchTool(
    allowedDomains: copyAgentValue<List<String>>(
      allowedDomains,
      this.allowedDomains,
      'AgentSessionWebSearchTool.allowedDomains',
    ),
    clearAllowedDomains:
        clearAllowedDomains ??
        (identical(allowedDomains, unsetCopyWithValue)
            ? this.clearAllowedDomains
            : allowedDomains == null),
    contextSize: copyAgentValue<AgentWebSearchContextSizeParam>(
      contextSize,
      this.contextSize,
      'AgentSessionWebSearchTool.contextSize',
    ),
    clearContextSize:
        clearContextSize ??
        (identical(contextSize, unsetCopyWithValue)
            ? this.clearContextSize
            : contextSize == null),
    location: copyAgentValue<AgentWebSearchLocation>(
      location,
      this.location,
      'AgentSessionWebSearchTool.location',
    ),
    clearLocation:
        clearLocation ??
        (identical(location, unsetCopyWithValue)
            ? this.clearLocation
            : location == null),
    mode: copyAgentValue<AgentWebSearchModeParam>(
      mode,
      this.mode,
      'AgentSessionWebSearchTool.mode',
    ),
    clearMode:
        clearMode ??
        (identical(mode, unsetCopyWithValue) ? this.clearMode : mode == null),
  );
}

/// A tool available to the agent.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionToolResource extends AgentJsonModel {
  const AgentSessionToolResource();

  /// Parses a known contract or detached future received value.
  factory AgentSessionToolResource.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionToolResource.type',
    )) {
      'computer_use' => AgentSessionComputerUseToolResource.fromJson(json),
      'function' => AgentSessionFunctionToolResource.fromJson(json),
      'mcp' => AgentSessionMcpToolResource.fromJson(json),
      'programmatic_tool_calling' =>
        AgentSessionProgrammaticToolCallingToolResource.fromJson(json),
      'web_search' => AgentSessionWebSearchToolResource.fromJson(json),
      _ => UnknownAgentSessionToolResource.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `computer_use` contract.
  factory AgentSessionToolResource.computerUse({
    required bool includeScreenshots,
    Map<String, dynamic> rawJson,
  }) = AgentSessionComputerUseToolResource;

  /// Builds the `function` contract.
  factory AgentSessionToolResource.function({
    required bool deferLoading,
    required String description,
    required String name,
    required Map<String, dynamic> parameters,
    Map<String, dynamic> rawJson,
  }) = AgentSessionFunctionToolResource;

  /// Builds the `mcp` contract.
  factory AgentSessionToolResource.mcp({
    required List<String>? allowedTools,
    required AgentMcpConnectionOriginResource connectionOrigin,
    required String? credentialId,
    required Map<String, dynamic> requestMetadata,
    required bool required,
    required String serverLabel,
    required AgentSessionMcpTransportResource transport,
    Map<String, dynamic> rawJson,
  }) = AgentSessionMcpToolResource;

  /// Builds the `programmatic_tool_calling` contract.
  factory AgentSessionToolResource.programmaticToolCalling({
    required bool enabled,
    Map<String, dynamic> rawJson,
  }) = AgentSessionProgrammaticToolCallingToolResource;

  /// Builds the `web_search` contract.
  factory AgentSessionToolResource.webSearch({
    required List<String>? allowedDomains,
    required AgentWebSearchContextSizeResource contextSize,
    required AgentWebSearchLocationResource? location,
    required AgentWebSearchModeResource mode,
    Map<String, dynamic> rawJson,
  }) = AgentSessionWebSearchToolResource;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionToolResource extends AgentSessionToolResource {
  const UnknownAgentSessionToolResource._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionToolResource.fromJson(Map<String, dynamic> json) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionToolResource.type',
    );
    if (const [
      'computer_use',
      'function',
      'mcp',
      'programmatic_tool_calling',
      'web_search',
    ].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionToolResource: expected a future discriminator',
      );
    }
    return UnknownAgentSessionToolResource._(
      snapshotAgentJson(json, 'UnknownAgentSessionToolResource'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionToolResource copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentSessionToolResource.fromJson(rawJson ?? this.rawJson);
}

/// Browser use in an OpenAI-hosted session.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionComputerUseToolResource
    extends AgentSessionToolResource {
  /// Creates a validated [AgentSessionComputerUseToolResource].
  AgentSessionComputerUseToolResource({
    required this.includeScreenshots,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'include_screenshots',
         'type',
       ], 'AgentSessionComputerUseToolResource') {
    validate();
  }

  /// Whether computer tool outputs include screenshots.
  final bool includeScreenshots;

  /// The type of the object. Always `computer_use`.
  @override
  String get type => 'computer_use';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionComputerUseToolResource] with contextual, payload-free errors.
  factory AgentSessionComputerUseToolResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'computer_use',
      'AgentSessionComputerUseToolResource',
    );
    return AgentSessionComputerUseToolResource(
      includeScreenshots: requiredAgentValue(
        json,
        'include_screenshots',
        'AgentSessionComputerUseToolResource.includeScreenshots',
        requireAgentBool,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['include_screenshots', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'include_screenshots': includeScreenshots,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionComputerUseToolResource copyWith({
    bool? includeScreenshots,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionComputerUseToolResource(
    includeScreenshots: includeScreenshots ?? this.includeScreenshots,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A function defined by the application.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionFunctionToolResource extends AgentSessionToolResource {
  /// Creates a validated [AgentSessionFunctionToolResource].
  AgentSessionFunctionToolResource({
    required this.deferLoading,
    required this.description,
    required this.name,
    required Map<String, dynamic> parameters,
    Map<String, dynamic> rawJson = const {},
  }) : parameters = snapshotAgentJson(
         parameters,
         'AgentSessionFunctionToolResource.parameters',
       ),
       rawJson = agentExtras(rawJson, const [
         'defer_loading',
         'description',
         'name',
         'parameters',
         'type',
       ], 'AgentSessionFunctionToolResource') {
    validate();
  }

  /// Whether the function is deferred and discovered through tool search.
  final bool deferLoading;

  /// A description of what the function does.
  final String description;

  /// The name of the function.
  final String name;

  /// A JSON Schema object describing the function's arguments.
  final Map<String, dynamic> parameters;

  /// The type of the object. Always `function`.
  @override
  String get type => 'function';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionFunctionToolResource] with contextual, payload-free errors.
  factory AgentSessionFunctionToolResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'function',
      'AgentSessionFunctionToolResource',
    );
    return AgentSessionFunctionToolResource(
      deferLoading: requiredAgentValue(
        json,
        'defer_loading',
        'AgentSessionFunctionToolResource.deferLoading',
        requireAgentBool,
        nullable: false,
      )!,
      description: requiredAgentValue(
        json,
        'description',
        'AgentSessionFunctionToolResource.description',
        requireAgentString,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentSessionFunctionToolResource.name',
        requireAgentString,
        nullable: false,
      )!,
      parameters: requiredAgentValue(
        json,
        'parameters',
        'AgentSessionFunctionToolResource.parameters',
        requireAgentObject,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'defer_loading',
            'description',
            'name',
            'parameters',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      description,
      'AgentSessionFunctionToolResource.description',
      min: 0,
    );
    validateAgentLength(name, 'AgentSessionFunctionToolResource.name', min: 0);
    validateAgentCount(
      parameters.length,
      'AgentSessionFunctionToolResource.parameters',
      min: 0,
    );
    for (final key in parameters.keys) {
      validateAgentLength(
        key,
        'AgentSessionFunctionToolResource.parameters',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'defer_loading': deferLoading,
    'description': description,
    'name': name,
    'parameters': parameters,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionFunctionToolResource copyWith({
    bool? deferLoading,
    String? description,
    String? name,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionFunctionToolResource(
    deferLoading: deferLoading ?? this.deferLoading,
    description: description ?? this.description,
    name: name ?? this.name,
    parameters: parameters ?? this.parameters,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Tools provided by a remote MCP server.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionMcpToolResource extends AgentSessionToolResource {
  /// Creates a validated [AgentSessionMcpToolResource].
  AgentSessionMcpToolResource({
    required List<String>? allowedTools,
    required this.connectionOrigin,
    required this.credentialId,
    required Map<String, dynamic> requestMetadata,
    required this.required,
    required this.serverLabel,
    required this.transport,
    Map<String, dynamic> rawJson = const {},
  }) : allowedTools = ownAgentValue<List<String>>(
         allowedTools,
         List.unmodifiable,
       ),
       requestMetadata = snapshotAgentJson(
         requestMetadata,
         'AgentSessionMcpToolResource.requestMetadata',
       ),
       rawJson = agentExtras(rawJson, const [
         'allowed_tools',
         'connection_origin',
         'credential_id',
         'request_metadata',
         'required',
         'server_label',
         'transport',
         'type',
       ], 'AgentSessionMcpToolResource') {
    validate();
  }

  /// The MCP tools the agent may call.
  final List<String>? allowedTools;

  /// Where outbound MCP HTTP connections originate.
  final AgentMcpConnectionOriginResource connectionOrigin;

  /// The attached vault credential selected for this MCP server, if any. Optional when exactly one attached credential matches the server URL.
  final String? credentialId;

  /// Metadata included with requests to this MCP server.
  final Map<String, dynamic> requestMetadata;

  /// Whether this MCP server must initialize before the first turn.
  final bool required;

  /// A label used to identify the MCP server in tool calls.
  final String serverLabel;

  /// The transport used to connect to the MCP server.
  final AgentSessionMcpTransportResource transport;

  /// The type of the object. Always `mcp`.
  @override
  String get type => 'mcp';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionMcpToolResource] with contextual, payload-free errors.
  factory AgentSessionMcpToolResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'mcp', 'AgentSessionMcpToolResource');
    return AgentSessionMcpToolResource(
      allowedTools: requiredAgentValue(
        json,
        'allowed_tools',
        'AgentSessionMcpToolResource.allowedTools',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      connectionOrigin: requiredAgentValue(
        json,
        'connection_origin',
        'AgentSessionMcpToolResource.connectionOrigin',
        (value, context) => AgentMcpConnectionOriginResource.fromJson(value),
        nullable: false,
      )!,
      credentialId: requiredAgentValue(
        json,
        'credential_id',
        'AgentSessionMcpToolResource.credentialId',
        requireAgentString,
        nullable: true,
      ),
      requestMetadata: requiredAgentValue(
        json,
        'request_metadata',
        'AgentSessionMcpToolResource.requestMetadata',
        requireAgentObject,
        nullable: false,
      )!,
      required: requiredAgentValue(
        json,
        'required',
        'AgentSessionMcpToolResource.required',
        requireAgentBool,
        nullable: false,
      )!,
      serverLabel: requiredAgentValue(
        json,
        'server_label',
        'AgentSessionMcpToolResource.serverLabel',
        requireAgentString,
        nullable: false,
      )!,
      transport: requiredAgentValue(
        json,
        'transport',
        'AgentSessionMcpToolResource.transport',
        (value, context) => AgentSessionMcpTransportResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'allowed_tools',
            'connection_origin',
            'credential_id',
            'request_metadata',
            'required',
            'server_label',
            'transport',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (allowedTools != null) {
      validateAgentCount(
        allowedTools!.length,
        'AgentSessionMcpToolResource.allowedTools',
        min: 0,
        max: 2000,
      );
      for (final item in allowedTools!) {
        validateAgentLength(
          item,
          'AgentSessionMcpToolResource.allowedTools',
          min: 0,
        );
      }
    }
    if (credentialId != null) {
      validateAgentLength(
        credentialId!,
        'AgentSessionMcpToolResource.credentialId',
        min: 0,
      );
    }
    validateAgentCount(
      requestMetadata.length,
      'AgentSessionMcpToolResource.requestMetadata',
      min: 0,
    );
    for (final key in requestMetadata.keys) {
      validateAgentLength(
        key,
        'AgentSessionMcpToolResource.requestMetadata',
        min: 0,
      );
    }
    validateAgentLength(
      serverLabel,
      'AgentSessionMcpToolResource.serverLabel',
      min: 0,
    );
    transport.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'allowed_tools': allowedTools?.map((value) => value).toList(),
    'connection_origin': connectionOrigin.toJson(),
    'credential_id': credentialId,
    'request_metadata': requestMetadata,
    'required': required,
    'server_label': serverLabel,
    'transport': transport.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionMcpToolResource copyWith({
    Object? allowedTools = unsetCopyWithValue,
    AgentMcpConnectionOriginResource? connectionOrigin,
    Object? credentialId = unsetCopyWithValue,
    Map<String, dynamic>? requestMetadata,
    bool? required,
    String? serverLabel,
    AgentSessionMcpTransportResource? transport,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionMcpToolResource(
    allowedTools: copyAgentValue<List<String>>(
      allowedTools,
      this.allowedTools,
      'AgentSessionMcpToolResource.allowedTools',
    ),
    connectionOrigin: connectionOrigin ?? this.connectionOrigin,
    credentialId: copyAgentValue<String>(
      credentialId,
      this.credentialId,
      'AgentSessionMcpToolResource.credentialId',
    ),
    requestMetadata: requestMetadata ?? this.requestMetadata,
    required: required ?? this.required,
    serverLabel: serverLabel ?? this.serverLabel,
    transport: transport ?? this.transport,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Enables calling tools from model-generated code.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionProgrammaticToolCallingToolResource
    extends AgentSessionToolResource {
  /// Creates a validated [AgentSessionProgrammaticToolCallingToolResource].
  AgentSessionProgrammaticToolCallingToolResource({
    required this.enabled,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'enabled',
         'type',
       ], 'AgentSessionProgrammaticToolCallingToolResource') {
    validate();
  }

  /// Whether tools can be called from model-generated code.
  final bool enabled;

  /// The type of the object. Always `programmatic_tool_calling`.
  @override
  String get type => 'programmatic_tool_calling';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionProgrammaticToolCallingToolResource] with contextual, payload-free errors.
  factory AgentSessionProgrammaticToolCallingToolResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'programmatic_tool_calling',
      'AgentSessionProgrammaticToolCallingToolResource',
    );
    return AgentSessionProgrammaticToolCallingToolResource(
      enabled: requiredAgentValue(
        json,
        'enabled',
        'AgentSessionProgrammaticToolCallingToolResource.enabled',
        requireAgentBool,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['enabled', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'enabled': enabled,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionProgrammaticToolCallingToolResource copyWith({
    bool? enabled,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionProgrammaticToolCallingToolResource(
    enabled: enabled ?? this.enabled,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Web search.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionWebSearchToolResource extends AgentSessionToolResource {
  /// Creates a validated [AgentSessionWebSearchToolResource].
  AgentSessionWebSearchToolResource({
    required List<String>? allowedDomains,
    required this.contextSize,
    required this.location,
    required this.mode,
    Map<String, dynamic> rawJson = const {},
  }) : allowedDomains = ownAgentValue<List<String>>(
         allowedDomains,
         List.unmodifiable,
       ),
       rawJson = agentExtras(rawJson, const [
         'allowed_domains',
         'context_size',
         'location',
         'mode',
         'type',
       ], 'AgentSessionWebSearchToolResource') {
    validate();
  }

  /// Allowed search domains, or `null` when the search is unrestricted.
  final List<String>? allowedDomains;

  /// The amount of search context made available to the model. Defaults to `medium`.
  final AgentWebSearchContextSizeResource contextSize;

  /// Approximate location used to localize search results, if provided.
  final AgentWebSearchLocationResource? location;

  /// The source used for web search results.
  final AgentWebSearchModeResource mode;

  /// The type of the object. Always `web_search`.
  @override
  String get type => 'web_search';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionWebSearchToolResource] with contextual, payload-free errors.
  factory AgentSessionWebSearchToolResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'web_search',
      'AgentSessionWebSearchToolResource',
    );
    return AgentSessionWebSearchToolResource(
      allowedDomains: requiredAgentValue(
        json,
        'allowed_domains',
        'AgentSessionWebSearchToolResource.allowedDomains',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      contextSize: requiredAgentValue(
        json,
        'context_size',
        'AgentSessionWebSearchToolResource.contextSize',
        (value, context) => AgentWebSearchContextSizeResource.fromJson(value),
        nullable: false,
      )!,
      location: requiredAgentValue(
        json,
        'location',
        'AgentSessionWebSearchToolResource.location',
        (value, context) => AgentWebSearchLocationResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      mode: requiredAgentValue(
        json,
        'mode',
        'AgentSessionWebSearchToolResource.mode',
        (value, context) => AgentWebSearchModeResource.fromJson(value),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'allowed_domains',
            'context_size',
            'location',
            'mode',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (allowedDomains != null) {
      validateAgentCount(
        allowedDomains!.length,
        'AgentSessionWebSearchToolResource.allowedDomains',
        min: 0,
        max: 2000,
      );
      for (final item in allowedDomains!) {
        validateAgentLength(
          item,
          'AgentSessionWebSearchToolResource.allowedDomains',
          min: 0,
        );
      }
    }
    if (location != null) {
      location!.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'allowed_domains': allowedDomains?.map((value) => value).toList(),
    'context_size': contextSize.toJson(),
    'location': location?.toJson(),
    'mode': mode.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionWebSearchToolResource copyWith({
    Object? allowedDomains = unsetCopyWithValue,
    AgentWebSearchContextSizeResource? contextSize,
    Object? location = unsetCopyWithValue,
    AgentWebSearchModeResource? mode,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionWebSearchToolResource(
    allowedDomains: copyAgentValue<List<String>>(
      allowedDomains,
      this.allowedDomains,
      'AgentSessionWebSearchToolResource.allowedDomains',
    ),
    contextSize: contextSize ?? this.contextSize,
    location: copyAgentValue<AgentWebSearchLocationResource>(
      location,
      this.location,
      'AgentSessionWebSearchToolResource.location',
    ),
    mode: mode ?? this.mode,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// The transport used to connect to an MCP server.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionMcpTransport extends AgentJsonModel {
  const AgentSessionMcpTransport();

  /// Parses a known contract or detached future received value.
  factory AgentSessionMcpTransport.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionMcpTransport.type',
    )) {
      'http' => AgentSessionMcpHttpTransport.fromJson(json),
      'stdio' => AgentSessionMcpStdioTransport.fromJson(json),
      _ => UnknownAgentSessionMcpTransport.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `http` contract.
  factory AgentSessionMcpTransport.http({
    String? authorization,
    bool clearAuthorization,
    Map<String, String>? headers,
    bool clearHeaders,
    required String serverUrl,
  }) = AgentSessionMcpHttpTransport;

  /// Builds the `stdio` contract.
  factory AgentSessionMcpTransport.stdio({
    List<String>? args,
    bool clearArgs,
    required String command,
    required String cwd,
    Map<String, String>? env,
    bool clearEnv,
    List<String>? envVars,
    bool clearEnvVars,
  }) = AgentSessionMcpStdioTransport;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionMcpTransport extends AgentSessionMcpTransport {
  const UnknownAgentSessionMcpTransport._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionMcpTransport.fromJson(Map<String, dynamic> json) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionMcpTransport.type',
    );
    if (const ['http', 'stdio'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionMcpTransport: expected a future discriminator',
      );
    }
    return UnknownAgentSessionMcpTransport._(
      snapshotAgentJson(json, 'UnknownAgentSessionMcpTransport'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionMcpTransport copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentSessionMcpTransport.fromJson(rawJson ?? this.rawJson);
  @override
  void validate() => throw const FormatException(
    'UnknownAgentSessionMcpTransport: future input is not writable',
  );
}

/// Connects to an MCP server over HTTP.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionMcpHttpTransport extends AgentSessionMcpTransport {
  /// Creates a validated [AgentSessionMcpHttpTransport].
  AgentSessionMcpHttpTransport({
    String? authorization,
    bool clearAuthorization = false,
    Map<String, String>? headers,
    bool clearHeaders = false,
    required this.serverUrl,
  }) : clearAuthorization = clearAuthorization,
       authorization = clearAuthorization ? null : authorization,
       clearHeaders = clearHeaders,
       headers = ownAgentValue<Map<String, String>>(
         clearHeaders ? null : headers,
         Map<String, String>.unmodifiable,
       ) {
    validate();
  }

  /// The authorization value sent to the MCP server, if any.
  final String? authorization;

  /// Sends `authorization: null`, rather than omitting it.
  final bool clearAuthorization;

  /// Additional HTTP headers sent to the MCP server.
  final Map<String, String>? headers;

  /// Sends `headers: null`, rather than omitting it.
  final bool clearHeaders;

  /// The URL of the MCP server.
  final String serverUrl;

  /// The type of the object. Always `http`.
  @override
  String get type => 'http';

  /// Parses [AgentSessionMcpHttpTransport] with contextual, payload-free errors.
  factory AgentSessionMcpHttpTransport.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'authorization',
      'headers',
      'server_url',
      'type',
    ], 'AgentSessionMcpHttpTransport');
    requireAgentTag(json, 'type', 'http', 'AgentSessionMcpHttpTransport');
    return AgentSessionMcpHttpTransport(
      authorization: optionalAgentValue(
        json,
        'authorization',
        'AgentSessionMcpHttpTransport.authorization',
        requireAgentString,
        nullable: true,
      ),
      clearAuthorization:
          json.containsKey('authorization') && json['authorization'] == null,
      headers: optionalAgentValue(
        json,
        'headers',
        'AgentSessionMcpHttpTransport.headers',
        requireAgentStringMap,
        nullable: true,
      ),
      clearHeaders: json.containsKey('headers') && json['headers'] == null,
      serverUrl: requiredAgentValue(
        json,
        'server_url',
        'AgentSessionMcpHttpTransport.serverUrl',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    if (authorization != null) {
      validateAgentLength(
        authorization!,
        'AgentSessionMcpHttpTransport.authorization',
        min: 0,
        max: 1048576,
      );
    }
    if (headers != null) {
      validateAgentCount(
        headers!.length,
        'AgentSessionMcpHttpTransport.headers',
        min: 0,
        max: 1024,
      );
      for (final key in headers!.keys) {
        validateAgentLength(
          key,
          'AgentSessionMcpHttpTransport.headers',
          min: 1,
          max: 256,
        );
      }
      for (final item in headers!.values) {
        validateAgentLength(
          item,
          'AgentSessionMcpHttpTransport.headers',
          min: 0,
          max: 1048576,
        );
      }
    }
    validateAgentLength(
      serverUrl,
      'AgentSessionMcpHttpTransport.serverUrl',
      min: 0,
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearAuthorization)
      'authorization': null
    else
      'authorization': ?authorization,
    if (clearHeaders) 'headers': null else 'headers': ?headers,
    'server_url': serverUrl,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionMcpHttpTransport copyWith({
    Object? authorization = unsetCopyWithValue,
    bool? clearAuthorization,
    Object? headers = unsetCopyWithValue,
    bool? clearHeaders,
    String? serverUrl,
  }) => AgentSessionMcpHttpTransport(
    authorization: copyAgentValue<String>(
      authorization,
      this.authorization,
      'AgentSessionMcpHttpTransport.authorization',
    ),
    clearAuthorization:
        clearAuthorization ??
        (identical(authorization, unsetCopyWithValue)
            ? this.clearAuthorization
            : authorization == null),
    headers: copyAgentValue<Map<String, String>>(
      headers,
      this.headers,
      'AgentSessionMcpHttpTransport.headers',
    ),
    clearHeaders:
        clearHeaders ??
        (identical(headers, unsetCopyWithValue)
            ? this.clearHeaders
            : headers == null),
    serverUrl: serverUrl ?? this.serverUrl,
  );
}

/// Starts an MCP server as a local process.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionMcpStdioTransport extends AgentSessionMcpTransport {
  /// Creates a validated [AgentSessionMcpStdioTransport].
  AgentSessionMcpStdioTransport({
    List<String>? args,
    bool clearArgs = false,
    required this.command,
    required this.cwd,
    Map<String, String>? env,
    bool clearEnv = false,
    List<String>? envVars,
    bool clearEnvVars = false,
  }) : clearArgs = clearArgs,
       args = ownAgentValue<List<String>>(
         clearArgs ? null : args,
         List.unmodifiable,
       ),
       clearEnv = clearEnv,
       env = ownAgentValue<Map<String, String>>(
         clearEnv ? null : env,
         Map<String, String>.unmodifiable,
       ),
       clearEnvVars = clearEnvVars,
       envVars = ownAgentValue<List<String>>(
         clearEnvVars ? null : envVars,
         List.unmodifiable,
       ) {
    validate();
  }

  /// Arguments passed to the MCP server command.
  final List<String>? args;

  /// Sends `args: null`, rather than omitting it.
  final bool clearArgs;

  /// The command used to start the MCP server.
  final String command;

  /// The working directory used to start the MCP server.
  final String cwd;

  /// Environment variables set for the MCP server process.
  final Map<String, String>? env;

  /// Sends `env: null`, rather than omitting it.
  final bool clearEnv;

  /// Environment variable names to inherit from the selected execution environment.
  final List<String>? envVars;

  /// Sends `env_vars: null`, rather than omitting it.
  final bool clearEnvVars;

  /// The type of the object. Always `stdio`.
  @override
  String get type => 'stdio';

  /// Parses [AgentSessionMcpStdioTransport] with contextual, payload-free errors.
  factory AgentSessionMcpStdioTransport.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'args',
      'command',
      'cwd',
      'env',
      'env_vars',
      'type',
    ], 'AgentSessionMcpStdioTransport');
    requireAgentTag(json, 'type', 'stdio', 'AgentSessionMcpStdioTransport');
    return AgentSessionMcpStdioTransport(
      args: optionalAgentValue(
        json,
        'args',
        'AgentSessionMcpStdioTransport.args',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      clearArgs: json.containsKey('args') && json['args'] == null,
      command: requiredAgentValue(
        json,
        'command',
        'AgentSessionMcpStdioTransport.command',
        requireAgentString,
        nullable: false,
      )!,
      cwd: requiredAgentValue(
        json,
        'cwd',
        'AgentSessionMcpStdioTransport.cwd',
        requireAgentString,
        nullable: false,
      )!,
      env: optionalAgentValue(
        json,
        'env',
        'AgentSessionMcpStdioTransport.env',
        requireAgentStringMap,
        nullable: true,
      ),
      clearEnv: json.containsKey('env') && json['env'] == null,
      envVars: optionalAgentValue(
        json,
        'env_vars',
        'AgentSessionMcpStdioTransport.envVars',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      clearEnvVars: json.containsKey('env_vars') && json['env_vars'] == null,
    );
  }
  @override
  void validate() {
    if (args != null) {
      validateAgentCount(
        args!.length,
        'AgentSessionMcpStdioTransport.args',
        min: 0,
        max: 16384,
      );
      for (final item in args!) {
        validateAgentLength(
          item,
          'AgentSessionMcpStdioTransport.args',
          min: 0,
          max: 1048576,
        );
      }
    }
    validateAgentLength(
      command,
      'AgentSessionMcpStdioTransport.command',
      min: 0,
      max: 1048576,
    );
    validateAgentLength(
      cwd,
      'AgentSessionMcpStdioTransport.cwd',
      min: 0,
      max: 1048576,
    );
    if (env != null) {
      validateAgentCount(
        env!.length,
        'AgentSessionMcpStdioTransport.env',
        min: 0,
        max: 1024,
      );
      for (final key in env!.keys) {
        validateAgentLength(
          key,
          'AgentSessionMcpStdioTransport.env',
          min: 1,
          max: 256,
        );
      }
      for (final item in env!.values) {
        validateAgentLength(
          item,
          'AgentSessionMcpStdioTransport.env',
          min: 0,
          max: 1048576,
        );
      }
    }
    if (envVars != null) {
      validateAgentCount(
        envVars!.length,
        'AgentSessionMcpStdioTransport.envVars',
        min: 0,
        max: 16384,
      );
      for (final item in envVars!) {
        validateAgentLength(
          item,
          'AgentSessionMcpStdioTransport.envVars',
          min: 0,
          max: 1048576,
        );
      }
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearArgs)
      'args': null
    else if (args != null)
      'args': args!.map((value) => value).toList(),
    'command': command,
    'cwd': cwd,
    if (clearEnv) 'env': null else 'env': ?env,
    if (clearEnvVars)
      'env_vars': null
    else if (envVars != null)
      'env_vars': envVars!.map((value) => value).toList(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionMcpStdioTransport copyWith({
    Object? args = unsetCopyWithValue,
    bool? clearArgs,
    String? command,
    String? cwd,
    Object? env = unsetCopyWithValue,
    bool? clearEnv,
    Object? envVars = unsetCopyWithValue,
    bool? clearEnvVars,
  }) => AgentSessionMcpStdioTransport(
    args: copyAgentValue<List<String>>(
      args,
      this.args,
      'AgentSessionMcpStdioTransport.args',
    ),
    clearArgs:
        clearArgs ??
        (identical(args, unsetCopyWithValue) ? this.clearArgs : args == null),
    command: command ?? this.command,
    cwd: cwd ?? this.cwd,
    env: copyAgentValue<Map<String, String>>(
      env,
      this.env,
      'AgentSessionMcpStdioTransport.env',
    ),
    clearEnv:
        clearEnv ??
        (identical(env, unsetCopyWithValue) ? this.clearEnv : env == null),
    envVars: copyAgentValue<List<String>>(
      envVars,
      this.envVars,
      'AgentSessionMcpStdioTransport.envVars',
    ),
    clearEnvVars:
        clearEnvVars ??
        (identical(envVars, unsetCopyWithValue)
            ? this.clearEnvVars
            : envVars == null),
  );
}

/// The transport used to connect to an MCP server.
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionMcpTransportResource extends AgentJsonModel {
  const AgentSessionMcpTransportResource();

  /// Parses a known contract or detached future received value.
  factory AgentSessionMcpTransportResource.fromJson(Map<String, dynamic> json) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionMcpTransportResource.type',
    )) {
      'http' => AgentSessionMcpHttpTransportResource.fromJson(json),
      'stdio' => AgentSessionMcpStdioTransportResource.fromJson(json),
      _ => UnknownAgentSessionMcpTransportResource.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `http` contract.
  factory AgentSessionMcpTransportResource.http({
    required String serverUrl,
    Map<String, dynamic> rawJson,
  }) = AgentSessionMcpHttpTransportResource;

  /// Builds the `stdio` contract.
  factory AgentSessionMcpTransportResource.stdio({
    required List<String> args,
    required String command,
    required String cwd,
    required List<String> envVars,
    Map<String, dynamic> rawJson,
  }) = AgentSessionMcpStdioTransportResource;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionMcpTransportResource
    extends AgentSessionMcpTransportResource {
  const UnknownAgentSessionMcpTransportResource._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionMcpTransportResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionMcpTransportResource.type',
    );
    if (const ['http', 'stdio'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionMcpTransportResource: expected a future discriminator',
      );
    }
    return UnknownAgentSessionMcpTransportResource._(
      snapshotAgentJson(json, 'UnknownAgentSessionMcpTransportResource'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionMcpTransportResource copyWith({
    Map<String, dynamic>? rawJson,
  }) =>
      UnknownAgentSessionMcpTransportResource.fromJson(rawJson ?? this.rawJson);
}

/// Connects to an MCP server over HTTP.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionMcpHttpTransportResource
    extends AgentSessionMcpTransportResource {
  /// Creates a validated [AgentSessionMcpHttpTransportResource].
  AgentSessionMcpHttpTransportResource({
    required this.serverUrl,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'server_url',
         'type',
       ], 'AgentSessionMcpHttpTransportResource') {
    validate();
  }

  /// The URL of the MCP server.
  final String serverUrl;

  /// The type of the object. Always `http`.
  @override
  String get type => 'http';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionMcpHttpTransportResource] with contextual, payload-free errors.
  factory AgentSessionMcpHttpTransportResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'http',
      'AgentSessionMcpHttpTransportResource',
    );
    return AgentSessionMcpHttpTransportResource(
      serverUrl: requiredAgentValue(
        json,
        'server_url',
        'AgentSessionMcpHttpTransportResource.serverUrl',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['server_url', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      serverUrl,
      'AgentSessionMcpHttpTransportResource.serverUrl',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'server_url': serverUrl,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionMcpHttpTransportResource copyWith({
    String? serverUrl,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionMcpHttpTransportResource(
    serverUrl: serverUrl ?? this.serverUrl,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Starts an MCP server as a local process.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionMcpStdioTransportResource
    extends AgentSessionMcpTransportResource {
  /// Creates a validated [AgentSessionMcpStdioTransportResource].
  AgentSessionMcpStdioTransportResource({
    required List<String> args,
    required this.command,
    required this.cwd,
    required List<String> envVars,
    Map<String, dynamic> rawJson = const {},
  }) : args = List.unmodifiable(args),
       envVars = List.unmodifiable(envVars),
       rawJson = agentExtras(rawJson, const [
         'args',
         'command',
         'cwd',
         'env_vars',
         'type',
       ], 'AgentSessionMcpStdioTransportResource') {
    validate();
  }

  /// Arguments passed to the MCP server command.
  final List<String> args;

  /// The command used to start the MCP server.
  final String command;

  /// The working directory used to start the MCP server.
  final String cwd;

  /// Environment variable names inherited from the execution environment.
  final List<String> envVars;

  /// The type of the object. Always `stdio`.
  @override
  String get type => 'stdio';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionMcpStdioTransportResource] with contextual, payload-free errors.
  factory AgentSessionMcpStdioTransportResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'stdio',
      'AgentSessionMcpStdioTransportResource',
    );
    return AgentSessionMcpStdioTransportResource(
      args: requiredAgentValue(
        json,
        'args',
        'AgentSessionMcpStdioTransportResource.args',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: false,
      )!,
      command: requiredAgentValue(
        json,
        'command',
        'AgentSessionMcpStdioTransportResource.command',
        requireAgentString,
        nullable: false,
      )!,
      cwd: requiredAgentValue(
        json,
        'cwd',
        'AgentSessionMcpStdioTransportResource.cwd',
        requireAgentString,
        nullable: false,
      )!,
      envVars: requiredAgentValue(
        json,
        'env_vars',
        'AgentSessionMcpStdioTransportResource.envVars',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'args',
            'command',
            'cwd',
            'env_vars',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(
      args.length,
      'AgentSessionMcpStdioTransportResource.args',
      min: 0,
      max: 2000,
    );
    for (final item in args) {
      validateAgentLength(
        item,
        'AgentSessionMcpStdioTransportResource.args',
        min: 0,
      );
    }
    validateAgentLength(
      command,
      'AgentSessionMcpStdioTransportResource.command',
      min: 0,
    );
    validateAgentLength(
      cwd,
      'AgentSessionMcpStdioTransportResource.cwd',
      min: 0,
    );
    validateAgentCount(
      envVars.length,
      'AgentSessionMcpStdioTransportResource.envVars',
      min: 0,
      max: 2000,
    );
    for (final item in envVars) {
      validateAgentLength(
        item,
        'AgentSessionMcpStdioTransportResource.envVars',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'args': args.map((value) => value).toList(),
    'command': command,
    'cwd': cwd,
    'env_vars': envVars.map((value) => value).toList(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionMcpStdioTransportResource copyWith({
    List<String>? args,
    String? command,
    String? cwd,
    List<String>? envVars,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionMcpStdioTransportResource(
    args: args ?? this.args,
    command: command ?? this.command,
    cwd: cwd ?? this.cwd,
    envVars: envVars ?? this.envVars,
    rawJson: rawJson ?? this.rawJson,
  );
}
