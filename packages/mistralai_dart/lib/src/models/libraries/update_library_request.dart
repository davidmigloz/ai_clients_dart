import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request to update a library (PATCH semantics).
///
/// All fields are optional; omitted fields are left unchanged. [name] is sent
/// only when non-null. [description] is tri-state: provide a value to set it,
/// or set [clearDescription] to emit an explicit `null` that clears it
/// server-side; otherwise it is omitted (unchanged).
@immutable
class UpdateLibraryRequest {
  /// The new name for the library, if changing it.
  final String? name;

  /// The new description for the library, if setting one.
  final String? description;

  /// When true, `toJson` emits `"description": null` to clear the description.
  final bool clearDescription;

  /// Creates an [UpdateLibraryRequest].
  const UpdateLibraryRequest({
    this.name,
    this.description,
    this.clearDescription = false,
  });

  /// Creates an [UpdateLibraryRequest] from JSON.
  factory UpdateLibraryRequest.fromJson(Map<String, dynamic> json) =>
      UpdateLibraryRequest(
        name: json['name'] as String?,
        description: json['description'] as String?,
        clearDescription:
            json.containsKey('description') && json['description'] == null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (description != null)
      'description': description
    else if (clearDescription)
      'description': null,
  };

  /// Creates a copy with replaced values.
  UpdateLibraryRequest copyWith({
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    bool? clearDescription,
  }) {
    return UpdateLibraryRequest(
      name: name == unsetCopyWithValue ? this.name : name as String?,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      clearDescription: clearDescription ?? this.clearDescription,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UpdateLibraryRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name &&
        description == other.description &&
        clearDescription == other.clearDescription;
  }

  @override
  int get hashCode => Object.hash(name, description, clearDescription);

  @override
  String toString() =>
      'UpdateLibraryRequest(name: $name, description: $description, '
      'clearDescription: $clearDescription)';
}
