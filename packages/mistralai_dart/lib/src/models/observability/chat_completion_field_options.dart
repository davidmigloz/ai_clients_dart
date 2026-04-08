import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Available options for a chat completion field.
@immutable
class ChatCompletionFieldOptions {
  /// The available options (strings or booleans).
  final List<Object?>? options;

  /// Creates a [ChatCompletionFieldOptions].
  ChatCompletionFieldOptions({List<Object?>? options})
    : options = options != null ? List.unmodifiable(options) : null;

  /// Creates a [ChatCompletionFieldOptions] from JSON.
  factory ChatCompletionFieldOptions.fromJson(Map<String, dynamic> json) =>
      ChatCompletionFieldOptions(
        options: (json['options'] as List?)?.cast<Object?>(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (options != null) 'options': options};

  /// Creates a copy with replaced values.
  ChatCompletionFieldOptions copyWith({Object? options = unsetCopyWithValue}) {
    return ChatCompletionFieldOptions(
      options: options == unsetCopyWithValue
          ? this.options
          : options as List<Object?>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatCompletionFieldOptions) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(options, other.options);
  }

  @override
  int get hashCode => listHash(options);

  @override
  String toString() =>
      'ChatCompletionFieldOptions(options: ${options?.length ?? 0} options)';
}
