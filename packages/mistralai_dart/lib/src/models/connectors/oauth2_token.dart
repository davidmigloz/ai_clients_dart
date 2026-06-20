import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// An OAuth2 access token used as connector credentials.
@immutable
class OAuth2Token {
  /// The OAuth2 access token.
  final String accessToken;

  /// The token type, typically "Bearer".
  final String tokenType;

  /// The lifetime of the token in seconds.
  final int? expiresIn;

  /// The granted OAuth2 scope.
  final String? scope;

  /// The refresh token, when present.
  final String? refreshToken;

  /// When the token expires.
  final DateTime? expiresAt;

  /// Creates an [OAuth2Token].
  const OAuth2Token({
    required this.accessToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
    this.scope,
    this.refreshToken,
    this.expiresAt,
  });

  /// Creates an [OAuth2Token] from JSON.
  factory OAuth2Token.fromJson(Map<String, dynamic> json) => OAuth2Token(
    accessToken: json['access_token'] as String? ?? '',
    tokenType: json['token_type'] as String? ?? 'Bearer',
    expiresIn: json['expires_in'] as int?,
    scope: json['scope'] as String?,
    refreshToken: json['refresh_token'] as String?,
    expiresAt: json['expires_at'] != null
        ? DateTime.tryParse(json['expires_at'] as String)
        : null,
  );

  /// Converts this token to JSON.
  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'token_type': tokenType,
    if (expiresIn != null) 'expires_in': expiresIn,
    if (scope != null) 'scope': scope,
    if (refreshToken != null) 'refresh_token': refreshToken,
    if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  OAuth2Token copyWith({
    String? accessToken,
    String? tokenType,
    Object? expiresIn = unsetCopyWithValue,
    Object? scope = unsetCopyWithValue,
    Object? refreshToken = unsetCopyWithValue,
    Object? expiresAt = unsetCopyWithValue,
  }) => OAuth2Token(
    accessToken: accessToken ?? this.accessToken,
    tokenType: tokenType ?? this.tokenType,
    expiresIn: expiresIn == unsetCopyWithValue
        ? this.expiresIn
        : expiresIn as int?,
    scope: scope == unsetCopyWithValue ? this.scope : scope as String?,
    refreshToken: refreshToken == unsetCopyWithValue
        ? this.refreshToken
        : refreshToken as String?,
    expiresAt: expiresAt == unsetCopyWithValue
        ? this.expiresAt
        : expiresAt as DateTime?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuth2Token &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          tokenType == other.tokenType &&
          expiresIn == other.expiresIn &&
          scope == other.scope &&
          refreshToken == other.refreshToken &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode => Object.hash(
    accessToken,
    tokenType,
    expiresIn,
    scope,
    refreshToken,
    expiresAt,
  );

  @override
  String toString() =>
      'OAuth2Token('
      'accessToken: [redacted], '
      'tokenType: $tokenType, '
      'expiresIn: $expiresIn, '
      'scope: $scope, '
      'refreshToken: ${refreshToken == null ? null : '[redacted]'}, '
      'expiresAt: $expiresAt)';
}
