import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'auth_data.dart';

/// Request body for partially updating a connector.
///
/// All fields are optional; only the provided fields are updated.
@immutable
class UpdateConnectorRequest {
  /// An optional human-readable title for the connector.
  final String? title;

  /// The name of the connector.
  final String? name;

  /// The description of the connector.
  final String? description;

  /// The optional URL of the icon to associate with the connector.
  final String? iconUrl;

  /// An optional system prompt for the connector.
  final String? systemPrompt;

  /// Optional new connection config (freeform).
  final Map<String, dynamic>? connectionConfig;

  /// Optional new connection secrets (freeform).
  final Map<String, dynamic>? connectionSecrets;

  /// The connector protocol. Always "mcp".
  final String protocol;

  /// New server URL for the MCP connector.
  final String? server;

  /// New headers for the MCP connector.
  final Map<String, dynamic>? headers;

  /// New authentication data for the MCP connector.
  final AuthData? authData;

  /// Creates an [UpdateConnectorRequest].
  const UpdateConnectorRequest({
    this.title,
    this.name,
    this.description,
    this.iconUrl,
    this.systemPrompt,
    this.connectionConfig,
    this.connectionSecrets,
    this.protocol = 'mcp',
    this.server,
    this.headers,
    this.authData,
  });

  /// Creates an [UpdateConnectorRequest] from JSON.
  factory UpdateConnectorRequest.fromJson(Map<String, dynamic> json) =>
      UpdateConnectorRequest(
        title: json['title'] as String?,
        name: json['name'] as String?,
        description: json['description'] as String?,
        iconUrl: json['icon_url'] as String?,
        systemPrompt: json['system_prompt'] as String?,
        connectionConfig: json['connection_config'] as Map<String, dynamic>?,
        connectionSecrets: json['connection_secrets'] as Map<String, dynamic>?,
        protocol: json['protocol'] as String? ?? 'mcp',
        server: json['server'] as String?,
        headers: json['headers'] as Map<String, dynamic>?,
        authData: json['auth_data'] != null
            ? AuthData.fromJson(json['auth_data'] as Map<String, dynamic>)
            : null,
      );

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (iconUrl != null) 'icon_url': iconUrl,
    if (systemPrompt != null) 'system_prompt': systemPrompt,
    if (connectionConfig != null) 'connection_config': connectionConfig,
    if (connectionSecrets != null) 'connection_secrets': connectionSecrets,
    'protocol': protocol,
    if (server != null) 'server': server,
    if (headers != null) 'headers': headers,
    if (authData != null) 'auth_data': authData!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  UpdateConnectorRequest copyWith({
    Object? title = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? iconUrl = unsetCopyWithValue,
    Object? systemPrompt = unsetCopyWithValue,
    Object? connectionConfig = unsetCopyWithValue,
    Object? connectionSecrets = unsetCopyWithValue,
    String? protocol,
    Object? server = unsetCopyWithValue,
    Object? headers = unsetCopyWithValue,
    Object? authData = unsetCopyWithValue,
  }) => UpdateConnectorRequest(
    title: title == unsetCopyWithValue ? this.title : title as String?,
    name: name == unsetCopyWithValue ? this.name : name as String?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    iconUrl: iconUrl == unsetCopyWithValue ? this.iconUrl : iconUrl as String?,
    systemPrompt: systemPrompt == unsetCopyWithValue
        ? this.systemPrompt
        : systemPrompt as String?,
    connectionConfig: connectionConfig == unsetCopyWithValue
        ? this.connectionConfig
        : connectionConfig as Map<String, dynamic>?,
    connectionSecrets: connectionSecrets == unsetCopyWithValue
        ? this.connectionSecrets
        : connectionSecrets as Map<String, dynamic>?,
    protocol: protocol ?? this.protocol,
    server: server == unsetCopyWithValue ? this.server : server as String?,
    headers: headers == unsetCopyWithValue
        ? this.headers
        : headers as Map<String, dynamic>?,
    authData: authData == unsetCopyWithValue
        ? this.authData
        : authData as AuthData?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateConnectorRequest &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          name == other.name &&
          description == other.description &&
          iconUrl == other.iconUrl &&
          systemPrompt == other.systemPrompt &&
          mapsDeepEqual(connectionConfig, other.connectionConfig) &&
          mapsDeepEqual(connectionSecrets, other.connectionSecrets) &&
          protocol == other.protocol &&
          server == other.server &&
          mapsDeepEqual(headers, other.headers) &&
          authData == other.authData;

  @override
  int get hashCode => Object.hash(
    title,
    name,
    description,
    iconUrl,
    systemPrompt,
    mapDeepHashCode(connectionConfig),
    mapDeepHashCode(connectionSecrets),
    protocol,
    server,
    mapDeepHashCode(headers),
    authData,
  );

  @override
  String toString() =>
      'UpdateConnectorRequest('
      'title: $title, '
      'name: $name, '
      'description: $description, '
      'iconUrl: $iconUrl, '
      'systemPrompt: $systemPrompt, '
      'connectionConfig: ${connectionConfig?.length ?? 'null'} entries, '
      'connectionSecrets: ${connectionSecrets == null ? 'null' : '[redacted]'}, '
      'protocol: $protocol, '
      'server: $server, '
      'headers: ${headers?.length ?? 'null'} entries, '
      'authData: $authData)';
}
