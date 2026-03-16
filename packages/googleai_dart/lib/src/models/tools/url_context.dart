/// Tool that enables URL context fetching and analysis.
///
/// This is an empty marker class — URL context requires no additional
/// configuration.
class UrlContext {
  /// Creates a [UrlContext].
  const UrlContext();

  /// Creates a [UrlContext] from JSON.
  // ignore: avoid_unused_constructor_parameters
  factory UrlContext.fromJson(Map<String, dynamic> json) => const UrlContext();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {};

  @override
  String toString() => 'UrlContext()';
}
