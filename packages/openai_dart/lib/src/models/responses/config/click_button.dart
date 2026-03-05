/// The mouse button used in a click action.
enum ClickButton {
  /// Unknown button (fallback for unrecognized values).
  unknown('unknown'),

  /// Left mouse button.
  left('left'),

  /// Right mouse button.
  right('right'),

  /// Mouse wheel button (middle click).
  wheel('wheel'),

  /// Browser back button.
  back('back'),

  /// Browser forward button.
  forward('forward');

  /// The JSON value for this button.
  final String value;

  const ClickButton(this.value);

  /// Creates a [ClickButton] from a JSON value.
  factory ClickButton.fromJson(String json) {
    return ClickButton.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ClickButton.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
