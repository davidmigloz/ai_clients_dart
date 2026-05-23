import '../copy_with_sentinel.dart';

/// A review snippet from an interaction (uses snake_case JSON keys).
///
/// Named `InteractionReviewSnippet` to avoid collision with the
/// `ReviewSnippet` class in the metadata models (which uses camelCase keys).
class InteractionReviewSnippet {
  /// The ID of the review.
  final String? reviewId;

  /// The title of the review.
  final String? title;

  /// The URL of the review.
  final String? url;

  /// Creates an [InteractionReviewSnippet] instance.
  const InteractionReviewSnippet({this.reviewId, this.title, this.url});

  /// Creates an [InteractionReviewSnippet] from JSON.
  factory InteractionReviewSnippet.fromJson(Map<String, dynamic> json) =>
      InteractionReviewSnippet(
        reviewId: json['review_id'] as String?,
        title: json['title'] as String?,
        url: json['url'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (reviewId != null) 'review_id': reviewId,
    if (title != null) 'title': title,
    if (url != null) 'url': url,
  };

  /// Creates a copy with replaced values.
  InteractionReviewSnippet copyWith({
    Object? reviewId = unsetCopyWithValue,
    Object? title = unsetCopyWithValue,
    Object? url = unsetCopyWithValue,
  }) {
    return InteractionReviewSnippet(
      reviewId: reviewId == unsetCopyWithValue
          ? this.reviewId
          : reviewId as String?,
      title: title == unsetCopyWithValue ? this.title : title as String?,
      url: url == unsetCopyWithValue ? this.url : url as String?,
    );
  }
}
