import '../common/copy_with_sentinel.dart';
import 'agent_json_helpers.dart';

/// A credential-free transport used to connect to an MCP server.
///
/// Variants: [AgentMcpHttpTransport], [AgentMcpStdioTransport] and [UnknownAgentMcpTransport].
sealed class AgentMcpTransport extends AgentJsonModel {
  const AgentMcpTransport();

  /// Parses known variants strictly and retains future received variants.
  factory AgentMcpTransport.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(json['type'], 'AgentMcpTransport.type')) {
        'http' => AgentMcpHttpTransport.fromJson(json),
        'stdio' => AgentMcpStdioTransport.fromJson(json),
        _ => UnknownAgentMcpTransport.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `http` variant.
  factory AgentMcpTransport.http({
    Map<String, String>? headers,
    bool clearHeaders,
    required String serverUrl,
  }) = AgentMcpHttpTransport;

  /// Creates the `stdio` variant.
  factory AgentMcpTransport.stdio({
    List<String>? args,
    bool clearArgs,
    required String command,
    required String cwd,
    List<String>? envVars,
    bool clearEnvVars,
  }) = AgentMcpStdioTransport;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownAgentMcpTransport extends AgentMcpTransport {
  const UnknownAgentMcpTransport._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownAgentMcpTransport.fromJson(Map<String, dynamic> json) {
    final type = requireAgentString(
      json['type'],
      'UnknownAgentMcpTransport.type',
    );
    if (const ['http', 'stdio'].contains(type)) {
      throw const FormatException(
        'UnknownAgentMcpTransport: expected a future type',
      );
    }
    return UnknownAgentMcpTransport._(
      snapshotAgentJson(json, 'UnknownAgentMcpTransport'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownAgentMcpTransport copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentMcpTransport.fromJson(rawJson ?? this.rawJson);

  @override
  void validate() => throw const FormatException(
    'UnknownAgentMcpTransport: future tools/transports are not writable',
  );
}

/// Connects to an MCP server over HTTP.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentMcpHttpTransport extends AgentMcpTransport {
  /// Creates a validated [AgentMcpHttpTransport].
  AgentMcpHttpTransport({
    Map<String, String>? headers,
    bool clearHeaders = false,
    required this.serverUrl,
  }) : clearHeaders = clearHeaders,
       headers = ownAgentValue<Map<String, String>>(
         clearHeaders ? null : headers,
         Map<String, String>.unmodifiable,
       ) {
    validate();
  }

  /// Non-secret HTTP headers sent to the MCP server.
  final Map<String, String>? headers;

  /// Sends `headers: null`, rather than omitting it.
  final bool clearHeaders;

  /// The URL of the MCP server.
  final String serverUrl;

  /// The type of the object. Always `http`.
  @override
  String get type => 'http';

  /// Parses [AgentMcpHttpTransport] with contextual, payload-free errors.
  factory AgentMcpHttpTransport.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'headers',
      'server_url',
      'type',
    ], 'AgentMcpHttpTransport');
    requireAgentTag(json, 'type', 'http', 'AgentMcpHttpTransport');
    return AgentMcpHttpTransport(
      headers: optionalAgentValue(
        json,
        'headers',
        'AgentMcpHttpTransport.headers',
        requireAgentStringMap,
        nullable: true,
      ),
      clearHeaders: json.containsKey('headers') && json['headers'] == null,
      serverUrl: requiredAgentValue(
        json,
        'server_url',
        'AgentMcpHttpTransport.serverUrl',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    if (headers != null) {
      validateAgentCount(
        headers!.length,
        'AgentMcpHttpTransport.headers',
        min: 0,
        max: 1024,
      );
      for (final key in headers!.keys) {
        validateAgentLength(
          key,
          'AgentMcpHttpTransport.headers',
          min: 1,
          max: 256,
        );
      }
      for (final item in headers!.values) {
        validateAgentLength(
          item,
          'AgentMcpHttpTransport.headers',
          min: 0,
          max: 1048576,
        );
      }
    }
    validateAgentLength(
      serverUrl,
      'AgentMcpHttpTransport.serverUrl',
      min: 0,
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearHeaders) 'headers': null else 'headers': ?headers,
    'server_url': serverUrl,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentMcpHttpTransport copyWith({
    Object? headers = unsetCopyWithValue,
    bool? clearHeaders,
    String? serverUrl,
  }) => AgentMcpHttpTransport(
    headers: copyAgentValue<Map<String, String>>(
      headers,
      this.headers,
      'AgentMcpHttpTransport.headers',
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
final class AgentMcpStdioTransport extends AgentMcpTransport {
  /// Creates a validated [AgentMcpStdioTransport].
  AgentMcpStdioTransport({
    List<String>? args,
    bool clearArgs = false,
    required this.command,
    required this.cwd,
    List<String>? envVars,
    bool clearEnvVars = false,
  }) : clearArgs = clearArgs,
       args = ownAgentValue<List<String>>(
         clearArgs ? null : args,
         List.unmodifiable,
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

  /// Environment variable names to inherit from the selected execution environment.
  final List<String>? envVars;

  /// Sends `env_vars: null`, rather than omitting it.
  final bool clearEnvVars;

  /// The type of the object. Always `stdio`.
  @override
  String get type => 'stdio';

  /// Parses [AgentMcpStdioTransport] with contextual, payload-free errors.
  factory AgentMcpStdioTransport.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'args',
      'command',
      'cwd',
      'env_vars',
      'type',
    ], 'AgentMcpStdioTransport');
    requireAgentTag(json, 'type', 'stdio', 'AgentMcpStdioTransport');
    return AgentMcpStdioTransport(
      args: optionalAgentValue(
        json,
        'args',
        'AgentMcpStdioTransport.args',
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
        'AgentMcpStdioTransport.command',
        requireAgentString,
        nullable: false,
      )!,
      cwd: requiredAgentValue(
        json,
        'cwd',
        'AgentMcpStdioTransport.cwd',
        requireAgentString,
        nullable: false,
      )!,
      envVars: optionalAgentValue(
        json,
        'env_vars',
        'AgentMcpStdioTransport.envVars',
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
        'AgentMcpStdioTransport.args',
        min: 0,
        max: 16384,
      );
      for (final item in args!) {
        validateAgentLength(
          item,
          'AgentMcpStdioTransport.args',
          min: 0,
          max: 1048576,
        );
      }
    }
    validateAgentLength(
      command,
      'AgentMcpStdioTransport.command',
      min: 0,
      max: 1048576,
    );
    validateAgentLength(
      cwd,
      'AgentMcpStdioTransport.cwd',
      min: 0,
      max: 1048576,
    );
    if (envVars != null) {
      validateAgentCount(
        envVars!.length,
        'AgentMcpStdioTransport.envVars',
        min: 0,
        max: 16384,
      );
      for (final item in envVars!) {
        validateAgentLength(
          item,
          'AgentMcpStdioTransport.envVars',
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
    if (clearEnvVars)
      'env_vars': null
    else if (envVars != null)
      'env_vars': envVars!.map((value) => value).toList(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentMcpStdioTransport copyWith({
    Object? args = unsetCopyWithValue,
    bool? clearArgs,
    String? command,
    String? cwd,
    Object? envVars = unsetCopyWithValue,
    bool? clearEnvVars,
  }) => AgentMcpStdioTransport(
    args: copyAgentValue<List<String>>(
      args,
      this.args,
      'AgentMcpStdioTransport.args',
    ),
    clearArgs:
        clearArgs ??
        (identical(args, unsetCopyWithValue) ? this.clearArgs : args == null),
    command: command ?? this.command,
    cwd: cwd ?? this.cwd,
    envVars: copyAgentValue<List<String>>(
      envVars,
      this.envVars,
      'AgentMcpStdioTransport.envVars',
    ),
    clearEnvVars:
        clearEnvVars ??
        (identical(envVars, unsetCopyWithValue)
            ? this.clearEnvVars
            : envVars == null),
  );
}

/// A credential-free transport used to connect to an MCP server.
///
/// Variants: [AgentMcpHttpTransportResource], [AgentMcpStdioTransportResource] and [UnknownAgentMcpTransportResource].
sealed class AgentMcpTransportResource extends AgentJsonModel {
  const AgentMcpTransportResource();

  /// Parses known variants strictly and retains future received variants.
  factory AgentMcpTransportResource.fromJson(Map<String, dynamic> json) =>
      switch (requireAgentString(
        json['type'],
        'AgentMcpTransportResource.type',
      )) {
        'http' => AgentMcpHttpTransportResource.fromJson(json),
        'stdio' => AgentMcpStdioTransportResource.fromJson(json),
        _ => UnknownAgentMcpTransportResource.fromJson(json),
      };

  /// The canonical discriminator.
  String get type;

  @override
  Map<String, dynamic> toJson();

  /// Creates the `http` variant.
  factory AgentMcpTransportResource.http({
    required Map<String, String> headers,
    required String serverUrl,
    Map<String, dynamic> rawJson,
  }) = AgentMcpHttpTransportResource;

  /// Creates the `stdio` variant.
  factory AgentMcpTransportResource.stdio({
    required List<String> args,
    required String command,
    required String cwd,
    required List<String> envVars,
    Map<String, dynamic> rawJson,
  }) = AgentMcpStdioTransportResource;
}

/// A future discriminator with a finite, deeply detached private snapshot.
/// Known malformed variants cannot use this fallback.
final class UnknownAgentMcpTransportResource extends AgentMcpTransportResource {
  const UnknownAgentMcpTransportResource._(this.rawJson);

  /// Retains an unknown discriminator without admitting a malformed known one.
  factory UnknownAgentMcpTransportResource.fromJson(Map<String, dynamic> json) {
    final type = requireAgentString(
      json['type'],
      'UnknownAgentMcpTransportResource.type',
    );
    if (const ['http', 'stdio'].contains(type)) {
      throw const FormatException(
        'UnknownAgentMcpTransportResource: expected a future type',
      );
    }
    return UnknownAgentMcpTransportResource._(
      snapshotAgentJson(json, 'UnknownAgentMcpTransportResource'),
    );
  }

  /// The detached original received object.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Copies this future received object.
  UnknownAgentMcpTransportResource copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownAgentMcpTransportResource.fromJson(rawJson ?? this.rawJson);
}

/// Connects to an MCP server over HTTP.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentMcpHttpTransportResource extends AgentMcpTransportResource {
  /// Creates a validated [AgentMcpHttpTransportResource].
  AgentMcpHttpTransportResource({
    required Map<String, String> headers,
    required this.serverUrl,
    Map<String, dynamic> rawJson = const {},
  }) : headers = Map<String, String>.unmodifiable(headers),
       rawJson = agentExtras(rawJson, const [
         'headers',
         'server_url',
         'type',
       ], 'AgentMcpHttpTransportResource') {
    validate();
  }

  /// Non-secret HTTP headers sent to the MCP server.
  final Map<String, String> headers;

  /// The URL of the MCP server.
  final String serverUrl;

  /// The type of the object. Always `http`.
  @override
  String get type => 'http';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentMcpHttpTransportResource] with contextual, payload-free errors.
  factory AgentMcpHttpTransportResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'http', 'AgentMcpHttpTransportResource');
    return AgentMcpHttpTransportResource(
      headers: requiredAgentValue(
        json,
        'headers',
        'AgentMcpHttpTransportResource.headers',
        requireAgentStringMap,
        nullable: false,
      )!,
      serverUrl: requiredAgentValue(
        json,
        'server_url',
        'AgentMcpHttpTransportResource.serverUrl',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['headers', 'server_url', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(
      headers.length,
      'AgentMcpHttpTransportResource.headers',
      min: 0,
    );
    for (final key in headers.keys) {
      validateAgentLength(key, 'AgentMcpHttpTransportResource.headers', min: 0);
    }
    for (final item in headers.values) {
      validateAgentLength(
        item,
        'AgentMcpHttpTransportResource.headers',
        min: 0,
      );
    }
    validateAgentLength(
      serverUrl,
      'AgentMcpHttpTransportResource.serverUrl',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'headers': headers,
    'server_url': serverUrl,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentMcpHttpTransportResource copyWith({
    Map<String, String>? headers,
    String? serverUrl,
    Map<String, dynamic>? rawJson,
  }) => AgentMcpHttpTransportResource(
    headers: headers ?? this.headers,
    serverUrl: serverUrl ?? this.serverUrl,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Starts an MCP server as a local process.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentMcpStdioTransportResource extends AgentMcpTransportResource {
  /// Creates a validated [AgentMcpStdioTransportResource].
  AgentMcpStdioTransportResource({
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
       ], 'AgentMcpStdioTransportResource') {
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

  /// Parses [AgentMcpStdioTransportResource] with contextual, payload-free errors.
  factory AgentMcpStdioTransportResource.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'type', 'stdio', 'AgentMcpStdioTransportResource');
    return AgentMcpStdioTransportResource(
      args: requiredAgentValue(
        json,
        'args',
        'AgentMcpStdioTransportResource.args',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: false,
      )!,
      command: requiredAgentValue(
        json,
        'command',
        'AgentMcpStdioTransportResource.command',
        requireAgentString,
        nullable: false,
      )!,
      cwd: requiredAgentValue(
        json,
        'cwd',
        'AgentMcpStdioTransportResource.cwd',
        requireAgentString,
        nullable: false,
      )!,
      envVars: requiredAgentValue(
        json,
        'env_vars',
        'AgentMcpStdioTransportResource.envVars',
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
      'AgentMcpStdioTransportResource.args',
      min: 0,
      max: 2000,
    );
    for (final item in args) {
      validateAgentLength(item, 'AgentMcpStdioTransportResource.args', min: 0);
    }
    validateAgentLength(
      command,
      'AgentMcpStdioTransportResource.command',
      min: 0,
    );
    validateAgentLength(cwd, 'AgentMcpStdioTransportResource.cwd', min: 0);
    validateAgentCount(
      envVars.length,
      'AgentMcpStdioTransportResource.envVars',
      min: 0,
      max: 2000,
    );
    for (final item in envVars) {
      validateAgentLength(
        item,
        'AgentMcpStdioTransportResource.envVars',
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
  AgentMcpStdioTransportResource copyWith({
    List<String>? args,
    String? command,
    String? cwd,
    List<String>? envVars,
    Map<String, dynamic>? rawJson,
  }) => AgentMcpStdioTransportResource(
    args: args ?? this.args,
    command: command ?? this.command,
    cwd: cwd ?? this.cwd,
    envVars: envVars ?? this.envVars,
    rawJson: rawJson ?? this.rawJson,
  );
}
