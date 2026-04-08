import 'package:meta/meta.dart';

/// Request to create a new dataset.
@immutable
class PostDatasetInSchema {
  /// Dataset name (5-50 characters).
  final String name;

  /// Dataset description (max 200 characters).
  final String description;

  /// Creates a [PostDatasetInSchema].
  const PostDatasetInSchema({required this.name, required this.description});

  /// Creates a [PostDatasetInSchema] from JSON.
  factory PostDatasetInSchema.fromJson(Map<String, dynamic> json) =>
      PostDatasetInSchema(
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'name': name, 'description': description};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDatasetInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name && description == other.description;
  }

  @override
  int get hashCode => Object.hash(name, description);

  @override
  String toString() =>
      'PostDatasetInSchema(name: $name, description: $description)';
}
