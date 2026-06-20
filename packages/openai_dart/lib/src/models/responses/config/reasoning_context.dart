/// Controls which reasoning items are rendered back to the model on later turns.
///
/// When returned on a response, this is the effective reasoning context mode
/// used for the response.
enum ReasoningContext {
  /// Unknown mode (fallback for unrecognized values).
  unknown('unknown'),

  /// Let the model decide which reasoning items to render on later turns.
  auto('auto'),

  /// Render only the current turn's reasoning items.
  currentTurn('current_turn'),

  /// Render reasoning items from all turns.
  allTurns('all_turns');

  /// The JSON value for this mode.
  final String value;

  const ReasoningContext(this.value);

  /// Creates a [ReasoningContext] from a JSON value.
  factory ReasoningContext.fromJson(String json) {
    return ReasoningContext.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ReasoningContext.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
