import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A JSON patch payload response.
@immutable
class JSONPatchPayloadResponse {
  /// The payload type.
  final String type;

  /// The list of JSON patch operations.
  final List<Map<String, dynamic>> value;

  /// Creates a [JSONPatchPayloadResponse].
  JSONPatchPayloadResponse({
    this.type = 'json_patch',
    required List<Map<String, dynamic>> value,
  }) : value = List.unmodifiable(value);

  /// Creates a [JSONPatchPayloadResponse] from JSON.
  factory JSONPatchPayloadResponse.fromJson(Map<String, dynamic> json) =>
      JSONPatchPayloadResponse(
        type: json['type'] as String? ?? 'json_patch',
        value: (json['value'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'value': value};

  /// Creates a copy with replaced values.
  JSONPatchPayloadResponse copyWith({
    String? type,
    List<Map<String, dynamic>>? value,
  }) {
    return JSONPatchPayloadResponse(
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JSONPatchPayloadResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listOfMapsDeepEqual(value, other.value)) return false;
    return type == other.type;
  }

  @override
  int get hashCode => Object.hash(type, listOfMapsHashCode(value));

  @override
  String toString() =>
      'JSONPatchPayloadResponse(type: $type, value: ${value.length})';
}
