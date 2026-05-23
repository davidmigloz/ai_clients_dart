import '../copy_with_sentinel.dart';

/// A signing secret used to verify webhook payloads.
class SigningSecret {
  /// The truncated version of the signing secret.
  final String? truncatedSecret;

  /// The expiration date of the signing secret.
  final DateTime? expireTime;

  /// Creates a [SigningSecret] instance.
  const SigningSecret({this.truncatedSecret, this.expireTime});

  /// Creates a [SigningSecret] from JSON.
  factory SigningSecret.fromJson(Map<String, dynamic> json) => SigningSecret(
    truncatedSecret: json['truncated_secret'] as String?,
    expireTime: json['expire_time'] != null
        ? DateTime.parse(json['expire_time'] as String)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (truncatedSecret != null) 'truncated_secret': truncatedSecret,
    if (expireTime != null) 'expire_time': expireTime!.toIso8601String(),
  };

  /// Creates a copy with replaced values.
  SigningSecret copyWith({
    Object? truncatedSecret = unsetCopyWithValue,
    Object? expireTime = unsetCopyWithValue,
  }) {
    return SigningSecret(
      truncatedSecret: truncatedSecret == unsetCopyWithValue
          ? this.truncatedSecret
          : truncatedSecret as String?,
      expireTime: expireTime == unsetCopyWithValue
          ? this.expireTime
          : expireTime as DateTime?,
    );
  }
}
