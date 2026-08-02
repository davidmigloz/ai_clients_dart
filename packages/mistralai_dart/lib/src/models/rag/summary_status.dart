/// The status of a RAG search index schema/document summary.
enum SummaryStatus {
  /// The summary was written by hand.
  handwritten('handwritten'),

  /// The summary was generated automatically.
  generated('generated'),

  /// The summary was generated automatically and then confirmed by a human.
  generatedConfirmed('generated_confirmed'),

  /// Unknown status (forward-compatible fallback).
  unknown('unknown');

  const SummaryStatus(this.value);

  /// The string value of this status.
  final String value;

  /// Converts to a JSON value.
  String toJson() => value;

  /// Creates a [SummaryStatus] from a JSON value.
  static SummaryStatus fromJson(String? value) => fromString(value);

  /// Creates a [SummaryStatus] from a string value.
  static SummaryStatus fromString(String? value) {
    if (value == null) return SummaryStatus.unknown;
    return SummaryStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SummaryStatus.unknown,
    );
  }
}
