import '../common/copy_with_sentinel.dart';
import 'agent_config.dart';
import 'agent_enums.dart';
import 'agent_json_helpers.dart';
import 'agent_mcp_transport.dart';

/// A tool that can be stored on a reusable agent without session credentials.
///
/// Variants: [AgentComputerUseTool], [AgentFunctionTool], [AgentMcpTool], [AgentProgrammaticToolCallingTool], [AgentToolSearchTool], [AgentWebSearchTool] and [UnknownAgentTool].
sealed class AgentTool extends AgentJsonModel {
  const AgentTool();

  /// Parses known variants strictly and retains future received variants.
  factory AgentTool.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(json['type'], 'AgentTool.type')) {
        'computer_use' => AgentComputerUseTool.fromJson(json),
        'function' => AgentFunctionTool.fromJson(json),
        'mcp' => AgentMcpTool.fromJson(json),
        'programmatic_tool_calling' =>
          AgentProgrammaticToolCallingTool.fromJson(json),
        'tool_search' => AgentToolSearchTool.fromJson(json),
        'web_search' => AgentWebSearchTool.fromJson(json),
        _ => UnknownAgentTool.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `computer_use` variant.
  factory AgentTool.computerUse({bool? includeScreenshots}) =
      AgentComputerUseTool;

  /// Creates the `function` variant.
  factory AgentTool.function({
    bool? deferLoading,
    required String description,
    required String name,
    required Map<String, dynamic> parameters,
  }) = AgentFunctionTool;

  /// Creates the `mcp` variant.
  factory AgentTool.mcp({
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
    required AgentMcpTransport transport,
  }) = AgentMcpTool;

  /// Creates the `programmatic_tool_calling` variant.
  factory AgentTool.programmaticToolCalling({bool? enabled}) =
      AgentProgrammaticToolCallingTool;

  /// Creates the `tool_search` variant.
  const factory AgentTool.toolSearch() = AgentToolSearchTool;

  /// Creates the `web_search` variant.
  factory AgentTool.webSearch({
    List<String>? allowedDomains,
    bool clearAllowedDomains,
    AgentWebSearchContextSizeParam? contextSize,
    bool clearContextSize,
    AgentWebSearchLocation? location,
    bool clearLocation,
    AgentWebSearchModeParam? mode,
    bool clearMode,
  }) = AgentWebSearchTool;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownAgentTool extends AgentTool {
  const UnknownAgentTool._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownAgentTool.fromJson(Map<String, dynamic> json) {
    final type = requireAgentString(json['type'], 'UnknownAgentTool.type');
    if (const [
      'computer_use',
      'function',
      'mcp',
      'programmatic_tool_calling',
      'tool_search',
      'web_search',
    ].contains(type)) {
      throw const FormatException('UnknownAgentTool: expected a future type');
    }
    return UnknownAgentTool._(snapshotAgentJson(json, 'UnknownAgentTool'));
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownAgentTool copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentTool.fromJson(rawJson ?? this.rawJson);

  @override
  void validate() => throw const FormatException(
    'UnknownAgentTool: future tools/transports are not writable',
  );
}

/// Browser use in an OpenAI-hosted session.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentComputerUseTool extends AgentTool {
  /// Creates a validated [AgentComputerUseTool].
  AgentComputerUseTool({this.includeScreenshots}) {
    validate();
  }

  /// Whether computer tool outputs include screenshots. Defaults to `false`.
  final bool? includeScreenshots;

  /// The type of the object. Always `computer_use`.
  @override
  String get type => 'computer_use';

  /// Parses [AgentComputerUseTool] with contextual, payload-free errors.
  factory AgentComputerUseTool.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'include_screenshots',
      'type',
    ], 'AgentComputerUseTool');
    requireAgentTag(json, 'type', 'computer_use', 'AgentComputerUseTool');
    return AgentComputerUseTool(
      includeScreenshots: optionalAgentValue(
        json,
        'include_screenshots',
        'AgentComputerUseTool.includeScreenshots',
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
  AgentComputerUseTool copyWith({
    Object? includeScreenshots = unsetCopyWithValue,
  }) => AgentComputerUseTool(
    includeScreenshots: copyAgentValue<bool>(
      includeScreenshots,
      this.includeScreenshots,
      'AgentComputerUseTool.includeScreenshots',
    ),
  );
}

/// A function defined by the application.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentFunctionTool extends AgentTool {
  /// Creates a validated [AgentFunctionTool].
  AgentFunctionTool({
    this.deferLoading,
    required this.description,
    required this.name,
    required Map<String, dynamic> parameters,
  }) : parameters = snapshotAgentJson(
         parameters,
         'AgentFunctionTool.parameters',
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

  /// Parses [AgentFunctionTool] with contextual, payload-free errors.
  factory AgentFunctionTool.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'defer_loading',
      'description',
      'name',
      'parameters',
      'type',
    ], 'AgentFunctionTool');
    requireAgentTag(json, 'type', 'function', 'AgentFunctionTool');
    return AgentFunctionTool(
      deferLoading: optionalAgentValue(
        json,
        'defer_loading',
        'AgentFunctionTool.deferLoading',
        requireAgentBool,
        nullable: false,
      ),
      description: requiredAgentValue(
        json,
        'description',
        'AgentFunctionTool.description',
        requireAgentString,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentFunctionTool.name',
        requireAgentString,
        nullable: false,
      )!,
      parameters: requiredAgentValue(
        json,
        'parameters',
        'AgentFunctionTool.parameters',
        requireAgentObject,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      description,
      'AgentFunctionTool.description',
      min: 0,
      max: 1048576,
    );
    validateAgentLength(name, 'AgentFunctionTool.name', min: 0, max: 1048576);
    validateAgentCount(
      parameters.length,
      'AgentFunctionTool.parameters',
      min: 0,
      max: 1024,
    );
    for (final key in parameters.keys) {
      validateAgentLength(
        key,
        'AgentFunctionTool.parameters',
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
  AgentFunctionTool copyWith({
    Object? deferLoading = unsetCopyWithValue,
    String? description,
    String? name,
    Map<String, dynamic>? parameters,
  }) => AgentFunctionTool(
    deferLoading: copyAgentValue<bool>(
      deferLoading,
      this.deferLoading,
      'AgentFunctionTool.deferLoading',
    ),
    description: description ?? this.description,
    name: name ?? this.name,
    parameters: parameters ?? this.parameters,
  );
}

/// Tools provided by a remote MCP server without stored credentials.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentMcpTool extends AgentTool {
  /// Creates a validated [AgentMcpTool].
  AgentMcpTool({
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
         (value) => snapshotAgentJson(value, 'AgentMcpTool.requestMetadata'),
       ) {
    validate();
  }

  /// The MCP tools the agent may call. All server tools are allowed when omitted.
  final List<String>? allowedTools;

  /// Sends `allowed_tools: null`, rather than omitting it.
  final bool clearAllowedTools;

  /// Selects where outbound MCP HTTP connections originate.
  final AgentMcpConnectionOriginParam? connectionOrigin;

  /// Sends `connection_origin: null`, rather than omitting it.
  final bool clearConnectionOrigin;

  /// The vault credential selected for this MCP server. Optional when exactly one attached credential matches the server URL.
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

  /// The credential-free transport used to connect to the MCP server.
  final AgentMcpTransport transport;

  /// The type of the object. Always `mcp`.
  @override
  String get type => 'mcp';

  /// Parses [AgentMcpTool] with contextual, payload-free errors.
  factory AgentMcpTool.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'allowed_tools',
      'connection_origin',
      'credential_id',
      'request_metadata',
      'required',
      'server_label',
      'transport',
      'type',
    ], 'AgentMcpTool');
    requireAgentTag(json, 'type', 'mcp', 'AgentMcpTool');
    return AgentMcpTool(
      allowedTools: optionalAgentValue(
        json,
        'allowed_tools',
        'AgentMcpTool.allowedTools',
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
        'AgentMcpTool.connectionOrigin',
        (value, context) => AgentMcpConnectionOriginParam.fromJson(value),
        nullable: true,
      ),
      clearConnectionOrigin:
          json.containsKey('connection_origin') &&
          json['connection_origin'] == null,
      credentialId: optionalAgentValue(
        json,
        'credential_id',
        'AgentMcpTool.credentialId',
        requireAgentString,
        nullable: true,
      ),
      clearCredentialId:
          json.containsKey('credential_id') && json['credential_id'] == null,
      requestMetadata: optionalAgentValue(
        json,
        'request_metadata',
        'AgentMcpTool.requestMetadata',
        requireAgentObject,
        nullable: true,
      ),
      clearRequestMetadata:
          json.containsKey('request_metadata') &&
          json['request_metadata'] == null,
      required: optionalAgentValue(
        json,
        'required',
        'AgentMcpTool.required',
        requireAgentBool,
        nullable: false,
      ),
      serverLabel: requiredAgentValue(
        json,
        'server_label',
        'AgentMcpTool.serverLabel',
        requireAgentString,
        nullable: false,
      )!,
      transport: requiredAgentValue(
        json,
        'transport',
        'AgentMcpTool.transport',
        (value, context) =>
            AgentMcpTransport.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    if (allowedTools != null) {
      validateAgentCount(
        allowedTools!.length,
        'AgentMcpTool.allowedTools',
        min: 0,
        max: 16384,
      );
      for (final item in allowedTools!) {
        validateAgentLength(
          item,
          'AgentMcpTool.allowedTools',
          min: 0,
          max: 1048576,
        );
      }
    }
    if (connectionOrigin != null) {
      validateAgentEnum(connectionOrigin!.value, [
        'service',
        'environment',
      ], 'AgentMcpTool.connectionOrigin');
    }
    if (credentialId != null) {
      validateAgentLength(
        credentialId!,
        'AgentMcpTool.credentialId',
        min: 0,
        max: 1048576,
      );
    }
    if (requestMetadata != null) {
      validateAgentCount(
        requestMetadata!.length,
        'AgentMcpTool.requestMetadata',
        min: 0,
        max: 1024,
      );
      for (final key in requestMetadata!.keys) {
        validateAgentLength(
          key,
          'AgentMcpTool.requestMetadata',
          min: 1,
          max: 256,
        );
      }
    }
    validateAgentLength(
      serverLabel,
      'AgentMcpTool.serverLabel',
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
  AgentMcpTool copyWith({
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
    AgentMcpTransport? transport,
  }) => AgentMcpTool(
    allowedTools: copyAgentValue<List<String>>(
      allowedTools,
      this.allowedTools,
      'AgentMcpTool.allowedTools',
    ),
    clearAllowedTools:
        clearAllowedTools ??
        (identical(allowedTools, unsetCopyWithValue)
            ? this.clearAllowedTools
            : allowedTools == null),
    connectionOrigin: copyAgentValue<AgentMcpConnectionOriginParam>(
      connectionOrigin,
      this.connectionOrigin,
      'AgentMcpTool.connectionOrigin',
    ),
    clearConnectionOrigin:
        clearConnectionOrigin ??
        (identical(connectionOrigin, unsetCopyWithValue)
            ? this.clearConnectionOrigin
            : connectionOrigin == null),
    credentialId: copyAgentValue<String>(
      credentialId,
      this.credentialId,
      'AgentMcpTool.credentialId',
    ),
    clearCredentialId:
        clearCredentialId ??
        (identical(credentialId, unsetCopyWithValue)
            ? this.clearCredentialId
            : credentialId == null),
    requestMetadata: copyAgentValue<Map<String, dynamic>>(
      requestMetadata,
      this.requestMetadata,
      'AgentMcpTool.requestMetadata',
    ),
    clearRequestMetadata:
        clearRequestMetadata ??
        (identical(requestMetadata, unsetCopyWithValue)
            ? this.clearRequestMetadata
            : requestMetadata == null),
    required: copyAgentValue<bool>(
      required,
      this.required,
      'AgentMcpTool.required',
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
final class AgentProgrammaticToolCallingTool extends AgentTool {
  /// Creates a validated [AgentProgrammaticToolCallingTool].
  AgentProgrammaticToolCallingTool({this.enabled}) {
    validate();
  }

  /// Whether tools can be called from model-generated code. Defaults to `true`.
  final bool? enabled;

  /// The type of the object. Always `programmatic_tool_calling`.
  @override
  String get type => 'programmatic_tool_calling';

  /// Parses [AgentProgrammaticToolCallingTool] with contextual, payload-free errors.
  factory AgentProgrammaticToolCallingTool.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'enabled',
      'type',
    ], 'AgentProgrammaticToolCallingTool');
    requireAgentTag(
      json,
      'type',
      'programmatic_tool_calling',
      'AgentProgrammaticToolCallingTool',
    );
    return AgentProgrammaticToolCallingTool(
      enabled: optionalAgentValue(
        json,
        'enabled',
        'AgentProgrammaticToolCallingTool.enabled',
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
  AgentProgrammaticToolCallingTool copyWith({
    Object? enabled = unsetCopyWithValue,
  }) => AgentProgrammaticToolCallingTool(
    enabled: copyAgentValue<bool>(
      enabled,
      this.enabled,
      'AgentProgrammaticToolCallingTool.enabled',
    ),
  );
}

/// Discovers deferred function tools and loads them into the model context.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentToolSearchTool extends AgentTool {
  /// Creates a validated [AgentToolSearchTool].
  const AgentToolSearchTool();

  /// The type of the object. Always `tool_search`.
  @override
  String get type => 'tool_search';

  /// Parses [AgentToolSearchTool] with contextual, payload-free errors.
  factory AgentToolSearchTool.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const ['type'], 'AgentToolSearchTool');
    requireAgentTag(json, 'type', 'tool_search', 'AgentToolSearchTool');
    return const AgentToolSearchTool();
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentToolSearchTool copyWith() => const AgentToolSearchTool();
}

/// Web search.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentWebSearchTool extends AgentTool {
  /// Creates a validated [AgentWebSearchTool].
  AgentWebSearchTool({
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

  /// Parses [AgentWebSearchTool] with contextual, payload-free errors.
  factory AgentWebSearchTool.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'allowed_domains',
      'context_size',
      'location',
      'mode',
      'type',
    ], 'AgentWebSearchTool');
    requireAgentTag(json, 'type', 'web_search', 'AgentWebSearchTool');
    return AgentWebSearchTool(
      allowedDomains: optionalAgentValue(
        json,
        'allowed_domains',
        'AgentWebSearchTool.allowedDomains',
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
        'AgentWebSearchTool.contextSize',
        (value, context) => AgentWebSearchContextSizeParam.fromJson(value),
        nullable: true,
      ),
      clearContextSize:
          json.containsKey('context_size') && json['context_size'] == null,
      location: optionalAgentValue(
        json,
        'location',
        'AgentWebSearchTool.location',
        (value, context) =>
            AgentWebSearchLocation.fromJson(requireAgentObject(value, context)),
        nullable: true,
      ),
      clearLocation: json.containsKey('location') && json['location'] == null,
      mode: optionalAgentValue(
        json,
        'mode',
        'AgentWebSearchTool.mode',
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
        'AgentWebSearchTool.allowedDomains',
        min: 0,
        max: 16384,
      );
      for (final item in allowedDomains!) {
        validateAgentLength(
          item,
          'AgentWebSearchTool.allowedDomains',
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
      ], 'AgentWebSearchTool.contextSize');
    }
    if (location != null) {
      location!.validate();
    }
    if (mode != null) {
      validateAgentEnum(mode!.value, [
        'disabled',
        'cached',
        'live',
      ], 'AgentWebSearchTool.mode');
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
  AgentWebSearchTool copyWith({
    Object? allowedDomains = unsetCopyWithValue,
    bool? clearAllowedDomains,
    Object? contextSize = unsetCopyWithValue,
    bool? clearContextSize,
    Object? location = unsetCopyWithValue,
    bool? clearLocation,
    Object? mode = unsetCopyWithValue,
    bool? clearMode,
  }) => AgentWebSearchTool(
    allowedDomains: copyAgentValue<List<String>>(
      allowedDomains,
      this.allowedDomains,
      'AgentWebSearchTool.allowedDomains',
    ),
    clearAllowedDomains:
        clearAllowedDomains ??
        (identical(allowedDomains, unsetCopyWithValue)
            ? this.clearAllowedDomains
            : allowedDomains == null),
    contextSize: copyAgentValue<AgentWebSearchContextSizeParam>(
      contextSize,
      this.contextSize,
      'AgentWebSearchTool.contextSize',
    ),
    clearContextSize:
        clearContextSize ??
        (identical(contextSize, unsetCopyWithValue)
            ? this.clearContextSize
            : contextSize == null),
    location: copyAgentValue<AgentWebSearchLocation>(
      location,
      this.location,
      'AgentWebSearchTool.location',
    ),
    clearLocation:
        clearLocation ??
        (identical(location, unsetCopyWithValue)
            ? this.clearLocation
            : location == null),
    mode: copyAgentValue<AgentWebSearchModeParam>(
      mode,
      this.mode,
      'AgentWebSearchTool.mode',
    ),
    clearMode:
        clearMode ??
        (identical(mode, unsetCopyWithValue) ? this.clearMode : mode == null),
  );
}

/// A credential-free tool available to a reusable agent.
///
/// Variants: [AgentComputerUseToolResource], [AgentFunctionToolResource], [AgentMcpToolResource], [AgentProgrammaticToolCallingToolResource], [AgentToolSearchToolResource], [AgentWebSearchToolResource] and [UnknownAgentToolResource].
sealed class AgentToolResource extends AgentJsonModel {
  const AgentToolResource();

  /// Parses known variants strictly and retains future received variants.
  factory AgentToolResource.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(json['type'], 'AgentToolResource.type')) {
        'computer_use' => AgentComputerUseToolResource.fromJson(json),
        'function' => AgentFunctionToolResource.fromJson(json),
        'mcp' => AgentMcpToolResource.fromJson(json),
        'programmatic_tool_calling' =>
          AgentProgrammaticToolCallingToolResource.fromJson(json),
        'tool_search' => AgentToolSearchToolResource.fromJson(json),
        'web_search' => AgentWebSearchToolResource.fromJson(json),
        _ => UnknownAgentToolResource.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `computer_use` variant.
  factory AgentToolResource.computerUse({
    required bool includeScreenshots,
    Map<String, dynamic> rawJson,
  }) = AgentComputerUseToolResource;

  /// Creates the `function` variant.
  factory AgentToolResource.function({
    required bool deferLoading,
    required String description,
    required String name,
    required Map<String, dynamic> parameters,
    Map<String, dynamic> rawJson,
  }) = AgentFunctionToolResource;

  /// Creates the `mcp` variant.
  factory AgentToolResource.mcp({
    required List<String>? allowedTools,
    required AgentMcpConnectionOriginResource connectionOrigin,
    required String? credentialId,
    required Map<String, dynamic> requestMetadata,
    required bool required,
    required String serverLabel,
    required AgentMcpTransportResource transport,
    Map<String, dynamic> rawJson,
  }) = AgentMcpToolResource;

  /// Creates the `programmatic_tool_calling` variant.
  factory AgentToolResource.programmaticToolCalling({
    required bool enabled,
    Map<String, dynamic> rawJson,
  }) = AgentProgrammaticToolCallingToolResource;

  /// Creates the `tool_search` variant.
  factory AgentToolResource.toolSearch({Map<String, dynamic> rawJson}) =
      AgentToolSearchToolResource;

  /// Creates the `web_search` variant.
  factory AgentToolResource.webSearch({
    required List<String>? allowedDomains,
    required AgentWebSearchContextSizeResource contextSize,
    required AgentWebSearchLocationResource? location,
    required AgentWebSearchModeResource mode,
    Map<String, dynamic> rawJson,
  }) = AgentWebSearchToolResource;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownAgentToolResource extends AgentToolResource {
  const UnknownAgentToolResource._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownAgentToolResource.fromJson(Map<String, dynamic> json) {
    final type = requireAgentString(
      json['type'],
      'UnknownAgentToolResource.type',
    );
    if (const [
      'computer_use',
      'function',
      'mcp',
      'programmatic_tool_calling',
      'tool_search',
      'web_search',
    ].contains(type)) {
      throw const FormatException(
        'UnknownAgentToolResource: expected a future type',
      );
    }
    return UnknownAgentToolResource._(
      snapshotAgentJson(json, 'UnknownAgentToolResource'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownAgentToolResource copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentToolResource.fromJson(rawJson ?? this.rawJson);
}

/// Browser use in an OpenAI-hosted session.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentComputerUseToolResource extends AgentToolResource {
  /// Creates a validated [AgentComputerUseToolResource].
  AgentComputerUseToolResource({
    required this.includeScreenshots,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'include_screenshots',
         'type',
       ], 'AgentComputerUseToolResource') {
    validate();
  }

  /// Whether computer tool outputs include screenshots.
  final bool includeScreenshots;

  /// The type of the object. Always `computer_use`.
  @override
  String get type => 'computer_use';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentComputerUseToolResource] with contextual, payload-free errors.
  factory AgentComputerUseToolResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'type',
      'computer_use',
      'AgentComputerUseToolResource',
    );
    return AgentComputerUseToolResource(
      includeScreenshots: requiredAgentValue(
        json,
        'include_screenshots',
        'AgentComputerUseToolResource.includeScreenshots',
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
  AgentComputerUseToolResource copyWith({
    bool? includeScreenshots,
    Map<String, dynamic>? rawJson,
  }) => AgentComputerUseToolResource(
    includeScreenshots: includeScreenshots ?? this.includeScreenshots,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A function defined by the application.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentFunctionToolResource extends AgentToolResource {
  /// Creates a validated [AgentFunctionToolResource].
  AgentFunctionToolResource({
    required this.deferLoading,
    required this.description,
    required this.name,
    required Map<String, dynamic> parameters,
    Map<String, dynamic> rawJson = const {},
  }) : parameters = snapshotAgentJson(
         parameters,
         'AgentFunctionToolResource.parameters',
       ),
       rawJson = agentExtras(rawJson, const [
         'defer_loading',
         'description',
         'name',
         'parameters',
         'type',
       ], 'AgentFunctionToolResource') {
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

  /// Parses [AgentFunctionToolResource] with contextual, payload-free errors.
  factory AgentFunctionToolResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'function', 'AgentFunctionToolResource');
    return AgentFunctionToolResource(
      deferLoading: requiredAgentValue(
        json,
        'defer_loading',
        'AgentFunctionToolResource.deferLoading',
        requireAgentBool,
        nullable: false,
      )!,
      description: requiredAgentValue(
        json,
        'description',
        'AgentFunctionToolResource.description',
        requireAgentString,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'AgentFunctionToolResource.name',
        requireAgentString,
        nullable: false,
      )!,
      parameters: requiredAgentValue(
        json,
        'parameters',
        'AgentFunctionToolResource.parameters',
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
      'AgentFunctionToolResource.description',
      min: 0,
    );
    validateAgentLength(name, 'AgentFunctionToolResource.name', min: 0);
    validateAgentCount(
      parameters.length,
      'AgentFunctionToolResource.parameters',
      min: 0,
    );
    for (final key in parameters.keys) {
      validateAgentLength(key, 'AgentFunctionToolResource.parameters', min: 0);
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
  AgentFunctionToolResource copyWith({
    bool? deferLoading,
    String? description,
    String? name,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? rawJson,
  }) => AgentFunctionToolResource(
    deferLoading: deferLoading ?? this.deferLoading,
    description: description ?? this.description,
    name: name ?? this.name,
    parameters: parameters ?? this.parameters,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Tools provided by a remote MCP server without stored credentials.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentMcpToolResource extends AgentToolResource {
  /// Creates a validated [AgentMcpToolResource].
  AgentMcpToolResource({
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
         'AgentMcpToolResource.requestMetadata',
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
       ], 'AgentMcpToolResource') {
    validate();
  }

  /// The MCP tools the agent may call, or null when all server tools are allowed.
  final List<String>? allowedTools;

  /// Where outbound MCP HTTP connections originate.
  final AgentMcpConnectionOriginResource connectionOrigin;

  /// The vault credential selected for this MCP server, if any.
  final String? credentialId;

  /// Metadata included with requests to this MCP server.
  final Map<String, dynamic> requestMetadata;

  /// Whether this MCP server must initialize before the first turn.
  final bool required;

  /// A label used to identify the MCP server in tool calls.
  final String serverLabel;

  /// The credential-free transport used to connect to the MCP server.
  final AgentMcpTransportResource transport;

  /// The type of the object. Always `mcp`.
  @override
  String get type => 'mcp';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentMcpToolResource] with contextual, payload-free errors.
  factory AgentMcpToolResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'mcp', 'AgentMcpToolResource');
    return AgentMcpToolResource(
      allowedTools: requiredAgentValue(
        json,
        'allowed_tools',
        'AgentMcpToolResource.allowedTools',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      connectionOrigin: requiredAgentValue(
        json,
        'connection_origin',
        'AgentMcpToolResource.connectionOrigin',
        (value, context) => AgentMcpConnectionOriginResource.fromJson(value),
        nullable: false,
      )!,
      credentialId: requiredAgentValue(
        json,
        'credential_id',
        'AgentMcpToolResource.credentialId',
        requireAgentString,
        nullable: true,
      ),
      requestMetadata: requiredAgentValue(
        json,
        'request_metadata',
        'AgentMcpToolResource.requestMetadata',
        requireAgentObject,
        nullable: false,
      )!,
      required: requiredAgentValue(
        json,
        'required',
        'AgentMcpToolResource.required',
        requireAgentBool,
        nullable: false,
      )!,
      serverLabel: requiredAgentValue(
        json,
        'server_label',
        'AgentMcpToolResource.serverLabel',
        requireAgentString,
        nullable: false,
      )!,
      transport: requiredAgentValue(
        json,
        'transport',
        'AgentMcpToolResource.transport',
        (value, context) => AgentMcpTransportResource.fromJson(
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
        'AgentMcpToolResource.allowedTools',
        min: 0,
        max: 2000,
      );
      for (final item in allowedTools!) {
        validateAgentLength(item, 'AgentMcpToolResource.allowedTools', min: 0);
      }
    }
    if (credentialId != null) {
      validateAgentLength(
        credentialId!,
        'AgentMcpToolResource.credentialId',
        min: 0,
      );
    }
    validateAgentCount(
      requestMetadata.length,
      'AgentMcpToolResource.requestMetadata',
      min: 0,
    );
    for (final key in requestMetadata.keys) {
      validateAgentLength(key, 'AgentMcpToolResource.requestMetadata', min: 0);
    }
    validateAgentLength(
      serverLabel,
      'AgentMcpToolResource.serverLabel',
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
  AgentMcpToolResource copyWith({
    Object? allowedTools = unsetCopyWithValue,
    AgentMcpConnectionOriginResource? connectionOrigin,
    Object? credentialId = unsetCopyWithValue,
    Map<String, dynamic>? requestMetadata,
    bool? required,
    String? serverLabel,
    AgentMcpTransportResource? transport,
    Map<String, dynamic>? rawJson,
  }) => AgentMcpToolResource(
    allowedTools: copyAgentValue<List<String>>(
      allowedTools,
      this.allowedTools,
      'AgentMcpToolResource.allowedTools',
    ),
    connectionOrigin: connectionOrigin ?? this.connectionOrigin,
    credentialId: copyAgentValue<String>(
      credentialId,
      this.credentialId,
      'AgentMcpToolResource.credentialId',
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
final class AgentProgrammaticToolCallingToolResource extends AgentToolResource {
  /// Creates a validated [AgentProgrammaticToolCallingToolResource].
  AgentProgrammaticToolCallingToolResource({
    required this.enabled,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'enabled',
         'type',
       ], 'AgentProgrammaticToolCallingToolResource') {
    validate();
  }

  /// Whether tools can be called from model-generated code.
  final bool enabled;

  /// The type of the object. Always `programmatic_tool_calling`.
  @override
  String get type => 'programmatic_tool_calling';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentProgrammaticToolCallingToolResource] with contextual, payload-free errors.
  factory AgentProgrammaticToolCallingToolResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'programmatic_tool_calling',
      'AgentProgrammaticToolCallingToolResource',
    );
    return AgentProgrammaticToolCallingToolResource(
      enabled: requiredAgentValue(
        json,
        'enabled',
        'AgentProgrammaticToolCallingToolResource.enabled',
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
  AgentProgrammaticToolCallingToolResource copyWith({
    bool? enabled,
    Map<String, dynamic>? rawJson,
  }) => AgentProgrammaticToolCallingToolResource(
    enabled: enabled ?? this.enabled,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Discovers deferred function tools and loads them into the model context.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentToolSearchToolResource extends AgentToolResource {
  /// Creates a validated [AgentToolSearchToolResource].
  AgentToolSearchToolResource({Map<String, dynamic> rawJson = const {}})
    : rawJson = agentExtras(rawJson, const [
        'type',
      ], 'AgentToolSearchToolResource') {
    validate();
  }

  /// The type of the object. Always `tool_search`.
  @override
  String get type => 'tool_search';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentToolSearchToolResource] with contextual, payload-free errors.
  factory AgentToolSearchToolResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'tool_search', 'AgentToolSearchToolResource');
    return AgentToolSearchToolResource(
      rawJson: {
        for (final entry in json.entries)
          if (!const ['type'].contains(entry.key)) entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentToolSearchToolResource copyWith({Map<String, dynamic>? rawJson}) =>
      AgentToolSearchToolResource(rawJson: rawJson ?? this.rawJson);
}

/// Web search.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentWebSearchToolResource extends AgentToolResource {
  /// Creates a validated [AgentWebSearchToolResource].
  AgentWebSearchToolResource({
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
       ], 'AgentWebSearchToolResource') {
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

  /// Parses [AgentWebSearchToolResource] with contextual, payload-free errors.
  factory AgentWebSearchToolResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'web_search', 'AgentWebSearchToolResource');
    return AgentWebSearchToolResource(
      allowedDomains: requiredAgentValue(
        json,
        'allowed_domains',
        'AgentWebSearchToolResource.allowedDomains',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: true,
      ),
      contextSize: requiredAgentValue(
        json,
        'context_size',
        'AgentWebSearchToolResource.contextSize',
        (value, context) => AgentWebSearchContextSizeResource.fromJson(value),
        nullable: false,
      )!,
      location: requiredAgentValue(
        json,
        'location',
        'AgentWebSearchToolResource.location',
        (value, context) => AgentWebSearchLocationResource.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: true,
      ),
      mode: requiredAgentValue(
        json,
        'mode',
        'AgentWebSearchToolResource.mode',
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
        'AgentWebSearchToolResource.allowedDomains',
        min: 0,
        max: 2000,
      );
      for (final item in allowedDomains!) {
        validateAgentLength(
          item,
          'AgentWebSearchToolResource.allowedDomains',
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
  AgentWebSearchToolResource copyWith({
    Object? allowedDomains = unsetCopyWithValue,
    AgentWebSearchContextSizeResource? contextSize,
    Object? location = unsetCopyWithValue,
    AgentWebSearchModeResource? mode,
    Map<String, dynamic>? rawJson,
  }) => AgentWebSearchToolResource(
    allowedDomains: copyAgentValue<List<String>>(
      allowedDomains,
      this.allowedDomains,
      'AgentWebSearchToolResource.allowedDomains',
    ),
    contextSize: contextSize ?? this.contextSize,
    location: copyAgentValue<AgentWebSearchLocationResource>(
      location,
      this.location,
      'AgentWebSearchToolResource.location',
    ),
    mode: mode ?? this.mode,
    rawJson: rawJson ?? this.rawJson,
  );
}
