import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/libraries/entity_type.dart';
import '../../models/libraries/library.dart';
import '../../models/libraries/library_document.dart';
import '../../models/libraries/processing_status_out.dart';
import '../../models/libraries/sharing_list.dart';
import '../../models/libraries/sharing_request.dart';
import '../../models/libraries/sharing_response.dart';
import '../base_resource.dart';

/// Resource for managing document libraries (Beta).
///
/// Libraries provide document storage for RAG (Retrieval-Augmented Generation).
/// Documents in libraries can be accessed by agents through the document_library
/// tool for context-aware responses.
///
/// Example usage:
/// ```dart
/// // Create a new library
/// final library = await client.libraries.create(
///   name: 'My Knowledge Base',
///   description: 'Technical documentation for my product',
/// );
/// print('Library ID: ${library.id}');
///
/// // Add a document to the library
/// final document = await client.libraries.documents.create(
///   libraryId: library.id,
///   fileId: 'file-abc123', // Previously uploaded file
/// );
/// print('Document: ${document.name}');
///
/// // List documents in the library
/// final docs = await client.libraries.documents.list(libraryId: library.id);
/// for (final doc in docs.data) {
///   print('  - ${doc.name} (${doc.status})');
/// }
/// ```
class LibrariesResource extends ResourceBase {
  /// Creates a [LibrariesResource].
  LibrariesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  }) : documents = LibraryDocumentsResource(
         config: config,
         httpClient: httpClient,
         interceptorChain: interceptorChain,
         requestBuilder: requestBuilder,
       );

  /// Sub-resource for managing documents within libraries.
  final LibraryDocumentsResource documents;

  /// Creates a new library.
  ///
  /// [name] is the name for the library.
  /// [description] is an optional description of the library contents.
  Future<Library> create({required String name, String? description}) async {
    final url = requestBuilder.buildUrl('/v1/libraries');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final body = <String, dynamic>{'name': name, 'description': ?description};

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Library.fromJson(responseBody);
  }

  /// Lists all libraries.
  ///
  /// [page] is the page number to retrieve (0-indexed).
  /// [pageSize] is the number of libraries per page.
  Future<LibraryList> list({int? page, int? pageSize}) async {
    final queryParams = <String, String>{
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/libraries',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return LibraryList.fromJson(responseBody);
  }

  /// Retrieves a library by ID.
  ///
  /// [libraryId] is the unique identifier of the library.
  Future<Library> retrieve({required String libraryId}) async {
    final url = requestBuilder.buildUrl('/v1/libraries/$libraryId');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Library.fromJson(responseBody);
  }

  /// Updates a library.
  ///
  /// [libraryId] is the unique identifier of the library.
  /// [name] is the new name for the library.
  /// [description] is the new description for the library.
  Future<Library> update({
    required String libraryId,
    String? name,
    String? description,
  }) async {
    final url = requestBuilder.buildUrl('/v1/libraries/$libraryId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final body = <String, dynamic>{'name': ?name, 'description': ?description};

    final httpRequest = http.Request('PUT', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Library.fromJson(responseBody);
  }

  /// Deletes a library.
  ///
  /// [libraryId] is the unique identifier of the library to delete.
  Future<void> delete({required String libraryId}) async {
    final url = requestBuilder.buildUrl('/v1/libraries/$libraryId');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  /// Lists all sharing entries for a library.
  ///
  /// [libraryId] is the unique identifier of the library.
  Future<SharingList> listSharing({required String libraryId}) async {
    final url = requestBuilder.buildUrl('/v1/libraries/$libraryId/share');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return SharingList.fromJson(responseBody);
  }

  /// Creates or updates sharing for a library.
  ///
  /// You must be the owner of the library to share it. An owner cannot
  /// change their own role. A library cannot be shared outside of the
  /// organization.
  ///
  /// [libraryId] is the unique identifier of the library.
  /// [request] contains the sharing configuration.
  Future<SharingResponse> share({
    required String libraryId,
    required SharingRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/libraries/$libraryId/share');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PUT', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return SharingResponse.fromJson(responseBody);
  }

  /// Removes sharing for a library.
  ///
  /// An owner cannot delete their own access. You must be the owner of
  /// the library to delete access for others.
  ///
  /// [libraryId] is the unique identifier of the library.
  /// [shareWithUuid] is the UUID of the entity to remove access for.
  /// [shareWithType] is the type of entity to remove access for.
  /// [orgId] is the optional organization ID.
  Future<SharingResponse> deleteSharing({
    required String libraryId,
    required String shareWithUuid,
    required EntityType shareWithType,
    String? orgId,
  }) async {
    final url = requestBuilder.buildUrl('/v1/libraries/$libraryId/share');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final body = <String, dynamic>{
      'share_with_uuid': shareWithUuid,
      'share_with_type': shareWithType.value,
      'org_id': ?orgId,
    };

    final httpRequest = http.Request('DELETE', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return SharingResponse.fromJson(responseBody);
  }
}

/// Resource for managing documents within a library.
class LibraryDocumentsResource extends ResourceBase {
  /// Creates a [LibraryDocumentsResource].
  LibraryDocumentsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Adds a document to a library.
  ///
  /// [libraryId] is the ID of the library to add the document to.
  /// [fileId] is the ID of a previously uploaded file to add.
  /// [documentName] is an optional name for the document.
  Future<LibraryDocument> create({
    required String libraryId,
    required String fileId,
    String? documentName,
  }) async {
    final url = requestBuilder.buildUrl('/v1/libraries/$libraryId/documents');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final body = <String, dynamic>{
      'file_id': fileId,
      'document_name': ?documentName,
    };

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return LibraryDocument.fromJson(responseBody);
  }

  /// Lists documents in a library.
  ///
  /// [libraryId] is the ID of the library.
  /// [page] is the page number to retrieve (0-indexed).
  /// [pageSize] is the number of documents per page.
  Future<LibraryDocumentList> list({
    required String libraryId,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, String>{
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/libraries/$libraryId/documents',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return LibraryDocumentList.fromJson(responseBody);
  }

  /// Retrieves a document by ID.
  ///
  /// [libraryId] is the ID of the library.
  /// [documentId] is the unique identifier of the document.
  Future<LibraryDocument> retrieve({
    required String libraryId,
    required String documentId,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/libraries/$libraryId/documents/$documentId',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return LibraryDocument.fromJson(responseBody);
  }

  /// Updates a document's metadata.
  ///
  /// [libraryId] is the ID of the library.
  /// [documentId] is the unique identifier of the document.
  /// [documentName] is the new name for the document.
  Future<LibraryDocument> update({
    required String libraryId,
    required String documentId,
    String? documentName,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/libraries/$libraryId/documents/$documentId',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final body = <String, dynamic>{'document_name': ?documentName};

    final httpRequest = http.Request('PUT', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return LibraryDocument.fromJson(responseBody);
  }

  /// Deletes a document from a library.
  ///
  /// [libraryId] is the ID of the library.
  /// [documentId] is the unique identifier of the document to delete.
  Future<void> delete({
    required String libraryId,
    required String documentId,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/libraries/$libraryId/documents/$documentId',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  /// Retrieves the text content of a document.
  ///
  /// Returns the text content that was extracted from the document.
  /// For documents like PDF, DOCX, and PPTX, the text content results
  /// from processing using Mistral OCR.
  ///
  /// [libraryId] is the ID of the library.
  /// [documentId] is the unique identifier of the document.
  Future<LibraryDocumentContent> getContent({
    required String libraryId,
    required String documentId,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/libraries/$libraryId/documents/$documentId/text_content',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return LibraryDocumentContent.fromJson(responseBody);
  }

  /// Gets the processing status of a document.
  ///
  /// [libraryId] is the ID of the library.
  /// [documentId] is the unique identifier of the document.
  Future<ProcessingStatusOut> getStatus({
    required String libraryId,
    required String documentId,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/libraries/$libraryId/documents/$documentId/status',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ProcessingStatusOut.fromJson(responseBody);
  }

  /// Gets a signed URL for downloading the document.
  ///
  /// [libraryId] is the ID of the library.
  /// [documentId] is the unique identifier of the document.
  Future<String> getSignedUrl({
    required String libraryId,
    required String documentId,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/libraries/$libraryId/documents/$documentId/signed-url',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return responseBody['url'] as String;
  }

  /// Gets a signed URL for the extracted text content.
  ///
  /// [libraryId] is the ID of the library.
  /// [documentId] is the unique identifier of the document.
  Future<String> getExtractedTextSignedUrl({
    required String libraryId,
    required String documentId,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/libraries/$libraryId/documents/$documentId/extracted-text-signed-url',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return responseBody['url'] as String;
  }

  /// Reprocesses a document.
  ///
  /// Triggers re-extraction and processing of the document content.
  ///
  /// [libraryId] is the ID of the library.
  /// [documentId] is the unique identifier of the document.
  Future<void> reprocess({
    required String libraryId,
    required String documentId,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/libraries/$libraryId/documents/$documentId/reprocess',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('POST', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }
}
