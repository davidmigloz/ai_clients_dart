import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';

/// Request parameters for creating a [Memory].
@immutable
class CreateMemoryParams {
  /// Memory path within the store, 2–1024 characters.
  final String path;

  /// Memory content. May be `null` to create an empty marker entry.
  final String? content;

  /// Creates a [CreateMemoryParams].
  const CreateMemoryParams({required this.path, required this.content});

  /// Creates a [CreateMemoryParams] from JSON.
  factory CreateMemoryParams.fromJson(Map<String, dynamic> json) {
    return CreateMemoryParams(
      path: json['path'] as String,
      content: json['content'] as String?,
    );
  }

  /// Converts to JSON.
  ///
  /// `content` is required by the API spec — both `path` and `content` are
  /// always emitted, with `content` allowed to be `null`.
  Map<String, dynamic> toJson() => {'path': path, 'content': content};

  /// Creates a copy with replaced values.
  CreateMemoryParams copyWith({
    String? path,
    Object? content = unsetCopyWithValue,
  }) {
    return CreateMemoryParams(
      path: path ?? this.path,
      content: identical(content, unsetCopyWithValue)
          ? this.content
          : content as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateMemoryParams &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          content == other.content;

  @override
  int get hashCode => Object.hash(path, content);

  @override
  String toString() =>
      'CreateMemoryParams('
      'path: $path, '
      'content: ${content == null ? null : '${content!.length} chars'})';
}
