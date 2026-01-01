import 'package:meta/meta.dart';

/// An event that occurred during fine-tuning.
@immutable
class TrainingEvent {
  /// Name/type of the event.
  final String name;

  /// Event data/message.
  final String? data;

  /// Timestamp when the event occurred.
  final DateTime? createdAt;

  /// Creates a [TrainingEvent].
  const TrainingEvent({required this.name, this.data, this.createdAt});

  /// Creates a [TrainingEvent] from JSON.
  factory TrainingEvent.fromJson(Map<String, dynamic> json) => TrainingEvent(
    name: json['name'] as String? ?? '',
    data: json['data'] as String?,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'] as String)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (data != null) 'data': data,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingEvent &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          data == other.data &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(name, data, createdAt);

  @override
  String toString() => 'TrainingEvent(name: $name, data: $data)';
}
