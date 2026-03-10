import 'package:meta/meta.dart';

/// Processing status of a library document.
@immutable
class ProcessingStatusOut {
  /// The document ID.
  final String documentId;

  /// The processing status (legacy).
  ///
  /// Common values include "pending", "processing", "completed", "failed".
  final String processingStatus;

  /// The process status.
  ///
  /// New field with more granular status values.
  final String? processStatus;

  /// Creates [ProcessingStatusOut].
  const ProcessingStatusOut({
    required this.documentId,
    required this.processingStatus,
    this.processStatus,
  });

  /// Creates from JSON.
  factory ProcessingStatusOut.fromJson(Map<String, dynamic> json) =>
      ProcessingStatusOut(
        documentId: json['document_id'] as String,
        processingStatus: json['processing_status'] as String,
        processStatus: json['process_status'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'document_id': documentId,
    'processing_status': processingStatus,
    if (processStatus != null) 'process_status': processStatus,
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
