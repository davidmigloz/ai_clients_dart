import '../copy_with_sentinel.dart';

/// Response payload for `WebhookService.RotateSigningSecret`.
class RotateSigningSecretResponse {
  /// The newly generated signing secret.
  final String? secret;

  /// Creates a [RotateSigningSecretResponse] instance.
  const RotateSigningSecretResponse({this.secret});

  /// Creates a [RotateSigningSecretResponse] from JSON.
  factory RotateSigningSecretResponse.fromJson(Map<String, dynamic> json) =>
      RotateSigningSecretResponse(secret: json['secret'] as String?);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (secret != null) 'secret': secret};

  /// Creates a copy with replaced values.
  RotateSigningSecretResponse copyWith({Object? secret = unsetCopyWithValue}) {
    return RotateSigningSecretResponse(
      secret: secret == unsetCopyWithValue ? this.secret : secret as String?,
    );
  }
}
