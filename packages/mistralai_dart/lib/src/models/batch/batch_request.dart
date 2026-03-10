import 'package:meta/meta.dart';

/// An individual request within a batch job.
@immutable
class BatchRequest {
  /// The request body.
  final Map<String, dynamic> body;

  /// Optional custom identifier for tracking this request.
  final String? customId;

  /// Creates a [BatchRequest].
  const BatchRequest({required this.body, this.customId});

  /// Creates a [BatchRequest] from JSON.
  factory BatchRequest.fromJson(Map<String, dynamic> json) => BatchRequest(
    body: json['body'] as Map<String, dynamic>? ?? {},
    customId: json['custom_id'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'body': body,
    if (customId != null) 'custom_id': customId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchRequest &&
          runtimeType == other.runtimeType &&
          customId == other.customId;

  @override
  int get hashCode => customId.hashCode;

  @override
  String toString() => 'BatchRequest(customId: $customId)';
}
