import '../copy_with_sentinel.dart';
import 'media_wire_options.dart';

/// Video interpretation approach for GenerateContent.
///
/// Retains the wire value for options added by future API versions.
extension type const MediaProcessing(String value) {
  /// Use the model-specific default.
  static const unspecified = MediaProcessing('MEDIA_PROCESSING_UNSPECIFIED');

  /// Sample video frames at a fixed rate.
  static const static = MediaProcessing('STATIC');

  /// Let the model navigate the video dynamically.
  static const agentic = MediaProcessing('AGENTIC');

  /// Creates a value from the API representation.
  factory MediaProcessing.fromJson(String value) => MediaProcessing(value);

  /// Converts to JSON.
  String toJson() => value;
}

/// Content to extract from document pages.
///
/// Retains the wire value for options added by future API versions.
extension type const DocumentContentLayer(String value) {
  /// Use the default content layer.
  static const unspecified = DocumentContentLayer('CONTENT_LAYER_UNSPECIFIED');

  /// Rendered page images.
  static const pageImage = DocumentContentLayer('PAGE_IMAGE');

  /// Extracted text.
  static const pageText = DocumentContentLayer('PAGE_TEXT');

  /// Creates a value from the API representation.
  factory DocumentContentLayer.fromJson(String value) =>
      DocumentContentLayer(value);

  /// Converts to JSON.
  String toJson() => value;
}

/// Content to extract from a spreadsheet.
///
/// Retains the wire value for options added by future API versions.
extension type const SpreadsheetContentLayer(String value) {
  /// Use the default content layers.
  static const unspecified = SpreadsheetContentLayer(
    'CONTENT_LAYER_UNSPECIFIED',
  );

  /// Values, merges, and formats.
  static const data = SpreadsheetContentLayer('DATA');

  /// Formula expressions and results.
  static const formulas = SpreadsheetContentLayer('FORMULAS');

  /// A rendered image of the sheet.
  static const visual = SpreadsheetContentLayer('VISUAL');

  /// Creates a value from the API representation.
  factory SpreadsheetContentLayer.fromJson(String value) =>
      SpreadsheetContentLayer(value);

  /// Converts to JSON.
  String toJson() => value;
}

/// Clipping options for an audio part.
class AudioMetadata {
  /// A protobuf duration relative to the start, such as `1.5s`.
  final String? startOffset;

  /// The end offset as a protobuf duration.
  final String? endOffset;

  /// Creates a [AudioMetadata].
  const AudioMetadata({this.startOffset, this.endOffset})
    : _wireExtensions = const {};

  final Map<String, dynamic> _wireExtensions;

  const AudioMetadata._({
    this.startOffset,
    this.endOffset,
    required this._wireExtensions,
  });

  /// Creates from JSON.
  factory AudioMetadata.fromJson(Map<String, dynamic> json) => AudioMetadata._(
    startOffset: json['startOffset'] as String?,
    endOffset: json['endOffset'] as String?,
    wireExtensions: mediaExtensions(json, const {'startOffset', 'endOffset'}),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    ..._wireExtensions,
    if (startOffset != null) 'startOffset': startOffset,
    if (endOffset != null) 'endOffset': endOffset,
  };

  /// Creates a copy with replaced values.
  AudioMetadata copyWith({
    Object? startOffset = unsetCopyWithValue,
    Object? endOffset = unsetCopyWithValue,
  }) => AudioMetadata._(
    startOffset: startOffset == unsetCopyWithValue
        ? this.startOffset
        : startOffset as String?,
    endOffset: endOffset == unsetCopyWithValue
        ? this.endOffset
        : endOffset as String?,
    wireExtensions: _wireExtensions,
  );
}

/// Page selection and content layers for a document part.
class DocumentMetadata {
  /// The first page to include, starting at 1.
  final int? startPage;

  /// The last page to include, starting at 1.
  final int? endPage;

  /// The layers to extract. An empty list selects the backend default.
  final List<DocumentContentLayer>? contentLayers;

  /// Creates a [DocumentMetadata].
  const DocumentMetadata({this.startPage, this.endPage, this.contentLayers})
    : _wireExtensions = const {};

  final Map<String, dynamic> _wireExtensions;

  const DocumentMetadata._({
    this.startPage,
    this.endPage,
    this.contentLayers,
    required this._wireExtensions,
  });

  /// Creates from JSON.
  factory DocumentMetadata.fromJson(Map<String, dynamic> json) =>
      DocumentMetadata._(
        startPage: json['startPage'] as int?,
        endPage: json['endPage'] as int?,
        contentLayers: (json['contentLayers'] as List?)
            ?.cast<String>()
            .map(DocumentContentLayer.fromJson)
            .toList(),
        wireExtensions: mediaExtensions(json, const {
          'startPage',
          'endPage',
          'contentLayers',
        }),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    ..._wireExtensions,
    if (startPage != null) 'startPage': startPage,
    if (endPage != null) 'endPage': endPage,
    if (contentLayers != null)
      'contentLayers': contentLayers!.map((value) => value.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  DocumentMetadata copyWith({
    Object? startPage = unsetCopyWithValue,
    Object? endPage = unsetCopyWithValue,
    Object? contentLayers = unsetCopyWithValue,
  }) => DocumentMetadata._(
    startPage: startPage == unsetCopyWithValue
        ? this.startPage
        : startPage as int?,
    endPage: endPage == unsetCopyWithValue ? this.endPage : endPage as int?,
    contentLayers: contentLayers == unsetCopyWithValue
        ? this.contentLayers
        : contentLayers as List<DocumentContentLayer>?,
    wireExtensions: _wireExtensions,
  );
}

/// Sheet selection and extraction options for a spreadsheet part.
class SpreadsheetMetadata {
  /// The cells to extract in A1 notation, such as `A1:D10`.
  final String? visibleCells;

  /// The index of the sheet to extract, starting at 1.
  final int? sheetIndex;

  /// The layers to extract. An empty list selects the backend defaults.
  final List<SpreadsheetContentLayer>? contentLayers;

  /// Creates a [SpreadsheetMetadata].
  const SpreadsheetMetadata({
    this.visibleCells,
    this.sheetIndex,
    this.contentLayers,
  }) : _wireExtensions = const {};

  final Map<String, dynamic> _wireExtensions;

  const SpreadsheetMetadata._({
    this.visibleCells,
    this.sheetIndex,
    this.contentLayers,
    required this._wireExtensions,
  });

  /// Creates from JSON.
  factory SpreadsheetMetadata.fromJson(Map<String, dynamic> json) =>
      SpreadsheetMetadata._(
        visibleCells: json['visibleCells'] as String?,
        sheetIndex: json['sheetIndex'] as int?,
        contentLayers: (json['contentLayers'] as List?)
            ?.cast<String>()
            .map(SpreadsheetContentLayer.fromJson)
            .toList(),
        wireExtensions: mediaExtensions(json, const {
          'visibleCells',
          'sheetIndex',
          'contentLayers',
        }),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    ..._wireExtensions,
    if (visibleCells != null) 'visibleCells': visibleCells,
    if (sheetIndex != null) 'sheetIndex': sheetIndex,
    if (contentLayers != null)
      'contentLayers': contentLayers!.map((value) => value.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  SpreadsheetMetadata copyWith({
    Object? visibleCells = unsetCopyWithValue,
    Object? sheetIndex = unsetCopyWithValue,
    Object? contentLayers = unsetCopyWithValue,
  }) => SpreadsheetMetadata._(
    visibleCells: visibleCells == unsetCopyWithValue
        ? this.visibleCells
        : visibleCells as String?,
    sheetIndex: sheetIndex == unsetCopyWithValue
        ? this.sheetIndex
        : sheetIndex as int?,
    contentLayers: contentLayers == unsetCopyWithValue
        ? this.contentLayers
        : contentLayers as List<SpreadsheetContentLayer>?,
    wireExtensions: _wireExtensions,
  );
}
