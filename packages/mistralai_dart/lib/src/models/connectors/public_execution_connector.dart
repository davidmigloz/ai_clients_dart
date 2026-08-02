import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'public_execution_connection_config.dart';

/// A connector integration exposed in the public execution environment.
@immutable
class PublicExecutionConnector {
  /// The connector identifier.
  final String id;

  /// The connector name.
  final String name;

  /// The connector's public connection configuration.
  final PublicExecutionConnectionConfig? connectionConfig;

  /// Creates a [PublicExecutionConnector].
  const PublicExecutionConnector({
    required this.id,
    required this.name,
    this.connectionConfig,
  });

  /// Creates a [PublicExecutionConnector] from JSON.
  factory PublicExecutionConnector.fromJson(Map<String, dynamic> json) =>
      PublicExecutionConnector(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        connectionConfig: json['connection_config'] != null
            ? PublicExecutionConnectionConfig.fromJson(
                json['connection_config'] as Map<String, dynamic>,
              )
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (connectionConfig != null)
      'connection_config': connectionConfig!.toJson(),
  };

  /// Creates a copy with replaced values.
  PublicExecutionConnector copyWith({
    String? id,
    String? name,
    Object? connectionConfig = unsetCopyWithValue,
  }) {
    return PublicExecutionConnector(
      id: id ?? this.id,
      name: name ?? this.name,
      connectionConfig: connectionConfig == unsetCopyWithValue
          ? this.connectionConfig
          : connectionConfig as PublicExecutionConnectionConfig?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PublicExecutionConnector) return false;
    if (runtimeType != other.runtimeType) return false;
    return id == other.id &&
        name == other.name &&
        connectionConfig == other.connectionConfig;
  }

  @override
  int get hashCode => Object.hash(id, name, connectionConfig);

  @override
  String toString() =>
      'PublicExecutionConnector('
      'id: $id, '
      'name: $name, '
      'connectionConfig: $connectionConfig'
      ')';
}
