import 'package:meta/meta.dart';

import 'dataset_preview.dart';
import 'paginated_result.dart';

/// Response containing a paginated list of dataset previews.
@immutable
class DatasetPreviews {
  /// The paginated datasets.
  final PaginatedResult<DatasetPreview> datasets;

  /// Creates a [DatasetPreviews].
  const DatasetPreviews({required this.datasets});

  /// Creates a [DatasetPreviews] from JSON.
  factory DatasetPreviews.fromJson(Map<String, dynamic> json) =>
      DatasetPreviews(
        datasets: PaginatedResult.fromJson(
          json['datasets'] as Map<String, dynamic>? ?? {},
          DatasetPreview.fromJson,
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'datasets': datasets.toJson((e) => e.toJson()),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DatasetPreviews) return false;
    if (runtimeType != other.runtimeType) return false;
    return datasets == other.datasets;
  }

  @override
  int get hashCode => datasets.hashCode;

  @override
  String toString() => 'DatasetPreviews(datasets: $datasets)';
}
