import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Content of a single asset attached to a [SkillDefinition].
///
/// The API models this as a `oneOf` between base64-encoded binary content
/// ([rawContent]) and plain-text content ([textContent]); exactly one of the
/// two must be set. Use the [SkillAssetContent.raw] and
/// [SkillAssetContent.text] factories to construct instances unambiguously
/// (they are safe by construction and support `const`). The unnamed
/// constructor validates at runtime instead — asserts are stripped in
/// release builds, so it throws [ArgumentError] rather than relying on
/// `assert`.
@immutable
class SkillAssetContent {
  /// Base64-encoded binary content.
  final String? rawContent;

  /// Plain-text content.
  final String? textContent;

  /// Whether this asset is executable.
  final bool? isExecutable;

  /// Creates a [SkillAssetContent], validating that exactly one of
  /// [rawContent] or [textContent] is non-null.
  ///
  /// Throws an [ArgumentError] otherwise. Prefer [SkillAssetContent.raw] or
  /// [SkillAssetContent.text] when the content kind is known statically —
  /// they're `const`-constructible and can't produce an invalid state.
  factory SkillAssetContent({
    String? rawContent,
    String? textContent,
    bool? isExecutable,
  }) {
    if ((rawContent != null) == (textContent != null)) {
      throw ArgumentError(
        'Exactly one of rawContent or textContent must be set.',
      );
    }
    return SkillAssetContent._(
      rawContent: rawContent,
      textContent: textContent,
      isExecutable: isExecutable,
    );
  }

  const SkillAssetContent._({
    this.rawContent,
    this.textContent,
    this.isExecutable,
  });

  /// Creates a [SkillAssetContent] carrying base64-encoded binary content.
  const factory SkillAssetContent.raw({
    required String rawContent,
    bool? isExecutable,
  }) = SkillAssetContent._;

  /// Creates a [SkillAssetContent] carrying plain-text content.
  const factory SkillAssetContent.text({
    required String textContent,
    bool? isExecutable,
  }) = SkillAssetContent._;

  /// Creates a [SkillAssetContent] from JSON.
  ///
  /// Throws a [FormatException] unless exactly one of `rawContent` or
  /// `textContent` is present in [json] with a non-null `String` value.
  factory SkillAssetContent.fromJson(Map<String, dynamic> json) {
    final hasRaw = json.containsKey('rawContent');
    final hasText = json.containsKey('textContent');
    if (hasRaw == hasText) {
      throw FormatException(
        'SkillAssetContent: expected exactly one of "rawContent" or '
        '"textContent", got ${hasRaw ? 'both' : 'neither'}: $json',
      );
    }
    final key = hasRaw ? 'rawContent' : 'textContent';
    final value = json[key];
    if (value is! String) {
      throw FormatException(
        'SkillAssetContent: "$key" must be a non-null String, got '
        '${value.runtimeType}: $json',
      );
    }
    return hasRaw
        ? SkillAssetContent.raw(
            rawContent: value,
            isExecutable: json['isExecutable'] as bool?,
          )
        : SkillAssetContent.text(
            textContent: value,
            isExecutable: json['isExecutable'] as bool?,
          );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (rawContent != null) 'rawContent': rawContent,
    if (textContent != null) 'textContent': textContent,
    if (isExecutable != null) 'isExecutable': isExecutable,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Routes through the validating unnamed constructor, so the result can
  /// never have zero or two content fields set — it throws [ArgumentError]
  /// instead. In particular, switching content kind requires explicitly
  /// clearing the other field in the same call, e.g. going from a raw asset
  /// to a text one needs `copyWith(textContent: 'new text', rawContent:
  /// null)`; passing only `textContent` while the old `rawContent` is still
  /// set leaves both non-null and throws.
  SkillAssetContent copyWith({
    Object? rawContent = unsetCopyWithValue,
    Object? textContent = unsetCopyWithValue,
    Object? isExecutable = unsetCopyWithValue,
  }) => SkillAssetContent(
    rawContent: rawContent == unsetCopyWithValue
        ? this.rawContent
        : rawContent as String?,
    textContent: textContent == unsetCopyWithValue
        ? this.textContent
        : textContent as String?,
    isExecutable: isExecutable == unsetCopyWithValue
        ? this.isExecutable
        : isExecutable as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillAssetContent &&
          runtimeType == other.runtimeType &&
          rawContent == other.rawContent &&
          textContent == other.textContent &&
          isExecutable == other.isExecutable;

  @override
  int get hashCode => Object.hash(rawContent, textContent, isExecutable);

  @override
  String toString() =>
      'SkillAssetContent(rawContent: ${rawContent != null}, '
      'textContent: $textContent, isExecutable: $isExecutable)';
}
