import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'auth_data.dart';
import 'connector_auth_method.dart';
import 'connector_oauth.dart';
import 'public_resource_visibility.dart';

/// Request body for creating a connector.
@immutable
class CreateConnectorRequest {
  /// The name of the connector. Should be 64 chars maximum, alphanumeric,
  /// with only underscores/dashes.
  final String name;

  /// The description of the connector.
  final String description;

  /// The URL of the connector server.
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

  /// Legacy OAuth authorization-code credentials. Serialized as an auth method.
  final AuthData? authData;

  /// Optional OAuth2 authorization server metadata (freeform).
  final Map<String, dynamic>? oauth2ServerMetadata;

  /// Optional URL to fetch OAuth2 authorization server metadata from
  /// (RFC 8414).
  final String? oauth2ServerMetadataUrl;

  /// Optional system prompt for the connector.
  final String? systemPrompt;

  /// Connector transport, mcp or http. Omit to use the MCP default.
  final String? protocol;

  /// Authentication methods supported by the connector.
  final List<ConnectorAuthMethod>? authMethods;

  /// Connector-wide headers applied before caller-specific headers.
  final Map<String, ConnectorGlobalHeader>? globalHeaders;

  /// Creates a [CreateConnectorRequest].
  const CreateConnectorRequest({
    this.protocol,
    this.authMethods,
    this.globalHeaders,
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
        protocol: json['protocol'] as String?,
        authMethods: (json['auth_methods'] as List<Object?>?)
            ?.map(
              (value) =>
                  ConnectorAuthMethod.fromJson(value! as Map<String, dynamic>),
            )
            .toList(),
        globalHeaders: (json['global_headers'] as Map<String, dynamic>?)?.map(
          (name, value) => MapEntry(
            name,
            ConnectorGlobalHeader.fromJson(value as Map<String, dynamic>),
          ),
        ),
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

  List<ConnectorAuthMethod>? get _resolvedAuthMethods =>
      authMethods ??
      (authData == null
          ? null
          : [OAuthAuthorizationCodeConnectorAuthMethod(authData: authData!)]);

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() {
    if (protocol != null && protocol != 'mcp' && protocol != 'http') {
      throw ArgumentError.value(protocol, 'protocol', 'Expected mcp or http');
    }
    final methods = _resolvedAuthMethods;
    if (methods?.any((method) => method is ConnectorAuthMethodPatch) == true) {
      throw ArgumentError('ConnectorAuthMethodPatch is only valid for updates');
    }
    return {
      if (protocol != null) 'protocol': protocol,
      if (methods != null)
        'auth_methods': methods.map((value) => value.toJson()).toList(),
      if (globalHeaders != null)
        'global_headers': globalHeaders!.map(
          (name, value) => MapEntry(name, value.toJson()),
        ),
      'name': name,
      'description': description,
      'server': server,
      if (title != null) 'title': title,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (visibility != null) 'visibility': visibility!.toJson(),
      if (headers != null) 'headers': headers,
      if (oauth2ServerMetadata != null)
        'oauth2_server_metadata': oauth2ServerMetadata,
      if (oauth2ServerMetadataUrl != null)
        'oauth2_server_metadata_url': oauth2ServerMetadataUrl,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
    };
  }

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  CreateConnectorRequest copyWith({
    Object? protocol = unsetCopyWithValue,
    Object? authMethods = unsetCopyWithValue,
    Object? globalHeaders = unsetCopyWithValue,
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
    protocol: protocol == unsetCopyWithValue
        ? this.protocol
        : protocol as String?,
    authMethods: authMethods == unsetCopyWithValue
        ? this.authMethods
        : (authMethods as List<Object?>?)?.cast<ConnectorAuthMethod>(),
    globalHeaders: globalHeaders == unsetCopyWithValue
        ? this.globalHeaders
        : (globalHeaders as Map<Object?, Object?>?)
              ?.cast<String, ConnectorGlobalHeader>(),
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
        : (headers as Map<Object?, Object?>?)?.cast<String, dynamic>(),
    authData: authData == unsetCopyWithValue
        ? this.authData
        : authData as AuthData?,
    oauth2ServerMetadata: oauth2ServerMetadata == unsetCopyWithValue
        ? this.oauth2ServerMetadata
        : (oauth2ServerMetadata as Map<Object?, Object?>?)
              ?.cast<String, dynamic>(),
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
          protocol == other.protocol &&
          listsEqual(_resolvedAuthMethods, other._resolvedAuthMethods) &&
          mapsEqual(globalHeaders, other.globalHeaders) &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          server == other.server &&
          title == other.title &&
          iconUrl == other.iconUrl &&
          visibility == other.visibility &&
          mapsDeepEqual(headers, other.headers) &&
          mapsDeepEqual(oauth2ServerMetadata, other.oauth2ServerMetadata) &&
          oauth2ServerMetadataUrl == other.oauth2ServerMetadataUrl &&
          systemPrompt == other.systemPrompt;

  @override
  int get hashCode => Object.hashAll([
    name,
    description,
    server,
    title,
    iconUrl,
    visibility,
    mapDeepHashCode(headers),
    mapDeepHashCode(oauth2ServerMetadata),
    oauth2ServerMetadataUrl,
    systemPrompt,
    protocol,
    listHash(_resolvedAuthMethods),
    mapHash(globalHeaders),
  ]);

  @override
  String toString() =>
      'CreateConnectorRequest(protocol: $protocol, authMethods: ${authMethods?.length}, globalHeaders: ${globalHeaders?.length}, '
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
