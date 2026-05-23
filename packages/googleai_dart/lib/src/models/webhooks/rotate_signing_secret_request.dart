import '../copy_with_sentinel.dart';

/// Revocation behavior for previous signing secrets when rotating.
enum SigningSecretRevocationBehavior {
  /// Generate a new signing secret and revoke all previous secrets after 24
  /// hours. Default and safest option for migrations.
  revokePreviousSecretsAfterH24,

  /// Revoke all previous secrets immediately. Use with caution as this can
  /// interrupt ongoing notifications.
  revokePreviousSecretsImmediately,
}

/// Converts a JSON string to a [SigningSecretRevocationBehavior], or `null`
/// if unrecognized (forward-compatible).
SigningSecretRevocationBehavior? signingSecretRevocationBehaviorFromString(
  String? value,
) {
  return switch (value) {
    'revoke_previous_secrets_after_h24' =>
      SigningSecretRevocationBehavior.revokePreviousSecretsAfterH24,
    'revoke_previous_secrets_immediately' =>
      SigningSecretRevocationBehavior.revokePreviousSecretsImmediately,
    _ => null,
  };
}

/// Converts a [SigningSecretRevocationBehavior] to its JSON string.
String signingSecretRevocationBehaviorToString(
  SigningSecretRevocationBehavior value,
) {
  return switch (value) {
    SigningSecretRevocationBehavior.revokePreviousSecretsAfterH24 =>
      'revoke_previous_secrets_after_h24',
    SigningSecretRevocationBehavior.revokePreviousSecretsImmediately =>
      'revoke_previous_secrets_immediately',
  };
}

/// Request payload for `WebhookService.RotateSigningSecret`.
class RotateSigningSecretRequest {
  /// The revocation behavior for previous signing secrets.
  final SigningSecretRevocationBehavior? revocationBehavior;

  /// Creates a [RotateSigningSecretRequest] instance.
  const RotateSigningSecretRequest({this.revocationBehavior});

  /// Creates a [RotateSigningSecretRequest] from JSON.
  factory RotateSigningSecretRequest.fromJson(Map<String, dynamic> json) =>
      RotateSigningSecretRequest(
        revocationBehavior: signingSecretRevocationBehaviorFromString(
          json['revocation_behavior'] as String?,
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (revocationBehavior != null)
      'revocation_behavior': signingSecretRevocationBehaviorToString(
        revocationBehavior!,
      ),
  };

  /// Creates a copy with replaced values.
  RotateSigningSecretRequest copyWith({
    Object? revocationBehavior = unsetCopyWithValue,
  }) {
    return RotateSigningSecretRequest(
      revocationBehavior: revocationBehavior == unsetCopyWithValue
          ? this.revocationBehavior
          : revocationBehavior as SigningSecretRevocationBehavior?,
    );
  }
}
