import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'auth_status.dart';
import 'credentials_status_error_reason.dart';

/// The status of a connector credential.
@immutable
class CredentialsStatus {
  /// The validity status.
  final AuthStatus statusType;

  /// When the credential was last checked.
  final DateTime? lastCheckedAt;

  /// The HTTP status code observed when the credential errored.
  final int? errorHttpCode;

  /// A human-readable reason describing the error.
  final CredentialsStatusErrorReason? errorMessage;

  /// Creates a [CredentialsStatus].
  const CredentialsStatus({
    required this.statusType,
    this.lastCheckedAt,
    this.errorHttpCode,
    this.errorMessage,
  });

  /// Creates a [CredentialsStatus] from JSON.
  factory CredentialsStatus.fromJson(Map<String, dynamic> json) =>
      CredentialsStatus(
        statusType: AuthStatus.fromJson(json['status_type'] as String?),
        lastCheckedAt: json['last_checked_at'] != null
            ? DateTime.tryParse(json['last_checked_at'] as String)
            : null,
        errorHttpCode: json['error_http_code'] as int?,
        errorMessage: json['error_message'] != null
            ? CredentialsStatusErrorReason.fromJson(
                json['error_message'] as String?,
              )
            : null,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'status_type': statusType.toJson(),
    if (lastCheckedAt != null)
      'last_checked_at': lastCheckedAt!.toIso8601String(),
    if (errorHttpCode != null) 'error_http_code': errorHttpCode,
    if (errorMessage != null) 'error_message': errorMessage!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  CredentialsStatus copyWith({
    AuthStatus? statusType,
    Object? lastCheckedAt = unsetCopyWithValue,
    Object? errorHttpCode = unsetCopyWithValue,
    Object? errorMessage = unsetCopyWithValue,
  }) => CredentialsStatus(
    statusType: statusType ?? this.statusType,
    lastCheckedAt: lastCheckedAt == unsetCopyWithValue
        ? this.lastCheckedAt
        : lastCheckedAt as DateTime?,
    errorHttpCode: errorHttpCode == unsetCopyWithValue
        ? this.errorHttpCode
        : errorHttpCode as int?,
    errorMessage: errorMessage == unsetCopyWithValue
        ? this.errorMessage
        : errorMessage as CredentialsStatusErrorReason?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialsStatus &&
          runtimeType == other.runtimeType &&
          statusType == other.statusType &&
          lastCheckedAt == other.lastCheckedAt &&
          errorHttpCode == other.errorHttpCode &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      Object.hash(statusType, lastCheckedAt, errorHttpCode, errorMessage);

  @override
  String toString() =>
      'CredentialsStatus('
      'statusType: $statusType, '
      'lastCheckedAt: $lastCheckedAt, '
      'errorHttpCode: $errorHttpCode, '
      'errorMessage: $errorMessage)';
}
