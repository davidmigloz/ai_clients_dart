import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../models/images/images.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Resource for image operations.
///
/// Provides image generation, editing, and variation capabilities using
/// GPT image models (e.g. `gpt-image-2`) and DALL-E.
///
/// Access this resource through [OpenAIClient.images].
///
/// ## Example
///
/// ```dart
/// // Generate an image with GPT Image 2
/// final response = await client.images.generate(
///   ImageGenerationRequest(
///     model: ImageModels.gptImage2,
///     prompt: 'A white cat sitting on a windowsill',
///     size: ImageSize.size1024x1024,
///     background: ImageBackground.transparent,
///   ),
/// );
///
/// // GPT image models always return base64; decode before using as bytes.
/// final b64Json = response.data.first.b64Json;
/// if (b64Json == null) {
///   throw StateError('Expected base64 image data but got null');
/// }
/// final bytes = base64Decode(b64Json);
/// print('Tokens used: ${response.usage?.totalTokens}');
/// ```
class ImagesResource extends ResourceBase with StreamingResource {
  /// Creates an [ImagesResource].
  ImagesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _generateEndpoint = '/images/generations';
  static const _editEndpoint = '/images/edits';
  static const _variationEndpoint = '/images/variations';

  /// Generates images from a text prompt.
  ///
  /// Creates one or more images based on the provided text description.
  ///
  /// ## Parameters
  ///
  /// - [request] - The image generation request.
  ///
  /// ## Returns
  ///
  /// An [ImageResponse] containing the generated images.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final response = await client.images.generate(
  ///   ImageGenerationRequest(
  ///     model: ImageModels.gptImage2,
  ///     prompt: 'A beautiful sunset over mountains',
  ///     size: ImageSize.size1536x1024,
  ///     quality: ImageQuality.high,
  ///     outputFormat: ImageOutputFormat.webp,
  ///   ),
  /// );
  ///
  /// for (final image in response.data) {
  ///   print('Base64 image: ${image.b64Json?.length} chars');
  /// }
  /// ```
  Future<ImageResponse> generate(ImageGenerationRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_generateEndpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return ImageResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Streams image generation as Server-Sent Events (GPT image models only).
  ///
  /// Forces `stream: true` on the request. Yields one or more
  /// [ImageGenPartialImageEvent]s followed by a terminal
  /// [ImageGenCompletedEvent] carrying the final image and token-based usage.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final stream = client.images.generateStream(
  ///   ImageGenerationRequest(
  ///     model: ImageModels.gptImage2,
  ///     prompt: 'A white cat wearing a top hat',
  ///     partialImages: 2,
  ///   ),
  /// );
  ///
  /// await for (final event in stream) {
  ///   switch (event) {
  ///     case ImageGenPartialImageEvent():
  ///       print('partial #${event.partialImageIndex}');
  ///     case ImageGenCompletedEvent():
  ///       print('done — ${event.usage.totalTokens} tokens');
  ///     case ImageGenUnknownEvent():
  ///       // Forward-compatibility fallback.
  ///   }
  /// }
  /// ```
  Stream<ImageGenStreamEvent> generateStream(
    ImageGenerationRequest request, {
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final body = request.toJson()..['stream'] = true;
    return streamSseEvents(
      endpoint: _generateEndpoint,
      body: body,
      abortTrigger: abortTrigger,
    ).map((json) {
      final sseEvent = json['_event'] as String?;
      final error = json['error'];
      if (sseEvent == 'error' || error != null) {
        throwInlineStreamError(json, sseEvent, error);
      }
      try {
        return ImageGenStreamEvent.fromJson(json);
      } on FormatException catch (e) {
        throw ParseException(
          message: 'Failed to parse image generation stream event: $e',
          responseBody: json.toString(),
          cause: e,
        );
      } on TypeError catch (e) {
        throw ParseException(
          message: 'Failed to parse image generation stream event: $e',
          responseBody: json.toString(),
          cause: e,
        );
      }
    });
  }

  /// Creates edited or extended images.
  ///
  /// Given an original image and a mask, generates new images where
  /// the mask area has been replaced based on the prompt.
  ///
  /// ## Parameters
  ///
  /// - [request] - The image edit request with image, mask, and prompt.
  ///
  /// ## Returns
  ///
  /// An [ImageResponse] containing the edited images.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final imageBytes = File('original.png').readAsBytesSync();
  ///
  /// final response = await client.images.edit(
  ///   ImageEditRequest(
  ///     image: imageBytes,
  ///     imageFilename: 'original.png',
  ///     prompt: 'Add a rainbow in the sky',
  ///     model: ImageModels.gptImage2,
  ///     inputFidelity: ImageInputFidelity.high,
  ///   ),
  /// );
  /// ```
  Future<ImageResponse> edit(ImageEditRequest request) async {
    ensureNotClosed?.call();
    final httpRequest = _createEditMultipartRequest(request);
    httpRequest.headers.addAll(requestBuilder.buildMultipartHeaders());
    final response = await interceptorChain.execute(httpRequest);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ImageResponse.fromJson(json);
  }

  /// Creates edited images using JSON payload references.
  ///
  /// This method sends `application/json` and is intended for GPT image
  /// editing workflows where images are referenced by URL or File ID.
  Future<ImageResponse> editJson(ImageEditJsonRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_editEndpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return ImageResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Streams an image edit using a JSON payload (GPT image models only).
  ///
  /// Forces `stream: true` on the request. Yields
  /// [ImageEditPartialImageEvent]s then a terminal [ImageEditCompletedEvent].
  Stream<ImageEditStreamEvent> editJsonStream(
    ImageEditJsonRequest request, {
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final body = request.toJson()..['stream'] = true;
    return streamSseEvents(
      endpoint: _editEndpoint,
      body: body,
      abortTrigger: abortTrigger,
    ).map(_mapEditEvent);
  }

  /// Streams a multipart image edit (GPT image models only).
  ///
  /// Forces `stream: true` on the request. Yields
  /// [ImageEditPartialImageEvent]s then a terminal [ImageEditCompletedEvent].
  Stream<ImageEditStreamEvent> editStream(
    ImageEditRequest request, {
    Future<void>? abortTrigger,
  }) async* {
    ensureNotClosed?.call();

    final multipart = _createEditMultipartRequest(
      ImageEditRequest(
        image: request.image,
        imageFilename: request.imageFilename,
        prompt: request.prompt,
        mask: request.mask,
        maskFilename: request.maskFilename,
        model: request.model,
        n: request.n,
        size: request.size,
        responseFormat: request.responseFormat,
        user: request.user,
        background: request.background,
        inputFidelity: request.inputFidelity,
        quality: request.quality,
        outputFormat: request.outputFormat,
        outputCompression: request.outputCompression,
        moderation: request.moderation,
        stream: true,
        partialImages: request.partialImages,
      ),
    )..headers.addAll(requestBuilder.buildMultipartHeaders());

    final response = await httpClient.send(multipart);
    final requestId =
        response.headers['x-request-id'] ??
        response.request?.headers['X-Request-ID'] ??
        'unknown';

    if (response.statusCode >= 400) {
      final body = await response.stream.bytesToString();
      throw parseStreamError(response.statusCode, body, requestId);
    }

    const parser = SseParser();
    await for (final json in parser.parse(response.stream)) {
      yield _mapEditEvent(json);
    }
  }

  ImageEditStreamEvent _mapEditEvent(Map<String, dynamic> json) {
    final sseEvent = json['_event'] as String?;
    final error = json['error'];
    if (sseEvent == 'error' || error != null) {
      throwInlineStreamError(json, sseEvent, error);
    }
    try {
      return ImageEditStreamEvent.fromJson(json);
    } on FormatException catch (e) {
      throw ParseException(
        message: 'Failed to parse image edit stream event: $e',
        responseBody: json.toString(),
        cause: e,
      );
    } on TypeError catch (e) {
      throw ParseException(
        message: 'Failed to parse image edit stream event: $e',
        responseBody: json.toString(),
        cause: e,
      );
    }
  }

  /// Creates variations of an existing image.
  ///
  /// Generates images that are similar in style and content to
  /// the provided image.
  ///
  /// ## Parameters
  ///
  /// - [request] - The image variation request with source image.
  ///
  /// ## Returns
  ///
  /// An [ImageResponse] containing the image variations.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final imageBytes = File('original.png').readAsBytesSync();
  ///
  /// final response = await client.images.createVariation(
  ///   ImageVariationRequest(
  ///     image: imageBytes,
  ///     imageFilename: 'original.png',
  ///     n: 3, // Generate 3 variations
  ///     size: ImageSize.size512x512,
  ///   ),
  /// );
  /// ```
  Future<ImageResponse> createVariation(ImageVariationRequest request) async {
    ensureNotClosed?.call();
    final httpRequest = _createVariationMultipartRequest(request);
    httpRequest.headers.addAll(requestBuilder.buildMultipartHeaders());
    final response = await interceptorChain.execute(httpRequest);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ImageResponse.fromJson(json);
  }

  http.MultipartRequest _createEditMultipartRequest(ImageEditRequest request) {
    final url = requestBuilder.buildUrl(_editEndpoint);
    final httpRequest = http.MultipartRequest('POST', url);

    // Add image file
    httpRequest.files.add(
      http.MultipartFile.fromBytes(
        'image',
        request.image,
        filename: request.imageFilename,
      ),
    );

    // Add mask if provided
    if (request.mask != null) {
      httpRequest.files.add(
        http.MultipartFile.fromBytes(
          'mask',
          request.mask!,
          filename: request.maskFilename ?? 'mask.png',
        ),
      );
    }

    // Add required fields
    httpRequest.fields['prompt'] = request.prompt;

    // Add optional fields
    if (request.model != null) {
      httpRequest.fields['model'] = request.model!;
    }
    if (request.n != null) {
      httpRequest.fields['n'] = request.n.toString();
    }
    if (request.size != null) {
      httpRequest.fields['size'] = request.size!.toJson();
    }
    if (request.responseFormat != null) {
      httpRequest.fields['response_format'] = request.responseFormat!.toJson();
    }
    if (request.user != null) {
      httpRequest.fields['user'] = request.user!;
    }
    if (request.background != null) {
      httpRequest.fields['background'] = request.background!.toJson();
    }
    if (request.inputFidelity != null) {
      httpRequest.fields['input_fidelity'] = request.inputFidelity!.toJson();
    }
    if (request.quality != null) {
      httpRequest.fields['quality'] = request.quality!.toJson();
    }
    if (request.outputFormat != null) {
      httpRequest.fields['output_format'] = request.outputFormat!.toJson();
    }
    if (request.outputCompression != null) {
      httpRequest.fields['output_compression'] = request.outputCompression
          .toString();
    }
    if (request.moderation != null) {
      httpRequest.fields['moderation'] = request.moderation!.toJson();
    }
    if (request.stream != null) {
      httpRequest.fields['stream'] = request.stream! ? 'true' : 'false';
    }
    if (request.partialImages != null) {
      httpRequest.fields['partial_images'] = request.partialImages.toString();
    }

    return httpRequest;
  }

  http.MultipartRequest _createVariationMultipartRequest(
    ImageVariationRequest request,
  ) {
    final url = requestBuilder.buildUrl(_variationEndpoint);
    final httpRequest = http.MultipartRequest('POST', url);

    // Add image file
    httpRequest.files.add(
      http.MultipartFile.fromBytes(
        'image',
        request.image,
        filename: request.imageFilename,
      ),
    );

    // Add optional fields
    if (request.model != null) {
      httpRequest.fields['model'] = request.model!;
    }
    if (request.n != null) {
      httpRequest.fields['n'] = request.n.toString();
    }
    if (request.size != null) {
      httpRequest.fields['size'] = request.size!.toJson();
    }
    if (request.responseFormat != null) {
      httpRequest.fields['response_format'] = request.responseFormat!.toJson();
    }
    if (request.user != null) {
      httpRequest.fields['user'] = request.user!;
    }

    return httpRequest;
  }
}
