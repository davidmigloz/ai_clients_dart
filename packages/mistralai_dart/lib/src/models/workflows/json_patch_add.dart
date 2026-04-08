import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A JSON patch add operation.
@immutable
class JSONPatchAdd {
  /// The operation type.
  final String op;

  /// The JSON path.
  final String path;

  /// The value to add.
  final Object value;

  /// Creates a [JSONPatchAdd].
  const JSONPatchAdd({
    this.op = 'add',
    required this.path,
    required this.value,
  });

  /// Creates a [JSONPatchAdd] from JSON.
  factory JSONPatchAdd.fromJson(Map<String, dynamic> json) => JSONPatchAdd(
    op: json['op'] as String? ?? 'add',
    path: json['path'] as String? ?? '',
    value: json['value'] ?? const <String, dynamic>{},
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'op': op, 'path': path, 'value': value};

  /// Creates a copy with replaced values.
  JSONPatchAdd copyWith({String? op, String? path, Object? value}) {
    return JSONPatchAdd(
      op: op ?? this.op,
      path: path ?? this.path,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JSONPatchAdd) return false;
    if (runtimeType != other.runtimeType) return false;
    return op == other.op &&
        path == other.path &&
        valuesDeepEqual(value, other.value);
  }

  @override
  int get hashCode => Object.hash(op, path, valueDeepHashCode(value));

  @override
  String toString() => 'JSONPatchAdd(op: $op, path: $path, value: $value)';
}
