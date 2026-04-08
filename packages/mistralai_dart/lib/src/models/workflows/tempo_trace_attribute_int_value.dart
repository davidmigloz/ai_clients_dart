import 'package:meta/meta.dart';

/// An integer value for a trace attribute.
@immutable
class TempoTraceAttributeIntValue {
  /// The integer value as a string.
  final String intValue;

  /// Creates a [TempoTraceAttributeIntValue].
  const TempoTraceAttributeIntValue({required this.intValue});

  /// Creates a [TempoTraceAttributeIntValue] from JSON.
  factory TempoTraceAttributeIntValue.fromJson(Map<String, dynamic> json) =>
      TempoTraceAttributeIntValue(intValue: json['intValue'] as String? ?? '');

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'intValue': intValue};

  /// Creates a copy with replaced values.
  TempoTraceAttributeIntValue copyWith({String? intValue}) {
    return TempoTraceAttributeIntValue(intValue: intValue ?? this.intValue);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TempoTraceAttributeIntValue) return false;
    if (runtimeType != other.runtimeType) return false;
    return intValue == other.intValue;
  }

  @override
  int get hashCode => intValue.hashCode;

  @override
  String toString() => 'TempoTraceAttributeIntValue(intValue: $intValue)';
}
