part of 'steps.dart';

/// Result of a File Search call.
class FileSearchResultStep extends InteractionStep {
  @override
  String get type => 'file_search_result';

  /// ID matching the corresponding [FileSearchCallStep.id].
  final String callId;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [FileSearchResultStep] instance.
  const FileSearchResultStep({required this.callId, this.signature});

  /// Creates a [FileSearchResultStep] from JSON.
  factory FileSearchResultStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'file_search_result') {
      throw FormatException(
        'Expected type "file_search_result" but got "${json['type']}"',
      );
    }
    final callId = json['call_id'];
    if (callId is! String) {
      throw const FormatException(
        'FileSearchResultStep: missing required "call_id"',
      );
    }
    return FileSearchResultStep(
      callId: callId,
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  FileSearchResultStep copyWith({
    Object? callId = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return FileSearchResultStep(
      callId: callId == unsetCopyWithValue ? this.callId : callId! as String,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
