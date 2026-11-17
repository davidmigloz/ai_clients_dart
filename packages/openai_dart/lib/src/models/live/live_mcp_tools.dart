part of 'live_tools.dart';

/// Contexts allowed to invoke a delegated Live tool.
enum LiveCallableToolAllowedCaller {
  /// Tools called directly by the Responses backend.
  direct,

  /// Tools called from a programmatic tool invocation.
  programmatic;

  /// Parses the caller without echoing unsupported values.
  factory LiveCallableToolAllowedCaller.fromJson(String value) =>
      values.firstWhere(
        (caller) => caller.name == value,
        orElse: () =>
            throw const FormatException('Unsupported Live tool caller'),
      );

  /// Returns the wire value.
  String toJson() => name;
}

/// A list of tool names or an object filter limiting which MCP tools are used.
sealed class LiveMCPAllowedTools extends LiveJsonModel {
  const LiveMCPAllowedTools();

  /// Creates a list of explicitly allowed MCP tools.
  factory LiveMCPAllowedTools.names(Iterable<String> names) = LiveMCPToolNames;

  /// Parses either canonical representation.
  factory LiveMCPAllowedTools.fromJson(Object? json) => switch (json) {
    final List<dynamic> names => LiveMCPToolNames([
      for (final value in names)
        requireLiveString(value, 'LiveMCPAllowedTools.name'),
    ]),
    _ => LiveMCPToolFilter.fromJson(
      requireLiveObject(json, 'LiveMCPAllowedTools'),
    ),
  };
}

/// An explicit list of allowed tool names.
final class LiveMCPToolNames extends LiveMCPAllowedTools {
  /// Captures an immutable list of tool names.
  LiveMCPToolNames(Iterable<String> names) : names = List.unmodifiable(names);

  /// Allowed MCP tool names.
  final List<String> names;

  @override
  List<String> toJson() => names;
}

/// Selects MCP tools by name and read-only annotation.
final class LiveMCPToolFilter extends LiveMCPAllowedTools {
  /// Creates a tool filter. Null or unset fields are omitted unless supplied
  /// explicitly in [rawJson].
  LiveMCPToolFilter({
    List<String>? toolNames,
    bool? readOnly,
    Map<String, dynamic> rawJson = const {},
  }) : this._(
         snapshotLiveJson({
           ...rawJson,
           'tool_names': ?toolNames,
           'read_only': ?readOnly,
         }, 'LiveMCPToolFilter'),
       );

  LiveMCPToolFilter._(this.rawJson)
    : toolNames = optionalLiveValue(
        rawJson,
        'tool_names',
        'LiveMCPToolFilter',
        (value, context) => List.unmodifiable(
          requireLiveList(
            value,
            context,
          ).map((name) => requireLiveString(name, context)),
        ),
        nullable: true,
      ),
      readOnly = optionalLiveValue(
        rawJson,
        'read_only',
        'LiveMCPToolFilter',
        requireLiveBool,
        nullable: true,
      );

  /// Parses and preserves nullable fields and future metadata.
  factory LiveMCPToolFilter.fromJson(Map<String, dynamic> json) =>
      LiveMCPToolFilter(rawJson: json);

  /// Tool names that match the filter, if configured.
  final List<String>? toolNames;

  /// Whether the filter matches read-only MCP tools.
  final bool? readOnly;

  /// Immutable wire values, including future metadata.
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() => rawJson;
}

/// Scalar default approval behavior or a pair of selective approval filters.
sealed class LiveMCPApproval extends LiveJsonModel {
  const LiveMCPApproval();

  /// Require explicit approval for every call.
  static const always = LiveMCPApprovalMode._('always');

  /// Allow every call without an explicit MCP approval.
  static const never = LiveMCPApprovalMode._('never');

  /// Parses a scalar or filter without inventing default approval.
  factory LiveMCPApproval.fromJson(Object? json) => switch (json) {
    'always' => always,
    'never' => never,
    String() => throw const FormatException(
      'Unsupported Live MCP approval mode',
    ),
    _ => LiveMCPApprovalFilter.fromJson(
      requireLiveObject(json, 'LiveMCPApproval'),
    ),
  };
}

/// A scalar approval policy.
final class LiveMCPApprovalMode extends LiveMCPApproval {
  const LiveMCPApprovalMode._(this.value);

  /// Canonical approval policy.
  final String value;

  @override
  String toJson() => value;
}

/// Tool filters for always and never requiring approval.
final class LiveMCPApprovalFilter extends LiveMCPApproval {
  /// Creates independent filters for mandatory approval and approval bypass.
  LiveMCPApprovalFilter({
    LiveMCPToolFilter? always,
    LiveMCPToolFilter? never,
    Map<String, dynamic> rawJson = const {},
  }) : this._(
         snapshotLiveJson({
           ...rawJson,
           if (always != null) 'always': always.toJson(),
           if (never != null) 'never': never.toJson(),
         }, 'LiveMCPApprovalFilter'),
       );

  LiveMCPApprovalFilter._(this.rawJson)
    : always = _filter(rawJson, 'always'),
      never = _filter(rawJson, 'never');

  /// Parses and preserves nullable policies and future metadata.
  factory LiveMCPApprovalFilter.fromJson(Map<String, dynamic> json) =>
      LiveMCPApprovalFilter(rawJson: json);

  /// Tools for which approval must be requested.
  final LiveMCPToolFilter? always;

  /// Tools for which approval may be skipped.
  final LiveMCPToolFilter? never;

  /// Immutable wire values, including future metadata.
  final Map<String, dynamic> rawJson;

  static LiveMCPToolFilter? _filter(Map<String, dynamic> rawJson, String key) =>
      optionalLiveValue(
        rawJson,
        key,
        'LiveMCPApprovalFilter',
        (value, context) =>
            LiveMCPToolFilter.fromJson(requireLiveObject(value, context)),
        nullable: true,
      );

  @override
  Map<String, dynamic> toJson() => rawJson;
}

/// MCP server configuration for a Responses-backed Live delegation.
final class LiveMCPTool extends LiveTool {
  /// Creates the request configuration. Non-null typed arguments override the
  /// corresponding raw keys. Explicit null fields can be supplied in [rawJson].
  LiveMCPTool({
    String? serverLabel,
    String? serverUrl,
    String? serverDescription,
    String? authorization,
    Map<String, String>? headers,
    LiveMCPAllowedTools? allowedTools,
    LiveMCPApproval? requireApproval,
    String? connectorId,
    String? tunnelId,
    List<LiveCallableToolAllowedCaller>? allowedCallers,
    bool? deferLoading,
    Map<String, dynamic> rawJson = const {},
  }) : this._(
         snapshotLiveJson({
           ...rawJson,
           'server_label': ?serverLabel,
           'server_url': ?serverUrl,
           'server_description': ?serverDescription,
           'authorization': ?authorization,
           'headers': ?headers,
           if (allowedTools != null) 'allowed_tools': allowedTools.toJson(),
           if (requireApproval != null)
             'require_approval': requireApproval.toJson(),
           'connector_id': ?connectorId,
           'tunnel_id': ?tunnelId,
           if (allowedCallers != null)
             'allowed_callers': allowedCallers
                 .map((caller) => caller.toJson())
                 .toList(),
           'defer_loading': ?deferLoading,
         }, 'LiveMCPTool'),
       );

  LiveMCPTool._(this.rawJson)
    : serverLabel = _string(rawJson, 'server_label', nullable: false),
      serverUrl = _string(rawJson, 'server_url'),
      serverDescription = _string(rawJson, 'server_description'),
      authorization = _string(rawJson, 'authorization'),
      headers = optionalLiveValue(
        rawJson,
        'headers',
        'LiveMCPTool',
        (value, context) => Map.unmodifiable({
          for (final entry in requireLiveObject(value, context).entries)
            entry.key: requireLiveString(entry.value, context),
        }),
        nullable: true,
      ),
      allowedTools = optionalLiveValue(
        rawJson,
        'allowed_tools',
        'LiveMCPTool',
        (value, _) => LiveMCPAllowedTools.fromJson(value),
        nullable: true,
      ),
      requireApproval = optionalLiveValue(
        rawJson,
        'require_approval',
        'LiveMCPTool',
        (value, _) => LiveMCPApproval.fromJson(value),
        nullable: true,
      ),
      connectorId = _string(rawJson, 'connector_id'),
      tunnelId = _string(rawJson, 'tunnel_id'),
      allowedCallers = optionalLiveValue(
        rawJson,
        'allowed_callers',
        'LiveMCPTool',
        (value, context) => List.unmodifiable([
          for (final caller in requireLiveList(value, context))
            LiveCallableToolAllowedCaller.fromJson(
              requireLiveString(caller, context),
            ),
        ]),
        nullable: true,
      ),
      deferLoading = optionalLiveValue(
        rawJson,
        'defer_loading',
        'LiveMCPTool',
        requireLiveBool,
        nullable: true,
      ) {
    validate();
  }

  /// Parses declared fields and snapshots any additional request metadata.
  factory LiveMCPTool.fromJson(Map<String, dynamic> json) {
    requireLiveType(json, 'mcp', 'LiveMCPTool');
    return LiveMCPTool(rawJson: json);
  }

  @override
  String get type => 'mcp';

  /// Label used to identify the server in tool calls and tool choices.
  final String? serverLabel;

  /// Remote MCP server URI.
  final String? serverUrl;

  /// Optional human-readable description of the server.
  final String? serverDescription;

  /// Write-only token for connecting to the server or connector.
  final String? authorization;

  /// Write-only HTTP headers for connecting to the server or connector.
  final Map<String, String>? headers;

  /// List or filter of allowed tools for this server.
  final LiveMCPAllowedTools? allowedTools;

  /// Specifies which tools require explicit user approval.
  final LiveMCPApproval? requireApproval;

  /// Legacy connector ID. Newer models use [serverUrl] or [tunnelId].
  final String? connectorId;

  /// Secure MCP Tunnel identifier.
  final String? tunnelId;

  /// Invocation contexts that can call tools from this server.
  final List<LiveCallableToolAllowedCaller>? allowedCallers;

  /// Whether the tool should be deferred and discovered through tool search.
  final bool? deferLoading;

  /// Immutable wire values. Request contents can contain private credentials.
  @override
  final Map<String, dynamic> rawJson;

  static String? _string(
    Map<String, dynamic> rawJson,
    String key, {
    bool nullable = true,
  }) => optionalLiveValue(
    rawJson,
    key,
    'LiveMCPTool',
    requireLiveString,
    nullable: nullable,
  );

  @override
  void validate() {
    if (serverLabel case final value?) {
      validateLiveLength(value, 'LiveMCPTool.server_label', max: 128);
      if (!RegExp(r'^[A-Za-z][A-Za-z0-9_-]*$').hasMatch(value)) {
        throw const FormatException('LiveMCPTool.server_label: invalid label');
      }
    }
    if (serverUrl case final value?) {
      if (Uri.tryParse(value)?.hasScheme != true) {
        throw const FormatException(
          'LiveMCPTool.server_url: expected an absolute URI',
        );
      }
    }
    if (tunnelId case final value?) {
      if (!RegExp(r'^tunnel_[a-z0-9]{32}$').hasMatch(value)) {
        throw const FormatException('LiveMCPTool.tunnel_id: invalid tunnel ID');
      }
    }
    if (allowedCallers?.isEmpty == true) {
      throw const FormatException(
        'LiveMCPTool.allowed_callers: expected at least one caller',
      );
    }
    allowedTools?.validate();
    requireApproval?.validate();
  }

  /// Copies the tool, with typed fields overlaying supplied raw data.
  ///
  /// Omitting [authorization] and [headers] retains the corresponding values.
  /// Pass explicit null to remove either credential field from the request.
  LiveMCPTool copyWith({
    String? serverLabel,
    String? serverUrl,
    String? serverDescription,
    Object? authorization = liveUnset,
    Object? headers = liveUnset,
    LiveMCPAllowedTools? allowedTools,
    LiveMCPApproval? requireApproval,
    String? connectorId,
    String? tunnelId,
    List<LiveCallableToolAllowedCaller>? allowedCallers,
    bool? deferLoading,
    Map<String, dynamic>? rawJson,
  }) {
    final retained = {...(rawJson ?? this.rawJson)};
    if (authorization == null) retained.remove('authorization');
    if (headers == null) retained.remove('headers');
    return LiveMCPTool(
      serverLabel: serverLabel,
      serverUrl: serverUrl,
      serverDescription: serverDescription,
      authorization: copyLiveValue<String>(
        authorization,
        null,
        'LiveMCPTool.authorization',
      ),
      headers: copyLiveValue<Map<String, String>>(
        headers,
        null,
        'LiveMCPTool.headers',
      ),
      allowedTools: allowedTools,
      requireApproval: requireApproval,
      connectorId: connectorId,
      tunnelId: tunnelId,
      allowedCallers: allowedCallers,
      deferLoading: deferLoading,
      rawJson: retained,
    );
  }

  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};
}
