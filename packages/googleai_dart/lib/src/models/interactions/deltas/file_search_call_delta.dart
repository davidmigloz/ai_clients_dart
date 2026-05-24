part of 'deltas.dart';

/// A streamed delta for a file search tool call.
class FileSearchCallDelta extends StepDeltaData {
  @override
  String get type => 'file_search_call';

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [FileSearchCallDelta] instance.
  const FileSearchCallDelta({this.signature});

  /// Creates a [FileSearchCallDelta] from JSON.
  factory FileSearchCallDelta.fromJson(Map<String, dynamic> json) =>
      FileSearchCallDelta(signature: json['signature'] as String?);

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (signature != null) 'signature': signature,
  };
}
