import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'show_response.dart';

/// Model information for one variant returned by `models.showManifests`.
///
/// The wire object combines [runner] and the model inspection [details].
@immutable
class ShowManifest {
  /// Runner serving this variant.
  final String? runner;

  /// Model information for this variant.
  final ShowResponse details;

  /// Creates a [ShowManifest].
  const ShowManifest({this.runner, required this.details});

  /// Creates a [ShowManifest] from its flattened JSON object.
  factory ShowManifest.fromJson(Map<String, dynamic> json) => ShowManifest(
    runner: json['runner'] as String?,
    details: ShowResponse.fromJson(json),
  );

  /// Converts to flattened JSON.
  Map<String, dynamic> toJson() => {
    ...details.toJson(),
    if (runner != null) 'runner': runner,
  };

  /// Creates a copy with replaced values; explicit null clears [runner].
  ShowManifest copyWith({
    Object? runner = unsetCopyWithValue,
    ShowResponse? details,
  }) => ShowManifest(
    runner: identical(runner, unsetCopyWithValue)
        ? this.runner
        : runner as String?,
    details: details ?? this.details,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShowManifest &&
          runner == other.runner &&
          details == other.details;

  @override
  int get hashCode => Object.hash(runner, details);

  @override
  String toString() => 'ShowManifest(runner: $runner, details: $details)';
}
