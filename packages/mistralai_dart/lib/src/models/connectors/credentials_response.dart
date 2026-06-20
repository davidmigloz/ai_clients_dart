import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'authentication_configuration.dart';
import 'outbound_authentication_type.dart';

/// Response listing a connector's configured credentials.
@immutable
class CredentialsResponse {
  /// The configured credentials.
  final List<AuthenticationConfiguration> credentials;

  /// Auth methods for which the connector has preset credentials.
  final List<OutboundAuthenticationType>? connectorPresetCredentialsForAuth;

  /// Creates a [CredentialsResponse].
  const CredentialsResponse({
    required this.credentials,
    this.connectorPresetCredentialsForAuth,
  });

  /// Creates a [CredentialsResponse] from JSON.
  factory CredentialsResponse.fromJson(Map<String, dynamic> json) =>
      CredentialsResponse(
        credentials:
            (json['credentials'] as List<dynamic>?)
                ?.map(
                  (e) => AuthenticationConfiguration.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            const [],
        connectorPresetCredentialsForAuth:
            (json['connector_preset_credentials_for_auth'] as List<dynamic>?)
                ?.map((e) => OutboundAuthenticationType.fromJson(e as String?))
                .toList(),
      );

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() => {
    'credentials': credentials.map((e) => e.toJson()).toList(),
    if (connectorPresetCredentialsForAuth != null)
      'connector_preset_credentials_for_auth':
          connectorPresetCredentialsForAuth!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  CredentialsResponse copyWith({
    List<AuthenticationConfiguration>? credentials,
    List<OutboundAuthenticationType>? connectorPresetCredentialsForAuth,
  }) => CredentialsResponse(
    credentials: credentials ?? this.credentials,
    connectorPresetCredentialsForAuth:
        connectorPresetCredentialsForAuth ??
        this.connectorPresetCredentialsForAuth,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialsResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(credentials, other.credentials) &&
          listsEqual(
            connectorPresetCredentialsForAuth,
            other.connectorPresetCredentialsForAuth,
          );

  @override
  int get hashCode => Object.hash(
    Object.hashAll(credentials),
    listHash(connectorPresetCredentialsForAuth),
  );

  @override
  String toString() =>
      'CredentialsResponse('
      'credentials: ${credentials.length} items, '
      'connectorPresetCredentialsForAuth: '
      '${connectorPresetCredentialsForAuth == null ? 'null' : '${connectorPresetCredentialsForAuth!.length} items'})';
}
