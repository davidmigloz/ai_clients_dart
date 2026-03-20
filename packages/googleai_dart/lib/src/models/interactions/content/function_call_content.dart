part of 'content.dart';

/// A function tool call content block.
class FunctionCallContent extends InteractionContent {
  @override
  String get type => 'function_call';

  /// A unique ID for this specific tool call.
  final String? id;

  /// The name of the tool to call.
  final String? name;

  /// The arguments to pass to the function.
  final Map<String, dynamic>? arguments;

  /// The signature of the function call.
  final String? signature;

  /// Creates a [FunctionCallContent] instance.
  const FunctionCallContent({
    this.id,
    this.name,
    this.arguments,
    this.signature,
  });

  /// Creates a [FunctionCallContent] from JSON.
  factory FunctionCallContent.fromJson(Map<String, dynamic> json) =>
      FunctionCallContent(
        id: json['id'] as String?,
        name: json['name'] as String?,
        arguments: json['arguments'] as Map<String, dynamic>?,
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (arguments != null) 'arguments': arguments,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  FunctionCallContent copyWith({
    Object? id = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? arguments = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return FunctionCallContent(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      arguments: arguments == unsetCopyWithValue
          ? this.arguments
          : arguments as Map<String, dynamic>?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
