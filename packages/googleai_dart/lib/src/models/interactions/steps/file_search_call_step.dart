part of 'steps.dart';

/// A File Search tool call step.
class FileSearchCallStep extends InteractionStep {
  @override
  String get type => 'file_search_call';

  /// A unique ID for this specific tool call.
  final String id;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [FileSearchCallStep] instance.
  const FileSearchCallStep({required this.id, this.signature});

  /// Creates a [FileSearchCallStep] from JSON.
  factory FileSearchCallStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'file_search_call') {
      throw FormatException(
        'Expected type "file_search_call" but got "${json['type']}"',
      );
    }
    final id = json['id'];
    if (id is! String) {
      throw const FormatException('FileSearchCallStep: missing required "id"');
    }
    return FileSearchCallStep(id: id, signature: json['signature'] as String?);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  FileSearchCallStep copyWith({
    Object? id = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return FileSearchCallStep(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
