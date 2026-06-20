import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request to update a library document (PATCH semantics).
///
/// All fields are optional; omitted fields are left unchanged. [name] is sent
/// only when non-null. [attributes] and [expiresAt] are tri-state: provide a
/// value to set it, or set the matching `clear*` flag to emit an explicit
/// `null` that clears it server-side; otherwise the field is omitted.
@immutable
class UpdateDocumentRequest {
  /// The new name for the document, if changing it.
  final String? name;

  /// Arbitrary attributes associated with the document, if setting them.
  final Map<String, dynamic>? attributes;

  /// When true, `toJson` emits `"attributes": null` to clear the attributes.
  final bool clearAttributes;

  /// When the document expires (ISO 8601 date-time), if setting it.
  final String? expiresAt;

  /// When true, `toJson` emits `"expires_at": null` to clear the expiration.
  final bool clearExpiresAt;

  /// Creates an [UpdateDocumentRequest].
  const UpdateDocumentRequest({
    this.name,
    this.attributes,
    this.clearAttributes = false,
    this.expiresAt,
    this.clearExpiresAt = false,
  });

  /// Creates an [UpdateDocumentRequest] from JSON.
  factory UpdateDocumentRequest.fromJson(Map<String, dynamic> json) =>
      UpdateDocumentRequest(
        name: json['name'] as String?,
        attributes: json['attributes'] as Map<String, dynamic>?,
        clearAttributes:
            json.containsKey('attributes') && json['attributes'] == null,
        expiresAt: json['expires_at'] as String?,
        clearExpiresAt:
            json.containsKey('expires_at') && json['expires_at'] == null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (attributes != null)
      'attributes': attributes
    else if (clearAttributes)
      'attributes': null,
    if (expiresAt != null)
      'expires_at': expiresAt
    else if (clearExpiresAt)
      'expires_at': null,
  };

  /// Creates a copy with replaced values.
  UpdateDocumentRequest copyWith({
    Object? name = unsetCopyWithValue,
    Object? attributes = unsetCopyWithValue,
    bool? clearAttributes,
    Object? expiresAt = unsetCopyWithValue,
    bool? clearExpiresAt,
  }) {
    return UpdateDocumentRequest(
      name: name == unsetCopyWithValue ? this.name : name as String?,
      attributes: attributes == unsetCopyWithValue
          ? this.attributes
          : attributes as Map<String, dynamic>?,
      clearAttributes: clearAttributes ?? this.clearAttributes,
      expiresAt: expiresAt == unsetCopyWithValue
          ? this.expiresAt
          : expiresAt as String?,
      clearExpiresAt: clearExpiresAt ?? this.clearExpiresAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UpdateDocumentRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name &&
        mapsDeepEqual(attributes, other.attributes) &&
        clearAttributes == other.clearAttributes &&
        expiresAt == other.expiresAt &&
        clearExpiresAt == other.clearExpiresAt;
  }

  @override
  int get hashCode => Object.hash(
    name,
    mapDeepHashCode(attributes),
    clearAttributes,
    expiresAt,
    clearExpiresAt,
  );

  @override
  String toString() =>
      'UpdateDocumentRequest('
      'name: $name, '
      'attributes: $attributes, '
      'clearAttributes: $clearAttributes, '
      'expiresAt: $expiresAt, '
      'clearExpiresAt: $clearExpiresAt'
      ')';
}
