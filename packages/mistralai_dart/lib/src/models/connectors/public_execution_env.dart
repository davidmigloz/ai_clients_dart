import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../tools/tool.dart';
import 'public_connector_execution_data.dart';

/// Credentials-free projection of a connector execution environment, exposed
/// via the public `/connectors/mistral` response.
@immutable
class PublicExecutionEnv {
  /// The tools available in this environment.
  final List<Tool> tools;

  /// The connector execution data (integrations and execution tools).
  final PublicConnectorExecutionData toolExecutionData;

  /// Non-fatal errors encountered while building the execution environment.
  final List<String> errors;

  /// Creates a [PublicExecutionEnv].
  PublicExecutionEnv({
    required List<Tool> tools,
    required this.toolExecutionData,
    required List<String> errors,
  }) : tools = List.unmodifiable(tools),
       errors = List.unmodifiable(errors);

  /// Creates a [PublicExecutionEnv] from JSON.
  factory PublicExecutionEnv.fromJson(Map<String, dynamic> json) {
    final toolExecutionDataJson =
        json['tool_execution_data'] as Map<String, dynamic>?;
    if (toolExecutionDataJson == null) {
      throw const FormatException(
        'PublicExecutionEnv: missing required field "tool_execution_data"',
      );
    }
    return PublicExecutionEnv(
      tools:
          (json['tools'] as List?)
              ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      toolExecutionData: PublicConnectorExecutionData.fromJson(
        toolExecutionDataJson,
      ),
      errors: (json['errors'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'tools': tools.map((e) => e.toJson()).toList(),
    'tool_execution_data': toolExecutionData.toJson(),
    'errors': errors,
  };

  /// Creates a copy with replaced values.
  PublicExecutionEnv copyWith({
    List<Tool>? tools,
    PublicConnectorExecutionData? toolExecutionData,
    List<String>? errors,
  }) {
    return PublicExecutionEnv(
      tools: tools ?? this.tools,
      toolExecutionData: toolExecutionData ?? this.toolExecutionData,
      errors: errors ?? this.errors,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PublicExecutionEnv) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(tools, other.tools) &&
        toolExecutionData == other.toolExecutionData &&
        listsEqual(errors, other.errors);
  }

  @override
  int get hashCode =>
      Object.hash(listHash(tools), toolExecutionData, listHash(errors));

  @override
  String toString() =>
      'PublicExecutionEnv('
      'tools: ${tools.length}, '
      'toolExecutionData: $toolExecutionData, '
      'errors: $errors'
      ')';
}
