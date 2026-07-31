import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/dreams/create_dream_request.dart';
import '../models/dreams/dream.dart';
import '../models/dreams/dream_status.dart';
import '../models/dreams/list_dreams_response.dart';
import 'base_resource.dart';

/// Beta header for the Dreams API.
const _betaHeader = 'dreaming-2026-04-21';

/// Resource for the Dreams API (Beta, research preview).
///
/// A dream is an asynchronous memory-consolidation job that reads a memory
/// store plus a set of session transcripts and writes consolidated memories
/// into a new output memory store. This is a research preview: request and
/// response shapes are volatile and may change without the deprecation
/// period that applies to generally-available endpoints. This is a beta
/// feature and requires the `anthropic-beta` header.
class DreamsResource extends ResourceBase {
  /// Creates a [DreamsResource].
  DreamsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates a new dream.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<Dream> create(
    CreateDreamRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/dreams');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Dream.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Lists dreams.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of dreams to return.
  /// - [page]: Pagination token from a previous response.
  /// - [includeArchived]: Whether to include archived dreams.
  /// - [statuses]: Filter dreams by status. Multiple values are OR-ed.
  /// - [createdAtGt]: Filter dreams created strictly after this ISO 8601
  ///   timestamp (exclusive lower bound).
  /// - [createdAtLt]: Filter dreams created strictly before this ISO 8601
  ///   timestamp (exclusive upper bound).
  /// - [abortTrigger]: Allows canceling the request.
  Future<ListDreamsResponse> list({
    int? limit,
    String? page,
    bool? includeArchived,
    List<DreamStatus>? statuses,
    String? createdAtGt,
    String? createdAtLt,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'page': ?page,
      'include_archived': ?includeArchived?.toString(),
      'statuses[]': ?statuses?.map((s) => s.toJson()).toList(),
      'created_at[gt]': ?createdAtGt,
      'created_at[lt]': ?createdAtLt,
    };

    final url = requestBuilder.buildUrl(
      '/v1/dreams',
      queryParams: queryParams.isEmpty ? null : queryParams,
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return ListDreamsResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a specific dream.
  ///
  /// Parameters:
  /// - [dreamId]: The ID of the dream to retrieve.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Dream> retrieve(String dreamId, {Future<void>? abortTrigger}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/dreams/$dreamId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Dream.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Archives a dream.
  ///
  /// Parameters:
  /// - [dreamId]: The ID of the dream to archive.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Dream> archive(String dreamId, {Future<void>? abortTrigger}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/dreams/$dreamId/archive');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Dream.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Cancels a pending or running dream.
  ///
  /// Parameters:
  /// - [dreamId]: The ID of the dream to cancel.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Dream> cancel(String dreamId, {Future<void>? abortTrigger}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/dreams/$dreamId/cancel');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Dream.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
