import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Body for sending a workflow signal.
@immutable
class SignalInvocationBody {
  /// The signal name.
  final String name;

  /// The signal input.
  final Object? input;

  /// Creates a [SignalInvocationBody].
  const SignalInvocationBody({required this.name, this.input});

  /// Creates a [SignalInvocationBody] from JSON.
  factory SignalInvocationBody.fromJson(Map<String, dynamic> json) =>
      SignalInvocationBody(
        name: json['name'] as String? ?? '',
        input: json['input'],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (input != null) 'input': input,
  };

  /// Creates a copy with replaced values.
  SignalInvocationBody copyWith({
    String? name,
    Object? input = unsetCopyWithValue,
  }) {
    return SignalInvocationBody(
      name: name ?? this.name,
      input: input == unsetCopyWithValue ? this.input : input,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SignalInvocationBody) return false;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name && valuesDeepEqual(input, other.input);
  }

  @override
  int get hashCode => Object.hash(name, valueDeepHashCode(input));

  @override
  String toString() => 'SignalInvocationBody(name: $name, input: $input)';
}
