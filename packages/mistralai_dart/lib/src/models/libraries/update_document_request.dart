import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request to update a library document.
@immutable
class UpdateDocumentRequest {
  /// The new name for the document.
  final String name;

  /// Arbitrary attributes associated with the document.
  final Map<String, dynamic>? attributes;

  /// When the document expires (ISO 8601 date-time).
  final String? expiresAt;

  /// Creates an [UpdateDocumentRequest].
  const UpdateDocumentRequest({
    required this.name,
    this.attributes,
    this.expiresAt,
  });

  /// Creates an [UpdateDocumentRequest] from JSON.
  factory UpdateDocumentRequest.fromJson(Map<String, dynamic> json) =>
      UpdateDocumentRequest(
        name: json['name'] as String? ?? '',
        attributes: json['attributes'] as Map<String, dynamic>?,
        expiresAt: json['expires_at'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (attributes != null) 'attributes': attributes,
    if (expiresAt != null) 'expires_at': expiresAt,
  };

  /// Creates a copy with replaced values.
  UpdateDocumentRequest copyWith({
    String? name,
    Object? attributes = unsetCopyWithValue,
    Object? expiresAt = unsetCopyWithValue,
  }) {
    return UpdateDocumentRequest(
      name: name ?? this.name,
      attributes: attributes == unsetCopyWithValue
          ? this.attributes
          : attributes as Map<String, dynamic>?,
      expiresAt: expiresAt == unsetCopyWithValue
          ? this.expiresAt
          : expiresAt as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UpdateDocumentRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name &&
        mapsDeepEqual(attributes, other.attributes) &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode => Object.hash(name, mapDeepHashCode(attributes), expiresAt);

  @override
  String toString() =>
      'UpdateDocumentRequest('
      'name: $name, '
      'attributes: $attributes, '
      'expiresAt: $expiresAt'
      ')';
}
