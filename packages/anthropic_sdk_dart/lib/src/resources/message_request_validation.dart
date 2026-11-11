import '../client/config.dart';
import '../errors/exceptions.dart';

/// Validates fields rejected by the 2026-10-21 Messages contract.
///
/// Validate the serialized shape at the request boundary so older requests can
/// still be constructed, parsed, and sent with the legacy API version.
void validateMessageRequestVersion(
  String? apiVersion,
  Map<String, dynamic> body,
) {
  if (apiVersion?.trim() != AnthropicConfig.defaultApiVersion) return;
  _validateBody(body, '');
}

/// Applies the same version rules to every request in a message batch.
void validateBatchRequestVersion(
  String? apiVersion,
  Map<String, dynamic> body,
) {
  if (apiVersion?.trim() != AnthropicConfig.defaultApiVersion) return;
  if (body['requests'] case final List<Object?> requests) {
    for (final (index, item) in requests.indexed) {
      if (item case {'params': final Map<String, dynamic> params}) {
        _validateBody(params, 'requests[$index].params.');
      }
    }
  }
}

void _validateBody(Map<String, dynamic> body, String prefix) {
  for (final field in const ['temperature', 'top_p', 'top_k']) {
    if (body.containsKey(field)) {
      _reject('$prefix$field', 'Remove the sampling parameter');
    }
  }

  if (body['messages'] case final List<Object?> messages) {
    for (final (index, message) in messages.indexed) {
      if (message case {
        'role': final String role,
        'content': final List<Object?> blocks,
      }) {
        final field = '${prefix}messages[$index].content';
        for (final (blockIndex, block) in blocks.indexed) {
          if (block case {'type': 'document'} when role == 'assistant') {
            _reject(
              '$field[$blockIndex]',
              'Send direct document blocks in user messages',
            );
          }
          if (role == 'user') {
            _validateUserCitations(block, '$field[$blockIndex]');
          }
        }
      }
    }
  }
}

void _validateUserCitations(Object? block, String field) {
  switch (block) {
    case {'type': 'text', 'citations': final List<Object?> citations}
        when citations.isNotEmpty:
      _reject('$field.citations', 'Remove citations from user text blocks');
    case {
      'type': 'search_result' || 'tool_result' || 'mcp_tool_result',
      'content': final List<Object?> children,
    }:
      _validateUserCitationChildren(children, '$field.content');
    case {
      'type': 'document',
      'source': {'type': 'content', 'content': final List<Object?> children},
    }:
      _validateUserCitationChildren(children, '$field.source.content');
    case {
      'type': 'web_fetch_tool_result',
      'content': {
        'type': 'web_fetch_result',
        'content': final Object? document,
      },
    }:
      _validateUserCitations(document, '$field.content.content');
  }
}

void _validateUserCitationChildren(List<Object?> children, String field) {
  for (final (index, child) in children.indexed) {
    _validateUserCitations(child, '$field[$index]');
  }
}

Never _reject(String field, String advice) {
  throw ValidationException(
    fieldErrors: {
      field: [advice],
    },
    message:
        '$field is unsupported with API version '
        '${AnthropicConfig.defaultApiVersion}. $advice or explicitly '
        'configure apiVersion: AnthropicConfig.legacyApiVersion.',
  );
}
