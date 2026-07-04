/// Configuration for how conversation history is handled in a Live session.
class HistoryConfig {
  /// Whether the initial history should be included in client content.
  final bool? initialHistoryInClientContent;

  /// Creates a [HistoryConfig].
  const HistoryConfig({this.initialHistoryInClientContent});

  /// Creates a [HistoryConfig] from JSON.
  factory HistoryConfig.fromJson(Map<String, dynamic> json) {
    return HistoryConfig(
      initialHistoryInClientContent:
          json['initialHistoryInClientContent'] as bool?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (initialHistoryInClientContent != null)
      'initialHistoryInClientContent': initialHistoryInClientContent,
  };

  /// Creates a copy with the given fields replaced.
  HistoryConfig copyWith({bool? initialHistoryInClientContent}) {
    return HistoryConfig(
      initialHistoryInClientContent:
          initialHistoryInClientContent ?? this.initialHistoryInClientContent,
    );
  }

  @override
  String toString() =>
      'HistoryConfig('
      'initialHistoryInClientContent: $initialHistoryInClientContent)';
}
