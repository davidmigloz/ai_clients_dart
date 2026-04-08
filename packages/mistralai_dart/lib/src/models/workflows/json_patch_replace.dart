import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A JSON patch replace operation.
@immutable
class JSONPatchReplace {
  /// The operation type.
  final String op;

  /// The JSON path.
  final String path;

  /// The value to replace with.
  final Object value;

  /// Creates a [JSONPatchReplace].
  const JSONPatchReplace({
    this.op = 'replace',
    required this.path,
    required this.value,
  });

  /// Creates a [JSONPatchReplace] from JSON.
  factory JSONPatchReplace.fromJson(Map<String, dynamic> json) =>
      JSONPatchReplace(
        op: json['op'] as String? ?? 'replace',
        path: json['path'] as String? ?? '',
        value: json['value'] ?? const <String, dynamic>{},
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'op': op, 'path': path, 'value': value};

  /// Creates a copy with replaced values.
  JSONPatchReplace copyWith({String? op, String? path, Object? value}) {
    return JSONPatchReplace(
      op: op ?? this.op,
      path: path ?? this.path,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JSONPatchReplace) return false;
    if (runtimeType != other.runtimeType) return false;
    return op == other.op &&
        path == other.path &&
        valuesDeepEqual(value, other.value);
  }

  @override
  int get hashCode => Object.hash(op, path, valueDeepHashCode(value));

  @override
  String toString() => 'JSONPatchReplace(op: $op, path: $path, value: $value)';
}
