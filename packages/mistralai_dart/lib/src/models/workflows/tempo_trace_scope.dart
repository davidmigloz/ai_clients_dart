import 'package:meta/meta.dart';

/// A trace scope.
@immutable
class TempoTraceScope {
  /// The scope name.
  final String name;

  /// Creates a [TempoTraceScope].
  const TempoTraceScope({required this.name});

  /// Creates a [TempoTraceScope] from JSON.
  factory TempoTraceScope.fromJson(Map<String, dynamic> json) =>
      TempoTraceScope(name: json['name'] as String? ?? '');

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'name': name};

  /// Creates a copy with replaced values.
  TempoTraceScope copyWith({String? name}) {
    return TempoTraceScope(name: name ?? this.name);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TempoTraceScope) return false;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'TempoTraceScope(name: $name)';
}
