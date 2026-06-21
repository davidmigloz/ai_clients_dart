import 'package:meta/meta.dart';

/// The OAuth2 authorization URL returned for a connector.
@immutable
class AuthUrlResponse {
  /// The authorization URL to redirect the user to.
  final String authUrl;

  /// The time-to-live of the URL, in seconds.
  final int ttl;

  /// Creates an [AuthUrlResponse].
  const AuthUrlResponse({required this.authUrl, required this.ttl});

  /// Creates an [AuthUrlResponse] from JSON.
  factory AuthUrlResponse.fromJson(Map<String, dynamic> json) =>
      AuthUrlResponse(
        authUrl: json['auth_url'] as String? ?? '',
        ttl: json['ttl'] as int? ?? 0,
      );

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() => {'auth_url': authUrl, 'ttl': ttl};

  /// Creates a copy with the given fields replaced.
  AuthUrlResponse copyWith({String? authUrl, int? ttl}) =>
      AuthUrlResponse(authUrl: authUrl ?? this.authUrl, ttl: ttl ?? this.ttl);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUrlResponse &&
          runtimeType == other.runtimeType &&
          authUrl == other.authUrl &&
          ttl == other.ttl;

  @override
  int get hashCode => Object.hash(authUrl, ttl);

  @override
  String toString() => 'AuthUrlResponse(authUrl: $authUrl, ttl: $ttl)';
}
