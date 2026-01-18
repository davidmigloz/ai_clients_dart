import 'package:meta/meta.dart';

/// Options that control streamed response behavior.
@immutable
class StreamOptions {
  /// Whether to obfuscate sensitive information in streamed output.
  ///
  /// Defaults to `true` on the server.
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
