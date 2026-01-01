/// Share level for library access.
///
/// Defines the access level when sharing a library with an entity.
enum ShareLevel {
  /// View-only access.
  viewer('Viewer'),

  /// Full editing access.
  editor('Editor');

  const ShareLevel(this.value);

  /// The string value used in the API.
  final String value;

  /// Creates from a JSON string value.
  static ShareLevel fromString(String? value) {
    return ShareLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ShareLevel.viewer,
    );
  }
}
