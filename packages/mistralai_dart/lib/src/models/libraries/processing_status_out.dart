import 'package:meta/meta.dart';

/// Processing status of a library document.
@immutable
class ProcessingStatusOut {
  /// The document ID.
  final String documentId;

  /// The processing status.
  ///
  /// Common values include "pending", "processing", "completed", "failed".
  final String processingStatus;

  /// Creates [ProcessingStatusOut].
  const ProcessingStatusOut({
    required this.documentId,
    required this.processingStatus,
  });

  /// Creates from JSON.
  factory ProcessingStatusOut.fromJson(Map<String, dynamic> json) =>
      ProcessingStatusOut(
        documentId: json['document_id'] as String,
        processingStatus: json['processing_status'] as String,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'document_id': documentId,
    'processing_status': processingStatus,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessingStatusOut &&
          runtimeType == other.runtimeType &&
          documentId == other.documentId &&
          processingStatus == other.processingStatus;

  @override
  int get hashCode => Object.hash(documentId, processingStatus);

  @override
  String toString() =>
      'ProcessingStatusOut('
      'documentId: $documentId, processingStatus: $processingStatus)';
}
