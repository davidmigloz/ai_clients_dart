import 'package:http/http.dart' as http;

import '../../client/interceptor_chain.dart';
import '../../client/openai_client.dart';
import '../../client/request_builder.dart';
import '../../errors/exceptions.dart';
import '../../interceptors/interceptor.dart';
import '../../models/agents/agents.dart';
import '../../models/files/file_object.dart';
import '../../resources/agent_environment_files_resource.dart';
import '../../resources/files_resource.dart';
import '../../utils/private_agent_inspection_http.dart';
import 'agent_file_abort.dart';
import 'agent_file_inputs.dart';
import 'agent_file_materialization.dart';
import 'agent_file_preparation.dart';

/// Explicit selected-file preparation and staging using existing API resources.
///
/// Captures one client's resource generation. Preparation uploads only;
/// [stage] additionally copies one observed upload into an explicitly selected
/// connected environment. No environment creation, directory sync or deletion
/// occurs. Portable streams are materialized one at a time within a local byte
/// budget; this helper does not promise constant-memory multipart streaming.
final class AgentFiles {
  /// Captures matching Files/Agents resources before any asynchronous work.
  AgentFiles(OpenAIClient client)
    : _files = client.files,
      _environmentFiles = _stagingResource(client.agents.environments.files);

  final FilesResource _files;
  final AgentEnvironmentFilesResource _environmentFiles;

  /// Default local per-file materialization budget, not an API upload quota.
  static const int defaultMaxFileBytes = 64 * 1024 * 1024;

  /// Uploads explicitly selected data with `purpose=user_data` in input order.
  ///
  /// All destinations, ancestor/duplicate conflicts and declared sizes are
  /// validated before opening a source or uploading. [maxFileBytes] is a local
  /// memory limit that callers may explicitly change. Cancellation releases a
  /// selected source promptly; HTTP cancellation uses the supplied transport's
  /// support. A successful acknowledgment observed before exit is recorded,
  /// while uncertain delivery never produces an inferred ID. On failure,
  /// [AgentFilePreparationException.prepared] retains known caller-owned uploads.
  /// Shared upload idempotency keys are rejected up front; repeated keys supplied
  /// dynamically by credentials or middleware fail before the affected upload.
  Future<PreparedAgentFiles> prepare(
    List<AgentFileInput> files, {
    int maxFileBytes = defaultMaxFileBytes,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) async {
    final selected = List<AgentFileInput>.unmodifiable(files);
    final headers = additionalHeaders == null
        ? null
        : Map<String, String>.unmodifiable(additionalHeaders);
    _preflight(selected, maxFileBytes, {
      ..._files.config.defaultHeaders,
      ...?headers,
    });
    final gate = AgentFileAbortGate(abortTrigger);
    final uploads = _uploadResource(_files);
    final uploaded = <String>[];
    final references = <AgentSessionHostedEnvironmentFileConfigFileId>[];
    try {
      await Future<void>.value();
      gate.check();
      for (final input in selected) {
        gate.check();
        final bytes = await materializeAgentFile(input, maxFileBytes, gate);
        gate.check();
        final signal = gate.bind();
        final FileObject file;
        try {
          file = await uploads.upload(
            bytes: bytes,
            filename: input.filename,
            purpose: FilePurpose.userData,
            additionalHeaders: headers,
            abortTrigger: signal.future,
            redactDiagnostics: true,
          );
        } finally {
          signal.dispose();
        }
        if (file.id.isEmpty) {
          throw const ParseException(
            message: 'File upload returned no usable identifier.',
          );
        }
        // Record the actual acknowledgment before mapping or observing abort.
        // A later failure cannot hide a successful caller-owned upload.
        uploaded.add(file.id);
        references.add(
          AgentSessionHostedEnvironmentFileConfigFileId(
            fileId: file.id,
            path: input.destination,
          ),
        );
        gate.check();
      }
      return PreparedAgentFiles(files: references, uploadedFileIds: uploaded);
    } catch (error) {
      throw AgentFilePreparationException(
        prepared: PreparedAgentFiles(
          files: references,
          uploadedFileIds: uploaded,
        ),
        cause: error,
      );
    } finally {
      gate.dispose();
    }
  }

  /// Uploads and explicitly stages one file into an existing environment.
  ///
  /// Hosted destination and environment ID are validated before upload. The
  /// Files upload remains caller-owned even if the separate staging call fails.
  /// An inherited/default or shared per-call Idempotency-Key applies only to the
  /// upload; it is omitted for the distinct environment write. Use the raw
  /// environment-files resource when an independent staging key is required.
  Future<StagedAgentFile> stage(
    String environmentId,
    AgentFileInput file, {
    int maxFileBytes = defaultMaxFileBytes,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) async {
    _validateEnvironmentId(environmentId);
    final headers = additionalHeaders == null
        ? null
        : Map<String, String>.unmodifiable(additionalHeaders);
    final prepared = await prepare(
      [file],
      maxFileBytes: maxFileBytes,
      additionalHeaders: headers,
      abortTrigger: abortTrigger,
    );
    final gate = AgentFileAbortGate(abortTrigger);
    try {
      await Future<void>.value();
      gate.check();
      final signal = gate.bind();
      try {
        final staged = await _environmentFiles.create(
          environmentId,
          prepared.files.single,
          additionalHeaders: headers,
          abortTrigger: signal.future,
        );
        gate.check();
        return StagedAgentFile(
          uploadedFileId: prepared.uploadedFileIds.single,
          file: staged,
        );
      } finally {
        signal.dispose();
      }
    } catch (error) {
      throw AgentFilePreparationException(prepared: prepared, cause: error);
    } finally {
      gate.dispose();
    }
  }
}

void _preflight(
  List<AgentFileInput> files,
  int budget,
  Map<String, String> headers,
) {
  if (!budget.isFinite || budget < 0) {
    throw const FormatException(
      'Agent files: expected a finite nonnegative byte budget.',
    );
  }
  if (files.length > 1 &&
      headers.keys.any((name) => name.toLowerCase() == 'idempotency-key')) {
    throw const FormatException(
      'Agent files: do not reuse one Idempotency-Key across uploads.',
    );
  }
  final root = _FilePathNode();
  for (final file in files) {
    file.validate();
    if (file.length > budget) {
      throw const FormatException(
        'Agent file exceeds the selected local byte budget.',
      );
    }
    var node = root;
    for (final part in file.destination.split('/').skip(1)) {
      if (node.isFile) {
        throw const FormatException('Agent file destinations conflict.');
      }
      node = node.children.putIfAbsent(part, _FilePathNode.new);
    }
    if (node.isFile || node.children.isNotEmpty) {
      throw const FormatException('Agent file destinations conflict.');
    }
    node.isFile = true;
  }
}

final class _FilePathNode {
  final children = <String, _FilePathNode>{};
  bool isFile = false;
}

void _validateEnvironmentId(String id) {
  if (id.isEmpty || id == '.' || id == '..' || id.runes.length > 1048576) {
    throw const FormatException(
      'Agent file staging requires an opaque environment ID.',
    );
  }
  try {
    if (Uri.decodeComponent(Uri.encodeComponent(id)) != id) {
      throw const FormatException(
        'Agent file staging requires a losslessly encodable environment ID.',
      );
    }
  } on ArgumentError {
    throw const FormatException(
      'Agent file staging requires an encodable environment ID.',
    );
  }
}

AgentEnvironmentFilesResource _stagingResource(
  AgentEnvironmentFilesResource source,
) => AgentEnvironmentFilesResource(
  config: source.config,
  httpClient: source.httpClient,
  interceptorChain: _StagingInterceptorChain(source.interceptorChain),
  requestBuilder: _StagingRequestBuilder(source.requestBuilder),
  ensureNotClosed: source.ensureNotClosed,
);

/// Retains the exact URL/header builder except for a distinct write's key.
final class _StagingRequestBuilder extends RequestBuilder {
  _StagingRequestBuilder(this.source) : super(config: source.config);
  final RequestBuilder source;
  @override
  Uri buildUrl(String path, {Map<String, String>? queryParams}) =>
      privateAgentInspectionExternal(
        null,
        () => source.buildUrl(path, queryParams: queryParams),
        redactDiagnostics: true,
      );
  @override
  Map<String, String> buildBetaHeaders({
    required String betaFeature,
    Map<String, String>? additionalHeaders,
  }) => Map<String, String>.of(
    privateAgentInspectionExternal(
      null,
      () => source.buildBetaHeaders(
        betaFeature: betaFeature,
        additionalHeaders: additionalHeaders,
      ),
      redactDiagnostics: true,
    ),
  )..removeWhere((key, _) => key.toLowerCase() == 'idempotency-key');
}

/// Delegates to the original chain/list, retaining later middleware changes.
final class _StagingInterceptorChain extends InterceptorChain {
  _StagingInterceptorChain(this.source)
    : super(
        interceptors: source.interceptors,
        httpClient: source.httpClient,
        retryWrapper: source.retryWrapper,
        timeout: source.timeout,
        ensureNotClosed: source.ensureNotClosed,
      );
  final InterceptorChain source;
  @override
  Future<http.Response> execute(
    http.BaseRequest request, {
    Future<void>? abortTrigger,
    bool allowRetries = true,
    bool redactDiagnostics = false,
  }) => source.execute(
    request,
    abortTrigger: abortTrigger,
    allowRetries: allowRetries,
    redactDiagnostics: true,
  );
}

// Each preparation owns the key registry; neither the client nor raw Files
// resource is mutated. Resolve the current middleware list on each dispatch.
FilesResource _uploadResource(FilesResource source) => FilesResource(
  config: source.config,
  httpClient: source.httpClient,
  interceptorChain: _UploadInterceptorChain(source.interceptorChain),
  requestBuilder: source.requestBuilder,
  ensureNotClosed: source.ensureNotClosed,
);

final class _UploadInterceptorChain extends InterceptorChain {
  _UploadInterceptorChain(this.source)
    : super(
        interceptors: source.interceptors,
        httpClient: source.httpClient,
        retryWrapper: source.retryWrapper,
        timeout: source.timeout,
        ensureNotClosed: source.ensureNotClosed,
      );
  final InterceptorChain source;
  final _keys = _DistinctUploadKeys();

  @override
  Future<http.Response> execute(
    http.BaseRequest request, {
    Future<void>? abortTrigger,
    bool allowRetries = true,
    bool redactDiagnostics = false,
  }) =>
      InterceptorChain(
        interceptors: [...source.interceptors, _keys],
        httpClient: source.httpClient,
        retryWrapper: source.retryWrapper,
        timeout: source.timeout,
        ensureNotClosed: source.ensureNotClosed,
      ).execute(
        request,
        abortTrigger: abortTrigger,
        allowRetries: allowRetries,
        redactDiagnostics: redactDiagnostics,
      );
}

final class _DistinctUploadKeys implements Interceptor {
  final _seen = <String>{};
  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) {
    final keys = context.request.headers.entries.where(
      (entry) => entry.key.toLowerCase() == 'idempotency-key',
    );
    for (final entry in keys) {
      if (!_seen.add(entry.value)) {
        throw const FormatException(
          'Agent files: do not reuse one Idempotency-Key across uploads.',
        );
      }
    }
    return next(context);
  }
}
