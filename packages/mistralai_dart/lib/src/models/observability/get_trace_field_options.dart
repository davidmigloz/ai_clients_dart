import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Available options for a trace field.
@immutable
class GetTraceFieldOptions {
  /// The available option values, or `null` if the field has no enumerable
  /// options.
  final List<String>? options;

  /// Creates a [GetTraceFieldOptions].
  GetTraceFieldOptions({List<String>? options})
    : options = options != null ? List.unmodifiable(options) : null;

  /// Creates a [GetTraceFieldOptions] from JSON.
  factory GetTraceFieldOptions.fromJson(Map<String, dynamic> json) =>
      GetTraceFieldOptions(options: (json['options'] as List?)?.cast<String>());

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (options != null) 'options': options};

  /// Creates a copy with replaced values.
  GetTraceFieldOptions copyWith({Object? options = unsetCopyWithValue}) =>
      GetTraceFieldOptions(
        options: options == unsetCopyWithValue
            ? this.options
            : options as List<String>?,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetTraceFieldOptions) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(options, other.options);
  }

  @override
  int get hashCode => listHash(options);

  @override
  String toString() =>
      'GetTraceFieldOptions(options: ${options?.length ?? 0} options)';
}
