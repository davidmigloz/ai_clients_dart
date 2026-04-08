import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'credential_auth.dart';

/// Request parameters for updating a credential.
///
/// Omit a field to preserve its current value.
@immutable
class UpdateCredentialParams {
  /// Updated authentication configuration.
  ///
  /// The `type` is immutable; the variant sent must match the stored
  /// credential's type.
  final CredentialUpdateAuth? auth;

  /// Updated human-readable name for the credential. 1-255 characters.
  final String? displayName;

  /// Metadata patch. Set a key to a string to upsert it, or to null to
  /// delete it. Omitted keys are preserved.
  final Map<String, String?>? metadata;

  /// Creates an [UpdateCredentialParams].
  const UpdateCredentialParams({this.auth, this.displayName, this.metadata});

  /// Creates an [UpdateCredentialParams] from JSON.
  factory UpdateCredentialParams.fromJson(Map<String, dynamic> json) {
    return UpdateCredentialParams(
      auth: json['auth'] != null
          ? CredentialUpdateAuth.fromJson(json['auth'] as Map<String, dynamic>)
          : null,
      displayName: json['display_name'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String?),
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (auth != null) 'auth': auth!.toJson(),
    if (displayName != null) 'display_name': displayName,
    if (metadata != null) 'metadata': metadata,
  };

  /// Creates a copy with replaced values.
  ///
  /// For nullable fields ([auth], [displayName], [metadata]), pass the sentinel
  /// value [unsetCopyWithValue] (or omit) to keep the original value, or pass
  /// `null` explicitly to set the field to null.
  UpdateCredentialParams copyWith({
    Object? auth = unsetCopyWithValue,
    Object? displayName = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return UpdateCredentialParams(
      auth: auth == unsetCopyWithValue
          ? this.auth
          : auth as CredentialUpdateAuth?,
      displayName: displayName == unsetCopyWithValue
          ? this.displayName
          : displayName as String?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String?>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateCredentialParams &&
          runtimeType == other.runtimeType &&
          auth == other.auth &&
          displayName == other.displayName &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(auth, displayName, mapHash(metadata));

  @override
  String toString() =>
      'UpdateCredentialParams('
      'auth: $auth, '
      'displayName: $displayName, '
      'metadata: $metadata)';
}
