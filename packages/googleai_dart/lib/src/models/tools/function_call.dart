import '../copy_with_sentinel.dart';

/// A predicted function call returned from the model.
class FunctionCall {
  /// Optional unique ID of the function call for correlation.
  ///
  /// Used in Live API sessions to match tool call responses to requests
  /// and to identify calls in cancellation messages.
  final String? id;

  final String? _name;

  /// The name of the function to call.
  ///
  /// Returns an empty string on a streamed fragment that omits the name.
  String get name => _name ?? '';

  /// The function parameters and values.
  final Map<String, dynamic>? args;

  /// Argument fragments from a Vertex AI GenerateContent stream.
  final List<FunctionCallPartialArg>? partialArgs;

  /// Whether further fragments for this function call are expected.
  final bool? willContinue;

  /// Creates a [FunctionCall].
  const FunctionCall({
    this.id,
    this._name,
    this.args,
    this.partialArgs,
    this.willContinue,
  });

  /// Creates a [FunctionCall] from JSON.
  factory FunctionCall.fromJson(Map<String, dynamic> json) => FunctionCall(
    id: json['id'] as String?,
    name: json['name'] as String?,
    args: json['args'] as Map<String, dynamic>?,
    partialArgs: (json['partialArgs'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>()
        .map(FunctionCallPartialArg.fromJson)
        .toList(),
    willContinue: json['willContinue'] as bool?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': ?_name,
    'args': ?args,
    if (partialArgs != null)
      'partialArgs': partialArgs!.map((argument) => argument.toJson()).toList(),
    'willContinue': ?willContinue,
  };

  /// Creates a copy with replaced values.
  FunctionCall copyWith({
    Object? id = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? args = unsetCopyWithValue,
    Object? partialArgs = unsetCopyWithValue,
    Object? willContinue = unsetCopyWithValue,
  }) {
    return FunctionCall(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      name: name == unsetCopyWithValue ? _name : name as String?,
      args: args == unsetCopyWithValue
          ? this.args
          : args as Map<String, dynamic>?,
      partialArgs: partialArgs == unsetCopyWithValue
          ? this.partialArgs
          : partialArgs as List<FunctionCallPartialArg>?,
      willContinue: willContinue == unsetCopyWithValue
          ? this.willContinue
          : willContinue as bool?,
    );
  }
}

/// A single argument fragment in a Vertex AI function call stream.
class FunctionCallPartialArg {
  /// JSONPath to this fragment's value in the complete argument object.
  final String jsonPath;

  /// Boolean value reported for this fragment.
  final bool? boolValue;

  /// Numeric value reported for this fragment.
  final num? numberValue;

  /// String value or string segment reported for this fragment.
  final String? stringValue;

  /// Null marker reported by providers that send the literal `NULL_VALUE`.
  final String? nullValue;

  final bool _hasNullValue;

  /// Whether the response explicitly contains a null value marker.
  bool get hasNullValue => _hasNullValue || nullValue != null;

  /// Whether more string segments for this path are expected.
  final bool? willContinue;

  /// Creates a [FunctionCallPartialArg].
  const FunctionCallPartialArg({
    required this.jsonPath,
    this.boolValue,
    this.numberValue,
    this.stringValue,
    this.nullValue,
    this._hasNullValue = false,
    this.willContinue,
  });

  /// Creates an argument fragment from JSON.
  factory FunctionCallPartialArg.fromJson(Map<String, dynamic> json) =>
      FunctionCallPartialArg(
        jsonPath: json['jsonPath'] as String,
        boolValue: json['boolValue'] as bool?,
        numberValue: json['numberValue'] as num?,
        stringValue: json['stringValue'] as String?,
        nullValue: json['nullValue'] as String?,
        hasNullValue: json.containsKey('nullValue'),
        willContinue: json['willContinue'] as bool?,
      );

  /// Converts this fragment to JSON.
  Map<String, dynamic> toJson() => {
    'jsonPath': jsonPath,
    'boolValue': ?boolValue,
    'numberValue': ?numberValue,
    'stringValue': ?stringValue,
    if (hasNullValue) 'nullValue': nullValue,
    'willContinue': ?willContinue,
  };

  /// Creates a copy with replaced values.
  FunctionCallPartialArg copyWith({
    String? jsonPath,
    Object? boolValue = unsetCopyWithValue,
    Object? numberValue = unsetCopyWithValue,
    Object? stringValue = unsetCopyWithValue,
    Object? nullValue = unsetCopyWithValue,
    bool? hasNullValue,
    Object? willContinue = unsetCopyWithValue,
  }) => FunctionCallPartialArg(
    jsonPath: jsonPath ?? this.jsonPath,
    boolValue: boolValue == unsetCopyWithValue
        ? this.boolValue
        : boolValue as bool?,
    numberValue: numberValue == unsetCopyWithValue
        ? this.numberValue
        : numberValue as num?,
    stringValue: stringValue == unsetCopyWithValue
        ? this.stringValue
        : stringValue as String?,
    nullValue: nullValue == unsetCopyWithValue
        ? this.nullValue
        : nullValue as String?,
    hasNullValue: hasNullValue ?? _hasNullValue,
    willContinue: willContinue == unsetCopyWithValue
        ? this.willContinue
        : willContinue as bool?,
  );
}
