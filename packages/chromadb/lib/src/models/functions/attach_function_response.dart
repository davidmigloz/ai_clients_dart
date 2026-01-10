import 'package:meta/meta.dart';

import 'attached_function_info.dart';

/// Response from attaching a function to a collection.
@immutable
class AttachFunctionResponse {
  /// Information about the attached function.
  final AttachedFunctionInfo attachedFunction;

  /// Whether this function was newly created (true) or already existed (false).
  final bool created;

  /// Creates an attach function response.
  const AttachFunctionResponse({
    required this.attachedFunction,
    required this.created,
  });

  /// Creates an attach function response from JSON.
  factory AttachFunctionResponse.fromJson(Map<String, dynamic> json) {
    return AttachFunctionResponse(
      attachedFunction: AttachedFunctionInfo.fromJson(
        json['attached_function'] as Map<String, dynamic>,
      ),
      created: json['created'] as bool,
    );
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() {
    return {'attached_function': attachedFunction.toJson(), 'created': created};
  }

  /// Creates a copy with replaced values.
  AttachFunctionResponse copyWith({
    AttachedFunctionInfo? attachedFunction,
    bool? created,
  }) {
    return AttachFunctionResponse(
      attachedFunction: attachedFunction ?? this.attachedFunction,
      created: created ?? this.created,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachFunctionResponse &&
          runtimeType == other.runtimeType &&
          attachedFunction == other.attachedFunction &&
          created == other.created;

  @override
  int get hashCode => Object.hash(attachedFunction, created);

  @override
  String toString() =>
      'AttachFunctionResponse(attachedFunction: $attachedFunction, '
      'created: $created)';
}
