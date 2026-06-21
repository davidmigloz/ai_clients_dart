import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Available options for a log field.
@immutable
class GetLogFieldOptions {
  /// The available option values, or `null` if the field has no enumerable
  /// options.
  final List<String>? options;

  /// Creates a [GetLogFieldOptions].
  GetLogFieldOptions({List<String>? options})
    : options = options != null ? List.unmodifiable(options) : null;

  /// Creates a [GetLogFieldOptions] from JSON.
  factory GetLogFieldOptions.fromJson(Map<String, dynamic> json) =>
      GetLogFieldOptions(options: (json['options'] as List?)?.cast<String>());

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (options != null) 'options': options};

  /// Creates a copy with replaced values.
  GetLogFieldOptions copyWith({Object? options = unsetCopyWithValue}) =>
      GetLogFieldOptions(
        options: options == unsetCopyWithValue
            ? this.options
            : options as List<String>?,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetLogFieldOptions) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(options, other.options);
  }

  @override
  int get hashCode => listHash(options);

  @override
  String toString() =>
      'GetLogFieldOptions(options: ${options?.length ?? 0} options)';
}
