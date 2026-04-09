import 'package:meta/meta.dart';

/// Information about a workflow worker.
@immutable
class WorkerInfo {
  /// The scheduler URL.
  final String schedulerUrl;

  /// The worker namespace.
  final String namespace;

  /// Whether TLS is enabled.
  final bool tls;

  /// Creates a [WorkerInfo].
  const WorkerInfo({
    required this.schedulerUrl,
    required this.namespace,
    this.tls = false,
  });

  /// Creates a [WorkerInfo] from JSON.
  factory WorkerInfo.fromJson(Map<String, dynamic> json) => WorkerInfo(
    schedulerUrl: json['scheduler_url'] as String? ?? '',
    namespace: json['namespace'] as String? ?? '',
    tls: json['tls'] as bool? ?? false,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'scheduler_url': schedulerUrl,
    'namespace': namespace,
    'tls': tls,
  };

  /// Creates a copy with replaced values.
  WorkerInfo copyWith({String? schedulerUrl, String? namespace, bool? tls}) {
    return WorkerInfo(
      schedulerUrl: schedulerUrl ?? this.schedulerUrl,
      namespace: namespace ?? this.namespace,
      tls: tls ?? this.tls,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkerInfo) return false;
    if (runtimeType != other.runtimeType) return false;
    return schedulerUrl == other.schedulerUrl &&
        namespace == other.namespace &&
        tls == other.tls;
  }

  @override
  int get hashCode => Object.hash(schedulerUrl, namespace, tls);

  @override
  String toString() =>
      'WorkerInfo(schedulerUrl: $schedulerUrl, namespace: $namespace, tls: $tls)';
}
