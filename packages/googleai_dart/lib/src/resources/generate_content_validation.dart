import '../client/config.dart';
import '../models/batch/generate_content_batch.dart';
import '../models/batch/inlined_request.dart';
import '../models/generation/generate_content_request.dart';

/// Validates the Vertex-only option at the HTTP entry point.
void validateFunctionArgumentStreaming({
  required bool? value,
  GoogleAIConfig? streamConfig,
}) {
  if (value == null ||
      (streamConfig?.apiMode == ApiMode.vertexAI &&
          (streamConfig?.apiVersion == ApiVersion.v1 ||
              streamConfig?.apiVersion == ApiVersion.v1beta1))) {
    return;
  }
  throw UnsupportedError(
    'Streaming function call arguments requires Vertex AI '
    'models.streamGenerateContent on v1 or v1beta1.',
  );
}

/// Validates a typed request on a route without function argument streaming.
void validateNonStreamingArguments(GenerateContentRequest? request) =>
    validateFunctionArgumentStreaming(
      value: request
          ?.toolConfig
          ?.functionCallingConfig
          ?.streamFunctionCallArguments,
    );

/// Validates inline generation requests before making a batch request.
void validateBatchFunctionArguments(GenerateContentBatch batch) {
  for (final entry
      in batch.inputConfig?.requests?.requests ?? const <InlinedRequest>[]) {
    validateNonStreamingArguments(entry.request);
  }
}
