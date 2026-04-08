import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A JSON patch remove operation.
@immutable
class JSONPatchRemove {
  /// The operation type.
  final String op;

  /// The JSON path.
  final String path;

  /// The value.
  final Object value;

  /// Creates a [JSONPatchRemove].
  const JSONPatchRemove({
    this.op = 'remove',
    required this.path,
    required this.value,
  });

  /// Creates a [JSONPatchRemove] from JSON.
  factory JSONPatchRemove.fromJson(Map<String, dynamic> json) =>
      JSONPatchRemove(
        op: json['op'] as String? ?? 'remove',
        path: json['path'] as String? ?? '',
        value: json['value'] ?? const <String, dynamic>{},
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'op': op, 'path': path, 'value': value};

  /// Creates a copy with replaced values.
  JSONPatchRemove copyWith({String? op, String? path, Object? value}) {
    return JSONPatchRemove(
      op: op ?? this.op,
      path: path ?? this.path,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JSONPatchRemove) return false;
    if (runtimeType != other.runtimeType) return false;
    return op == other.op &&
        path == other.path &&
        valuesDeepEqual(value, other.value);
  }

  @override
  int get hashCode => Object.hash(op, path, valueDeepHashCode(value));

  @override
  String toString() => 'JSONPatchRemove(op: $op, path: $path, value: $value)';
}
