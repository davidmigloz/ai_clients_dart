import 'package:meta/meta.dart';

/// A short-lived enrollment URL for a user profile.
///
/// Send this URL to the end user to authorize their profile. Valid until
/// [expiresAt]; once expired, request a new one.
@immutable
class EnrollmentUrl {
  /// Object type. Always `enrollment_url`.
  final String type;

  /// Enrollment URL to send to the end user. Valid until [expiresAt].
  final String url;

  /// When this enrollment URL expires.
  final DateTime expiresAt;

  /// Creates an [EnrollmentUrl].
  const EnrollmentUrl({
    this.type = 'enrollment_url',
    required this.url,
    required this.expiresAt,
  });

  /// Creates an [EnrollmentUrl] from JSON.
  factory EnrollmentUrl.fromJson(Map<String, dynamic> json) {
    return EnrollmentUrl(
      type: json['type'] as String? ?? 'enrollment_url',
      url: json['url'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'url': url,
    'expires_at': expiresAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  EnrollmentUrl copyWith({String? type, String? url, DateTime? expiresAt}) {
    return EnrollmentUrl(
      type: type ?? this.type,
      url: url ?? this.url,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnrollmentUrl &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          url == other.url &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode => Object.hash(type, url, expiresAt);

  @override
  String toString() =>
      'EnrollmentUrl(type: $type, url: $url, expiresAt: $expiresAt)';
}
