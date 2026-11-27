/// The stream returned by deployment log search.
enum DeploymentLogType {
  /// Image build output for a managed deployment.
  build('build'),

  /// Logs from the deployment workers.
  runtime('runtime'),

  /// Unrecognized wire value.
  unknown('unknown');

  const DeploymentLogType(this.value);

  /// Wire value.
  final String value;

  /// Decodes the wire value.
  static DeploymentLogType? fromJson(String? value) => switch (value) {
    null => null,
    'build' => build,
    'runtime' => runtime,
    _ => unknown,
  };
}
