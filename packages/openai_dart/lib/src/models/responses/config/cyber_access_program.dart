/// Cyber access programs accepted by the Responses API.
///
/// Selecting a program does not grant access. Model eligibility and
/// organization or project authorization are enforced by the server.
enum CyberAccessProgram {
  /// Select the standard access program explicitly.
  standard('standard'),

  /// Select the Daybreak Blue access program.
  daybreakBlue('daybreak_blue'),

  /// Select the Daybreak Red access program.
  daybreakRed('daybreak_red');

  /// The exact API wire value.
  final String value;

  const CyberAccessProgram(this.value);

  /// Parses a known wire value, returning `null` for an unrecognized value.
  ///
  /// Access-program object parsers reject unrecognized values with a
  /// contextual [FormatException], rather than silently selecting a program.
  static CyberAccessProgram? fromJson(String value) => switch (value) {
    'standard' => standard,
    'daybreak_blue' => daybreakBlue,
    'daybreak_red' => daybreakRed,
    _ => null,
  };

  /// Converts to the exact API wire value.
  String toJson() => value;
}
