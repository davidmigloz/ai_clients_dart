/// Granularity of confidence scores returned by the OCR API.
///
/// Used with `OcrRequest.confidenceScoresGranularity` to opt into
/// confidence score reporting on the response.
///
/// Defaults (when the field is omitted) to no confidence scores returned —
/// keeps payload small.
enum OcrConfidenceScoresGranularity {
  /// Per-word confidence scores (also includes page aggregates).
  word('word'),

  /// Page-level aggregate confidence scores only.
  page('page'),

  /// Unknown granularity (forward compatibility).
  unknown('unknown');

  const OcrConfidenceScoresGranularity(this.value);

  /// The string value used in the API.
  final String value;

  /// Creates from a string value.
  ///
  /// Returns null if [value] is null.
  /// Returns [unknown] if [value] does not match any known value.
  static OcrConfidenceScoresGranularity? fromString(String? value) =>
      switch (value) {
        'word' => word,
        'page' => page,
        null => null,
        _ => unknown,
      };
}
