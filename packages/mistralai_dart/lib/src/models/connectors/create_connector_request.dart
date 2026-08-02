import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'auth_data.dart';
import 'public_resource_visibility.dart';

/// Request body for creating a connector.
@immutable
class CreateConnectorRequest {
  /// The name of the connector. Should be 64 chars maximum, alphanumeric,
  /// with only underscores/dashes.
  final String name;

  /// The description of the connector.
  final String description;

  /// The URL of the MCP server.
  final String server;

  /// An optional human-readable title for the connector.
  final String? title;

  /// The optional URL of the icon to associate with the connector.
  final String? iconUrl;

  /// The connector visibility. Defaults to `private` server-side when
  /// omitted.
  final PublicResourceVisibility? visibility;

  /// Optional organization-level headers to send to the MCP server.
  final Map<String, dynamic>? headers;

  /// Optional additional authentication data for the connector.
  final AuthData? authData;

  /// Optional OAuth2 authorization server metadata (freeform).
  final Map<String, dynamic>? oauth2ServerMetadata;

  /// Optional URL to fetch OAuth2 authorization server metadata from
  /// (RFC 8414).
  final String? oauth2ServerMetadataUrl;

  /// Optional system prompt for the connector.
  final String? systemPrompt;

  /// Creates a [CreateConnectorRequest].
  const CreateConnectorRequest({
    required this.name,
    required this.description,
    required this.server,
    this.title,
    this.iconUrl,
    this.visibility,
    this.headers,
    this.authData,
    this.oauth2ServerMetadata,
    this.oauth2ServerMetadataUrl,
    this.systemPrompt,
  });

  /// Creates a [CreateConnectorRequest] from JSON.
  factory CreateConnectorRequest.fromJson(Map<String, dynamic> json) =>
      CreateConnectorRequest(
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        server: json['server'] as String? ?? '',
        title: json['title'] as String?,
        iconUrl: json['icon_url'] as String?,
        visibility: json['visibility'] != null
            ? PublicResourceVisibility.fromJson(json['visibility'] as String?)
            : null,
        headers: json['headers'] as Map<String, dynamic>?,
        authData: json['auth_data'] != null
            ? AuthData.fromJson(json['auth_data'] as Map<String, dynamic>)
            : null,
        oauth2ServerMetadata:
            json['oauth2_server_metadata'] as Map<String, dynamic>?,
        oauth2ServerMetadataUrl: json['oauth2_server_metadata_url'] as String?,
        systemPrompt: json['system_prompt'] as String?,
      );

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'server': server,
    if (title != null) 'title': title,
    if (iconUrl != null) 'icon_url': iconUrl,
    if (visibility != null) 'visibility': visibility!.toJson(),
    if (headers != null) 'headers': headers,
    if (authData != null) 'auth_data': authData!.toJson(),
    if (oauth2ServerMetadata != null)
      'oauth2_server_metadata': oauth2ServerMetadata,
    if (oauth2ServerMetadataUrl != null)
      'oauth2_server_metadata_url': oauth2ServerMetadataUrl,
    if (systemPrompt != null) 'system_prompt': systemPrompt,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  CreateConnectorRequest copyWith({
    String? name,
    String? description,
    String? server,
    Object? title = unsetCopyWithValue,
    Object? iconUrl = unsetCopyWithValue,
    Object? visibility = unsetCopyWithValue,
    Object? headers = unsetCopyWithValue,
    Object? authData = unsetCopyWithValue,
    Object? oauth2ServerMetadata = unsetCopyWithValue,
    Object? oauth2ServerMetadataUrl = unsetCopyWithValue,
    Object? systemPrompt = unsetCopyWithValue,
  }) => CreateConnectorRequest(
    name: name ?? this.name,
    description: description ?? this.description,
    server: server ?? this.server,
    title: title == unsetCopyWithValue ? this.title : title as String?,
    iconUrl: iconUrl == unsetCopyWithValue ? this.iconUrl : iconUrl as String?,
    visibility: visibility == unsetCopyWithValue
        ? this.visibility
        : visibility as PublicResourceVisibility?,
    headers: headers == unsetCopyWithValue
        ? this.headers
        : headers as Map<String, dynamic>?,
    authData: authData == unsetCopyWithValue
        ? this.authData
        : authData as AuthData?,
    oauth2ServerMetadata: oauth2ServerMetadata == unsetCopyWithValue
        ? this.oauth2ServerMetadata
        : oauth2ServerMetadata as Map<String, dynamic>?,
    oauth2ServerMetadataUrl: oauth2ServerMetadataUrl == unsetCopyWithValue
        ? this.oauth2ServerMetadataUrl
        : oauth2ServerMetadataUrl as String?,
    systemPrompt: systemPrompt == unsetCopyWithValue
        ? this.systemPrompt
        : systemPrompt as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateConnectorRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          server == other.server &&
          title == other.title &&
          iconUrl == other.iconUrl &&
          visibility == other.visibility &&
          mapsDeepEqual(headers, other.headers) &&
          authData == other.authData &&
          mapsDeepEqual(oauth2ServerMetadata, other.oauth2ServerMetadata) &&
          oauth2ServerMetadataUrl == other.oauth2ServerMetadataUrl &&
          systemPrompt == other.systemPrompt;

  @override
  int get hashCode => Object.hash(
    name,
    description,
    server,
    title,
    iconUrl,
    visibility,
    mapDeepHashCode(headers),
    authData,
    mapDeepHashCode(oauth2ServerMetadata),
    oauth2ServerMetadataUrl,
    systemPrompt,
  );

  @override
  String toString() =>
      'CreateConnectorRequest('
      'name: $name, '
      'description: $description, '
      'server: $server, '
      'title: $title, '
      'iconUrl: $iconUrl, '
      'visibility: $visibility, '
      'headers: ${headers?.length ?? 'null'} entries, '
      'authData: $authData, '
      'oauth2ServerMetadata: ${oauth2ServerMetadata?.length ?? 'null'} entries, '
      'oauth2ServerMetadataUrl: $oauth2ServerMetadataUrl, '
      'systemPrompt: $systemPrompt)';
}
