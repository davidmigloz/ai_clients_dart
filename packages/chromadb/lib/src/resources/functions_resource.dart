import '../models/functions/attach_function_request.dart';
import '../models/functions/attach_function_response.dart';
import '../models/functions/detach_function_request.dart';
import '../models/functions/detach_function_response.dart';
import '../models/functions/get_attached_function_response.dart';
import 'base_resource.dart';

/// Resource for serverless function operations on a collection.
///
/// This resource provides methods for attaching, getting, and detaching
/// serverless functions that process records in a collection.
///
/// Example:
/// ```dart
/// final client = ChromaClient();
///
/// // Get functions resource for a collection
/// final functions = client.functions('collection-id');
///
/// // Attach a function
/// final response = await functions.attach(
///   name: 'my-processor',
///   functionId: 'embed_processor',
///   outputCollection: 'processed-data',
/// );
///
/// // Get attached function details
/// final details = await functions.get(name: 'my-processor');
///
/// // Detach the function
/// await functions.detach(name: 'my-processor');
/// ```
class FunctionsResource extends ResourceBase {
  /// The collection ID this resource operates on.
  final String collectionId;

  /// The tenant (optional, uses config default).
  final String? _tenant;

  /// The database (optional, uses config default).
  final String? _database;

  /// Creates a functions resource for a specific collection.
  FunctionsResource({
    required this.collectionId,
    String? tenant,
    String? database,
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    required super.retryWrapper,
  }) : _tenant = tenant,
       _database = database;

  /// Builds the base path for this collection's endpoints.
  String get _basePath {
    final t = _tenant ?? config.tenant;
    final d = _database ?? config.database;
    return '/api/v2/tenants/${Uri.encodeComponent(t)}'
        '/databases/${Uri.encodeComponent(d)}'
        '/collections/${Uri.encodeComponent(collectionId)}';
  }

  /// Attaches a function to process records in this collection.
  ///
  /// [name] - The name for this function instance (required).
  /// [functionId] - The ID of the function to attach (required).
  /// [outputCollection] - The name of the collection for output (required).
  /// [params] - Optional parameters for the function.
  ///
  /// Returns information about the attached function and whether it was
  /// newly created.
  ///
  /// Endpoint: `POST /api/v2/.../collections/{id}/functions/attach`
  Future<AttachFunctionResponse> attach({
    required String name,
    required String functionId,
    required String outputCollection,
    Map<String, dynamic>? params,
  }) async {
    final request = AttachFunctionRequest(
      name: name,
      functionId: functionId,
      outputCollection: outputCollection,
      params: params,
    );

    final response = await post(
      '$_basePath/functions/attach',
      body: request.toJson(),
    );
    return AttachFunctionResponse.fromJson(parseJson(response));
  }

  /// Gets details of an attached function by name.
  ///
  /// [name] - The name of the attached function (required).
  ///
  /// Returns full details of the attached function.
  ///
  /// Endpoint: `GET /api/v2/.../collections/{id}/functions/{name}`
  Future<GetAttachedFunctionResponse> getFunction({
    required String name,
  }) async {
    final response = await get(
      '$_basePath/functions/${Uri.encodeComponent(name)}',
    );
    return GetAttachedFunctionResponse.fromJson(parseJson(response));
  }

  /// Detaches a function from this collection.
  ///
  /// [name] - The name of the attached function to detach (required).
  /// [deleteOutput] - Whether to delete the output collection.
  ///
  /// Returns whether the detach operation was successful.
  ///
  /// Endpoint: `POST /api/v2/.../collections/{id}/attached_functions/{name}/detach`
  Future<DetachFunctionResponse> detach({
    required String name,
    bool? deleteOutput,
  }) async {
    final request = DetachFunctionRequest(deleteOutput: deleteOutput);

    final response = await post(
      '$_basePath/attached_functions/${Uri.encodeComponent(name)}/detach',
      body: request.toJson(),
    );
    return DetachFunctionResponse.fromJson(parseJson(response));
  }
}
