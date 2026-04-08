import 'package:meta/meta.dart';

/// A JSON patch append operation.
@immutable
class JSONPatchAppend {
  /// The operation type.
  final String op;

  /// The JSON path.
  final String path;

  /// The value to append.
  final String value;

  /// Creates a [JSONPatchAppend].
  const JSONPatchAppend({
    this.op = 'append',
    required this.path,
    required this.value,
  });

  /// Creates a [JSONPatchAppend] from JSON.
  factory JSONPatchAppend.fromJson(Map<String, dynamic> json) =>
      JSONPatchAppend(
        op: json['op'] as String? ?? 'append',
        path: json['path'] as String? ?? '',
        value: json['value'] as String? ?? '',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'op': op, 'path': path, 'value': value};

  /// Creates a copy with replaced values.
  JSONPatchAppend copyWith({String? op, String? path, String? value}) {
    return JSONPatchAppend(
      op: op ?? this.op,
      path: path ?? this.path,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JSONPatchAppend) return false;
    if (runtimeType != other.runtimeType) return false;
    return op == other.op && path == other.path && value == other.value;
  }

  @override
  int get hashCode => Object.hash(op, path, value);

  @override
  String toString() => 'JSONPatchAppend(op: $op, path: $path, value: $value)';
}
