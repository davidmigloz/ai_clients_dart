import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Additional authentication data for creating or updating a connector.
@immutable
class AuthData {
  /// The OAuth2 client ID.
  final String clientId;

  /// The OAuth2 client secret.
  final String? clientSecret;

  /// Creates an [AuthData].
  const AuthData({
    this.clientScopes,
    required this.clientId,
    this.clientSecret,
  });

  /// Creates an [AuthData] from JSON.
  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
    clientScopes: (json['client_scopes'] as List<Object?>?)
        ?.map((value) => value! as String)
        .toList(),
    clientId: json['client_id'] as String? ?? '',
    clientSecret: json['client_secret'] as String?,
  );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    if (clientScopes != null) 'client_scopes': clientScopes,
    'client_id': clientId,
    if (clientSecret != null) 'client_secret': clientSecret,
  };

  /// OAuth2 scopes associated with this client.
  final List<String>? clientScopes;

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for [clientSecret] to clear it explicitly; omit to keep.
  AuthData copyWith({
    Object? clientScopes = unsetCopyWithValue,
    String? clientId,
    Object? clientSecret = unsetCopyWithValue,
  }) => AuthData(
    clientScopes: clientScopes == unsetCopyWithValue
        ? this.clientScopes
        : (clientScopes as List<Object?>?)?.cast<String>(),
    clientId: clientId ?? this.clientId,
    clientSecret: clientSecret == unsetCopyWithValue
        ? this.clientSecret
        : clientSecret as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthData &&
          listsEqual(clientScopes, other.clientScopes) &&
          runtimeType == other.runtimeType &&
          clientId == other.clientId &&
          clientSecret == other.clientSecret;

  @override
  int get hashCode =>
      Object.hashAll([clientId, clientSecret, listHash(clientScopes)]);

  @override
  String toString() =>
      'AuthData(clientScopes: ${clientScopes?.length}, clientId: $clientId, clientSecret: ***)';
}
