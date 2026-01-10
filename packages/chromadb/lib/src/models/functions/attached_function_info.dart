import 'package:meta/meta.dart';

/// Brief information about an attached function.
///
/// Returned from attach operations with minimal details.
@immutable
class AttachedFunctionInfo {
  /// The unique identifier of this attached function instance.
  final String id;

  /// The name of this function instance.
  final String name;

  /// The name of the function type.
  final String functionName;

  /// Creates an attached function info.
  const AttachedFunctionInfo({
    required this.id,
    required this.name,
    required this.functionName,
  });

  /// Creates an attached function info from JSON.
  factory AttachedFunctionInfo.fromJson(Map<String, dynamic> json) {
    return AttachedFunctionInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      functionName: json['function_name'] as String,
    );
  }

  /// Converts this info to JSON.
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'function_name': functionName};
  }

  /// Creates a copy with replaced values.
  AttachedFunctionInfo copyWith({
    String? id,
    String? name,
    String? functionName,
  }) {
    return AttachedFunctionInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      functionName: functionName ?? this.functionName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachedFunctionInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          functionName == other.functionName;

  @override
  int get hashCode => Object.hash(id, name, functionName);

  @override
  String toString() =>
      'AttachedFunctionInfo(id: $id, name: $name, functionName: $functionName)';
}
