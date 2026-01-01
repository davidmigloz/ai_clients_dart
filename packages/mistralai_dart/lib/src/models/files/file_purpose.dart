/// The purpose of an uploaded file.
enum FilePurpose {
  /// File for fine-tuning a model.
  fineTune,

  /// File for batch processing.
  batch,

  /// File for OCR processing.
  ocr,

  /// File for audio processing.
  audio,

  /// Unknown purpose.
  unknown,
}

/// Converts a [FilePurpose] to its API string representation.
String filePurposeToString(FilePurpose purpose) {
  switch (purpose) {
    case FilePurpose.fineTune:
      return 'fine-tune';
    case FilePurpose.batch:
      return 'batch';
    case FilePurpose.ocr:
      return 'ocr';
    case FilePurpose.audio:
      return 'audio';
    case FilePurpose.unknown:
      return 'unknown';
  }
}

/// Parses a [FilePurpose] from its API string representation.
FilePurpose filePurposeFromString(String? value) {
  switch (value) {
    case 'fine-tune':
      return FilePurpose.fineTune;
    case 'batch':
      return FilePurpose.batch;
    case 'ocr':
      return FilePurpose.ocr;
    case 'audio':
      return FilePurpose.audio;
    default:
      return FilePurpose.unknown;
  }
}
