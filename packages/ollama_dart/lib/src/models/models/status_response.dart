import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Non-streaming status response for model operations.
@immutable
class StatusResponse {
  /// Current status message.
  final String? status;

  /// Creates a [StatusResponse].
  const StatusResponse({this.status});

  /// Creates a [StatusResponse] from JSON.
  factory StatusResponse.fromJson(Map<String, dynamic> json) =>
      StatusResponse(status: json['status'] as String?);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (status != null) 'status': status};

  /// Creates a copy with replaced values.
  StatusResponse copyWith({Object? status = unsetCopyWithValue}) {
    return StatusResponse(
      status: status == unsetCopyWithValue ? this.status : status as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusResponse &&
          runtimeType == other.runtimeType &&
          status == other.status;

  @override
  int get hashCode => status.hashCode;

  @override
  String toString() => 'StatusResponse(status: $status)';
}
