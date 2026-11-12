import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'tool_definition.dart';

/// Reference to a tool (or MCP toolset) affected by a mid-conversation
/// tool-change directive.
///
/// One of:
/// - [ToolChangeToolReference] — a tool declared directly in `tools[]`.
/// - [ToolChangeMCPToolReference] — a single MCP tool by server and name.
/// - [ToolChangeMCPToolsetReference] — every tool in an MCP server's toolset.
/// - [ToolChangeInlineDefinition] — an inline tool declaration.
/// - [UnknownToolChangeReference] — unrecognized type, for forward
///   compatibility (preserves raw JSON).
sealed class ToolChangeReference {
  const ToolChangeReference();

  /// References a tool declared directly in the request's `tools[]`.
  factory ToolChangeReference.tool(String name) = ToolChangeToolReference;

  /// References a single MCP tool by its server and remote name.
  factory ToolChangeReference.mcpTool({
    required String serverName,
    required String name,
  }) = ToolChangeMCPToolReference;

  /// References every tool in the named MCP server's toolset.
  factory ToolChangeReference.mcpToolset(String serverName) =
      ToolChangeMCPToolsetReference;

  /// Defines a tool by value in a tool-addition block.
  factory ToolChangeReference.definition(ToolDefinition definition) =
      ToolChangeInlineDefinition;

  /// Creates a [ToolChangeReference] from JSON.
  ///
  /// Dispatches on the `type` discriminator; unrecognized values fall back to
  /// [UnknownToolChangeReference].
  factory ToolChangeReference.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'tool_reference' => ToolChangeToolReference.fromJson(json),
      'mcp_tool_reference' => ToolChangeMCPToolReference.fromJson(json),
      'mcp_toolset_reference' => ToolChangeMCPToolsetReference.fromJson(json),
      'tool_definition' => ToolChangeInlineDefinition.fromJson(json),
      _ => UnknownToolChangeReference(rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Reference to a single tool the caller declared directly in `tools[]`.
///
/// Does not accept the composed `{server}_{name}` form the server assigns to
/// MCP-resolved tools — use [ToolChangeMCPToolReference] or
/// [ToolChangeMCPToolsetReference] for those.
@immutable
class ToolChangeToolReference extends ToolChangeReference {
  /// The referenced tool's name.
  final String name;

  /// Creates a [ToolChangeToolReference].
  const ToolChangeToolReference(this.name);

  /// Creates a [ToolChangeToolReference] from JSON.
  factory ToolChangeToolReference.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type != 'tool_reference') {
      throw FormatException(
        'ToolChangeToolReference: expected type "tool_reference", got "$type"',
      );
    }
    return ToolChangeToolReference(json['name'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'tool_reference', 'name': name};

  /// Creates a copy with replaced values.
  ToolChangeToolReference copyWith({String? name}) {
    return ToolChangeToolReference(name ?? this.name);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolChangeToolReference &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'ToolChangeToolReference(name: $name)';
}

/// Reference to a single MCP tool by its server and remote name — the same
/// `server_name`/`name` pair `mcp_tool_use` carries.
@immutable
class ToolChangeMCPToolReference extends ToolChangeReference {
  /// The MCP server name.
  final String serverName;

  /// The tool's remote name on that server.
  final String name;

  /// Creates a [ToolChangeMCPToolReference].
  const ToolChangeMCPToolReference({
    required this.serverName,
    required this.name,
  });

  /// Creates a [ToolChangeMCPToolReference] from JSON.
  factory ToolChangeMCPToolReference.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type != 'mcp_tool_reference') {
      throw FormatException(
        'ToolChangeMCPToolReference: expected type "mcp_tool_reference", '
        'got "$type"',
      );
    }
    return ToolChangeMCPToolReference(
      serverName: json['server_name'] as String,
      name: json['name'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp_tool_reference',
    'server_name': serverName,
    'name': name,
  };

  /// Creates a copy with replaced values.
  ToolChangeMCPToolReference copyWith({String? serverName, String? name}) {
    return ToolChangeMCPToolReference(
      serverName: serverName ?? this.serverName,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolChangeMCPToolReference &&
          runtimeType == other.runtimeType &&
          serverName == other.serverName &&
          name == other.name;

  @override
  int get hashCode => Object.hash(serverName, name);

  @override
  String toString() =>
      'ToolChangeMCPToolReference(serverName: $serverName, name: $name)';
}

/// Reference to every tool in the named MCP server's toolset.
@immutable
class ToolChangeMCPToolsetReference extends ToolChangeReference {
  /// The MCP server name.
  final String serverName;

  /// Creates a [ToolChangeMCPToolsetReference].
  const ToolChangeMCPToolsetReference(this.serverName);

  /// Creates a [ToolChangeMCPToolsetReference] from JSON.
  factory ToolChangeMCPToolsetReference.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type != 'mcp_toolset_reference') {
      throw FormatException(
        'ToolChangeMCPToolsetReference: expected type '
        '"mcp_toolset_reference", got "$type"',
      );
    }
    return ToolChangeMCPToolsetReference(json['server_name'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp_toolset_reference',
    'server_name': serverName,
  };

  /// Creates a copy with replaced values.
  ToolChangeMCPToolsetReference copyWith({String? serverName}) {
    return ToolChangeMCPToolsetReference(serverName ?? this.serverName);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolChangeMCPToolsetReference &&
          runtimeType == other.runtimeType &&
          serverName == other.serverName;

  @override
  int get hashCode => serverName.hashCode;

  @override
  String toString() => 'ToolChangeMCPToolsetReference(serverName: $serverName)';
}

/// A tool carried by value rather than referenced by name.
///
/// Use it in a tool-addition block with `inline-tools-2026-09-15`. For an MCP
/// connector toolset, also send `mcp-client-2026-09-15`.
@immutable
final class ToolChangeInlineDefinition extends ToolChangeReference {
  /// Creates an inline definition from a typed Messages tool declaration.
  const ToolChangeInlineDefinition(ToolDefinition this.definition)
    : _raw = null;

  const ToolChangeInlineDefinition._(this.definition, this._raw);

  /// Decodes an inline definition and retains its original JSON for replay.
  factory ToolChangeInlineDefinition.fromJson(Map<String, dynamic> json) {
    if (json case {
      'type': 'tool_definition',
      'definition': Map<String, dynamic> _,
    }) {
      final raw = deepUnmodifiableMap(json);
      final wireDefinition = raw['definition'] as Map<String, dynamic>;
      return ToolChangeInlineDefinition._(
        _parseDefinition(wireDefinition),
        raw,
      );
    }
    throw const FormatException('Expected an inline tool definition object');
  }

  /// The decoded tool declaration when its schema is known to this client.
  ///
  /// Unrecognized declarations remain available through [toJson].
  final ToolDefinition? definition;

  final Map<String, dynamic>? _raw;

  static ToolDefinition? _parseDefinition(Map<String, dynamic> json) {
    try {
      return ToolDefinition.fromJson(json);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Map<String, dynamic> toJson() =>
      _raw ?? {'type': 'tool_definition', 'definition': definition!.toJson()};

  @override
  bool operator ==(Object other) =>
      other is ToolChangeInlineDefinition &&
      mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() => 'ToolChangeInlineDefinition()';
}

/// A tool directive recorded inside a server compaction block.
@immutable
final class CompactionToolChange {
  /// Reads a directive while preserving the original JSON for signed replay.
  CompactionToolChange.fromJson(Map<String, dynamic> json)
    : raw = deepUnmodifiableMap(json);

  /// The server discriminator, normally `tool_addition` or `tool_removal`.
  String? get type => raw['type'] as String?;

  /// A tool definition or reference, when one is present.
  ToolChangeReference? get tool => switch (raw['tool']) {
    final Map<String, dynamic> value => ToolChangeReference.fromJson(value),
    _ => null,
  };

  /// The original provider payload.
  final Map<String, dynamic> raw;

  /// Returns the original provider payload.
  Map<String, dynamic> toJson() => raw;

  @override
  bool operator ==(Object other) =>
      other is CompactionToolChange && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// Unrecognized [ToolChangeReference] — preserves raw JSON for forward
/// compatibility.
@immutable
class UnknownToolChangeReference extends ToolChangeReference {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownToolChangeReference].
  const UnknownToolChangeReference({required this.rawJson});

  /// Creates an [UnknownToolChangeReference] from JSON.
  factory UnknownToolChangeReference.fromJson(Map<String, dynamic> json) {
    return UnknownToolChangeReference(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownToolChangeReference &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownToolChangeReference(rawJson: $rawJson)';
}
