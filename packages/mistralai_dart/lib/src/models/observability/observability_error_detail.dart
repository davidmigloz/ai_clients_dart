import 'package:meta/meta.dart';

import 'observability_error_code.dart';

/// Detail of an observability error.
@immutable
class ObservabilityErrorDetail {
  /// Error message.
  final String message;

  /// Error code.
  final ObservabilityErrorCode? errorCode;

  /// Creates an [ObservabilityErrorDetail].
  const ObservabilityErrorDetail({required this.message, this.errorCode});

  /// Creates an [ObservabilityErrorDetail] from JSON.
  factory ObservabilityErrorDetail.fromJson(Map<String, dynamic> json) =>
      ObservabilityErrorDetail(
        message: json['message'] as String? ?? '',
        errorCode: ObservabilityErrorCode.fromJson(
          json['error_code'] as String?,
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'message': message,
    'error_code': errorCode?.value,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ObservabilityErrorDetail) return false;
    if (runtimeType != other.runtimeType) return false;
    return message == other.message && errorCode == other.errorCode;
  }

  @override
  int get hashCode => Object.hash(message, errorCode);

  @override
  String toString() =>
      'ObservabilityErrorDetail(message: $message, errorCode: $errorCode)';
}
