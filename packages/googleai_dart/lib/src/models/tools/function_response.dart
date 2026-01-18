import '../copy_with_sentinel.dart';

/// Scheduling options for function responses.
enum FunctionResponseScheduling {
  /// Unspecified scheduling.
  schedulingUnspecified,

  /// Only add the result to the conversation context, do not interrupt or
  /// trigger generation.
  silent,

  /// Add the result to the conversation context, and prompt to generate output
  /// without interrupting ongoing generation.
  whenIdle,

  /// Add the result to the conversation context, interrupt ongoing generation
  /// and prompt to generate output.
  interrupt;

  /// Creates a [FunctionResponseScheduling] from JSON.
  factory FunctionResponseScheduling.fromJson(String value) => switch (value) {
    'SCHEDULING_UNSPECIFIED' => schedulingUnspecified,
    'SILENT' => silent,
    'WHEN_IDLE' => whenIdle,
    'INTERRUPT' => interrupt,
    _ => throw FormatException('Unknown FunctionResponseScheduling: $value'),
  };

  /// Converts to JSON.
  String toJson() => switch (this) {
    schedulingUnspecified => 'SCHEDULING_UNSPECIFIED',
    silent => 'SILENT',
    whenIdle => 'WHEN_IDLE',
    interrupt => 'INTERRUPT',
  };
}

/// Raw media bytes for function response.
class FunctionResponseBlob {
  /// The IANA standard MIME type of the source data.
  final String? mimeType;

  /// Raw bytes for media formats (base64 encoded).
  final String? data;

  /// Creates a [FunctionResponseBlob].
  const FunctionResponseBlob({this.mimeType, this.data});

  /// Creates a [FunctionResponseBlob] from JSON.
  factory FunctionResponseBlob.fromJson(Map<String, dynamic> json) =>
      FunctionResponseBlob(
        mimeType: json['mimeType'] as String?,
        data: json['data'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (mimeType != null) 'mimeType': mimeType,
    if (data != null) 'data': data,
  };

  /// Creates a copy with replaced values.
  FunctionResponseBlob copyWith({
    Object? mimeType = unsetCopyWithValue,
    Object? data = unsetCopyWithValue,
  }) {
    return FunctionResponseBlob(
      mimeType: mimeType == unsetCopyWithValue
          ? this.mimeType
          : mimeType as String?,
      data: data == unsetCopyWithValue ? this.data : data as String?,
    );
  }
}

/// A datatype containing media that is part of a FunctionResponse message.
///
/// Note: This is different from `FunctionResponsePart` in part.dart which
/// wraps a complete FunctionResponse. This class represents inline data
/// within a FunctionResponse.
class FunctionResponseInlinePart {
  /// Inline media bytes.
  final FunctionResponseBlob? inlineData;

  /// Creates a [FunctionResponseInlinePart].
  const FunctionResponseInlinePart({this.inlineData});

  /// Creates a [FunctionResponseInlinePart] from JSON.
  factory FunctionResponseInlinePart.fromJson(Map<String, dynamic> json) =>
      FunctionResponseInlinePart(
        inlineData: json['inlineData'] != null
            ? FunctionResponseBlob.fromJson(
                json['inlineData'] as Map<String, dynamic>,
              )
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (inlineData != null) 'inlineData': inlineData!.toJson(),
  };

  /// Creates a copy with replaced values.
  FunctionResponseInlinePart copyWith({
    Object? inlineData = unsetCopyWithValue,
  }) {
    return FunctionResponseInlinePart(
      inlineData: inlineData == unsetCopyWithValue
          ? this.inlineData
          : inlineData as FunctionResponseBlob?,
    );
  }
}

/// The result output from a function call.
class FunctionResponse {
  /// Optional ID of the function call this response is for.
  ///
  /// Used in Live API sessions to correlate responses with the original
  /// function call requests. Should match the [FunctionCall.id] of the
  /// call being responded to.
  final String? id;

  /// The name of the function that was called.
  final String name;

  /// The function response.
  final Map<String, dynamic> response;

  /// Ordered parts that constitute the function response.
  final List<FunctionResponseInlinePart>? parts;

  /// Signals that function call continues as a generator.
  final bool? willContinue;

  /// Specifies how the response should be scheduled in the conversation.
  final FunctionResponseScheduling? scheduling;

  /// Creates a [FunctionResponse].
  const FunctionResponse({
    this.id,
    required this.name,
    required this.response,
    this.parts,
    this.willContinue,
    this.scheduling,
  });

  /// Creates a [FunctionResponse] from JSON.
  factory FunctionResponse.fromJson(Map<String, dynamic> json) =>
      FunctionResponse(
        id: json['id'] as String?,
        name: json['name'] as String,
        response: json['response'] as Map<String, dynamic>,
        parts: (json['parts'] as List?)
            ?.map(
              (e) => FunctionResponseInlinePart.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
        willContinue: json['willContinue'] as bool?,
        scheduling: json['scheduling'] != null
            ? FunctionResponseScheduling.fromJson(json['scheduling'] as String)
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'response': response,
    if (parts != null) 'parts': parts!.map((e) => e.toJson()).toList(),
    if (willContinue != null) 'willContinue': willContinue,
    if (scheduling != null) 'scheduling': scheduling!.toJson(),
  };

  /// Creates a copy with replaced values.
  FunctionResponse copyWith({
    Object? id = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? response = unsetCopyWithValue,
    Object? parts = unsetCopyWithValue,
    Object? willContinue = unsetCopyWithValue,
    Object? scheduling = unsetCopyWithValue,
  }) {
    return FunctionResponse(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      name: name == unsetCopyWithValue ? this.name : name! as String,
      response: response == unsetCopyWithValue
          ? this.response
          : response! as Map<String, dynamic>,
      parts: parts == unsetCopyWithValue
          ? this.parts
          : parts as List<FunctionResponseInlinePart>?,
      willContinue: willContinue == unsetCopyWithValue
          ? this.willContinue
          : willContinue as bool?,
      scheduling: scheduling == unsetCopyWithValue
          ? this.scheduling
          : scheduling as FunctionResponseScheduling?,
    );
  }
}
