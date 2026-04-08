import 'package:meta/meta.dart';

import 'base_task_status.dart';

/// Status of a campaign.
@immutable
class CampaignStatus {
  /// The current status.
  final BaseTaskStatus status;

  /// Creates a [CampaignStatus].
  const CampaignStatus({required this.status});

  /// Creates a [CampaignStatus] from JSON.
  factory CampaignStatus.fromJson(Map<String, dynamic> json) => CampaignStatus(
    status: BaseTaskStatus.fromJson(json['status'] as String?),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'status': status.value};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CampaignStatus) return false;
    if (runtimeType != other.runtimeType) return false;
    return status == other.status;
  }

  @override
  int get hashCode => status.hashCode;

  @override
  String toString() => 'CampaignStatus(status: ${status.value})';
}
