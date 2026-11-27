part of 'steps.dart';

/// The definitions loaded by a server-side tool search.
class ToolSearchResultStep extends InteractionStep {
  @override
  String get type => 'tool_search_result';

  /// The corresponding [ToolSearchCallStep.id].
  final String callId;

  /// The retrieved function definitions, when present.
  final List<FunctionTool>? result;

  /// Opaque server signature to preserve when replaying step history.
  final String? signature;

  /// Creates a tool search result.
  const ToolSearchResultStep({
    required this.callId,
    this.result,
    this.signature,
  });

  /// Parses the result of a server-side search.
  factory ToolSearchResultStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'tool_search_result') {
      throw const FormatException(
        'ToolSearchResultStep: expected type "tool_search_result"',
      );
    }
    final callId = json['call_id'];
    if (callId is! String) {
      throw const FormatException(
        'ToolSearchResultStep: missing required "call_id"',
      );
    }
    return ToolSearchResultStep(
      callId: callId,
      result: (json['result'] as List<dynamic>?)?.map((value) {
        if (value is! Map<String, dynamic> || value['type'] != 'function') {
          throw const FormatException(
            'ToolSearchResultStep: expected a function declaration',
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
    'call_id': callId,
    if (result != null)
      'result': result!.map((function) => function.toJson()).toList(),
    if (signature != null) 'signature': signature,
  };
}
