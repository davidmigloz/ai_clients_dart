/// A layer to extract from video during static media processing.
extension type const InteractionVideoLayer(String value) {
  /// Sampled video frames.
  static const frames = InteractionVideoLayer('frames');

  /// The audio track.
  static const audio = InteractionVideoLayer('audio');

  /// A transcript of the audio track.
  static const transcript = InteractionVideoLayer('transcript');
}

/// A layer to extract from paginated content.
extension type const InteractionPageLayer(String value) {
  /// The rendered page.
  static const image = InteractionPageLayer('page_image');

  /// Text extracted from the page.
  static const text = InteractionPageLayer('page_text');
}

/// A layer to extract from a spreadsheet.
extension type const InteractionSpreadsheetLayer(String value) {
  /// The rendered sheet.
  static const visual = InteractionSpreadsheetLayer('visual');

  /// Cell values, merges and formats.
  static const data = InteractionSpreadsheetLayer('data');

  /// Formulas and their computed results.
  static const formulas = InteractionSpreadsheetLayer('formulas');
}

/// Selects a page range or content layers in a paginated document.
final class InteractionPageProcessingOptions {
  /// One-based inclusive start page.
  final int? startPage;

  /// One-based inclusive end page.
  final int? endPage;

  /// The layers to process.
  final List<InteractionPageLayer>? contentLayers;

  /// Creates processing options for PDF, document or presentation pages.
  const InteractionPageProcessingOptions({
    this.startPage,
    this.endPage,
    this.contentLayers,
  });

  /// Creates processing options from their wire representation.
  factory InteractionPageProcessingOptions.fromJson(
    Map<String, dynamic> json,
  ) => InteractionPageProcessingOptions(
    startPage: json['start_page'] as int?,
    endPage: json['end_page'] as int?,
    contentLayers: (json['content_layers'] as List<dynamic>?)
        ?.cast<String>()
        .map(InteractionPageLayer.new)
        .toList(),
  );

  /// Converts the options to their wire representation.
  Map<String, dynamic> toJson() => {
    'start_page': ?startPage,
    'end_page': ?endPage,
    if (contentLayers != null)
      'content_layers': [for (final layer in contentLayers!) layer.value],
  };
}

/// Selects a sheet, cell range or content layers in a workbook.
final class InteractionSpreadsheetProcessingOptions {
  /// The A1-notation range to extract, such as `A1:D10`.
  final String? visibleCells;

  /// The one-based sheet index in workbook order.
  final int? sheetIndex;

  /// The layers to process.
  final List<InteractionSpreadsheetLayer>? contentLayers;

  /// Creates processing options for spreadsheet files.
  const InteractionSpreadsheetProcessingOptions({
    this.visibleCells,
    this.sheetIndex,
    this.contentLayers,
  });

  /// Creates processing options from their wire representation.
  factory InteractionSpreadsheetProcessingOptions.fromJson(
    Map<String, dynamic> json,
  ) => InteractionSpreadsheetProcessingOptions(
    visibleCells: json['visible_cells'] as String?,
    sheetIndex: json['sheet_index'] as int?,
    contentLayers: (json['content_layers'] as List<dynamic>?)
        ?.cast<String>()
        .map(InteractionSpreadsheetLayer.new)
        .toList(),
  );

  /// Converts the options to their wire representation.
  Map<String, dynamic> toJson() => {
    'visible_cells': ?visibleCells,
    'sheet_index': ?sheetIndex,
    if (contentLayers != null)
      'content_layers': [for (final layer in contentLayers!) layer.value],
  };
}

/// Controls audio understanding for an Interactions audio content block.
final class InteractionAudioProcessing {
  final Object? _wireValue;

  /// Optional clip start, expressed in seconds with an `s` suffix.
  final String? startOffset;

  /// Optional clip end, expressed in seconds with an `s` suffix.
  final String? endOffset;

  /// Places the entire audio in context.
  const InteractionAudioProcessing.staticMode() : this._wire('static');

  /// Processes the selected audio interval.
  const InteractionAudioProcessing.clip({this.startOffset, this.endOffset})
    : _wireValue = null;

  const InteractionAudioProcessing._wire(this._wireValue)
    : startOffset = null,
      endOffset = null;

  /// Parses the shorthand or object form and retains future wire variants.
  factory InteractionAudioProcessing.fromJson(Object json) => switch (json) {
    final Map<String, dynamic> options when options['type'] == 'static' =>
      InteractionAudioProcessing.clip(
        startOffset: options['start_offset'] as String?,
        endOffset: options['end_offset'] as String?,
      ),
    String() ||
    Map<String, dynamic>() => InteractionAudioProcessing._wire(json),
    _ => throw const FormatException('Invalid Interactions audio processing'),
  };

  /// Converts the selector to its wire representation.
  Object toJson() =>
      _wireValue ??
      {
        'type': 'static',
        'start_offset': ?startOffset,
        'end_offset': ?endOffset,
      };
}

/// Controls video understanding for an Interactions video content block.
final class InteractionVideoProcessing {
  final Object? _wireValue;

  /// Optional clip start, expressed in seconds with an `s` suffix.
  final String? startOffset;

  /// Optional clip end, expressed in seconds with an `s` suffix.
  final String? endOffset;

  /// Optional frame sampling rate.
  final double? fps;

  /// The layers to process.
  final List<InteractionVideoLayer>? contentLayers;

  /// Uses fixed-rate frame extraction for the entire video.
  const InteractionVideoProcessing.staticMode() : this._wire('static');

  /// Lets the model navigate the video dynamically.
  const InteractionVideoProcessing.agentic() : this._wire('agentic');

  /// Processes a selected range, sampling rate or set of video layers.
  const InteractionVideoProcessing.clip({
    this.startOffset,
    this.endOffset,
    this.fps,
    this.contentLayers,
  }) : _wireValue = null;

  const InteractionVideoProcessing._wire(this._wireValue)
    : startOffset = null,
      endOffset = null,
      fps = null,
      contentLayers = null;

  /// Parses the shorthand or object form and retains future wire variants.
  factory InteractionVideoProcessing.fromJson(Object json) => switch (json) {
    final Map<String, dynamic> options when options['type'] == 'static' =>
      InteractionVideoProcessing.clip(
        startOffset: options['start_offset'] as String?,
        endOffset: options['end_offset'] as String?,
        fps: (options['fps'] as num?)?.toDouble(),
        contentLayers: (options['content_layers'] as List<dynamic>?)
            ?.cast<String>()
            .map(InteractionVideoLayer.new)
            .toList(),
      ),
    String() ||
    Map<String, dynamic>() => InteractionVideoProcessing._wire(json),
    _ => throw const FormatException('Invalid Interactions video processing'),
  };

  /// Converts the selector to its wire representation.
  Object toJson() =>
      _wireValue ??
      {
        'type': 'static',
        'start_offset': ?startOffset,
        'end_offset': ?endOffset,
        'fps': ?fps,
        if (contentLayers != null)
          'content_layers': [for (final layer in contentLayers!) layer.value],
      };
}

/// Controls document processing for an Interactions document content block.
final class InteractionDocumentProcessing {
  final Object? _wireValue;

  /// Page processing for PDFs, documents and presentations.
  final InteractionPageProcessingOptions? pageOptions;

  /// Sheet and range processing for spreadsheet files.
  final InteractionSpreadsheetProcessingOptions? spreadsheetOptions;

  /// Places all extracted pages in context.
  const InteractionDocumentProcessing.staticMode() : this._wire('static');

  /// Processes the selected document ranges and layers.
  const InteractionDocumentProcessing.select({
    this.pageOptions,
    this.spreadsheetOptions,
  }) : _wireValue = null;

  const InteractionDocumentProcessing._wire(this._wireValue)
    : pageOptions = null,
      spreadsheetOptions = null;

  /// Parses the shorthand or object form and retains future wire variants.
  factory InteractionDocumentProcessing.fromJson(Object json) => switch (json) {
    final Map<String, dynamic> options when options['type'] == 'static' =>
      InteractionDocumentProcessing.select(
        pageOptions: switch (options['page_options']) {
          final Map<String, dynamic> page =>
            InteractionPageProcessingOptions.fromJson(page),
          null => null,
          _ => throw const FormatException('Invalid page processing options'),
        },
        spreadsheetOptions: switch (options['spreadsheet_options']) {
          final Map<String, dynamic> sheet =>
            InteractionSpreadsheetProcessingOptions.fromJson(sheet),
          null => null,
          _ => throw const FormatException(
            'Invalid spreadsheet processing options',
          ),
        },
      ),
    String() ||
    Map<String, dynamic>() => InteractionDocumentProcessing._wire(json),
    _ => throw const FormatException(
      'Invalid Interactions document processing',
    ),
  };

  /// Converts the selector to its wire representation.
  Object toJson() =>
      _wireValue ??
      {
        'type': 'static',
        'page_options': ?pageOptions?.toJson(),
        'spreadsheet_options': ?spreadsheetOptions?.toJson(),
      };
}
