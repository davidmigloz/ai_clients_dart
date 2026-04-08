import 'package:meta/meta.dart';

/// A boolean value for a trace attribute.
@immutable
class TempoTraceAttributeBoolValue {
  /// The boolean value.
  final bool boolValue;

  /// Creates a [TempoTraceAttributeBoolValue].
  const TempoTraceAttributeBoolValue({required this.boolValue});

  /// Creates a [TempoTraceAttributeBoolValue] from JSON.
  factory TempoTraceAttributeBoolValue.fromJson(Map<String, dynamic> json) =>
      TempoTraceAttributeBoolValue(
        boolValue: json['boolValue'] as bool? ?? false,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'boolValue': boolValue};

  /// Creates a copy with replaced values.
  TempoTraceAttributeBoolValue copyWith({bool? boolValue}) {
    return TempoTraceAttributeBoolValue(boolValue: boolValue ?? this.boolValue);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TempoTraceAttributeBoolValue) return false;
    if (runtimeType != other.runtimeType) return false;
    return boolValue == other.boolValue;
  }

  @override
  int get hashCode => boolValue.hashCode;

  @override
  String toString() => 'TempoTraceAttributeBoolValue(boolValue: $boolValue)';
}
