import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'query_definition.dart';
import 'signal_definition.dart';
import 'update_definition.dart';

/// Code-based workflow definition.
@immutable
class WorkflowCodeDefinition {
  /// The input JSON schema.
  final Map<String, dynamic> inputSchema;

  /// The output JSON schema.
  final Map<String, dynamic>? outputSchema;

  /// Whether to enforce determinism.
  final bool enforceDeterminism;

  /// Execution timeout in seconds.
  final double? executionTimeout;

  /// Query definitions.
  final List<QueryDefinition>? queries;

  /// Signal definitions.
  final List<SignalDefinition>? signals;

  /// Update definitions.
  final List<UpdateDefinition>? updates;

  /// Creates a [WorkflowCodeDefinition].
  WorkflowCodeDefinition({
    required this.inputSchema,
    this.outputSchema,
    this.enforceDeterminism = false,
    this.executionTimeout,
    List<QueryDefinition>? queries,
    List<SignalDefinition>? signals,
    List<UpdateDefinition>? updates,
  }) : queries = queries != null ? List.unmodifiable(queries) : null,
       signals = signals != null ? List.unmodifiable(signals) : null,
       updates = updates != null ? List.unmodifiable(updates) : null;

  /// Creates a [WorkflowCodeDefinition] from JSON.
  factory WorkflowCodeDefinition.fromJson(Map<String, dynamic> json) =>
      WorkflowCodeDefinition(
        inputSchema: json['input_schema'] as Map<String, dynamic>? ?? {},
        outputSchema: json['output_schema'] as Map<String, dynamic>?,
        enforceDeterminism: json['enforce_determinism'] as bool? ?? false,
        executionTimeout: (json['execution_timeout'] as num?)?.toDouble(),
        queries: (json['queries'] as List?)
            ?.map((e) => QueryDefinition.fromJson(e as Map<String, dynamic>))
            .toList(),
        signals: (json['signals'] as List?)
            ?.map((e) => SignalDefinition.fromJson(e as Map<String, dynamic>))
            .toList(),
        updates: (json['updates'] as List?)
            ?.map((e) => UpdateDefinition.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'input_schema': inputSchema,
    if (outputSchema != null) 'output_schema': outputSchema,
    'enforce_determinism': enforceDeterminism,
    if (executionTimeout != null) 'execution_timeout': executionTimeout,
    if (queries != null) 'queries': queries?.map((e) => e.toJson()).toList(),
    if (signals != null) 'signals': signals?.map((e) => e.toJson()).toList(),
    if (updates != null) 'updates': updates?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  WorkflowCodeDefinition copyWith({
    Map<String, dynamic>? inputSchema,
    Object? outputSchema = unsetCopyWithValue,
    bool? enforceDeterminism,
    Object? executionTimeout = unsetCopyWithValue,
    Object? queries = unsetCopyWithValue,
    Object? signals = unsetCopyWithValue,
    Object? updates = unsetCopyWithValue,
  }) {
    return WorkflowCodeDefinition(
      inputSchema: inputSchema ?? this.inputSchema,
      outputSchema: outputSchema == unsetCopyWithValue
          ? this.outputSchema
          : outputSchema as Map<String, dynamic>?,
      enforceDeterminism: enforceDeterminism ?? this.enforceDeterminism,
      executionTimeout: executionTimeout == unsetCopyWithValue
          ? this.executionTimeout
          : executionTimeout as double?,
      queries: queries == unsetCopyWithValue
          ? this.queries
          : queries as List<QueryDefinition>?,
      signals: signals == unsetCopyWithValue
          ? this.signals
          : signals as List<SignalDefinition>?,
      updates: updates == unsetCopyWithValue
          ? this.updates
          : updates as List<UpdateDefinition>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowCodeDefinition) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!mapsDeepEqual(inputSchema, other.inputSchema)) return false;
    if (!mapsDeepEqual(outputSchema, other.outputSchema)) return false;
    if (!listsEqual(queries, other.queries)) return false;
    if (!listsEqual(signals, other.signals)) return false;
    if (!listsEqual(updates, other.updates)) return false;
    return enforceDeterminism == other.enforceDeterminism &&
        executionTimeout == other.executionTimeout;
  }

  @override
  int get hashCode => Object.hash(
    mapDeepHashCode(inputSchema),
    mapDeepHashCode(outputSchema),
    enforceDeterminism,
    executionTimeout,
    listHash(queries),
    listHash(signals),
    listHash(updates),
  );

  @override
  String toString() =>
      'WorkflowCodeDefinition('
      'inputSchema: ${inputSchema.length}, '
      'outputSchema: ${outputSchema?.length ?? 'null'}, '
      'enforceDeterminism: $enforceDeterminism, '
      'executionTimeout: $executionTimeout, '
      'queries: ${queries?.length ?? 'null'}, '
      'signals: ${signals?.length ?? 'null'}, '
      'updates: ${updates?.length ?? 'null'}'
      ')';
}
