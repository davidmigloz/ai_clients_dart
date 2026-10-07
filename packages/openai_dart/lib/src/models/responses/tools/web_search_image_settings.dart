import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/json_helpers.dart';

/// Guide-defined image-result settings for GA web search.
///
/// Members are optional. No maximum or default result count is imposed by
/// this client; a supplied count must be positive.
@immutable
class WebSearchImageSettings {
  /// Creates image settings with a positive optional result count.
  WebSearchImageSettings({this.maxResults, this.caption}) {
    if (maxResults != null && maxResults! <= 0) {
      throw ArgumentError.value(maxResults, 'maxResults', 'must be positive');
    }
  }

  /// Parses optional nonnull members with contextual errors.
  factory WebSearchImageSettings.fromJson(Map<String, dynamic> json) {
    final maxResults = optionalJsonInt(
      json,
      'max_results',
      'WebSearchImageSettings',
    );
    if (maxResults != null && maxResults <= 0) {
      throw const FormatException(
        'WebSearchImageSettings.max_results: expected a positive integer',
      );
    }
    return WebSearchImageSettings(
      maxResults: maxResults,
      caption: optionalJsonBool(json, 'caption', 'WebSearchImageSettings'),
    );
  }

  /// Maximum number of returned image results, if specified.
  final int? maxResults;

  /// Whether to include captions for image results.
  final bool? caption;

  /// Converts to JSON, preserving explicit false and omitting unset members.
  Map<String, dynamic> toJson() => {
    if (maxResults != null) 'max_results': maxResults,
    if (caption != null) 'caption': caption,
  };

  /// Creates a copy, with explicit null clearing an optional member.
  WebSearchImageSettings copyWith({
    Object? maxResults = unsetCopyWithValue,
    Object? caption = unsetCopyWithValue,
  }) => WebSearchImageSettings(
    maxResults: identical(maxResults, unsetCopyWithValue)
        ? this.maxResults
        : maxResults as int?,
    caption: identical(caption, unsetCopyWithValue)
        ? this.caption
        : caption as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchImageSettings &&
          runtimeType == other.runtimeType &&
          maxResults == other.maxResults &&
          caption == other.caption;

  @override
  int get hashCode => Object.hash(maxResults, caption);

  @override
  String toString() =>
      'WebSearchImageSettings(maxResults: $maxResults, caption: $caption)';
}
