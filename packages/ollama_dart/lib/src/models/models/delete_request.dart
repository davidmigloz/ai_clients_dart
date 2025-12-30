import 'package:meta/meta.dart';

/// Request to delete a model.
@immutable
class DeleteRequest {
  /// Model name to delete.
  final String model;

  /// Creates a [DeleteRequest].
  const DeleteRequest({required this.model});

  /// Creates a [DeleteRequest] from JSON.
  factory DeleteRequest.fromJson(Map<String, dynamic> json) =>
      DeleteRequest(model: json['model'] as String);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'model': model};

  /// Creates a copy with replaced values.
  DeleteRequest copyWith({String? model}) {
    return DeleteRequest(model: model ?? this.model);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteRequest &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => model.hashCode;

  @override
  String toString() => 'DeleteRequest(model: $model)';
}
