import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// A child variant available through a model manifest list.
@immutable
class ManifestSummary {
  /// Digest of the child manifest.
  final String? digest;

  /// Runner serving this variant.
  final String? runner;

  /// Weight format used by this variant.
  final String? format;

  /// Whether this is the selected variant.
  final bool? selected;

  /// Creates a [ManifestSummary].
  const ManifestSummary({this.digest, this.runner, this.format, this.selected});

  /// Creates a [ManifestSummary] from JSON.
  factory ManifestSummary.fromJson(Map<String, dynamic> json) =>
      ManifestSummary(
        digest: json['digest'] as String?,
        runner: json['runner'] as String?,
        format: json['format'] as String?,
        selected: json['selected'] as bool?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (digest != null) 'digest': digest,
    if (runner != null) 'runner': runner,
    if (format != null) 'format': format,
    if (selected != null) 'selected': selected,
  };

  /// Creates a copy with replaced values; explicit null clears a field.
  ManifestSummary copyWith({
    Object? digest = unsetCopyWithValue,
    Object? runner = unsetCopyWithValue,
    Object? format = unsetCopyWithValue,
    Object? selected = unsetCopyWithValue,
  }) => ManifestSummary(
    digest: identical(digest, unsetCopyWithValue)
        ? this.digest
        : digest as String?,
    runner: identical(runner, unsetCopyWithValue)
        ? this.runner
        : runner as String?,
    format: identical(format, unsetCopyWithValue)
        ? this.format
        : format as String?,
    selected: identical(selected, unsetCopyWithValue)
        ? this.selected
        : selected as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManifestSummary &&
          digest == other.digest &&
          runner == other.runner &&
          format == other.format &&
          selected == other.selected;

  @override
  int get hashCode => Object.hash(digest, runner, format, selected);

  @override
  String toString() =>
      'ManifestSummary(digest: $digest, runner: $runner, '
      'format: $format, selected: $selected)';
}
