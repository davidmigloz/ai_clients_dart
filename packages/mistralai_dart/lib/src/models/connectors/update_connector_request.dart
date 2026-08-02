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

  /// New server URL for the MCP connector.
  final String? server;

  /// New headers for the MCP connector.
  final Map<String, dynamic>? headers;

  /// New authentication data for the MCP connector.
  final AuthData? authData;

  /// The connector protocol. Always "mcp" — the API only supports MCP
  /// connectors.
  String get protocol => 'mcp';

  /// Creates an [UpdateConnectorRequest].
  const UpdateConnectorRequest({
    this.title,
    this.name,
    this.description,
    this.iconUrl,
    this.systemPrompt,
    this.server,
    this.headers,
    this.authData,
  });

  /// Creates an [UpdateConnectorRequest] from JSON.
  factory UpdateConnectorRequest.fromJson(Map<String, dynamic> json) {
    final protocol = json['protocol'] as String?;
    if (protocol != null && protocol != 'mcp') {
      throw FormatException(
        'UpdateConnectorRequest: expected protocol "mcp", got "$protocol"',
      );
    }
    return UpdateConnectorRequest(
      title: json['title'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      systemPrompt: json['system_prompt'] as String?,
      server: json['server'] as String?,
      headers: json['headers'] as Map<String, dynamic>?,
      authData: json['auth_data'] != null
          ? AuthData.fromJson(json['auth_data'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (iconUrl != null) 'icon_url': iconUrl,
    if (systemPrompt != null) 'system_prompt': systemPrompt,
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
      'protocol: $protocol, '
      'server: $server, '
      'headers: ${headers?.length ?? 'null'} entries, '
      'authData: $authData)';
}
