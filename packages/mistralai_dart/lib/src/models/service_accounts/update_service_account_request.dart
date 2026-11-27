import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Updates the description of a service account.
@immutable
class UpdateServiceAccountRequest {
  /// Sets [description] when non-null. Set [clearDescription] to clear it.
  const UpdateServiceAccountRequest({
    this.description,
    this.clearDescription = false,
  });

  /// New description to set.
  final String? description;

  /// Sends an explicit null description to remove the existing description.
  final bool clearDescription;

  /// Reads an update and distinguishes omitted descriptions from explicit null.
  factory UpdateServiceAccountRequest.fromJson(Map<String, dynamic> json) =>
      UpdateServiceAccountRequest(
        description: json['description'] as String?,
        clearDescription:
            json.containsKey('description') && json['description'] == null,
      );

  /// Converts the update to JSON.
  Map<String, dynamic> toJson() {
    if (clearDescription && description != null) {
      throw ArgumentError('Choose a description or clearDescription.');
    }
    return {
      if (clearDescription || description != null) 'description': description,
    };
  }

  /// Creates a copy with optional explicit null for [description].
  UpdateServiceAccountRequest copyWith({
    Object? description = unsetCopyWithValue,
    bool? clearDescription,
  }) => UpdateServiceAccountRequest(
    description: description == unsetCopyWithValue
        ? (clearDescription == true ? null : this.description)
        : description as String?,
    clearDescription:
        clearDescription ??
        (description == unsetCopyWithValue
            ? this.clearDescription
            : description == null),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateServiceAccountRequest &&
          description == other.description &&
          clearDescription == other.clearDescription;

  @override
  int get hashCode => Object.hash(description, clearDescription);

  @override
  String toString() =>
      'UpdateServiceAccountRequest(description: $description, '
      'clearDescription: $clearDescription)';
}
