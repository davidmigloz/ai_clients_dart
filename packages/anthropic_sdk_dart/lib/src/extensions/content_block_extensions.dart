import '../models/content/content_block.dart';
import '../models/content/input_content_block.dart';

/// Conversion from response [ContentBlock]s to request [InputContentBlock]s.
extension ContentBlockConversion on ContentBlock {
  /// Converts this response block into its input counterpart for replaying an
  /// assistant turn in a follow-up request (e.g. multi-turn tool use or
  /// extended thinking).
  ///
  /// Round-trips through JSON, so every block type is handled: types without a
  /// typed input counterpart become [UnknownInputContentBlock], preserving the
  /// raw payload verbatim. Thinking blocks must be replayed unmodified and in
  /// their original order; a modified block results in a 400
  /// `invalid_request_error`.
  InputContentBlock toInputBlock() => InputContentBlock.fromJson(toJson());
}
