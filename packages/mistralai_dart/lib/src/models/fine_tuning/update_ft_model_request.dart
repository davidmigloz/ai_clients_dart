import 'package:meta/meta.dart';

/// Request to update a fine-tuned model's metadata.
@immutable
class UpdateFTModelRequest {
  /// The new name for the model.
  final String? name;

  /// The new description for the model.
  final String? description;

  /// Creates [UpdateFTModelRequest].
  const UpdateFTModelRequest({this.name, this.description});

  /// Creates from JSON.
  factory UpdateFTModelRequest.fromJson(Map<String, dynamic> json) =>
      UpdateFTModelRequest(
        name: json['name'] as String?,
        description: json['description'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (description != null) 'description': description,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateFTModelRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description;

  @override
  int get hashCode => Object.hash(name, description);

  @override
  String toString() =>
      'UpdateFTModelRequest(name: $name, description: $description)';
}
