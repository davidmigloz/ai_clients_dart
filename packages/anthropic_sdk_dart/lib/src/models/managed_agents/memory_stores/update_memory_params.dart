import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// Private sentinel to distinguish "not provided" from explicit `null`.
const Object _notSet = Object();

/// Optional precondition for updating a memory.
///
/// Variants:
/// - [ContentSha256Precondition] — fail if the current content does not match
///   the given SHA-256 (type: `content_sha256`)
/// - [UnknownMemoryPrecondition] — Unrecognized type (preserves raw JSON)
sealed class MemoryPrecondition {
  const MemoryPrecondition();

  /// Creates a [MemoryPrecondition] from JSON.
  factory MemoryPrecondition.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'content_sha256' => ContentSha256Precondition.fromJson(json),
      _ => UnknownMemoryPrecondition.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Precondition that fails if the memory's current content SHA-256 does not
/// match.
@immutable
class ContentSha256Precondition extends MemoryPrecondition {
  /// The type discriminator. Always `content_sha256`.
  final String type;

  /// The expected content SHA-256, hex-encoded.
  final String contentSha256;

  /// Creates a [ContentSha256Precondition].
  const ContentSha256Precondition({
    this.type = 'content_sha256',
    required this.contentSha256,
  });

  /// Creates a [ContentSha256Precondition] from JSON.
  factory ContentSha256Precondition.fromJson(Map<String, dynamic> json) {
    return ContentSha256Precondition(
      type: json['type'] as String? ?? 'content_sha256',
      contentSha256: json['content_sha256'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'content_sha256': contentSha256,
  };

  /// Creates a copy with replaced values.
  ContentSha256Precondition copyWith({String? type, String? contentSha256}) {
    return ContentSha256Precondition(
      type: type ?? this.type,
      contentSha256: contentSha256 ?? this.contentSha256,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentSha256Precondition &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          contentSha256 == other.contentSha256;

  @override
  int get hashCode => Object.hash(type, contentSha256);

  @override
  String toString() =>
      'ContentSha256Precondition(type: $type, contentSha256: $contentSha256)';
}

/// Unrecognized [MemoryPrecondition] — preserves raw JSON for forward
/// compatibility.
@immutable
class UnknownMemoryPrecondition extends MemoryPrecondition {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownMemoryPrecondition].
  const UnknownMemoryPrecondition({required this.rawJson});

  /// Creates an [UnknownMemoryPrecondition] from JSON.
  factory UnknownMemoryPrecondition.fromJson(Map<String, dynamic> json) {
    return UnknownMemoryPrecondition(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownMemoryPrecondition &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownMemoryPrecondition(rawJson: $rawJson)';
}

/// Request parameters for updating a [Memory].
///
/// Omit a field to preserve its current value on the server.
/// Pass `null` explicitly to clear a clearable field.
@immutable
class UpdateMemoryParams {
  /// New memory path within the store, 2–1024 characters.
  String? get path => _path == _notSet ? null : _path as String?;
  final Object? _path;

  /// New content. Pass `null` to clear; omit to preserve.
  String? get content => _content == _notSet ? null : _content as String?;
  final Object? _content;

  /// Optional precondition that the server validates before applying the
  /// update.
  final MemoryPrecondition? precondition;

  /// Creates an [UpdateMemoryParams].
  ///
  /// Omit a field to preserve its current value on the server.
  /// Pass `null` explicitly to clear a clearable field.
  const UpdateMemoryParams({
    Object? path = _notSet,
    Object? content = _notSet,
    this.precondition,
  }) : _path = path,
       _content = content;

  /// Creates an [UpdateMemoryParams] from JSON.
  factory UpdateMemoryParams.fromJson(Map<String, dynamic> json) {
    return UpdateMemoryParams(
      path: json.containsKey('path') ? json['path'] as String? : _notSet,
      content: json.containsKey('content')
          ? json['content'] as String?
          : _notSet,
      precondition: json['precondition'] != null
          ? MemoryPrecondition.fromJson(
              json['precondition'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  ///
  /// Fields that were not set are omitted. Fields explicitly set to `null`
  /// are emitted as `null`.
  Map<String, dynamic> toJson() => {
    if (_path != _notSet) 'path': _path,
    if (_content != _notSet) 'content': _content,
    if (precondition != null) 'precondition': precondition!.toJson(),
  };

  /// Creates a copy with replaced values.
  UpdateMemoryParams copyWith({
    Object? path = unsetCopyWithValue,
    Object? content = unsetCopyWithValue,
    Object? precondition = unsetCopyWithValue,
  }) {
    return UpdateMemoryParams(
      path: path == unsetCopyWithValue ? _path : path,
      content: content == unsetCopyWithValue ? _content : content,
      precondition: precondition == unsetCopyWithValue
          ? this.precondition
          : precondition as MemoryPrecondition?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateMemoryParams &&
          runtimeType == other.runtimeType &&
          _path == other._path &&
          _content == other._content &&
          precondition == other.precondition;

  @override
  int get hashCode => Object.hash(_path, _content, precondition);

  @override
  String toString() =>
      'UpdateMemoryParams('
      'path: $path, '
      'content: ${content == null ? null : '${content!.length} chars'}, '
      'precondition: $precondition)';
}
