/// Selects how much of a memory's content is returned by `view`-aware
/// endpoints.
enum MemoryView {
  /// Returns identifiers and metadata only (no `content`).
  basic('basic'),

  /// Returns the full memory including `content`.
  full('full'),

  /// Unknown view — fallback for unrecognized values.
  unknown('unknown');

  const MemoryView(this.value);

  /// JSON value for this view.
  final String value;

  /// Parses a [MemoryView] from JSON.
  static MemoryView fromJson(String value) => switch (value) {
    'basic' => MemoryView.basic,
    'full' => MemoryView.full,
    _ => MemoryView.unknown,
  };

  /// Converts this view to JSON.
  String toJson() => value;
}
