import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'connection_config_type.dart';
import 'tool_execution_configuration.dart';

/// Connection config exposed in the public, unauthenticated
/// `/connectors/mistral` response.
///
/// Unlike the internal connection config, this has no `headers` field and
/// forbids extra fields, so connector credentials can never be serialized
/// into this cacheable response.
@immutable
class PublicExecutionConnectionConfig {
  /// The connection config type.
  final ConnectionConfigType type;

  /// Whether the connector is hosted internally by Mistral.
  final bool hostedInternally;

  /// The connection identifier.
  final String? id;

  /// The connection name.
  final String? name;

  /// The server URL.
  final String? server;

  /// The tool execution configuration.
  final ToolExecutionConfiguration? toolConfiguration;

  /// Creates a [PublicExecutionConnectionConfig].
  const PublicExecutionConnectionConfig({
    required this.type,
    this.hostedInternally = false,
    this.id,
    this.name,
    this.server,
    this.toolConfiguration,
  });

  /// Creates a [PublicExecutionConnectionConfig] from JSON.
  factory PublicExecutionConnectionConfig.fromJson(Map<String, dynamic> json) =>
      PublicExecutionConnectionConfig(
        type: ConnectionConfigType.fromJson(json['type'] as String?),
        hostedInternally: json['hosted_internally'] as bool? ?? false,
        id: json['id'] as String?,
        name: json['name'] as String?,
        server: json['server'] as String?,
        toolConfiguration: json['tool_configuration'] != null
            ? ToolExecutionConfiguration.fromJson(
                json['tool_configuration'] as Map<String, dynamic>,
              )
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type.toJson(),
    'hosted_internally': hostedInternally,
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (server != null) 'server': server,
    if (toolConfiguration != null)
      'tool_configuration': toolConfiguration!.toJson(),
  };

  /// Creates a copy with replaced values.
  PublicExecutionConnectionConfig copyWith({
    ConnectionConfigType? type,
    bool? hostedInternally,
    Object? id = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? server = unsetCopyWithValue,
    Object? toolConfiguration = unsetCopyWithValue,
  }) {
    return PublicExecutionConnectionConfig(
      type: type ?? this.type,
      hostedInternally: hostedInternally ?? this.hostedInternally,
      id: id == unsetCopyWithValue ? this.id : id as String?,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      server: server == unsetCopyWithValue ? this.server : server as String?,
      toolConfiguration: toolConfiguration == unsetCopyWithValue
          ? this.toolConfiguration
          : toolConfiguration as ToolExecutionConfiguration?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PublicExecutionConnectionConfig) return false;
    if (runtimeType != other.runtimeType) return false;
    return type == other.type &&
        hostedInternally == other.hostedInternally &&
        id == other.id &&
        name == other.name &&
        server == other.server &&
        toolConfiguration == other.toolConfiguration;
  }

  @override
  int get hashCode =>
      Object.hash(type, hostedInternally, id, name, server, toolConfiguration);

  @override
  String toString() =>
      'PublicExecutionConnectionConfig('
      'type: $type, '
      'hostedInternally: $hostedInternally, '
      'id: $id, '
      'name: $name, '
      'server: $server, '
      'toolConfiguration: $toolConfiguration'
      ')';
}
