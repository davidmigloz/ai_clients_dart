part of 'deltas.dart';

/// A partial update containing definitions loaded by server-side tool search.
class ToolSearchResultDelta extends StepDeltaData {
  @override
  String get type => 'tool_search_result';

  /// The retrieved function definitions, when present in this delta.
  final List<FunctionTool>? result;

  /// Opaque server signature, when present in this delta.
  final String? signature;

  /// Creates a tool search result delta.
  const ToolSearchResultDelta({this.result, this.signature});

  /// Parses a partial tool search result.
  factory ToolSearchResultDelta.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'tool_search_result') {
      throw const FormatException(
        'ToolSearchResultDelta: expected type "tool_search_result"',
      );
    }
    return ToolSearchResultDelta(
      result: (json['result'] as List<dynamic>?)?.map((value) {
        if (value is! Map<String, dynamic> || value['type'] != 'function') {
          throw const FormatException(
            'ToolSearchResultDelta: expected a function declaration',
          );
        }
        return FunctionTool.fromJson(value);
      }).toList(),
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (result != null)
      'result': result!.map((function) => function.toJson()).toList(),
    if (signature != null) 'signature': signature,
  };
}
