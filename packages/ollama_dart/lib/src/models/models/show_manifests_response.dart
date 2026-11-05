import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'show_manifest.dart';

/// Information about all variants in a model manifest list.
@immutable
class ShowManifestsResponse {
  /// Model information for each child manifest, in server order.
  final List<ShowManifest> manifests;

  /// License shared by the model variants.
  final String? license;

  /// Creates a [ShowManifestsResponse] and freezes [manifests].
  ShowManifestsResponse({required List<ShowManifest> manifests, this.license})
    : manifests = List.unmodifiable(manifests);

  /// Creates a [ShowManifestsResponse] from JSON.
  factory ShowManifestsResponse.fromJson(Map<String, dynamic> json) {
    final manifests = json['manifests'];
    if (manifests is! List) {
      throw const FormatException(
        'ShowManifestsResponse: missing manifests list',
      );
    }
    return ShowManifestsResponse(
      manifests: manifests.map((value) {
        if (value is! Map<String, dynamic>) {
          throw const FormatException(
            'ShowManifestsResponse: invalid manifest',
          );
        }
        return ShowManifest.fromJson(value);
      }).toList(),
      license: json['license'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'manifests': manifests.map((value) => value.toJson()).toList(),
    if (license != null) 'license': license,
  };

  /// Creates a copy with replaced values; explicit null clears [license].
  ShowManifestsResponse copyWith({
    List<ShowManifest>? manifests,
    Object? license = unsetCopyWithValue,
  }) => ShowManifestsResponse(
    manifests: manifests ?? this.manifests,
    license: identical(license, unsetCopyWithValue)
        ? this.license
        : license as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShowManifestsResponse &&
          listsEqual(manifests, other.manifests) &&
          license == other.license;

  @override
  int get hashCode => Object.hash(listHash(manifests), license);

  @override
  String toString() =>
      'ShowManifestsResponse(manifests: $manifests, license: $license)';
}
