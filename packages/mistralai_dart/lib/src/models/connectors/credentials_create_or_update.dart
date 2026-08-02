import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'connection_credentials.dart';

/// Request to create or update non-OAuth2 credentials for a connector.
@immutable
class CredentialsCreateOrUpdate {
  /// Name of the credentials. Use this name to access or modify them later.
  final String name;

  /// Controls whether this credential is the default for its auth method.
  final bool? isDefault;

  /// The credential data (headers, bearer token, etc.).
  final ConnectionCredentials? credentials;

  /// An optional human-readable title for the credentials.
  final String? title;

  /// Creates a [CredentialsCreateOrUpdate].
  const CredentialsCreateOrUpdate({
    required this.name,
    this.isDefault,
    this.credentials,
    this.title,
  });

  /// Creates a [CredentialsCreateOrUpdate] from JSON.
  factory CredentialsCreateOrUpdate.fromJson(Map<String, dynamic> json) =>
      CredentialsCreateOrUpdate(
        name: json['name'] as String? ?? '',
        isDefault: json['is_default'] as bool?,
        credentials: json['credentials'] != null
            ? ConnectionCredentials.fromJson(
                json['credentials'] as Map<String, dynamic>,
              )
            : null,
        title: json['title'] as String?,
      );

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (isDefault != null) 'is_default': isDefault,
    if (credentials != null) 'credentials': credentials!.toJson(),
    if (title != null) 'title': title,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  CredentialsCreateOrUpdate copyWith({
    String? name,
    Object? isDefault = unsetCopyWithValue,
    Object? credentials = unsetCopyWithValue,
    Object? title = unsetCopyWithValue,
  }) => CredentialsCreateOrUpdate(
    name: name ?? this.name,
    isDefault: isDefault == unsetCopyWithValue
        ? this.isDefault
        : isDefault as bool?,
    credentials: credentials == unsetCopyWithValue
        ? this.credentials
        : credentials as ConnectionCredentials?,
    title: title == unsetCopyWithValue ? this.title : title as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialsCreateOrUpdate &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          isDefault == other.isDefault &&
          credentials == other.credentials &&
          title == other.title;

  @override
  int get hashCode => Object.hash(name, isDefault, credentials, title);

  @override
  String toString() =>
      'CredentialsCreateOrUpdate('
      'name: $name, '
      'isDefault: $isDefault, '
      'credentials: ${credentials == null ? null : 'ConnectionCredentials([redacted])'}, '
      'title: $title)';
}
