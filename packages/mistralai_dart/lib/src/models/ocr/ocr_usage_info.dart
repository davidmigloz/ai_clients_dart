import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Usage information for an OCR request.
@immutable
class OcrUsageInfo {
  /// Number of pages processed.
  final int pagesProcessed;

  /// Document size in bytes.
  final int? docSizeBytes;

  /// Creates an [OcrUsageInfo].
  const OcrUsageInfo({required this.pagesProcessed, this.docSizeBytes});

  /// Creates an [OcrUsageInfo] from JSON.
  factory OcrUsageInfo.fromJson(Map<String, dynamic> json) => OcrUsageInfo(
    pagesProcessed: json['pages_processed'] as int? ?? 0,
    docSizeBytes: json['doc_size_bytes'] as int?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'pages_processed': pagesProcessed,
    if (docSizeBytes != null) 'doc_size_bytes': docSizeBytes,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  OcrUsageInfo copyWith({
    int? pagesProcessed,
    Object? docSizeBytes = unsetCopyWithValue,
  }) => OcrUsageInfo(
    pagesProcessed: pagesProcessed ?? this.pagesProcessed,
    docSizeBytes: docSizeBytes == unsetCopyWithValue
        ? this.docSizeBytes
        : docSizeBytes as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrUsageInfo &&
          runtimeType == other.runtimeType &&
          pagesProcessed == other.pagesProcessed &&
          docSizeBytes == other.docSizeBytes;

  @override
  int get hashCode => Object.hash(pagesProcessed, docSizeBytes);

  @override
  String toString() =>
      'OcrUsageInfo(pagesProcessed: $pagesProcessed, '
      'docSizeBytes: $docSizeBytes)';
}
