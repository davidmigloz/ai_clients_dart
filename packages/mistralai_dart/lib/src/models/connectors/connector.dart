import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'authentication_configuration.dart';
import 'connection_preference.dart';
import 'connector_locale.dart';
import 'connector_protocol.dart';
import 'connector_tool.dart';
import 'pagination_response.dart';
import 'public_authentication_method.dart';
import 'public_connection_config.dart';
import 'resource_type.dart';
import 'resource_visibility.dart';

/// An MCP connector (Beta).
///
/// Connectors expose external Model Context Protocol (MCP) servers to agents
/// and conversations, with configurable authentication and tool execution.
@immutable
class Connector {
  /// The unique identifier of the connector.
  final String id;

  /// The name of the connector.
  final String name;

  /// The description of the connector.
  final String description;

  /// When the connector was created.
  final DateTime createdAt;

  /// When the connector was last modified.
  final DateTime modifiedAt;

  /// The type of the connector owner.
  final ResourceType ownerType;

  /// The visibility of the connector.
  final ResourceVisibility visibility;

  /// Whether tool execution is private to the owner.
  final bool privateToolExecution;

  /// An optional human-readable title.
  final String? title;

  /// The URL of the MCP server.
  final String? server;

  /// The protocol the connector speaks.
  final ConnectorProtocol? protocol;

  /// The URL of the connector icon.
  final String? iconUrl;

  /// The MCP server card describing the server (freeform).
  final Map<String, dynamic>? serverCard;

  /// The ID of the connector owner.
  final String? ownerId;

  /// Localized strings for the connector.
  final ConnectorLocale? locale;

  /// An optional system prompt for the connector.
  final String? systemPrompt;

  /// The authentication methods supported by the connector.
  final List<PublicAuthenticationMethod>? supportedAuthMethods;

  /// The connection preferences configured for the connector.
  final List<ConnectionPreference>? connectionPreferences;

  /// The configured authentication credentials for the connector.
  final List<AuthenticationConfiguration>? connectionCredentials;

  /// Whether the connector is active for the caller.
  final bool? active;

  /// Whether this is a first-party Mistral connector.
  final bool mistral;

  /// Whether the caller is authenticated against the connector.
  final bool? isAuthenticated;

  /// The tools exposed by the connector.
  final List<ConnectorTool>? tools;

  /// The system prompt route.
  final String? systemPromptRoute;

  /// The public connection configuration.
  final PublicConnectionConfig? connectionConfig;

  /// Creates a [Connector].
  const Connector({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.modifiedAt,
    required this.ownerType,
    required this.visibility,
    required this.privateToolExecution,
    this.title,
    this.server,
    this.protocol,
    this.iconUrl,
    this.serverCard,
    this.ownerId,
    this.locale,
    this.systemPrompt,
    this.supportedAuthMethods,
    this.connectionPreferences,
    this.connectionCredentials,
    this.active,
    this.mistral = false,
    this.isAuthenticated,
    this.tools,
    this.systemPromptRoute,
    this.connectionConfig,
  });

  /// Creates a [Connector] from JSON.
  factory Connector.fromJson(Map<String, dynamic> json) => Connector(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.utc(1970),
    modifiedAt:
        DateTime.tryParse(json['modified_at'] as String? ?? '') ??
        DateTime.utc(1970),
    ownerType: ResourceType.fromJson(json['owner_type'] as int?),
    visibility: ResourceVisibility.fromJson(json['visibility'] as String?),
    privateToolExecution: json['private_tool_execution'] as bool? ?? false,
    title: json['title'] as String?,
    server: json['server'] as String?,
    protocol: json['protocol'] != null
        ? ConnectorProtocol.fromJson(json['protocol'] as String?)
        : null,
    iconUrl: json['icon_url'] as String?,
    serverCard: json['server_card'] as Map<String, dynamic>?,
    ownerId: json['owner_id'] as String?,
    locale: json['locale'] != null
        ? ConnectorLocale.fromJson(json['locale'] as Map<String, dynamic>)
        : null,
    systemPrompt: json['system_prompt'] as String?,
    supportedAuthMethods: (json['supported_auth_methods'] as List<dynamic>?)
        ?.map(
          (e) => PublicAuthenticationMethod.fromJson(e as Map<String, dynamic>),
        )
        .toList(),
    connectionPreferences: (json['connection_preferences'] as List<dynamic>?)
        ?.map((e) => ConnectionPreference.fromJson(e as Map<String, dynamic>))
        .toList(),
    connectionCredentials: (json['connection_credentials'] as List<dynamic>?)
        ?.map(
          (e) =>
              AuthenticationConfiguration.fromJson(e as Map<String, dynamic>),
        )
        .toList(),
    active: json['active'] as bool?,
    mistral: json['mistral'] as bool? ?? false,
    isAuthenticated: json['is_authenticated'] as bool?,
    tools: (json['tools'] as List<dynamic>?)
        ?.map((e) => ConnectorTool.fromJson(e as Map<String, dynamic>))
        .toList(),
    systemPromptRoute: json['system_prompt_route'] as String?,
    connectionConfig: json['connection_config'] != null
        ? PublicConnectionConfig.fromJson(
            json['connection_config'] as Map<String, dynamic>,
          )
        : null,
  );

  /// Converts this connector to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'created_at': createdAt.toIso8601String(),
    'modified_at': modifiedAt.toIso8601String(),
    'owner_type': ownerType.toJson(),
    'visibility': visibility.toJson(),
    'private_tool_execution': privateToolExecution,
    if (title != null) 'title': title,
    if (server != null) 'server': server,
    if (protocol != null) 'protocol': protocol!.toJson(),
    if (iconUrl != null) 'icon_url': iconUrl,
    if (serverCard != null) 'server_card': serverCard,
    if (ownerId != null) 'owner_id': ownerId,
    if (locale != null) 'locale': locale!.toJson(),
    if (systemPrompt != null) 'system_prompt': systemPrompt,
    if (supportedAuthMethods != null)
      'supported_auth_methods': supportedAuthMethods!
          .map((e) => e.toJson())
          .toList(),
    if (connectionPreferences != null)
      'connection_preferences': connectionPreferences!
          .map((e) => e.toJson())
          .toList(),
    if (connectionCredentials != null)
      'connection_credentials': connectionCredentials!
          .map((e) => e.toJson())
          .toList(),
    if (active != null) 'active': active,
    'mistral': mistral,
    if (isAuthenticated != null) 'is_authenticated': isAuthenticated,
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (systemPromptRoute != null) 'system_prompt_route': systemPromptRoute,
    if (connectionConfig != null)
      'connection_config': connectionConfig!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  Connector copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? modifiedAt,
    ResourceType? ownerType,
    ResourceVisibility? visibility,
    bool? privateToolExecution,
    Object? title = unsetCopyWithValue,
    Object? server = unsetCopyWithValue,
    Object? protocol = unsetCopyWithValue,
    Object? iconUrl = unsetCopyWithValue,
    Object? serverCard = unsetCopyWithValue,
    Object? ownerId = unsetCopyWithValue,
    Object? locale = unsetCopyWithValue,
    Object? systemPrompt = unsetCopyWithValue,
    Object? supportedAuthMethods = unsetCopyWithValue,
    Object? connectionPreferences = unsetCopyWithValue,
    Object? connectionCredentials = unsetCopyWithValue,
    Object? active = unsetCopyWithValue,
    bool? mistral,
    Object? isAuthenticated = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? systemPromptRoute = unsetCopyWithValue,
    Object? connectionConfig = unsetCopyWithValue,
  }) => Connector(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    modifiedAt: modifiedAt ?? this.modifiedAt,
    ownerType: ownerType ?? this.ownerType,
    visibility: visibility ?? this.visibility,
    privateToolExecution: privateToolExecution ?? this.privateToolExecution,
    title: title == unsetCopyWithValue ? this.title : title as String?,
    server: server == unsetCopyWithValue ? this.server : server as String?,
    protocol: protocol == unsetCopyWithValue
        ? this.protocol
        : protocol as ConnectorProtocol?,
    iconUrl: iconUrl == unsetCopyWithValue ? this.iconUrl : iconUrl as String?,
    serverCard: serverCard == unsetCopyWithValue
        ? this.serverCard
        : serverCard as Map<String, dynamic>?,
    ownerId: ownerId == unsetCopyWithValue ? this.ownerId : ownerId as String?,
    locale: locale == unsetCopyWithValue
        ? this.locale
        : locale as ConnectorLocale?,
    systemPrompt: systemPrompt == unsetCopyWithValue
        ? this.systemPrompt
        : systemPrompt as String?,
    supportedAuthMethods: supportedAuthMethods == unsetCopyWithValue
        ? this.supportedAuthMethods
        : supportedAuthMethods as List<PublicAuthenticationMethod>?,
    connectionPreferences: connectionPreferences == unsetCopyWithValue
        ? this.connectionPreferences
        : connectionPreferences as List<ConnectionPreference>?,
    connectionCredentials: connectionCredentials == unsetCopyWithValue
        ? this.connectionCredentials
        : connectionCredentials as List<AuthenticationConfiguration>?,
    active: active == unsetCopyWithValue ? this.active : active as bool?,
    mistral: mistral ?? this.mistral,
    isAuthenticated: isAuthenticated == unsetCopyWithValue
        ? this.isAuthenticated
        : isAuthenticated as bool?,
    tools: tools == unsetCopyWithValue
        ? this.tools
        : tools as List<ConnectorTool>?,
    systemPromptRoute: systemPromptRoute == unsetCopyWithValue
        ? this.systemPromptRoute
        : systemPromptRoute as String?,
    connectionConfig: connectionConfig == unsetCopyWithValue
        ? this.connectionConfig
        : connectionConfig as PublicConnectionConfig?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Connector &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          createdAt == other.createdAt &&
          modifiedAt == other.modifiedAt &&
          ownerType == other.ownerType &&
          visibility == other.visibility &&
          privateToolExecution == other.privateToolExecution &&
          title == other.title &&
          server == other.server &&
          protocol == other.protocol &&
          iconUrl == other.iconUrl &&
          mapsDeepEqual(serverCard, other.serverCard) &&
          ownerId == other.ownerId &&
          locale == other.locale &&
          systemPrompt == other.systemPrompt &&
          listsEqual(supportedAuthMethods, other.supportedAuthMethods) &&
          listsEqual(connectionPreferences, other.connectionPreferences) &&
          listsEqual(connectionCredentials, other.connectionCredentials) &&
          active == other.active &&
          mistral == other.mistral &&
          isAuthenticated == other.isAuthenticated &&
          listsEqual(tools, other.tools) &&
          systemPromptRoute == other.systemPromptRoute &&
          connectionConfig == other.connectionConfig;

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    description,
    createdAt,
    modifiedAt,
    ownerType,
    visibility,
    privateToolExecution,
    title,
    server,
    protocol,
    iconUrl,
    mapDeepHashCode(serverCard),
    ownerId,
    locale,
    systemPrompt,
    listHash(supportedAuthMethods),
    listHash(connectionPreferences),
    listHash(connectionCredentials),
    active,
    mistral,
    isAuthenticated,
    listHash(tools),
    systemPromptRoute,
    connectionConfig,
  ]);

  @override
  String toString() =>
      'Connector('
      'id: $id, '
      'name: $name, '
      'description: $description, '
      'createdAt: $createdAt, '
      'modifiedAt: $modifiedAt, '
      'ownerType: $ownerType, '
      'visibility: $visibility, '
      'privateToolExecution: $privateToolExecution, '
      'title: $title, '
      'server: $server, '
      'protocol: $protocol, '
      'iconUrl: $iconUrl, '
      'serverCard: ${serverCard?.length ?? 'null'} entries, '
      'ownerId: $ownerId, '
      'locale: $locale, '
      'systemPrompt: $systemPrompt, '
      'supportedAuthMethods: '
      '${supportedAuthMethods == null ? 'null' : '${supportedAuthMethods!.length} items'}, '
      'connectionPreferences: '
      '${connectionPreferences == null ? 'null' : '${connectionPreferences!.length} items'}, '
      'connectionCredentials: '
      '${connectionCredentials == null ? 'null' : '${connectionCredentials!.length} items'}, '
      'active: $active, '
      'mistral: $mistral, '
      'isAuthenticated: $isAuthenticated, '
      'tools: ${tools == null ? 'null' : '${tools!.length} items'}, '
      'systemPromptRoute: $systemPromptRoute, '
      'connectionConfig: $connectionConfig)';
}

/// A paginated list of connectors.
@immutable
class PaginatedConnectors {
  /// The connectors in this page.
  final List<Connector> items;

  /// Pagination metadata.
  final PaginationResponse pagination;

  /// Creates a [PaginatedConnectors].
  const PaginatedConnectors({required this.items, required this.pagination});

  /// Creates a [PaginatedConnectors] from JSON.
  factory PaginatedConnectors.fromJson(Map<String, dynamic> json) =>
      PaginatedConnectors(
        items:
            (json['items'] as List<dynamic>?)
                ?.map((e) => Connector.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        pagination: PaginationResponse.fromJson(
          (json['pagination'] as Map<String, dynamic>?) ?? const {},
        ),
      );

  /// Converts this list to JSON.
  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  PaginatedConnectors copyWith({
    List<Connector>? items,
    PaginationResponse? pagination,
  }) => PaginatedConnectors(
    items: items ?? this.items,
    pagination: pagination ?? this.pagination,
  );

  /// Whether the page is empty.
  bool get isEmpty => items.isEmpty;

  /// Whether the page has any connectors.
  bool get isNotEmpty => items.isNotEmpty;

  /// The number of connectors in this page.
  int get length => items.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginatedConnectors &&
          runtimeType == other.runtimeType &&
          listsEqual(items, other.items) &&
          pagination == other.pagination;

  @override
  int get hashCode => Object.hash(Object.hashAll(items), pagination);

  @override
  String toString() =>
      'PaginatedConnectors('
      'items: ${items.length} items, '
      'pagination: $pagination)';
}
