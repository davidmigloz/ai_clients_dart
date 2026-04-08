import 'package:meta/meta.dart';

/// A string value for a trace attribute.
@immutable
class TempoTraceAttributeStringValue {
  /// The string value.
  final String stringValue;

  /// Creates a [TempoTraceAttributeStringValue].
  const TempoTraceAttributeStringValue({required this.stringValue});

  /// Creates a [TempoTraceAttributeStringValue] from JSON.
  factory TempoTraceAttributeStringValue.fromJson(Map<String, dynamic> json) =>
      TempoTraceAttributeStringValue(
        stringValue: json['stringValue'] as String? ?? '',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'stringValue': stringValue};

  /// Creates a copy with replaced values.
  TempoTraceAttributeStringValue copyWith({String? stringValue}) {
    return TempoTraceAttributeStringValue(
      stringValue: stringValue ?? this.stringValue,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TempoTraceAttributeStringValue) return false;
    if (runtimeType != other.runtimeType) return false;
    return stringValue == other.stringValue;
  }

  @override
  int get hashCode => stringValue.hashCode;

  @override
  String toString() =>
      'TempoTraceAttributeStringValue(stringValue: $stringValue)';
}
