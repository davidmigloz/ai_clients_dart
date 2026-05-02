/// A content part that can appear inside a response-side `Message`.
///
/// Per the spec's `Message.content` union, response messages may carry both
/// input content (`input_text`, `input_image`, `input_file`, `input_video`)
/// and output content (`output_text`, `reasoning_text`, `summary_text`,
/// `refusal`). Stored or compacted history echoes prior user messages whose
/// parts are `input_*`, while the model's own messages emit `output_*`.
///
/// Both [InputContent] and [OutputContent] sealed hierarchies implement this
/// interface so [MessageOutputItem.content] can hold either.
abstract interface class MessageContentPart {
  /// Converts to JSON.
  Map<String, dynamic> toJson();
}
