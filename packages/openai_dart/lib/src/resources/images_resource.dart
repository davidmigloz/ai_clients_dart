import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/openai_client.dart';
import '../models/images/images.dart';
import 'base_resource.dart';

/// Resource for image operations.
///
/// Provides image generation, editing, and variation capabilities
/// using DALL-E models.
///
/// Access this resource through [OpenAIClient.images].
///
/// ## Example
///
/// ```dart
/// // Generate an image
/// final response = await client.images.generate(
///   ImageGenerationRequest(
///     model: 'dall-e-3',
///     prompt: 'A white cat sitting on a windowsill',
///     size: ImageSize.size1024x1024,
///   ),
/// );
///
/// final imageUrl = response.data.first.url;
/// ```
class ImagesResource extends BaseResource {
  /// Creates an [ImagesResource] with the given client.
  ImagesResource(super.client);

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
  ///     model: 'dall-e-3',
  ///     prompt: 'A beautiful sunset over mountains',
  ///     size: ImageSize.size1024x1024,
  ///     quality: ImageQuality.hd,
  ///     style: ImageStyle.vivid,
  ///   ),
  /// );
  ///
  /// for (final image in response.data) {
  ///   print('Image URL: ${image.url}');
  /// }
  /// ```
  Future<ImageResponse> generate(ImageGenerationRequest request) async {
    final json = await postJson(_generateEndpoint, body: request.toJson());
    return ImageResponse.fromJson(json);
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
  /// final maskBytes = File('mask.png').readAsBytesSync();
  ///
  /// final response = await client.images.edit(
  ///   ImageEditRequest(
  ///     image: imageBytes,
  ///     imageFilename: 'original.png',
  ///     mask: maskBytes,
  ///     maskFilename: 'mask.png',
  ///     prompt: 'Add a red hat',
  ///     model: 'dall-e-2',
  ///   ),
  /// );
  /// ```
  Future<ImageResponse> edit(ImageEditRequest request) async {
    final httpRequest = _createEditMultipartRequest(request);
    final response = await client.postMultipart(request: httpRequest);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ImageResponse.fromJson(json);
  }

  /// Creates edited images using JSON payload references.
  ///
  /// This method sends `application/json` and is intended for GPT image
  /// editing workflows where images are referenced by URL or File ID.
  Future<ImageResponse> editJson(ImageEditJsonRequest request) async {
    final json = await postJson(_editEndpoint, body: request.toJson());
    return ImageResponse.fromJson(json);
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
    final httpRequest = _createVariationMultipartRequest(request);
    final response = await client.postMultipart(request: httpRequest);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ImageResponse.fromJson(json);
  }

  http.MultipartRequest _createEditMultipartRequest(ImageEditRequest request) {
    final url = client.buildUrl(_editEndpoint);
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

    return httpRequest;
  }

  http.MultipartRequest _createVariationMultipartRequest(
    ImageVariationRequest request,
  ) {
    final url = client.buildUrl(_variationEndpoint);
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
