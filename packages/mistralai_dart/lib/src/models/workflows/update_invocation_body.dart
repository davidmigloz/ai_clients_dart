import 'package:meta/meta.dart';

import '../../utils/workflow_call_context.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Body for sending a workflow update.
@immutable
class UpdateInvocationBody {
  /// The update name.
  final String name;

  /// The update input.
  final Object? input;

  /// Cleartext technical IDs and flags passed to the workflow. Never include customer content.
  final Map<String, Object>? callContext;

  /// Creates a [UpdateInvocationBody].
  const UpdateInvocationBody({
    this.callContext,
    required this.name,
    this.input,
  });

  /// Creates a [UpdateInvocationBody] from JSON.
  factory UpdateInvocationBody.fromJson(Map<String, dynamic> json) =>
      UpdateInvocationBody(
        callContext: parseWorkflowCallContext(json['call_context']),
        name: json['name'] as String? ?? '',
        input: json['input'],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (callContext != null)
      'call_context': workflowCallContextToJson(callContext!),
    'name': name,
    if (input != null) 'input': input,
  };

  /// Creates a copy with replaced values.
  UpdateInvocationBody copyWith({
    Object? callContext = unsetCopyWithValue,
    String? name,
    Object? input = unsetCopyWithValue,
  }) {
    return UpdateInvocationBody(
      callContext: callContext == unsetCopyWithValue
          ? this.callContext
          : callContext as Map<String, Object>?,
      name: name ?? this.name,
      input: input == unsetCopyWithValue ? this.input : input,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UpdateInvocationBody) return false;
    if (runtimeType != other.runtimeType) return false;
    return mapsEqual(callContext, other.callContext) &&
        name == other.name &&
        valuesDeepEqual(input, other.input);
  }

  @override
  int get hashCode =>
      Object.hashAll([name, valueDeepHashCode(input), mapHash(callContext)]);

  @override
  String toString() =>
      'UpdateInvocationBody(callContext: ${callContext?.length}, name: $name, input: $input)';
}
