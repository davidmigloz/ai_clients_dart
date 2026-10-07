import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/json_helpers.dart';

/// A fragment of stdout and stderr emitted while a shell command runs.
///
/// Each stream is independent: either or both keys may be absent, and empty
/// strings are retained. An empty delta object is valid. Supplied JSON values
/// must be strings; explicit `null` is invalid.
@immutable
class ShellCallOutputDelta {
  /// The stdout fragment, or `null` when the delta omits stdout.
  final String? stdout;

  /// The stderr fragment, or `null` when the delta omits stderr.
  final String? stderr;

  /// Creates a [ShellCallOutputDelta].
  const ShellCallOutputDelta({this.stdout, this.stderr});

  /// Creates a [ShellCallOutputDelta] from JSON.
  factory ShellCallOutputDelta.fromJson(
    Map<String, dynamic> json, {
    String context = 'ShellCallOutputDelta',
  }) => ShellCallOutputDelta(
    stdout: optionalJsonString(json, 'stdout', context),
    stderr: optionalJsonString(json, 'stderr', context),
  );

  /// Converts to JSON, omitting stream keys whose value is `null`.
  Map<String, dynamic> toJson() => {
    if (stdout != null) 'stdout': stdout,
    if (stderr != null) 'stderr': stderr,
  };

  /// Creates a copy, using `null` to remove a stream key.
  ShellCallOutputDelta copyWith({
    Object? stdout = unsetCopyWithValue,
    Object? stderr = unsetCopyWithValue,
  }) => ShellCallOutputDelta(
    stdout: identical(stdout, unsetCopyWithValue)
        ? this.stdout
        : stdout as String?,
    stderr: identical(stderr, unsetCopyWithValue)
        ? this.stderr
        : stderr as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallOutputDelta &&
          runtimeType == other.runtimeType &&
          stdout == other.stdout &&
          stderr == other.stderr;

  @override
  int get hashCode => Object.hash(stdout, stderr);

  @override
  String toString() =>
      'ShellCallOutputDelta(stdout: ${stdout == null ? 'null' : '[${stdout!.length} chars]'}, stderr: ${stderr == null ? 'null' : '[${stderr!.length} chars]'})';
}
