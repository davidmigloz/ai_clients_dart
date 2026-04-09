import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';

/// MCP server connection definition as returned in API responses.
///
/// Variants:
/// - [MCPServerURLDefinition] — URL-based MCP server.
/// - [UnknownMCPServer] — unrecognised server type (preserves raw JSON).
sealed class MCPServer {
  const MCPServer();

  /// Creates an [MCPServer] from JSON.
  factory MCPServer.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'url' => MCPServerURLDefinition.fromJson(json),
      _ => UnknownMCPServer._(type: type, raw: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// URL-based MCP server connection.
@immutable
class MCPServerURLDefinition extends MCPServer {
  /// The type discriminator. Always `url`.
  final String type;

  /// Unique name for this server.
  final String name;

  /// Endpoint URL for the MCP server.
  final String url;

  /// Creates an [MCPServerURLDefinition].
  const MCPServerURLDefinition({
    this.type = 'url',
    required this.name,
    required this.url,
  });

  /// Creates an [MCPServerURLDefinition] from JSON.
  factory MCPServerURLDefinition.fromJson(Map<String, dynamic> json) {
    return MCPServerURLDefinition(
      type: json['type'] as String? ?? 'url',
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'name': name, 'url': url};

  /// Creates a copy with replaced values.
  MCPServerURLDefinition copyWith({String? type, String? name, String? url}) {
    return MCPServerURLDefinition(
      type: type ?? this.type,
      name: name ?? this.name,
      url: url ?? this.url,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCPServerURLDefinition &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          url == other.url;

  @override
  int get hashCode => Object.hash(type, name, url);

  @override
  String toString() =>
      'MCPServerURLDefinition(type: $type, name: $name, url: $url)';
}

/// Unrecognised MCP server type — preserves the raw JSON.
@immutable
class UnknownMCPServer extends MCPServer {
  /// The unrecognised type discriminator.
  final String type;

  /// The raw JSON map.
  final Map<String, dynamic> raw;

  const UnknownMCPServer._({required this.type, required this.raw});

  @override
  Map<String, dynamic> toJson() => raw;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownMCPServer &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => Object.hash(type, mapDeepHashCode(raw));

  @override
  String toString() => 'UnknownMCPServer(type: $type, raw: $raw)';
}

/// MCP server connection parameter for create/update requests.
///
/// Variants:
/// - [URLMCPServerParams] — URL-based MCP server.
/// - [UnknownMCPServerParams] — unrecognised server type (preserves raw JSON).
sealed class MCPServerParams {
  const MCPServerParams();

  /// Creates an [MCPServerParams] from JSON.
  factory MCPServerParams.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'url' => URLMCPServerParams.fromJson(json),
      _ => UnknownMCPServerParams._(type: type, raw: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// URL-based MCP server connection parameters.
@immutable
class URLMCPServerParams extends MCPServerParams {
  /// The type discriminator. Always `url`.
  final String type;

  /// Unique name for this server.
  final String name;

  /// Endpoint URL for the MCP server.
  final String url;

  /// Creates a [URLMCPServerParams].
  const URLMCPServerParams({
    this.type = 'url',
    required this.name,
    required this.url,
  });

  /// Creates a [URLMCPServerParams] from JSON.
  factory URLMCPServerParams.fromJson(Map<String, dynamic> json) {
    return URLMCPServerParams(
      type: json['type'] as String? ?? 'url',
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'name': name, 'url': url};

  /// Creates a copy with replaced values.
  URLMCPServerParams copyWith({String? type, String? name, String? url}) {
    return URLMCPServerParams(
      type: type ?? this.type,
      name: name ?? this.name,
      url: url ?? this.url,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is URLMCPServerParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          url == other.url;

  @override
  int get hashCode => Object.hash(type, name, url);

  @override
  String toString() =>
      'URLMCPServerParams(type: $type, name: $name, url: $url)';
}

/// Unrecognised MCP server params type — preserves the raw JSON.
@immutable
class UnknownMCPServerParams extends MCPServerParams {
  /// The unrecognised type discriminator.
  final String type;

  /// The raw JSON map.
  final Map<String, dynamic> raw;

  const UnknownMCPServerParams._({required this.type, required this.raw});

  @override
  Map<String, dynamic> toJson() => raw;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownMCPServerParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => Object.hash(type, mapDeepHashCode(raw));

  @override
  String toString() => 'UnknownMCPServerParams(type: $type, raw: $raw)';
}
