import 'package:meta/meta.dart';

import 'container_json_helpers.dart';

/// Memory configured for an execution container.
///
/// The API currently supports [gb1], [gb4], [gb16], and [gb64]. The open
/// constructor preserves unfamiliar values returned by future API versions.
@immutable
class ContainerMemoryLimit {
  /// One gigabyte of memory.
  static const gb1 = ContainerMemoryLimit('1g');

  /// Four gigabytes of memory.
  static const gb4 = ContainerMemoryLimit('4g');

  /// Sixteen gigabytes of memory.
  static const gb16 = ContainerMemoryLimit('16g');

  /// Sixty-four gigabytes of memory.
  static const gb64 = ContainerMemoryLimit('64g');

  /// Creates a memory limit from its exact API string.
  const ContainerMemoryLimit(this.value);

  /// Creates a [ContainerMemoryLimit] from a JSON string.
  factory ContainerMemoryLimit.fromJson(Object? json) {
    final value = requireContainerString(json, 'ContainerMemoryLimit');
    return switch (value) {
      '1g' => gb1,
      '4g' => gb4,
      '16g' => gb16,
      '64g' => gb64,
      _ => ContainerMemoryLimit(value),
    };
  }

  /// The exact API string, such as `4g`.
  final String value;

  /// Converts to the JSON string.
  String toJson() => value;

  /// Creates a copy with a replaced wire value.
  ContainerMemoryLimit copyWith({String? value}) =>
      ContainerMemoryLimit(value ?? this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerMemoryLimit &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ContainerMemoryLimit($value)';
}
