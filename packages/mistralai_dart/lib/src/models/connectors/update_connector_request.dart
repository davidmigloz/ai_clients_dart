import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'auth_data.dart';
import 'connector_auth_method.dart';

/// A nullable field supported by a connector update.
enum ConnectorUpdateField {
  /// Authentication declarations.
  authMethods('auth_methods'),

  /// Description.
  description('description'),

  /// Icon URL.
  iconUrl('icon_url'),

  /// Connector name.
  name('name'),

  /// Connector server URL.
  server('server'),

  /// MCP system prompt.
  systemPrompt('system_prompt'),

  /// Display title.
  title('title');

  const ConnectorUpdateField(this.value);

  /// The field name used on the wire.
  final String value;
}

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

  /// Headers for historical MCP deployments.
  final Map<String, dynamic>? headers;

  /// Legacy credentials for the OAuth authorization-code grant.
  final AuthData? authData;

  /// The connector protocol, mcp or http.
  final String protocol;

  /// Nullable fields to send explicitly when their values are null.
  final Set<ConnectorUpdateField> sendNullFields;

  /// Creates an [UpdateConnectorRequest].
  const UpdateConnectorRequest({
    this.authMethods,
    this.protocol = 'mcp',
    this.sendNullFields = const {},
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
    if (protocol != null && protocol != 'mcp' && protocol != 'http') {
      throw FormatException(
        'UpdateConnectorRequest: expected protocol "mcp" or "http", got "$protocol"',
      );
    }
    return UpdateConnectorRequest(
      authMethods: (json['auth_methods'] as List<Object?>?)
          ?.map(
            (value) =>
                ConnectorAuthMethod.fromJson(value! as Map<String, dynamic>),
          )
          .toList(),
      protocol: protocol ?? 'mcp',
      sendNullFields: {
        for (final field in ConnectorUpdateField.values)
          if (json.containsKey(field.value) && json[field.value] == null) field,
      },
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

  List<ConnectorAuthMethod>? get _resolvedAuthMethods =>
      authMethods ??
      (authData == null
          ? null
          : [OAuthAuthorizationCodeConnectorAuthMethod(authData: authData!)]);

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() {
    if (protocol != 'mcp' && protocol != 'http') {
      throw ArgumentError.value(protocol, 'protocol', 'Expected mcp or http');
    }
    if (protocol == 'http' &&
        (systemPrompt != null ||
            sendNullFields.contains(ConnectorUpdateField.systemPrompt))) {
      throw ArgumentError(
        'systemPrompt is only supported for MCP connector updates',
      );
    }
    final clearAuthMethods = sendNullFields.contains(
      ConnectorUpdateField.authMethods,
    );
    final methods = _resolvedAuthMethods;
    return {
      if (clearAuthMethods && authMethods == null)
        'auth_methods': null
      else if (methods != null)
        'auth_methods': methods.map((value) => value.toJson()).toList(),
      if (title != null || sendNullFields.contains(ConnectorUpdateField.title))
        'title': title,
      if (name != null || sendNullFields.contains(ConnectorUpdateField.name))
        'name': name,
      if (description != null ||
          sendNullFields.contains(ConnectorUpdateField.description))
        'description': description,
      if (iconUrl != null ||
          sendNullFields.contains(ConnectorUpdateField.iconUrl))
        'icon_url': iconUrl,
      if (systemPrompt != null ||
          sendNullFields.contains(ConnectorUpdateField.systemPrompt))
        'system_prompt': systemPrompt,
      'protocol': protocol,
      if (server != null ||
          sendNullFields.contains(ConnectorUpdateField.server))
        'server': server,
      if (headers != null) 'headers': headers,
    };
  }

  /// Authentication methods supported by the connector.
  final List<ConnectorAuthMethod>? authMethods;

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  UpdateConnectorRequest copyWith({
    Object? authMethods = unsetCopyWithValue,
    String? protocol,
    Set<ConnectorUpdateField>? sendNullFields,
    Object? title = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? iconUrl = unsetCopyWithValue,
    Object? systemPrompt = unsetCopyWithValue,
    Object? server = unsetCopyWithValue,
    Object? headers = unsetCopyWithValue,
    Object? authData = unsetCopyWithValue,
  }) => UpdateConnectorRequest(
    authMethods: authMethods == unsetCopyWithValue
        ? this.authMethods
        : (authMethods as List<Object?>?)?.cast<ConnectorAuthMethod>(),
    protocol: protocol ?? this.protocol,
    sendNullFields: sendNullFields ?? this.sendNullFields,
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
        : (headers as Map<Object?, Object?>?)?.cast<String, dynamic>(),
    authData: authData == unsetCopyWithValue
        ? this.authData
        : authData as AuthData?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateConnectorRequest &&
          listsEqual(_resolvedAuthMethods, other._resolvedAuthMethods) &&
          runtimeType == other.runtimeType &&
          protocol == other.protocol &&
          sendNullFields.length == other.sendNullFields.length &&
          sendNullFields.every(other.sendNullFields.contains) &&
          title == other.title &&
          name == other.name &&
          description == other.description &&
          iconUrl == other.iconUrl &&
          systemPrompt == other.systemPrompt &&
          server == other.server &&
          mapsDeepEqual(headers, other.headers);

  @override
  int get hashCode => Object.hashAll([
    protocol,
    Object.hashAllUnordered(sendNullFields),
    title,
    name,
    description,
    iconUrl,
    systemPrompt,
    server,
    mapDeepHashCode(headers),
    listHash(_resolvedAuthMethods),
  ]);

  @override
  String toString() =>
      'UpdateConnectorRequest(authMethods: ${authMethods?.length}, protocol: $protocol, '
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
