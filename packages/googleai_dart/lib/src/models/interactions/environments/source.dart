part of 'environments.dart';

/// The kind of a [Source] mounted into an environment.
enum SourceType {
  /// A Google Cloud Storage source.
  gcs,

  /// Inline content provided directly in [Source.content].
  inline,

  /// A source code repository.
  repository,

  /// A skill from the skill registry.
  skillRegistry,
}

/// Converts a JSON string to a [SourceType], or `null` if unrecognized
/// (forward-compatible).
SourceType? sourceTypeFromString(String? value) {
  return switch (value) {
    'gcs' => SourceType.gcs,
    'inline' => SourceType.inline,
    'repository' => SourceType.repository,
    'skill_registry' => SourceType.skillRegistry,
    _ => null,
  };
}

/// Converts a [SourceType] to its JSON string.
String sourceTypeToString(SourceType value) {
  return switch (value) {
    SourceType.gcs => 'gcs',
    SourceType.inline => 'inline',
    SourceType.repository => 'repository',
    SourceType.skillRegistry => 'skill_registry',
  };
}

/// A source mounted into an environment's sandbox.
class Source {
  /// The kind of source.
  final SourceType? type;

  /// Path or URL for non-inline sources.
  final String? source;

  /// Mount destination in the environment.
  final String? target;

  /// Inline content text (for [SourceType.inline]).
  final String? content;

  /// Optional encoding for inline content (e.g. `base64`).
  final String? encoding;

  /// Creates a [Source].
  const Source({
    this.type,
    this.source,
    this.target,
    this.content,
    this.encoding,
  });

  /// Creates a [Source] from JSON.
  factory Source.fromJson(Map<String, dynamic> json) => Source(
    type: sourceTypeFromString(json['type'] as String?),
    source: json['source'] as String?,
    target: json['target'] as String?,
    content: json['content'] as String?,
    encoding: json['encoding'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (type != null) 'type': sourceTypeToString(type!),
    if (source != null) 'source': source,
    if (target != null) 'target': target,
    if (content != null) 'content': content,
    if (encoding != null) 'encoding': encoding,
  };

  /// Creates a copy with replaced values.
  Source copyWith({
    Object? type = unsetCopyWithValue,
    Object? source = unsetCopyWithValue,
    Object? target = unsetCopyWithValue,
    Object? content = unsetCopyWithValue,
    Object? encoding = unsetCopyWithValue,
  }) {
    return Source(
      type: type == unsetCopyWithValue ? this.type : type as SourceType?,
      source: source == unsetCopyWithValue ? this.source : source as String?,
      target: target == unsetCopyWithValue ? this.target : target as String?,
      content: content == unsetCopyWithValue
          ? this.content
          : content as String?,
      encoding: encoding == unsetCopyWithValue
          ? this.encoding
          : encoding as String?,
    );
  }
}
