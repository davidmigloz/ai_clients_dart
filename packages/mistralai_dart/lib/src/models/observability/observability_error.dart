import 'package:meta/meta.dart';

import 'observability_error_detail.dart';

/// An observability API error response.
@immutable
class ObservabilityError {
  /// Error detail.
  final ObservabilityErrorDetail detail;

  /// Creates an [ObservabilityError].
  const ObservabilityError({required this.detail});

  /// Creates an [ObservabilityError] from JSON.
  factory ObservabilityError.fromJson(Map<String, dynamic> json) =>
      ObservabilityError(
        detail: ObservabilityErrorDetail.fromJson(
          json['detail'] as Map<String, dynamic>? ?? {},
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'detail': detail.toJson()};

  /// Creates a copy with the specified fields replaced.
  ObservabilityError copyWith({ObservabilityErrorDetail? detail}) =>
      ObservabilityError(detail: detail ?? this.detail);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ObservabilityError) return false;
    if (runtimeType != other.runtimeType) return false;
    return detail == other.detail;
  }

  @override
  int get hashCode => detail.hashCode;

  @override
  String toString() => 'ObservabilityError(detail: $detail)';
}
