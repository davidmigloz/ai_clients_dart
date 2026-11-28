import '../copy_with_sentinel.dart';

/// The kind of a server-managed credential.
enum CredentialType {
  /// Static token injected into an HTTP request header.
  bearerToken('bearer_token'),

  /// Credential that refreshes access tokens using OAuth2.
  oauth2('oauth2'),

  /// An environment variable credential.
  environmentVariable('environment_variable'),

  /// An unrecognized credential type.
  unknown('unknown');

  const CredentialType(this.value);

  /// Wire representation of the credential type.
  final String value;

  /// Parses a credential type from its wire value.
  static CredentialType fromString(String value) =>
      values.firstWhere((type) => type.value == value, orElse: () => unknown);
}

/// Current status of a server-managed credential.
enum CredentialStatus {
  /// The credential can be used.
  active,

  /// The credential has been revoked.
  revoked,

  /// An unrecognized status.
  unknown;

  /// Parses credential status from its wire value.
  static CredentialStatus fromString(String value) => values.firstWhere(
    (status) => status.name == value,
    orElse: () => unknown,
  );
}

/// Metadata for a credential stored by the Gemini Developer API.
///
/// Server responses contain metadata only. Secret material goes into the
/// create or update request.
final class Credential {
  /// The identifier used to reference this credential from an environment.
  final String id;

  /// The credential type.
  final CredentialType type;

  /// The status of the credential, when returned.
  final CredentialStatus? status;

  /// The time the credential was created, when returned.
  final DateTime? createTime;

  /// The time the credential was last updated, when returned.
  final DateTime? updateTime;

  /// Creates credential metadata.
  const Credential({
    required this.id,
    required this.type,
    this.status,
    this.createTime,
    this.updateTime,
  });

  /// Parses credential metadata.
  factory Credential.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final type = json['type'];
    final status = json['status'] as String?;
    if (id is! String || type is! String) {
      throw const FormatException('Credential: expected an id and type');
    }
    return Credential(
      id: id,
      type: CredentialType.fromString(type),
      status: status == null ? null : CredentialStatus.fromString(status),
      createTime: _parseTime(json['create_time']),
      updateTime: _parseTime(json['update_time']),
    );
  }

  static DateTime? _parseTime(Object? value) {
    if (value == null) return null;
    if (value is String) {
      final time = DateTime.tryParse(value);
      if (time != null) return time;
    }
    throw const FormatException('Credential: invalid timestamp');
  }

  /// Converts the metadata to its wire representation.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.value,
    if (status != null) 'status': status!.name,
    if (createTime != null)
      'create_time': createTime!.toUtc().toIso8601String(),
    if (updateTime != null)
      'update_time': updateTime!.toUtc().toIso8601String(),
  };

  /// Returns a copy with supplied metadata replaced.
  Credential copyWith({
    String? id,
    CredentialType? type,
    Object? status = unsetCopyWithValue,
    Object? createTime = unsetCopyWithValue,
    Object? updateTime = unsetCopyWithValue,
  }) => Credential(
    id: id ?? this.id,
    type: type ?? this.type,
    status: status == unsetCopyWithValue
        ? this.status
        : status as CredentialStatus?,
    createTime: createTime == unsetCopyWithValue
        ? this.createTime
        : createTime as DateTime?,
    updateTime: updateTime == unsetCopyWithValue
        ? this.updateTime
        : updateTime as DateTime?,
  );
}

/// One page of credential metadata.
final class ListCredentialsResponse {
  /// Credentials returned in this page, when present.
  final List<Credential>? credentials;

  /// The token for the next page, when available.
  final String? nextPageToken;

  /// Creates a page of credential metadata.
  const ListCredentialsResponse({this.credentials, this.nextPageToken});

  /// Parses a page of credential metadata.
  factory ListCredentialsResponse.fromJson(Map<String, dynamic> json) =>
      ListCredentialsResponse(
        credentials: (json['credentials'] as List<dynamic>?)
            ?.map((item) => Credential.fromJson(item as Map<String, dynamic>))
            .toList(),
        nextPageToken: json['next_page_token'] as String?,
      );

  /// Converts the page to its wire representation.
  Map<String, dynamic> toJson() => {
    if (credentials != null)
      'credentials': credentials!
          .map((credential) => credential.toJson())
          .toList(),
    'next_page_token': ?nextPageToken,
  };

  /// Returns a copy with supplied fields replaced.
  ListCredentialsResponse copyWith({
    Object? credentials = unsetCopyWithValue,
    Object? nextPageToken = unsetCopyWithValue,
  }) => ListCredentialsResponse(
    credentials: credentials == unsetCopyWithValue
        ? this.credentials
        : credentials as List<Credential>?,
    nextPageToken: nextPageToken == unsetCopyWithValue
        ? this.nextPageToken
        : nextPageToken as String?,
  );
}
