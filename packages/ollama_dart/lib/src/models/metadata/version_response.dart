import 'package:meta/meta.dart';

/// Response containing the Ollama version.
@immutable
class VersionResponse {
  /// Version of Ollama.
  final String? version;

  /// Creates a [VersionResponse].
  const VersionResponse({this.version});

  /// Creates a [VersionResponse] from JSON.
  factory VersionResponse.fromJson(Map<String, dynamic> json) =>
      VersionResponse(version: json['version'] as String?);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (version != null) 'version': version};

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
