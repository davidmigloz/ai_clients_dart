part of 'agent_session_models.dart';

/// Checks the documented saved/inline and initial-input creation conditions.
void _validateAgentSessionCreation({
  required String? agentId,
  required AgentSessionAgentConfig? agent,
  required AgentSessionEnvironment environment,
  required AgentSessionInitialInput? input,
  required bool stream,
}) {
  if (agentId == null && agent?.model == null) {
    throw const FormatException(
      'Session creation requires agentId or agent.model',
    );
  }
  if ((environment.type == 'none' ||
          (stream && environment.type != 'self_hosted')) &&
      input == null) {
    throw const FormatException(
      'Session creation requires initial input for this mode',
    );
  }
}

/// Bounds the runtime input and output-schema JSON, without counting archives.
///
/// The service adds metadata of its own, so this local check cannot promise
/// that an input at the boundary fits the final runtime envelope.
void _validateAgentSessionRuntimeBudget(Map<String, dynamic> body) {
  var size = 0;
  if (body['input'] != null) {
    size += utf8.encode(jsonEncode(body['input'])).length;
  }
  final agent = body['agent'];
  if (agent is Map<String, dynamic>) {
    final text = agent['text'];
    if (text is Map<String, dynamic>) {
      final format = text['format'];
      if (format is Map<String, dynamic> && format['schema'] != null) {
        size += utf8.encode(jsonEncode(format['schema'])).length;
      }
    }
  }
  if (size > 4194304) {
    throw const FormatException(
      'Session input and output schema exceed the 4 MiB runtime JSON limit',
    );
  }
}

/// Checks the submitted field values and option's 120 KiB compact JSON budget.
void _validateAgentSessionAuthenticationBudget(Map<String, dynamic> body) {
  final values = Map<String, dynamic>.of(body)
    ..remove('type')
    ..remove('action');
  if (utf8.encode(jsonEncode(values)).length > 122880) {
    throw const FormatException(
      'Browser authentication values exceed the 120 KiB JSON limit',
    );
  }
}

/// Checks source restrictions for a nonempty blocked-domain list.
void _validateAgentSessionNetwork(
  String access,
  List<String>? allowed,
  List<String>? blocked,
) {
  if (blocked == null || blocked.isEmpty) return;
  if (access != 'restricted' || (allowed != null && allowed.isNotEmpty)) {
    throw const FormatException(
      'Blocked domains require restricted access and no allowed domains',
    );
  }
  if (blocked.any((domain) => domain.contains('*'))) {
    throw const FormatException('Blocked domains do not support wildcards');
  }
}

/// Checks the source's absolute directory shape without reading a filesystem.
void _validateAgentSessionAbsolutePath(String path, String context) {
  if (!path.startsWith('/') || path.contains('\u0000')) {
    throw FormatException('$context: expected an absolute path');
  }
}

/// Checks a file destination stays inside the documented workspace root.
void _validateAgentSessionWorkspacePath(String path) {
  _validateAgentSessionAbsolutePath(path, 'Hosted file path');
  final segments = path.split('/');
  if (segments.length < 3 || segments[1] != 'workspace') {
    throw const FormatException(
      'Hosted file path: expected a destination inside /workspace',
    );
  }
  var depth = 0;
  for (final segment in segments.skip(2)) {
    if (segment == '..') {
      if (depth == 0) {
        throw const FormatException(
          'Hosted file path: cannot escape /workspace',
        );
      }
      depth--;
    } else if (segment.isNotEmpty && segment != '.') {
      depth++;
    }
  }
}

/// Checks standard base64 syntax; ZIP/content processing belongs to the service.
void _validateAgentSessionBase64(
  String data,
  String context, {
  int? maxDecodedBytes,
}) {
  if (!RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(data)) {
    throw FormatException('$context: expected standard base64');
  }
  try {
    final decoded = base64.decode(data);
    if (maxDecodedBytes != null && decoded.length > maxDecodedBytes) {
      throw FormatException('$context: decoded bytes exceed the source limit');
    }
  } on FormatException {
    throw FormatException('$context: expected standard base64');
  }
}

/// Bounds one follow-up input event submission to the documented runtime size.
void _validateAgentSessionEventRuntimeBudget(Map<String, dynamic> body) {
  if (utf8.encode(jsonEncode(body)).length > 4194304) {
    throw const FormatException(
      'Session events exceed the 4 MiB runtime JSON limit',
    );
  }
}

/// Checks the shared hosted-file creation budget from the frozen file guide.
/// Inline content is at most 5 MiB each and 10 MiB per creation configuration.
/// Files API references and capability ZIP archives have separate service limits.
void validateAgentHostedFileBudget(
  List<AgentSessionHostedEnvironmentFileConfig>? files,
) {
  var total = 0;
  for (final file in files ?? <AgentSessionHostedEnvironmentFileConfig>[]) {
    if (file is AgentSessionHostedEnvironmentFileConfigInline) {
      // Individual validation establishes standard-base64 syntax and padding.
      file.validate();
      final data = file.data;
      final padding = data.endsWith('==')
          ? 2
          : data.endsWith('=')
          ? 1
          : 0;
      total += data.length ~/ 4 * 3 - padding;
    }
  }
  if (total > 10485760) {
    throw const FormatException(
      'Hosted inline files exceed the 10 MiB creation limit',
    );
  }
}
