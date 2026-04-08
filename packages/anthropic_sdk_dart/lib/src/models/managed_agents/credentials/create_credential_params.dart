import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'credential_auth.dart';

/// Request parameters for creating a credential.
@immutable
class CreateCredentialParams {
  /// Authentication configuration for the credential.
  final CredentialCreateAuth auth;

  /// Human-readable name for the credential. Up to 255 characters.
  final String? displayName;

  /// Arbitrary key-value metadata to attach to the credential.
  final Map<String, String>? metadata;

  /// Creates a [CreateCredentialParams].
  const CreateCredentialParams({
    required this.auth,
    this.displayName,
    this.metadata,
  });

  /// Creates a [CreateCredentialParams] from JSON.
  factory CreateCredentialParams.fromJson(Map<String, dynamic> json) {
    return CreateCredentialParams(
      auth: CredentialCreateAuth.fromJson(json['auth'] as Map<String, dynamic>),
      displayName: json['display_name'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'auth': auth.toJson(),
    if (displayName != null) 'display_name': displayName,
    if (metadata != null) 'metadata': metadata,
  };

  /// Creates a copy with replaced values.
  ///
  /// For nullable fields ([displayName], [metadata]), pass the sentinel value
  /// [unsetCopyWithValue] (or omit) to keep the original value, or pass
  /// `null` explicitly to set the field to null.
  CreateCredentialParams copyWith({
    CredentialCreateAuth? auth,
    Object? displayName = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return CreateCredentialParams(
      auth: auth ?? this.auth,
      displayName: displayName == unsetCopyWithValue
          ? this.displayName
          : displayName as String?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateCredentialParams &&
          runtimeType == other.runtimeType &&
          auth == other.auth &&
          displayName == other.displayName &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(auth, displayName, mapHash(metadata));

  @override
  String toString() =>
      'CreateCredentialParams('
      'auth: $auth, '
      'displayName: $displayName, '
      'metadata: $metadata)';
}
