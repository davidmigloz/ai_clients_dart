/// Connector consumer scope used in request paths.
enum ConnectorConsumerScope {
  /// Current user.
  user('user'),

  /// Current workspace.
  workspace('workspace'),

  /// Current organization.
  organization('organization');

  const ConnectorConsumerScope(this.value);

  /// The path segment for this scope.
  final String value;
}
