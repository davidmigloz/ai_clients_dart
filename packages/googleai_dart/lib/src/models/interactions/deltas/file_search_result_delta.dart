part of 'deltas.dart';

/// A streamed delta for a file search result.
///
/// Each entry in [result] is a raw `FileSearchResult` object; the spec defines
/// no fields on it yet, so the payload is preserved verbatim.
class FileSearchResultDelta extends StepDeltaData {
  @override
  String get type => 'file_search_result';

  /// The results of the file search.
  final List<Map<String, dynamic>>? result;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [FileSearchResultDelta] instance.
  const FileSearchResultDelta({this.result, this.signature});

  /// Creates a [FileSearchResultDelta] from JSON.
  factory FileSearchResultDelta.fromJson(Map<String, dynamic> json) =>
      FileSearchResultDelta(
        result: (json['result'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList(),
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (result != null) 'result': result,
    if (signature != null) 'signature': signature,
  };
}
