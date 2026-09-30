import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A tensor returned by verbose model inspection.
@immutable
class ModelTensor {
  /// Tensor name.
  final String name;

  /// Tensor data type, such as `F32` or `Q4_0`.
  final String type;

  /// Tensor dimensions in the order reported by the model.
  final List<int> shape;

  /// Creates a [ModelTensor], copying its dimensions.
  ModelTensor({
    required this.name,
    required this.type,
    required List<int> shape,
  }) : shape = List.unmodifiable(shape);

  /// Creates a [ModelTensor] from JSON.
  ///
  /// Throws [FormatException] for missing or incorrectly typed fields.
  factory ModelTensor.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final type = json['type'];
    final shape = json['shape'];
    if (name is! String || type is! String || shape is! List) {
      throw const FormatException(
        'ModelTensor: expected string "name", string "type", and array "shape"',
      );
    }
    final dimensions = <int>[];
    for (var i = 0; i < shape.length; i++) {
      final dimension = shape[i];
      if (dimension is! int) {
        throw FormatException('ModelTensor: "shape[$i]" must be an integer');
      }
      dimensions.add(dimension);
    }
    return ModelTensor(name: name, type: type, shape: dimensions);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'name': name, 'type': type, 'shape': shape};

  /// Creates a copy with replaced values.
  ModelTensor copyWith({String? name, String? type, List<int>? shape}) =>
      ModelTensor(
        name: name ?? this.name,
        type: type ?? this.type,
        shape: shape ?? this.shape,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelTensor &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          listsEqual(shape, other.shape);

  @override
  int get hashCode => Object.hash(name, type, listHash(shape));

  @override
  String toString() => 'ModelTensor(name: $name, type: $type, shape: $shape)';
}
