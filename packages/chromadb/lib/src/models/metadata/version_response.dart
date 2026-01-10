import 'package:meta/meta.dart';

/// Response from the version endpoint.
///
/// Contains version information about the ChromaDB server.
@immutable
class VersionResponse {
  /// The server version string.
  final String version;

  /// Creates a version response.
  const VersionResponse({required this.version});

  /// Creates a version response from JSON.
  factory VersionResponse.fromJson(Map<String, dynamic> json) {
    return VersionResponse(version: json['version'] as String);
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() => {'version': version};

  /// Creates a copy of this response with optional modifications.
  VersionResponse copyWith({String? version}) {
    return VersionResponse(version: version ?? this.version);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VersionResponse &&
          runtimeType == other.runtimeType &&
          version == other.version;

  @override
  int get hashCode => version.hashCode;

  @override
  String toString() => 'VersionResponse(version: $version)';
}
