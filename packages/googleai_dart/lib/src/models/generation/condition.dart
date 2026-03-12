import '../copy_with_sentinel.dart';

/// Filter condition applicable to a single key.
class Condition {
  /// The numeric value to filter the metadata on.
  final double? numericValue;

  /// Required. Operator applied to the given key-value pair to trigger the
  /// condition.
  final String operation;

  /// The string value to filter the metadata on.
  final String? stringValue;

  /// Creates a [Condition].
  const Condition({
    this.numericValue,
    required this.operation,
    this.stringValue,
  });

  /// Creates a [Condition] from JSON.
  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      numericValue: json['numericValue'] != null
          ? (json['numericValue'] as num).toDouble()
          : null,
      operation: json['operation'] as String,
      stringValue: json['stringValue'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'numericValue': ?numericValue,
    'operation': operation,
    'stringValue': ?stringValue,
  };

  /// Creates a copy with replaced values.
  Condition copyWith({
    Object? numericValue = unsetCopyWithValue,
    Object? operation = unsetCopyWithValue,
    Object? stringValue = unsetCopyWithValue,
  }) {
    return Condition(
      numericValue: numericValue == unsetCopyWithValue
          ? this.numericValue
          : numericValue as double?,
      operation: operation == unsetCopyWithValue
          ? this.operation
          : operation! as String,
      stringValue: stringValue == unsetCopyWithValue
          ? this.stringValue
          : stringValue as String?,
    );
  }
}
