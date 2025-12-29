import 'package:meta/meta.dart';

/// Request to copy a model.
@immutable
class CopyRequest {
  /// Existing model name to copy from.
  final String source;

  /// New model name to create.
  final String destination;

  /// Creates a [CopyRequest].
  const CopyRequest({required this.source, required this.destination});

  /// Creates a [CopyRequest] from JSON.
  factory CopyRequest.fromJson(Map<String, dynamic> json) => CopyRequest(
    source: json['source'] as String,
    destination: json['destination'] as String,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'source': source,
    'destination': destination,
  };

  /// Creates a copy with replaced values.
  CopyRequest copyWith({String? source, String? destination}) {
    return CopyRequest(
      source: source ?? this.source,
      destination: destination ?? this.destination,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CopyRequest &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          destination == other.destination;

  @override
  int get hashCode => Object.hash(source, destination);

  @override
  String toString() =>
      'CopyRequest(source: $source, destination: $destination)';
}
