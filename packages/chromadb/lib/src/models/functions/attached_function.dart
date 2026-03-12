import 'package:meta/meta.dart';

import '../../utils/copy_with_sentinel.dart';

/// Full details of an attached function.
///
/// Returned from get operations with complete information.
@immutable
class AttachedFunction {
  /// The unique identifier of this attached function instance.
  final String id;

  /// The name of this function instance.
  final String name;

  /// The name of the function type.
  final String functionName;

  /// The ID of the input collection.
  final String inputCollectionId;

  /// The name of the output collection.
  final String outputCollection;

  /// The ID of the output collection (may be null if not yet created).
  final String? outputCollectionId;

  /// The tenant ID.
  final String tenantId;

  /// The database ID.
  final String databaseId;

  /// The WAL position up to which the function has processed.
  final int completionOffset;

  /// Minimum number of records required before invocation.
  final int minRecordsForInvocation;

  /// Function parameters as a JSON string (nullable).
  final String? params;

  /// Creates an attached function.
  const AttachedFunction({
    required this.id,
    required this.name,
    required this.functionName,
    required this.inputCollectionId,
    required this.outputCollection,
    this.outputCollectionId,
    required this.tenantId,
    required this.databaseId,
    required this.completionOffset,
    required this.minRecordsForInvocation,
    this.params,
  });

  /// Creates an attached function from JSON.
  factory AttachedFunction.fromJson(Map<String, dynamic> json) {
    return AttachedFunction(
      id: json['id'] as String,
      name: json['name'] as String,
      functionName: json['function_name'] as String,
      inputCollectionId: json['input_collection_id'] as String,
      outputCollection: json['output_collection'] as String,
      outputCollectionId: json['output_collection_id'] as String?,
      tenantId: json['tenant_id'] as String,
      databaseId: json['database_id'] as String,
      completionOffset: json['completion_offset'] as int,
      minRecordsForInvocation: json['min_records_for_invocation'] as int,
      params: json['params'] as String?,
    );
  }

  /// Converts this function to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'function_name': functionName,
      'input_collection_id': inputCollectionId,
      'output_collection': outputCollection,
      if (outputCollectionId != null)
        'output_collection_id': outputCollectionId,
      'tenant_id': tenantId,
      'database_id': databaseId,
      'completion_offset': completionOffset,
      'min_records_for_invocation': minRecordsForInvocation,
      'params': ?params,
    };
  }

  /// Creates a copy with replaced values.
  AttachedFunction copyWith({
    String? id,
    String? name,
    String? functionName,
    String? inputCollectionId,
    String? outputCollection,
    Object? outputCollectionId = unsetCopyWithValue,
    String? tenantId,
    String? databaseId,
    int? completionOffset,
    int? minRecordsForInvocation,
    Object? params = unsetCopyWithValue,
  }) {
    return AttachedFunction(
      id: id ?? this.id,
      name: name ?? this.name,
      functionName: functionName ?? this.functionName,
      inputCollectionId: inputCollectionId ?? this.inputCollectionId,
      outputCollection: outputCollection ?? this.outputCollection,
      outputCollectionId: outputCollectionId == unsetCopyWithValue
          ? this.outputCollectionId
          : outputCollectionId as String?,
      tenantId: tenantId ?? this.tenantId,
      databaseId: databaseId ?? this.databaseId,
      completionOffset: completionOffset ?? this.completionOffset,
      minRecordsForInvocation:
          minRecordsForInvocation ?? this.minRecordsForInvocation,
      params: params == unsetCopyWithValue ? this.params : params as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachedFunction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          functionName == other.functionName &&
          inputCollectionId == other.inputCollectionId &&
          outputCollection == other.outputCollection &&
          outputCollectionId == other.outputCollectionId &&
          tenantId == other.tenantId &&
          databaseId == other.databaseId &&
          completionOffset == other.completionOffset &&
          minRecordsForInvocation == other.minRecordsForInvocation &&
          params == other.params;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    functionName,
    inputCollectionId,
    outputCollection,
    outputCollectionId,
    tenantId,
    databaseId,
    completionOffset,
    minRecordsForInvocation,
    params,
  );

  @override
  String toString() =>
      'AttachedFunction(id: $id, name: $name, functionName: $functionName, '
      'inputCollectionId: $inputCollectionId, '
      'outputCollection: $outputCollection)';
}
