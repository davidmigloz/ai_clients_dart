import 'dart:async';
import 'dart:convert';

import '../errors/exceptions.dart';
import '../models/beta/config/output_config.dart';
import '../models/common/equality_helpers.dart';
import '../models/content/content_block.dart';
import '../models/messages/message.dart';
import '../models/messages/message_create_request.dart';
import '../models/metadata/stop_reason.dart';
import '../models/streaming/message_stream_event.dart';
import '../resources/messages_resource.dart';
import 'stream_extensions.dart';

/// A Claude-compatible JSON Schema and decoder for structured output.
///
/// The schema is sent to Claude as supplied. The decoder receives the decoded
/// JSON value for each text block independently and can validate it before
/// creating a Dart value.
final class StructuredOutput<T> {
  /// Creates an output format from a JSON Schema and a decoder.
  StructuredOutput({required Map<String, dynamic> schema, required this.decode})
    : format = JsonOutputFormat(schema: deepUnmodifiableMap(schema));

  /// The wire format sent in `output_config.format`.
  final JsonOutputFormat format;

  /// Decodes an individual JSON value to its application type.
  final T Function(Object? json) decode;

  /// Parses each text block in a completed [message].
  ///
  /// A normal end of turn or requested stop sequence can carry structured
  /// text. Other stop reasons preserve the raw message without parsing, so
  /// refusals, tool calls and incomplete output remain inspectable.
  ///
  /// Throws [StructuredOutputParseException] with the original [message] if
  /// completed text is invalid JSON or the decoder rejects it.
  ParsedMessage<T> parseMessage(Message message) {
    final values = <int, T>{};
    final stopReason = message.stopReason;
    if (stopReason == StopReason.endTurn ||
        stopReason == StopReason.stopSequence) {
      for (final (index, block) in message.content.indexed) {
        if (block is! TextBlock) continue;
        try {
          values[index] = decode(jsonDecode(block.text));
        } catch (error, stackTrace) {
          Error.throwWithStackTrace(
            StructuredOutputParseException._(message, index, error),
            stackTrace,
          );
        }
      }
    }
    return ParsedMessage._(message, Map.unmodifiable(values));
  }

  MessageCreateRequest _configure(MessageCreateRequest request) {
    final config = request.outputConfig ?? const OutputConfig();
    if (config.format != null) {
      throw const ValidationException(
        message: 'The structured output helper supplies output_config.format.',
        fieldErrors: {
          'output_config.format': ['Remove the format from the request.'],
        },
      );
    }
    return request.copyWith(outputConfig: config.copyWith(format: format));
  }
}

/// The raw Claude message and decoded values for its structured text blocks.
final class ParsedMessage<T> {
  const ParsedMessage._(this.message, this.parsedTextBlocks);

  /// Original response, including its stop reason, refusal details and usage.
  final Message message;

  /// Decoded values keyed by their indices in [Message.content].
  final Map<int, T> parsedTextBlocks;

  /// The first non-null decoded value, if any.
  T? get parsedOutput {
    for (final value in parsedTextBlocks.values) {
      if (value != null) return value;
    }
    return null;
  }
}

/// Completed structured text failed JSON decoding or the caller's decoder.
final class StructuredOutputParseException implements Exception {
  const StructuredOutputParseException._(
    this.message,
    this.blockIndex,
    this.cause,
  );

  /// Original Claude response.
  final Message message;

  /// Index in [Message.content] of the text that failed parsing.
  final int blockIndex;

  /// The JSON decoding or caller decoder error.
  final Object cause;

  @override
  String toString() =>
      'StructuredOutputParseException: could not decode text block $blockIndex';
}

/// A single-subscription Messages stream with a structured final result.
final class StructuredMessageStream<T> extends StreamView<MessageStreamEvent> {
  StructuredMessageStream._(super.stream, this._output);

  final StructuredOutput<T> _output;

  /// Consumes this stream, optionally delivering events as they arrive.
  ///
  /// Decoding runs after the complete message arrives. A failed or truncated
  /// stream propagates its error. Use either this method or a direct
  /// subscription to the raw stream.
  Future<ParsedMessage<T>> finalParsedMessage({
    void Function(MessageStreamEvent event)? onEvent,
  }) async {
    final events = onEvent == null
        ? this
        : map((event) {
            onEvent(event);
            return event;
          });
    return _output.parseMessage(await events.finalMessage());
  }
}

/// Structured output helpers for [MessagesResource].
extension StructuredMessagesResource on MessagesResource {
  /// Creates a message and decodes its completed structured text.
  ///
  /// Supply the schema in [output]. Other output config settings are preserved.
  /// The call uses the ordinary Messages transport and request headers.
  Future<ParsedMessage<T>> parse<T>(
    MessageCreateRequest request, {
    required StructuredOutput<T> output,
    Future<void>? abortTrigger,
    List<String> betas = const [],
    String? userProfileId,
    String? workspaceId,
  }) async {
    final message = await create(
      output._configure(request),
      abortTrigger: abortTrigger,
      betas: betas,
      userProfileId: userProfileId,
      workspaceId: workspaceId,
    );
    return output.parseMessage(message);
  }

  /// Streams a message with the supplied structured output format.
  ///
  /// Use [StructuredMessageStream.finalParsedMessage] to decode the final
  /// message and optionally observe the individual events.
  StructuredMessageStream<T> parseStream<T>(
    MessageCreateRequest request, {
    required StructuredOutput<T> output,
    Future<void>? abortTrigger,
    List<String> betas = const [],
    String? userProfileId,
    String? workspaceId,
  }) {
    try {
      return StructuredMessageStream._(
        createStream(
          output._configure(request),
          abortTrigger: abortTrigger,
          betas: betas,
          userProfileId: userProfileId,
          workspaceId: workspaceId,
        ),
        output,
      );
    } catch (error, stackTrace) {
      return StructuredMessageStream._(Stream.error(error, stackTrace), output);
    }
  }
}
