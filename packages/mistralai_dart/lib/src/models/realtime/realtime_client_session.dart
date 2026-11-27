import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request to mint a model-scoped client token for realtime transcription.
@immutable
final class CreateRealtimeClientSessionRequest {
  /// Creates a request for the model the browser will connect to.
  const CreateRealtimeClientSessionRequest({
    required this.model,
    this.ttlSeconds,
    this.metadata,
  });

  /// Decodes a client session request.
  factory CreateRealtimeClientSessionRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['purpose'] != null && json['purpose'] != 'realtime') {
      throw const FormatException(
        'Expected a realtime client session request.',
      );
    }
    return CreateRealtimeClientSessionRequest(
      model: json['model'] as String,
      ttlSeconds: json['ttl_seconds'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Model ID to allow when connecting.
  final String model;

  /// Requested token lifetime in seconds.
  final int? ttlSeconds;

  /// Metadata applied to the realtime session.
  final Map<String, dynamic>? metadata;

  /// The purpose for which the client session will be created.
  String get purpose => 'realtime';

  /// Encodes the session token request.
  Map<String, dynamic> toJson() => {
    'purpose': purpose,
    'model': model,
    'ttl_seconds': ?ttlSeconds,
    'metadata': ?metadata,
  };

  /// Copies the request with selected fields replaced.
  CreateRealtimeClientSessionRequest copyWith({
    String? model,
    Object? ttlSeconds = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) => CreateRealtimeClientSessionRequest(
    model: model ?? this.model,
    ttlSeconds: identical(ttlSeconds, unsetCopyWithValue)
        ? this.ttlSeconds
        : ttlSeconds as int?,
    metadata: identical(metadata, unsetCopyWithValue)
        ? this.metadata
        : (metadata as Map?)?.cast<String, dynamic>(),
  );
}

/// The ephemeral credential returned by the realtime sessions endpoint.
@immutable
final class RealtimeClientSecret {
  /// Creates a secret with an expiry time.
  const RealtimeClientSecret({required this.value, required this.expiresAt});

  /// Token to pass to the browser. Treat it as a credential.
  final String value;

  /// UTC expiration time of this credential.
  final DateTime expiresAt;

  /// Decodes the server response.
  factory RealtimeClientSecret.fromJson(Map<String, dynamic> json) =>
      RealtimeClientSecret(
        value: json['value'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String).toUtc(),
      );

  /// Serializes the credential for the browser. The result includes the secret.
  Map<String, dynamic> toJson() => {
    'value': value,
    'expires_at': expiresAt.toUtc().toIso8601String(),
  };

  /// Copies the credential with selected fields replaced.
  RealtimeClientSecret copyWith({String? value, DateTime? expiresAt}) =>
      RealtimeClientSecret(
        value: value ?? this.value,
        expiresAt: expiresAt ?? this.expiresAt,
      );

  @override
  String toString() =>
      'RealtimeClientSecret(value: [REDACTED], expiresAt: $expiresAt)';
}

/// The result of minting a realtime client credential.
@immutable
final class RealtimeClientSession {
  /// Creates a session with its credential and expiration.
  const RealtimeClientSession({
    required this.clientSecret,
    required this.expiresAt,
  });

  /// Token and expiration for opening the client session.
  final RealtimeClientSecret clientSecret;

  /// When this session expires.
  final DateTime expiresAt;

  /// The wire object discriminator.
  String get object => 'client.session';

  /// The purpose for which the client session was created.
  String get purpose => 'realtime';

  /// Decodes a realtime client session.
  factory RealtimeClientSession.fromJson(Map<String, dynamic> json) {
    if (json['purpose'] != 'realtime' ||
        (json['object'] != null && json['object'] != 'client.session')) {
      throw const FormatException('Expected a realtime client session.');
    }
    return RealtimeClientSession(
      clientSecret: RealtimeClientSecret.fromJson(
        json['client_secret'] as Map<String, dynamic>,
      ),
      expiresAt: DateTime.parse(json['expires_at'] as String).toUtc(),
    );
  }

  /// Serializes the response. The result includes a credential.
  Map<String, dynamic> toJson() => {
    'object': object,
    'purpose': purpose,
    'expires_at': expiresAt.toUtc().toIso8601String(),
    'client_secret': clientSecret.toJson(),
  };

  /// Copies the session with selected fields replaced.
  RealtimeClientSession copyWith({
    RealtimeClientSecret? clientSecret,
    DateTime? expiresAt,
  }) => RealtimeClientSession(
    clientSecret: clientSecret ?? this.clientSecret,
    expiresAt: expiresAt ?? this.expiresAt,
  );

  @override
  String toString() =>
      'RealtimeClientSession(expiresAt: $expiresAt, clientSecret: $clientSecret)';
}
