import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'execution_tool.dart';
import 'public_execution_connector.dart';

/// Public execution data describing the connector integrations and tools
/// available for a run.
@immutable
class PublicConnectorExecutionData {
  /// The connector integrations available for execution.
  final List<PublicExecutionConnector> integrations;

  /// The tools available for execution.
  final List<ExecutionTool> tools;

  /// Whether execution routes through the connectors gateway.
  final bool useConnectorsGateway;

  /// Creates a [PublicConnectorExecutionData].
  PublicConnectorExecutionData({
    required List<PublicExecutionConnector> integrations,
    required List<ExecutionTool> tools,
    this.useConnectorsGateway = false,
  }) : integrations = List.unmodifiable(integrations),
       tools = List.unmodifiable(tools);

  /// Creates a [PublicConnectorExecutionData] from JSON.
  factory PublicConnectorExecutionData.fromJson(Map<String, dynamic> json) =>
      PublicConnectorExecutionData(
        integrations:
            (json['integrations'] as List?)
                ?.map(
                  (e) => PublicExecutionConnector.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [],
        tools:
            (json['tools'] as List?)
                ?.map((e) => ExecutionTool.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        useConnectorsGateway: json['use_connectors_gateway'] as bool? ?? false,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'integrations': integrations.map((e) => e.toJson()).toList(),
    'tools': tools.map((e) => e.toJson()).toList(),
    'use_connectors_gateway': useConnectorsGateway,
  };

  /// Creates a copy with replaced values.
  PublicConnectorExecutionData copyWith({
    List<PublicExecutionConnector>? integrations,
    List<ExecutionTool>? tools,
    bool? useConnectorsGateway,
  }) {
    return PublicConnectorExecutionData(
      integrations: integrations ?? this.integrations,
      tools: tools ?? this.tools,
      useConnectorsGateway: useConnectorsGateway ?? this.useConnectorsGateway,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PublicConnectorExecutionData) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(integrations, other.integrations) &&
        listsEqual(tools, other.tools) &&
        useConnectorsGateway == other.useConnectorsGateway;
  }

  @override
  int get hashCode => Object.hash(
    listHash(integrations),
    listHash(tools),
    useConnectorsGateway,
  );

  @override
  String toString() =>
      'PublicConnectorExecutionData('
      'integrations: ${integrations.length}, '
      'tools: ${tools.length}, '
      'useConnectorsGateway: $useConnectorsGateway'
      ')';
}
