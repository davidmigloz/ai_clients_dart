import 'dart:convert';
import 'dart:typed_data';

import '../models/batch/status.dart';
import '../models/interactions/deltas/deltas.dart';
import '../models/interactions/events/events.dart';
import '../models/interactions/interaction.dart';
import '../models/interactions/usage.dart';

/// An input event for a Genie 4 world.
sealed class GenieInputEvent {
  const GenieInputEvent();

  /// Converts the event to the WebSocket wire format.
  Map<String, dynamic> toJson();
}

/// The reference image used to seed a world. Supply a 16:9 image.
class GenieReferenceImage {
  /// Base64-encoded image data, when supplied inline.
  final String? data;

  /// Image URI, when referencing an existing image.
  final String? uri;

  /// The image's MIME type, such as `image/jpeg` or `image/png`.
  final String? mimeType;

  /// Uses an inline, base64-encoded image.
  const GenieReferenceImage.base64({
    required String this.data,
    required String this.mimeType,
  }) : uri = null;

  /// Uses an image URI.
  const GenieReferenceImage.uri({required String this.uri, this.mimeType})
    : data = null;

  /// Encodes image bytes for the wire.
  factory GenieReferenceImage.bytes(
    List<int> bytes, {
    required String mimeType,
  }) =>
      GenieReferenceImage.base64(data: base64Encode(bytes), mimeType: mimeType);

  /// Converts the image to the WebSocket wire format.
  Map<String, dynamic> toJson() {
    if (data?.isEmpty ?? uri!.trim().isEmpty) {
      throw ArgumentError(
        'Genie reference image data or URI must be nonempty.',
      );
    }
    return {'data': ?data, 'uri': ?uri, 'mime_type': ?mimeType};
  }
}

/// Initializes a world from a prompt, a 16:9 reference image, or both.
final class GenieWorldSetup extends GenieInputEvent {
  /// Description of the world to generate.
  final String? prompt;

  /// Starting image for the world.
  final GenieReferenceImage? referenceImage;

  /// Creates the event that starts world generation.
  const GenieWorldSetup({this.prompt, this.referenceImage});

  @override
  Map<String, dynamic> toJson() {
    final text = prompt;
    if ((text == null || text.trim().isEmpty) && referenceImage == null) {
      throw ArgumentError(
        'Genie world setup requires a prompt or reference image.',
      );
    }
    return {
      'event_type': 'world_setup',
      if (text != null && text.trim().isNotEmpty)
        'world_prompt': {'text': text},
      if (referenceImage != null) 'reference_image': referenceImage!.toJson(),
    };
  }
}

/// A keyboard action sent to a Genie 4 world.
enum GenieAction {
  /// Presses a key.
  keyDown('key_down'),

  /// Releases a key.
  keyUp('key_up'),

  /// Presses and releases a key.
  keyClick('key_click');

  /// The API wire value.
  final String value;

  const GenieAction(this.value);
}

/// A movement or camera key supported by the Genie transport.
enum GenieKey {
  /// Down arrow.
  arrowDown('arrow_down'),

  /// Left arrow.
  arrowLeft('arrow_left'),

  /// Right arrow.
  arrowRight('arrow_right'),

  /// Up arrow.
  arrowUp('arrow_up'),

  /// A key.
  a('key_a'),

  /// D key.
  d('key_d'),

  /// Reserved E key. Genie 4 attaches no built-in gameplay action.
  e('key_e'),

  /// S key.
  s('key_s'),

  /// W key.
  w('key_w'),

  /// Reserved space bar. Genie 4 attaches no built-in gameplay action.
  space('space');

  /// The API wire value.
  final String value;

  const GenieKey(this.value);
}

/// A keyboard event that steers the active world.
final class GenieUserAction extends GenieInputEvent {
  /// The keyboard action to perform.
  final GenieAction action;

  /// The key affected by the action.
  final GenieKey key;

  /// Creates a movement or camera input event.
  const GenieUserAction({required this.action, required this.key});

  @override
  Map<String, dynamic> toJson() => {
    'event_type': 'user_action',
    'action': action.value,
    'input': key.value,
  };
}

/// A mid-session text input that changes the generated world.
final class GenieTextInput extends GenieInputEvent {
  /// The prompt supplied to the active world.
  final String text;

  /// Creates a text input event.
  const GenieTextInput(this.text);

  @override
  Map<String, dynamic> toJson() {
    if (text.trim().isEmpty) {
      throw ArgumentError('Genie text input must be nonempty.');
    }
    return {
      'event_type': 'input',
      'content': [
        {'type': 'text', 'text': text},
      ],
    };
  }
}

/// A Genie WebSocket server event.
///
/// The documented variants are [GenieConnectedEvent], [GenieCreatedEvent],
/// [GenieStepEvent], [GenieTerminalEvent], and [GenieErrorEvent].
/// [GenieUnknownEvent] preserves unrecognized event types.
sealed class GenieServerEvent {
  /// The wire discriminator.
  final String eventType;

  const GenieServerEvent(this.eventType);

  /// Parses one event from a single or batched server frame.
  factory GenieServerEvent.fromJson(Map<String, dynamic> json) {
    final type = json['event_type'];
    if (type is! String || type.isEmpty) {
      throw const FormatException('A Genie event must have an event_type.');
    }
    return switch (type) {
      'interaction.connected' => GenieConnectedEvent(
        interactionId: json['interaction_id'] as String?,
        interaction: switch (json['interaction']) {
          final Map<String, dynamic> value => Interaction.fromJson(value),
          _ => null,
        },
      ),
      'interaction.created' => GenieCreatedEvent(
        interactionId: json['interaction_id'] as String?,
      ),
      'step.start' ||
      'step.delta' ||
      'step.stop' => GenieStepEvent(InteractionEvent.fromJson(json)),
      'interaction.completed' ||
      'interaction.canceled' ||
      'interaction.cancelled' ||
      'reconnection_required' => GenieTerminalEvent._(
        type,
        created: DateTime.tryParse(json['created'] as String? ?? ''),
        updated: DateTime.tryParse(json['updated'] as String? ?? ''),
        status: switch (json['status']) {
          final Map<String, dynamic> value => Status.fromJson(value),
          _ => null,
        },
        usage: switch (json['usage']) {
          final Map<String, dynamic> value => InteractionUsage.fromJson(value),
          _ => null,
        },
      ),
      'error' => GenieErrorEvent(
        error: switch (json['error']) {
          final Map<String, dynamic> value => InteractionError.fromJson(value),
          _ => null,
        },
        eventId: json['event_id'] as String?,
      ),
      _ => GenieUnknownEvent(type, json),
    };
  }
}

/// The server acknowledged a connection to the interaction.
final class GenieConnectedEvent extends GenieServerEvent {
  /// The server-reported interaction ID, when included.
  final String? interactionId;

  /// The underlying interaction details, when supplied with the acknowledgement.
  final Interaction? interaction;

  /// Creates a connection acknowledgement.
  const GenieConnectedEvent({this.interactionId, this.interaction})
    : super('interaction.connected');
}

/// The server created the underlying interaction.
final class GenieCreatedEvent extends GenieServerEvent {
  /// The server-reported interaction ID, when included.
  final String? interactionId;

  /// Creates an interaction creation event.
  const GenieCreatedEvent({this.interactionId}) : super('interaction.created');
}

/// A step start, delta, or stop from a live Genie interaction.
final class GenieStepEvent extends GenieServerEvent {
  /// The typed step event. Audio and video arrive as [StepDeltaEvent]s.
  final InteractionEvent step;

  /// Wraps a typed Interactions step event.
  GenieStepEvent(this.step) : super(step.eventType);

  /// Decodes a JPEG frame or signed 16-bit stereo PCM chunk, when present.
  Uint8List? get mediaBytes {
    final data = switch (step) {
      StepDeltaEvent(
        delta: AudioDelta(:final data) || VideoDelta(:final data),
      ) =>
        data,
      _ => null,
    };
    return data == null ? null : base64Decode(data);
  }
}

/// A completion, cancellation, or reconnection-required notification.
final class GenieTerminalEvent extends GenieServerEvent {
  /// When the interaction was created, if reported.
  final DateTime? created;

  /// When the interaction was last updated, if reported.
  final DateTime? updated;

  /// Any RPC status returned by the interaction.
  final Status? status;

  /// Any token usage reported when generation ends.
  final InteractionUsage? usage;

  const GenieTerminalEvent._(
    super.eventType, {
    this.created,
    this.updated,
    this.status,
    this.usage,
  });

  /// Whether this event acknowledges completion of the server interaction.
  bool get completed => eventType == 'interaction.completed';
}

/// A server-reported error, delivered as an event so later frames can arrive.
final class GenieErrorEvent extends GenieServerEvent {
  /// The reported error, when the server supplies it.
  final InteractionError? error;

  /// The event ID, when present.
  final String? eventId;

  /// Creates a server error event.
  const GenieErrorEvent({this.error, this.eventId}) : super('error');
}

/// An event with a discriminator this SDK does not recognize.
final class GenieUnknownEvent extends GenieServerEvent {
  /// The original JSON payload.
  final Map<String, dynamic> rawJson;

  /// Creates a fallback event preserving the payload.
  const GenieUnknownEvent(super.eventType, this.rawJson);
}
