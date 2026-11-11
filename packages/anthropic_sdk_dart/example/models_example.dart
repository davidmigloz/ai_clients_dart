// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Lists active models by page and inspects model capabilities.
///
/// Run with ANTHROPIC_API_KEY set in the environment.
Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();
  try {
    const lifecycle = [ModelLifecycle.active];
    final firstPage = await client.models.list(limit: 5, lifecycle: lifecycle);
    for (final model in firstPage.data) {
      print('${model.id} (${model.line ?? model.displayName})');
    }

    final nextCursor = firstPage.lastId;
    if (firstPage.hasMore && nextCursor != null) {
      final secondPage = await client.models.list(
        afterId: nextCursor,
        limit: 5,
        lifecycle: lifecycle,
      );
      print('Models on the next page: ${secondPage.data.length}');
    }

    // Look up current capabilities before choosing a feature or thinking mode.
    final model = await client.models.retrieve('claude-sonnet-5-5');
    print('Lifecycle: ${model.lifecycle?.value ?? 'unreported'}');
    print(
      'Supports thinking between tools: '
      '${model.capabilities?.thinking.types.betweenTools?.supported}',
    );
    print(
      'Supports server web search: '
      '${model.capabilities?.serverTools?.webSearch.supported}',
    );
  } finally {
    client.close();
  }
}
