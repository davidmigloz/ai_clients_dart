/// The visibility scope of a file.
enum FileVisibility {
  /// Visible to all members of the workspace.
  workspace('workspace'),

  /// Visible only to the user who uploaded it.
  user('user'),

  /// Unknown visibility (forward compatibility).
  unknown('unknown');

  const FileVisibility(this.value);

  /// The string value of this visibility.
  final String value;

  /// Creates from a string value.
  static FileVisibility? fromString(String? value) => switch (value) {
    'workspace' => workspace,
    'user' => user,
    null => null,
    _ => unknown,
  };
}
