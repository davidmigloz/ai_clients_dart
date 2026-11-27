part of 'content.dart';

/// A document content block.
class DocumentContent extends InteractionContent {
  @override
  String get type => 'document';

  /// Base64-encoded document data.
  final String? data;

  /// URI of the document.
  final String? uri;

  /// The MIME type of the document.
  final String? mimeType;

  /// The resolution of rendered document pages.
  final InteractionMediaResolution? resolution;

  /// Document processing mode or page and spreadsheet selection.
  final InteractionDocumentProcessing? processing;

  /// Creates a [DocumentContent] instance.
  const DocumentContent({
    this.data,
    this.uri,
    this.mimeType,
    this.resolution,
    this.processing,
  });

  /// Creates a [DocumentContent] from JSON.
  factory DocumentContent.fromJson(
    Map<String, dynamic> json,
  ) => DocumentContent(
    data: json['data'] as String?,
    uri: json['uri'] as String?,
    mimeType: json['mime_type'] as String?,
    resolution: json['resolution'] != null
        ? interactionMediaResolutionFromString(json['resolution'] as String?)
        : null,
    processing: json['processing'] == null
        ? null
        : InteractionDocumentProcessing.fromJson(json['processing'] as Object),
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (data != null) 'data': data,
    if (uri != null) 'uri': uri,
    if (mimeType != null) 'mime_type': mimeType,
    if (resolution != null)
      'resolution': interactionMediaResolutionToString(resolution!),
    'processing': ?processing?.toJson(),
  };

  /// Creates a copy with replaced values.
  DocumentContent copyWith({
    Object? data = unsetCopyWithValue,
    Object? uri = unsetCopyWithValue,
    Object? mimeType = unsetCopyWithValue,
    Object? resolution = unsetCopyWithValue,
    Object? processing = unsetCopyWithValue,
  }) {
    return DocumentContent(
      data: data == unsetCopyWithValue ? this.data : data as String?,
      uri: uri == unsetCopyWithValue ? this.uri : uri as String?,
      mimeType: mimeType == unsetCopyWithValue
          ? this.mimeType
          : mimeType as String?,
      resolution: resolution == unsetCopyWithValue
          ? this.resolution
          : resolution as InteractionMediaResolution?,
      processing: processing == unsetCopyWithValue
          ? this.processing
          : processing as InteractionDocumentProcessing?,
    );
  }
}
