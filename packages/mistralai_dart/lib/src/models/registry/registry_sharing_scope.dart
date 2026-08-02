/// Sharing scope for a registry object (prompt or skill).
enum RegistrySharingScope {
  /// Unspecified sharing scope.
  sharingScopeUnspecified('sharing_scope_unspecified'),

  /// Private to the creator.
  private('private'),

  /// Shared within the workspace.
  workspace('workspace'),

  /// Unknown sharing scope (forward compatibility).
  unknown('unknown');

  const RegistrySharingScope(this.value);

  /// The string value used in the API.
  final String value;

  /// Creates from a string value.
  ///
  /// Returns null if [value] is null.
  /// Returns [unknown] if [value] does not match any known value.
  static RegistrySharingScope? fromString(String? value) => switch (value) {
    'sharing_scope_unspecified' => sharingScopeUnspecified,
    'private' => private,
    'workspace' => workspace,
    null => null,
    _ => unknown,
  };
}
