import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Content of a single asset attached to a [SkillDefinition].
///
/// The API models this as a `oneOf` between base64-encoded binary content
/// ([rawContent]) and plain-text content ([textContent]); exactly one of the
/// two must be set. Use the [SkillAssetContent.raw] and
/// [SkillAssetContent.text] factories to construct instances unambiguously.
@immutable
class SkillAssetContent {
  /// Base64-encoded binary content.
  final String? rawContent;

  /// Plain-text content.
  final String? textContent;

  /// Whether this asset is executable.
  final bool? isExecutable;

  /// Creates a [SkillAssetContent].
  ///
  /// Asserts that exactly one of [rawContent] or [textContent] is non-null.
  const SkillAssetContent({
    this.rawContent,
    this.textContent,
    this.isExecutable,
  }) : assert(
         (rawContent != null) != (textContent != null),
         'Exactly one of rawContent or textContent must be set.',
       );

  /// Creates a [SkillAssetContent] carrying base64-encoded binary content.
  const SkillAssetContent.raw({required String rawContent, bool? isExecutable})
    : this(rawContent: rawContent, isExecutable: isExecutable);

  /// Creates a [SkillAssetContent] carrying plain-text content.
  const SkillAssetContent.text({
    required String textContent,
    bool? isExecutable,
  }) : this(textContent: textContent, isExecutable: isExecutable);

  /// Creates a [SkillAssetContent] from JSON.
  ///
  /// Throws a [FormatException] unless exactly one of `rawContent` or
  /// `textContent` is present in [json].
  factory SkillAssetContent.fromJson(Map<String, dynamic> json) {
    final hasRaw = json.containsKey('rawContent');
    final hasText = json.containsKey('textContent');
    if (hasRaw == hasText) {
      throw FormatException(
        'SkillAssetContent: expected exactly one of "rawContent" or '
        '"textContent", got ${hasRaw ? 'both' : 'neither'}: $json',
      );
    }
    return SkillAssetContent(
      rawContent: json['rawContent'] as String?,
      textContent: json['textContent'] as String?,
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
  /// Pass `null` explicitly to clear nullable fields.
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
