import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import 'model.dart';

/// List of models.
@immutable
class ModelList {
  /// The object type (always "list").
  final String object;

  /// List of models.
  final List<Model> data;

  /// Creates a [ModelList].
  const ModelList({required this.object, required this.data});

  /// Creates a [ModelList] from JSON.
  factory ModelList.fromJson(Map<String, dynamic> json) => ModelList(
    object: json['object'] as String? ?? 'list',
    data:
        (json['data'] as List?)
            ?.map((e) => Model.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          listEquals(data, other.data);

  @override
  int get hashCode => Object.hash(object, Object.hashAll(data));

  @override
  String toString() => 'ModelList(data: ${data.length} models)';
}
