import 'dart:convert';

import 'package:meta/meta.dart';

import '../../utils/copy_with_sentinel.dart';
import '../../utils/equality_helpers.dart';

/// Request to attach a function to a collection.
///
/// Attaches a serverless function that processes records in the collection
/// and outputs results to another collection.
@immutable
class AttachFunctionRequest {
  /// The name for this function instance.
  final String name;

  /// The ID of the function to attach (references a registered function).
  final String functionId;

  /// The name of the collection where output will be stored.
  final String outputCollection;

  /// Optional parameters for the function (will be serialized to JSON string).
  final Map<String, dynamic>? params;

  /// Creates an attach function request.
  const AttachFunctionRequest({
    required this.name,
    required this.functionId,
    required this.outputCollection,
    this.params,
  });

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'function_id': functionId,
      'output_collection': outputCollection,
      if (params != null) 'params': jsonEncode(params),
    };
  }

  /// Creates a copy with replaced values.
  AttachFunctionRequest copyWith({
    String? name,
    String? functionId,
    String? outputCollection,
    Object? params = unsetCopyWithValue,
  }) {
    return AttachFunctionRequest(
      name: name ?? this.name,
      functionId: functionId ?? this.functionId,
      outputCollection: outputCollection ?? this.outputCollection,
      params: params == unsetCopyWithValue
          ? this.params
          : params as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachFunctionRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          functionId == other.functionId &&
          outputCollection == other.outputCollection &&
          mapsEqual(params, other.params);

  @override
  int get hashCode =>
      Object.hash(name, functionId, outputCollection, mapHashCode(params));

  @override
  String toString() =>
      'AttachFunctionRequest(name: $name, functionId: $functionId, '
      'outputCollection: $outputCollection, params: $params)';
}
