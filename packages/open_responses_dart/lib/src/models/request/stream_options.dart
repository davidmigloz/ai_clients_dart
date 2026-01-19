import 'package:meta/meta.dart';

/// Options that control streamed response behavior.
@immutable
class StreamOptions {
  /// Controls whether the server includes obfuscation padding in streamed events.
  ///
  /// When enabled, the server adds random padding to response events to help
  /// prevent timing-based side-channel attacks that could reveal sensitive
  /// information about the response content.
  ///
  /// When `null`, the field is omitted from the request and the server applies
  /// its default behavior (typically `true`). Set to an explicit `true` or
  /// `false` to override the server's default.
  final bool? includeObfuscation;

  /// Creates a [StreamOptions].
  const StreamOptions({this.includeObfuscation});

  /// Creates a [StreamOptions] from JSON.
  factory StreamOptions.fromJson(Map<String, dynamic> json) {
    return StreamOptions(
      includeObfuscation: json['include_obfuscation'] as bool?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (includeObfuscation != null) 'include_obfuscation': includeObfuscation,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamOptions &&
          runtimeType == other.runtimeType &&
          includeObfuscation == other.includeObfuscation;

  @override
  int get hashCode => includeObfuscation.hashCode;

  @override
  String toString() => 'StreamOptions(includeObfuscation: $includeObfuscation)';
}
