import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Available options for a span field.
@immutable
class GetSpanFieldOptions {
  /// The available option values, or `null` if the field has no enumerable
  /// options.
  final List<String>? options;

  /// Creates a [GetSpanFieldOptions].
  GetSpanFieldOptions({List<String>? options})
    : options = options != null ? List.unmodifiable(options) : null;

  /// Creates a [GetSpanFieldOptions] from JSON.
  factory GetSpanFieldOptions.fromJson(Map<String, dynamic> json) =>
      GetSpanFieldOptions(options: (json['options'] as List?)?.cast<String>());

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (options != null) 'options': options};

  /// Creates a copy with replaced values.
  GetSpanFieldOptions copyWith({Object? options = unsetCopyWithValue}) =>
      GetSpanFieldOptions(
        options: options == unsetCopyWithValue
            ? this.options
            : options as List<String>?,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetSpanFieldOptions) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(options, other.options);
  }

  @override
  int get hashCode => listHash(options);

  @override
  String toString() =>
      'GetSpanFieldOptions(options: ${options?.length ?? 0} options)';
}
