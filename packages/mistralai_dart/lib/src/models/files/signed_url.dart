import 'package:meta/meta.dart';

/// A pre-signed URL for downloading a file.
@immutable
class SignedUrl {
  /// The pre-signed URL for downloading the file.
  final String url;

  /// Unix timestamp of when the URL expires.
  final int? expiresAt;

  /// Creates a [SignedUrl].
  const SignedUrl({required this.url, this.expiresAt});

  /// Creates a [SignedUrl] from JSON.
  factory SignedUrl.fromJson(Map<String, dynamic> json) => SignedUrl(
    url: json['url'] as String? ?? '',
    expiresAt: json['expires_at'] as int?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'url': url,
    if (expiresAt != null) 'expires_at': expiresAt,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignedUrl &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode => Object.hash(url, expiresAt);

  @override
  String toString() => 'SignedUrl(url: $url, expiresAt: $expiresAt)';
}
