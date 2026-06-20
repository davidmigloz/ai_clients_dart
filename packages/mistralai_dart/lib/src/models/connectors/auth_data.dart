import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Additional authentication data for creating or updating a connector.
@immutable
class AuthData {
  /// The OAuth2 client ID.
  final String clientId;

  /// The OAuth2 client secret.
  final String? clientSecret;

  /// Creates an [AuthData].
  const AuthData({required this.clientId, this.clientSecret});

  /// Creates an [AuthData] from JSON.
  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
    clientId: json['client_id'] as String? ?? '',
    clientSecret: json['client_secret'] as String?,
  );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'client_id': clientId,
    if (clientSecret != null) 'client_secret': clientSecret,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for [clientSecret] to clear it explicitly; omit to keep.
  AuthData copyWith({
    String? clientId,
    Object? clientSecret = unsetCopyWithValue,
  }) => AuthData(
    clientId: clientId ?? this.clientId,
    clientSecret: clientSecret == unsetCopyWithValue
        ? this.clientSecret
        : clientSecret as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthData &&
          runtimeType == other.runtimeType &&
          clientId == other.clientId &&
          clientSecret == other.clientSecret;

  @override
  int get hashCode => Object.hash(clientId, clientSecret);

  @override
  String toString() => 'AuthData(clientId: $clientId, clientSecret: ***)';
}
