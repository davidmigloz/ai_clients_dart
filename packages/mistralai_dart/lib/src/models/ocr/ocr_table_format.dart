/// Format for extracted tables in OCR output.
enum OcrTableFormat {
  /// Markdown table format.
  markdown('markdown'),

  /// HTML table format.
  html('html');

  const OcrTableFormat(this.value);

  /// The string value used in the API.
  final String value;

  /// Creates from a JSON string value.
  ///
  /// Returns `null` if [value] is null or unrecognized.
  static OcrTableFormat? fromString(String? value) {
    if (value == null) return null;
    return OcrTableFormat.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OcrTableFormat.markdown,
    );
  }
}
