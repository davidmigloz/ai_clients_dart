/// A language supported by RAG search index summary endpoints.
///
/// This is a path-parameter enum used by the search index summary field
/// endpoints; it is not backed by a named component schema in the API spec.
enum SummaryLanguage {
  /// English.
  en('en'),

  /// French.
  fr('fr'),

  /// Spanish.
  es('es'),

  /// German.
  de('de'),

  /// Italian.
  it('it'),

  /// Brazilian Portuguese.
  ptBr('pt_br'),

  /// Polish.
  pl('pl'),

  /// Arabic.
  ar('ar'),

  /// Dutch.
  nl('nl'),

  /// Unknown language (forward-compatible fallback).
  unknown('unknown');

  const SummaryLanguage(this.value);

  /// The string value used in the URL path.
  final String value;

  /// Converts to the string used in the URL path.
  String toJson() => value;

  /// Creates a [SummaryLanguage] from a string value.
  static SummaryLanguage fromString(String? value) {
    if (value == null) return SummaryLanguage.unknown;
    return SummaryLanguage.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SummaryLanguage.unknown,
    );
  }
}
