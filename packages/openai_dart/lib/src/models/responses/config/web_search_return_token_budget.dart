/// The amount of web-search content returned to the model.
///
/// This guide-defined setting is only supported by GA web search. Model
/// support varies; omission leaves the server's token budget unchanged.
enum WebSearchReturnTokenBudget {
  /// Use the model's usual return-token budget.
  defaultBudget('default'),

  /// Return search content without the usual return-token limit.
  unlimited('unlimited');

  /// The wire value.
  final String value;

  const WebSearchReturnTokenBudget(this.value);

  /// Parses one of the documented budget values.
  factory WebSearchReturnTokenBudget.fromJson(String json) => switch (json) {
    'default' => WebSearchReturnTokenBudget.defaultBudget,
    'unlimited' => WebSearchReturnTokenBudget.unlimited,
    _ => throw const FormatException(
      'WebSearchReturnTokenBudget: expected "default" or "unlimited"',
    ),
  };

  /// Converts to the wire value.
  String toJson() => value;
}
