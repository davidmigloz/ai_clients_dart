import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// In-memory audio file for a multipart transcription or translation upload.
///
/// Ollama validates the file container, sample rate, size, and duration.
@immutable
class AudioFile {
  /// Raw file bytes, preserved without text encoding.
  final List<int> bytes;

  /// File name included in the multipart upload.
  final String filename;

  /// Creates an immutable audio file.
  AudioFile({required List<int> bytes, this.filename = 'audio.wav'})
    : bytes = List.unmodifiable(bytes);

  /// Creates a file from its JSON representation.
  factory AudioFile.fromJson(Map<String, dynamic> json) {
    final bytes = json['bytes'];
    final filename = json['filename'];
    if (bytes is! List) {
      throw const FormatException('AudioFile.bytes must be an integer list');
    }
    if (filename != null && filename is! String) {
      throw const FormatException('AudioFile.filename must be a string');
    }
    return AudioFile(
      bytes: [
        for (var i = 0; i < bytes.length; i++)
          if (bytes[i] case final int byte)
            byte
          else
            throw FormatException('AudioFile.bytes[$i] must be an integer'),
      ],
      filename: filename as String? ?? 'audio.wav',
    );
  }

  /// Converts to JSON. The HTTP API sends these bytes as multipart file data.
  Map<String, dynamic> toJson() => {'bytes': bytes, 'filename': filename};

  /// Creates a copy.
  AudioFile copyWith({List<int>? bytes, String? filename}) => AudioFile(
    bytes: bytes ?? this.bytes,
    filename: filename ?? this.filename,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioFile &&
          filename == other.filename &&
          listsEqual(bytes, other.bytes);

  @override
  int get hashCode => Object.hash(filename, listHash(bytes));

  @override
  String toString() =>
      'AudioFile(bytes: ${bytes.length} bytes, filename: $filename)';
}
