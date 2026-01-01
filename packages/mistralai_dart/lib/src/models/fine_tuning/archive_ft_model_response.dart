import 'package:meta/meta.dart';

/// Response from archiving or unarchiving a fine-tuned model.
@immutable
class ArchiveFTModelResponse {
  /// The model ID.
  final String id;

  /// The object type (always "model").
  final String object;

  /// Whether the model is archived.
  final bool archived;

  /// Creates [ArchiveFTModelResponse].
  const ArchiveFTModelResponse({
    required this.id,
    this.object = 'model',
    required this.archived,
  });

  /// Creates from JSON.
  factory ArchiveFTModelResponse.fromJson(Map<String, dynamic> json) =>
      ArchiveFTModelResponse(
        id: json['id'] as String,
        object: json['object'] as String? ?? 'model',
        archived: json['archived'] as bool,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'archived': archived,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArchiveFTModelResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          archived == other.archived;

  @override
  int get hashCode => Object.hash(id, object, archived);

  @override
  String toString() =>
      'ArchiveFTModelResponse(id: $id, object: $object, archived: $archived)';
}
