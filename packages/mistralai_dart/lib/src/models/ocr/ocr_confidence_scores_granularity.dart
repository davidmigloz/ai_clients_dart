/// Granularity level for OCR confidence scores.
///
/// Controls the detail level of confidence scores returned by the OCR endpoint.
enum OcrConfidenceScoresGranularity {
  /// Aggregate statistics (average and minimum) per page.
  page('page'),

  /// Per-word scores on each page and table, in addition to page aggregates.
  word('word');

  const OcrConfidenceScoresGranularity(this.value);

  /// The string value used in the API.
  final String value;

  /// Creates from a JSON string value.
  ///
  /// Returns `null` if [value] is null or unrecognized.
  static OcrConfidenceScoresGranularity? fromString(String? value) {
    if (value == null) return null;
    for (final e in OcrConfidenceScoresGranularity.values) {
      if (e.value == value) return e;
    }
    return null;
  }
}
