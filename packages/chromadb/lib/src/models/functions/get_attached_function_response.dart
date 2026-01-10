import 'package:meta/meta.dart' show immutable;

import 'attached_function.dart';

/// Response from getting an attached function.
@immutable
class GetAttachedFunctionResponse {
  /// The attached function details.
  final AttachedFunction attachedFunction;

  /// Creates a get attached function response.
  const GetAttachedFunctionResponse({required this.attachedFunction});

  /// Creates a response from JSON.
  factory GetAttachedFunctionResponse.fromJson(Map<String, dynamic> json) {
    return GetAttachedFunctionResponse(
      attachedFunction: AttachedFunction.fromJson(
        json['attached_function'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() {
    return {'attached_function': attachedFunction.toJson()};
  }

  /// Creates a copy with replaced values.
  GetAttachedFunctionResponse copyWith({AttachedFunction? attachedFunction}) {
    return GetAttachedFunctionResponse(
      attachedFunction: attachedFunction ?? this.attachedFunction,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetAttachedFunctionResponse &&
          runtimeType == other.runtimeType &&
          attachedFunction == other.attachedFunction;

  @override
  int get hashCode => attachedFunction.hashCode;

  @override
  String toString() =>
      'GetAttachedFunctionResponse(attachedFunction: $attachedFunction)';
}
