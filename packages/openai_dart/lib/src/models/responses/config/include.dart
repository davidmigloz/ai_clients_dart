/// Additional data to include in the response.
enum Include {
  /// Unknown include option (fallback for unrecognized values).
  unknown('unknown'),

  /// Include encrypted reasoning content.
  reasoningEncryptedContent('reasoning.encrypted_content'),

  /// Include log probabilities for output text.
  messageOutputTextLogprobs('message.output_text.logprobs'),

  /// Include file search results.
  fileSearchResults('file_search_call.results'),

  /// Include web search results, including image results when requested.
  webSearchResults('web_search_call.results'),

  /// Include the complete sources used by a web search action.
  webSearchActionSources('web_search_call.action.sources'),

  /// Include image URLs from input messages.
  messageInputImageImageUrl('message.input_image.image_url'),

  /// Include image URLs from computer call output.
  computerCallOutputImageUrl('computer_call_output.output.image_url'),

  /// Include code interpreter outputs.
  codeInterpreterOutputs('code_interpreter_call.outputs'),

  /// Include message input audio transcription.
  messageInputAudioTranscript('message.input_audio.transcription'),

  /// Include computer call outputs.
  computerCallOutputs('computer_call.outputs');

  /// The JSON value for this include option.
  final String value;

  const Include(this.value);

  /// Creates an [Include] from a JSON value.
  factory Include.fromJson(String json) {
    return Include.values.firstWhere(
      (e) => e.value == json,
      orElse: () => Include.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
