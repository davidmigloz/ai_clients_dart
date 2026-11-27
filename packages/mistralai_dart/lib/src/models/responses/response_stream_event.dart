import 'package:meta/meta.dart';

import '../../utils/additional_json_fields.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'response.dart';
import 'response_content.dart';
import 'response_item.dart';

/// A ResponseStreamEvent variant.
///
/// [ResponseStreamErrorEvent], [ResponseCompletedEvent], [ResponseContentPartAddedEvent], [ResponseContentPartDoneEvent], [ResponseCreatedEvent], [ResponseFailedEvent], [ResponseFunctionArgumentsDeltaEvent], [ResponseFunctionArgumentsDoneEvent], [ResponseInProgressEvent], [ResponseIncompleteEvent], [ResponseOutputItemAddedEvent], [ResponseOutputItemDoneEvent], [ResponseTextDeltaEvent], [ResponseTextDoneEvent], [ResponseReasoningTextDeltaEvent], [ResponseReasoningTextDoneEvent], or [UnknownResponseStreamEvent].
@immutable
sealed class ResponseStreamEvent {
  const ResponseStreamEvent();

  /// Parses an API payload.
  factory ResponseStreamEvent.fromJson(
    Map<String, dynamic> json,
  ) => switch (json['type']) {
    'error' => ResponseStreamErrorEvent.fromJson(json),
    'response.completed' => ResponseCompletedEvent.fromJson(json),
    'response.content_part.added' => ResponseContentPartAddedEvent.fromJson(
      json,
    ),
    'response.content_part.done' => ResponseContentPartDoneEvent.fromJson(json),
    'response.created' => ResponseCreatedEvent.fromJson(json),
    'response.failed' => ResponseFailedEvent.fromJson(json),
    'response.function_call_arguments.delta' =>
      ResponseFunctionArgumentsDeltaEvent.fromJson(json),
    'response.function_call_arguments.done' =>
      ResponseFunctionArgumentsDoneEvent.fromJson(json),
    'response.in_progress' => ResponseInProgressEvent.fromJson(json),
    'response.incomplete' => ResponseIncompleteEvent.fromJson(json),
    'response.output_item.added' => ResponseOutputItemAddedEvent.fromJson(json),
    'response.output_item.done' => ResponseOutputItemDoneEvent.fromJson(json),
    'response.output_text.delta' => ResponseTextDeltaEvent.fromJson(json),
    'response.output_text.done' => ResponseTextDoneEvent.fromJson(json),
    'response.reasoning_text.delta' => ResponseReasoningTextDeltaEvent.fromJson(
      json,
    ),
    'response.reasoning_text.done' => ResponseReasoningTextDoneEvent.fromJson(
      json,
    ),
    _ => UnknownResponseStreamEvent(json),
  };

  /// The wire event name, if the server included one.
  String? get type;

  /// The event's sequence number, if available.
  int? get sequenceNumber;

  /// Encodes the wire object.
  Map<String, dynamic> toJson();
}

/// A future ResponseStreamEvent value.
@immutable
final class UnknownResponseStreamEvent extends ResponseStreamEvent {
  /// Creates a fallback from the original payload.
  UnknownResponseStreamEvent(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  String? get type => raw['type'] is String ? raw['type'] as String : null;

  @override
  int? get sequenceNumber =>
      raw['sequence_number'] is int ? raw['sequence_number'] as int : null;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownResponseStreamEvent && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// The ResponsesErrorEvent wire payload.
@immutable
class ResponseStreamErrorEvent extends ResponseStreamEvent {
  /// Creates a [ResponseStreamErrorEvent].
  const ResponseStreamErrorEvent({
    this.code,
    required this.message,
    this.param,
    required this.sequenceNumber,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'error';

  /// The code field.
  final String? code;

  /// The message field.
  final String message;

  /// The param field.
  final String? param;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseStreamErrorEvent] from JSON.
  factory ResponseStreamErrorEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'error') {
      throw FormatException('ResponseStreamErrorEvent: unexpected type $value');
    }
    if (json['message'] == null) {
      throw const FormatException('ResponseStreamErrorEvent: missing message');
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseStreamErrorEvent: missing sequence_number',
      );
    }
    return ResponseStreamErrorEvent(
      code: json['code'] == null ? null : json['code'] as String,
      message: json['message'] as String,
      param: json['param'] == null ? null : json['param'] as String,
      sequenceNumber: json['sequence_number'] as int,
      extra: additionalJsonFields(json, const {
        'code',
        'message',
        'param',
        'sequence_number',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'code': ?code,
    'message': message,
    'param': ?param,
    'sequence_number': sequenceNumber,
  };

  /// Creates a copy with the given fields replaced.
  ResponseStreamErrorEvent copyWith({
    Object? code = unsetCopyWithValue,
    String? message,
    Object? param = unsetCopyWithValue,
    int? sequenceNumber,
    Object? extra = unsetCopyWithValue,
  }) => ResponseStreamErrorEvent(
    code: code == unsetCopyWithValue ? this.code : code as String?,
    message: message ?? this.message,
    param: param == unsetCopyWithValue ? this.param : param as String?,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseStreamErrorEvent &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          param == other.param &&
          sequenceNumber == other.sequenceNumber &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    code,
    message,
    param,
    sequenceNumber,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseStreamErrorEvent('
      'code: $code, '
      'message: $message, '
      'param: $param, '
      'sequenceNumber: $sequenceNumber, '
      'extra: ${extra?.length})';
}

/// The ResponsesCompletedEvent wire payload.
@immutable
class ResponseCompletedEvent extends ResponseStreamEvent {
  /// Creates a [ResponseCompletedEvent].
  const ResponseCompletedEvent({
    required this.response,
    required this.sequenceNumber,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'response.completed';

  /// The response field.
  final MistralResponse response;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseCompletedEvent] from JSON.
  factory ResponseCompletedEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'response.completed') {
      throw FormatException('ResponseCompletedEvent: unexpected type $value');
    }
    if (json['response'] == null) {
      throw const FormatException('ResponseCompletedEvent: missing response');
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseCompletedEvent: missing sequence_number',
      );
    }
    return ResponseCompletedEvent(
      response: MistralResponse.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
      sequenceNumber: json['sequence_number'] as int,
      extra: additionalJsonFields(json, const {
        'response',
        'sequence_number',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'response': response.toJson(),
    'sequence_number': sequenceNumber,
  };

  /// Creates a copy with the given fields replaced.
  ResponseCompletedEvent copyWith({
    MistralResponse? response,
    int? sequenceNumber,
    Object? extra = unsetCopyWithValue,
  }) => ResponseCompletedEvent(
    response: response ?? this.response,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCompletedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode =>
      Object.hashAll([response, sequenceNumber, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseCompletedEvent('
      'response: $response, '
      'sequenceNumber: $sequenceNumber, '
      'extra: ${extra?.length})';
}

/// The ResponsesContentPartAddedEvent wire payload.
@immutable
class ResponseContentPartAddedEvent extends ResponseStreamEvent {
  /// Creates a [ResponseContentPartAddedEvent].
  const ResponseContentPartAddedEvent({
    required this.contentIndex,
    required this.itemId,
    required this.outputIndex,
    required this.part,
    required this.sequenceNumber,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'response.content_part.added';

  /// The content_index field.
  final int contentIndex;

  /// The item_id field.
  final String itemId;

  /// The output_index field.
  final int outputIndex;

  /// The part field.
  final ResponseOutputPart part;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseContentPartAddedEvent] from JSON.
  factory ResponseContentPartAddedEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value?
        when value != 'response.content_part.added') {
      throw FormatException(
        'ResponseContentPartAddedEvent: unexpected type $value',
      );
    }
    if (json['content_index'] == null) {
      throw const FormatException(
        'ResponseContentPartAddedEvent: missing content_index',
      );
    }
    if (json['item_id'] == null) {
      throw const FormatException(
        'ResponseContentPartAddedEvent: missing item_id',
      );
    }
    if (json['output_index'] == null) {
      throw const FormatException(
        'ResponseContentPartAddedEvent: missing output_index',
      );
    }
    if (json['part'] == null) {
      throw const FormatException(
        'ResponseContentPartAddedEvent: missing part',
      );
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseContentPartAddedEvent: missing sequence_number',
      );
    }
    return ResponseContentPartAddedEvent(
      contentIndex: json['content_index'] as int,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      part: ResponseOutputPart.fromJson(json['part'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int,
      extra: additionalJsonFields(json, const {
        'content_index',
        'item_id',
        'output_index',
        'part',
        'sequence_number',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'content_index': contentIndex,
    'item_id': itemId,
    'output_index': outputIndex,
    'part': part.toJson(),
    'sequence_number': sequenceNumber,
  };

  /// Creates a copy with the given fields replaced.
  ResponseContentPartAddedEvent copyWith({
    int? contentIndex,
    String? itemId,
    int? outputIndex,
    ResponseOutputPart? part,
    int? sequenceNumber,
    Object? extra = unsetCopyWithValue,
  }) => ResponseContentPartAddedEvent(
    contentIndex: contentIndex ?? this.contentIndex,
    itemId: itemId ?? this.itemId,
    outputIndex: outputIndex ?? this.outputIndex,
    part: part ?? this.part,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseContentPartAddedEvent &&
          runtimeType == other.runtimeType &&
          contentIndex == other.contentIndex &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          part == other.part &&
          sequenceNumber == other.sequenceNumber &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    contentIndex,
    itemId,
    outputIndex,
    part,
    sequenceNumber,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseContentPartAddedEvent('
      'contentIndex: $contentIndex, '
      'itemId: $itemId, '
      'outputIndex: $outputIndex, '
      'part: $part, '
      'sequenceNumber: $sequenceNumber, '
      'extra: ${extra?.length})';
}

/// The ResponsesContentPartDoneEvent wire payload.
@immutable
class ResponseContentPartDoneEvent extends ResponseStreamEvent {
  /// Creates a [ResponseContentPartDoneEvent].
  const ResponseContentPartDoneEvent({
    required this.contentIndex,
    required this.itemId,
    required this.outputIndex,
    required this.part,
    required this.sequenceNumber,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'response.content_part.done';

  /// The content_index field.
  final int contentIndex;

  /// The item_id field.
  final String itemId;

  /// The output_index field.
  final int outputIndex;

  /// The part field.
  final ResponseOutputPart part;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseContentPartDoneEvent] from JSON.
  factory ResponseContentPartDoneEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value?
        when value != 'response.content_part.done') {
      throw FormatException(
        'ResponseContentPartDoneEvent: unexpected type $value',
      );
    }
    if (json['content_index'] == null) {
      throw const FormatException(
        'ResponseContentPartDoneEvent: missing content_index',
      );
    }
    if (json['item_id'] == null) {
      throw const FormatException(
        'ResponseContentPartDoneEvent: missing item_id',
      );
    }
    if (json['output_index'] == null) {
      throw const FormatException(
        'ResponseContentPartDoneEvent: missing output_index',
      );
    }
    if (json['part'] == null) {
      throw const FormatException('ResponseContentPartDoneEvent: missing part');
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseContentPartDoneEvent: missing sequence_number',
      );
    }
    return ResponseContentPartDoneEvent(
      contentIndex: json['content_index'] as int,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      part: ResponseOutputPart.fromJson(json['part'] as Map<String, dynamic>),
      sequenceNumber: json['sequence_number'] as int,
      extra: additionalJsonFields(json, const {
        'content_index',
        'item_id',
        'output_index',
        'part',
        'sequence_number',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'content_index': contentIndex,
    'item_id': itemId,
    'output_index': outputIndex,
    'part': part.toJson(),
    'sequence_number': sequenceNumber,
  };

  /// Creates a copy with the given fields replaced.
  ResponseContentPartDoneEvent copyWith({
    int? contentIndex,
    String? itemId,
    int? outputIndex,
    ResponseOutputPart? part,
    int? sequenceNumber,
    Object? extra = unsetCopyWithValue,
  }) => ResponseContentPartDoneEvent(
    contentIndex: contentIndex ?? this.contentIndex,
    itemId: itemId ?? this.itemId,
    outputIndex: outputIndex ?? this.outputIndex,
    part: part ?? this.part,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseContentPartDoneEvent &&
          runtimeType == other.runtimeType &&
          contentIndex == other.contentIndex &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          part == other.part &&
          sequenceNumber == other.sequenceNumber &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    contentIndex,
    itemId,
    outputIndex,
    part,
    sequenceNumber,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseContentPartDoneEvent('
      'contentIndex: $contentIndex, '
      'itemId: $itemId, '
      'outputIndex: $outputIndex, '
      'part: $part, '
      'sequenceNumber: $sequenceNumber, '
      'extra: ${extra?.length})';
}

/// The ResponsesCreatedEvent wire payload.
@immutable
class ResponseCreatedEvent extends ResponseStreamEvent {
  /// Creates a [ResponseCreatedEvent].
  const ResponseCreatedEvent({
    required this.response,
    required this.sequenceNumber,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'response.created';

  /// The response field.
  final MistralResponse response;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseCreatedEvent] from JSON.
  factory ResponseCreatedEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'response.created') {
      throw FormatException('ResponseCreatedEvent: unexpected type $value');
    }
    if (json['response'] == null) {
      throw const FormatException('ResponseCreatedEvent: missing response');
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseCreatedEvent: missing sequence_number',
      );
    }
    return ResponseCreatedEvent(
      response: MistralResponse.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
      sequenceNumber: json['sequence_number'] as int,
      extra: additionalJsonFields(json, const {
        'response',
        'sequence_number',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'response': response.toJson(),
    'sequence_number': sequenceNumber,
  };

  /// Creates a copy with the given fields replaced.
  ResponseCreatedEvent copyWith({
    MistralResponse? response,
    int? sequenceNumber,
    Object? extra = unsetCopyWithValue,
  }) => ResponseCreatedEvent(
    response: response ?? this.response,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCreatedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode =>
      Object.hashAll([response, sequenceNumber, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseCreatedEvent('
      'response: $response, '
      'sequenceNumber: $sequenceNumber, '
      'extra: ${extra?.length})';
}

/// The ResponsesFailedEvent wire payload.
@immutable
class ResponseFailedEvent extends ResponseStreamEvent {
  /// Creates a [ResponseFailedEvent].
  const ResponseFailedEvent({
    required this.response,
    required this.sequenceNumber,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'response.failed';

  /// The response field.
  final MistralResponse response;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseFailedEvent] from JSON.
  factory ResponseFailedEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'response.failed') {
      throw FormatException('ResponseFailedEvent: unexpected type $value');
    }
    if (json['response'] == null) {
      throw const FormatException('ResponseFailedEvent: missing response');
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseFailedEvent: missing sequence_number',
      );
    }
    return ResponseFailedEvent(
      response: MistralResponse.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
      sequenceNumber: json['sequence_number'] as int,
      extra: additionalJsonFields(json, const {
        'response',
        'sequence_number',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'response': response.toJson(),
    'sequence_number': sequenceNumber,
  };

  /// Creates a copy with the given fields replaced.
  ResponseFailedEvent copyWith({
    MistralResponse? response,
    int? sequenceNumber,
    Object? extra = unsetCopyWithValue,
  }) => ResponseFailedEvent(
    response: response ?? this.response,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFailedEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode =>
      Object.hashAll([response, sequenceNumber, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseFailedEvent('
      'response: $response, '
      'sequenceNumber: $sequenceNumber, '
      'extra: ${extra?.length})';
}

/// The ResponsesFunctionCallArgumentsDeltaEvent wire payload.
@immutable
class ResponseFunctionArgumentsDeltaEvent extends ResponseStreamEvent {
  /// Creates a [ResponseFunctionArgumentsDeltaEvent].
  const ResponseFunctionArgumentsDeltaEvent({
    required this.delta,
    required this.itemId,
    required this.outputIndex,
    required this.sequenceNumber,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'response.function_call_arguments.delta';

  /// The delta field.
  final String delta;

  /// The item_id field.
  final String itemId;

  /// The output_index field.
  final int outputIndex;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseFunctionArgumentsDeltaEvent] from JSON.
  factory ResponseFunctionArgumentsDeltaEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['type'] case final value?
        when value != 'response.function_call_arguments.delta') {
      throw FormatException(
        'ResponseFunctionArgumentsDeltaEvent: unexpected type $value',
      );
    }
    if (json['delta'] == null) {
      throw const FormatException(
        'ResponseFunctionArgumentsDeltaEvent: missing delta',
      );
    }
    if (json['item_id'] == null) {
      throw const FormatException(
        'ResponseFunctionArgumentsDeltaEvent: missing item_id',
      );
    }
    if (json['output_index'] == null) {
      throw const FormatException(
        'ResponseFunctionArgumentsDeltaEvent: missing output_index',
      );
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseFunctionArgumentsDeltaEvent: missing sequence_number',
      );
    }
    return ResponseFunctionArgumentsDeltaEvent(
      delta: json['delta'] as String,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int,
      extra: additionalJsonFields(json, const {
        'delta',
        'item_id',
        'output_index',
        'sequence_number',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'delta': delta,
    'item_id': itemId,
    'output_index': outputIndex,
    'sequence_number': sequenceNumber,
  };

  /// Creates a copy with the given fields replaced.
  ResponseFunctionArgumentsDeltaEvent copyWith({
    String? delta,
    String? itemId,
    int? outputIndex,
    int? sequenceNumber,
    Object? extra = unsetCopyWithValue,
  }) => ResponseFunctionArgumentsDeltaEvent(
    delta: delta ?? this.delta,
    itemId: itemId ?? this.itemId,
    outputIndex: outputIndex ?? this.outputIndex,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFunctionArgumentsDeltaEvent &&
          runtimeType == other.runtimeType &&
          delta == other.delta &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    delta,
    itemId,
    outputIndex,
    sequenceNumber,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseFunctionArgumentsDeltaEvent('
      'delta: $delta, '
      'itemId: $itemId, '
      'outputIndex: $outputIndex, '
      'sequenceNumber: $sequenceNumber, '
      'extra: ${extra?.length})';
}

/// The ResponsesFunctionCallArgumentsDoneEvent wire payload.
@immutable
class ResponseFunctionArgumentsDoneEvent extends ResponseStreamEvent {
  /// Creates a [ResponseFunctionArgumentsDoneEvent].
  const ResponseFunctionArgumentsDoneEvent({
    required this.arguments,
    required this.itemId,
    required this.outputIndex,
    required this.sequenceNumber,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'response.function_call_arguments.done';

  /// The arguments field.
  final String arguments;

  /// The item_id field.
  final String itemId;

  /// The output_index field.
  final int outputIndex;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseFunctionArgumentsDoneEvent] from JSON.
  factory ResponseFunctionArgumentsDoneEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['type'] case final value?
        when value != 'response.function_call_arguments.done') {
      throw FormatException(
        'ResponseFunctionArgumentsDoneEvent: unexpected type $value',
      );
    }
    if (json['arguments'] == null) {
      throw const FormatException(
        'ResponseFunctionArgumentsDoneEvent: missing arguments',
      );
    }
    if (json['item_id'] == null) {
      throw const FormatException(
        'ResponseFunctionArgumentsDoneEvent: missing item_id',
      );
    }
    if (json['output_index'] == null) {
      throw const FormatException(
        'ResponseFunctionArgumentsDoneEvent: missing output_index',
      );
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseFunctionArgumentsDoneEvent: missing sequence_number',
      );
    }
    return ResponseFunctionArgumentsDoneEvent(
      arguments: json['arguments'] as String,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int,
      extra: additionalJsonFields(json, const {
        'arguments',
        'item_id',
        'output_index',
        'sequence_number',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'arguments': arguments,
    'item_id': itemId,
    'output_index': outputIndex,
    'sequence_number': sequenceNumber,
  };

  /// Creates a copy with the given fields replaced.
  ResponseFunctionArgumentsDoneEvent copyWith({
    String? arguments,
    String? itemId,
    int? outputIndex,
    int? sequenceNumber,
    Object? extra = unsetCopyWithValue,
  }) => ResponseFunctionArgumentsDoneEvent(
    arguments: arguments ?? this.arguments,
    itemId: itemId ?? this.itemId,
    outputIndex: outputIndex ?? this.outputIndex,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFunctionArgumentsDoneEvent &&
          runtimeType == other.runtimeType &&
          arguments == other.arguments &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    arguments,
    itemId,
    outputIndex,
    sequenceNumber,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseFunctionArgumentsDoneEvent('
      'arguments: $arguments, '
      'itemId: $itemId, '
      'outputIndex: $outputIndex, '
      'sequenceNumber: $sequenceNumber, '
      'extra: ${extra?.length})';
}

/// The ResponsesInProgressEvent wire payload.
@immutable
class ResponseInProgressEvent extends ResponseStreamEvent {
  /// Creates a [ResponseInProgressEvent].
  const ResponseInProgressEvent({
    required this.response,
    required this.sequenceNumber,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'response.in_progress';

  /// The response field.
  final MistralResponse response;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseInProgressEvent] from JSON.
  factory ResponseInProgressEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'response.in_progress') {
      throw FormatException('ResponseInProgressEvent: unexpected type $value');
    }
    if (json['response'] == null) {
      throw const FormatException('ResponseInProgressEvent: missing response');
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseInProgressEvent: missing sequence_number',
      );
    }
    return ResponseInProgressEvent(
      response: MistralResponse.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
      sequenceNumber: json['sequence_number'] as int,
      extra: additionalJsonFields(json, const {
        'response',
        'sequence_number',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'response': response.toJson(),
    'sequence_number': sequenceNumber,
  };

  /// Creates a copy with the given fields replaced.
  ResponseInProgressEvent copyWith({
    MistralResponse? response,
    int? sequenceNumber,
    Object? extra = unsetCopyWithValue,
  }) => ResponseInProgressEvent(
    response: response ?? this.response,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseInProgressEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode =>
      Object.hashAll([response, sequenceNumber, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseInProgressEvent('
      'response: $response, '
      'sequenceNumber: $sequenceNumber, '
      'extra: ${extra?.length})';
}

/// The ResponsesIncompleteEvent wire payload.
@immutable
class ResponseIncompleteEvent extends ResponseStreamEvent {
  /// Creates a [ResponseIncompleteEvent].
  const ResponseIncompleteEvent({
    required this.response,
    required this.sequenceNumber,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'response.incomplete';

  /// The response field.
  final MistralResponse response;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseIncompleteEvent] from JSON.
  factory ResponseIncompleteEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'response.incomplete') {
      throw FormatException('ResponseIncompleteEvent: unexpected type $value');
    }
    if (json['response'] == null) {
      throw const FormatException('ResponseIncompleteEvent: missing response');
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseIncompleteEvent: missing sequence_number',
      );
    }
    return ResponseIncompleteEvent(
      response: MistralResponse.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
      sequenceNumber: json['sequence_number'] as int,
      extra: additionalJsonFields(json, const {
        'response',
        'sequence_number',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'response': response.toJson(),
    'sequence_number': sequenceNumber,
  };

  /// Creates a copy with the given fields replaced.
  ResponseIncompleteEvent copyWith({
    MistralResponse? response,
    int? sequenceNumber,
    Object? extra = unsetCopyWithValue,
  }) => ResponseIncompleteEvent(
    response: response ?? this.response,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseIncompleteEvent &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          sequenceNumber == other.sequenceNumber &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode =>
      Object.hashAll([response, sequenceNumber, valueDeepHashCode(extra)]);

  @override
  String toString() =>
      'ResponseIncompleteEvent('
      'response: $response, '
      'sequenceNumber: $sequenceNumber, '
      'extra: ${extra?.length})';
}

/// The ResponsesOutputItemAddedEvent wire payload.
@immutable
class ResponseOutputItemAddedEvent extends ResponseStreamEvent {
  /// Creates a [ResponseOutputItemAddedEvent].
  const ResponseOutputItemAddedEvent({
    required this.item,
    required this.outputIndex,
    required this.sequenceNumber,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'response.output_item.added';

  /// The item field.
  final ResponseOutputItem item;

  /// The output_index field.
  final int outputIndex;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseOutputItemAddedEvent] from JSON.
  factory ResponseOutputItemAddedEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value?
        when value != 'response.output_item.added') {
      throw FormatException(
        'ResponseOutputItemAddedEvent: unexpected type $value',
      );
    }
    if (json['item'] == null) {
      throw const FormatException('ResponseOutputItemAddedEvent: missing item');
    }
    if (json['output_index'] == null) {
      throw const FormatException(
        'ResponseOutputItemAddedEvent: missing output_index',
      );
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseOutputItemAddedEvent: missing sequence_number',
      );
    }
    return ResponseOutputItemAddedEvent(
      item: ResponseOutputItem.fromJson(json['item'] as Map<String, dynamic>),
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int,
      extra: additionalJsonFields(json, const {
        'item',
        'output_index',
        'sequence_number',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'item': item.toJson(),
    'output_index': outputIndex,
    'sequence_number': sequenceNumber,
  };

  /// Creates a copy with the given fields replaced.
  ResponseOutputItemAddedEvent copyWith({
    ResponseOutputItem? item,
    int? outputIndex,
    int? sequenceNumber,
    Object? extra = unsetCopyWithValue,
  }) => ResponseOutputItemAddedEvent(
    item: item ?? this.item,
    outputIndex: outputIndex ?? this.outputIndex,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseOutputItemAddedEvent &&
          runtimeType == other.runtimeType &&
          item == other.item &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    item,
    outputIndex,
    sequenceNumber,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseOutputItemAddedEvent('
      'item: $item, '
      'outputIndex: $outputIndex, '
      'sequenceNumber: $sequenceNumber, '
      'extra: ${extra?.length})';
}

/// The ResponsesOutputItemDoneEvent wire payload.
@immutable
class ResponseOutputItemDoneEvent extends ResponseStreamEvent {
  /// Creates a [ResponseOutputItemDoneEvent].
  const ResponseOutputItemDoneEvent({
    required this.item,
    required this.outputIndex,
    required this.sequenceNumber,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'response.output_item.done';

  /// The item field.
  final ResponseOutputItem item;

  /// The output_index field.
  final int outputIndex;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseOutputItemDoneEvent] from JSON.
  factory ResponseOutputItemDoneEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value?
        when value != 'response.output_item.done') {
      throw FormatException(
        'ResponseOutputItemDoneEvent: unexpected type $value',
      );
    }
    if (json['item'] == null) {
      throw const FormatException('ResponseOutputItemDoneEvent: missing item');
    }
    if (json['output_index'] == null) {
      throw const FormatException(
        'ResponseOutputItemDoneEvent: missing output_index',
      );
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseOutputItemDoneEvent: missing sequence_number',
      );
    }
    return ResponseOutputItemDoneEvent(
      item: ResponseOutputItem.fromJson(json['item'] as Map<String, dynamic>),
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int,
      extra: additionalJsonFields(json, const {
        'item',
        'output_index',
        'sequence_number',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'item': item.toJson(),
    'output_index': outputIndex,
    'sequence_number': sequenceNumber,
  };

  /// Creates a copy with the given fields replaced.
  ResponseOutputItemDoneEvent copyWith({
    ResponseOutputItem? item,
    int? outputIndex,
    int? sequenceNumber,
    Object? extra = unsetCopyWithValue,
  }) => ResponseOutputItemDoneEvent(
    item: item ?? this.item,
    outputIndex: outputIndex ?? this.outputIndex,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseOutputItemDoneEvent &&
          runtimeType == other.runtimeType &&
          item == other.item &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    item,
    outputIndex,
    sequenceNumber,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseOutputItemDoneEvent('
      'item: $item, '
      'outputIndex: $outputIndex, '
      'sequenceNumber: $sequenceNumber, '
      'extra: ${extra?.length})';
}

/// The ResponsesTextDeltaEvent wire payload.
@immutable
class ResponseTextDeltaEvent extends ResponseStreamEvent {
  /// Creates a [ResponseTextDeltaEvent].
  const ResponseTextDeltaEvent({
    required this.contentIndex,
    required this.delta,
    required this.itemId,
    required this.logprobs,
    required this.outputIndex,
    required this.sequenceNumber,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'response.output_text.delta';

  /// The content_index field.
  final int contentIndex;

  /// The delta field.
  final String delta;

  /// The item_id field.
  final String itemId;

  /// The logprobs field.
  final List<ResponseStreamTokenLogprob> logprobs;

  /// The output_index field.
  final int outputIndex;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseTextDeltaEvent] from JSON.
  factory ResponseTextDeltaEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value?
        when value != 'response.output_text.delta') {
      throw FormatException('ResponseTextDeltaEvent: unexpected type $value');
    }
    if (json['content_index'] == null) {
      throw const FormatException(
        'ResponseTextDeltaEvent: missing content_index',
      );
    }
    if (json['delta'] == null) {
      throw const FormatException('ResponseTextDeltaEvent: missing delta');
    }
    if (json['item_id'] == null) {
      throw const FormatException('ResponseTextDeltaEvent: missing item_id');
    }
    if (json['logprobs'] == null) {
      throw const FormatException('ResponseTextDeltaEvent: missing logprobs');
    }
    if (json['output_index'] == null) {
      throw const FormatException(
        'ResponseTextDeltaEvent: missing output_index',
      );
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseTextDeltaEvent: missing sequence_number',
      );
    }
    return ResponseTextDeltaEvent(
      contentIndex: json['content_index'] as int,
      delta: json['delta'] as String,
      itemId: json['item_id'] as String,
      logprobs: (json['logprobs'] as List)
          .map(
            (item) => ResponseStreamTokenLogprob.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int,
      extra: additionalJsonFields(json, const {
        'content_index',
        'delta',
        'item_id',
        'logprobs',
        'output_index',
        'sequence_number',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'content_index': contentIndex,
    'delta': delta,
    'item_id': itemId,
    'logprobs': logprobs.map((item) => item.toJson()).toList(),
    'output_index': outputIndex,
    'sequence_number': sequenceNumber,
  };

  /// Creates a copy with the given fields replaced.
  ResponseTextDeltaEvent copyWith({
    int? contentIndex,
    String? delta,
    String? itemId,
    List<ResponseStreamTokenLogprob>? logprobs,
    int? outputIndex,
    int? sequenceNumber,
    Object? extra = unsetCopyWithValue,
  }) => ResponseTextDeltaEvent(
    contentIndex: contentIndex ?? this.contentIndex,
    delta: delta ?? this.delta,
    itemId: itemId ?? this.itemId,
    logprobs: logprobs ?? this.logprobs,
    outputIndex: outputIndex ?? this.outputIndex,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseTextDeltaEvent &&
          runtimeType == other.runtimeType &&
          contentIndex == other.contentIndex &&
          delta == other.delta &&
          itemId == other.itemId &&
          valuesDeepEqual(logprobs, other.logprobs) &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    contentIndex,
    delta,
    itemId,
    valueDeepHashCode(logprobs),
    outputIndex,
    sequenceNumber,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseTextDeltaEvent('
      'contentIndex: $contentIndex, '
      'delta: $delta, '
      'itemId: $itemId, '
      'logprobs: ${logprobs.length}, '
      'outputIndex: $outputIndex, '
      'sequenceNumber: $sequenceNumber, '
      'extra: ${extra?.length})';
}

/// The ResponsesTextDoneEvent wire payload.
@immutable
class ResponseTextDoneEvent extends ResponseStreamEvent {
  /// Creates a [ResponseTextDoneEvent].
  const ResponseTextDoneEvent({
    required this.contentIndex,
    required this.itemId,
    required this.logprobs,
    required this.outputIndex,
    required this.sequenceNumber,
    required this.text,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'response.output_text.done';

  /// The content_index field.
  final int contentIndex;

  /// The item_id field.
  final String itemId;

  /// The logprobs field.
  final List<ResponseStreamTokenLogprob> logprobs;

  /// The output_index field.
  final int outputIndex;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// The text field.
  final String text;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseTextDoneEvent] from JSON.
  factory ResponseTextDoneEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value?
        when value != 'response.output_text.done') {
      throw FormatException('ResponseTextDoneEvent: unexpected type $value');
    }
    if (json['content_index'] == null) {
      throw const FormatException(
        'ResponseTextDoneEvent: missing content_index',
      );
    }
    if (json['item_id'] == null) {
      throw const FormatException('ResponseTextDoneEvent: missing item_id');
    }
    if (json['logprobs'] == null) {
      throw const FormatException('ResponseTextDoneEvent: missing logprobs');
    }
    if (json['output_index'] == null) {
      throw const FormatException(
        'ResponseTextDoneEvent: missing output_index',
      );
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseTextDoneEvent: missing sequence_number',
      );
    }
    if (json['text'] == null) {
      throw const FormatException('ResponseTextDoneEvent: missing text');
    }
    return ResponseTextDoneEvent(
      contentIndex: json['content_index'] as int,
      itemId: json['item_id'] as String,
      logprobs: (json['logprobs'] as List)
          .map(
            (item) => ResponseStreamTokenLogprob.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int,
      text: json['text'] as String,
      extra: additionalJsonFields(json, const {
        'content_index',
        'item_id',
        'logprobs',
        'output_index',
        'sequence_number',
        'text',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'content_index': contentIndex,
    'item_id': itemId,
    'logprobs': logprobs.map((item) => item.toJson()).toList(),
    'output_index': outputIndex,
    'sequence_number': sequenceNumber,
    'text': text,
  };

  /// Creates a copy with the given fields replaced.
  ResponseTextDoneEvent copyWith({
    int? contentIndex,
    String? itemId,
    List<ResponseStreamTokenLogprob>? logprobs,
    int? outputIndex,
    int? sequenceNumber,
    String? text,
    Object? extra = unsetCopyWithValue,
  }) => ResponseTextDoneEvent(
    contentIndex: contentIndex ?? this.contentIndex,
    itemId: itemId ?? this.itemId,
    logprobs: logprobs ?? this.logprobs,
    outputIndex: outputIndex ?? this.outputIndex,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    text: text ?? this.text,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseTextDoneEvent &&
          runtimeType == other.runtimeType &&
          contentIndex == other.contentIndex &&
          itemId == other.itemId &&
          valuesDeepEqual(logprobs, other.logprobs) &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          text == other.text &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    contentIndex,
    itemId,
    valueDeepHashCode(logprobs),
    outputIndex,
    sequenceNumber,
    text,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseTextDoneEvent('
      'contentIndex: $contentIndex, '
      'itemId: $itemId, '
      'logprobs: ${logprobs.length}, '
      'outputIndex: $outputIndex, '
      'sequenceNumber: $sequenceNumber, '
      'text: $text, '
      'extra: ${extra?.length})';
}

/// The ResponsesReasoningTextDeltaEvent wire payload.
@immutable
class ResponseReasoningTextDeltaEvent extends ResponseStreamEvent {
  /// Creates a [ResponseReasoningTextDeltaEvent].
  const ResponseReasoningTextDeltaEvent({
    required this.contentIndex,
    required this.delta,
    required this.itemId,
    required this.outputIndex,
    required this.sequenceNumber,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'response.reasoning_text.delta';

  /// The content_index field.
  final int contentIndex;

  /// The delta field.
  final String delta;

  /// The item_id field.
  final String itemId;

  /// The output_index field.
  final int outputIndex;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseReasoningTextDeltaEvent] from JSON.
  factory ResponseReasoningTextDeltaEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value?
        when value != 'response.reasoning_text.delta') {
      throw FormatException(
        'ResponseReasoningTextDeltaEvent: unexpected type $value',
      );
    }
    if (json['content_index'] == null) {
      throw const FormatException(
        'ResponseReasoningTextDeltaEvent: missing content_index',
      );
    }
    if (json['delta'] == null) {
      throw const FormatException(
        'ResponseReasoningTextDeltaEvent: missing delta',
      );
    }
    if (json['item_id'] == null) {
      throw const FormatException(
        'ResponseReasoningTextDeltaEvent: missing item_id',
      );
    }
    if (json['output_index'] == null) {
      throw const FormatException(
        'ResponseReasoningTextDeltaEvent: missing output_index',
      );
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseReasoningTextDeltaEvent: missing sequence_number',
      );
    }
    return ResponseReasoningTextDeltaEvent(
      contentIndex: json['content_index'] as int,
      delta: json['delta'] as String,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int,
      extra: additionalJsonFields(json, const {
        'content_index',
        'delta',
        'item_id',
        'output_index',
        'sequence_number',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'content_index': contentIndex,
    'delta': delta,
    'item_id': itemId,
    'output_index': outputIndex,
    'sequence_number': sequenceNumber,
  };

  /// Creates a copy with the given fields replaced.
  ResponseReasoningTextDeltaEvent copyWith({
    int? contentIndex,
    String? delta,
    String? itemId,
    int? outputIndex,
    int? sequenceNumber,
    Object? extra = unsetCopyWithValue,
  }) => ResponseReasoningTextDeltaEvent(
    contentIndex: contentIndex ?? this.contentIndex,
    delta: delta ?? this.delta,
    itemId: itemId ?? this.itemId,
    outputIndex: outputIndex ?? this.outputIndex,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseReasoningTextDeltaEvent &&
          runtimeType == other.runtimeType &&
          contentIndex == other.contentIndex &&
          delta == other.delta &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    contentIndex,
    delta,
    itemId,
    outputIndex,
    sequenceNumber,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseReasoningTextDeltaEvent('
      'contentIndex: $contentIndex, '
      'delta: $delta, '
      'itemId: $itemId, '
      'outputIndex: $outputIndex, '
      'sequenceNumber: $sequenceNumber, '
      'extra: ${extra?.length})';
}

/// The ResponsesReasoningTextDoneEvent wire payload.
@immutable
class ResponseReasoningTextDoneEvent extends ResponseStreamEvent {
  /// Creates a [ResponseReasoningTextDoneEvent].
  const ResponseReasoningTextDoneEvent({
    required this.contentIndex,
    required this.itemId,
    required this.outputIndex,
    required this.sequenceNumber,
    required this.text,
    this.extra,
  });

  /// The fixed type discriminator.
  @override
  String get type => 'response.reasoning_text.done';

  /// The content_index field.
  final int contentIndex;

  /// The item_id field.
  final String itemId;

  /// The output_index field.
  final int outputIndex;

  /// The sequence_number field.
  @override
  final int sequenceNumber;

  /// The text field.
  final String text;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ResponseReasoningTextDoneEvent] from JSON.
  factory ResponseReasoningTextDoneEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value?
        when value != 'response.reasoning_text.done') {
      throw FormatException(
        'ResponseReasoningTextDoneEvent: unexpected type $value',
      );
    }
    if (json['content_index'] == null) {
      throw const FormatException(
        'ResponseReasoningTextDoneEvent: missing content_index',
      );
    }
    if (json['item_id'] == null) {
      throw const FormatException(
        'ResponseReasoningTextDoneEvent: missing item_id',
      );
    }
    if (json['output_index'] == null) {
      throw const FormatException(
        'ResponseReasoningTextDoneEvent: missing output_index',
      );
    }
    if (json['sequence_number'] == null) {
      throw const FormatException(
        'ResponseReasoningTextDoneEvent: missing sequence_number',
      );
    }
    if (json['text'] == null) {
      throw const FormatException(
        'ResponseReasoningTextDoneEvent: missing text',
      );
    }
    return ResponseReasoningTextDoneEvent(
      contentIndex: json['content_index'] as int,
      itemId: json['item_id'] as String,
      outputIndex: json['output_index'] as int,
      sequenceNumber: json['sequence_number'] as int,
      text: json['text'] as String,
      extra: additionalJsonFields(json, const {
        'content_index',
        'item_id',
        'output_index',
        'sequence_number',
        'text',
        'type',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...?extra,
    'type': type,
    'content_index': contentIndex,
    'item_id': itemId,
    'output_index': outputIndex,
    'sequence_number': sequenceNumber,
    'text': text,
  };

  /// Creates a copy with the given fields replaced.
  ResponseReasoningTextDoneEvent copyWith({
    int? contentIndex,
    String? itemId,
    int? outputIndex,
    int? sequenceNumber,
    String? text,
    Object? extra = unsetCopyWithValue,
  }) => ResponseReasoningTextDoneEvent(
    contentIndex: contentIndex ?? this.contentIndex,
    itemId: itemId ?? this.itemId,
    outputIndex: outputIndex ?? this.outputIndex,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    text: text ?? this.text,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : (extra as Map?)?.cast<String, dynamic>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseReasoningTextDoneEvent &&
          runtimeType == other.runtimeType &&
          contentIndex == other.contentIndex &&
          itemId == other.itemId &&
          outputIndex == other.outputIndex &&
          sequenceNumber == other.sequenceNumber &&
          text == other.text &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    contentIndex,
    itemId,
    outputIndex,
    sequenceNumber,
    text,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ResponseReasoningTextDoneEvent('
      'contentIndex: $contentIndex, '
      'itemId: $itemId, '
      'outputIndex: $outputIndex, '
      'sequenceNumber: $sequenceNumber, '
      'text: $text, '
      'extra: ${extra?.length})';
}
