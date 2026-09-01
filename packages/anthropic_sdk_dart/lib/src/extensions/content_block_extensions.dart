import '../models/content/content_block.dart';
import '../models/content/input_content_block.dart';

/// Conversion from response [ContentBlock]s to request [InputContentBlock]s.
extension ContentBlockConversion on ContentBlock {
  /// Converts this response block into its input counterpart for replaying an
  /// assistant turn in a follow-up request (e.g. multi-turn tool use or
  /// extended thinking).
  ///
  /// Round-trips through JSON: an *unrecognized* block type becomes an
  /// [UnknownInputContentBlock] that preserves the raw payload verbatim, so
  /// new server-side block types replay without an SDK update.
  ///
  /// A *malformed* block is not silently degraded. Throws [FormatException]
  /// when a response block omits a field the request schema requires — the
  /// response models are deliberately lenient about fields that
  /// Anthropic-compatible third-party servers may drop, and failing here
  /// names the offending field instead of sending a request the API rejects
  /// with an opaque 400.
  ///
  /// Thinking blocks must be replayed unmodified and in their original order;
  /// a modified block results in a 400 `invalid_request_error`.
  InputContentBlock toInputBlock() => InputContentBlock.fromJson(toJson());
}
