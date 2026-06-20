import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request body for calling an MCP tool on a connector.
@immutable
class ConnectorCallToolRequest {
  /// The arguments to pass to the tool.
  final Map<String, dynamic>? arguments;

  /// Creates a [ConnectorCallToolRequest].
  const ConnectorCallToolRequest({this.arguments});

  /// Creates a [ConnectorCallToolRequest] from JSON.
  factory ConnectorCallToolRequest.fromJson(Map<String, dynamic> json) =>
      ConnectorCallToolRequest(
        arguments: json['arguments'] as Map<String, dynamic>?,
      );

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() => {
    if (arguments != null) 'arguments': arguments,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for [arguments] to clear it explicitly; omit to keep.
  ConnectorCallToolRequest copyWith({Object? arguments = unsetCopyWithValue}) =>
      ConnectorCallToolRequest(
        arguments: arguments == unsetCopyWithValue
            ? this.arguments
            : arguments as Map<String, dynamic>?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorCallToolRequest &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(arguments, other.arguments);

  @override
  int get hashCode => mapDeepHashCode(arguments);

  @override
  String toString() => 'ConnectorCallToolRequest(arguments: $arguments)';
}
