import 'package:meta/meta.dart';

/// A JSON payload response.
@immutable
class JSONPayloadResponse {
  /// The payload type.
  final String type;

  /// The JSON value.
  final Object value;

  /// Creates a [JSONPayloadResponse].
  const JSONPayloadResponse({this.type = 'json', required this.value});

  /// Creates a [JSONPayloadResponse] from JSON.
  factory JSONPayloadResponse.fromJson(Map<String, dynamic> json) =>
      JSONPayloadResponse(
        type: json['type'] as String? ?? 'json',
        value: json['value'] ?? Object(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'value': value};

  /// Creates a copy with replaced values.
  JSONPayloadResponse copyWith({String? type, Object? value}) {
    return JSONPayloadResponse(
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JSONPayloadResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return type == other.type && value == other.value;
  }

  @override
  int get hashCode => Object.hash(type, value);

  @override
  String toString() => 'JSONPayloadResponse(type: $type, value: $value)';
}
