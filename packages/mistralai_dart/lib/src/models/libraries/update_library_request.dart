import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request to update a library.
@immutable
class UpdateLibraryRequest {
  /// The new name for the library.
  final String name;

  /// The new description for the library.
  final String? description;

  /// Creates an [UpdateLibraryRequest].
  const UpdateLibraryRequest({required this.name, this.description});

  /// Creates an [UpdateLibraryRequest] from JSON.
  factory UpdateLibraryRequest.fromJson(Map<String, dynamic> json) =>
      UpdateLibraryRequest(
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null) 'description': description,
  };

  /// Creates a copy with replaced values.
  UpdateLibraryRequest copyWith({
    String? name,
    Object? description = unsetCopyWithValue,
  }) {
    return UpdateLibraryRequest(
      name: name ?? this.name,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UpdateLibraryRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name && description == other.description;
  }

  @override
  int get hashCode => Object.hash(name, description);

  @override
  String toString() =>
      'UpdateLibraryRequest(name: $name, description: $description)';
}
