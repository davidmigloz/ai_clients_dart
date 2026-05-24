import 'package:meta/meta.dart';

/// Citations configuration for a content block or tool output.
///
/// Toggles whether the model may cite the associated source (e.g. a
/// `search_result` block, a `document` block, or web fetch tool output).
@immutable
class RequestCitationsConfig {
  /// Whether citations are enabled for the associated source.
  final bool enabled;

  /// Creates a [RequestCitationsConfig].
  const RequestCitationsConfig({this.enabled = true});

  /// Creates a [RequestCitationsConfig] from JSON.
  factory RequestCitationsConfig.fromJson(Map<String, dynamic> json) {
    return RequestCitationsConfig(enabled: json['enabled'] as bool? ?? true);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'enabled': enabled};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestCitationsConfig &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled;

  @override
  int get hashCode => enabled.hashCode;

  @override
  String toString() => 'RequestCitationsConfig(enabled: $enabled)';
}
