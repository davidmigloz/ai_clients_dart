import 'package:meta/meta.dart';

/// Request to update a fine-tuned model's metadata.
@immutable
class UpdateFTModelRequest {
  /// The new name for the model.
  final String? name;

  /// The new description for the model.
  final String? description;

  /// Sends `name: null` instead of leaving the field omitted.
  final bool clearName;

  /// Sends `description: null` instead of leaving the field omitted.
  final bool clearDescription;

  /// Creates [UpdateFTModelRequest].
  const UpdateFTModelRequest({
    this.name,
    this.description,
    this.clearName = false,
    this.clearDescription = false,
  });

  /// Creates from JSON.
  factory UpdateFTModelRequest.fromJson(Map<String, dynamic> json) =>
      UpdateFTModelRequest(
        name: json['name'] as String?,
        description: json['description'] as String?,
        clearName: json.containsKey('name') && json['name'] == null,
        clearDescription:
            json.containsKey('description') && json['description'] == null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    if (clearName && name != null) {
      throw ArgumentError('Specify either name or clearName.');
    }
    if (clearDescription && description != null) {
      throw ArgumentError('Specify either description or clearDescription.');
    }
    return {
      if (clearName || name != null) 'name': name,
      if (clearDescription || description != null) 'description': description,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateFTModelRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          clearName == other.clearName &&
          clearDescription == other.clearDescription;

  @override
  int get hashCode =>
      Object.hash(name, description, clearName, clearDescription);

  @override
  String toString() =>
      'UpdateFTModelRequest(name: $name, description: $description, '
      'clearName: $clearName, clearDescription: $clearDescription)';
}
